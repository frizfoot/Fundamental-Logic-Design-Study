# =============================================================
# q_git_push.tcl - [GitHub Push] for Quartus and Questa
#
#   Quartus : Tools > Tcl Scripts... > (choose this file) > Run
#             or Tcl Console:  source C:/path/repo/scripts/q_git_push.tcl
#   Questa  : Transcript:      source C:/path/repo/scripts/q_git_push.tcl
#
# commit all changes -> merge remote changes -> push  (same as the Vivado button)
# In Quartus, the open project's file list is synced (src/ sdc/) before the commit.
# =============================================================
set q_scripts_dir [file normalize [file dirname [info script]]]
source [file join $q_scripts_dir git_common.tcl]

proc q_tool_name {} {
    if {[info commands is_project_open] ne ""} {
        return "Quartus [lindex [split $::quartus(version) " "] 1]"
    }
    if {[info commands vsim] ne "" || [info commands vlog] ne ""} { return "Questa" }
    return "Tcl"
}

proc q_git_push_main {} {
    git_banner "GitHub PUSH start: $::GIT_ROOT"
    if {[git_has_rebase_in_progress]} {
        puts "ERROR: a previous merge/conflict is unresolved. Run git status in a terminal."
        return
    }
    git_ensure_remote

    if {[info commands is_project_open] ne ""} {
        set ::QP_LIBRARY_ONLY 1
        source [file join $::q_scripts_dir quartus_proj.tcl]
        catch {qp_sync_open_project}
    }

    git_run add -A
    lassign [git_try diff --cached --quiet] clean _
    if {!$clean} {
        set ts  [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]
        set msg "[q_tool_name] @ [info hostname] - $ts"
        git_run commit -q -m $msg
        puts "Committed: $msg"
        puts [git_run show --stat --format= HEAD]
    } else {
        puts "Nothing new to commit."
    }

    puts "Pulling remote changes..."
    lassign [git_try pull --no-rebase --no-edit origin $::GIT_BRANCH] ok out
    if {!$ok} {
        puts $out
        catch {git_run merge --abort}
        puts "ERROR: conflict with remote changes - aborted. Your commit is kept locally."
        puts "       Check whether the same file was edited on the other PC."
        return
    }

    puts "Pushing... (a GitHub login window may appear the first time)"
    lassign [git_try push origin HEAD:$::GIT_BRANCH] ok out
    puts $out
    if {!$ok} {
        puts "ERROR: push failed. Check login / network."
        return
    }
    git_banner "GitHub PUSH done"
}

q_git_push_main
