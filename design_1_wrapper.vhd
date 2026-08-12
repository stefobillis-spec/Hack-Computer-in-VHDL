library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1_wrapper is
  port (
    UART_RXD_0 : in STD_LOGIC;
    UART_TXD_0 : out STD_LOGIC;
    blue_0 : out STD_LOGIC_VECTOR ( 3 downto 0 );
    button_0 : in STD_LOGIC;
    clk_in1_0 : in STD_LOGIC;
    green_0 : out STD_LOGIC_VECTOR ( 3 downto 0 );
    hsync_0 : out STD_LOGIC;
    red_0 : out STD_LOGIC_VECTOR ( 3 downto 0 );
    vsync_0 : out STD_LOGIC
  );
end design_1_wrapper;

architecture STRUCTURE of design_1_wrapper is
  component design_1 is
  port (
    clk_in1_0 : in STD_LOGIC;
    button_0 : in STD_LOGIC;
    UART_RXD_0 : in STD_LOGIC;
    UART_TXD_0 : out STD_LOGIC;
    green_0 : out STD_LOGIC_VECTOR ( 3 downto 0 );
    red_0 : out STD_LOGIC_VECTOR ( 3 downto 0 );
    vsync_0 : out STD_LOGIC;
    hsync_0 : out STD_LOGIC;
    blue_0 : out STD_LOGIC_VECTOR ( 3 downto 0 )
  );
  end component design_1;
begin
design_1_i: component design_1
     port map (
      UART_RXD_0 => UART_RXD_0,
      UART_TXD_0 => UART_TXD_0,
      blue_0(3 downto 0) => blue_0(3 downto 0),
      button_0 => button_0,
      clk_in1_0 => clk_in1_0,
      green_0(3 downto 0) => green_0(3 downto 0),
      hsync_0 => hsync_0,
      red_0(3 downto 0) => red_0(3 downto 0),
      vsync_0 => vsync_0
    );
end STRUCTURE;
