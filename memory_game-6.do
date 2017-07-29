# Set the working dir, where all compiled Verilog goes.

vlib work

# Compile all Verilog modules in mux.v to working dir;
# could also have multiple Verilog files.
# The timescale argument defines default time unit
# (used when no unit is specified), while the second number
# defines precision (all times are rounded to this value)


vlog -timescale 1ns/1ns memory_game_6.v

# Load simulation using mux as the top level simulation module.
vsim memory_game_6

# Log all signals and add some signals to waveform window.
log {/*}

# add wave {/*}would add all items in top level simulation module.
add wave -r {/*}

# reset, set initial values

force {SW[6]} 0
force {SW[7]} 0
force {SW[8]} 0
force {SW[9]} 0


force {KEY[0]} 0
force {KEY[1]} 0
force {KEY[2]} 0
force {KEY[3]} 0


force {SW[1]} 0

force {SW[0]} 0
run 10ns

force {SW[0]} 1
run 10ns

force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 20ns

force {SW[0]} 0
run 10ns



force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 800ns

force {SW[1]} 1


force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 2200ns

# level 1
force {KEY[0]} 1
force {KEY[1]} 0
force {KEY[2]} 0
force {KEY[3]} 0
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 200ns
force {KEY[0]} 0
force {KEY[1]} 0
force {KEY[2]} 0
force {KEY[3]} 0
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 200ns
force {KEY[0]} 0
force {KEY[1]} 1
force {KEY[2]} 0
force {KEY[3]} 0
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 200ns
force {KEY[0]} 0
force {KEY[1]} 0
force {KEY[2]} 0
force {KEY[3]} 0
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 200ns
force {KEY[0]} 0
force {KEY[1]} 0
force {KEY[2]} 1
force {KEY[3]} 0
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 200ns
force {KEY[0]} 0
force {KEY[1]} 0
force {KEY[2]} 0
force {KEY[3]} 0
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 200ns
force {KEY[0]} 0
force {KEY[1]} 0
force {KEY[2]} 0
force {KEY[3]} 1
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 200ns
force {KEY[0]} 0
force {KEY[1]} 0
force {KEY[2]} 0
force {KEY[3]} 0
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 2200ns

# level 2
force {KEY[0]} 1
force {KEY[1]} 0
force {KEY[2]} 0
force {KEY[3]} 0
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 200ns
force {KEY[0]} 0
force {KEY[1]} 0
force {KEY[2]} 0
force {KEY[3]} 0
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 200ns
force {KEY[0]} 0
force {KEY[1]} 1
force {KEY[2]} 0
force {KEY[3]} 0
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 200ns
force {KEY[0]} 0
force {KEY[1]} 0
force {KEY[2]} 0
force {KEY[3]} 0
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 200ns
force {KEY[0]} 0
force {KEY[1]} 1
force {KEY[2]} 0
force {KEY[3]} 0
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 200ns
force {KEY[0]} 0
force {KEY[1]} 0
force {KEY[2]} 0
force {KEY[3]} 0
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 200ns
force {KEY[0]} 1
force {KEY[1]} 0
force {KEY[2]} 0
force {KEY[3]} 0
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 200ns
force {KEY[0]} 0
force {KEY[1]} 0
force {KEY[2]} 0
force {KEY[3]} 0
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 200ns
force {KEY[0]} 1
force {KEY[1]} 0
force {KEY[2]} 0
force {KEY[3]} 0
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 200ns
force {KEY[0]} 0
force {KEY[1]} 0
force {KEY[2]} 0
force {KEY[3]} 0
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 2200ns

# level 3
force {KEY[0]} 0
force {KEY[1]} 0
force {KEY[2]} 1
force {KEY[3]} 0
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 200ns
force {KEY[0]} 0
force {KEY[1]} 0
force {KEY[2]} 0
force {KEY[3]} 0
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 200ns
force {KEY[0]} 0
force {KEY[1]} 1
force {KEY[2]} 0
force {KEY[3]} 0
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 200ns
force {KEY[0]} 0
force {KEY[1]} 0
force {KEY[2]} 0
force {KEY[3]} 0
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 200ns
force {KEY[0]} 1
force {KEY[1]} 0
force {KEY[2]} 0
force {KEY[3]} 0
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 200ns
force {KEY[0]} 0
force {KEY[1]} 0
force {KEY[2]} 0
force {KEY[3]} 0
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 200ns
force {KEY[0]} 0
force {KEY[1]} 0
force {KEY[2]} 1
force {KEY[3]} 0
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 200ns
force {KEY[0]} 0
force {KEY[1]} 0
force {KEY[2]} 0
force {KEY[3]} 0
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 200ns
force {KEY[0]} 0
force {KEY[1]} 1
force {KEY[2]} 0
force {KEY[3]} 0
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 200ns
force {KEY[0]} 0
force {KEY[1]} 0
force {KEY[2]} 0
force {KEY[3]} 0
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 200ns
force {KEY[0]} 1
force {KEY[1]} 0
force {KEY[2]} 0
force {KEY[3]} 0
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 200ns
force {KEY[0]} 0
force {KEY[1]} 0
force {KEY[2]} 0
force {KEY[3]} 0
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 2200ns


# level 4 (random)
force {KEY[0]} 0
force {KEY[1]} 1
force {KEY[2]} 0
force {KEY[3]} 0
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 200ns
force {KEY[0]} 0
force {KEY[1]} 0
force {KEY[2]} 0
force {KEY[3]} 0
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 200ns
force {KEY[0]} 0
force {KEY[1]} 0
force {KEY[2]} 0
force {KEY[3]} 1
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 200ns
force {KEY[0]} 0
force {KEY[1]} 0
force {KEY[2]} 0
force {KEY[3]} 0
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 200ns
force {KEY[0]} 1
force {KEY[1]} 0
force {KEY[2]} 0
force {KEY[3]} 0
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 200ns
force {KEY[0]} 0
force {KEY[1]} 0
force {KEY[2]} 0
force {KEY[3]} 0
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 200ns
force {KEY[0]} 0
force {KEY[1]} 1
force {KEY[2]} 0
force {KEY[3]} 0
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 200ns
force {KEY[0]} 0
force {KEY[1]} 0
force {KEY[2]} 0
force {KEY[3]} 0
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 200ns
force {KEY[0]} 1
force {KEY[1]} 0
force {KEY[2]} 0
force {KEY[3]} 0
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 200ns
force {KEY[0]} 0
force {KEY[1]} 0
force {KEY[2]} 0
force {KEY[3]} 0
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 200ns
force {KEY[0]} 1
force {KEY[1]} 0
force {KEY[2]} 0
force {KEY[3]} 0
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 200ns
force {KEY[0]} 0
force {KEY[1]} 0
force {KEY[2]} 0
force {KEY[3]} 0
force {CLOCK_50} 0 0, 1 10ns -repeat 20ns
run 2200ns
