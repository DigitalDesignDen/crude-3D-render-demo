-- line_drawer.vhd: DDA-based line drawing with sfixed(10 downto -8)
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.fixed_pkg.ALL;

entity line_drawer is
    Port (
        clk       : in  STD_LOGIC;
        rst       : in  STD_LOGIC;
        start     : in  STD_LOGIC;
        x0, y0    : in  sfixed(10 downto -8);
        x1, y1    : in  sfixed(10 downto -8);
        pixel_x   : out integer range 0 to 4095;
        pixel_y   : out integer range 0 to 4095;
        valid     : out STD_LOGIC;
        done      : out STD_LOGIC
    );
end entity;

architecture rtl of line_drawer is
    type state_t is (IDLE, INIT, DRAW, FINISH);
    signal state    : state_t := IDLE;

    signal dx, dy       : sfixed(11 downto -8);
    signal steps        : integer;
    signal x_inc, y_inc : sfixed(10 downto -8);
    signal curr_x, curr_y : sfixed(10 downto -8);
    signal counter      : integer := 0;
begin
    process(clk, rst)
    begin
        if rst = '1' then
            state   <= IDLE;
            valid   <= '0';
            done    <= '0';
            counter <= 0;
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    valid <= '0'; done <= '0';
                    if start = '1' then
                        state <= INIT;
                    end if;
                when INIT =>
                    -- compute deltas
                    dx <= x1 - x0;
                    dy <= y1 - y0;
                    -- determine steps = max(|dx|, |dy|) in integer domain
                    if abs(to_integer(resize(dx, dx'high, 0))) > abs(to_integer(resize(dy, dy'high, 0))) then
                        steps <= abs(to_integer(resize(dx, dx'high, 0)));
                    else
                        steps <= abs(to_integer(resize(dy, dy'high, 0)));
                    end if;
                    -- compute increments
                    x_inc <= dx / to_sfixed(steps, x_inc'high, x_inc'low);
                    y_inc <= dy / to_sfixed(steps, y_inc'high, y_inc'low);
                    -- initialize current position
                    curr_x <= x0;
                    curr_y <= y0;
                    counter <= 0;
                    state <= DRAW;
                when DRAW =>
                    if counter <= steps then
                        -- output pixel
                        pixel_x <= to_integer(truncate(curr_x));
                        pixel_y <= to_integer(truncate(curr_y));
                        valid   <= '1';
                        -- step to next point
                        curr_x <= curr_x + x_inc;
                        curr_y <= curr_y + y_inc;
                        counter <= counter + 1;
                    else
                        valid <= '0';
                        state <= FINISH;
                    end if;
                when FINISH =>
                    done <= '1';
                    if start = '0' then
                        state <= IDLE;
                    end if;
            end case;
        end if;
    end process;
end architecture;
