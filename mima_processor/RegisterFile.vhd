library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use WORK.MIMACOMMONS.ALL;


entity RegisterFile is
    Port ( clk : in  STD_LOGIC;
			  rst : in  STD_LOGIC;
           alu_x : out  STD_LOGIC_VECTOR (23 downto 0);
           alu_y : out  STD_LOGIC_VECTOR (23 downto 0);
           alu_z : in  STD_LOGIC_VECTOR (23 downto 0);
           opcode : out  STD_LOGIC_VECTOR (7 downto 0);
			  control_wires : in  CONTROL_SIGNALS;
			  monitoring_regf : out  MONITORING_SIGNALS_REGF;
           mem_addr : out  STD_LOGIC_VECTOR (19 downto 0);
           mem_din : in  STD_LOGIC_VECTOR (23 downto 0);
			  mem_dout : out  STD_LOGIC_VECTOR (23 downto 0);
			  mem_sdr_we : in  STD_LOGIC);
end RegisterFile;

architecture Structural of RegisterFile is
	
	COMPONENT NBitRegister
	GENERIC( N : integer);
	PORT(
		din : IN std_logic_vector(N-1 downto 0);
		dout : OUT std_logic_vector(N-1 downto 0);
		ce : IN std_logic;
		rst : IN std_logic;
		clk : IN std_logic
		);
	END COMPONENT;
	
	type bus_arr is array (0 to 5) of STD_LOGIC_VECTOR(23 downto 0);
	signal bus_in_s : bus_arr := (others => (others => '0'));
	signal bus_rd_s : STD_LOGIC_VECTOR(23 downto 0) := (others => '0');
	signal ir_dout_s, accu_dout_s, x_dout_s, y_dout_s, z_dout_s, sdr_dout_s : STD_LOGIC_VECTOR(23 downto 0) := (others => '0');
	signal iar_dout_s, sar_dout_s : STD_LOGIC_VECTOR(19 downto 0) := (others => '0');
	signal sdr_we_s : STD_LOGIC := '0';
	signal monitoring_regf_s : MONITORING_SIGNALS_REGF := (others => (others => '0'));
	signal sdr_din_s : STD_LOGIC_VECTOR(23 downto 0) := (others => '0');
	signal sdr_mem_s, sdr_bus_rd_s : STD_LOGIC_VECTOR(23 downto 0) := (others => '0');
	
	function or_reduce_array(a : bus_arr) return std_logic_vector is
		variable ret : std_logic_vector(23 downto 0) := (others => '0');
	begin
		for i in a'range loop
			ret := ret or std_logic_vector(a(i));
		end loop;
		return ret;
	end function or_reduce_array;
	
begin
	
	bus_in_s(0) <= "0000" & ir_dout_s(19 downto 0) when control_wires.I_re = '1' else (others =>'0');
	bus_in_s(1) <= "0000" & iar_dout_s when control_wires.P_re = '1' else (others =>'0');
	bus_in_s(2) <= accu_dout_s when control_wires.A_re = '1' else (others =>'0');
	bus_in_s(3) <= z_dout_s when control_wires.Z_re = '1' else (others =>'0');
	bus_in_s(4) <= sdr_dout_s when control_wires.D_re = '1' else (others =>'0');
	bus_in_s(5) <= x"000001" when control_wires.E_re = '1' else (others => '0');
	bus_rd_s <= or_reduce_array(bus_in_s);
	
	sdr_we_s <= control_wires.D_we or mem_sdr_we;	
	sdr_mem_s <= mem_din when mem_sdr_we = '1' else (others => '0');
	sdr_bus_rd_s <= bus_rd_s when control_wires.D_we = '1' else (others => '0');
	sdr_din_s <= sdr_mem_s or sdr_bus_rd_s;
	
	ir: 	NBitRegister GENERIC MAP( N => 24) PORT MAP(bus_rd_s, ir_dout_s, control_wires.I_we, rst, clk);
	iar: 	NBitRegister GENERIC MAP( N => 20) PORT MAP(bus_rd_s(19 downto 0), iar_dout_s, control_wires.P_we, rst, clk);
	accu: NBitRegister GENERIC MAP( N => 24) PORT MAP(bus_rd_s, accu_dout_s, control_wires.A_we, rst, clk);
	x: 	NBitRegister GENERIC MAP( N => 24) PORT MAP(bus_rd_s, x_dout_s, control_wires.X_we, rst, clk);
	y: 	NBitRegister GENERIC MAP( N => 24) PORT MAP(bus_rd_s, y_dout_s, control_wires.Y_we, rst, clk);
	z: 	NBitRegister GENERIC MAP( N => 24) PORT MAP(alu_z, z_dout_s, '1', rst, clk);
	sar: 	NBitRegister GENERIC MAP( N => 20) PORT MAP(bus_rd_s(19 downto 0), sar_dout_s, control_wires.S_we, rst, clk);
	sdr: 	NBitRegister GENERIC MAP( N => 24) PORT MAP(sdr_din_s, sdr_dout_s, sdr_we_s, rst, clk);
	
	opcode <= ir_dout_s(23 downto 16);
	alu_x <= x_dout_s;
	alu_y <= y_dout_s;
	mem_dout <= sdr_dout_s;
	mem_addr <= sar_dout_s;
	
	monitoring_regf_s.regf_accu <= accu_dout_s;
	monitoring_regf_s.regf_x <= x_dout_s;
	monitoring_regf_s.regf_y <= y_dout_s;
	monitoring_regf_s.regf_z <= z_dout_s;
	monitoring_regf_s.regf_ir <= ir_dout_s;
	monitoring_regf_s.regf_iar <= iar_dout_s;
	monitoring_regf_s.regf_sar <= sar_dout_s;
	monitoring_regf_s.regf_sdr <= sdr_dout_s;
	monitoring_regf_s.regf_bus <= bus_rd_s;
	monitoring_regf <= monitoring_regf_s;
	
	
end Structural;

