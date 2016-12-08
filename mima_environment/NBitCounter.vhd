library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity NBitCounter is
	 Generic (N : INTEGER := 26);
    Port ( dout : out  STD_LOGIC_VECTOR(N-1 downto 0);
			  en : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           rst : in  STD_LOGIC);
end NBitCounter;

architecture Behavioral of NBitCounter is
	signal count : UNSIGNED(N-1 downto 0) := (others => '0');
begin
process(clk, rst, en)
begin
	if (clk'event and clk = '1') then
		if (rst = '1') then
			count <= (others => '0');
		else 
			if (en = '1') then
				count <= count + 1;
			end if;
		end if;
	end if;
end process;
	dout <= std_logic_vector(count);
end Behavioral;

