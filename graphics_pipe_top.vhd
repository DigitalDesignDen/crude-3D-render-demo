-- graphics_pipe_top
library ieee;
use work.fixed_pkg.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;
use work.vector_math_pkg.all;

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

		-- adc conduit
		ADC_CONVST	:	out std_logic;
		ADC_SCK		:	out std_logic;
		ADC_SDI		:	out std_logic;
		ADC_SDO		:	in std_logic;
		
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

-- video signals
signal clock_25	: std_logic;
signal videoEN		: std_logic;
signal red, green	: std_logic_vector(7 downto 0);
signal blue			: std_logic_vector(7 downto 0);
signal hc, vc		: std_logic_vector(9 downto 0);

--synchronizer signals
signal r_synchPipe_25		: std_logic;

--graphical signals
type t_P3 is array (0 to 3) of sfixed(10 downto -8);
type t_P3_collection is array (natural range <>) of t_P3;
type t_M4x4 is array (0 to 3, 0 to 3) of sfixed(10 downto -8);

--sin cos signals
signal angle_index : integer range 0 to 255 := 91;
signal sin_value   : sfixed(10 downto -8);
signal cos_value   : sfixed(10 downto -8);

--adc reading
signal adc_reading : std_logic_vector(11 downto 0);


constant test_vertex		: t_P3_collection := (
	(to_sfixed(-100.0,10,-8), to_sfixed(-100.0,10,-8),to_sfixed(0.0,10,-8), to_sfixed(1.0,10,-8)),
	(to_sfixed(100.0,10,-8),  to_sfixed(100.0,10,-8), to_sfixed(0.0,10,-8), to_sfixed(1.0,10,-8)),
	(to_sfixed(100.0,10,-8),  to_sfixed(-100.0,10,-8),to_sfixed(0.0,10,-8), to_sfixed(1.0,10,-8)),
	(to_sfixed(-100.0,10,-8), to_sfixed(100.0,10,-8), to_sfixed(0.0,10,-8), to_sfixed(1.0,10,-8)),
	(to_sfixed(0.0,10,-8),   to_sfixed(0.0,10,-8),  to_sfixed(0.0,10,-8),   to_sfixed(1.0,10,-8))
	);

