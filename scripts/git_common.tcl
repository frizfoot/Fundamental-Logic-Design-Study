# =============================================================
# git_common.tcl - Vivado 툴바 버튼(git_push / git_pull) 공통 함수
# =============================================================
set GIT_REMOTE_URL "https://github.com/frizfoot/Fundamental-Logic-Design-Study.git"
set GIT_BRANCH     "master"
set GIT_ROOT       [file normalize [file join [file dirname [info script]] ..]]

# 터미널 프롬프트 대기로 Vivado 가 멈추지 않도록 (로그인은 Git Credential Manager 창으로)
set ::env(GIT_TERMINAL_PROMPT) 0

proc git_run {args} {
    # stderr 도 결과에 합침. 실패 시 에러를 던짐
    return [exec git -C $::GIT_ROOT {*}$args 2>@1]
}

proc git_try {args} {
    # 실패해도 에러를 던지지 않고 {성공여부 출력} 반환
    set ok [expr {![catch {exec git -C $::GIT_ROOT {*}$args 2>@1} out]}]
    return [list $ok $out]
}

proc git_banner {msg} {
    puts "=========================================================="
    puts " $msg"
    puts "=========================================================="
}

proc git_ensure_remote {} {
    # 토큰이 박힌 예전 URL 대신 깨끗한 URL 사용 (인증은 Git Credential Manager)
    lassign [git_try remote get-url origin] ok url
    if {!$ok} {
        git_run remote add origin $::GIT_REMOTE_URL
    } elseif {$url ne $::GIT_REMOTE_URL} {
        git_run remote set-url origin $::GIT_REMOTE_URL
    }
}

proc git_has_rebase_in_progress {} {
    set gd [file join $::GIT_ROOT .git]
    foreach f {rebase-merge rebase-apply MERGE_HEAD} {
        if {[file exists [file join $gd $f]]} { return 1 }
    }
    return 0
}

# 열려 있는 프로젝트가 projects/<작업명>/vivado_proj 이면
# src/ sim/ xdc/ 에 새로 생긴 파일은 추가하고, 사라진 파일은 프로젝트에서 제거
proc git_sync_open_project {} {
    if {[catch {current_project} proj] || $proj eq ""} { return }
    set pdir [file normalize [get_property DIRECTORY [current_project]]]
    if {[file tail $pdir] ne "vivado_proj"} { return }
    set work [file dirname $pdir]

    set map [list src sources_1 {v sv vh svh vhd vhdl} \
                  sim sim_1     {v sv vh svh vhd vhdl wcfg} \
                  xdc constrs_1 {xdc}]
    set added 0; set removed 0
    foreach {dir fs exts} $map {
        set fileset [get_filesets $fs]
        set disk {}
        foreach e $exts {
            foreach f [glob -nocomplain -directory [file join $work $dir] -types f *.$e] {
                lappend disk [file normalize $f]
            }
        }
        set inproj {}
        foreach f [get_files -quiet -of_objects $fileset -norecurse] {
            lappend inproj [file normalize $f]
        }
        foreach f $disk {
            if {[lsearch -exact $inproj $f] < 0} { add_files -norecurse -fileset $fileset $f; incr added }
        }
        foreach f $inproj {
            if {[string first [file normalize [file join $work $dir]] $f] == 0 && ![file exists $f]} {
                remove_files -fileset $fileset $f; incr removed
            }
        }
    }
    if {$added || $removed} {
        update_compile_order -fileset sources_1
        update_compile_order -fileset sim_1
    }
    puts "Open project synced ([file tail $work]): added $added, removed $removed"
}
