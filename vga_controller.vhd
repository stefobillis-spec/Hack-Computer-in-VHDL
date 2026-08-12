-- VGA Controller for monochrome 512x256 framebuffer via Pmod VGA
-- File: vga_controller.vhd
--
-- Displays a 512x256 monochrome image (stored in your dual-port VRAM,
-- 16 pixels/word, MSB = leftmost pixel) centered inside a standard
-- 640x480 @ 60Hz VGA signal (25 MHz pixel clock, negative sync polarity).
-- Border pixels (outside the 512x256 window) are driven black.
--
-- CLOCKING: clk_pix MUST be a true 25 MHz clock (e.g. from a Clocking
-- Wizard / MMCM), not a divided "clock enable". Drive clk2 of your
-- rams_pipeline instance with this SAME clock.
--
-- LATENCY HANDLING: rams_pipeline registers res2 one clock cycle after
-- addr2 is presented. This controller compensates by generating the
-- pixel/sync timing from h_count/v_count, then delaying those exact
-- same counters by one clock (h_count_d/v_count_d) so that the delayed
-- signals line up with vram_data the cycle it actually arrives. No
-- shift registers or state machines needed -- just a one-cycle pipeline.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_controller is
    generic(
        -- 640x480 @ 60Hz VESA timing (25 MHz pixel clock)
        H_VISIBLE : integer := 640;
        H_FRONT   : integer := 16;
        H_SYNC    : integer := 96;
        H_BACK    : integer := 48;
        V_VISIBLE : integer := 480;
        V_FRONT   : integer := 10;
        V_SYNC    : integer := 2;
        V_BACK    : integer := 33;

        -- Framebuffer image size (must match VRAM contents: 512x256,
        -- 16 pixels/word => 32 words/row x 256 rows = 8192 words)
        IMG_W     : integer := 512;
        IMG_H     : integer := 256
    );
    port(
        clk_pix   : in  std_logic;                      -- 25 MHz pixel clock
        rst       : in  std_logic;                      -- sync reset, active high

        -- Connect directly to rams_pipeline's addr2 / res2 (clk2 = clk_pix)
        vram_addr : out std_logic_vector(12 downto 0);
        vram_data : in  std_logic_vector(15 downto 0);

        -- Pmod VGA signals
        hsync     : out std_logic;
        vsync     : out std_logic;
        red       : out std_logic_vector(3 downto 0);
        green     : out std_logic_vector(3 downto 0);
        blue      : out std_logic_vector(3 downto 0)
    );
end vga_controller;

architecture rtl of vga_controller is

    constant H_TOTAL  : integer := H_VISIBLE + H_FRONT + H_SYNC + H_BACK; -- 800
    constant V_TOTAL  : integer := V_VISIBLE + V_FRONT + V_SYNC + V_BACK; -- 525
    constant H_OFFSET : integer := (H_VISIBLE - IMG_W) / 2;               -- 64
    constant V_OFFSET : integer := (V_VISIBLE - IMG_H) / 2;               -- 112

    -- raster position counters
    signal h_count   : unsigned(9 downto 0) := (others => '0');
    signal v_count   : unsigned(9 downto 0) := (others => '0');

    -- one-cycle-delayed copies, to realign with the RAM's 1-cycle read latency
    signal h_count_d : unsigned(9 downto 0) := (others => '0');
    signal v_count_d : unsigned(9 downto 0) := (others => '0');

    -- sync/blank generated from the CURRENT counters, then delayed
    signal hsync_i, vsync_i : std_logic := '1';
    signal hsync_d, vsync_d : std_logic := '1';

    -- is the CURRENT pixel inside the 512x256 image window?
    signal in_image_i : std_logic := '0';
    signal in_image_d : std_logic := '0';

    -- which of the 16 pixels in the current word this pixel is (0 = leftmost)
    signal bit_sel_i : unsigned(3 downto 0) := (others => '0');
    signal bit_sel_d : unsigned(3 downto 0) := (others => '0');

    signal img_x : unsigned(9 downto 0);
    signal img_y : unsigned(9 downto 0);

    signal pixel_bit : std_logic;

begin

    -- Position within the image (only meaningful when in_image_i = '1')
    img_x <= h_count - to_unsigned(H_OFFSET, h_count'length);
    img_y <= v_count - to_unsigned(V_OFFSET, v_count'length);

    in_image_i <= '1' when (h_count >= H_OFFSET) and (h_count < H_OFFSET + IMG_W) and
                            (v_count >= V_OFFSET) and (v_count < V_OFFSET + IMG_H)
                  else '0';

    -- VRAM address = row*32 + word_column, formed directly by concatenation
    -- (row = img_y(7:0), word_column = img_x(8:4) i.e. img_x/16)
    -- bit_sel = img_x(3:0) i.e. img_x mod 16 (0 = leftmost pixel = MSB)
    vram_addr <= std_logic_vector(img_y(7 downto 0) & img_x(8 downto 4));
    bit_sel_i <= img_x(3 downto 0);

    hsync_i <= '0' when (h_count >= H_VISIBLE + H_FRONT) and
                         (h_count <  H_VISIBLE + H_FRONT + H_SYNC)
               else '1';

    vsync_i <= '0' when (v_count >= V_VISIBLE + V_FRONT) and
                         (v_count <  V_VISIBLE + V_FRONT + V_SYNC)
               else '1';

    -- Single synchronous process: raster counters + the one-cycle
    -- delay/realignment stage that matches the RAM's read latency.
    process(clk_pix)
    begin
        if rising_edge(clk_pix) then
            if rst = '1' then
                h_count <= (others => '0');
                v_count <= (others => '0');
            else
                if h_count = H_TOTAL - 1 then
                    h_count <= (others => '0');
                    if v_count = V_TOTAL - 1 then
                        v_count <= (others => '0');
                    else
                        v_count <= v_count + 1;
                    end if;
                else
                    h_count <= h_count + 1;
                end if;
            end if;

            -- Delay everything computed from h_count/v_count by exactly
            -- one clock so it lines up with vram_data (which reflects the
            -- address that was driven on the PREVIOUS clock edge).
            h_count_d   <= h_count;
            v_count_d   <= v_count;
            hsync_d     <= hsync_i;
            vsync_d     <= vsync_i;
            in_image_d  <= in_image_i;
            bit_sel_d   <= bit_sel_i;
        end if;
    end process;

    -- Select the correct pixel bit (MSB = leftmost) from the word that
    -- just arrived on vram_data, using the DELAYED bit index so it
    -- matches the pixel that address was actually for.
    pixel_bit <= not(vram_data(15 - to_integer(bit_sel_d))) when in_image_d = '1' else '0';

    hsync <= hsync_d;
    vsync <= vsync_d;

    -- Monochrome: drive R, G, and B identically -> white or black.
    -- pixel_bit is already forced to '0' outside the image window,
    -- which is always inside the visible 640x480 area, so no separate
    -- blanking check is needed here.
    red   <= (others => pixel_bit);
    green <= (others => pixel_bit);
    blue  <= (others => pixel_bit);

end rtl;