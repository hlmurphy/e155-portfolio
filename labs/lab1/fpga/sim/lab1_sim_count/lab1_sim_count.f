-L work
-reflib pmi_work
-reflib ovi_ice40up


"C:/Users/hmurphy/Documents/GitHub/E155-lab01/fpga/radiant_project/counter.sv" 
"C:/Users/hmurphy/Documents/GitHub/E155-lab01/fpga/radiant_project/lab1_hm.sv" 
"C:/Users/hmurphy/Documents/GitHub/E155-lab01/fpga/radiant_project/seven_segment_decoder.sv" 
"C:/Users/hmurphy/Documents/GitHub/E155-lab01/fpga/sim/seven_segment_decoder_tb.sv" 
"C:/Users/hmurphy/Documents/GitHub/E155-lab01/fpga/sim/lab1_hm_tb.sv" 
"C:/Users/hmurphy/Documents/GitHub/E155-lab01/fpga/sim/counter_tb.sv" 
-sv
-optionset VOPTDEBUG
+noacc+pmi_work.*
+noacc+ovi_ice40up.*

-vopt.options
  -suppress vopt-7033
-end

-gui
-top counter_tb
-vsim.options
  -suppress vsim-7033,vsim-8630,3009,3389
  -t ns
-end

-do "view wave"
-do "add wave /*"
