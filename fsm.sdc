# SDC File for I2C FSM Design

# Define the clock with a period of 10 ns (100 MHz)
create_clock -name clk -period 10 [get_ports clk]

# Define input and output delays based on clock period
set_input_delay -clock clk 2.0 [get_ports rst_n]
set_input_delay -clock clk 2.0 [get_ports start_tx]
set_input_delay -clock clk 2.0 [get_ports data_in*]
set_input_delay -clock clk 2.0 [get_ports ack_in]

set_output_delay -clock clk 2.0 [get_ports scl]
set_output_delay -clock clk 2.0 [get_ports sda]
set_output_delay -clock clk 2.0 [get_ports done]
set_output_delay -clock clk 2.0 [get_ports busy]

# Set clock uncertainty (to account for jitter and variations)
set_clock_uncertainty 0.5 [get_clocks clk]

# Specify timing exceptions (if required)
# False path between asynchronous reset and clock domain
set_false_path -from [get_ports rst_n] -to [get_clocks clk]

# Max and min delay constraints (to ensure proper timing margins)
set_max_delay 8 -from [get_ports start_tx] -to [get_ports done]
set_min_delay 1 -from [get_ports start_tx] -to [get_ports done]

# Define load capacitance for output ports (optional)
set_load 5 [get_ports scl]
set_load 5 [get_ports sda]
set_load 5 [get_ports done]
set_load 5 [get_ports busy]

# Multicycle path constraints (if required for longer operations)
# Example: Assume data processing takes multiple cycles
set_multicycle_path 2 -setup -from [get_ports start_tx] -to [get_ports done]
set_multicycle_path 1 -hold -from [get_ports start_tx] -to [get_ports done]
