-- ReadBRAM_TOP
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity ReadBRAM is

port (
		CLOCK_50_B5B	:	in std_logic;

		HDMI_TX_HS	:	out std_logic;
		HDMI_TX_VS	:	out std_logic;
		HDMI_TX_CLK	:	out std_logic;
		HDMI_TX_DE	:	out std_logic;
		HDMI_TX_INT	:	in std_logic;
		HDMI_TX_D	:	out std_logic_vector(23 downto 0);
		
		LEDG			:	out std_logic_vector(7 downto 0);
		
		KEY			:	in	std_logic_vector(3 downto 0)
		
		);

end ReadBRAM;


architecture mixed of ReadBRAM is

-- video signals
signal clock_25	: std_logic;
signal videoEN		: std_logic;
signal red, green	: std_logic_vector(7 downto 0);
signal blue			: std_logic_vector(7 downto 0);
signal hc, vc		: std_logic_vector(9 downto 0);

--ram signals
signal s_ram_data_out		: std_logic_vector(11 downto 0);
signal addr_read				: natural range 0 to (640 - 1) := 1;

begin

	U1 : vga_640x480
		port map (clk => clock_25, clr => '1', hsync => HDMI_TX_HS,
						vsync => HDMI_TX_VS, hc => hc, vc => vc, visible_img => videoEN);
						
						
	U2 : clkdiv
		port map (mclk => CLOCK_50_B5B, clr => '0', clk_out => clock_25);
		
	U3 : sample_RAM
		port map (clk_a => clock_25, clk_b => '0', addr_a => addr_read, addr_b => 0,
					data_a => (others => '0'), data_b => (others => '0'), we_a => '0', we_b => '0',
					q_a => s_ram_data_out,
					q_b => open);
		
	
	-- combinational logic
	HDMI_TX_DE	<= videoEN;
	HDMI_TX_CLK	<= clock_25;
	HDMI_TX_D(23 downto 16)	<= red;
	HDMI_TX_D(15 downto 8)	<= green;
	HDMI_TX_D(7 downto 0)	<= blue;
	
	addr_read <= to_integer(unsigned(hc) - 144) when videoEN = '1'
																						else 0;
																						
	LEDG(7 downto 4) <= KEY(3 downto 0);
	
	-- sequential logic
--	colorgen : process(clock_25)
--	begin
--		if (rising_edge(clock_25)) then
--			if (videoEN = '1') then
--				if (hc(5) = '1') then
--					red	<= X"AF";
--					green	<= X"11";
--					blue	<= X"3E";
--				else
--					red	<= X"46";
--					green	<= X"06";
--					blue	<= X"18";
--				end if;
--			else
--				red	<= (others => '0');
--				green	<= (others => '0');
--				blue	<= (others => '0');
--			end if;
--		end if;
--	end process colorgen;
	
	ramreader : process (clock_25)
	begin
		if(rising_edge(clock_25)) then
			if (videoEN = '1') then
				if (unsigned(vc) - 31 = unsigned(s_ram_data_out)) then
					red	<= "11101010";
					green	<= "11101010";
					blue	<= "00000000";
				else
					red	<= X"46";
					green	<= X"06";
					blue	<= X"18";
				end if;
			else
				red	<= (others => '0');
				green	<= (others => '0');
				blue	<= (others => '0');
			end if;
		end if;
	end process ramreader;

end mixed;