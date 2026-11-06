# =============================================================
# create_proj.tcl - 버전 호환 로컬 Vivado 프로젝트 생성기
#
# 사용법 (Vivado Tcl Console, 2025.2 / 2026.1 공통):
#   cd C:/경로/리포지토리/projects/16.29
#   source ../../scripts/create_proj.tcl
#
# - 현재 폴더(projects/<작업명>)의 src/ sim/ xdc/ 파일을 복사 없이 원본 경로로 연결
# - ip/*.xci 는 로컬 프로젝트로 import 후 현재 Vivado 버전에 맞게 upgrade
# - project.tcl 이 있으면 fpga_part / top_module / sim_top 값을 읽어 적용
# - unused/ 폴더는 무시됨 (프로젝트에서 빠져 있던 파일 보관용)
# =============================================================

# 작업 폴더: 변수 create_proj_dir 또는 -tclargs <폴더> 로 지정 가능, 없으면 현재 폴더
if {[info exists ::create_proj_dir] && $::create_proj_dir ne ""} {
    set work_dir [file normalize $::create_proj_dir]
} elseif {[info exists ::argv] && [llength $::argv] > 0 && [file isdirectory [lindex $::argv 0]]} {
    set work_dir [file normalize [lindex $::argv 0]]
} else {
    set work_dir [file normalize [pwd]]
}
set proj_name "local_work"
set proj_dir  [file join $work_dir vivado_proj]

# 기본값 (project.tcl 에서 덮어씀)
set fpga_part  "xc7k70tfbv676-1"
set top_module ""
set sim_top    ""
if {[file exists [file join $work_dir project.tcl]]} {
    source [file join $work_dir project.tcl]
}

foreach d {src sim xdc} { file mkdir [file join $work_dir $d] }

# 이 PC의 Vivado 에 해당 파트가 설치되어 있지 않으면 설치된 파트로 대체
if {[llength [get_parts -quiet $fpga_part]] == 0} {
    set fallback ""
    foreach p {xc7k70tfbv676-1 xc7a35tcpg236-1 xc7vx485tffg1157-1} {
        if {[llength [get_parts -quiet $p]] > 0} { set fallback $p; break }
    }
    if {$fallback eq ""} { set fallback [lindex [get_parts] 0] }
    puts "WARNING: part $fpga_part is not installed on this PC -> using $fallback (project.tcl unchanged)"
    set fpga_part $fallback
}

create_project -force $proj_name $proj_dir -part $fpga_part
set_property target_language Verilog [current_project]

proc hdl_files {dir} {
    set out {}
    foreach ext {v sv vh svh vhd vhdl} {
        set out [concat $out [glob -nocomplain -directory $dir -types f *.$ext]]
    }
    return [lsort $out]
}

set rtl_files [hdl_files [file join $work_dir src]]
if {[llength $rtl_files] > 0} {
    add_files -norecurse -fileset [get_filesets sources_1] $rtl_files
}

set xdc_files [glob -nocomplain -directory [file join $work_dir xdc] -types f *.xdc]
if {[llength $xdc_files] > 0} {
    add_files -norecurse -fileset [get_filesets constrs_1] $xdc_files
}

set sim_files [concat [hdl_files [file join $work_dir sim]] \
                      [glob -nocomplain -directory [file join $work_dir sim] -types f *.wcfg]]
if {[llength $sim_files] > 0} {
    add_files -norecurse -fileset [get_filesets sim_1] $sim_files
}

# IP 코어: 원본 .xci 를 로컬 프로젝트로 복사(import) 후 현재 버전으로 업그레이드
# (원본 xci 가 다른 버전의 출력물로 오염되지 않도록 함)
set xci_files [glob -nocomplain -directory [file join $work_dir ip] -types f *.xci]
if {[llength $xci_files] > 0} {
    import_ip -files $xci_files
    set ips [get_ips]
    if {[llength $ips] > 0} {
        catch {upgrade_ip $ips}
        generate_target all $ips
    }
}

# Block Design: src/*_bd.tcl (write_bd_tcl -no_ip_version 로 저장한 파일) 복원
foreach bd_tcl [glob -nocomplain -directory [file join $work_dir src] -types f *_bd.tcl] {
    source $bd_tcl
}

if {$top_module ne ""} { set_property top $top_module [get_filesets sources_1] }
if {$sim_top    ne ""} { set_property top $sim_top    [get_filesets sim_1] }
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "=========================================================="
puts " Local Vivado project created: $proj_dir/$proj_name.xpr"
puts " Vivado [version -short] / part $fpga_part"
puts " Edits to files in src/ sim/ xdc/ go straight to Git."
puts " Create NEW source files in src/ or sim/, NOT inside vivado_proj/."
puts "=========================================================="
