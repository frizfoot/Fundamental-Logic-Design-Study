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
    puts "Open them with File > Open Project > projects/<name>/vivado_proj/<name>.xpr"
}

# Vivado GUI 의 [Add Sources > Create File] 은 새 파일을
# vivado_proj/<프로젝트명>.srcs/<fileset>/new/ 에 만드는데, 이 폴더는 .gitignore 대상이라
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
        # Vivado 생성물 폴더는 건너뜀 (프로젝트 이름이 local_work 든 <작업명> 이든)
        if {[regexp {\.(sim|runs|gen|cache|ip_user_files|hw)$} [file tail $d]]} { continue }
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

# =============================================================
# 잘못 열린 프로젝트 감지
# New Project 마법사나 Recent Projects 로 연 프로젝트(예: <저장소>/dice/dice.xpr)는
# 소스가 <이름>.srcs/ 에 있고, 이 폴더는 .gitignore 대상이다.
#  -> Push 해도 안 올라가고, Pull 해도 Vivado 화면은 그대로다 (받은 파일은 projects/<이름>/ 로 감).
# GitHub 와 동기화되는 건 projects/<이름>/vivado_proj 프로젝트뿐이므로, 그 외 프로젝트가
# 열려 있으면 버튼 출력 맨 끝에 크게 경고한다.
# =============================================================
proc git_norm_text {s} { return [string trimright [string map [list "\r\n" "\n"] $s]] }

proc git_read_text {f} {
    set fh [open $f r]
    fconfigure $fh -translation auto
    set d [read $fh]
    close $fh
    return [git_norm_text $d]
}

# 파일 내용이 저장소 경로 rel 의 과거 커밋 버전 중 하나와 같으면 1 (= 예전 사본, 잃는 것 없음)
proc git_in_history {f rel} {
    set mine [git_read_text $f]
    lassign [git_try log --format=%H -- $rel] ok hashes
    if {!$ok} { return 0 }
    foreach h [split $hashes "\n"] {
        set h [string trim $h]
        if {$h eq ""} { continue }
        lassign [git_try show "$h:$rel"] ok2 content
        if {$ok2 && [git_norm_text $content] eq $mine} { return 1 }
    }
    return 0
}

# 작업 폴더의 동기화되는 로컬 프로젝트 파일 (있으면 그 파일, 없으면 만들어질 경로)
proc git_local_xpr {work} {
    set found [lsort [glob -nocomplain -directory [file join $work vivado_proj] -types f *.xpr]]
    if {[llength $found] > 0} { return [file normalize [lindex $found 0]] }
    return [file join $work vivado_proj "[file tail $work].xpr"]
}

# 열린 프로젝트 정보: 없으면 {}, 있으면 dict {dir name xpr synced inrepo work}
proc git_open_project_info {} {
    if {[catch {current_project} proj] || $proj eq ""} { return {} }
    set pdir [format %s [file normalize [get_property DIRECTORY [current_project]]]]
    set name [format %s [get_property NAME [current_project]]]
    set projects_dir [file join $::GIT_ROOT projects]
    set synced [expr {[file tail $pdir] eq "vivado_proj" && [string equal -nocase [file dirname [file dirname $pdir]] $projects_dir]}]
    set inrepo [expr {[string first [string tolower "$::GIT_ROOT/"] [string tolower "$pdir/"]] == 0}]
    if {$synced} { set work [file dirname $pdir] } else { set work [file join $projects_dir $name] }
    return [dict create dir $pdir name $name xpr [file join $pdir "$name.xpr"] synced $synced inrepo $inrepo work $work]
}

# 새 작업 폴더의 project.tcl / note.md 생성 (열린 프로젝트의 파트와 top 사용)
proc git_write_new_work_files {work name} {
    foreach d {src sim xdc} { file mkdir [file join $work $d] }
    set pt [file join $work project.tcl]
    if {![file exists $pt]} {
        set part   [get_property PART [current_project]]
        set top    [get_property -quiet top [get_filesets -quiet sources_1]]
        set simtop [get_property -quiet top [get_filesets -quiet sim_1]]
        set fh [open $pt w]
        puts $fh "# $name project settings (read by create_proj.tcl)"
        puts $fh "set fpga_part \"$part\""
        puts $fh "set top_module \"$top\""
        puts $fh "set sim_top \"$simtop\""
        close $fh
    }
    set nm [file join $work note.md]
    set tpl [file join $::GIT_ROOT scripts note_template.md]
    if {![file exists $nm] && [file exists $tpl]} {
        # Vivado 의 puts 는 한글을 한 번 더 변환해서 깨뜨리므로, 제목(영문)만 puts 로 쓰고
        # 한글 템플릿 본문(UTF-8)은 바이트 그대로 fcopy 로 붙인다
        set out [open $nm w]
        fconfigure $out -translation binary
        puts -nonewline $out "# $name\n"
        set in [open $tpl r]
        fconfigure $in -translation binary
        fcopy $in $out
        close $in
        close $out
    }
}

