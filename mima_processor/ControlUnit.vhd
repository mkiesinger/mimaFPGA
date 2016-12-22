library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use WORK.MIMACOMMONS.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ControlUnit is
    Port ( opcode : in  STD_LOGIC_VECTOR (7 downto 0);
			  clk : in  STD_LOGIC;
			  rst : in  STD_LOGIC;
			  control_wires : out  CONTROL_SIGNALS;
			  monitoring_cu : out  MONITORING_SIGNALS_CU);
end ControlUnit;

architecture Structural of ControlUnit is
	
	COMPONENT NBitRegister
	GENERIC( N : integer);
	PORT(
		din : IN std_logic_vector(N-1 downto 0);
		ce : IN std_logic;
		rst : IN std_logic;
		clk : IN std_logic;          
		dout : OUT std_logic_vector(N-1 downto 0)
		);
	END COMPONENT;

	COMPONENT UInstructionROM
	PORT(
		addr : IN std_logic_vector(7 downto 0);  
		uinstr_raw :  OUT std_logic_vector(27 downto 0);
		control_wires : OUT CONTROL_SIGNALS
		);
	END COMPONENT;
	
	COMPONENT MicroFunctionAddrROM
	PORT(
		op_addr : IN std_logic_vector(4 downto 0);
		func_entry_addr : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;

	signal next_addr_s : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	signal current_addr_s : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	signal op_addr_s : STD_LOGIC_VECTOR (4 downto 0) := (others => '0');
	signal control_wires_s : CONTROL_SIGNALS := ('0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 
																"000",'0', '0', "00", "00000000");
	signal func_entry_addr_s : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	signal uinstr_raw_s : STD_LOGIC_VECTOR(27 downto 0) := (others => '0');
	signal monitoring_cu_s : MONITORING_SIGNALS_CU := (others => (others => '0'));
	
begin
	
	op_addr_s <= '1' & opcode(3 downto 0) when opcode(7 downto 4) = "1111" else 
					'0' & opcode(7 downto 4);
	next_addr_s <= func_entry_addr_s when current_addr_s = x"FF" else
						control_wires_s.next_addr;
	
	address_reg: NBitRegister GENERIC MAP( N => 8) PORT MAP(
		din => next_addr_s,
		dout => current_addr_s,
		ce => '1',
		rst => rst,
		clk => clk
	);
	 
	u_instr_rom: UInstructionROM PORT MAP(
		addr => current_addr_s,
		uinstr_raw => uinstr_raw_s,
		control_wires => control_wires_s
	);
	
	function_entry_rom: MicroFunctionAddrROM PORT MAP(
		op_addr => op_addr_s,
		func_entry_addr => func_entry_addr_s
	);
	
	control_wires <= control_wires_s;
	monitoring_cu_s.cu_control_signals <= uinstr_raw_s;
	monitoring_cu_s.cu_current_addr <= current_addr_s;
	monitoring_cu_s.cu_next_addr <= next_addr_s;
	
	monitoring_cu <= monitoring_cu_s;

end Structural;

