library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;


entity ALU is
	generic(size : integer := 16);
	port(reset : in std_logic;
	     x : in std_logic_vector(size-1 downto 0);
	     y : in std_logic_vector(size-1 downto 0);
	     control_bits : in std_logic_vector(5 downto 0);
	     output : out std_logic_vector(size-1 downto 0);
	     zero : out std_logic := '0';
	     negative : out std_logic := '0');
end ALU;


architecture Behavioral of ALU is 
begin


process(reset,x,y,control_bits)

variable x_var : signed(size-1 downto 0);
variable y_var : signed(size-1 downto 0);
variable output_var : signed(size-1 downto 0);
begin
if reset = '0' then
x_var := signed(x);
y_var := signed(y);
	if control_bits(5) = '1' then
		x_var := (others => '0');
	end if;
	if control_bits(4) = '1' then
		x_var := not(x_var);
	end if;
	if control_bits(3) = '1' then
		y_var := (others => '0');
	end if;
	if control_bits(2) = '1' then
		y_var := not(y_var);
	end if;
	if control_bits(1) = '1' then
		output_var := x_var + y_var;
	else
		output_var := x_var and y_var;
	end if;
	if control_bits(0) = '1' then
		output_var := not(output_var);
	end if;
	
output <= std_logic_vector(output_var);
negative <= output_var(size-1);

if output_var = 0 then
	zero <= '1';
else
    zero <= '0';
end if;
end if;
end process;


end Behavioral;