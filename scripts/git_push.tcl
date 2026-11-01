# =============================================================
# git_push.tcl - [GitHub 올리기] 버튼
# 변경사항 커밋 -> 원격 변경 받아서 합치기(merge) -> 푸시
# =============================================================
source [file join [file dirname [info script]] git_common.tcl]

proc git_push_main {} {
    git_banner "GitHub PUSH start: $::GIT_ROOT"
    if {[git_has_rebase_in_progress]} {
        puts "ERROR: a previous rebase/conflict is unresolved. Run git status in a terminal."
        return
    }
    git_ensure_remote

    # 열려 있는 블록 디자인 저장 (있는 경우)
    catch {foreach bd [get_bd_designs -quiet] { save_bd_design $bd }}

    # 1) 커밋
    git_run add -A
    lassign [git_try diff --cached --quiet] clean _
    if {!$clean} {
        set ts [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]
        set msg "Vivado [version -short] @ [info hostname] - $ts"
        git_run commit -q -m $msg
        puts "Committed: $msg"
        puts [git_run show --stat --format= HEAD]
    } else {
        puts "Nothing new to commit."
    }

    # 2) 원격 변경 합치기
    puts "Pulling remote changes..."
    lassign [git_try pull --no-rebase --no-edit origin $::GIT_BRANCH] ok out
    if {!$ok} {
        puts $out
        catch {git_run merge --abort}
        puts "ERROR: conflict with remote changes - aborted. Your commit is kept locally."
        puts "       Check whether the same file was edited on another PC."
        return
    }

    # 3) 푸시
    puts "Pushing... (a GitHub login window may appear the first time)"
    lassign [git_try push origin HEAD:$::GIT_BRANCH] ok out
    puts $out
    if {!$ok} {
        puts "ERROR: push failed. Check login / network."
        return
    }
    git_banner "GitHub PUSH done"
}

git_push_main
