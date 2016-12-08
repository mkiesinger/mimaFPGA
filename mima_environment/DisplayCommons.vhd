--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;

package DisplayCommons is
	
	type color is (red, yellow, green, blue, white, grey, purple, black);
	
	type textstring is array(0 to 15) of std_logic_vector(7 downto 0);
	
	type text_field is record
		text : textstring;
		color : color;
		size : integer range 0 to 3;
		pos_x : integer range 0 to 799;
		pos_y : integer range 0 to 599;
	end record;
	
	type number_field is record
		address : integer range 0 to 15;
		color : color;
		size : integer range 0 to 3;
		pos_x : integer range 0 to 799;
		pos_y : integer range 0 to 599;
	end record;
		
	constant TEXT_FIELD_SIZE : integer := 16;
	
	function get_rgb8bit (c : color) return std_logic_vector;
	
	function to_std_logic_vector(a : string) return std_logic_vector;
	
	function to_text(a : string(1 to 16)) return textstring;
	
-- type <new_type> is
--  record
--    <type_name>        : std_logic_vector( 7 downto 0);
--    <type_name>        : std_logic;
-- end record;
--
-- Declare constants
--
-- constant <constant_name>		: time := <time_unit> ns;
-- constant <constant_name>		: integer := <value;
--
-- Declare functions and procedure
--
-- function <function_name>  (signal <signal_name> : in <type_declaration>) return <type_declaration>;
-- procedure <procedure_name> (<type_declaration> <constant_name>	: in <type_declaration>);
--

end DisplayCommons;

package body DisplayCommons is

	function get_rgb8bit (c : color) return std_logic_vector is
		variable ret : std_logic_vector(7 downto 0) := (others => '0');
	begin
		-- rrrgggbb
		case c is 
			when red => return "11100000";
			when yellow => return "11111100";
			when green => return "00011100";
			when blue => return "00000011";
			when white => return "11111111";
			when grey => return "10010010";
			when purple => return "11100011";
			when black => return "00000000";
		end case;
	end get_rgb8bit;
	
	function to_std_logic_vector(a : string) return std_logic_vector is
		variable ret : std_logic_vector(a'length*8-1 downto 0);
	begin
		for i in a'range loop
			ret(i*8+7 downto i*8) := std_logic_vector(to_unsigned(character'pos(a(i)), 8));
		end loop;
		return ret;
	end function to_std_logic_vector;
	
	function to_text(a : string(1 to 16)) return textstring is
		variable ret : textstring := (others => (others => '0'));
	begin
		for i in a'range loop
			ret(i-1) := std_logic_vector(to_unsigned(character'pos(a(i)), 8));
		end loop;
		return ret;
	end function to_text;

---- Example 1
--  function <function_name>  (signal <signal_name> : in <type_declaration>  ) return <type_declaration> is
--    variable <variable_name>     : <type_declaration>;
--  begin
--    <variable_name> := <signal_name> xor <signal_name>;
--    return <variable_name>; 
--  end <function_name>;

---- Example 2
--  function <function_name>  (signal <signal_name> : in <type_declaration>;
--                         signal <signal_name>   : in <type_declaration>  ) return <type_declaration> is
--  begin
--    if (<signal_name> = '1') then
--      return <signal_name>;
--    else
--      return 'Z';
--    end if;
--  end <function_name>;

---- Procedure Example
--  procedure <procedure_name>  (<type_declaration> <constant_name>  : in <type_declaration>) is
--    
--  begin
--    
--  end <procedure_name>;
 
end DisplayCommons;
