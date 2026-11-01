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

set work_dir  [file normalize [pwd]]
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
puts " 로컬 Vivado 프로젝트 생성 완료: $proj_dir/$proj_name.xpr"
puts " Vivado [version -short] / part $fpga_part"
puts " src, sim, xdc 안의 파일을 수정하면 그대로 Git 에 반영됩니다."
puts " 새 소스 파일은 반드시 vivado_proj/ 밖의 src/ 또는 sim/ 에 만드세요."
puts "=========================================================="
