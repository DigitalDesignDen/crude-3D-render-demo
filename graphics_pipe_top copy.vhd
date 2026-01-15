-- graphics_pipe_top
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity graphics_pipe_top is
	port (
		-- clock
		CLOCK_50_B5B	:	in std_logic;

		-- video conduit
		HDMI_TX_HS	:	out std_logic;
		HDMI_TX_VS	:	out std_logic;
		HDMI_TX_CLK	:	out std_logic;
		HDMI_TX_DE	:	out std_logic;
		HDMI_TX_INT	:	in std_logic;
		HDMI_TX_D	:	out std_logic_vector(23 downto 0);
		
		-- LEDs conduit
		LEDR			:	out std_logic_vector(9 downto 0);
		LEDG			:	out std_logic_vector(7 downto 0);
		
		-- Keys conduit
		KEY			: in std_logic_vector(3 downto 0);
		
		-- Switched conduit
		SW				: in std_logic_vector(9 downto 0)
	);
end graphics_pipe_top;

architecture structural of graphics_pipe_top is

-- state Machine signals
type t_state is (start, readADC, writeSamples, readSamples);
signal s_stateM : t_state := start;

-- video signals
signal clock_25	: std_logic;
signal videoEN		: std_logic;
signal red, green	: std_logic_vector(7 downto 0);
signal blue			: std_logic_vector(7 downto 0);
signal hc, vc		: std_logic_vector(9 downto 0);

--ram signals
signal s_ram_data_out		: std_logic_vector(11 downto 0);
signal s_sample				: std_logic_vector(11 downto 0);
signal s_ram_write_en		: std_logic := '1';
signal addr_read				: natural range 0 to (640 - 1) := 0;
signal addr_write				: natural range 0 to (640 - 1) := 0;
signal s_readAllowed_50		: std_logic;
signal r_readAllowed_25		: std_logic;
signal s_writeAllowed		: std_logic := '1';

--synchronizer signals
signal r_synchPipe_25		: std_logic;

--graphical signals
type t_P3 is array (0 to 3) of integer;
type t_P3_collection is array (natural range <>) of t_P3; --0 to 41

--sin cos signals
signal angle_index : integer range 0 to 255 := 0;
signal sin_value   : integer range -32768 to 32767;
signal cos_value   : integer range -32768 to 32767;


