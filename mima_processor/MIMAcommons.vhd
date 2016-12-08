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

package MIMAcommons is

	type control_signals is
		record 
			A_we : STD_LOGIC;
			A_re : STD_LOGIC;
			X_we : STD_LOGIC;
			Y_we : STD_LOGIC;
			Z_re : STD_LOGIC;
			E_re : STD_LOGIC;
			P_we : STD_LOGIC;
			P_re : STD_LOGIC;
			I_we : STD_LOGIC;
			I_re : STD_LOGIC;
			D_we : STD_LOGIC;
			D_re : STD_LOGIC;
			S_we : STD_LOGIC;
			C : STD_LOGIC_VECTOR(2 downto 0);
			R : STD_LOGIC;
			W : STD_LOGIC;
			RESERVED : STD_LOGIC_VECTOR(1 downto 0);
			NEXT_ADDR : STD_LOGIC_VECTOR(7 downto 0);
		end record;
			
	type monitoring_signals is
		record
			regf_accu : STD_LOGIC_VECTOR(23 downto 0);
			regf_x : STD_LOGIC_VECTOR(23 downto 0);
			regf_y : STD_LOGIC_VECTOR(23 downto 0);
			regf_z : STD_LOGIC_VECTOR(23 downto 0);
			regf_ir : STD_LOGIC_VECTOR(23 downto 0);
			regf_iar : STD_LOGIC_VECTOR(19 downto 0);
			regf_sar : STD_LOGIC_VECTOR(19 downto 0);
			regf_sdr : STD_LOGIC_VECTOR(23 downto 0);
			regf_bus : STD_LOGIC_VECTOR(23 downto 0);
			cu_control_signals : STD_LOGIC_VECTOR(27 downto 0);
			cu_current_addr : STD_LOGIC_VECTOR(7 downto 0);
			cu_next_addr : STD_LOGIC_VECTOR(7 downto 0);
		end record;
		
	type monitoring_signals_regf is
		record
			regf_accu : STD_LOGIC_VECTOR(23 downto 0);
			regf_x : STD_LOGIC_VECTOR(23 downto 0);
			regf_y : STD_LOGIC_VECTOR(23 downto 0);
			regf_z : STD_LOGIC_VECTOR(23 downto 0);
			regf_ir : STD_LOGIC_VECTOR(23 downto 0);
			regf_iar : STD_LOGIC_VECTOR(19 downto 0);
			regf_sar : STD_LOGIC_VECTOR(19 downto 0);
			regf_sdr : STD_LOGIC_VECTOR(23 downto 0);
			regf_bus : STD_LOGIC_VECTOR(23 downto 0);
		end record;
		
	type monitoring_signals_cu is
		record
			cu_control_signals : STD_LOGIC_VECTOR(27 downto 0);
			cu_current_addr : STD_LOGIC_VECTOR(7 downto 0);
			cu_next_addr : STD_LOGIC_VECTOR(7 downto 0);
		end record;
			
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

end MIMAcommons;

package body MIMAcommons is

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
 
end MIMAcommons;
