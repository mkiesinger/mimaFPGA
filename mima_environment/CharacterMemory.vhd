library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use WORK.DISPLAYCOMMONS.ALL;
use IEEE.NUMERIC_STD.ALL;


entity CharacterMemory is
    Port ( en : in  STD_LOGIC;
           x : in  STD_LOGIC_VECTOR (9 downto 0);
           y : in  STD_LOGIC_VECTOR (9 downto 0);
           char_number : out  STD_LOGIC_VECTOR (7 downto 0);
           char_x : out  STD_LOGIC_VECTOR (2 downto 0);
           char_y : out  STD_LOGIC_VECTOR (2 downto 0);
			  color_8bit : out STD_LOGIC_VECTOR(7 downto 0));
end CharacterMemory;

architecture Behavioral of CharacterMemory is
	
	type text_array is ARRAY(0 to 15) of text_field;
	constant DEFAULT_TEXT : text_field := (text => to_text("                "),
														color => white,
														size => 0,
														pos_x => 799,
														pos_y => 599);
														
	constant MF_TXT 	: text_field := (to_text("mimaFPGA        "), white, 3, 162, 32);
	constant BMK_TXT 	: text_field := (to_text("MONITORING SUITE"), white, 2, 162, 96);
	constant MS_TXT 	: text_field := (to_text("Manuel Killinger"), white, 1, 418, 128);
	constant ACC_TXT 	: text_field := (to_text("ACCU:           "), white, 1, 64, 288);
	constant X_TXT 	: text_field := (to_text("X:              "), white, 1, 64, 336);
	constant Y_TXT 	: text_field := (to_text("Y:              "), white, 1, 64, 384);
	constant Z_TXT 	: text_field := (to_text("Z:              "), white, 1, 64, 432);
	constant BUS_TXT 	: text_field := (to_text("BUS:            "), white, 1, 64, 480);
	constant SAR_TXT 	: text_field := (to_text("SAR:            "), white, 1, 64, 528);
	constant SDR_TXT 	: text_field := (to_text("SDR:            "), white, 1, 64, 576);
	constant IR_TXT 	: text_field := (to_text("IR:             "), white, 1, 64, 192);
	constant IAR_TXT 	: text_field := (to_text("IAR:            "), white, 1, 64, 240);
	constant CS_TXT 	: text_field := (to_text("Control Signals:"), white, 1, 432, 192);
	constant CMA_TXT 	: text_field := (to_text("Curr Micro Addr:"), white, 1, 432, 288);
	constant NMA_TXT 	: text_field := (to_text("Next Micro Addr:"), white, 1, 432, 384);
	constant CLK_TXT 	: text_field := (to_text("Clock Speed:    "), white, 1, 432, 480);
		
	
														
														
	constant TEXT_ROM : text_array := (	0 => MF_TXT,
													1 => BMK_TXT,
													2 => MS_TXT,
													3 => ACC_TXT,
													4 => X_TXT,
													5 => Y_TXT,
													6 => Z_TXT,
													7 => BUS_TXT,
													8 => SAR_TXT,
													9 => SDR_TXT,
													10 => IR_TXT,
													11 => IAR_TXT,
													12 => CS_TXT,
													13 => CMA_TXT,
													14 => NMA_TXT,
													15 => CLK_TXT); 
	
	constant TEXT_LENGTH : INTEGER := 16;
	constant TEXT_WIDTH : INTEGER := TEXT_LENGTH * 8; -- Text field width is 16 characters and each is 8 pixels wide 
	constant TEXT_HEIGTH : INTEGER := 8; -- 8 pixels
	type char_values_array is ARRAY(0 to text_array'length-1) of UNSIGNED(2 downto 0);

	type char_numbers_array is ARRAY(0 to text_array'length-1) of INTEGER range 0 to TEXT_LENGTH-1;
	
	type is_visible_temp_array is ARRAY (0 to text_array'length-1) of UNSIGNED(9 downto 0);
	type vector8bit_array is ARRAY (0 to text_array'length-1) of STD_LOGIC_VECTOR(7 downto 0);
	
	
	function or_reduce_array(a : char_values_array) return std_logic_vector is
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
	
begin
process(en, x, y)
	variable is_visible_v : STD_LOGIC_VECTOR(text_array'length-1 downto 0) := (others => '0');
	variable is_vis_temp_v : is_visible_temp_array := (others => to_unsigned(0, 10));
	variable char_x_v : char_values_array := (others => "000");
	variable char_y_v : char_values_array := (others => "000");

	variable char_str_pos_v : char_numbers_array := (others => 0);
	
	variable color_v : vector8bit_array := (others => std_logic_vector(to_unsigned(0, 8)));
	variable character_ascii_value_v : vector8bit_array := (others => std_logic_vector(to_unsigned(0, 8)));
begin
		for I in 0 to text_array'length-1 loop
		
			-- check if there is a text_field at the current position (x,y)
			if ("00" & unsigned(y) >= to_unsigned(TEXT_ROM(I).pos_y, 12) AND "00" & unsigned(y) < to_unsigned(TEXT_ROM(I).pos_y, 12) + shift_left(to_unsigned(TEXT_HEIGTH, 12), TEXT_ROM(I).size)
					AND "00" &  unsigned(x) >= to_unsigned(TEXT_ROM(I).pos_x, 12) AND "00" & unsigned(x) < to_unsigned(TEXT_ROM(I).pos_x, 12) + shift_left(to_unsigned(TEXT_WIDTH, 12), TEXT_ROM(I).size)) then
				is_visible_v(I) := '1';
			else 
				is_visible_v(I) := '0';
			end if;
		
			-- find the position of the character that should be displayed in the current text field
			is_vis_temp_v(I) := (others => is_visible_v(I));
			--char_in_string_pos_v(I) := to_integer(shift_right(UNSIGNED(x) - to_unsigned(TEXT_ROM(I).pos_x, 10), TEXT_ROM(I).size + 3)) +1; -- divide by 8 to get the char at the position and +1 cause string indexing starts at 1
			char_str_pos_v(I) := to_integer(shift_right("00" & UNSIGNED(x) - to_unsigned(TEXT_ROM(I).pos_x, 12), TEXT_ROM(I).size + 3)(3 downto 0)); -- divide by 8 to get the char at the position and +1 cause string indexing starts at 1
			
			
			-- read the character from the text field to display
			--character_ascii_value_v(I) := std_logic_vector(to_unsigned(character'pos(TEXT_ROM(I).text(char_in_string_pos_v(I))), 8)) AND std_logic_vector(is_vis_temp_v(I)(7 downto 0));
			character_ascii_value_v(I) := TEXT_ROM(I).text(char_str_pos_v(I)) AND std_logic_vector(is_vis_temp_v(I)(7 downto 0));
			
			-- assign the current characters x and y pixel positions 
			char_x_v(I) := shift_right("00" & UNSIGNED(x) - to_unsigned(TEXT_ROM(I).pos_x, 12), TEXT_ROM(I).size)(2 downto 0) AND is_vis_temp_v(I)(2 downto 0);
			char_y_v(I) := shift_right("00" & UNSIGNED(y) - to_unsigned(TEXT_ROM(I).pos_y, 12), TEXT_ROM(I).size)(2 downto 0) AND is_vis_temp_v(I)(2 downto 0);
			
			color_v(I) := get_rgb8bit(TEXT_ROM(I).color) AND std_logic_vector(is_vis_temp_v(I)(7 downto 0));
		
		end loop;

		if (en = '1') then	
			char_number <= or_reduce_array(character_ascii_value_v);
			char_x <= or_reduce_array(char_x_v);
			char_y <= or_reduce_array(char_y_v);
			color_8bit <= or_reduce_array(color_v);
		else 
			char_number <= (others => '0');
			char_x <= (others => '0');
			char_y <= (others => '0');
			color_8bit <= (others => '0');
		end if;
	
end process;

end Behavioral;

