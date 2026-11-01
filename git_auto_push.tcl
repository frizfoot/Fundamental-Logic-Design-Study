# =============================================================
# git_auto_push.tcl
# Vivado에서 실행할 자동 커밋/푸시 스크립트
# 설정값은 같은 폴더의 git_auto_config.tcl 에서 불러옵니다.
# =============================================================

set SCRIPT_DIR [file dirname [file normalize [info script]]]
source [file join $SCRIPT_DIR "git_auto_config.tcl"]

# -------------------------------------------------------------
# git 명령어를 GIT_ROOT_DIR 에서 실행하는 헬퍼
# -------------------------------------------------------------
proc run_git {args} {
    global GIT_ROOT_DIR
    set cmd [linsert $args 0 exec git -C $GIT_ROOT_DIR]
    return [eval $cmd]
}

proc git_auto_push {} {
    global GIT_ROOT_DIR GITHUB_REMOTE_URL REMOTE_BRANCH COMMIT_PREFIX FORCE_FIRST_PUSH

    puts "===================================================="
    puts "Git auto push started: [clock format [clock seconds]]"
    puts "Repo: $GIT_ROOT_DIR"
    puts "===================================================="

    # 1) remote URL을 항상 최신 토큰으로 갱신 (토큰 갱신 시 config만 고치면 자동 반영됨)
    if {[catch {run_git remote set-url origin $GITHUB_REMOTE_URL} err]} {
        puts "ERROR: failed to set remote url - $err"
        return
    }

    # 2) 원격 변경사항 먼저 받아오기 (다른 컴퓨터에서 올린 작업 병합)
    puts "Fetching from origin..."
    if {[catch {run_git fetch origin} err]} {
        puts "WARNING: git fetch failed - $err"
    } else {
        puts "Pulling (merge) from origin/$REMOTE_BRANCH..."
        if {[catch {run_git pull origin $REMOTE_BRANCH} err]} {
            puts "ERROR: git pull failed - $err"
            puts "Conflict일 가능성이 있습니다. 수동으로 확인 후 해결해주세요."
            return
        }
    }

    # 3) 모든 변경사항 스테이징
    if {[catch {run_git add -A} err]} {
        puts "ERROR: git add failed - $err"
        return
    }

    # 4) 변경사항이 있는지 확인
    if {[catch {run_git diff --cached --quiet} result options]} {
        set has_changes 1
    } else {
        set has_changes 0
    }

    # 5) 변경사항이 있으면 커밋
    if {$has_changes} {
        set timestamp [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]
        set commit_msg "$COMMIT_PREFIX - $timestamp"
        if {[catch {run_git commit -m $commit_msg} err]} {
            puts "ERROR: git commit failed - $err"
            return
        }
        puts "Committed: $commit_msg"
    } else {
        puts "No new changes to commit."
    }

    # 6) push
    set push_args [list push -u origin HEAD:$REMOTE_BRANCH]
    if {$FORCE_FIRST_PUSH} {
        lappend push_args --force
    }

    if {[catch {eval run_git $push_args} err]} {
        puts "ERROR: git push failed - $err"
        puts "Check your GitHub token in git_auto_config.tcl"
        return
    }

    puts "===================================================="
    puts "Git auto push finished successfully."
    puts "===================================================="
}

# 스크립트를 직접 실행했을 때 바로 동작
git_auto_push
