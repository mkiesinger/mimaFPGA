library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity PerformanceMonitorVGA is
    Port ( clk40 : in  STD_LOGIC; 
           en : in  STD_LOGIC;
			  num_din : in  STD_LOGIC_VECTOR (31 downto 0) := std_logic_vector(to_unsigned(0, 32));
			  num_addr : out  STD_LOGIC_VECTOR (3 downto 0);
           r : out  STD_LOGIC_VECTOR (4 downto 0);
			  g : out  STD_LOGIC_VECTOR (5 downto 0);
			  b : out  STD_LOGIC_VECTOR (4 downto 0);
			  x : out  STD_LOGIC_VECTOR (9 downto 0);
			  y : out  STD_LOGIC_VECTOR (9 downto 0);
			  hsync : out  STD_LOGIC;
			  vsync : out  STD_LOGIC;
			  blank : out  STD_LOGIC);
end PerformanceMonitorVGA;

architecture Structural of PerformanceMonitorVGA is

	COMPONENT VGAController
	GENERIC( DELAY_STAGES : INTEGER );
	PORT(
		clk : IN std_logic;
		en : IN std_logic;
		resolution_sel : IN std_logic;
		hsync : OUT std_logic;
		vsync : OUT std_logic;
		x : OUT std_logic_vector(9 downto 0);
		y : OUT std_logic_vector(9 downto 0);
		blank : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT VGATextDisplayer
	PORT(
		clk : IN std_logic;
		en : IN std_logic;
		num_din : IN std_logic_vector(31 downto 0);
		num_addr : OUT std_logic_vector(3 downto 0);
		x : IN std_logic_vector(9 downto 0);
		y : IN std_logic_vector(9 downto 0);          
		rgb_16 : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;
	
	signal x_s : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
	signal y_s : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
	signal rgb_16_s : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
	
begin

	controller: VGAController GENERIC MAP( DELAY_STAGES => 1 ) -- 1 as the reading from the font rom takes 1 cycle
	PORT MAP(																  
		clk => clk40,
		en => en,
		resolution_sel => '1', -- 800x600
		hsync => hsync,
		vsync => vsync,
		x => x_s,
		y => y_s,
		blank => blank
	);
	
	textDisplayer: VGATextDisplayer PORT MAP(
		clk => clk40,
		en => en,
   	num_din => num_din,
		num_addr => num_addr,
		x => x_s,
		y => y_s,
		rgb_16 => rgb_16_s
	);

	r <= rgb_16_s(15 downto 11);
	g <= rgb_16_s(10 downto 5);
	b <= rgb_16_s(4 downto 0);
	
	x <= x_s;
	y <= y_s;
	
end Structural;

