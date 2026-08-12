-- Block RAM with Optional Output Registers
-- File: rams_pipeline.vhd
library IEEE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity rams_pipeline is
generic(bits : integer := 16;
        size : integer := 15);
port(clk1, clk2 : in std_logic;
     we : in std_logic;
     addr1 : in std_logic_vector(size-3 downto 0);
     addr2 : in std_logic_vector(size-3 downto 0);
     di : in std_logic_vector(bits-1 downto 0);
     res1 : out std_logic_vector(bits-1 downto 0);
     res2 : out std_logic_vector(bits-1 downto 0)
);
end rams_pipeline;

architecture beh of rams_pipeline is
type ram_type is array (2**(size-2)-1 downto 0) of std_logic_vector(bits-1 downto 0);
signal ram : ram_type := (others => "0000000000000000"); 

begin
process(clk1)
begin
if rising_edge(clk1) then
    if we = '1' then
        ram(to_integer(unsigned(addr1))) <= di;
    end if;
    res1 <= ram(to_integer(unsigned(addr1)));
end if;
end process;

process(clk2)
begin
if rising_edge(clk2) then
    res2 <= ram(to_integer(unsigned(addr2)));
end if;
end process;

end beh;
