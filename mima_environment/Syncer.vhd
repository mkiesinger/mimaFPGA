library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.math_real."ceil";
use IEEE.math_real."log2";
use IEEE.NUMERIC_STD.ALL;


entity Syncer is
	Generic( -- Predefined timings are for 640x480 resolution
				-- Horizontal timing (line)
				HVA : INTEGER := 640; -- Visible area
				HFP : INTEGER :=  16; -- Front porch
				HSP : INTEGER :=  96; -- Sync pulse
				HBP : INTEGER :=  48; -- Back porch
				-- Vertical timing (frame)
				VVA : INTEGER := 480; -- Visible area;
				VFP : INTEGER :=  10; -- Front porch
				VSP : INTEGER :=   2; -- Sync pulse
				VBP : INTEGER :=  33  -- Back porch
			);
    Port ( hsync : out  STD_LOGIC;
           vsync : out  STD_LOGIC;
           clk : in  STD_LOGIC;
           x : out  STD_LOGIC_VECTOR (integer(ceil(log2(real(HVA))))-1 downto 0);	-- HVA log2
           y : out  STD_LOGIC_VECTOR (integer(ceil(log2(real(VVA))))-1 downto 0);	-- VVA log2
			  blank : out  STD_LOGIC);
end Syncer;

architecture Behavioral of Syncer is
 
	signal hpos : integer range 0 to HVA+HFP+HSP+HBP := 0;
	signal vpos : integer range 0 to VVA+VFP+VSP+VBP := 0;

begin
process(clk)
begin
	if (clk'event and clk  = '1') then
	
		if (hpos < (HVA+HFP+HSP+HBP) - 1) then
			hpos <= hpos + 1;
		else
			hpos <= 0;	
			if (vpos < (VVA+VFP+VSP+VBP) - 1) then
				vpos <= vpos + 1;
			else
				vpos <= 0;
			end if;
		end if;

		if (hpos >= (HVA+HFP) and hpos < (HVA+HFP+HSP)) then
			hsync <= '0';
		else
			hsync <= '1';
		end if;
  
		if (vpos >= (VVA+VFP) and vpos < (VVA+VFP+VSP)) then
			vsync <= '0';
		else
			vsync <= '1';
		end if;
		
		if (hpos < HVA) then
			x <= std_logic_vector(to_unsigned(hpos, x'length));
		else 
			x <= (others => '0');
		end if;
		
		if (vpos < VVA) then
			y <= std_logic_vector(to_unsigned(vpos, y'length));
		else 
			y <= (others => '0');
		end if;

		if (hpos < HVA and vpos < VVA) then
			blank <= '0';
		else 
			blank <= '1';
		end if;
		
	end if;
end process;

end Behavioral;