constant s_suzanneModel				: t_P3_collection			:= (
	(-71, -7, 75, 1),
	(71, -7, 75, 1),
	(45, 5, 81, 1),
	(-45, 5, 81, 1),
	(-31, -23, 105, 1),
	(-20, -7, 84, 1),
	(20, -7, 84, 1),
	(8, -31, 86, 1),
	(-8, -31, 86, 1),
	(-38, -47, 104, 1),
	(-20, -56, 84, 1),
	(20, -56, 84, 1),
	(-45, -67, 80, 1),
	(45, -67, 80, 1),
	(38, -47, 104, 1),
	(60, -40, 99, 1),
	(-71, -56, 75, 1),
	(71, -56, 75, 1),
	(-82, -31, 73, 1),
	(82, -31, 73, 1),
	(-60, -40, 99, 1),
	(31, -23, 105, 1),
	(-53, -16, 103, 1),
	(53, -16, 103, 1),
	(0, 24, 103, 1),
	(0, -74, 74, 1),
	(-31, 31, 67, 1),
	(46, 120, 74, 1),
	(-46, 120, 74, 1),
	(-73, 10, 74, 1),
	(-104, -52, 82, 1),
	(110, -54, 76, 1),
	(-32, -100, 97, 1),
	(32, -100, 97, 1),
	(0, -54, 96, 1),
	(-79, -22, 86, 1),
	(34, -62, 99, 1),
	(-39, -62, 97, 1),
	(0, 25, 97, 1),
	(0, 18, 96, 1),
	(-11, 16, 104, 1),
	(76, 7, 75, 1),
	(95, -49, 88, 1),
	(32, -84, 111, 1),
	(-32, -85, 110, 1),
	(0, -42, 107, 1),
	(11, 15, 103, 1),
	(-2, 128, 76, 1),
	(13, -16, 96, 1),
	(-17, 31, 97, 1),
	(0, 43, 99, 1),
	(16, 31, 98, 1),
	(5, 115, 89, 1),
	(-13, 98, 95, 1),
	(12, 100, 92, 1),
	(-10, 107, 82, 1),
	(53, -50, 97, 1),
	(71, -39, 88, 1),
	(70, -27, 88, 1),
	(59, -15, 92, 1),
	(48, -11, 94, 1),
	(-25, -39, 98, 1),
	(25, -38, 99, 1),
	(-38, -51, 101, 1),
	(-29, -17, 98, 1),
	(-53, -9, 90, 1),
	(-71, -27, 87, 1),
	(-71, -39, 87, 1),
	(-53, -50, 97, 1),
	(36, -51, 100, 1),
	(29, -17, 98, 1),
	(0, -54, 81, 1),
	(34, -92, 78, 1),
	(-33, -92, 79, 1),
	(58, -70, 57, 1),
	(103, -52, 59, 1),
	(-103, -52, 59, 1),
	(102, -20, 47, 1),
	(-100, -18, 48, 1),
	(32, 30, 67, 1),
	(0, 74, 41, 1),
	(0, 63, 36, 1),
	(-27, 38, 54, 1),
	(41, 118, 51, 1),
	(31, 65, 51, 1),
	(-41, 118, 53, 1),
	(-31, 65, 51, 1),
	(3, 123, 52, 1),
	(28, 38, 54, 1),
	(-27, 29, 60, 1),
	(27, 29, 60, 1),
	(-58, -70, 57, 1),
	(-94, -52, 43, 1),
	(94, -52, 43, 1),
	(-82, -58, 36, 1),
	(82, -58, 36, 1),
	(-115, -51, -31, 1),
	(136, 14, -41, 1),
	(171, -9, -63, 1),
	(177, -40, -57, 1),
	(163, -62, -57, 1),
	(-133, -62, -40, 1),
	(133, -62, -40, 1),
	(115, -51, -31, 1),
	(-161, -23, -58, 1),
	(-161, -7, -52, 1),
	(-136, 14, -41, 1),
	(-123, -39, -37, 1),
	(-115, 5, -27, 1),
	(135, 0, -48, 1),
	(160, -21, -58, 1),
	(121, -41, -38, 1),
	(-114, -32, -34, 1),
	(114, -32, -34, 1),
	(-135, 0, -48, 1),
	(114, 5, -27, 1),
	(-115, -14, -42, 1),
	(115, -14, -42, 1),
	(-121, -8, -43, 1),
	(121, -8, -43, 1),
	(-125, -22, -45, 1),
	(125, -22, -45, 1),
	(-145, -46, -55, 1),
	(151, -43, -56, 1),
	(-133, -56, -63, 1),
	(133, -56, -63, 1),
	(-162, -62, -57, 1),
	(-180, -28, -64, 1),
	(-135, 11, -64, 1),
	(135, 11, -64, 1));

