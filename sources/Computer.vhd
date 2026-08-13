library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Computer is
    Generic(bits : integer := 16;
            size : integer := 15);
    Port ( system_clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           screen_clk : in STD_LOGIC;
           KBD_data : in STD_LOGIC_VECTOR (7 downto 0);
           KBD_vld : in std_logic;
           display_addr : in std_logic_vector(size-3 downto 0);
           display_data : out STD_LOGIC_VECTOR(bits-1 downto 0));
           
end Computer;

architecture Behavioral of Computer is


------------------ CPU component Declaration -------------------
component CPU is
Port (reset : in std_logic;
      clk : in std_logic;
      inM : in std_logic_vector(bits-1 downto 0);
      instr : in std_logic_vector (bits-1 downto 0);
      outM : out std_logic_vector(bits-1 downto 0);
      writeM : out std_logic;
      addrM : out std_logic_vector (bits-2 downto 0);
      prg_cntr : out std_logic_vector(bits-1 downto 0));
end component;


------------------ROM component Declaration -------------------
component roms_1 is
    Port ( 
           clk : in STD_LOGIC;
           address : in STD_LOGIC_VECTOR (bits-1 downto 0);
           data : out STD_LOGIC_VECTOR (bits-1 downto 0));
end component;


------------------ Memory component Declaration -------------------
component Memory_top is
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
           KBD_vld : in std_logic);
end component;




-------------- Intermediate Signals -----------------
signal ROM2CPU : std_logic_vector(15 downto 0);
signal PC_out : std_logic_vector(15 downto 0);
signal Mem2CPU : std_logic_vector(15 downto 0);
signal CPU2Mem : std_logic_vector(15 downto 0);
signal Mem_address : std_logic_vector(14 downto 0);
signal write : std_logic;


begin



----------------- Connections between components  ------------------

CPU1: CPU port map(reset => reset, clk => system_clk, inM => Mem2CPU, instr => ROM2CPU,
                   outM => CPU2Mem, writeM => write, addrM => Mem_address, prg_cntr => PC_out);
                   
                   
ROM1: roms_1 port map(clk => system_clk, address => PC_out, data => ROM2CPU);


Memory2: Memory_top port map(reset => reset, clk => system_clk, disp_clk => screen_clk, 
                            mem_in => CPU2Mem, addr => Mem_address(size-1 downto 0),
                            disp_addr => display_addr, disp_out => display_data, load => write,
                            mem_out => Mem2CPU, KBD_data => KBD_data, KBD_vld => KBD_vld);
                            


end Behavioral;
