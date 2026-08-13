library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Memory_top is
    Generic( size : integer := 15;
             bits : integer := 16);
    Port ( reset : in STD_LOGIC;
           clk : in STD_LOGIC;
           disp_clk : in STD_LOGIC;
           mem_in : in STD_LOGIC_VECTOR (bits-1 downto 0);
           addr : in STD_LOGIC_VECTOR (size-1 downto 0);
           disp_addr : in STD_LOGIC_VECTOR (size-3 downto 0);
           disp_out : out STD_LOGIC_VECTOR (bits-1 downto 0);
           load : in STD_LOGIC;
           mem_out : out STD_LOGIC_VECTOR (bits-1 downto 0);
           KBD_data : in STD_LOGIC_VECTOR (7 downto 0);
           KBD_vld : in STD_LOGIC);
end Memory_top;

architecture Behavioral of Memory_top is

component rams_dist is
port(clk : in std_logic;
     we : in std_logic;
     a : in std_logic_vector(size-2 downto 0);
     di : in std_logic_vector(bits-1 downto 0);
     do : out std_logic_vector(bits-1 downto 0));
end component;

component rams_pipeline is
port(clk1, clk2 : in std_logic;
     we : in std_logic;
     addr1 : in std_logic_vector(size-3 downto 0);
     addr2 : in std_logic_vector(size-3 downto 0);
     di : in std_logic_vector(bits-1 downto 0);
     res1 : out std_logic_vector(bits-1 downto 0);
     res2 : out std_logic_vector(bits-1 downto 0));
end component;


signal address : std_logic_vector(size-1 downto 0);
signal input : std_logic_vector(bits-1 downto 0);
signal ram_out : std_logic_vector(bits-1 downto 0);
signal screen_out : std_logic_vector(bits-1 downto 0);
signal load_ram : std_logic;
signal load_screen : std_logic;

signal clear_addr : unsigned(size-1 downto 0) := (others => '0'); 
signal done_clear : std_logic := '0';

signal KBD_reg : std_logic_vector(7 downto 0) := (others => '0');
signal counter : unsigned(22 downto 0) := (others => '0');

begin

RAM: rams_dist port map(clk => clk, we => load_ram, a => address(size-2 downto 0), di => input,
                        do => ram_out);
          
SCREEN: rams_pipeline port map(clk1 => clk, clk2 => disp_clk, we => load_screen,
                               addr1 => address(size-3 downto 0), addr2 => disp_addr, 
                               di => input, res1 => screen_out, res2 => disp_out);
                             
                             
                               

load_ram <= (load and not(addr(size-1))) when reset = '0' else '1';
load_screen <= (load and (addr(size-1) and not(addr(size-2)))) when reset = '0' else '1';

address <= addr when reset = '0' else std_logic_vector(clear_addr);
input <= mem_in when reset = '0' else (others => '0');


KBD: process(clk)
begin
    if rising_edge(clk) then
        if reset = '1' then
            KBD_reg <= (others => '0');
            counter  <= (others => '0');
        else
            if KBD_vld = '1' then
                KBD_reg <= KBD_data;
                counter  <= (others => '0');  -- restart the 50 ms window
            else
                if KBD_reg /= "00000000" then  -- only count while holding a value
                    if counter = 2000 - 1 then    -- 50 us at 40 MHz
                        KBD_reg <= (others => '0');
                        counter  <= (others => '0');
                    else
                        counter <= counter + 1;
                    end if;
                end if;
            end if;
        end if;
    end if;
end process;




clear: process(clk)
begin
if rising_edge(clk) then
if reset = '1' then
    if done_clear = '0' then
        if clear_addr < (2**(size-1)+2**(size-2)) then
            clear_addr <= clear_addr + 1;
        else
            clear_addr <= (others => '0');
            done_clear <= '1';
        end if;
    else
        clear_addr <= (others => '0');
    end if;
else
    clear_addr <= (others => '0');
    done_clear <= '0';
end if;
end if;
end process;




OUTPUT: process(address,screen_out,ram_out,KBD_data,KBD_reg,reset) 
begin
if reset = '1' then
    mem_out <= (others => '0');
else
if (address(size-2) and address(size-1)) = '1' then
    mem_out <= "00000000" & KBD_reg;
else
    if address(size-1) = '1' then
        mem_out <= screen_out;
    else 
        mem_out <= ram_out;
    end if;
end if;
end if;
end process;



end Behavioral;
