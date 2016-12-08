library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use WORK.DISPLAYCOMMONS.ALL;
use IEEE.NUMERIC_STD.ALL;


entity NumbersMemory is
	Port(en          : in  STD_LOGIC;
		 x           : in  STD_LOGIC_VECTOR(9 downto 0);
		 y           : in  STD_LOGIC_VECTOR(9 downto 0);
		 num_din    : in  STD_LOGIC_VECTOR(31 downto 0);
		 num_addr    : out STD_LOGIC_VECTOR(3 downto 0);
		 char_number : out STD_LOGIC_VECTOR(7 downto 0);
		 char_x      : out STD_LOGIC_VECTOR(2 downto 0);
		 char_y      : out STD_LOGIC_VECTOR(2 downto 0);
		 color_8bit  : out STD_LOGIC_VECTOR(7 downto 0));
end NumbersMemory;

architecture Behavioral of NumbersMemory is
	type num_array is ARRAY (0 to 15) of number_field;
	constant DEFAULT_NUMBER : number_field := (address => 0,
		                                       color   => black,
		                                       size    => 0,
		                                       pos_x   => 0,
		                                       pos_y   => 0);
	constant ACCU_NUM : number_field := (0, white, 1, 160, 288);
	constant X_NUM : number_field := (1, white, 1, 160, 336);
	constant Y_NUM : number_field := (2, white, 1, 160, 384);
	constant Z_NUM : number_field := (3, white, 1, 160, 432);
	constant BUS_NUM : number_field := (8, white, 1, 160, 480);
	constant SAR_NUM : number_field := (6, white, 1, 160, 528);
	constant SDR_NUM : number_field := (7, white, 1, 160, 576);
	constant IR_NUM : number_field := (4, white, 1, 160, 192);
	constant IAR_NUM : number_field := (5, white, 1, 160, 240);
	constant CS_NUM : number_field := (9, white, 1, 432, 232);
	constant CMA_NUM : number_field := (10, white, 1, 432, 328);
	constant NMA_NUM : number_field := (11, white, 1, 432, 424);
	constant CLK_NUM : number_field := (12, white, 1, 432, 520);
		                                

	constant NUM_ROM : num_array := (
		0  => ACCU_NUM,
		1  => X_NUM,
		2  => Y_NUM,
		3  => Z_NUM,
		4  => BUS_NUM,
		5  => SAR_NUM,
		6  => SDR_NUM,
		7  => IR_NUM,
		8  => IAR_NUM,
		9  => CS_NUM,
		10  => CMA_NUM,
		11 => NMA_NUM,
		12 => CLK_NUM,
		others => DEFAULT_NUMBER);

	constant NUM_LENGTH : INTEGER := 8; -- 8 hex values to display for 32 bit
	constant NUM_WIDTH  : INTEGER := NUM_LENGTH * 8; -- Text field width is 16 characters and each is 8 pixels wide 
	constant NUM_HEIGTH : INTEGER := 8; -- 8 pixels
	type char_values_array is ARRAY (0 to num_array'length - 1) of UNSIGNED(2 downto 0);

--	type number_index_array is ARRAY (0 to num_array'length - 1) of STD_LOGIC_VECTOR(2 downto 0);

	type is_visible_temp_array is ARRAY (0 to num_array'length - 1) of UNSIGNED(9 downto 0);
	type vector8bit_array is ARRAY (0 to num_array'length - 1) of STD_LOGIC_VECTOR(7 downto 0);
	type vector4bit_array is ARRAY (0 to num_array'length - 1) of STD_LOGIC_VECTOR(3 downto 0);
	type vector3bit_array is ARRAY (0 to num_array'length - 1) of STD_LOGIC_VECTOR(2 downto 0);

	function or_reduce_array(a : char_values_array) return std_logic_vector is
		variable ret : std_logic_vector(2 downto 0) := (others => '0');
	begin
		for i in a'range loop
			ret := ret or std_logic_vector(a(i));
		end loop;
		return ret;
	end function or_reduce_array;

	function or_reduce_array(a : vector3bit_array) return std_logic_vector is
		variable ret : std_logic_vector(2 downto 0) := (others => '0');
	begin
		for i in a'range loop
			ret := ret or std_logic_vector(a(i));
		end loop;
		return ret;
	end function or_reduce_array;

	function or_reduce_array(a : vector8bit_array) return std_logic_vector is
		variable ret : std_logic_vector(7 downto 0) := (others => '0');
	begin
		for i in a'range loop
			ret := ret or a(i);
		end loop;
		return ret;
	end function or_reduce_array;

	function or_reduce_array(a : vector4bit_array) return std_logic_vector is
		variable ret : std_logic_vector(3 downto 0) := (others => '0');
	begin
		for i in a'range loop
			ret := ret or a(i);
		end loop;
		return ret;
	end function or_reduce_array;
	
	function or_reduce_vector(v : std_logic_vector) return std_logic is
		variable ret : std_logic := '0';
	begin
		for i in v'range loop
			ret := ret or v(i);
		end loop;
		return ret;
	end function or_reduce_vector;

	function mux(sel : std_logic_vector(2 downto 0); v : std_logic_vector(31 downto 0)) return std_logic_vector is
		variable ret : std_logic_vector(3 downto 0) := (others => '0');
	begin
		case sel is
			when "000" => ret := v(31 downto 28);
			when "001" => ret := v(27 downto 24);
			when "010" => ret := v(23 downto 20);
			when "011" => ret := v(19 downto 16);
			when "100" => ret := v(15 downto 12);
			when "101" => ret := v(11 downto 8);
			when "110" => ret := v(7 downto 4);
			when "111" => ret := v(3 downto 0);
			when others => ret := "0000";
		end case;
		return ret;
	end function mux;

	function to_char(i : integer range 0 to 15) return character is
		variable c : character := '?';
	begin
		case i is
			when 0  => c := '0';
			when 1  => c := '1';
			when 2  => c := '2';
			when 3  => c := '3';
			when 4  => c := '4';
			when 5  => c := '5';
			when 6  => c := '6';
			when 7  => c := '7';
			when 8  => c := '8';
			when 9  => c := '9';
			when 10 => c := 'A';
			when 11 => c := 'B';
			when 12 => c := 'C';
			when 13 => c := 'D';
			when 14 => c := 'E';
			when 15 => c := 'F';
		   --when others => c := '?';
		end case;
		return c;
	end function to_char;

begin
	process(en, x, y, num_din)
		variable is_visible_v  : STD_LOGIC_VECTOR(num_array'length - 1 downto 0) := (others => '0');
		variable is_vis_temp_v : is_visible_temp_array                           := (others => to_unsigned(0, 10));
		variable char_x_v      : char_values_array                               := (others => "000");
		variable char_y_v      : char_values_array                               := (others => "000");

		variable hex_num_index_v : vector3bit_array := (others => std_logic_vector(to_unsigned(0, 3)));
		variable selected_nibble_v : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');

		variable color_v                 : vector8bit_array := (others => std_logic_vector(to_unsigned(0, 8)));
		variable character_ascii_value_v : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

		variable addresses_v : vector4bit_array := (others => "0000");

	begin
		for I in 0 to num_array'length - 1 loop

			-- check if there is a number_field at the current position (x,y)
			if ("00" & unsigned(y) >= to_unsigned(NUM_ROM(I).pos_y, 12) AND "00" & unsigned(y) < to_unsigned(NUM_ROM(I).pos_y, 12) + shift_left(to_unsigned(NUM_HEIGTH, 12), NUM_ROM(I).size) AND "00" & unsigned(x) >= to_unsigned(NUM_ROM(I).pos_x, 12) AND "00" & unsigned(x) <
				to_unsigned(NUM_ROM(I).pos_x, 12) + shift_left(to_unsigned(NUM_WIDTH, 12), NUM_ROM(I).size)) then
				is_visible_v(I) := '1';
			else
				is_visible_v(I) := '0';
			end if;

			is_vis_temp_v(I)   := (others => is_visible_v(I));
			
			-- find the position of the character that should be displayed in the current text field
			hex_num_index_v(I) := std_logic_vector(shift_right("00" & UNSIGNED(x) - to_unsigned(NUM_ROM(I).pos_x, 12), NUM_ROM(I).size + 3)(2 downto 0) AND is_vis_temp_v(I)(2 downto 0)); -- divide by 8 to get the char at the position and +1 cause string indexing starts at 1
			
		end loop;
		
			-- select the nibble to display from the num_din input
			selected_nibble_v := mux(or_reduce_array(hex_num_index_v), num_din);
			
			-- convert the nibble to its character value 0 -> 0, 1 -> 1, 10 -> A and so on
			character_ascii_value_v := std_logic_vector(to_unsigned(
			character'pos(
			to_char(
			to_integer(
			unsigned(
			selected_nibble_v)))), 8)) AND (character_ascii_value_v'range => or_reduce_vector(is_visible_v));

		for I in 0 to num_array'length - 1 loop
			

			-- assign the current characters x and y pixel positions 
			char_x_v(I) := shift_right("00" & UNSIGNED(x) - to_unsigned(NUM_ROM(I).pos_x, 12), NUM_ROM(I).size)(2 downto 0) AND is_vis_temp_v(I)(2 downto 0);
			char_y_v(I) := shift_right("00" & UNSIGNED(y) - to_unsigned(NUM_ROM(I).pos_y, 12), NUM_ROM(I).size)(2 downto 0) AND is_vis_temp_v(I)(2 downto 0);
			
			-- assign the addresses
			addresses_v(I) := std_logic_vector(to_unsigned(NUM_ROM(I).address, 4) AND is_vis_temp_v(I)(3 downto 0));

			color_v(I) := get_rgb8bit(NUM_ROM(I).color) AND std_logic_vector(is_vis_temp_v(I)(7 downto 0));

		end loop;

		if (en = '1') then
			char_number <= character_ascii_value_v;
			char_x      <= or_reduce_array(char_x_v);
			char_y      <= or_reduce_array(char_y_v);
			color_8bit  <= or_reduce_array(color_v);
			num_addr    <= or_reduce_array(addresses_v);
		else
			char_number <= (others => '0');
			char_x      <= (others => '0');
			char_y      <= (others => '0');
			color_8bit  <= (others => '0');
			num_addr    <= (others => '0');
		end if;

	end process;

end Behavioral;