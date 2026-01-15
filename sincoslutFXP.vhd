library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fixed_pkg.all;

entity sincoslut_fixed is
    port (
        angle_index : in integer range 0 to 255;
        sin_value   : out sfixed(10 downto -8);
        cos_value   : out sfixed(10 downto -8)
    );
end sincoslut_fixed;

architecture rtl of sincoslut_fixed is

    type sin_lut_t is array (0 to 63) of sfixed(10 downto -8);
    constant SIN_LUT : sin_lut_t := (
--        to_sfixed(0.0, 10, -8),
--to_sfixed(804.0 / 32768.0, 10, -8),
--to_sfixed(1607.0 / 32768.0, 10, -8),
--to_sfixed(2410.0 / 32768.0, 10, -8),
--to_sfixed(3211.0 / 32768.0, 10, -8),
--to_sfixed(4011.0 / 32768.0, 10, -8),
--to_sfixed(4807.0 / 32768.0, 10, -8),
--to_sfixed(5601.0 / 32768.0, 10, -8),
--to_sfixed(6392.0 / 32768.0, 10, -8),
--to_sfixed(7179.0 / 32768.0, 10, -8),
--to_sfixed(7961.0 / 32768.0, 10, -8),
--to_sfixed(8739.0 / 32768.0, 10, -8),
--to_sfixed(9511.0 / 32768.0, 10, -8),
--to_sfixed(10278.0 / 32768.0, 10, -8),
--to_sfixed(11038.0 / 32768.0, 10, -8),
--to_sfixed(11792.0 / 32768.0, 10, -8),
--to_sfixed(12539.0 / 32768.0, 10, -8),
--to_sfixed(13278.0 / 32768.0, 10, -8),
--to_sfixed(14009.0 / 32768.0, 10, -8),
--to_sfixed(14732.0 / 32768.0, 10, -8),
--to_sfixed(15446.0 / 32768.0, 10, -8),
--to_sfixed(16150.0 / 32768.0, 10, -8),
--to_sfixed(16845.0 / 32768.0, 10, -8),
--to_sfixed(17530.0 / 32768.0, 10, -8),
--to_sfixed(18204.0 / 32768.0, 10, -8),
--to_sfixed(18867.0 / 32768.0, 10, -8),
--to_sfixed(19519.0 / 32768.0, 10, -8),
--to_sfixed(20159.0 / 32768.0, 10, -8),
--to_sfixed(20787.0 / 32768.0, 10, -8),
--to_sfixed(21402.0 / 32768.0, 10, -8),
--to_sfixed(22004.0 / 32768.0, 10, -8),
--to_sfixed(22594.0 / 32768.0, 10, -8),
--to_sfixed(23169.0 / 32768.0, 10, -8),
--to_sfixed(23731.0 / 32768.0, 10, -8),
--to_sfixed(24278.0 / 32768.0, 10, -8),
--to_sfixed(24811.0 / 32768.0, 10, -8),
--to_sfixed(25329.0 / 32768.0, 10, -8),
--to_sfixed(25831.0 / 32768.0, 10, -8),
--to_sfixed(26318.0 / 32768.0, 10, -8),
--to_sfixed(26789.0 / 32768.0, 10, -8),
--to_sfixed(27244.0 / 32768.0, 10, -8),
--to_sfixed(27683.0 / 32768.0, 10, -8),
--to_sfixed(28105.0 / 32768.0, 10, -8),
--to_sfixed(28510.0 / 32768.0, 10, -8),
--to_sfixed(28897.0 / 32768.0, 10, -8),
--to_sfixed(29268.0 / 32768.0, 10, -8),
--to_sfixed(29621.0 / 32768.0, 10, -8),
--to_sfixed(29955.0 / 32768.0, 10, -8),
--to_sfixed(30272.0 / 32768.0, 10, -8),
--to_sfixed(30571.0 / 32768.0, 10, -8),
--to_sfixed(30851.0 / 32768.0, 10, -8),
--to_sfixed(31113.0 / 32768.0, 10, -8),
--to_sfixed(31356.0 / 32768.0, 10, -8),
--to_sfixed(31580.0 / 32768.0, 10, -8),
--to_sfixed(31785.0 / 32768.0, 10, -8),
--to_sfixed(31970.0 / 32768.0, 10, -8),
--to_sfixed(32137.0 / 32768.0, 10, -8),
--to_sfixed(32284.0 / 32768.0, 10, -8),
--to_sfixed(32412.0 / 32768.0, 10, -8),
--to_sfixed(32520.0 / 32768.0, 10, -8),
--to_sfixed(32609.0 / 32768.0, 10, -8),
--to_sfixed(32678.0 / 32768.0, 10, -8),
--to_sfixed(32727.0 / 32768.0, 10, -8),
--to_sfixed(32757.0 / 32768.0, 10, -8)
to_sfixed(0.0, 10, -8),
to_sfixed(0.024930691738072875, 10, -8),
to_sfixed(0.04984588566069716, 10, -8),
to_sfixed(0.07473009358642425, 10, -8),
to_sfixed(0.09956784659581666, 10, -8),
to_sfixed(0.12434370464748516, 10, -8),
to_sfixed(0.14904226617617444, 10, -8),
to_sfixed(0.17364817766693033, 10, -8),
to_sfixed(0.19814614319939758, 10, -8),
to_sfixed(0.2225209339563144, 10, -8),
to_sfixed(0.24675739769029362, 10, -8),
to_sfixed(0.2708404681430051, 10, -8),
to_sfixed(0.2947551744109042, 10, -8),
to_sfixed(0.31848665025168443, 10, -8),
to_sfixed(0.3420201433256687, 10, -8),
to_sfixed(0.365341024366395, 10, -8),
to_sfixed(0.38843479627469474, 10, -8),
to_sfixed(0.41128710313061156, 10, -8),
to_sfixed(0.4338837391175581, 10, -8),
to_sfixed(0.45621065735316296, 10, -8),
to_sfixed(0.4782539786213182, 10, -8),
to_sfixed(0.5, 10, -8),
to_sfixed(0.521435203379498, 10, -8),
to_sfixed(0.5425462638657593, 10, -8),
to_sfixed(0.5633200580636221, 10, -8),
to_sfixed(0.5837436722347898, 10, -8),
to_sfixed(0.6038044103254774, 10, -8),
to_sfixed(0.6234898018587335, 10, -8),
to_sfixed(0.6427876096865393, 10, -8),
to_sfixed(0.6616858375968594, 10, -8),
to_sfixed(0.6801727377709194, 10, -8),
to_sfixed(0.6982368180860727, 10, -8),
to_sfixed(0.7158668492597184, 10, -8),
to_sfixed(0.7330518718298263, 10, -8),
to_sfixed(0.7497812029677342, 10, -8),
to_sfixed(0.766044443118978, 10, -8),
to_sfixed(0.7818314824680298, 10, -8),
to_sfixed(0.7971325072229224, 10, -8),
to_sfixed(0.8119380057158565, 10, -8),
to_sfixed(0.8262387743159948, 10, -8),
to_sfixed(0.8400259231507714, 10, -8),
to_sfixed(0.8532908816321556, 10, -8),
to_sfixed(0.8660254037844387, 10, -8),
to_sfixed(0.8782215733702285, 10, -8),
to_sfixed(0.8898718088114685, 10, -8),
to_sfixed(0.9009688679024191, 10, -8),
to_sfixed(0.9115058523116731, 10, -8),
to_sfixed(0.9214762118704076, 10, -8),
to_sfixed(0.9308737486442042, 10, -8),
to_sfixed(0.9396926207859083, 10, -8),
to_sfixed(0.9479273461671317, 10, -8),
to_sfixed(0.9555728057861407, 10, -8),
to_sfixed(0.962624246950012, 10, -8),
to_sfixed(0.969077286229078, 10, -8),
to_sfixed(0.9749279121818236, 10, -8),
to_sfixed(0.9801724878485438, 10, -8),
to_sfixed(0.984807753012208, 10, -8),
to_sfixed(0.9888308262251285, 10, -8),
to_sfixed(0.9922392066001721, 10, -8),
to_sfixed(0.9950307753654014, 10, -8),
to_sfixed(0.9972037971811801, 10, -8),
to_sfixed(0.9987569212189223, 10, -8),
to_sfixed(0.9996891820008162, 10, -8),
to_sfixed(1.0, 10, -8)
    );

begin
    process(angle_index)
    begin
        case angle_index is
            when 0 to 63  => sin_value <= SIN_LUT(angle_index);
            when 64 to 127 => sin_value <= SIN_LUT(127 - angle_index);
            when 128 to 191 => sin_value <= resize(-SIN_LUT(angle_index - 128), 10, -8);
            when 192 to 255 => sin_value <= resize(-SIN_LUT(255 - angle_index), 10, -8);
        end case;

        case angle_index is
            when 0 to 63  => cos_value <= SIN_LUT(63 - angle_index);
            when 64 to 127 => cos_value <= resize(-SIN_LUT(angle_index - 64), 10, -8);
            when 128 to 191 => cos_value <= resize(-SIN_LUT(191 - angle_index), 10, -8);
            when 192 to 255 => cos_value <= SIN_LUT(angle_index - 192);
        end case;
    end process;
end rtl;
