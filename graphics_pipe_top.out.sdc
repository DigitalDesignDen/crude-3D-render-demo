## Generated SDC file "graphics_pipe_top.out.sdc"

## Copyright (C) 1991-2013 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 13.0.1 Build 232 06/12/2013 Service Pack 1 SJ Web Edition"

## DATE    "Tue Apr 01 23:54:33 2025"

##
## DEVICE  "5CGXFC5C6F27C7"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************


create_clock -name CLK_50 -period 20.000 [get_ports {CLOCK_50_B5B}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name CLK_25 -divide_by 2 -source [get_ports {CLOCK_50_B5B}] [get_registers {clkdiv:U2|counter[0]}]

#[get_pins {clkdiv:U2|clk_out}]



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {CLK_25}] -rise_to [get_clocks {CLK_25}]  0.280  
set_clock_uncertainty -rise_from [get_clocks {CLK_25}] -fall_to [get_clocks {CLK_25}]  0.280  
set_clock_uncertainty -rise_from [get_clocks {CLK_25}] -rise_to [get_clocks {CLK_50}]  0.280  
set_clock_uncertainty -rise_from [get_clocks {CLK_25}] -fall_to [get_clocks {CLK_50}]  0.280  
set_clock_uncertainty -fall_from [get_clocks {CLK_25}] -rise_to [get_clocks {CLK_25}]  0.280  
set_clock_uncertainty -fall_from [get_clocks {CLK_25}] -fall_to [get_clocks {CLK_25}]  0.280  
set_clock_uncertainty -fall_from [get_clocks {CLK_25}] -rise_to [get_clocks {CLK_50}]  0.280  
set_clock_uncertainty -fall_from [get_clocks {CLK_25}] -fall_to [get_clocks {CLK_50}]  0.280  


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************
# Allow up to 18 clocks from the register that produces x_sum…  
# …to the register that captures x_proj.
set_multicycle_path -setup 4 \
  -from [get_registers  {w_sum[*]}] \
  -to   [get_registers  {x_proj[*]}]
  
set_multicycle_path -setup 4 \
  -from [get_registers  {w_sum[*]}] \
  -to   [get_registers  {y_proj[*]}]
  
set_multicycle_path -hold 3 \
  -from [get_registers  {w_sum[*]}] \
  -to   [get_registers  {x_proj[*]}]
  
set_multicycle_path -hold 3 \
  -from [get_registers  {w_sum[*]}] \
  -to   [get_registers  {y_proj[*]}]
  
  

set_multicycle_path -setup 4 \
  -from [get_registers  {x_sum[*]}] \
  -to   [get_registers  {x_proj[*]}]
  
set_multicycle_path -setup 4 \
  -from [get_registers  {y_sum[*]}] \
  -to   [get_registers  {y_proj[*]}]
  
set_multicycle_path -hold 3 \
  -from [get_registers  {x_sum[*]}] \
  -to   [get_registers  {x_proj[*]}]
  
set_multicycle_path -hold 3 \
  -from [get_registers  {y_sum[*]}] \
  -to   [get_registers  {y_proj[*]}]



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

