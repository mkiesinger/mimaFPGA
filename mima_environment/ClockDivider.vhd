library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ClockDivider is
    Port ( clk_in : in  STD_LOGIC;
           clk_out : out  STD_LOGIC;
           div : in  STD_LOGIC_VECTOR (24 downto 0);
           set_div : in  STD_LOGIC);
end ClockDivider;

architecture Behavioral of ClockDivider is
	signal ubound : UNSIGNED(24 downto 0) := (others => '0');
	signal p : STD_LOGIC := '0'; 
	signal count : UNSIGNED(24 downto 0) := (others => '0');
begin
process(clk_in, div, set_div)
begin
	if (clk_in'event and clk_in = '1') then	
		if (count = (count'range => '0')) then 
			if (p = '0') then
				count <= ubound;
			end if;
			p <= not p;
		else 
			count <= count - 1;
		end if;
		
		if (set_div = '1') then
			ubound <= unsigned(div);
		end if;
		
	end if;
end process;
	clk_out <= p;
	
end Behavioral;
