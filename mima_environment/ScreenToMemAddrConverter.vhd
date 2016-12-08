library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ScreenToMemAddrConverter is
    Port ( x : in  STD_LOGIC_VECTOR (9 downto 0);
           y : in  STD_LOGIC_VECTOR (9 downto 0);
			  addr : out  STD_LOGIC_VECTOR (12 downto 0);
           din : in  STD_LOGIC_VECTOR (15 downto 0);
           pixel : out  STD_LOGIC;
			  clk : in  STD_LOGIC);
end ScreenToMemAddrConverter;

architecture Structural of ScreenToMemAddrConverter is
	
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
	
	function one_bit_16_way_mux(v : std_logic_vector(15 downto 0); sel : std_logic_vector(3 downto 0)) return std_logic is
	begin
		return v(to_integer(unsigned(sel)));
	end function one_bit_16_way_mux; 
	
	signal pixel_sel_s : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
	signal x_del_s : STD_LOGIC_VECTOR(0 downto 0) := (others => '0');
	signal y_del_s : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
	
begin

	addr <= y(7 downto 0) & x(8 downto 4);

	mux_delay_reg: NBitRegister GENERIC MAP (N => 4) PORT MAP(
		din => x(3 downto 0),
		dout => pixel_sel_s,
		ce => '1',
		re => '1',
		rst => '0',
		clk => clk
	);
	
	x_delay_reg: NBitRegister GENERIC MAP (N => 1) PORT MAP(x(9 downto 9), '1', '1', '0', clk, x_del_s);
	y_delay_reg: NBitRegister GENERIC MAP (N => 2) PORT MAP(y(9 downto 8), '1', '1', '0', clk, y_del_s);

	
	pixel <= not one_bit_16_way_mux(din, not pixel_sel_s) when 
				y_del_s = "00" and
				x_del_s = "0" else '1';
	
end Structural;

