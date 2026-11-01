# =============================================================
# git_pull.tcl - [GitHub 받기] 버튼
# 원격 최신 내용 받기 (아직 안 올린 로컬 수정은 보존) -> 열린 프로젝트 파일 목록 갱신
# =============================================================
source [file join [file dirname [info script]] git_common.tcl]

proc git_pull_main {} {
    git_banner "GitHub PULL start: $::GIT_ROOT"
    if {[git_has_rebase_in_progress]} {
        puts "ERROR: a previous rebase/conflict is unresolved. Run git status in a terminal."
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
        # 이 PC에 아직 로컬 프로젝트가 없는 작업 폴더 안내
        foreach d [glob -nocomplain -directory [file join $::GIT_ROOT projects] -types d *] {
            if {![file exists [file join $d vivado_proj]]} {
                puts "NOTE: [file tail $d] has no local project on this PC -> cd $d ; source ../../scripts/create_proj.tcl"
            }
        }
    }
    git_sync_open_project
    git_banner "GitHub PULL done"
}

git_pull_main
