library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use WORK.MIMACOMMONS.ALL;


entity MIMAProcessor is
    Port ( mem_addr : out  STD_LOGIC_VECTOR (19 downto 0);
           mem_din : in  STD_LOGIC_VECTOR (23 downto 0);
			  mem_dout : out  STD_LOGIC_VECTOR (23 downto 0);
			  mem_re : out  STD_LOGIC;
			  mem_we : out  STD_LOGIC;
			  mem_sdr_we : in  STD_LOGIC;
			  monitoring : out  MONITORING_SIGNALS;
           clk : in  STD_LOGIC;
			  rst : in  STD_LOGIC);
end MIMAProcessor;

architecture Structural of MIMAProcessor is
	
	COMPONENT RegisterFile
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		alu_z : IN std_logic_vector(23 downto 0);
		control_wires : IN CONTROL_SIGNALS;
		monitoring_regf : OUT MONITORING_SIGNALS_REGF;
		mem_din : IN std_logic_vector(23 downto 0);
		mem_sdr_we : IN std_logic;          
		alu_x : OUT std_logic_vector(23 downto 0);
		alu_y : OUT std_logic_vector(23 downto 0);
		opcode : OUT std_logic_vector(7 downto 0);
		mem_addr : OUT std_logic_vector(19 downto 0);
		mem_dout : OUT std_logic_vector(23 downto 0)
		);
	END COMPONENT;
	
	COMPONENT ALU
	PORT(
		x : IN std_logic_vector(23 downto 0);
		y : IN std_logic_vector(23 downto 0);
		func : IN std_logic_vector(2 downto 0);          
		z : OUT std_logic_vector(23 downto 0)
		);
	END COMPONENT;

	COMPONENT ControlUnit
	PORT(
		opcode : IN std_logic_vector(7 downto 0);
		clk : IN std_logic; 
		rst : IN std_logic;
		control_wires : OUT CONTROL_SIGNALS;
		monitoring_cu : OUT MONITORING_SIGNALS_CU
		);
	END COMPONENT;
	
	signal alu_x_s : STD_LOGIC_VECTOR(23 downto 0) := (others => '0');
	signal alu_y_s : STD_LOGIC_VECTOR(23 downto 0) := (others => '0');
	signal alu_z_s : STD_LOGIC_VECTOR(23 downto 0) := (others => '0');
	signal opcode_s : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	
	signal control_wires_s : CONTROL_SIGNALS := ('0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 
																"000",'0', '0', "00", "00000000");
	signal monitoring_regf_s : MONITORING_SIGNALS_REGF := (others => (others => '0'));
	signal monitoring_cu_s : MONITORING_SIGNALS_CU := (others => (others => '0'));
	
begin
	
	reg_file: RegisterFile PORT MAP(
		clk => clk,
		rst => rst,
		alu_x => alu_x_s,
		alu_y => alu_y_s,
		alu_z => alu_z_s,
		opcode => opcode_s,
		control_wires => control_wires_s,
		monitoring_regf => monitoring_regf_s,
		mem_addr => mem_addr,
		mem_din => mem_din,
		mem_dout => mem_dout,
		mem_sdr_we => mem_sdr_we
	);
	
	arithmetic_logic_unit: ALU PORT MAP(
		x => alu_x_s,
		y => alu_y_s,
		func => control_wires_s.c,
		z => alu_z_s
	);
	
	cu: ControlUnit PORT MAP(
		opcode => opcode_s,
		clk => clk,
		rst => rst,
		control_wires => control_wires_s,
		monitoring_cu => monitoring_cu_s
	);
	
	monitoring.regf_accu <= monitoring_regf_s.regf_accu;
	monitoring.regf_x <= monitoring_regf_s.regf_x; 
	monitoring.regf_y <= monitoring_regf_s.regf_y; 
	monitoring.regf_z <= monitoring_regf_s.regf_z; 
	monitoring.regf_ir <= monitoring_regf_s.regf_ir; 
	monitoring.regf_iar <= monitoring_regf_s.regf_iar; 
	monitoring.regf_sar <= monitoring_regf_s.regf_sar; 
	monitoring.regf_sdr <= monitoring_regf_s.regf_sdr; 
	monitoring.regf_bus <= monitoring_regf_s.regf_bus; 
	monitoring.cu_control_signals <= monitoring_cu_s.cu_control_signals;
	monitoring.cu_current_addr <= monitoring_cu_s.cu_current_addr;
	monitoring.cu_next_addr <= monitoring_cu_s.cu_next_addr; 
	
	mem_re <= control_wires_s.r;
	mem_we <= control_wires_s.w;

end Structural;

