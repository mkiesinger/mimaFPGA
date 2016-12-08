library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity ClockFreqMonitor is
    Port ( clk_40 : in  STD_LOGIC;
           clk_mon : in  STD_LOGIC;
           freq_in_hz : out  STD_LOGIC_VECTOR (25 downto 0));
end ClockFreqMonitor;

architecture Structural of ClockFreqMonitor is
	
	COMPONENT PulseCounter
	PORT(
		clk : IN std_logic;          
		pulse : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT NBitCounter
	GENERIC( N : INTEGER);
	PORT(
		en : IN std_logic;
		clk : IN std_logic;
		rst : IN std_logic;          
		dout : OUT std_logic_vector(N-1 downto 0)
		);
	END COMPONENT;
	
	COMPONENT EdgeDetector
	PORT(
		input : IN std_logic;
		clk : IN std_logic;
		sel : IN std_logic;          
		pulse : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT NBitRegister
	GENERIC( N : INTEGER);
	PORT(
		din : IN std_logic_vector(N-1 downto 0);
		ce : IN std_logic;
		re : IN std_logic;
		rst : IN std_logic;
		clk : IN std_logic;          
		dout : OUT std_logic_vector(N-1 downto 0)
		);
	END COMPONENT;

	signal one_hz_pulse_s : STD_LOGIC := '0';
	signal freq_count_s : STD_LOGIC_VECTOR(25 downto 0);
	signal clk_mon_re_pulse_s : STD_LOGIC := '0';
	
begin

	one_hz_pulse: PulseCounter PORT MAP(
		clk => clk_40,
		pulse => one_hz_pulse_s
	);
	
	freq_counter: NBitCounter GENERIC MAP(N => 26) PORT MAP(
		dout => freq_count_s,
		en => clk_mon_re_pulse_s,
		clk => clk_40,
		rst => one_hz_pulse_s
	);
	
	clk_to_pulse: EdgeDetector PORT MAP(
		input => clk_mon,
		clk => clk_40,
		sel => '0',
		pulse => clk_mon_re_pulse_s
	);
	
	current_freq: NBitRegister GENERIC MAP(N => 26) PORT MAP(
		din => freq_count_s,
		dout => freq_in_hz,
		ce => one_hz_pulse_s,
		re => '1',
		rst => '0',
		clk => clk_40
	);
	
end Structural;