constant s_icosphereModel			: t_P3_collection			:= ((0, 0, -171, 1),
(124, -90, -76, 1),
(-47, -145, -76, 1),
(-153, 0, -76, 1),
(-47, 145, -76, 1),
(124, 90, -76, 1),
(47, -145, 76, 1),
(-124, -90, 76, 1),
(-124, 90, 76, 1),
(47, 145, 76, 1),
(153, 0, 76, 1),
(0, 0, 171, 1),
(-27, -85, -145, 1),
(72, -52, -145, 1),
(45, -138, -90, 1),
(145, 0, -90, 1),
(72, 52, -145, 1),
(-90, 0, -145, 1),
(-118, -85, -90, 1),
(-27, 85, -145, 1),
(-118, 85, -90, 1),
(45, 138, -90, 1),
(163, -52, 0, 1),
(163, 52, 0, 1),
(0, -171, 0, 1),
(100, -138, 0, 1),
(-163, -52, 0, 1),
(-100, -138, 0, 1),
(-100, 138, 0, 1),
(-163, 52, 0, 1),
(100, 138, 0, 1),
(0, 171, 0, 1),
(118, -85, 90, 1),
(-45, -138, 90, 1),
(-145, 0, 90, 1),
(-45, 138, 90, 1),
(118, 85, 90, 1),
(27, -85, 145, 1),
(90, 0, 145, 1),
(-72, -52, 145, 1),
(-72, 52, 145, 1),
(27, 85, 145, 1));

constant s_cubeModel			: t_P3_collection := (
	(-35, 39, 207, 1),
	(-98, 189, 21, 1),
	(186, 4, 105, 1),
	(124, 154, -81, 1),
	(-124, -154, 81, 1),
	(-186, -4, -105, 1),
	(98, -189, -21, 1),
	(35, -39, -207, 1));


