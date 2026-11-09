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
    }
    # 이 PC에 로컬 프로젝트가 없는 작업 폴더는 자동 생성 (다른 PC에서 새로 올린 작업 포함)
    git_create_missing_projects [glob -nocomplain -directory [file join $::GIT_ROOT projects] -types d *]
    git_sync_open_project
    git_banner "GitHub PULL done"
}

git_pull_main
# 동기화 안 되는 프로젝트가 열려 있으면 맨 끝에 크게 경고 (안 그러면 Pull 이 안 된 것처럼 보임)
set git_unsynced [git_check_open_project 0]
if {$git_unsynced ne {}} { git_warn_unsynced {*}$git_unsynced }