constant cube				: t_P3_collection := (
(to_sfixed(-2.3225905895233154,10,-8), to_sfixed(2.5303754806518555,10,-8), to_sfixed(13.423962593078613,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(-6.359494209289551,10,-8), to_sfixed(12.235384941101074,10,-8), to_sfixed(1.360952615737915,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(12.06867790222168,10,-8), to_sfixed(0.2855377197265625,10,-8), to_sfixed(6.801873207092285,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(8.031774520874023,10,-8), to_sfixed(9.990547180175781,10,-8), to_sfixed(-5.261137008666992,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(-8.031774520874023,10,-8), to_sfixed(-9.990547180175781,10,-8), to_sfixed(5.261137008666992,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(-12.06867790222168,10,-8), to_sfixed(-0.2855377197265625,10,-8), to_sfixed(-6.801873207092285,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(6.359494209289551,10,-8), to_sfixed(-12.235384941101074,10,-8), to_sfixed(-1.360952615737915,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(2.3225905895233154,10,-8), to_sfixed(-2.5303754806518555,10,-8), to_sfixed(-13.423962593078613,10,-8), to_sfixed(1.0,10,-8))
);

constant icosphere			: t_P3_collection := (
(to_sfixed(0.0,10,-8), to_sfixed(0.0,10,-8), to_sfixed(-8.0,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(5.788858413696289,10,-8), to_sfixed(-4.2058024406433105,10,-8), to_sfixed(-3.57775616645813,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(-2.211104154586792,10,-8), to_sfixed(-6.805193901062012,10,-8), to_sfixed(-3.5777587890625,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(-7.155409812927246,10,-8), to_sfixed(0.0,10,-8), to_sfixed(-3.5777249336242676,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(-2.211104154586792,10,-8), to_sfixed(6.805193901062012,10,-8), to_sfixed(-3.5777587890625,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(5.788858413696289,10,-8), to_sfixed(4.2058024406433105,10,-8), to_sfixed(-3.57775616645813,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(2.211104154586792,10,-8), to_sfixed(-6.805193901062012,10,-8), to_sfixed(3.5777587890625,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(-5.788858413696289,10,-8), to_sfixed(-4.2058024406433105,10,-8), to_sfixed(3.57775616645813,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(-5.788858413696289,10,-8), to_sfixed(4.2058024406433105,10,-8), to_sfixed(3.57775616645813,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(2.211104154586792,10,-8), to_sfixed(6.805193901062012,10,-8), to_sfixed(3.5777587890625,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(7.155409812927246,10,-8), to_sfixed(0.0,10,-8), to_sfixed(3.5777249336242676,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(0.0,10,-8), to_sfixed(0.0,10,-8), to_sfixed(8.0,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(-1.2996444702148438,10,-8), to_sfixed(-3.999962091445923,10,-8), to_sfixed(-6.805235385894775,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(3.4025814533233643,10,-8), to_sfixed(-2.4720911979675293,10,-8), to_sfixed(-6.805233478546143,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(2.1029505729675293,10,-8), to_sfixed(-6.472093105316162,10,-8), to_sfixed(-4.205901145935059,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(6.805182933807373,10,-8), to_sfixed(0.0,10,-8), to_sfixed(-4.205887317657471,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(3.4025814533233643,10,-8), to_sfixed(2.4720911979675293,10,-8), to_sfixed(-6.805233478546143,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(-4.205838203430176,10,-8), to_sfixed(0.0,10,-8), to_sfixed(-6.805213451385498,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(-5.505515098571777,10,-8), to_sfixed(-3.9999754428863525,10,-8), to_sfixed(-4.205889701843262,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(-1.2996444702148438,10,-8), to_sfixed(3.999962091445923,10,-8), to_sfixed(-6.805235385894775,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(-5.505515098571777,10,-8), to_sfixed(3.9999754428863525,10,-8), to_sfixed(-4.205889701843262,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(2.1029505729675293,10,-8), to_sfixed(6.472093105316162,10,-8), to_sfixed(-4.205901145935059,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(7.608462810516357,10,-8), to_sfixed(-2.4721009731292725,10,-8), to_sfixed(0.0,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(7.608462810516357,10,-8), to_sfixed(2.4721009731292725,10,-8), to_sfixed(0.0,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(0.0,10,-8), to_sfixed(-7.999999523162842,10,-8), to_sfixed(0.0,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(4.702284812927246,10,-8), to_sfixed(-6.472133636474609,10,-8), to_sfixed(0.0,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(-7.608462810516357,10,-8), to_sfixed(-2.4721009731292725,10,-8), to_sfixed(0.0,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(-4.702284812927246,10,-8), to_sfixed(-6.472133636474609,10,-8), to_sfixed(0.0,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(-4.702284812927246,10,-8), to_sfixed(6.472133636474609,10,-8), to_sfixed(0.0,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(-7.608462810516357,10,-8), to_sfixed(2.4721009731292725,10,-8), to_sfixed(0.0,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(4.702284812927246,10,-8), to_sfixed(6.472133636474609,10,-8), to_sfixed(0.0,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(0.0,10,-8), to_sfixed(7.999999523162842,10,-8), to_sfixed(0.0,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(5.505515098571777,10,-8), to_sfixed(-3.9999754428863525,10,-8), to_sfixed(4.205889701843262,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(-2.1029505729675293,10,-8), to_sfixed(-6.472093105316162,10,-8), to_sfixed(4.205901145935059,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(-6.805182933807373,10,-8), to_sfixed(0.0,10,-8), to_sfixed(4.205887317657471,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(-2.1029505729675293,10,-8), to_sfixed(6.472093105316162,10,-8), to_sfixed(4.205901145935059,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(5.505515098571777,10,-8), to_sfixed(3.9999754428863525,10,-8), to_sfixed(4.205889701843262,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(1.2996444702148438,10,-8), to_sfixed(-3.999962091445923,10,-8), to_sfixed(6.805234909057617,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(4.205838203430176,10,-8), to_sfixed(0.0,10,-8), to_sfixed(6.805213451385498,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(-3.4025814533233643,10,-8), to_sfixed(-2.4720911979675293,10,-8), to_sfixed(6.805233478546143,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(-3.4025814533233643,10,-8), to_sfixed(2.4720911979675293,10,-8), to_sfixed(6.805233478546143,10,-8), to_sfixed(1.0,10,-8)),
(to_sfixed(1.2996444702148438,10,-8), to_sfixed(3.999962091445923,10,-8), to_sfixed(6.805234909057617,10,-8), to_sfixed(1.0,10,-8))
);

constant spaceship_vertices : t_P3_collection := (
    -- Nose (tip)
    (to_sfixed(0.0,10,-8),to_sfixed(16.0,10,-8),to_sfixed(0.0,10,-8),to_sfixed(1.0,10,-8)),

    -- Fuselage front (mid-section)
    (to_sfixed(-0.8,10,-8),to_sfixed(9.6,10,-8),to_sfixed(0.32,10,-8),to_sfixed(1.0,10,-8)),
    (to_sfixed(0.8,10,-8), to_sfixed(9.6,10,-8), to_sfixed(0.32,10,-8),to_sfixed(1.0,10,-8)),
    (to_sfixed(0.8,10,-8), to_sfixed(9.6,10,-8), to_sfixed(-0.32,10,-8),to_sfixed(1.0,10,-8)),
    (to_sfixed(-0.8,10,-8), to_sfixed(9.6,10,-8), to_sfixed(-0.32,10,-8),to_sfixed(1.0,10,-8)),

    -- Fuselage rear
    (to_sfixed(-0.64,10,-8), to_sfixed(3.2,10,-8), to_sfixed(0.24,10,-8),to_sfixed(1.0,10,-8)),
    (to_sfixed(0.64,10,-8), to_sfixed(3.2,10,-8), to_sfixed(0.24,10,-8),to_sfixed(1.0,10,-8)),
    (to_sfixed(0.64,10,-8), to_sfixed(3.2,10,-8), to_sfixed(-0.24,10,-8),to_sfixed(1.0,10,-8)),
    (to_sfixed(-0.64,10,-8), to_sfixed(3.2,10,-8), to_sfixed(-0.24,10,-8),to_sfixed(1.0,10,-8)),

    -- Left wing
    (to_sfixed(-2.4,10,-8), to_sfixed(6.4,10,-8), to_sfixed(0.0,10,-8),to_sfixed(1.0,10,-8)),
    (to_sfixed(-0.8,10,-8), to_sfixed(6.4,10,-8), to_sfixed(0.08,10,-8),to_sfixed(1.0,10,-8)),
    (to_sfixed(-0.8,10,-8), to_sfixed(6.4,10,-8), to_sfixed(-0.08,10,-8),to_sfixed(1.0,10,-8)),

    -- Right wing
    (to_sfixed(2.4,10,-8), to_sfixed(6.4,10,-8), to_sfixed(0.0,10,-8), to_sfixed(1.0,10,-8)),
    (to_sfixed(0.8,10,-8), to_sfixed(6.4,10,-8), to_sfixed(0.08,10,-8), to_sfixed(1.0,10,-8)),
    (to_sfixed(0.8,10,-8), to_sfixed(6.4,10,-8), to_sfixed(-0.08,10,-8), to_sfixed(1.0,10,-8)),

    -- Top stabilizer
    (to_sfixed(0.0,10,-8), to_sfixed(4.0,10,-8), to_sfixed(-1.28,10,-8), to_sfixed(1.0,10,-8)),
    (to_sfixed(-0.16,10,-8), to_sfixed(4.0,10,-8), to_sfixed(-0.48,10,-8), to_sfixed(1.0,10,-8)),
    (to_sfixed(0.16,10,-8), to_sfixed(4.0,10,-8), to_sfixed(-0.48,10,-8), to_sfixed(1.0,10,-8))
);

------------------------------------------
-- Plug in the model you want to render --
------------------------------------------
signal s_modelVertices			: t_P3_collection (natural range 0 to cube'length-1)	:= cube;
signal s_modelVertices_rot		: t_P3_collection (natural range 0 to s_modelVertices'length-1);

-----------------------------------
-- Perspective projection matrix --
-----------------------------------									
signal s_A : t_M4x4 := (
  (to_sfixed(1.0,10,-8), to_sfixed(0.0,10,-8), to_sfixed(0.0,10,-8), to_sfixed(0.0,10,-8)),
  (to_sfixed(0.0,10,-8), to_sfixed(1.0,10,-8), to_sfixed(0.0,10,-8), to_sfixed(0.0,10,-8)),
  (to_sfixed(0.0,10,-8), to_sfixed(0.0,10,-8), to_sfixed(1.0,10,-8), to_sfixed(4.0,10,-8)),
  (to_sfixed(0.0,10,-8), to_sfixed(0.0,10,-8), to_sfixed(2#0.0011#,10,-8), to_sfixed(4.0,10,-8))
);




type t_P2 is array (0 to 3) of sfixed(10 downto -8);
type t_P2_collection is array (natural range <>) of t_P2;
signal s_P2							: t_P2_collection(0 to s_modelVertices'length-1);
signal s_P2_new						: t_P2_collection(0 to s_modelVertices'length-1);

type integer_vector is array (natural range <>) of integer;
type signed_vector22Q16 is array (natural range <>) of sfixed(21 downto -16);
signal vertex_index : integer range 0 to s_modelVertices'length-1 := 0;

type t_stage_state is (MULT,ADD1,ADD2,DIVIDE1,DIVIDE2,PERSADD,REG,FINAL,IDLE,ASSIGN);
signal stage : t_stage_state := MULT;

signal x_mult, y_mult, z_mult, w_mult : signed_vector22Q16(0 to 3);

signal x_sum_part1, y_sum_part1, w_sum_part1	: sfixed(22 downto -16);
signal x_sum, y_sum							 	: sfixed(24 downto -16);
signal w_sum									: sfixed(24 downto -16);

signal x_scaled, y_scaled : sfixed(40 downto -16); -- Extra room after shifting
signal x_proj, y_proj : sfixed(10 downto -8);  -- Final screen-space projection



signal xy_reg : t_P2_collection(0 to s_modelVertices'length-1); -- Extra register stage
signal x_final : signed(26 downto 0) := (others => '1');
signal y_final : signed(26 downto 0) := (others => '1');

--------------------------
-- line drawing helpers --
--------------------------
signal DRAW_line_pixel : std_logic;


begin

-------------------------------------------------------------------------------
-- Process to handle the perspective transformation of the current model.    --
-------------------------------------------------------------------------------
	process(clock_25)
	variable ranThisFrame	: boolean := false;
	variable timer			: integer range 0 to 20 := 0;
	begin
		if rising_edge(clock_25) then

            if to_integer(unsigned(hc)) = 0 and to_integer(unsigned(vc)) = 0 then
                ranThisFrame := false;
            end if;

			if not ranThisFrame then
				case stage is
					when MULT =>
						-- Load multiplications into pipeline registers
						x_mult(0) <= s_A(0,0) * s_modelVertices_rot(vertex_index)(0);
						x_mult(1) <= s_A(0,1) * s_modelVertices_rot(vertex_index)(1);
						x_mult(2) <= s_A(0,2) * s_modelVertices_rot(vertex_index)(2);
						x_mult(3) <= s_A(0,3) * s_modelVertices_rot(vertex_index)(3);

						y_mult(0) <= s_A(1,0) * s_modelVertices_rot(vertex_index)(0);
						y_mult(1) <= s_A(1,1) * s_modelVertices_rot(vertex_index)(1);
						y_mult(2) <= s_A(1,2) * s_modelVertices_rot(vertex_index)(2);
						y_mult(3) <= s_A(1,3) * s_modelVertices_rot(vertex_index)(3);

						z_mult(0) <= s_A(2,0) * s_modelVertices_rot(vertex_index)(0);
						z_mult(1) <= s_A(2,1) * s_modelVertices_rot(vertex_index)(1);
						z_mult(2) <= s_A(2,2) * s_modelVertices_rot(vertex_index)(2);
						z_mult(3) <= s_A(2,3) * s_modelVertices_rot(vertex_index)(3);


						w_mult(0) <= s_A(3,0) * s_modelVertices_rot(vertex_index)(0);
						w_mult(1) <= s_A(3,1) * s_modelVertices_rot(vertex_index)(1);
						w_mult(2) <= s_A(3,2) * s_modelVertices_rot(vertex_index)(2);
						w_mult(3) <= s_A(3,3) * s_modelVertices_rot(vertex_index)(3);
		
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
		
						stage <= DIVIDE1; -- Move to perspective multiplication
					
					when DIVIDE1 =>
							-- go to some wait cycles for long combiational path of division
							-- this is the first wait cycle
							timer := 0;
							stage <= DIVIDE2;

					when DIVIDE2 => 
						if timer < 2 then  -- Wait for ~2 additional cycles
							timer := timer + 1;
						else
							-- Perform the division now
							if to_integer(w_sum) /= 0 then
								x_proj <= resize(resize(x_sum , 10, -8) / resize(w_sum , 10, -8) , 10, -8);
								y_proj <= resize(resize(y_sum , 10, -8) / resize(w_sum , 10, -8) , 10, -8);
							else
								x_proj <= resize(x_sum, 10, -8);
								y_proj <= resize(y_sum, 10, -8);
							end if;
							timer := 0;
							stage <= PERSADD;
						end if;

					when PERSADD => 
						xy_reg(vertex_index)(0) <= resize((x_proj sll 2) + 300.0 , 10 , -8);
						xy_reg(vertex_index)(1) <= to_sfixed(to_integer((y_proj sll 2)) + 280, 10, -8);
						stage <= REG; -- Move to writing output
	
					when REG => 

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

---------------------------------------------------------------------------------------------
-- Process to handle the rotational transformation of the current model.    --
---------------------------------------------------------------------------------------------
rotationTransform : process(clock_25)

constant angle_max : integer := 255;
variable x		: sfixed(10 downto -8);
variable y		: sfixed(10 downto -8);
variable z		: sfixed(10 downto -8);
variable w		: sfixed(10 downto -8);
variable x_tmp	: sfixed(10 downto -8);
variable y_tmp	: sfixed(10 downto -8);
variable z_tmp	: sfixed(10 downto -8);

begin
	if rising_edge(clock_25) then
		if to_integer(unsigned(hc)) = 0 and to_integer(unsigned(vc)) = 0 then
--			angle_index <= (angle_index + 1) mod angle_max;
--			angle_index <= (angle_index + to_integer(unsigned(adc_reading(11 downto 6)))) mod angle_max;
			angle_index <= to_integer(unsigned(adc_reading(11 downto 4)));

			s_A(0,0) <= resize(sfixed(SW(9 downto 0)), 10, -8); -- Debug purpose: finde a good value for near clipping plane (x-scale)
			s_A(1,1) <= resize(sfixed(SW(9 downto 0)), 10, -8); -- Debug purpose: finde a good value for near clipping plane (y-scale)
--			s_A(3,2)(-1 downto -8) <= sfixed(adc_reading(11 downto 4));

			-- rotation around y-axis
		--	for k in 0 to s_modelVertices'length-1 loop
		--		x := s_modelVertices(k)(0);
		--		y := s_modelVertices(k)(1);
		--		z := s_modelVertices(k)(2);
		--		w := s_modelVertices(k)(3);
		--	
		--		x_tmp := resize(x * cos_value + z * sin_value , 10, -8);
		--		z_tmp := resize((-1) * x * sin_value + z * cos_value , 10, -8);
		--	
		--		
		--		s_modelVertices_rot(k)(0) <= x_tmp;
		--		s_modelVertices_rot(k)(1) <= y;
		--		s_modelVertices_rot(k)(2) <= z_tmp;
		--		s_modelVertices_rot(k)(3) <= w;
		--			
		--	end loop;


			-- rotation around x-axis
			for k in 0 to s_modelVertices'length-1 loop
				x := s_modelVertices(k)(0);
				y := s_modelVertices(k)(1);
				z := s_modelVertices(k)(2);
				w := s_modelVertices(k)(3);
				
				-- Rotate around the x-axis:
				y_tmp := resize(y * cos_value - z * sin_value, 10, -8);
				z_tmp := resize(y * sin_value + z * cos_value, 10, -8);
				
				s_modelVertices_rot(k)(0) <= x;
				s_modelVertices_rot(k)(1) <= y_tmp;
				s_modelVertices_rot(k)(2) <= z_tmp;
				s_modelVertices_rot(k)(3) <= w;
			end loop;

			
		end if;
	end if;
end process;

----------------
-- Rasterizer --
----------------
process(clock_25)
variable match		: boolean;
variable x,y		: integer;
variable gradient	: integer range -128 to 735; -- 480 + 255

begin
    if rising_edge(clock_25) then
        if videoEN = '1' then
            match	:= false;  -- Reset flag before checking pixels
			x		:= to_integer(unsigned(hc) - 144);
			y		:= to_integer(unsigned(vc) - 31);
            
            -- Iterate through all vertices
            for i in 0 to s_modelVertices'length-1 loop

				for dx in -1 to 1 loop
					for dy in -1 to 1 loop
						if (x = to_integer(s_P2(i)(0)) + dx) and 
						   (y = to_integer(s_P2(i)(1)) + dy) then
							case i is
								when 0 => 
									red   <= (others => '1');
									green <= (others => '1'); -- Point color
									blue  <= (others => '1');
								when 1 => 
									red   <= (others => '0');
									green <= (others => '1'); -- Point color
									blue  <= (others => '0');
								when 2 => 
									red   <= (others => '0');
									green <= (others => '0'); -- Point color
									blue  <= (others => '1');
								when 3 => 
									red   <= (others => '1');
									green <= (others => '0'); -- Point color
									blue  <= (others => '0');
								when 4 => 
									red   <= (others => '0');
									green <= (others => '1'); -- Point color
									blue  <= (others => '1');
								when others => 
									red   <= (others => '1');
									green <= (others => '0'); -- Point color
									blue  <= (others => '1');
						   end case;
							match := true;
						end if;
					end loop;
				end loop;
            end loop;
            
            -- If no match was found, set background color
            if not match then
				gradient := y + angle_index - 128;

				if gradient > 255 then
                	red   <= (others => '1');   -- background
                	green <= (others => '1');   -- background
				elsif gradient < 0 then
					red   <= (others => '0');   -- background
                	green <= (others => '0');   -- background
				else
					red		<= std_logic_vector(to_unsigned(gradient,8));   -- background
					green	<= std_logic_vector(to_unsigned(gradient,8));   -- background
				end if;
                blue  <= X"AA"; --std_logic_vector(to_unsigned( ( 170 + angle_index ) mod 255 , 8));   -- background
            end if;

			if DRAW_line_pixel = '1' then
				red   <= (others => '0');
				green <= (others => '0'); -- line color
				blue  <= (others => '0');
			end if;

        else
            red   <= (others => '0');
            green <= (others => '0'); -- All black during blanking
            blue  <= (others => '0');
        end if;
    end if;
end process;

	U1 : vga_640x480
		port map (clk => clock_25, clr => '1', hsync => HDMI_TX_HS,
						vsync => HDMI_TX_VS, hc => hc, vc => vc, visible_img => videoEN);
						
						
	U2 : clkdiv
		port map (mclk => CLOCK_50_B5B, clr => '1', clk25 => clock_25);

	U3 : sincoslut_fixed
		port map ((255-angle_index), sin_value, cos_value);

	U4 : ADC_read
		port map(clk => clock_25,
				 ADC_CONVST => ADC_CONVST,
				 ADC_SCK => ADC_SCK,
				 ADC_SDI => ADC_SDI,
				 ADC_SDO => ADC_SDO,
				 o_data => adc_reading);
		
					
--------------------------					 
-- combinational logic ---
--------------------------
	HDMI_TX_DE	<= videoEN;
	HDMI_TX_CLK	<= clock_25;
	HDMI_TX_D(23 downto 16)	<= red;
	HDMI_TX_D(15 downto 8)	<= green;
	HDMI_TX_D(7 downto 0)	<= blue;

------------------
-- line drawing --
------------------
process(s_P2, hc, vc)
variable x1, y1, x2, y2		: integer;
variable P1, P2				: integer range 0 to (s_modelVertices'length - 1);
variable dX,dY,dXcur,dYcur	: integer range -1688 to 1688 :=0;
variable HPOS, VPOS			: integer;
variable linear_dependent	: boolean;
variable match				: boolean;
begin
	match := false;

	for i in 0 to 11 loop

		case i is
			when 0 =>
				P1 := 1;
				P2 := 5;

			when 1 => 
				P1 := 1;
				P2 := 3;

			when 2 =>
				P1 := 7;
				P2 := 3;

			when 3 => 
				P1 := 0;
				P2 := 4;

			when 4 => 
				P1 := 3;
				P2 := 2;
			
			when 5 => 
				P1 := 2;
				P2 := 0;

			when 6 => 
				P1 := 0;
				P2 := 1;

			when 7 => 
				P1 := 5;
				P2 := 4;

			when 8 => 
				P1 := 4;
				P2 := 6;

			when 9 => 
				P1 := 7;
				P2 := 6;

			when 10 => 
				P1 := 6;
				P2 := 2;
		
			when others =>
				P1 := 7;
				P2 := 5;
		end case;

		x1 := to_integer(s_P2(P1)(0));
		y1 := to_integer(s_P2(P1)(1));
		x2 := to_integer(s_P2(P2)(0));
		y2 := to_integer(s_P2(P2)(1));
		
		VPOS :=  to_integer(unsigned(vc) - 31);
		HPOS :=  to_integer(unsigned(hc) - 144);


		DIFF(x1,y1,x2,y2,dX,dY);

		DIFF(HPOS,VPOS,x2,y2,dXcur,dYcur);

		DET(dX,dY,dXcur,dYcur,linear_dependent);

		if	linear_dependent AND
			(
			(HPOS < x1 NAND HPOS < x2) AND
			(HPOS > x1 NAND HPOS > x2) AND
			(VPOS < y1 NAND VPOS < y2) AND
			(VPOS > y1 NAND VPOS > y2)
			)
		then
			DRAW_line_pixel <= '1';
			match := true;
		end if;

		if not match then
			DRAW_line_pixel <= '0';
		end if;
	end loop;
end process;



-------------------------------------------
-- For debugging purpose only below here --
-------------------------------------------

--LEDG(7 downto 0) <= std_logic_vector(x_mult(to_integer(unsigned(SW(1 downto 0)))))(7 downto 0);
--LEDR(3 downto 0) <= std_logic_vector(to_unsigned(s_A(3,3), 12))(11 downto 8) when SW(9) = '0';
--LEDG <= std_logic_vector(to_unsigned(s_A(3,3), 12))(7 downto 0) when SW(9) = '0';

--LEDR <= std_logic_vector(s_modelVertices(0)(2))(9 downto 0) when SW(9) = '0';
--LEDG <= std_logic_vector(s_modelVertices(0)(2))(-1 downto -8) when SW(9) = '0' else std_logic_vector(to_sfixed(0.5, 9 ,-8))(-1 downto -8);

--LEDR <= std_logic_vector(s_modelVertices(0)(2)(9 downto 0) when SW(9) = '0' else "0" & std_logic_vector(resize(to_sfixed(-512, 9, -8), 8, -8))(8 downto 0);

LEDG <= adc_reading(11 downto 4);

--process(clock_25)
--begin
--if(rising_edge(clock_25)) then
--	angle_index <= to_integer(unsigned(SW(7 downo 0)));
--end if;
--end process;

---------------------------------------------------------------------------------------------
-- Debug Process to simply move some  model vertices in the z-direction back and forth.    --
---------------------------------------------------------------------------------------------
--MOVE-Z : process(clock_25)
--variable prescale : integer := 1;
--begin
--	if rising_edge(clock_25) then
--		if to_integer(unsigned(hc)) = 0 and to_integer(unsigned(vc)) = 0 then
--			if  s_modelVertices(0)(2) > -15 then
--				s_modelVertices(0)(2) <= resize(s_modelVertices(0)(2) - to_sfixed(0.1,10,-8), 10, -8);
--				s_modelVertices(1)(2) <= resize(s_modelVertices(1)(2) - to_sfixed(0.1,10,-8), 10, -8);
--				s_modelVertices(2)(2) <= resize(s_modelVertices(2)(2) - to_sfixed(0.1,10,-8), 10, -8);
--				s_modelVertices(3)(2) <= resize(s_modelVertices(3)(2) - to_sfixed(0.1,10,-8), 10, -8);
--			else
--				s_modelVertices(0)(2) <= to_sfixed(15.0,10,-8);
--				s_modelVertices(1)(2) <= to_sfixed(15.0,10,-8);
--				s_modelVertices(2)(2) <= to_sfixed(15.0,10,-8);
--				s_modelVertices(3)(2) <= to_sfixed(15.0,10,-8);
--			end if;
--			prescale := 1;
--		else
--			prescale := prescale + 1;
--		end if;
--	end if;
--end process;


end structural;