library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use WORK.MIMACOMMONS.ALL;
use IEEE.NUMERIC_STD.ALL;


entity UInstructionROM is
    Port ( addr : in  STD_LOGIC_VECTOR (7 downto 0);
			  uinstr_raw :  out STD_LOGIC_VECTOR(27 downto 0);
			  control_wires : out  CONTROL_SIGNALS);
end UInstructionROM;

architecture Behavioral of UInstructionROM is
	
	type MICRO_INSTRUCTION_ROM is array(0 to 255) of STD_LOGIC_VECTOR(27 downto 0);
	signal data : STD_LOGIC_VECTOR(27 downto 0) := (others => '0');
	
	function bin(i : integer) return std_logic_vector is
	begin
		return std_logic_vector(to_unsigned(i, 10));
	end function bin;
	
	constant rom : MICRO_INSTRUCTION_ROM := (
		
		-- 		 A XYZEP I D SC  RW	R NEXT_ADDR		OPC	|ARG	|
		0 		=> "001000010000100010" & bin(1),	-- FETCH |		|IAR -> SAR, X; R = '1'
		1 		=> "000101000000000010" & bin(2), 	--					|E -> Y; R = '1' 
		2 		=> "000000000000000110" & bin(3),	--					|ADD; R = '1'
		3 		=> "000010100000000000" & bin(4),	--					|Z -> IAR
		4 		=> "000000001001000000" & bin(255), --					|SDR -> IR		
		
		8 		=> "100000000100000000" & bin(0),	-- LDC	|c		|IR -> Acc
		
		12 	=> "000000000100100010" & bin(13),	-- LDV	|[a]	|IR -> SAR; R = '1'
		13 	=> "000000000000000010" & bin(14),	-- 				|R = '1'
		14		=> "000000000000000010" & bin(15),	-- 				|R = '1'
		15		=> "100000000001000000" & bin(0),	--					|SDR -> Acc
		
		20		=> "010000000010000000" & bin(21),	-- STV	|[a]	|Acc -> SDR
		21 	=> "000000000100100001" & bin(22),	--					|IR -> SAR; W = '1'
		22		=> "000000000000000001" & bin(23),	--					|W = '1'
		23		=> "000000000000000001" & bin(0),	--					|W = '1'
		
		28 	=> "000000000100100010" & bin(29),	-- ADD	|[a]	|IR -> SAR; R = '1'
		29		=> "011000000000000010" & bin(30),	--					|Acc -> X; R = '1'
		30		=> "000000000000000010" & bin(31),	--					|R = '1'
		31		=> "000100000001000000" & bin(32),	--					|SDR -> Y
		32		=> "000000000000000100" & bin(33),	--					|ADD
		33		=> "100010000000000000" & bin(0),	--					|Z -> Acc
		
		36 	=> "000000000100100010" & bin(37),	-- AND	|[a]	|IR -> SAR; D = '1'
		37		=> "011000000000000010" & bin(38),	--					|Acc -> X; R = '1'
		38		=> "000000000000000010" & bin(39),	--					|R = '1'
		39		=> "000100000001000000" & bin(40),	--					|SDR -> Y
		40		=> "000000000000001100" & bin(41),	--					|AND
		41		=> "100010000000000000" & bin(0),	--					|Z -> Acc
		
		44 	=> "000000000100100010" & bin(45),	-- OR 	|[a]	|IR -> SAR; D = '1'
		45		=> "011000000000000010" & bin(46),	--					|Acc -> X; R = '1'
		46		=> "000000000000000010" & bin(47),	--					|R = '1'
		47		=> "000100000001000000" & bin(48),	--					|SDR -> Y
		48		=> "000000000000010000" & bin(49),	--					|OR
		49		=> "100010000000000000" & bin(0),	--					|Z -> Acc
		
		52 	=> "000000000100100010" & bin(53),	-- XOR	|[a]	|IR -> SAR; D = '1'
		53		=> "011000000000000010" & bin(54),	--					|Acc -> X; R = '1'
		54		=> "000000000000000010" & bin(55),	--					|R = '1'
		55		=> "000100000001000000" & bin(56),	--					|SDR -> Y
		56		=> "000000000000010100" & bin(57),	--					|XOR
		57		=> "100010000000000000" & bin(0),	--					|Z -> Acc
		
		60 	=> "000000000100100010" & bin(61), 	-- EQL	|[A]	|IR -> SAR; R = '1'
		61		=> "011000000000000010" & bin(62),	-- 				|Acc -> X; R = '1'
		62		=> "000000000000000010" & bin(63),	-- 				|R = '1'
		63		=> "000100000001000000" & bin(64),	-- 				|SDR -> Y
		64		=> "000000000000011100" & bin(65),	-- 				|EQL
		65		=> "100010000000000000" & bin(0),	-- 				|Z -> Acc
		
		68		=> "000000100100000000" & bin(0),	-- JMP	|a 	|IR -> IAR
		
		72		=> "001001000000000000" & bin(73),	-- JMN	|a		|E -> X
		73		=> "010100000000001000" & bin(74),	-- 				|ROR; Acc -> Y
		74		=> "001010000000000000" & bin(75),	-- 				|Z -> X
		75		=> "000000000000001100" & bin(76),	-- 				|AND
		76		=> "000110000000000000" & bin(77),	-- 				|Z -> Y
		77		=> "000100000100011100" & bin(78),	-- 				|EQL; R -> Y
		78		=> "001010000000000000" & bin(79),	-- 				|Z -> X
		79		=> "000100010000001100" & bin(80),	-- 				|AND; IAR -> Y
		80		=> "000010000010011000" & bin(81),	-- 				|NOT; Z -> SDR
		81		=> "001010000000000000" & bin(82),	-- 				|Z -> X
		82		=> "001000000001001100" & bin(83),	-- 				|AND; SDR -> X
		83		=> "000110000000000000" & bin(84),	-- 				|Z -> Y
		84		=> "000000000000010000" & bin(85),	-- 				|OR
		85		=> "000010100000000000" & bin(0),	-- 				|Z -> IAR
		
		88		=> "011000000000000000" & bin(89),	-- NOT	|		|Acc -> X
		89		=> "000000000000011000" & bin(90),	-- 				|NOT
		90		=> "100010000000000000" & bin(0),	-- 				|Z -> Acc
		
		96		=> "011000000000000000" & bin(97),	-- RAR	|		|Acc -> X
		97		=> "000000000000001000" & bin(98),	-- 				|ROR
		98		=> "100010000000000000" & bin(0),	-- 				|Z -> Acc
		
		100	=> "000000000100100010" & bin(101), --	LDIV	|[[a]]|IR -> SAR; R = '1'
		101	=> "000000000000000010" & bin(102), --					|R = '1'
		102	=> "000000000000000010" & bin(103), --					|R = '1'
		103	=> "000000000001100010" & bin(104), --					|SDR -> SAR; R = '1'
		104	=> "000000000000000010" & bin(105), --					|R = '1'
		105	=> "000000000000000010" & bin(106), --					|R = '1'
		106	=> "100000000001000000" & bin(0),   --					|SDR -> Acc
				
		112	=> "000000000100100010" & bin(113), --	STIV	|[[a]]|IR -> SAR; R = '1'
		113	=> "000000000000000010" & bin(114), --					|R = '1'
		114	=> "000000000000000010" & bin(115), --					|R = '1'
		115	=> "000000000001100000" & bin(116), --					|SDR -> SAR
		116	=> "010000000010000001" & bin(117), --					|Acc -> SDR; W = '1'
		117	=> "000000000000000001" & bin(118), --					|W = '1'
		118	=> "000000000000000001" & bin(0),   --					|W = '1'
				
		124	=> "000000010010000000" & bin(125), --	JMS	|a		|IAR -> SDR
		125	=> "000000000100100001" & bin(126), --					|IR -> SAR, X; W = '1'
		126	=> "000101000000000001" & bin(127), --					|E -> Y; W = '1'
		127	=> "000000000000000101" & bin(128), --					|ADD; W = '1'
		128	=> "000010000000100010" & bin(129), --					|Z -> SAR; R = '1'
		129	=> "000000000000000010" & bin(130), --					|R = '1'
		130	=> "000000000000000010" & bin(131), --					|R = '1'
		131	=> "000000100001000000" & bin(0),   --					|SDR -> IAR
				
		136	=> "000000000100100010" & bin(137), --	JIND	|[a]	|IR -> SAR; R = '1'
		137	=> "000000000000000010" & bin(138), --					|R = '1'
		138	=> "000000000000000010" & bin(139), --					|R = '1'
		139	=> "000000100001000000" & bin(0),   --					|SDR -> IAR
		
		255	=> "000000000000000000" & bin(0),   -- reserved for the cu to jump to the decoded functions
		
		others => (others => '0')
	);
	
begin
	
	data  <= rom(to_integer(unsigned(addr)));
	uinstr_raw <= data;
	control_wires.A_we <= data(27);
	control_wires.A_re <= data(26);
	control_wires.X_we <= data(25);
	control_wires.Y_we <= data(24);
	control_wires.Z_re <= data(23);
	control_wires.E_re <= data(22);
	control_wires.P_we <= data(21);
	control_wires.P_re <= data(20);
	control_wires.I_we <= data(19);
	control_wires.I_re <= data(18);
	control_wires.D_we <= data(17);
	control_wires.D_re <= data(16);
	control_wires.S_we <= data(15);
	control_wires.C <= data(14 downto 12);
	control_wires.R <= data(11);
	control_wires.W <= data(10);
	control_wires.RESERVED <= data(9 downto 8);
	control_wires.NEXT_ADDR <= data(7 downto 0);

end Behavioral;

