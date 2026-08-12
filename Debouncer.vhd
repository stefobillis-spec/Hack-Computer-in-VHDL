library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Top is
    Port ( clk : in STD_LOGIC;
           button : in STD_LOGIC;
           debounced_out : out STD_LOGIC);-- := '1');
end Top;

architecture Behavioral of Top is
signal ff : std_logic_vector(1 downto 0);
signal counter_reset : std_logic;
begin

counter_reset <= ff(0) xor ff(1);

process(clk)
variable count : integer range 0 to 40000000/100; -- default 50000000/100
begin
if clk'event and clk = '1' then
    ff(0) <= button;
    ff(1) <= ff(0);
    if counter_reset = '1' then
        count := 0;
    elsif count < 40000000/100 then
        count := count + 1;
    else
        debounced_out <= ff(1);
    end if;
--    debounced_out <= button;
end if;
end process;


end Behavioral;
