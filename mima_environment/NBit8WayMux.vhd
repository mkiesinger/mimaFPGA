library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity NBit8WayMux is
	 Generic ( N : INTEGER := 1);
    Port ( sel : in  STD_LOGIC_VECTOR(2 downto 0);
           data0 : in  STD_LOGIC_VECTOR (N-1 downto 0);
           data1 : in  STD_LOGIC_VECTOR (N-1 downto 0);
           data2 : in  STD_LOGIC_VECTOR (N-1 downto 0);
           data3 : in  STD_LOGIC_VECTOR (N-1 downto 0);
           data4 : in  STD_LOGIC_VECTOR (N-1 downto 0);
           data5 : in  STD_LOGIC_VECTOR (N-1 downto 0);
           data6 : in  STD_LOGIC_VECTOR (N-1 downto 0);
           data7 : in  STD_LOGIC_VECTOR (N-1 downto 0);
           dout : out  STD_LOGIC_VECTOR (N-1 downto 0));
end NBit8WayMux;

architecture Behavioral of NBit8WayMux is

begin
	
	dout <= data0 when sel = "000" else
			data1 when sel = "001" else
			data2 when sel = "010" else
			data3 when sel = "011" else
			data4 when sel = "100" else
			data5 when sel = "101" else
			data6 when sel = "110" else
			data7 when sel = "111";

end Behavioral;

