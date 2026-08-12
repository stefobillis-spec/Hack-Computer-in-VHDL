library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

------------------- Entity Declaration -------------------
entity CPU is
Generic (bits : integer := 16);
Port (reset : in std_logic;
      clk : in std_logic;
      inM : in std_logic_vector(bits-1 downto 0);
      instr : in std_logic_vector (bits-1 downto 0);
      outM : out std_logic_vector(bits-1 downto 0);
      writeM : out std_logic;
      addrM : out std_logic_vector (bits-2 downto 0);
      prg_cntr : out std_logic_vector(bits-1 downto 0));
end CPU;

architecture Behavioral of CPU is

--------------------- ALU declaration -------------------
component ALU is
	generic(size : integer := 16);
	port(reset : in std_logic; 
	     x : in std_logic_vector(size-1 downto 0);
	     y : in std_logic_vector(size-1 downto 0);
	     control_bits : in std_logic_vector(5 downto 0);
	     output : out std_logic_vector(size-1 downto 0);
	     zero : out std_logic;
	     negative : out std_logic);
    end component;

---------------------- PC declaration ----------------------  
component PC is
    Generic(bits : integer := 16);
    Port ( input : in STD_LOGIC_VECTOR (bits-1 downto 0);
           clk : in STD_LOGIC;
           load : in STD_LOGIC;
           inc : in STD_LOGIC;
           reset : in STD_LOGIC;
           output : out STD_LOGIC_VECTOR (bits-1 downto 0));
end component;

------------------ Intermediate signals -------------------
signal A_reg : std_logic_vector(bits-1 downto 0);
signal D_reg : std_logic_vector(bits-1 downto 0);
signal alu_y_in : std_logic_vector(bits-1 downto 0);
signal ALUout : std_logic_vector(bits-1 downto 0);
signal zr : std_logic := '0';
signal neg : std_logic := '0';
signal pos : std_logic := '0';


----------------- Control signals ------------------------
signal loadPC : std_logic := '0';
signal jump : std_logic := '0';



begin

----------------- Control signals logic -------------------
pos <= not(neg or zr); 
jump <= (instr(2) and neg) or (instr(1) and zr) or (instr(0) and pos);
loadPC <= jump and instr(15);

---------------- I/O signals logic -----------------------
outM <= ALUout; 
writeM <= instr(15) and instr(3); 
addrM <= A_reg(bits-2 downto 0);

-------------- ALU y input -----------------------
alu_y_in <= inM when instr(12) = '1' else A_reg;



---------------- ALU component instantiation -------------
ALU1: ALU port map(reset => reset, x => D_reg, y => alu_y_in,
	     control_bits => instr(11 downto 6), output => ALUout, zero => zr, negative => neg);
	     
----------------- PC component instantiation -------------
PC1: PC port map(input => A_reg, clk => clk, load => loadPC,
                 inc => '1', reset => reset, output => prg_cntr);



A_reg_proc: process(clk,reset)
begin
if reset = '1' then
    A_reg <= (others => '0');
elsif rising_edge(clk) then
    if instr(15) = '0' then
        A_reg <= instr;
    elsif (instr(15) and instr(5)) = '1' then
        A_reg <= ALUout;
        
end if;
end if;
end process;

--------------- D register process -------------------
D_reg_proc: process(clk,reset)
begin
if reset = '1' then
    D_reg <= (others => '0');
elsif rising_edge(clk) then
if (instr(15) and instr(4)) = '1' then 
    D_reg <= ALUout;
end if;
end if;
end process;



end Behavioral;
