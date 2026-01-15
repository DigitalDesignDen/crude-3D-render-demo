-- sincoslut
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity sincoslut is
    port (
        angle_index : in integer range 0 to 255;
        sin_value   : out integer range -32768 to 32767; --range -32768 to 32767;
        cos_value   : out integer range -32768 to 32767
    );
end sincoslut;

architecture rtl of sincoslut is

    type sin_lut_t is array (0 to 63) of integer range 0 to 32767;
    constant SIN_LUT : sin_lut_t := (
        0,
804,
1607,
2410,
3211,
4011,
4807,
5601,
6392,
7179,
7961,
8739,
9511,
10278,
11038,
11792,
12539,
13278,
14009,
14732,
15446,
16150,
16845,
17530,
18204,
18867,
19519,
20159,
20787,
21402,
22004,
22594,
23169,
23731,
24278,
24811,
25329,
25831,
26318,
26789,
27244,
27683,
28105,
28510,
28897,
29268,
29621,
29955,
30272,
30571,
30851,
31113,
31356,
31580,
31785,
31970,
32137,
32284,
32412,
32520,
32609,
32678,
32727,
32757
        );
    

begin


    
    process(angle_index)
    begin
            case angle_index is
                when 0 to 63  => sin_value <= SIN_LUT(angle_index);
                when 64 to 127 => sin_value <= SIN_LUT(127 - angle_index);  -- sin(90 - x) = cos(x)
                when 128 to 191 => sin_value <= (-1) * SIN_LUT(angle_index - 128); -- sin(180 - x) = -sin(x)
                when 192 to 255 => sin_value <= (-1) * SIN_LUT(255 - angle_index); -- sin(270 - x) = -cos(x)
            end case;
            
            case angle_index is
                when 0 to 63  => cos_value <= SIN_LUT(63 - angle_index); -- cos(x) = sin(90 - x)
                when 64 to 127 => cos_value <= (-1) * SIN_LUT(angle_index - 64); -- cos(180 - x) = -cos(x)
                when 128 to 191 => cos_value <= (-1) * SIN_LUT(191 - angle_index); -- cos(270 - x) = -sin(x)
                when 192 to 255 => cos_value <= SIN_LUT(angle_index - 192); -- cos(360 - x) = sin(x)
            end case;
    end process;
    

end architecture;