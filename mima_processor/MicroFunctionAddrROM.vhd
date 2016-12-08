library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity MicroFunctionAddrROM is
    Port ( op_addr : in  STD_LOGIC_VECTOR (4 downto 0);
           func_entry_addr : out  STD_LOGIC_VECTOR (7 downto 0));
end MicroFunctionAddrROM;

architecture Behavioral of MicroFunctionAddrROM is

	function bin(i : integer) return std_logic_vector is
	begin
		return std_logic_vector(to_unsigned(i, 8));
	end function bin;
	
	type MICRO_FUNCTION_ADRESSES_ROM is array (0 to 31) of STD_LOGIC_VECTOR(7 downto 0);
	constant rom : MICRO_FUNCTION_ADRESSES_ROM := (
	
							 --	OPC	|MNEM	|ARG	|LOC in u-inst ROM
		0	=> bin(8),	 --	0		|LDC	|c		|8	
		1	=> bin(12),	 --	1		|LDV	|[a]	|12
		2	=> bin(20),	 --	2		|STV	|[a]	|20
		3	=> bin(28),	 --	3		|ADD	|[a]	|28
		4	=> bin(36),	 --	4		|AND	|[a]	|36
		5	=> bin(44),	 --	5		|OR	|[a]	|44
		6	=> bin(52),	 --	6		|XOR	|[a]	|52
		7	=> bin(60),	 --	7		|EQL	|[a]	|60
		8	=> bin(68),	 --	8		|JMP	|a		|68
		9	=> bin(72),	 --	9		|JMN	|a    |72
		10	=> bin(100), --	A		|LDIV	|[[a]]|100
		11	=> bin(112), --	B		|LDIV	|[[a]]|112
		12	=> bin(124), --	C		|JMS	|a		|124
		13	=> bin(136), --	D		|JIND	|a		|136
		
		17	=> bin(88),	 --	F1		|NOT	|		|88
		18	=> bin(96),	 --	F2		|RAR	|		|96
		
		others => (others => '0')
	);
	
begin
	
	func_entry_addr <= rom(to_integer(unsigned(op_addr)));
	
end Behavioral;

