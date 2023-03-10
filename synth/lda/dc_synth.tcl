ock/**************************************************/
#/* Compile Script for Synopsys                    */
#/*                                                */
#/* dc_shell-xg-t -f compile_dc.tcl                */
#/*                                                */
#/* Christopher Edmonds, OSU                       */
#/* edmondsc@onid.orst.edu                         */
#/**************************************************/

set hdlin_auto_save_templates true
set hdlin_check_no_latch      true
set hdlin_warn_sens_list      true

#/**************************************************/
#/* User Set Variables                             */
#/**************************************************/

#/* Top-level Module Name                          */
set design_toplevel lda
#set design_toplevel {REPLACE}

#/* List of Verilog files
#CHANGE HERE IF YOU ARE USING SYSTEM VERILOG    */
#set design_verilog_files [getenv VERILOG_FILES]
#set package_files ../../src/package/*.sv
set design_verilog_files ../../src/lda/*.sv

#/* The name of the clock pin. If no clock-pin     */
#/* exists, pick anything                          */
#set design_clock_pin [getenv DESIGN_CLOCK]
set design_clock_pin clk_i

#/* The name of the reset pin. If no clock-pin     */
#/* exists, pick anything                          */
#set design_reset_pin [getenv DESIGN_RESET]
set design_reset_pin rstn_i

#/* Max target frequency in MHz for optimization       */
set design_clk_freq_MHz 600
set design_period [expr 1000.0 / $design_clk_freq_MHz ]

# Input delay and output delay are specified to describe delay outside of your design
#/* Delay of input signals                         */
# Specifies the input delay relative to the clock edge.
# This usually represents previous blocks’ clock to Q delay + combinational logic delay + Route delay with respect to clk edge
# set design_input_delay_ns 1
set design_input_delay_ns [expr $design_period * 0.1]

#/* Reserved time for output signals               */
# Specifies the required time of the output relative to the clock edge.
# can be calculated as below.
# set_output_delay -max = max(Tdelay,out2ext) + Tsetup,ext
# set_output_delay -min = min(Tdelay,out2ext) + Thold,ext
# set design_output_delay_ns 1
set design_output_delay_ns [expr $design_period * 0.1]

#/* Maximum delay on the specified path in the current design..
# Allows you to specify the max path length for any start point to any endpoint.
set design_max_delay_ns 0.5

#/**************************************************/
#/* Shouldn't Need To Change the Rest              */
#/**************************************************/
# set SynopsysInstall [getenv "DCROOT"]
# set search_path [list . \
# [format "%s%s" $SynopsysInstall /libraries/syn] \
# [format "%s%s" $SynopsysInstall /dw/sim_ver] \
# ]
#set synlib_wait_for_design_license [list "DesignWare-Foundation"]
# set symbol_library [list generic.sdb]
# set synthetic_library [list dw_foundation.sldb]
#set synthetic_library dw_foundation.sldb

define_design_lib WORK -path ./work

define_name_rules nameRules -restricted "!@#$%^&*()\\-" -case_insensitive

# set cell_path [getenv SYNOPSYS_DB_DIR]
# set search_path [concat $search_path $cell_path]
# set search_path [concat [concat [pwd]/rtl_src] $search_path ]
# set alib_library_analysis_path $cell_path
# set alib_library_analysis_path ./

set verilogout_show_unconnected_pins "true"
#set_ultra_optimization true
#set_ultra_optimization -force    

#set target_library [format "%s" [getenv SYNOPSYS_DB]]

#set link_library    "* $target_library"
#set link_library [concat [concat "*" $target_library] $synthetic_library]

#CHANGE HERE verilog-> sverilog and ./rtl_src/cluster_top to ./rtl_src/file_containing_your_top
#analyze -format sverilog [glob $package_files]
analyze -format sverilog [glob $design_verilog_files]


#elaborate $design_toplevel -parameter [getenv PARAMETERS]
elaborate $design_toplevel
#puts [getenv TOP_LEVEL]

current_design $design_toplevel
link

uniquify 

check_design

#Set the wire load model
set_wire_load_model -name tsmc65_wl10

#Set up the clock period
set clk_name $design_clock_pin
create_clock -period $design_period -name my_clk $clk_name

#Set clock jitter to 100ps
# Specifies the uncertainty (skew) of specified clock networks.
# Indicates that uncertainty applies only to setup and hold checks, respectively
set_clock_uncertainty -setup 0.1 my_clk
set_clock_uncertainty -hold  0.1 my_clk

#Set the input and output delay
set_input_delay  $design_input_delay_ns  -clock my_clk [all_inputs]
set_output_delay $design_output_delay_ns -clock my_clk [all_outputs]

# Removes timing constraints from particular paths. 
# for asyn reset, static digital control bits, etc.
# set_false_path -from [get_ports "rstb"]
# set_false_path -from [get_ports "div_ctrl"]


