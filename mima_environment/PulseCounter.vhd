library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity PulseCounter is
    Port ( clk : in  STD_LOGIC;
           pulse : out  STD_LOGIC);
end PulseCounter;

architecture Behavioral of PulseCounter is
	
	constant UBOUND : UNSIGNED(27 downto 0) := x"26259FF";     -- 1Hz at 40Mhz clock speed
	signal count : UNSIGNED(27 downto 0) := (others => '0');
	
begin
process(clk)
begin
	if (clk'event and clk = '1') then
		if (count = UBOUND) then
			count <= (others => '0');
		else
			count <= count + 1;
		end if;
	end if;
end process;
	
	pulse <= '1' when count = UBOUND else
				'0';

end Behavioral;

