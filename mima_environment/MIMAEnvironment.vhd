library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use WORK.MIMACOMMONS.ALL;


entity MIMAEnvironment is
	 Port ( clk : in  STD_LOGIC;
			  reset : in  STD_LOGIC;
			  r : out  STD_LOGIC_VECTOR(4 downto 0);
			  g : out  STD_LOGIC_VECTOR(5 downto 0);
			  b : out  STD_LOGIC_VECTOR(4 downto 0);
			  hsync : out  STD_LOGIC;
			  vsync : out  STD_LOGIC;
			  screen_select : in  STD_LOGIC;
			  speed_up : in  STD_LOGIC;
			  speed_down : in  STD_LOGIC;
			  ps2_clk : in  STD_LOGIC;
			  ps2_data : in  STD_lOGIC);
end MIMAEnvironment;

architecture Structural of MIMAEnvironment is
	
	COMPONENT MIMAProcessor
	PORT(
		mem_din : IN std_logic_vector(23 downto 0);
		mem_sdr_we : IN std_logic;
		clk : IN std_logic;
		rst : IN std_logic;          
		mem_addr : OUT std_logic_vector(19 downto 0);
		mem_dout : OUT std_logic_vector(23 downto 0);
		mem_re : OUT std_logic;
		mem_we : OUT std_logic;
		monitoring : OUT MONITORING_SIGNALS
		);
	END COMPONENT;
	
	COMPONENT MemoryController
	PORT(
		mima_din : IN std_logic_vector(23 downto 0);
		mima_addr : IN std_logic_vector(19 downto 0);
		mima_we : IN std_logic;
		mima_re : IN std_logic;
		clk_mima : IN std_logic;
		screen_addr : IN std_logic_vector(12 downto 0);
		clk_screen : IN std_logic;
		io_ascii : IN std_logic_vector(6 downto 0);
		io_ascii_we : IN std_logic;
		clk_io_ascii : IN std_logic;
		mima_dout : OUT std_logic_vector(23 downto 0);
		mima_rdy : OUT std_logic;
		screen_dout : OUT std_logic_vector(15 downto 0);
		reset : IN std_logic
		);
	END COMPONENT;
	
	COMPONENT ScreenController
	PORT(
		en : IN std_logic;
		monitoring_mima : IN MONITORING_SIGNALS;
		monitoring_freq : IN std_logic_vector(25 downto 0);
		screen_mem_din : IN std_logic_vector(15 downto 0);
		io_screen_sel : IN std_logic;
		clk40 : IN std_logic;          
		screen_mem_addr : OUT std_logic_vector(12 downto 0);
		r : OUT std_logic_vector(4 downto 0);
		g : OUT std_logic_vector(5 downto 0);
		b : OUT std_logic_vector(4 downto 0);
		hsync : OUT std_logic;
		vsync : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT ps2_keyboard_to_ascii
	PORT(
		clk : IN std_logic;
		ps2_clk : IN std_logic;
		ps2_data : IN std_logic;          
		ascii_new : OUT std_logic;
		ascii_code : OUT std_logic_vector(6 downto 0)
		);
	END COMPONENT;

	COMPONENT ClockController
	PORT(
		clk_in : IN std_logic;
		speed_up : IN std_logic;
		speed_down : IN std_logic;          
		clk_out : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT ClockFreqMonitor
	PORT(
		clk_40 : IN std_logic;
		clk_mon : IN std_logic;          
		freq_in_hz : OUT std_logic_vector(25 downto 0)
		);
	END COMPONENT;
	
	component clk48_to_clk40
		port(
		CLK_IN           : in     std_logic;
		CLK_OUT          : out    std_logic
		);
	end component;
	
	signal mima_mem_addr_s : STD_LOGIC_VECTOR(19 downto 0);
	signal mima_din_s : STD_LOGIC_VECTOR(23 downto 0);
	signal mima_dout_s : STD_LOGIC_VECTOR(23 downto 0);
	signal mima_mem_re_s, mima_mem_we_s, mem_rd_rdy_s : STD_LOGIC := '0';
	
	signal monitoring_mima_s : MONITORING_SIGNALS := (others => (others => '0'));
	signal monitoring_freq_s : STD_LOGIC_VECTOR(25 downto 0) := (others => '0');
	
	signal clk40_s, clk_mima_s : STD_LOGIC := '0';
	signal reset_s : STD_LOGIC := '0';
	signal speed_up_s, speed_down_s : STD_LOGIC := '0';
	
	signal screen_addr_s : STD_LOGIC_VECTOR(12 downto 0) := (others => '0');
	signal screen_din_s : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
	
	signal ascii_new_s : STD_LOGIC := '0';
	signal ascii_code_s : STD_LOGIC_VECTOR(6 downto 0) := (others => '0');
	
begin

	reset_s <= not reset;
	speed_up_s <= not speed_up;
	speed_down_s <= not speed_down;
	
	mima_processor: MIMAProcessor PORT MAP(
		mem_addr => mima_mem_addr_s,
		mem_din => mima_din_s,
		mem_dout => mima_dout_s,
		mem_re => mima_mem_re_s,
		mem_we => mima_mem_we_s,
		mem_sdr_we => mem_rd_rdy_s,
		monitoring => monitoring_mima_s,
		clk => clk_mima_s,
		rst => reset_s
	);
	
	memory_controller: MemoryController PORT MAP(
		mima_din => mima_dout_s,
		mima_dout => mima_din_s,
		mima_addr => mima_mem_addr_s,
		mima_we => mima_mem_we_s,
		mima_re => mima_mem_re_s,
		mima_rdy => mem_rd_rdy_s,
		clk_mima => clk_mima_s,
		screen_addr => screen_addr_s,
		screen_dout => screen_din_s,
		clk_screen => clk40_s,
		io_ascii => ascii_code_s,
		io_ascii_we => ascii_new_s,
		clk_io_ascii => clk40_s,
		reset => reset_s
	);
	
	screen_controller: ScreenController PORT MAP(
		en => '1',
		monitoring_mima => monitoring_mima_s,
		monitoring_freq => monitoring_freq_s,
		screen_mem_addr => screen_addr_s,
		screen_mem_din => screen_din_s,
		r => r,
		g => g,
		b => b,
		hsync => hsync,
		vsync => vsync,
		io_screen_sel => screen_select,
		clk40 => clk40_s
	);
	
	ps2_to_ascii: ps2_keyboard_to_ascii PORT MAP(
		clk => clk40_s,
		ps2_clk => ps2_clk,
		ps2_data => ps2_data,
		ascii_new => ascii_new_s,
		ascii_code => ascii_code_s 
	);
	
	clock_controller: ClockController PORT MAP(
		clk_in => clk40_s,
		clk_out => clk_mima_s,
		speed_up => speed_up_s,
		speed_down => speed_down_s
	);
	
	clock_freq_monitor: ClockFreqMonitor PORT MAP(
		clk_40 => clk40_s,
		clk_mon => clk_mima_s,
		freq_in_hz => monitoring_freq_s
	);
	
	clk_48_to_40_ipcore : clk48_to_clk40
		port map(
			CLK_IN => clk,
			CLK_OUT => clk40_s
	);
	
end Structural;

