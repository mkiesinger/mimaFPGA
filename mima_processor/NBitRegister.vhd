library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity NBitRegister is
	 Generic ( N : INTEGER := 1);
    Port ( din : in  STD_LOGIC_VECTOR (N-1 downto 0);
           dout : out  STD_LOGIC_VECTOR (N-1 downto 0);
           ce : in  STD_LOGIC := '1';
			  re : in  STD_LOGIC := '1';
			  rst : in  STD_LOGIC := '0';
           clk : in  STD_LOGIC);
	end NBitRegister;

architecture Behavioral of NBitRegister is

	signal reg : STD_LOGIC_VECTOR(N-1 downto 0) := (others => '0');
	
begin
process(clk, ce, din, rst)
begin
		if (clk'event and clk = '1') then
			if (rst = '1') then
				reg <= (others => '0');
			else 
				if (ce = '1') then
					reg <= din;
				end if;
			end if;
		end if;
end process;

	dout <= reg when re = '1' else
			  (others => '0');

end Behavioral;

