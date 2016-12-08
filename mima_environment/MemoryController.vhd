library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity MemoryController is
    Port ( mima_din : in  STD_LOGIC_VECTOR (23 downto 0);
           mima_dout : out  STD_LOGIC_VECTOR (23 downto 0);
           mima_addr : in  STD_LOGIC_VECTOR (19 downto 0);
           mima_we : in  STD_LOGIC;
			  mima_re : in  STD_LOGIC;
			  mima_rdy : out  STD_LOGIC;
           clk_mima : in  STD_LOGIC;
			  screen_addr : in  STD_LOGIC_VECTOR(12 downto 0);
			  screen_dout : out  STD_LOGIC_VECTOR(15 downto 0);
			  clk_screen : in  STD_LOGIC; 
			  io_ascii : in  STD_LOGIC_VECTOR(6 downto 0);
			  io_ascii_we : in  STD_LOGIC;
			  clk_io_ascii : in  STD_LOGIC;
			  reset : in  STD_LOGIC);
end MemoryController;
	
architecture Structural of MemoryController is

	COMPONENT MIMA_RAM
		PORT (
			clka : IN STD_LOGIC;
			ena : IN STD_LOGIC;
			wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
			addra : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
			dina : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
			douta : OUT STD_LOGIC_VECTOR(23 DOWNTO 0)
		);
	END COMPONENT;
	
	COMPONENT ProgramROM
		PORT (
			a : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
			clk : IN STD_LOGIC;
			qspo : OUT STD_LOGIC_VECTOR(23 DOWNTO 0)
		);
	END COMPONENT;
	
	COMPONENT ScreenMemoryMap
		PORT (
			clka : IN STD_LOGIC;
			wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
			addra : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
			dina : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			clkb : IN STD_LOGIC;
			addrb : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
			doutb : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
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
	
	COMPONENT EdgeDetector
	PORT(
		input : IN std_logic;
		clk : IN std_logic;
		sel : IN std_logic;          
		pulse : OUT std_logic;
		rst : IN std_logic
		);
	END COMPONENT;

	COMPONENT NBitRegister
	GENERIC( N : integer);
	PORT(
		din : IN std_logic_vector(N-1 downto 0);
		ce : IN std_logic;
		re : IN std_logic;
		rst : IN std_logic;
		clk : IN std_logic;          
		dout : OUT std_logic_vector(N-1 downto 0)
		);
	END COMPONENT;

	
	
	
		

	signal mima_re_s, mima_we_s : STD_LOGIC := '0';
	signal re_pulse_s, we_pulse_s : STD_LOGIC_VECTOR(0 to 0) := "0";
	signal read_ready_s, write_ready_s : STD_LOGIC_VECTOR(0 to 0) := "0";
	
	signal bank_sel_s : STD_LOGIC_VECTOR(2 downto 0) := "000"; 
	
	signal heap_we_s, screen_we_s : STD_LOGIC_VECTOR(0 to 0);
	
	signal heap_dout_s, prom_dout_s : STD_LOGIC_VECTOR(23 downto 0) := (others => '0');
	signal keyboard_dout_s : STD_LOGIC_VECTOR(6 downto 0) := (others => '0');
	
	signal mima_dout_s : STD_LOGIC_VECTOR(23 downto 0) := (others => '0');

begin	
	
	mima_re_s <= mima_re and not read_ready_s(0);
	mima_we_s <= mima_we and not write_ready_s(0);
	mima_rdy <= read_ready_s(0);
	
	bank_sel_s <= "000" when unsigned(mima_addr) = x"00000" else
					"001" when x"00001" <= unsigned(mima_addr) and unsigned(mima_addr) <= x"03FFF" else -- heap spasns from x"00001" to x"03FFF", 16K
					"010" when x"04000" <= unsigned(mima_addr) and unsigned(mima_addr) <= x"05FFF" else -- screen memory map spans from x"04000" to x"05FFF", 8K
					"011" when unsigned(mima_addr) = x"06000" else												 				     -- keyborad mapping is a single memory location at x"06000"
					"100" when x"08000" <= unsigned(mima_addr) and unsigned(mima_addr) <= x"0FFFF" else -- program rom spans from x"08000" to x"0FFFF", 32K
					"111";
	
	heap_we_s(0) <= '1' when bank_sel_s = "001" and we_pulse_s = "1" else '0';
	screen_we_s(0) <= '1' when bank_sel_s = "010" and we_pulse_s = "1" else '0';

	 
	
	heap16k : MIMA_RAM
		PORT MAP (
			clka => clk_mima,
			ena => '1',
			wea => heap_we_s,
			addra => mima_addr(13 downto 0),
			dina => mima_din,
			douta => heap_dout_s 
		);
	
	prom32k : ProgramROM
		PORT MAP (
			a => mima_addr(14 downto 0),
			clk => clk_mima,
			qspo => prom_dout_s
		);

	screen_mem8k : ScreenMemoryMap
		PORT MAP (
			clka => clk_mima,
			wea => screen_we_s,
			addra => mima_addr(12 downto 0),
			dina => mima_din(15 downto 0),
			clkb => clk_screen,
			addrb => screen_addr,
			doutb => screen_dout
		);

	keyboard_reg: NBitRegister GENERIC MAP( N => 7) PORT MAP(
		din => io_ascii,
		dout => keyboard_dout_s,
		ce => io_ascii_we,
		re => '1',
		rst => reset,
		clk => clk_io_ascii
	);
	
	read_enable_detec: EdgeDetector PORT MAP(mima_re_s, clk_mima, '0', re_pulse_s(0), reset);
	write_enable_detec: EdgeDetector PORT MAP(mima_we_s, clk_mima, '0', we_pulse_s(0), reset);
-- delay mima_we by one cycle so it matches with the correct address read from mimas storage adress register
	
	read_delay_reg: NBitRegister GENERIC MAP( N => 1) PORT MAP( re_pulse_s, '1', '1', reset, clk_mima, read_ready_s);
	write_delay_reg: NBitRegister GENERIC MAP( N => 1) PORT MAP( we_pulse_s, '1', '1', reset, clk_mima, write_ready_s);
	
	mima_dout_s <= x"808000" when bank_sel_s = "000" else
						heap_dout_s when bank_sel_s = "001" else
						x"0000" & "0" & keyboard_dout_s when bank_sel_s = "011" else
						prom_dout_s when bank_sel_s = "100" else
						x"000000";
	mima_dout <= mima_dout_s when read_ready_s = "1" else
					 x"000000";

						 
end Structural;

