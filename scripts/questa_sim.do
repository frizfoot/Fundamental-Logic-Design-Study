# =============================================================
# questa_sim.do - compile src/ + sim/ and run the testbench (Questa, any PC)
#
# Usage (Questa Transcript):
#   do C:/path/repo/scripts/questa_sim.do C:/path/repo/projects/<name>
#   (or: cd to projects/<name> first, then  do ../../scripts/questa_sim.do)
# Batch / terminal:
#   vsim -c -do "do ../../scripts/questa_sim.do; quit -f"     (from projects/<name>)
#
# - Testbench top = sim_top in project.tcl (if empty: the only module in sim/)
# - Files ending in _pkg.sv are compiled first (packages before their users)
# - Work library goes to projects/<name>/questa_work/ (git-ignored)
# - Waves: if sim/wave.do exists it is used. Save your wave window with
#   File > Save Format... into sim/wave.do so both PCs get the same waves.
# =============================================================
if {$argc > 0} {
    set qs_work [file normalize $1]
} else {
    set qs_work [file normalize [pwd]]
}
if {![file exists [file join $qs_work project.tcl]]} {
    error "project.tcl not found in $qs_work - pass projects/<name> as argument"
}

# read sim_top from project.tcl
namespace eval ::qs_cfg {}
namespace eval ::qs_cfg [list source [file join $qs_work project.tcl]]
set qs_top ""
if {[info exists ::qs_cfg::sim_top]} { set qs_top $::qs_cfg::sim_top }
namespace delete ::qs_cfg

proc qs_hdl {dir} {
    set out {}
    foreach e {sv v} { set out [concat $out [glob -nocomplain -directory $dir -types f *.$e]] }
    set out [lsort $out]
    # packages first
    set pkgs [lsearch -all -inline -regexp $out {_pkg\.sv$}]
    set rest [lsearch -all -inline -not -regexp $out {_pkg\.sv$}]
    return [concat $pkgs $rest]
}

set qs_src [qs_hdl [file join $qs_work src]]
set qs_sim [qs_hdl [file join $qs_work sim]]
if {[llength $qs_sim] == 0} { error "no testbench in $qs_work/sim" }

if {$qs_top eq ""} {
    # guess: the module declared in sim/ when there is exactly one
    set mods {}
    foreach f $qs_sim {
        set fh [open $f r]; set txt [read $fh]; close $fh
        foreach {_ m} [regexp -all -inline -line {^\s*module\s+(\w+)} $txt] { lappend mods $m }
    }
    if {[llength $mods] != 1} { error "set sim_top in project.tcl (sim/ has modules: $mods)" }
    set qs_top [lindex $mods 0]
}

quietly catch {quit -sim}
set qs_lib [file join $qs_work questa_work]
file mkdir $qs_lib
cd $qs_lib
if {![file exists work]} { vlib work }
vmap work work

set qs_inc [list +incdir+[file join $qs_work src] +incdir+[file join $qs_work sim]]
vlog -sv -work work {*}$qs_inc {*}$qs_src {*}$qs_sim

vsim -onfinish stop -voptargs=+acc work.$qs_top
if {![batch_mode]} {
    set qs_wave [file join $qs_work sim wave.do]
    if {[file exists $qs_wave]} { do $qs_wave } else { add wave -r /* }
}
run -all
echo "questa_sim: [file tail $qs_work] / $qs_top done  (rerun: do <repo>/scripts/questa_sim.do $qs_work)"
