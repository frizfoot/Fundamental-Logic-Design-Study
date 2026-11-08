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

# 로컬 프로젝트(vivado_proj)가 없는 작업 폴더들을 별도 Vivado batch 프로세스로 생성
# (지금 GUI 에 열려 있는 프로젝트는 건드리지 않음)
proc git_create_missing_projects {dirs} {
    set todo {}
    foreach d $dirs {
        if {[file isdirectory $d] && ![file exists [file join $d vivado_proj]]} { lappend todo [file normalize $d] }
    }
    if {[llength $todo] == 0} { return }

    set vivado [file nativename [file join $::env(XILINX_VIVADO) bin vivado.bat]]
    set list_tcl [file join $::env(TEMP) git_create_projects_[pid].tcl]
    set fh [open $list_tcl w]
    puts $fh "foreach d [list $todo] {"
    puts $fh "    set ::create_proj_dir \$d"
    puts $fh "    if {\[catch {source [list [file join $::GIT_ROOT scripts create_proj.tcl]]} e\]} { puts \"FAILED \$d : \$e\" }"
    puts $fh "    catch {close_project}"
    puts $fh "}"
    close $fh

    puts "Creating local Vivado project(s) for: [join [lmap d $todo {file tail $d}] {, }]  (please wait...)"
    set old [pwd]
    cd $::env(TEMP)
    catch {exec cmd /c $vivado -mode batch -nojournal -nolog -source $list_tcl 2>@1} out
    cd $old
    file delete -force $list_tcl [file join $::env(TEMP) dfx_runtime.txt]
    foreach line [split $out "\n"] {
        if {[regexp {Local Vivado project created|WARNING: part|FAILED|^ERROR} $line]} { puts $line }
    }
    puts "Open them with File > Open Project > projects/<name>/vivado_proj/local_work.xpr"
}

# Vivado GUI 의 [Add Sources > Create File] 은 새 파일을
# vivado_proj/local_work.srcs/<fileset>/new/ 에 만드는데, 이 폴더는 .gitignore 대상이라
# 커밋되지 않는다 ("Nothing new to commit" 의 원인).
# 열린 프로젝트의 그런 파일을 src/ sim/ xdc/ 로 옮기고 프로젝트 참조도 새 경로로 바꾼다.
set GIT_SRC_EXTS {.v .sv .vh .svh .vhd .vhdl .xdc .wcfg}

proc git_adopt_project_files {} {
    if {[catch {current_project} proj] || $proj eq ""} { return }
    set pdir [file normalize [get_property DIRECTORY [current_project]]]
    if {[file tail $pdir] ne "vivado_proj"} { return }
    set work [file dirname $pdir]
    set moved 0
    # sources_1 를 먼저 처리 (sim_1 조회 시 소스 파일이 같이 보일 수 있음)
    foreach {fs dir} {sources_1 src sim_1 sim constrs_1 xdc} {
        set fileset [get_filesets -quiet $fs]
        if {$fileset eq ""} { continue }
        set top [get_property -quiet top $fileset]
        set changed 0
        # 주의: Vivado 명령(remove_files 등)에 넘긴 Tcl 경로 객체는 내부가 망가져
        #       재사용 시 Vivado 가 크래시함 ("UpdateStringOfFsPath with invalid object").
        #       그래서 경로는 항상 [format %s ...] 로 새 문자열을 만들어 넘긴다.
        set files [lmap f [get_files -quiet -of_objects $fileset -norecurse] {format %s $f}]
        foreach f $files {
            set nf [format %s [file normalize $f]]
            if {[string first "$pdir/" $nf] != 0} { continue }
            if {[string tolower [file extension $nf]] ni $::GIT_SRC_EXTS} { continue }
            if {![file exists $nf]} { continue }
            set dst [format %s [file join $work $dir [file tail $nf]]]
            if {[file exists $dst]} {
                puts "WARNING: [file tail $nf] exists in both $dir/ and vivado_proj - not moved (not uploaded!): $nf"
                continue
            }
            file mkdir [file dirname $dst]
            if {[catch {
                remove_files -fileset $fileset [format %s $nf]
                file rename [format %s $nf] [format %s $dst]
                add_files -norecurse -fileset $fileset [format %s $dst]
            } e]} {
                puts "WARNING: could not move [file tail $nf] to $dir/ : $e"
                if {[file exists $dst] && ![file exists $nf]} { catch {file rename [format %s $dst] [format %s $nf]} }
                catch {add_files -norecurse -fileset $fileset [format %s $nf]}
                continue
            }
            puts "Moved into repo: vivado_proj/... -> [file tail $work]/$dir/[file tail $nf]"
            incr moved; set changed 1
        }
        if {$changed && $top ne ""} { catch {set_property top $top $fileset} }
    }
    if {$moved} {
        catch {update_compile_order -fileset sources_1}
        catch {update_compile_order -fileset sim_1}
    }
}

# 열려 있지 않은 다른 프로젝트의 vivado_proj 안에 숨어 있는 소스 파일 경고
proc git_find_src_in {dir} {
    set out {}
    foreach f [glob -nocomplain -directory $dir -types f *] {
        if {[string tolower [file extension $f]] in $::GIT_SRC_EXTS} { lappend out $f }
    }
    foreach d [glob -nocomplain -directory $dir -types d *] {
        if {[file tail $d] in {local_work.sim local_work.runs local_work.gen local_work.cache local_work.ip_user_files local_work.hw}} { continue }
        set out [concat $out [git_find_src_in $d]]
    }
    return $out
}

proc git_warn_hidden_sources {} {
    set hidden {}
    foreach p [glob -nocomplain -directory [file join $::GIT_ROOT projects] -types d */vivado_proj] {
        set hidden [concat $hidden [git_find_src_in $p]]
    }
    if {[llength $hidden] == 0} { return }
    puts "WARNING: these files are inside vivado_proj/ (git-ignored) and were NOT uploaded."
    puts "         Open that project in Vivado and press GitHub Push again to move them:"
    foreach f $hidden { puts "           $f" }
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
                lappend disk [format %s [file normalize $f]]
            }
        }
        set inproj {}
        foreach f [get_files -quiet -of_objects $fileset -norecurse] {
            lappend inproj [format %s [file normalize [format %s $f]]]
        }
        foreach f $disk {
            if {[lsearch -exact $inproj $f] < 0} { add_files -norecurse -fileset $fileset [format %s $f]; incr added }
        }
        foreach f $inproj {
            if {[string first [file normalize [file join $work $dir]] $f] == 0 && ![file exists $f]} {
                remove_files -fileset $fileset [format %s $f]; incr removed
            }
        }
    }
    if {$added || $removed} {
        update_compile_order -fileset sources_1
        update_compile_order -fileset sim_1
    }
    puts "Open project synced ([file tail $work]): added $added, removed $removed"
}
