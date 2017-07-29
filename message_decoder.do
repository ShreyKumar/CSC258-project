# Set the working dir, where all compiled Verilog goes.

vlib work

# Compile all Verilog modules in mux.v to working dir;
# could also have multiple Verilog files.
# The timescale argument defines default time unit
# (used when no unit is specified), while the second number
# defines precision (all times are rounded to this value)


vlog -timescale 1ns/1ns message_decoder.v

# Load simulation using mux as the top level simulation module.
vsim message_decoder

# Log all signals and add some signals to waveform window.
log {/*}

# add wave {/*}would add all items in top level simulation module.
add wave -r {/*}

# reset, set initial values

force {state_number[0]} 0
force {state_number[1]} 1
force {state_number[2]} 0
force {state_number[3]} 0

force {level_number[0]} 1
force {level_number[1]} 1
force {level_number[2]} 0
force {level_number[3]} 0
run 10ns
