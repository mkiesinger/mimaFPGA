library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity ClockController is
    Port ( clk_in : in  STD_LOGIC;
           clk_out : out  STD_LOGIC;
           speed_up : in  STD_LOGIC;
           speed_down : in  STD_LOGIC);
end ClockController;

architecture Structural of ClockController is
	COMPONENT EdgeDetector
	PORT(
		input : IN std_logic;
		clk : IN std_logic;
		sel : IN std_logic;          
		pulse : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT SpeedRegulator
	PORT(
		en : IN std_logic;
		mode : IN std_logic;
		clk : IN std_logic;          
		speed : OUT std_logic_vector(24 downto 0)
		);
	END COMPONENT;
	
	COMPONENT ClockDivider
	PORT(
		clk_in : IN std_logic;
		div : IN std_logic_vector(24 downto 0);
		set_div : IN std_logic;          
		clk_out : OUT std_logic
		);
	END COMPONENT;

	signal spup_pulse_s : STD_LOGIC := '0';
	signal spdwn_pulse_s : STD_LOGIC := '0';
	signal pulse_s : STD_LOGIC := '0';
	signal clk_out_s : STD_LOGIC := '0';
	signal speed_div_s : STD_LOGIC_VECTOR(24 downto 0) := (others => '0');
	
begin
	
	speedup_edge_detec: EdgeDetector PORT MAP(
		input => speed_up,
		clk => clk_in,
		sel => '0',
		pulse => spup_pulse_s
	);
	
	speeddown_edge_detec: EdgeDetector PORT MAP(
		input => speed_down,
		clk => clk_in,
		sel => '0',
		pulse => spdwn_pulse_s
	);
	
	pulse_s <= spup_pulse_s or spdwn_pulse_s;
	
	speed_regulator: SpeedRegulator PORT MAP(
		en => pulse_s,
		mode => spdwn_pulse_s,
		clk => clk_in,
		speed => speed_div_s
	);
	
	clk_div: ClockDivider PORT MAP(
		clk_in => clk_in,
		clk_out => clk_out_s,
		div => speed_div_s,
		set_div => '1'
	);
	
	clk_out <= clk_out_s;

end Structural;