# 동기화 안 되는 열린 프로젝트의 소스를 projects/<이름>/ 과 비교해 보고 줄 목록을 반환.
# adopt=1 이고, 프로젝트가 저장소 안에 있고, projects/<이름>/ 이 아직 없으면
# (= New Project 마법사로 막 만든 새 작업) 소스를 projects/<이름>/ 으로 복사한다.
# 이미 있는 파일은 절대 덮어쓰지 않는다.
proc git_check_unsynced {info adopt} {
    set work [dict get $info work]
    set name [dict get $info name]
    set do_copy [expr {$adopt && [dict get $info inrepo] && ![file exists $work]}]
    set lines {}
    set seen {}
    set copied 0
    # sources_1 를 먼저 처리 (sim_1 조회 시 소스 파일이 같이 보일 수 있음)
    foreach {fs dir} {sources_1 src sim_1 sim constrs_1 xdc} {
        set fileset [get_filesets -quiet $fs]
        if {$fileset eq ""} { continue }
        foreach f [lmap f [get_files -quiet -of_objects $fileset -norecurse] {format %s $f}] {
            set nf [format %s [file normalize $f]]
            if {[string tolower [file extension $nf]] ni $::GIT_SRC_EXTS} { continue }
            if {![file exists $nf] || [lsearch -exact $seen $nf] >= 0} { continue }
            lappend seen $nf
            set tail [file tail $nf]
            set rel "projects/$name/$dir/$tail"
            set dst [file join $work $dir $tail]
            if {[file exists $dst]} {
                if {[git_read_text $nf] eq [git_read_text $dst]} {
                    lappend lines "same as $rel"
                } elseif {[git_in_history $nf $rel]} {
                    lappend lines "OLD copy of $rel (nothing lost - the newer version is in projects/)"
                } else {
                    lappend lines "EDITED HERE, NOT UPLOADED (differs from $rel): $nf"
                }
            } elseif {$do_copy} {
                file mkdir [file dirname $dst]
                file copy $nf $dst
                incr copied
                lappend lines "copied into repo: $rel"
            } else {
                lappend lines "ONLY HERE, NOT UPLOADED: $nf"
            }
        }
    }
    if {$do_copy && ($copied > 0 || [llength $seen] == 0)} {
        git_write_new_work_files $work $name
        lappend lines "new work folder created: projects/$name"
    }
    return $lines
}

proc git_warn_unsynced {info lines} {
    set work [dict get $info work]
    set name [dict get $info name]
    set bar [string repeat ! 78]
    puts ""
    puts $bar
    puts "!! WRONG PROJECT OPEN - this project is NOT synced with GitHub:"
    puts "!!     [dict get $info xpr]"
    puts "!! Only projects/<name>/vivado_proj/<name>.xpr is synced. This project keeps its"
    puts "!! files in a git-ignored folder: Push does not upload them, Pull does not change them."
    foreach l $lines { puts "!!   - $l" }
    if {[file exists $work]} {
        puts "!! Close this project and open the synced one instead:"
        puts "!!     File > Open Project > [git_local_xpr $work]"
    } elseif {[dict get $info inrepo]} {
        puts "!! Press GitHub Push once with this project open: its sources are copied into"
        puts "!! projects/$name/ and uploaded, then open projects/$name/vivado_proj/$name.xpr"
    } else {
        puts "!! This project is outside $::GIT_ROOT, so nothing from it goes to GitHub."
    }
    puts $bar
}

# 버튼 출력 맨 끝에서 호출: 동기화 안 되는 프로젝트가 열려 있으면 경고
# (adopt=1 은 Push 용: 새 작업이면 projects/<이름>/ 으로 복사)
proc git_check_open_project {adopt} {
    set info [git_open_project_info]
    if {$info eq {} || [dict get $info synced]} { return {} }
    return [list $info [git_check_unsynced $info $adopt]]
}
