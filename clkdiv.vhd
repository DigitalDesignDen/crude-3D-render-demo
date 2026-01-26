-- clock divider
-- Author: DigitalDesignDen (Patrick Goncalves)
-- Date: 2021-08-15
-- Description:
-- This module implements a clock divider that
-- divides input clock by 2^24 to generate a slower clock.
-- The output clock frequency is determined by the input clock frequency.
-- Multiple bits of the counter can be used to achieve different division factors.


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity clkdiv is
	generic (
		division_factor : integer := 2	-- division factor has to be a power of 2 in range 2 to 16777216
										-- 2^1 to 2^24
										-- division_factor = 2  -> clk_out = mclk / 2
										-- division_factor = 16777216 -> clk_out = mclk / 16777216
										-- default is 2
										-- division_factor of non-power of 2 will result in a rounding to the nearest power of 2			
		); 
	port (	
		mclk	:	in std_logic;
		clr		:	in std_logic;
		clk_out	:	out std_logic
		);
end clkdiv;

architecture clkdiv of clkdiv is
    constant BIT_NO : natural := integer(log2(real(division_factor)))-1;
	signal counter : unsigned(23 downto 0);
begin
	
	process(mclk, clr)
	begin
		if clr = '1' then
			counter <= (others => '0');
		elsif (rising_edge(mclk)) then
			counter <= counter + 1;
		end if;
	end process;
	
	-- comb logic
	clk_out <= counter(BIT_NO);
	
end clkdiv;
