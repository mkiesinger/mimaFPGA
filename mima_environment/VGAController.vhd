library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.math_real. "ceil";
use IEEE.math_real. "log2";


entity VGAController is
	Generic(DELAY_STAGES : INTEGER := 1);
	Port(clk            : in  STD_LOGIC;
		 en             : in  STD_LOGIC;
		 resolution_sel : in  STD_LOGIC; -- 0: 600x480, 1: 800x600
		 hsync          : out STD_LOGIC;
		 vsync          : out STD_LOGIC;
		 x              : out STD_LOGIC_VECTOR(9 downto 0);
		 y              : out STD_LOGIC_VECTOR(9 downto 0);
		 blank			 : out STD_LOGIC);
end VGAController;

architecture Structural of VGAController is
	COMPONENT NBitRegister
		Generic(N : INTEGER := 1);
		PORT(
			din  : IN  std_logic_vector(N - 1 downto 0);
			ce   : IN  std_logic;
			rst  : IN  std_logic;
			clk  : IN  std_logic;
			dout : OUT std_logic_vector(N - 1 downto 0)
		);
	END COMPONENT;

	COMPONENT Syncer
		GENERIC(                        -- Predefined timings are for 640x480 resolution
			-- Horizontal timing (line)
			HVA : INTEGER := 640;       -- Visible area
			HFP : INTEGER := 16;        -- Front porch
			HSP : INTEGER := 96;        -- Sync pulse
			HBP : INTEGER := 48;        -- Back porch
			-- Vertical timing (frame)
			VVA : INTEGER := 480;       -- Visible area;
			VFP : INTEGER := 10;        -- Front porch
			VSP : INTEGER := 2;         -- Sync pulse
			VBP : INTEGER := 33         -- Back porch
		);
		PORT(
			clk   : IN  std_logic;
			hsync : OUT std_logic;
			vsync : OUT std_logic;
			x     : OUT std_logic_vector(integer(ceil(log2(real(HVA)))) - 1 downto 0);
			y     : OUT std_logic_vector(integer(ceil(log2(real(VVA)))) - 1 downto 0);
			blank : OUT std_logic
		);
	END COMPONENT;

	signal x0_s     : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
	signal y0_s     : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
	signal hsync0_s : STD_LOGIC                    := '0';
	signal vsync0_s : STD_LOGIC                    := '0';
	signal blank0_s : STD_LOGIC                    := '0';

	signal x1_s     : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
	signal y1_s     : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
	signal hsync1_s : STD_LOGIC                    := '0';
	signal vsync1_s : STD_LOGIC                    := '0';
	signal blank1_s : STD_LOGIC                    := '0';

	signal x_s           : STD_LOGIC_VECTOR(9 downto 0)            := (others => '0');
	signal y_s           : STD_LOGIC_VECTOR(9 downto 0)            := (others => '0');
	signal hsync_delay_s : STD_LOGIC_VECTOR(DELAY_STAGES downto 0) := (others => '0');
	signal vsync_delay_s : STD_LOGIC_VECTOR(DELAY_STAGES downto 0) := (others => '0');
	signal blank_delay_s : STD_LOGIC_VECTOR(DELAY_STAGES downto 0) := (others => '0');

begin
	sync640x480 : Syncer PORT MAP(
			hsync => hsync0_s,
			vsync => vsync0_s,
			clk   => clk,
			x     => x0_s(9 downto 0),
			y     => y0_s(8 downto 0),
			blank => blank0_s
		);

	sync800x600 : Syncer
		GENERIC MAP(
			-- Horizontal timing (line)
			HVA => 800,                 -- Visible area
			HFP => 40,                  -- Front porch
			HSP => 128,                 -- Sync pulse
			HBP => 88,                  -- Back porch
			-- Vertical timing (frame)
			VVA => 600,                 -- Visible area;
			VFP => 1,                   -- Front porch
			VSP => 4,                   -- Sync pulse
			VBP => 23                   -- Back porch
		)
		PORT MAP(
			hsync => hsync1_s,
			vsync => vsync1_s,
			clk   => clk,
			x     => x1_s(9 downto 0),
			y     => y1_s(9 downto 0),
			blank => blank1_s
		);

	x_s <= x0_s when resolution_sel = '0' else x1_s when resolution_sel = '1';
	y_s <= y0_s when resolution_sel = '0' else y1_s when resolution_sel = '1';

	x <= x_s when en = '1' else (others => '0');
	y <= y_s when en = '1' else (others => '0');

	hsync_delay_s(0) <= hsync0_s when resolution_sel = '0' else hsync1_s when resolution_sel = '1';
	vsync_delay_s(0) <= vsync0_s when resolution_sel = '0' else vsync1_s when resolution_sel = '1';
	blank_delay_s(0) <= blank0_s when resolution_sel = '0' else blank1_s when resolution_sel = '1';

	gen_delay_stages : for I in 0 to DELAY_STAGES - 1 generate -- generates delay pipeline

		hs_reg : NBitRegister GENERIC MAP(N => 1)
			PORT MAP(
				din  => hsync_delay_s(I downto I),
				dout => hsync_delay_s(I + 1 downto I + 1),
				ce   => '1',
				rst  => '0',
				clk  => clk
			);

		vs_reg : NBitRegister GENERIC MAP(N => 1)
			PORT MAP(
				din  => vsync_delay_s(I downto I),
				dout => vsync_delay_s(I + 1 downto I + 1),
				ce   => '1',
				rst  => '0',
				clk  => clk
			);
			
		blank_reg : NBitRegister GENERIC MAP(N => 1)
			PORT MAP(
				din  => blank_delay_s(I downto I),
				dout => blank_delay_s(I + 1 downto I + 1),
				ce   => '1',
				rst  => '0',
				clk  => clk
			);

	end generate gen_delay_stages;

	hsync <= hsync_delay_s(DELAY_STAGES) and en;
	vsync <= vsync_delay_s(DELAY_STAGES) and en;
	blank <= blank_delay_s(DELAY_STAGES) and en;
	
end Structural;

