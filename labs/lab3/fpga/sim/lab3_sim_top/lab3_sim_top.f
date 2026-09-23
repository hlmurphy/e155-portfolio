-L work
-reflib pmi_work
-reflib ovi_ice40up


"C:/Users/hmurphy/Documents/GitHub/e155-portfolio/labs/lab3/fpga/radiant/modules/cols_sync.sv" 
"C:/Users/hmurphy/Documents/GitHub/e155-portfolio/labs/lab3/fpga/radiant/modules/debouncer.sv" 
"C:/Users/hmurphy/Documents/GitHub/e155-portfolio/labs/lab3/fpga/radiant/modules/display_register.sv" 
"C:/Users/hmurphy/Documents/GitHub/e155-portfolio/labs/lab3/fpga/radiant/modules/display_scan.sv" 
"C:/Users/hmurphy/Documents/GitHub/e155-portfolio/labs/lab3/fpga/radiant/modules/key_encoder.sv" 
"C:/Users/hmurphy/Documents/GitHub/e155-portfolio/labs/lab3/fpga/radiant/modules/lab3_hm.sv" 
"C:/Users/hmurphy/Documents/GitHub/e155-portfolio/labs/lab3/fpga/radiant/modules/reset_sync.sv" 
"C:/Users/hmurphy/Documents/GitHub/e155-portfolio/labs/lab3/fpga/radiant/modules/scan_counter.sv" 
"C:/Users/hmurphy/Documents/GitHub/e155-portfolio/labs/lab3/fpga/radiant/modules/seven_seg_decoder.sv" 
"C:/Users/hmurphy/Documents/GitHub/e155-portfolio/labs/lab3/fpga/radiant/testbenches/encoder_tb.sv" 
"C:/Users/hmurphy/Documents/GitHub/e155-portfolio/labs/lab3/fpga/radiant/testbenches/cols_tb.sv" 
"C:/Users/hmurphy/Documents/GitHub/e155-portfolio/labs/lab3/fpga/radiant/testbenches/debouncer_tb.sv" 
"C:/Users/hmurphy/Documents/GitHub/e155-portfolio/labs/lab3/fpga/radiant/testbenches/rst_tb.sv" 
"C:/Users/hmurphy/Documents/GitHub/e155-portfolio/labs/lab3/fpga/radiant/testbenches/scan_tb.sv" 
"C:/Users/hmurphy/Documents/GitHub/e155-portfolio/labs/lab3/fpga/radiant/testbenches/disp_reg_tb.sv" 
"C:/Users/hmurphy/Documents/GitHub/e155-portfolio/labs/lab3/fpga/radiant/testbenches/top_tb.sv" 
-sv
-optionset VOPTDEBUG
+noacc+pmi_work.*
+noacc+ovi_ice40up.*

-vopt.options
  -suppress vopt-7033
-end

-gui
-top top_tb
-vsim.options
  -suppress vsim-7033,vsim-8630,3009,3389
-end

-do "view wave"
-do "add wave /*"
-do "run -all"
