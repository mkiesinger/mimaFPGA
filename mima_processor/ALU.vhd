library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ALU is
    Port ( x : in  STD_LOGIC_VECTOR (23 downto 0);
           y : in  STD_LOGIC_VECTOR (23 downto 0);
			  func : in  STD_LOGIC_VECTOR (2 downto 0);
           z : out  STD_LOGIC_VECTOR (23 downto 0));
end ALU;

architecture Behavioral of ALU is

begin
process(x, y, func)
	variable comp : STD_LOGIC_VECTOR(23 downto 0) := std_logic_vector(to_unsigned(0, 24));
begin
	
	if (unsigned(x) = unsigned(y)) then
		comp := std_logic_vector(to_signed(-1, 24));
	else 
		comp := std_logic_vector(to_unsigned(0, 24));
	end if; 
	
	case func is
			when "000" => z <= std_logic_vector(to_unsigned(0, 24));
			when "001" => z <= std_logic_vector(unsigned(x) + unsigned(y));
			when "010" => z <= x(0) & x(23 downto 1);
			when "011" => z <= x and y;
			when "100" => z <= x or y;
			when "101" => z <= x xor y;
			when "110" => z <= not x;
			when "111" => z <= comp;
			when others => z <= std_logic_vector(to_unsigned(0, 24));
		end case;	
end process;

end Behavioral;

