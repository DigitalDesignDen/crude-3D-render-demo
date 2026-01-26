-- ADC_reader.vhd
-- Author: DigitalDesignDen (Patrick Goncalves)
-- Date: June 6, 2024
-- Description:
-- This file contains an SPI ADC reader module for interfacing with a 12-bit ADC.
-- ADC IC used: LTC2308.
-- The module generates the necessary control signals to initiate conversions.
-- It reads the 12-bit data output from the ADC channel "AD7" and provides it as a standard logic vector output.
-- The module assumes a clock input of 25MHz to meet the timing requirements of the ADC.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ADC_read is 

	port(
		-- clocks
		clk	:	in std_logic;			-- 25MHz clock input
		
		-- adc
		ADC_CONVST	:	out std_logic;
		ADC_SCK		:	out std_logic;
		ADC_SDI		:	out std_logic;
		ADC_SDO		:	in std_logic;

        -- data out
        o_data      :   out std_logic_vector(11 downto 0)
	
	);
	
end ADC_read;

architecture rtl of ADC_read is

	 type state_type is (start, convst1, convst2, conv, sckhi, scklo, hold);	
	 signal state					:	state_type := start;
	 signal data					:	std_logic_vector(11 downto 0);
     signal count					:	integer range 0 to 12 := 0;
	 
	 signal i_clock25				:	std_logic;
	 
	 signal i_convCounter		:	integer range 0 to 79 := 0;


begin

	clock_div : process(clk) --clock_div
	begin
		if (rising_edge(clk)) then
			i_clock25 <= not i_clock25;
		end if;
	end process clock_div; -- clock_div

	
	spi : process(clk) -- spi
	begin
				
		if (rising_edge(clk)) then
		
			ADC_CONVST <= '0';
			ADC_SCK <= '0';
			
			case state is
				when start =>
						ADC_CONVST <= '1';
						state <= convst1;
				when convst1 =>
						state <= convst2;
				when convst2 =>
						state <= conv;
						ADC_CONVST <= '0';
				when conv =>
						-- wait for 1.6us
						if (i_convCounter = 79) then
							i_convCounter <= 0;
							state <= scklo;
						else
							i_convCounter <= i_convCounter + 1;
							state <= conv;
						end if;
				when sckhi =>
						state <= scklo;
						ADC_SCK <= '0';
						data(0) <= ADC_SDO;
						data(11 downto 1) <= data(10 downto 0);
						count <= count + 1;
				when scklo =>
						if count >= 12 then
							state <= hold;
							count <= 0;
						else
							state <= sckhi;
							ADC_SCK <= '1';
						end if;
				when hold =>
						o_data <= data(11 downto 0);
						state <= start;
			end case;
		end if;
	end process spi; -- spi

	
	-- combinational logic

	
	ADC_SDI <= '1';
	
end rtl;