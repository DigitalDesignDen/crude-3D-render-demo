-- vga_640x480
library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity vga_640x480 is
	port (	clk, clr :		in std_logic;
				hsync : 		out std_logic;
				vsync :			out std_logic;
				hc :				out std_logic_vector(9 downto 0);
				vc :				out std_logic_vector(9 downto 0);
				visible_img :	out std_logic
			);
end vga_640x480;

architecture vga_640x480 of vga_640x480 is
 
-- pixels per line = 800
constant hpixels : std_logic_vector(9 downto 0) := "1100100000";

-- # of lines = 521
--constant vlines : std_logic_vector(9 downto 0) := "1000001001";
constant vlines : std_logic_vector(9 downto 0) := "1000001101"; --525

-- hor back porch = 144 (128 + 16)
constant hbp : std_logic_vector(9 downto 0) := "0010010000";

-- hor front porch = 784 (128 + 16 +640)
constant hfp : std_logic_vector(9 downto 0) := "1100010000";

-- ver back porch = 31 (2 + 29)
--constant vbp : std_logic_vector(9 downto 0) := "0000011111";
constant vbp : std_logic_vector(9 downto 0) := "0000100011"; --35

-- hor back porch = 511 (2 + 29 + 480)
--constant vfp : std_logic_vector(9 downto 0) := "0111111111";
constant vfp : std_logic_vector(9 downto 0) := "1000000011"; -- 515

-- coutners
signal hcs, vcs : std_logic_vector(9 downto 0);
signal vsenable : std_logic;

begin

-- coutner for the horizontal sync signal
process(clk, clr)
begin
	if clr = '0' then
		hcs <= (others => '0');
	elsif (rising_edge(clk)) then
		if hcs = hpixels - 1 then
		
			-- counter has reached end
			-- reset coutner
			hcs <= "0000000000";
			
			-- enable the vertical counter
			vsenable <= '1';
		else
			hcs <= hcs + 1;
			vsenable <= '0';
		end if;
	end if;
end process;

-- coutner for the vertical sync signal
process(clk,clr)
begin
	if clr = '0' then
		vcs <= (others => '0');
	elsif (rising_edge(clk) and vsenable = '1') then
		if vcs = vlines - 1 then
		
			-- reset counter
			vcs <= (others => '0');
		else
			-- increment vert counter
			vcs <= vcs + 1 ;
		end if;
	end if;
end process;

-- comb logic
-- Horizontal sync pule is low when hc os 0 - 127
--hsync <= '0' when hcs < 128 else '1';
hsync <= '0' when hcs < 96 else '1';

-- Vertical sync pulse is low when vc is 0 or 1
vsync <= '0' when vcs < 2 else '1';

-- Visible image when between the porches
visible_img <= '1' when (((hcs < hfp) and (hcs >= hbp))
							and ((vcs < vfp) and (vcs >= vbp))) else '0';

-- mapping coutner signals to port
hc <= hcs;
vc <= vcs;
							
end vga_640x480;