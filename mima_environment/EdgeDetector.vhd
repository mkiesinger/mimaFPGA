library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity EdgeDetector is
    Port ( input : in  STD_LOGIC; 
			  clk : in  STD_LOGIC;
           sel : in  STD_LOGIC;	-- sel = '0': detects rising edge; else falling edge
           pulse : out  STD_LOGIC;
			  rst : in  STD_LOGIC := '0');
end EdgeDetector;

architecture Behavioral of EdgeDetector is

	signal prev, curr : STD_LOGIC := '0';
	
begin
process(clk, input, sel) 
begin

	if (clk'event and clk = '1') then
		if (rst = '1') then
			curr <= '0';
			prev <= '0';
		else 
			curr <= input;
			prev <= curr;
		end if;
	end if;
	
end process;

	pulse <= '1' when prev = '0' and curr = '1' and sel = '0' else
				'1' when prev = '1' and curr = '0' and sel = '1' else
				'0';
				
end Behavioral;

