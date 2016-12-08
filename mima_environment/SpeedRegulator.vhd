library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity SpeedRegulator is
    Port ( en : in  STD_LOGIC;
           mode : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           speed : out  STD_LOGIC_VECTOR (24 downto 0));
end SpeedRegulator;

architecture Behavioral of SpeedRegulator is
	constant STEP : UNSIGNED(24 downto 0) := "0" & x"000001";
	signal speed_reg : UNSIGNED(24 downto 0) := "0" & x"000001"; -- "1" & x"312D00";    -- 20M to start clock at 1 hz

begin
process(clk, mode, en)
begin
	if (clk'event and clk = '1') then
		if (en = '1') then
			if (mode = '0') then 				-- increment
				speed_reg <= speed_reg + STEP;
			else 										-- decrement
				speed_reg <= speed_reg - STEP;
			end if;
		end if;
	end if;
end process;
	speed <= std_logic_vector(speed_reg);

end Behavioral;

