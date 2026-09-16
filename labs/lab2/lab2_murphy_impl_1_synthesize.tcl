if {[catch {

# define run engine funtion
source [file join {C:/lscc/radiant/2026.1} scripts tcl flow run_engine.tcl]
# define global variables
global para
set para(gui_mode) "1"
set para(prj_dir) "C:/Users/hmurphy/Downloads/E155/lab2_murphy"
if {![file exists {C:/Users/hmurphy/Downloads/E155/lab2_murphy/impl_1}]} {
  file mkdir {C:/Users/hmurphy/Downloads/E155/lab2_murphy/impl_1}
}
cd {C:/Users/hmurphy/Downloads/E155/lab2_murphy/impl_1}
# synthesize IPs
# synthesize VMs
# propgate constraints
file delete -force -- lab2_murphy_impl_1_cpe.ldc
::radiant::runengine::run_engine_newmsg cpe -syn lse -f "lab2_murphy_impl_1.cprj" -a "iCE40UP"  -o lab2_murphy_impl_1_cpe.ldc
# synthesize top design
file delete -force -- lab2_murphy_impl_1.vm lab2_murphy_impl_1.ldc
::radiant::runengine::run_engine_newmsg synthesis -f "C:/Users/hmurphy/Downloads/E155/lab2_murphy/impl_1/lab2_murphy_impl_1_lattice.synproj" -logfile "lab2_murphy_impl_1_lattice.srp"
::radiant::runengine::run_postsyn [list -a iCE40UP -p iCE40UP5K -t SG48 -sp High-Performance_1.2V -oc Industrial -top -w -o lab2_murphy_impl_1_syn.udb lab2_murphy_impl_1.vm] [list lab2_murphy_impl_1.ldc]

} out]} {
   ::radiant::runengine::runtime_log $out
   exit 1
}
