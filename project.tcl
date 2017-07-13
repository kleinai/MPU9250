# #
#  
# #

proc add_sources {folder fileset} {
   # Gather up sources
   set verilog_files [glob -nocomplain -type f $folder/*.v]
   set systemverilog_files [glob -nocomplain -type f $folder/*.sv]
   set vhdl_files [concat \
      [glob -nocomplain -type f $folder/*.vhd] \
      [glob -nocomplain -type f $folder/*.vhdl] \
   ]

   if {$verilog_files ne ""} {
      add_files -norecurse -fileset $fileset $verilog_files
      set file_objs [get_files -of [get_filesets $fileset] [list "*.v"]]
      set_property -name "file_type" -value "verilog" -objects $file_objs
   }

   if {$systemverilog_files ne ""} {   
      add_files -norecurse -fileset $fileset $systemverilog_files
      set file_objs [get_files -of [get_filesets $fileset] [list "*.sv"]]
      set_property -name "file_type" -value "systemverilog" -objects $file_objs
   }

   if {$vhdl_files ne ""} {   
      add_files -norecurse -fileset $fileset $vhdl_files
      set file_objs [get_files -of [get_filesets $fileset] [list "*.vhdl" "*.vhd"]]
      set_property -name "file_type" -value "vhdl" -objects $file_objs
   }
}

# ##############################################################################
# Abstracted TCL file
# ##############################################################################

set rootFolder [pwd]
set projectName [file tail [pwd]]
set sourceFolder "[pwd]/src"
set sourceTempFolder "[pwd]/src.temp"

set compileProject 0
if {[llength $argv] > 0} {
   set compileProject [lindex $argv 0]
}
# ##############################################################################
# setup project
# ##############################################################################
create_project $projectName -part xc7z020clg400-3 -force ./vivado
set_property target_language VHDL [current_project]
set_property STEPS.WRITE_BITSTREAM.ARGS.BIN_FILE true [get_runs impl_1]

# Sets IP repos

# Use "ip_repo" one folder up or two folders up if we're in "ip_repo" already
set global_repo_folder "[file normalize $rootFolder/../ip_repo]"
if {[file tail $rootFolder/..] ne "ip_repo"} {
   set global_repo_folder "[file normalize $rootFolder/../../ip_repo]"
}
set folders [list \
   "$global_repo_folder"\
   "./ip_repo"\
]
set_property ip_repo_paths $folders [current_fileset]
update_ip_catalog -rebuild

if [file exists $sourceFolder/hdl] {
   add_sources $sourceFolder/hdl sources_1
}

if [file exists $sourceFolder/bd] {
   # Generates the block diagram and creates wrapper
   source $sourceFolder/bd/$projectName\.tcl
   make_wrapper -files [get_files $projectName\.bd] -top -import
}  

# Imports the constraints folder
if [file exists $sourceFolder/xdc] {
   add_files -fileset constrs_1 -norecurse [glob -nocomplain -type f $sourceFolder/xdc/*.xdc]
}

# Add component if it's an IP
if [file exists $rootFolder/component.xml] {
   set file $rootFolder/component.xml
   add_files -fileset sources_1 $file
   set file_obj [get_files -of [get_filesets sources_1] [list "*$file"]]
   set_property -name "file_type" -value "IP-XACT" -objects $file_obj
}

if [file exists $rootFolder/sim] {
   add_sources $rootFolder/sim sim_1
   set files [glob -nocomplain -type f $rootFolder/sim/*.wcfg]
   if {$files ne ""} {
      add_files -fileset sim_1 -norecurse $files
   }
}

# Deleting vivado folders / Files
file delete -force -- .Xil