#set_max_delay -from [get_ports a[*]] -to [get_ports out[*]] $design_max_delay_ns 
#set_max_delay -from [get_ports b[*]] -to [get_ports out[*]] $design_max_delay_ns 
#set_max_delay -from [get_ports cin] -to [get_ports out[*]] $design_max_delay_ns 

#Setup the capacitive load on the output pins (pF)
set_load 0.04 [all_outputs]
set_max_fanout 1 [all_inputs]
#set_driving_cell -lib_cell INVX1BA10TR -pin Y [get_ports clk]
set_driving_cell -lib_cell INVX1BA10TR -pin Y [all_inputs]

check_design
report_constraints -all_violators

# Compile with hierarchical design
#compile -map_effort medium
#compile
compile_ultra -retime -gate_clock
set_host_options -max_cores 16
#compile_ultra -timing_high_effort_scriptca	 -retime -num_cpus 16

# Make sure we are at the top level
set current_design  $design_toplevel
change_names -rules verilog -hierarchy -verbose
change_names -rules nameRules -hierarchy -verbose

# Generate area and constraints reports on the optimized design
setenv REPORT_DIR reports
file mkdir [getenv REPORT_DIR]
report_area    > [format "%s%s%s" [getenv REPORT_DIR] "/" $design_toplevel ".gate.area.rpt"]


# Generate area and constraints reports on the optimized design
report_area > [format "%s%s%s" [getenv REPORT_DIR] "/" $design_toplevel ".gate.area.rpt"]

# Generate timing report for worst case path
report_timing -delay max   >  [format "%s%s%s%s" [getenv REPORT_DIR] "/" $design_toplevel ".gate.delay.rpt"]
report_timing -delay min   >  [format "%s%s%s%s" [getenv REPORT_DIR] "/" $design_toplevel ".gate.hold.rpt"]
report_timing              >  [format "%s%s%s%s" [getenv REPORT_DIR] "/" $design_toplevel ".gate.timing.rpt"]
report_timing -max_path 50 >> [format "%s%s%s%s" [getenv REPORT_DIR] "/" $design_toplevel ".gate.timing.rpt"]
report_timing_requirement  >> [format "%s%s%s%s" [getenv REPORT_DIR] "/" $design_toplevel ".gate.timing.rpt"]
report_constraint          >> [format "%s%s%s%s" [getenv REPORT_DIR] "/" $design_toplevel ".gate.timing.rpt"]
report_attribute           >> [format "%s%s%s%s" [getenv REPORT_DIR] "/" $design_toplevel ".gate.timing.rpt"]
report_constraint -all_violators >> [format "%s%s%s%s" [getenv REPORT_DIR] "/" $design_toplevel ".gate.timing.rpt"]
check_design               >> [format "%s%s%s%s" [getenv REPORT_DIR] "/" $design_toplevel ".gate.timing.rpt"]
report_clock 		   >  [format "%s%s%s%s" [getenv REPORT_DIR] "/" $design_toplevel ".gate.clock.rpt"]

# Generate other reports
report_hierarchy >  [format "%s%s%s%s" [getenv REPORT_DIR] "/" $design_toplevel ".gate.hierarchy.rpt"]
report_resources >  [format "%s%s%s%s" [getenv REPORT_DIR] "/" $design_toplevel ".gate.resources.rpt"]
report_reference >> [format "%s%s%s%s" [getenv REPORT_DIR] "/" $design_toplevel ".gate.resources.rpt"]
report_cell      >  [format "%s%s%s%s" [getenv REPORT_DIR] "/" $design_toplevel ".gate.cell.rpt"]
report_area      >  [format "%s%s%s" "reports/" $design_toplevel ".gate.area.rpt"]

# Generate power report
report_power -verbose > [format "%s%s%s%s" [getenv REPORT_DIR] "/" $design_toplevel ".gate.power.rpt"]

# Save the compiled design
setenv VLOGOUT_DIR vlogout
file mkdir [getenv VLOGOUT_DIR]
write -format verilog -hierarchy -output  [format "%s%s%s%s" [getenv VLOGOUT_DIR] "/" $design_toplevel ".gate.v"]

# Write out the delay information to the sdf file
# SDF: stand format for back annotation timing info
setenv SDF_OUT_DIR sdfout
file mkdir [getenv SDF_OUT_DIR]
write_sdf [format "%s%s%s%s" [getenv SDF_OUT_DIR] "/" $design_toplevel ".gate.sdf"] 
# SDC: Synopsys Design Constraint file including timing constraints for PnR
setenv SDC_OUT_DIR sdc_out
file mkdir [getenv SDF_OUT_DIR]
write_sdc [format "%s%s%s%s" [getenv SDC_OUT_DIR] "/" $design_toplevel ".gate.sdc"] 

exit
