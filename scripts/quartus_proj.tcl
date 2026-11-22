# =============================================================
# quartus_proj.tcl - Quartus project create / sync (Quartus Lite, any PC)
#
# Usage:
#   Command line : quartus_sh -t scripts/quartus_proj.tcl projects/<name>
#   Quartus GUI  : Tools > Tcl Scripts... (or Tcl Console)
#                  source C:/path/repo/scripts/quartus_proj.tcl
#                  -> syncs the project that is open now
#
# - The project lives in projects/<name>/quartus/<name>.qpf/.qsf (committed to Git).
#   Pin Planner / Assignment Editor changes are saved in the .qsf, so they sync too.
# - Paths in the .qsf are relative (../src/...), so the same .qsf works on every PC.
# - Values come from projects/<name>/project.tcl:
#     quartus_family, quartus_device, top_module
# - src/*.v *.sv *.vhd        -> design files (sim/ is for Questa only)
# - sdc/*.sdc                 -> timing constraints
# - Files added in src/ sdc/ are added to the .qsf; deleted ones are removed.
# =============================================================
package require ::quartus::project

set ::QP_EXT_MAP {
    .v    VERILOG_FILE
    .vh   VERILOG_INCLUDE_FILE
    .sv   SYSTEMVERILOG_FILE
    .svh  VERILOG_INCLUDE_FILE
    .vhd  VHDL_FILE
    .vhdl VHDL_FILE
}

proc qp_rel_files {work sub exts} {
    set out {}
    foreach e $exts {
        foreach f [glob -nocomplain -directory [file join $work $sub] -types f *$e] {
            lappend out "../$sub/[file tail $f]"
        }
    }
    return [lsort -unique $out]
}

# Make the .qsf file list match src/ and sdc/ (project must be open)
proc qp_sync_files {work} {
    set want {}
    foreach {ext kind} $::QP_EXT_MAP {
        foreach f [qp_rel_files $work src [list $ext]] { lappend want [list $kind $f] }
    }
    foreach f [qp_rel_files $work sdc {.sdc}] { lappend want [list SDC_FILE $f] }

    set kinds [lsort -unique [concat [dict values $::QP_EXT_MAP] SDC_FILE]]
    set have {}
    foreach kind $kinds {
        foreach_in_collection a [get_all_global_assignments -name $kind] {
            lappend have [list $kind [lindex $a 2]]
        }
    }

    set added 0; set removed 0
    foreach item $want {
        if {[lsearch -exact $have $item] < 0} {
            set_global_assignment -name [lindex $item 0] [lindex $item 1]
            incr added
        }
    }
    foreach item $have {
        lassign $item kind f
        # only manage files that point into src/ or sdc/ of this work folder
        if {![regexp {^\.\./(src|sdc)/} $f]} { continue }
        if {[lsearch -exact $want $item] < 0} {
            set_global_assignment -name $kind $f -remove
            incr removed
        }
    }
    return [list $added $removed]
}

proc qp_read_settings {work} {
    set s [dict create family "MAX 10" device "" top ""]
    set pt [file join $work project.tcl]
    if {[file exists $pt]} {
        # project.tcl is plain "set name value" lines; evaluate in a scratch namespace
        namespace eval ::qp_cfg {}
        namespace eval ::qp_cfg [list source $pt]
        if {[info exists ::qp_cfg::quartus_family]} { dict set s family $::qp_cfg::quartus_family }
        if {[info exists ::qp_cfg::quartus_device]} { dict set s device $::qp_cfg::quartus_device }
        if {[info exists ::qp_cfg::top_module]}     { dict set s top    $::qp_cfg::top_module }
        namespace delete ::qp_cfg
    }
    return $s
}

# Create (if missing) and sync projects/<name>/quartus/<name>.qpf
# Returns 1 if a Quartus project is (now) there, 0 if the folder is not a Quartus work.
proc qp_create_or_sync {work} {
    set work [file normalize $work]
    set name [file tail $work]
    set s [qp_read_settings $work]
    if {[dict get $s device] eq ""} {
        puts "skip $name : no quartus_device in project.tcl"
        return 0
    }
    foreach d {src sim sdc quartus} { file mkdir [file join $work $d] }
    set old [pwd]
    cd [file join $work quartus]
    set is_new [expr {![project_exists $name]}]
    if {$is_new} {
        project_new -revision $name $name
        set_global_assignment -name FAMILY [dict get $s family]
        set_global_assignment -name DEVICE [dict get $s device]
        set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
    } else {
        project_open -revision $name $name
    }
    if {[dict get $s top] ne ""} {
        set_global_assignment -name TOP_LEVEL_ENTITY [dict get $s top]
    }
    lassign [qp_sync_files $work] added removed
    export_assignments
    project_close
    cd $old
    if {$is_new} {
        puts "Quartus project created: projects/$name/quartus/$name.qpf ([dict get $s device], files: $added)"
    } else {
        puts "Quartus project synced ($name): added $added, removed $removed"
    }
    return 1
}

# In the Quartus GUI: sync the project that is open now, then reopen it
proc qp_sync_open_project {} {
    if {![is_project_open]} { return 0 }
    set qdir [file normalize [get_project_directory]]
    if {[file tail $qdir] ne "quartus"} {
        puts "WARNING: open project is not projects/<name>/quartus/ - not synced with GitHub: $qdir"
        return 0
    }
    set work [file dirname $qdir]
    lassign [qp_sync_files $work] added removed
    export_assignments
    puts "Open Quartus project synced ([file tail $work]): added $added, removed $removed"
    return 1
}

# ---- entry point ----
if {[info exists ::argv] && [llength $::argv] > 0} {
    foreach d $::argv { qp_create_or_sync $d }
} elseif {![info exists ::QP_LIBRARY_ONLY]} {
    if {![qp_sync_open_project]} {
        puts "Usage: quartus_sh -t scripts/quartus_proj.tcl projects/<name>   (or open a project first)"
    }
}
