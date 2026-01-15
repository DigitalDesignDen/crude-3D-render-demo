-- clock divider
library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity clkdiv is
	port (	mclk :	in std_logic;
				clr :		in std_logic;
				clk25 :	out std_logic
			);
end clkdiv;

architecture clkdiv of clkdiv is
	signal counter : std_logic_vector(23 downto 0);
begin
	
	process(mclk, clr)
	begin
		if clr = '0' then
			counter <= (others => '0');
		elsif (rising_edge(mclk)) then
			counter <= counter + 1;
		end if;
	end process;
	
	-- comb logic
	clk25 <= counter(0);
	
end clkdiv;