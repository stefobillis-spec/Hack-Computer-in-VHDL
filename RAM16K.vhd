library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rams_dist is
generic(bits : integer := 16;
        size : integer := 15);
port(
clk : in std_logic;
we : in std_logic;
a : in std_logic_vector(size-2 downto 0);
di : in std_logic_vector(bits-1 downto 0);
do : out std_logic_vector(bits-1 downto 0)
);
end rams_dist;

architecture syn of rams_dist is
type ram_type is array (2**(size-1)-1 downto 0) of std_logic_vector(bits-1 downto 0);
signal RAM : ram_type := (others => "0000000000000000");
begin
process(clk)
begin
if (clk'event and clk = '1') then
    if (we = '1') then
        RAM(to_integer(unsigned(a))) <= di;
    end if;
end if;
end process;

do <= RAM(to_integer(unsigned(a)));

end syn;