# Set the working dir, where all compiled Verilog goes.

vlib work

# Compile all Verilog modules in mux.v to working dir;
# could also have multiple Verilog files.
# The timescale argument defines default time unit
# (used when no unit is specified), while the second number
# defines precision (all times are rounded to this value)


vlog -timescale 1ns/1ns playback.v

# Load simulation using mux as the top level simulation module.
vsim playback

# Log all signals and add some signals to waveform window.
log {/*}

# add wave {/*}would add all items in top level simulation module.
add wave -r {/*}

# reset, set initial values

force {reset} 0
run 10ns

force {reset} 1
run 10ns

#clk cycle
force {clk} 0
run 10ns
force {clk} 1
run 10ns

force {reset} 0
run 10ns

force {load_level} 1
force {level_length} 2#0100
force {level_data} 2#0001000100010010
run 10ns

#clk cycle
force {clk} 0
run 10ns
force {clk} 1
run 10ns

force {start_playback} 1
run 10ns

#clk cycle
force {clk} 0
run 10ns
force {clk} 1
run 10ns

#clk cycle
force {clk} 0
run 10ns
force {clk} 1
run 10ns

#clk cycle
force {clk} 0
run 10ns
force {clk} 1
run 10ns

#clk cycle
force {clk} 0
run 10ns
force {clk} 1
run 10ns

#clk cycle
force {clk} 0
run 10ns
force {clk} 1
run 10ns

#clk cycle
force {clk} 0
run 10ns
force {clk} 1
run 10ns

#clk cycle
force {clk} 0
run 10ns
force {clk} 1
run 10ns

#clk cycle
force {clk} 0
run 10ns
force {clk} 1
run 10ns

#clk cycle
force {clk} 0
run 10ns
force {clk} 1
run 10ns

#clk cycle
force {clk} 0
run 10ns
force {clk} 1
run 10ns

#clk cycle
force {clk} 0
run 10ns
force {clk} 1
run 10ns

#clk cycle
force {clk} 0
run 10ns
force {clk} 1
run 10ns

#clk cycle
force {clk} 0
run 10ns
force {clk} 1
run 10ns
