library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity AsciiFontRom is
    Port ( clk : in  STD_LOGIC;
           addr : in  STD_LOGIC_VECTOR (9 downto 0);
           dout : out  STD_LOGIC_VECTOR (7 downto 0));
end AsciiFontRom;

architecture Structural of AsciiFontRom is

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
	
	signal dout_s : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	
	type ROM is ARRAY(0 to 1023) of STD_LOGIC_VECTOR(7 downto 0);
	constant font_rom : ROM := (
		-- Memory of the ascii characters 0-127. Each line
		-- represents a Symbol of 8x8 pixels
		-- Font: Standard.pf, PixelFontEdit 2.7
		-- ascii table: http://www.asciitable.com/index/asciifull.gif		
			x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",	-- (.)
			x"7E", x"81", x"A5", x"81", x"BD", x"99", x"81", x"7E",	-- (.)
			x"7E", x"FF", x"DB", x"FF", x"C3", x"E7", x"FF", x"7E",	-- (.)
			x"6C", x"FE", x"FE", x"FE", x"7C", x"38", x"10", x"00",	-- (.)
			x"10", x"38", x"7C", x"FE", x"7C", x"38", x"10", x"00",	-- (.)
			x"3C", x"3C", x"18", x"FF", x"E7", x"18", x"3C", x"00",	-- (.)
			x"10", x"38", x"7C", x"FE", x"EE", x"10", x"38", x"00",	-- (.)
			x"00", x"00", x"18", x"3C", x"3C", x"18", x"00", x"00",	-- (.)
			x"FF", x"FF", x"E7", x"C3", x"C3", x"E7", x"FF", x"FF",	-- (.)
			x"00", x"3C", x"66", x"42", x"42", x"66", x"3C", x"00",	-- (.)
			x"FF", x"C3", x"99", x"BD", x"BD", x"99", x"C3", x"FF",	-- (.)
			x"0F", x"07", x"0F", x"7D", x"CC", x"CC", x"CC", x"78",	-- (.)
			x"3C", x"66", x"66", x"66", x"3C", x"18", x"7E", x"18",	-- (.)
			x"08", x"0C", x"0A", x"0A", x"08", x"78", x"F0", x"00",	-- (.)
			x"18", x"14", x"1A", x"16", x"72", x"E2", x"0E", x"1C",	-- (.)
			x"10", x"54", x"38", x"EE", x"38", x"54", x"10", x"00",	-- (.)
			x"80", x"E0", x"F8", x"FE", x"F8", x"E0", x"80", x"00",	-- (.)
			x"02", x"0E", x"3E", x"FE", x"3E", x"0E", x"02", x"00",	-- (.)
			x"18", x"3C", x"5A", x"18", x"5A", x"3C", x"18", x"00",	-- (.)
			x"66", x"66", x"66", x"66", x"66", x"00", x"66", x"00",	-- (.)
			x"7F", x"DB", x"DB", x"DB", x"7B", x"1B", x"1B", x"00",	-- (.)
			x"1C", x"22", x"38", x"44", x"44", x"38", x"88", x"70",	-- (.)
			x"00", x"00", x"00", x"00", x"7E", x"7E", x"7E", x"00",	-- (.)
			x"18", x"3C", x"5A", x"18", x"5A", x"3C", x"18", x"7E",	-- (.)
			x"18", x"3C", x"5A", x"18", x"18", x"18", x"18", x"00",	-- (.)
			x"18", x"18", x"18", x"18", x"5A", x"3C", x"18", x"00",	-- (.)
			x"00", x"18", x"0C", x"FE", x"0C", x"18", x"00", x"00",	-- (.)
			x"00", x"30", x"60", x"FE", x"60", x"30", x"00", x"00",	-- (.)
			x"00", x"00", x"C0", x"C0", x"C0", x"FE", x"00", x"00",	-- (.)
			x"00", x"24", x"42", x"FF", x"42", x"24", x"00", x"00",	-- (.)
			x"00", x"10", x"38", x"7C", x"FE", x"FE", x"00", x"00",	-- (.)
			x"00", x"FE", x"FE", x"7C", x"38", x"10", x"00", x"00",	-- (.)
			x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",	-- ( )
			x"18", x"3C", x"3C", x"18", x"18", x"00", x"18", x"00",	-- (!)
			x"6C", x"24", x"24", x"00", x"00", x"00", x"00", x"00",	-- (")
			x"6C", x"6C", x"FE", x"6C", x"FE", x"6C", x"6C", x"00",	-- (#)
			x"10", x"7C", x"D0", x"7C", x"16", x"FC", x"10", x"00",	-- ($)
			x"00", x"66", x"AC", x"D8", x"36", x"6A", x"CC", x"00",	-- (%)
			x"38", x"4C", x"38", x"78", x"CE", x"CC", x"7A", x"00",	-- (&)
			x"30", x"10", x"20", x"00", x"00", x"00", x"00", x"00",	-- (')
			x"18", x"30", x"60", x"60", x"60", x"30", x"18", x"00",	-- (()
			x"60", x"30", x"18", x"18", x"18", x"30", x"60", x"00",	-- ())
			x"00", x"66", x"3C", x"FF", x"3C", x"66", x"00", x"00",	-- (*)
			x"00", x"30", x"30", x"FC", x"30", x"30", x"00", x"00",	-- (+)
			x"00", x"00", x"00", x"00", x"00", x"30", x"10", x"20",	-- (")
			x"00", x"00", x"00", x"FC", x"00", x"00", x"00", x"00",	-- (-)
			x"00", x"00", x"00", x"00", x"00", x"00", x"30", x"00",	-- (.)
			x"02", x"06", x"0C", x"18", x"30", x"60", x"C0", x"00",	-- (/)
			x"7C", x"CE", x"DE", x"F6", x"E6", x"E6", x"7C", x"00",	-- (0)
			x"18", x"38", x"78", x"18", x"18", x"18", x"7E", x"00",	-- (1)
			x"7C", x"C6", x"06", x"1C", x"70", x"C6", x"FE", x"00",	-- (2)
			x"7C", x"C6", x"06", x"3C", x"06", x"C6", x"7C", x"00",	-- (3)
			x"1C", x"3C", x"6C", x"CC", x"FE", x"0C", x"1E", x"00",	-- (4)
			x"FE", x"C0", x"FC", x"06", x"06", x"C6", x"7C", x"00",	-- (5)
			x"7C", x"C6", x"C0", x"FC", x"C6", x"C6", x"7C", x"00",	-- (6)
			x"FE", x"C6", x"0C", x"18", x"30", x"30", x"30", x"00",	-- (7)
			x"7C", x"C6", x"C6", x"7C", x"C6", x"C6", x"7C", x"00",	-- (8)
			x"7C", x"C6", x"C6", x"7E", x"06", x"C6", x"7C", x"00",	-- (9)
			x"00", x"30", x"00", x"00", x"00", x"30", x"00", x"00",	-- (:)
			x"00", x"30", x"00", x"00", x"00", x"30", x"10", x"20",	-- (;)
			x"0C", x"18", x"30", x"60", x"30", x"18", x"0C", x"00",	-- (<)
			x"00", x"00", x"7E", x"00", x"00", x"7E", x"00", x"00",	-- (=)
			x"60", x"30", x"18", x"0C", x"18", x"30", x"60", x"00",	-- (>)
			x"78", x"CC", x"0C", x"18", x"30", x"00", x"30", x"00",	-- (?)
			x"7C", x"82", x"9E", x"A6", x"9E", x"80", x"7C", x"00",	-- (@)
			x"7C", x"C6", x"C6", x"FE", x"C6", x"C6", x"C6", x"00",	-- (A)
			x"FC", x"66", x"66", x"7C", x"66", x"66", x"FC", x"00",	-- (B)
			x"7C", x"C6", x"C0", x"C0", x"C0", x"C6", x"7C", x"00",	-- (C)
			x"FC", x"66", x"66", x"66", x"66", x"66", x"FC", x"00",	-- (D)
			x"FE", x"62", x"68", x"78", x"68", x"62", x"FE", x"00",	-- (E)
			x"FE", x"62", x"68", x"78", x"68", x"60", x"F0", x"00",	-- (F)
			x"7C", x"C6", x"C6", x"C0", x"CE", x"C6", x"7E", x"00",	-- (G)
			x"C6", x"C6", x"C6", x"FE", x"C6", x"C6", x"C6", x"00",	-- (H)
			x"3C", x"18", x"18", x"18", x"18", x"18", x"3C", x"00",	-- (I)
			x"1E", x"0C", x"0C", x"0C", x"CC", x"CC", x"78", x"00",	-- (J)
			x"E6", x"66", x"6C", x"78", x"6C", x"66", x"E6", x"00",	-- (K)
			x"F0", x"60", x"60", x"60", x"62", x"66", x"FE", x"00",	-- (L)
			x"82", x"C6", x"EE", x"FE", x"D6", x"C6", x"C6", x"00",	-- (M)
			x"C6", x"E6", x"F6", x"DE", x"CE", x"C6", x"C6", x"00",	-- (N)
			x"7C", x"C6", x"C6", x"C6", x"C6", x"C6", x"7C", x"00",	-- (O)
			x"FC", x"66", x"66", x"7C", x"60", x"60", x"F0", x"00",	-- (P)
			x"7C", x"C6", x"C6", x"C6", x"D6", x"DE", x"7C", x"06",	-- (Q)
			x"FC", x"66", x"66", x"7C", x"66", x"66", x"E6", x"00",	-- (R)
			x"7C", x"C6", x"C0", x"7C", x"06", x"C6", x"7C", x"00",	-- (S)
			x"7E", x"5A", x"5A", x"18", x"18", x"18", x"3C", x"00",	-- (T)
			x"C6", x"C6", x"C6", x"C6", x"C6", x"C6", x"7C", x"00",	-- (U)
			x"C6", x"C6", x"C6", x"C6", x"6C", x"38", x"10", x"00",	-- (V)
			x"C6", x"C6", x"D6", x"FE", x"EE", x"C6", x"82", x"00",	-- (W)
			x"C6", x"6C", x"38", x"38", x"38", x"6C", x"C6", x"00",	-- (X)
			x"66", x"66", x"66", x"3C", x"18", x"18", x"3C", x"00",	-- (Y)
			x"FE", x"C6", x"8C", x"18", x"32", x"66", x"FE", x"00",	-- (Z)
			x"78", x"60", x"60", x"60", x"60", x"60", x"78", x"00",	-- ([)
			x"C0", x"60", x"30", x"18", x"0C", x"06", x"02", x"00",	-- (\)
			x"78", x"18", x"18", x"18", x"18", x"18", x"78", x"00",	-- (])
			x"10", x"38", x"6C", x"C6", x"00", x"00", x"00", x"00",	-- (^)
			x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"FF",	-- (_)
			x"30", x"20", x"10", x"00", x"00", x"00", x"00", x"00",	-- (`)
			x"00", x"00", x"78", x"0C", x"7C", x"CC", x"76", x"00",	-- (a)
			x"E0", x"60", x"60", x"7C", x"66", x"66", x"7C", x"00",	-- (b)
			x"00", x"00", x"7C", x"C6", x"C0", x"C6", x"7C", x"00",	-- (c)
			x"1C", x"0C", x"0C", x"7C", x"CC", x"CC", x"76", x"00",	-- (d)
			x"00", x"00", x"7C", x"C6", x"FE", x"C0", x"7C", x"00",	-- (e)
			x"1C", x"36", x"30", x"78", x"30", x"30", x"78", x"00",	-- (f)
			x"00", x"00", x"76", x"CC", x"CC", x"7C", x"0C", x"78",	-- (g)
			x"E0", x"60", x"6C", x"76", x"66", x"66", x"E6", x"00",	-- (h)
			x"18", x"00", x"38", x"18", x"18", x"18", x"3C", x"00",	-- (i)
			x"00", x"0C", x"00", x"1C", x"0C", x"0C", x"CC", x"78",	-- (j)
			x"E0", x"60", x"66", x"6C", x"78", x"6C", x"E6", x"00",	-- (k)
			x"38", x"18", x"18", x"18", x"18", x"18", x"3C", x"00",	-- (l)
			x"00", x"00", x"CC", x"FE", x"D6", x"D6", x"D6", x"00",	-- (m)
			x"00", x"00", x"DC", x"66", x"66", x"66", x"66", x"00",	-- (n)
			x"00", x"00", x"7C", x"C6", x"C6", x"C6", x"7C", x"00",	-- (o)
			x"00", x"00", x"DC", x"66", x"66", x"7C", x"60", x"F0",	-- (p)
			x"00", x"00", x"7C", x"CC", x"CC", x"7C", x"0C", x"1E",	-- (q)
			x"00", x"00", x"DE", x"76", x"60", x"60", x"F0", x"00",	-- (r)
			x"00", x"00", x"7C", x"C0", x"7C", x"06", x"7C", x"00",	-- (s)
			x"10", x"30", x"FC", x"30", x"30", x"34", x"18", x"00",	-- (t)
			x"00", x"00", x"CC", x"CC", x"CC", x"CC", x"76", x"00",	-- (u)
			x"00", x"00", x"C6", x"C6", x"6C", x"38", x"10", x"00",	-- (v)
			x"00", x"00", x"C6", x"D6", x"D6", x"FE", x"6C", x"00",	-- (w)
			x"00", x"00", x"C6", x"6C", x"38", x"6C", x"C6", x"00",	-- (x)
			x"00", x"00", x"CC", x"CC", x"CC", x"7C", x"0C", x"F8",	-- (y)
			x"00", x"00", x"FC", x"98", x"30", x"64", x"FC", x"00",	-- (z)
			x"0E", x"18", x"18", x"30", x"18", x"18", x"0E", x"00",	-- ({)
			x"18", x"18", x"18", x"00", x"18", x"18", x"18", x"00",	-- (|)
			x"E0", x"30", x"30", x"18", x"30", x"30", x"E0", x"00",	-- (})
			x"76", x"DC", x"00", x"00", x"00", x"00", x"00", x"00",	-- (~)
			x"00", x"10", x"38", x"6C", x"C6", x"C6", x"FE", x"00"	-- (.)      	
	);		
	
begin

	dout_s <= font_rom(to_integer(unsigned(addr)));
	
	buffer_reg: NBitRegister GENERIC MAP (N => 8) PORT MAP(
		din => dout_s,
		dout => dout,
		ce => '1',
		re => '1',
		rst => '0',
		clk => clk
	);

end Structural;

