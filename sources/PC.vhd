library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;


entity PC is
    Generic(bits : integer := 16);
    Port ( input : in STD_LOGIC_VECTOR (bits-1 downto 0);
           clk : in STD_LOGIC;
           load : in STD_LOGIC;
           inc : in STD_LOGIC;
           reset : in STD_LOGIC;
           output : out STD_LOGIC_VECTOR (bits-1 downto 0));
end PC;

architecture Behavioral of PC is
signal outval : unsigned(bits-1 downto 0) := (others => '0'); 

begin


output <= std_logic_vector(outval);

process(clk)
begin
if rising_edge(clk) then
if reset = '1' then
    outval <= (others => '0');
else
    if load = '1' then
        outval <= unsigned(input(bits-1 downto 0));
    else
        if inc = '1' then
            outval <= outval + 1;
        else
            outval <= outval;
        end if;
    end if;
end if;
end if;
end process;

end Behavioral;
