library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity FontDisplayer is
    Port ( en : in  STD_LOGIC;
			  clk : in  STD_LOGIC;
           char_number : in  STD_LOGIC_VECTOR (6 downto 0);
           char_x : in  STD_LOGIC_VECTOR (2 downto 0);
           char_y : in  STD_LOGIC_VECTOR (2 downto 0);
			  color_8bit_in : in  STD_LOGIC_VECTOR (7 downto 0);
			  color_8bit_out : out  STD_LOGIC_VECTOR (7 downto 0);
           pixel : out  STD_LOGIC);
end FontDisplayer;

architecture Structural of FontDisplayer is
	
	COMPONENT AsciiFontRom
	PORT(
		clk : IN std_logic;
		addr : IN std_logic_vector(9 downto 0);          
		dout : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;
	
	COMPONENT NBit8WayMux
	GENERIC( N : INTEGER := 1);
	PORT(
		sel : IN std_logic_vector(2 downto 0);
		data0 : IN std_logic_vector(N-1 downto 0);
		data1 : IN std_logic_vector(N-1 downto 0);
		data2 : IN std_logic_vector(N-1 downto 0);
		data3 : IN std_logic_vector(N-1 downto 0);
		data4 : IN std_logic_vector(N-1 downto 0);
		data5 : IN std_logic_vector(N-1 downto 0);
		data6 : IN std_logic_vector(N-1 downto 0);
		data7 : IN std_logic_vector(N-1 downto 0);          
		dout : OUT std_logic_vector(N-1 downto 0)
		);
	END COMPONENT;
	
	COMPONENT NBitRegister
	Generic ( N : INTEGER := 3);
	PORT(
		din : IN std_logic_vector(N-1 downto 0);
		ce : IN std_logic;
		rst : IN std_logic;
		clk : IN std_logic;          
		dout : OUT std_logic_vector(N-1 downto 0)
		);
	END COMPONENT;
	
	signal addr_s : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
	signal dout_s : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	signal pixel_s : STD_LOGIC_VECTOR(0 downto 0) := "0";
	signal mux_delay_s : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
	

begin
	
	addr_s <= char_number & char_y;	
	
	from: AsciiFontRom PORT MAP(
		clk => clk,
		addr => addr_s,
		dout => dout_s
	);
	
	mux_delay_reg: NBitRegister GENERIC MAP( N => 3 )  -- delay mux 1 cycle as ram needs 1 cycle to load the pixel
		PORT MAP(
			din => char_x,
			dout => mux_delay_s,
			ce => '1',
			rst => '0',
			clk => clk
	);
	
	
	color_delay_reg: NBitRegister GENERIC MAP( N => 8 )  -- delay color 1 cycle as ram needs 1 cycle to load the pixel
		PORT MAP(
			din => color_8bit_in,
			dout => color_8bit_out,
			ce => '1',
			rst => '0',
			clk => clk
	);
	
	mux: NBit8WayMux 
	PORT MAP(
		sel => mux_delay_s,
		data0 => dout_s(7 downto 7),
		data1 => dout_s(6 downto 6),
		data2 => dout_s(5 downto 5),
		data3 => dout_s(4 downto 4),
		data4 => dout_s(3 downto 3),
		data5 => dout_s(2 downto 2),
		data6 => dout_s(1 downto 1),
		data7 => dout_s(0 downto 0),
		dout => pixel_s
	);	
	
	pixel <= pixel_s(0) and en;
	
end Structural;

