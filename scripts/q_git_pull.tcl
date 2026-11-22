# =============================================================
# q_git_pull.tcl - [GitHub Pull] for Quartus and Questa
#
#   Quartus : Tools > Tcl Scripts... > (choose this file) > Run
#             or Tcl Console:  source C:/path/repo/scripts/q_git_pull.tcl
#   Questa  : Transcript:      source C:/path/repo/scripts/q_git_pull.tcl
#
# get the latest commits (local edits not pushed yet are kept)
# Quartus: work folders that have quartus_device in project.tcl but no
#          quartus/<name>.qpf yet get one; the open project's file list is synced.
# Questa : after pulling, rerun   do .../scripts/questa_sim.do <work folder>
# =============================================================
set q_scripts_dir [file normalize [file dirname [info script]]]
source [file join $q_scripts_dir git_common.tcl]

proc q_git_pull_main {} {
    git_banner "GitHub PULL start: $::GIT_ROOT"
    if {[git_has_rebase_in_progress]} {
        puts "ERROR: a previous merge/conflict is unresolved. Run git status in a terminal."
        return
    }
    git_ensure_remote

    set before [git_run rev-parse HEAD]
    lassign [git_try pull --no-rebase --no-edit --autostash origin $::GIT_BRANCH] ok out
    puts $out
    if {!$ok} {
        catch {git_run merge --abort}
        puts "ERROR: pull failed (conflict or network). Local files are unchanged."
        return
    }
    set after [git_run rev-parse HEAD]
    if {$before eq $after} {
        puts "Already up to date."
    } else {
        puts "Changed files:"
        puts [git_run diff --stat $before $after]
    }

    if {[info commands is_project_open] ne ""} {
        set ::QP_LIBRARY_ONLY 1
        source [file join $::q_scripts_dir quartus_proj.tcl]
        if {[is_project_open]} {
            # the GUI keeps its own copy of the settings: reopen so pulled .qsf changes show up
            set qdir [file normalize [get_project_directory]]
            set rev  [get_current_revision]
            set proj [file rootname [file tail [lindex [glob -nocomplain -directory $qdir *.qpf] 0]]]
            project_close
            q_create_missing
            cd $qdir
            project_open -revision $rev $proj
            catch {qp_sync_open_project}
            puts "Reopened Quartus project: $proj"
        } else {
            q_create_missing
        }
    }
    git_banner "GitHub PULL done"
}

proc q_create_missing {} {
    foreach d [glob -nocomplain -directory [file join $::GIT_ROOT projects] -types d *] {
        set name [file tail $d]
        if {[file exists [file join $d quartus "$name.qpf"]]} { continue }
        set pt [file join $d project.tcl]
        if {![file exists $pt]} { continue }
        set fh [open $pt r]; set txt [read $fh]; close $fh
        if {[regexp {quartus_device\s+"[^"]+"} $txt]} { qp_create_or_sync $d }
    }
}

q_git_pull_main