constant s_modelVertices		: t_P3_collection (natural range 0 to s_icosphereModel'length-1)	:= s_icosphereModel;
signal s_modelVertices_rot		: t_P3_collection (natural range 0 to s_modelVertices'length-1);


type t_matrix is array (0 to 3, 0 to 3) of integer;
--signal s_A : t_matrix := ((1, 0, 0, 0),  -- Keep X unchanged
--                           (0, 1, 0, 0),  -- Keep Y unchanged
--                           (0, 0, 1, 0),  -- Keep Z unchanged
--                           (0, 0, 0, 1)); -- Homogeneous coordinate

signal f : natural := 1;
signal s_A : t_matrix := ((1, 0, 0, 0),  
                           (0, 1, 0, 0),  
                           (0, 0, 1, 512),    
                           (0, 0, 1, 512));   -- Perspective projection



type t_P2 is array (0 to 3) of integer;
type t_P2_collection is array (natural range <>) of t_P2;
signal s_P2						: t_P2_collection(0 to s_modelVertices'length-1);
signal s_P2_new						: t_P2_collection(0 to s_modelVertices'length-1);

type integer_vector is array (natural range <>) of integer;
type signed_vector12b is array (natural range <>) of signed(11 downto 0);
signal vertex_index : integer range 0 to s_modelVertices'length-1 := 0;

type t_stage_state is (MULT,ADD1,ADD2,PERSMULT,PERSDIV_PREP,PERSDIV,PERSADD,REG,FINAL,IDLE,ASSIGN);
signal stage : t_stage_state := MULT;

signal x_mult, y_mult, z_mult, w_mult : signed_vector12b(0 to 3);
signal x_sum_part1, y_sum_part1, w_sum_part1 : signed(11 downto 0);
signal x_sum, y_sum, w_sum : signed(11 downto 0);
signal w_reciprocal : signed(11 downto 0);
signal x_pers_mult, y_pers_mult : signed(23 downto 0);
signal x_pers_div, y_pers_div : signed(23 downto 0);

signal xy_reg : t_P2_collection(0 to s_modelVertices'length-1); -- Extra register stage
signal x_final : signed(23 downto 0) := (others => '1');
signal y_final : signed(23 downto 0) := (others => '1');

attribute multstyle : string;
attribute multstyle of x_mult, y_mult, w_mult, x_sum, y_sum, w_sum, x_pers_mult, y_pers_mult, x_pers_div, y_pers_div, x_final, y_final: signal is "dsp";


begin

	process(clock_25)
	variable ranThisFrame : boolean := false;
	begin
		if rising_edge(clock_25) then

            if to_integer(unsigned(hc)) = 0 and to_integer(unsigned(vc)) = 0 then
                ranThisFrame := false;
            end if;

			if not ranThisFrame then
				case stage is
					when MULT =>
						-- Load multiplications into pipeline registers
						x_mult(0) <= to_signed( s_A(0,0) * s_modelVertices_rot(vertex_index)(0) , 12);
						x_mult(1) <= to_signed( s_A(0,1) * s_modelVertices_rot(vertex_index)(1) , 12);
						x_mult(2) <= to_signed( s_A(0,2) * s_modelVertices_rot(vertex_index)(2) , 12);
						x_mult(3) <= to_signed( s_A(0,3) * s_modelVertices_rot(vertex_index)(3) , 12);

						y_mult(0) <= to_signed( s_A(1,0) * s_modelVertices_rot(vertex_index)(0) , 12);
						y_mult(1) <= to_signed( s_A(1,1) * s_modelVertices_rot(vertex_index)(1) , 12);
						y_mult(2) <= to_signed( s_A(1,2) * s_modelVertices_rot(vertex_index)(2) , 12);
						y_mult(3) <= to_signed( s_A(1,3) * s_modelVertices_rot(vertex_index)(3) , 12);

						z_mult(0) <= to_signed( s_A(2,0) * s_modelVertices_rot(vertex_index)(0), 12);
						z_mult(1) <= to_signed( s_A(2,1) * s_modelVertices_rot(vertex_index)(1), 12);
						z_mult(2) <= to_signed( s_A(2,2) * s_modelVertices_rot(vertex_index)(2), 12);
						z_mult(3) <= to_signed( s_A(2,3) * s_modelVertices_rot(vertex_index)(3), 12);


						w_mult(0) <= to_signed( s_A(3,0) * s_modelVertices_rot(vertex_index)(0) , 12);
						w_mult(1) <= to_signed( s_A(3,1) * s_modelVertices_rot(vertex_index)(1) , 12);
						w_mult(2) <= to_signed( s_A(3,2) * s_modelVertices_rot(vertex_index)(2) , 12);
						w_mult(3) <= to_signed( s_A(3,3) * s_modelVertices_rot(vertex_index)(3) , 12);
		
						stage <= ADD1; -- Move to addition stage

					when ADD1 => 
						x_sum_part1 <= x_mult(0) + x_mult(1);
						y_sum_part1 <= y_mult(0) + y_mult(1);
						w_sum_part1 <= w_mult(0) + w_mult(1);
						stage <= ADD2;
		
					when ADD2 =>
						-- Compute sum of multiplication results
						x_sum <= x_sum_part1 + x_mult(2) + x_mult(3);
						y_sum <= y_sum_part1 + y_mult(2) + y_mult(3);
						w_sum <= w_sum_part1 + w_mult(2) + w_mult(3);
		
						stage <= PERSMULT; -- Move to perspective multiplication

					when PERSMULT => 
						x_pers_mult <= x_sum * 256;
						y_pers_mult <= y_sum * 256;

						stage <= PERSDIV_PREP;
		
					when PERSDIV_PREP =>
						if w_sum /= 0 then
							w_reciprocal <= 4096 / w_sum; -- Use shift-friendly value (adjust scale factor)
						else
							w_reciprocal <= to_signed(4096, w_reciprocal'length);
						end if;
						stage <= PERSDIV;
					
					when PERSDIV =>
						x_pers_div <= signed(std_logic_vector((x_pers_mult * w_reciprocal))(35 downto 12));
						y_pers_div <= signed(std_logic_vector((y_pers_mult * w_reciprocal))(35 downto 12));
						stage <= PERSADD;

					when PERSADD => 
						x_final <= x_pers_div + 300;
						y_final <= y_pers_div + 280;
						stage <= REG; -- Move to writing output
	
					when REG => 
						xy_reg(vertex_index)(0) <= to_integer(x_final);
						xy_reg(vertex_index)(1) <= to_integer(y_final);
						stage <= FINAL;
		
					when FINAL =>				
						if vertex_index >= ((s_modelVertices'length) - 1) then
							vertex_index <= 0; -- Reset after last vertex
							-- Store final results and move to next vertex
							s_P2_new <= xy_reg;
							stage <= ASSIGN;
						else
							vertex_index <= vertex_index + 1;
							stage <= IDLE;  -- Add an idle state before restarting
						end if;

					when IDLE => 
						stage <= MULT;			-- Restart pipeline for next vertex
						

					when ASSIGN => 
						if to_integer(unsigned(hc)) = 0 and to_integer(unsigned(vc)) = 0 then
							s_P2 <= s_P2_new;
							stage <= MULT;		-- Restart pipeline for next vertex
							ranThisFrame := true;
						end if;
	
					when others => 
						stage <= MULT;
						
				end case;
			end if;
		end if;
	end process;

--process(clock_25)
--begin
--	if(rising_edge(clock_25)) then
--		for k in 0 to 41 loop
--			for i in 0 to 3 loop
--				s_P2(k)(i) <= (s_A(i,0)*s_modelVertices(k,0)) + (s_A(i,1)*s_modelVertices(k,1)) + 
--							  (s_A(i,2)*s_modelVertices(k,2)) + (s_A(i,3)*s_modelVertices(k,3));						
--			end loop;
--		end loop;
--	end if;
--end process;



rotationTransform : process(clock_25)
variable counter25 : natural;
constant prescaler25 : natural := 625000;
constant angle_max : integer := 255;

variable x : integer;
variable y : integer;
variable z : integer;
variable w : integer;
variable x_tmp : integer;
variable z_tmp : integer;

begin
	if rising_edge(clock_25) then
		if counter25 < prescaler25 then
			counter25 := counter25 + 1;
		else
			counter25 := 0;

			angle_index <= (angle_index + 1) mod angle_max;

			for k in 0 to s_modelVertices'length-1 loop
				x := s_modelVertices(k)(0);
				y := s_modelVertices(k)(1);
				z := s_modelVertices(k)(2);
				w := s_modelVertices(k)(3);
			
				x_tmp := x * cos_value + z * sin_value;
				z_tmp := (-1) * x * sin_value + z * cos_value;
			
				-- Optional: rounding
				s_modelVertices_rot(k)(0) <= to_integer( to_signed((x_tmp + 16384),32) srl 15 );
				s_modelVertices_rot(k)(1) <= y;
				s_modelVertices_rot(k)(2) <= to_integer( to_signed((z_tmp + 16384),32) srl 15 );
				s_modelVertices_rot(k)(3) <= w;

--				s_modelVertices_rot(k)(0) <= (( s_modelVertices(k)(0) * cos_value + s_modelVertices(k)(2) * sin_value ) + 16383) / 32768;
--				s_modelVertices_rot(k)(1) <= s_modelVertices(k)(1);
--				s_modelVertices_rot(k)(2) <= (( (-1) * s_modelVertices(k)(0) * sin_value + s_modelVertices(k)(2) * cos_value ) + 16383) / 32768;
--				s_modelVertices_rot(k)(3) <= s_modelVertices(k)(3);
					
			end loop;
			
		end if;
	end if;
end process;


--Synchronizer_50to25 : process(clock_25)
--begin
--	if(rising_edge(clock_25)) then
--		r_synchPipe_25		<= s_readAllowed_50;
--		r_readAllowed_25	<= r_synchPipe_25;
--	end if;
--end process Synchronizer_50to25;

--sampleWrite : process(CLOCK_50_B5B)
--variable match : boolean := false;
--begin
--match := false;
--	if (rising_edge(CLOCK_50_B5B)) then
--		if (s_writeAllowed = '1') then
--			if (addr_write = 639) then
--				addr_write <= 0;
--				s_readAllowed_50 <= '1';
--
--			else
--				addr_write <= addr_write + 1;
--				
--				
--				for n in 0 to 41 loop
--					if addr_write = s_P2(n)(1) then
--						s_sample <= std_logic_vector(to_unsigned( s_P2(n)(2) , 12));
--						match := true;
--					end if;
--				end loop;
--				
--				if not match then
--					s_sample <= (others => '0');
--				end if;
--			end if;
--		end if;
--	end if;
--end process sampleWrite;

	U1 : vga_640x480
		port map (clk => clock_25, clr => '1', hsync => HDMI_TX_HS,
						vsync => HDMI_TX_VS, hc => hc, vc => vc, visible_img => videoEN);
						
						
	U2 : clkdiv
		port map (mclk => CLOCK_50_B5B, clr => '1', clk25 => clock_25);

	U3 : sincoslut
		port map (angle_index, sin_value, cos_value);
		
--	U3 : sample_RAM
--		port map (clk_a => clock_25, clk_b => CLOCK_50_B5B, addr_a => addr_read, addr_b => addr_write,
--					data_a => (others => '0'), data_b => s_sample, we_a => '0', we_b => s_ram_write_en,
--					q_a => s_ram_data_out,
--					q_b => open);
					
					 
	-- combinational logic     		
	HDMI_TX_DE	<= videoEN;
	HDMI_TX_CLK	<= clock_25;
	HDMI_TX_D(23 downto 16)	<= red;
	HDMI_TX_D(15 downto 8)	<= green;
	HDMI_TX_D(7 downto 0)	<= blue;

--	LEDG(7 downto 0) <= std_logic_vector(x_mult(to_integer(unsigned(SW(1 downto 0)))))(7 downto 0);
--	LEDR(3 downto 0) <= std_logic_vector(x_mult(to_integer(unsigned(SW(1 downto 0)))))(11 downto 8);

--process(clock_25)
--begin
--if(rising_edge(clock_25)) then
--	angle_index <= to_integer(unsigned(SW(7 downo 0)));
--end if;
--end process;




--	addr_read <= to_integer(unsigned(hc) - 144) when videoEN = '1' else 0;

	
	
--	ramreader : process (clock_25)
--	begin
--		if(rising_edge(clock_25)) then
--			if (videoEN = '1') then
--				if(true) then
--					if (unsigned(vc) - 31 = unsigned(s_ram_data_out)) then
--						red	<= "11101010";
--						green	<= "11101010";		-- point yellow
--						blue	<= "00000000";
--					else
--						red	<= X"46";
--						green	<= X"06";		-- dark reed bg
--						blue	<= X"18";
--					end if;
--				else
--					red	<= X"46";
--					green	<= X"06";
--					blue	<= X"18";
--				end if;
--			else
--				red	<= (others => '0');
--				green	<= (others => '0');	-- all black at blanking
--				blue	<= (others => '0');
--			end if;
--		end if;
--	end process ramreader;

process(clock_25)
variable match	: boolean;
variable x,y	: integer;
begin
    if rising_edge(clock_25) then
        if videoEN = '1' then
            match	:= false;  -- Reset flag before checking pixels
			x		:= to_integer(unsigned(hc) - 144);
			y		:= to_integer(unsigned(vc) - 31);
            
            -- Iterate through all vertices
            for i in 0 to s_modelVertices'length-1 loop

				for dx in 0 to 1 loop
					for dy in 0 to 1 loop
						if (x = s_P2(i)(0) + dx) and 
						   (y = s_P2(i)(1) + dy) then
							red   <= X"00";
							green <= X"FF"; -- Point color
							blue  <= (others => '1');
							match := true;
						end if;
					end loop;
				end loop;
            end loop;
            
            -- If no match was found, set background color
            if not match then
                red   <= (others => '0');
                green <= (others => '0');  -- background
                blue  <= (others => '0');
            end if;
        else
            red   <= (others => '0');
            green <= (others => '0'); -- All black during blanking
            blue  <= (others => '0');
        end if;
    end if;
end process;



end structural;