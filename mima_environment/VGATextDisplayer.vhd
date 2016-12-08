library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity VGATextDisplayer is
	Port(clk      : in  STD_LOGIC;
		 en       : in  STD_LOGIC;
		 x        : in  STD_LOGIC_VECTOR(9 downto 0);
		 y        : in  STD_LOGIC_VECTOR(9 downto 0);
		 num_din  : in  STD_LOGIC_VECTOR(31 downto 0);
		 num_addr : out STD_LOGIC_VECTOR(3 downto 0);
		 rgb_16   : out STD_LOGIC_VECTOR(15 downto 0));
end VGATextDisplayer;

architecture Structural of VGATextDisplayer is
	COMPONENT CharacterMemory
		PORT(
			en          : IN  std_logic;
			x           : IN  std_logic_vector(9 downto 0);
			y           : IN  std_logic_vector(9 downto 0);
			char_number : OUT std_logic_vector(7 downto 0);
			char_x      : OUT std_logic_vector(2 downto 0);
			char_y      : OUT std_logic_vector(2 downto 0);
			color_8bit  : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;
	
	COMPONENT NumbersMemory
	PORT(
		en : IN std_logic;
		x : IN std_logic_vector(9 downto 0);
		y : IN std_logic_vector(9 downto 0);
		num_din : IN std_logic_vector(31 downto 0);          
		num_addr : OUT std_logic_vector(3 downto 0);
		char_number : OUT std_logic_vector(7 downto 0);
		char_x : OUT std_logic_vector(2 downto 0);
		char_y : OUT std_logic_vector(2 downto 0);
		color_8bit : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;

	COMPONENT FontDisplayer
		PORT(
			en             : IN  std_logic;
			clk            : IN  std_logic;
			char_number    : IN  std_logic_vector(6 downto 0);
			char_x         : IN  std_logic_vector(2 downto 0);
			char_y         : IN  std_logic_vector(2 downto 0);
			color_8bit_in  : in  STD_LOGIC_VECTOR(7 downto 0);
			color_8bit_out : out STD_LOGIC_VECTOR(7 downto 0);
			pixel          : OUT std_logic
		);
	END COMPONENT;

	signal char_number_s        : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	signal char_number1_s        : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	signal char_number2_s        : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	
	signal char_x_s             : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
	signal char_x1_s             : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
	signal char_x2_s             : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');

	signal char_y_s             : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
	signal char_y1_s             : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
	signal char_y2_s             : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
	
	signal pixel_s              : STD_LOGIC                    := '0';
	
	signal color_8bit_s         : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	signal color_8bit1_s         : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	signal color_8bit2_s         : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	
	signal color_8bit_delayed_s : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

begin

	char_mem : CharacterMemory PORT MAP(
			en          => en,
			x           => x,
			y           => y,
			char_number => char_number1_s,
			char_x      => char_x1_s,
			char_y      => char_y1_s,
			color_8bit  => color_8bit1_s
		);
		
	num_mem: NumbersMemory PORT MAP(
			en => en,
			x => x,
			y => y,
			num_din => num_din,
			num_addr => num_addr,
			char_number => char_number2_s,
			char_x => char_x2_s,
			char_y => char_y2_s,
			color_8bit => color_8bit2_s
	);
	
	char_number_s <= char_number1_s or char_number2_s;
	char_x_s <= char_x1_s or char_x2_s;
	char_y_s <= char_y1_s or char_y2_s;
	color_8bit_s <= color_8bit1_s or color_8bit2_s;

	font_display : FontDisplayer PORT MAP(
			en             => en,
			clk            => clk,
			char_number    => char_number_s(6 downto 0),
			char_x         => char_x_s,
			char_y         => char_y_s,
			color_8bit_in  => color_8bit_s,
			color_8bit_out => color_8bit_delayed_s,
			pixel          => pixel_s
		);

	-- rgb_16 is rrrrrggggggbbbbb
	-- red 
	rgb_16(15 downto 14) <= "11" when color_8bit_delayed_s(7) = '1' and pixel_s = '1' else "00";
	rgb_16(13 downto 12) <= "11" when color_8bit_delayed_s(6) = '1' and pixel_s = '1' else "00";
	rgb_16(11)           <= color_8bit_delayed_s(5) when pixel_s = '1' else '0';
	-- green
	rgb_16(10 downto 9)  <= "11" when color_8bit_delayed_s(4) = '1' and pixel_s = '1' else "00";
	rgb_16(8 downto 7)   <= "11" when color_8bit_delayed_s(3) = '1' and pixel_s = '1' else "00";
	rgb_16(6 downto 5)   <= "11" when color_8bit_delayed_s(2) = '1' and pixel_s = '1' else "00";
	-- blue
	rgb_16(4 downto 2)   <= "111" when color_8bit_delayed_s(1) = '1' and pixel_s = '1' else "000";
	rgb_16(1 downto 0)   <= "11" when color_8bit_delayed_s(0) = '1' and pixel_s = '1' else "00";

end Structural;

