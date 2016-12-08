library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use WORK.MIMACOMMONS.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ScreenController is
    Port ( en : in  STD_LOGIC;
			  monitoring_mima : in  MONITORING_SIGNALS;
			  monitoring_freq : in  STD_LOGIC_VECTOR(25 downto 0);
			  screen_mem_addr : out  STD_LOGIC_VECTOR(12 downto 0);
			  screen_mem_din :  in  STD_LOGIC_VECTOR(15 downto 0);
			  r : OUT STD_LOGIC_VECTOR(4 downto 0);
			  g : OUT STD_LOGIC_VECTOR(5 downto 0);
			  b : OUT STD_LOGIC_VECTOR(4 downto 0);
			  hsync : OUT STD_LOGIC;
			  vsync : OUT STD_LOGIC;
			  io_screen_sel : in  STD_LOGIC;
			  clk40 : in  STD_LOGIC);
end ScreenController;

architecture Structural of ScreenController is
	
	COMPONENT PerformanceMonitorVGA
	PORT(
		clk40 : IN std_logic;
		en : IN std_logic;
		num_din : IN std_logic_vector(31 downto 0);          
		num_addr : OUT std_logic_vector(3 downto 0);
		r : OUT std_logic_vector(4 downto 0);
		g : OUT std_logic_vector(5 downto 0);
		b : OUT std_logic_vector(4 downto 0);
		x : OUT std_logic_vector(9 downto 0);
		y : OUT std_logic_vector(9 downto 0);
		hsync : OUT std_logic;
		vsync : OUT std_logic;
		blank : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT ScreenToMemAddrConverter
	PORT(
		x : IN std_logic_vector(9 downto 0);
		y : IN std_logic_vector(9 downto 0);
		din : IN std_logic_vector(15 downto 0);
		clk : IN std_logic;          
		addr : OUT std_logic_vector(12 downto 0);
		pixel : OUT std_logic
		);
	END COMPONENT;
	
	signal perf_mon_din_s : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
	signal perf_mon_addr_s : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
	type perf_mon_arr is ARRAY(0 to 15) of STD_LOGIC_VECTOR(31 downto 0);
	signal perf_mon_mux_s : perf_mon_arr := (others => (others => '0'));
	
	signal r_s : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
	signal g_s : STD_LOGIC_VECTOR(5 downto 0) := (others => '0');
	signal b_s : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
	signal blank_s : STD_LOGIC := '0';
	
	signal x_s, y_s : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
	signal screen_pixel_s : STD_LOGIC := '0';
	
	function mux(a : perf_mon_arr; sel : std_logic_vector(3 downto 0)) return std_logic_vector is
	begin
		return a(to_integer(unsigned(sel)));
	end function mux;
	
begin

	performance_monitor: PerformanceMonitorVGA PORT MAP(
		clk40 => clk40,
		en => en,
		num_din => perf_mon_din_s,
		num_addr => perf_mon_addr_s,
		r => r_s,
		g => g_s,
		b => b_s,
		x => x_s,
		y => y_s,
		hsync => hsync,
		vsync => vsync,
		blank => blank_s
	);
	
	screen_xy_to_addr: ScreenToMemAddrConverter PORT MAP(
		x => x_s,
		y => y_s,
		addr => screen_mem_addr,
		din => screen_mem_din,
		pixel => screen_pixel_s,
		clk => clk40
	);
	
	perf_mon_mux_s(0) <= x"00" & monitoring_mima.regf_accu;
	perf_mon_mux_s(1) <= x"00" & monitoring_mima.regf_x;
	perf_mon_mux_s(2) <= x"00" & monitoring_mima.regf_y;
	perf_mon_mux_s(3) <= x"00" & monitoring_mima.regf_z;
	perf_mon_mux_s(4) <= x"00" & monitoring_mima.regf_ir;
	perf_mon_mux_s(5) <= x"000" & monitoring_mima.regf_iar;
	perf_mon_mux_s(6) <= x"000" & monitoring_mima.regf_sar;
	perf_mon_mux_s(7) <= x"00" & monitoring_mima.regf_sdr;
	perf_mon_mux_s(8) <= x"00" & monitoring_mima.regf_bus;
	perf_mon_mux_s(9) <= x"0" & monitoring_mima.cu_control_signals;
	perf_mon_mux_s(10) <= x"000000" & monitoring_mima.cu_current_addr;
	perf_mon_mux_s(11) <= x"000000" & monitoring_mima.cu_next_addr;
	perf_mon_mux_s(12) <= "000000" & monitoring_freq;
	
	perf_mon_din_s <= mux(perf_mon_mux_s, perf_mon_addr_s);
	
	r <= r_s when io_screen_sel = '0' and blank_s = '0' else 
		(others => screen_pixel_s) when io_screen_sel = '1' and blank_s = '0' else
		(others => '0');
	g <= g_s when io_screen_sel = '0' and blank_s = '0' else 
		(others => screen_pixel_s) when io_screen_sel = '1' and blank_s = '0' else
		(others => '0');
	b <= b_s when io_screen_sel = '0' and blank_s = '0' else 
		(others => screen_pixel_s) when io_screen_sel = '1' and blank_s = '0' else
		(others => '0');
	
end Structural;

