# =============================================================
# install_buttons.tcl - Vivado 툴바에 [GitHub 올리기] [GitHub 받기] 버튼 등록
#
# PC마다(그리고 Vivado 버전마다) 1회 실행:
#   Vivado Tcl Console 에서  source C:/경로/리포지토리/scripts/install_buttons.tcl
# 실행 후 Vivado 를 껐다 켜면 툴바에 버튼이 나타납니다.
# =============================================================
set scripts_dir [file normalize [file dirname [info script]]]
set ver         [version -short]
set cmd_dir     [file join $::env(APPDATA) Xilinx Vivado $ver commands]
set cmd_xml     [file join $cmd_dir commands.xml]
file mkdir $cmd_dir

if {[file exists $cmd_xml]} {
    file copy -force $cmd_xml "$cmd_xml.bak"
}

proc button_xml {pos name menu tcl} {
    return "  <custom_command>
    <position>$pos</position>
    <name>$name</name>
    <menu_name>$menu</menu_name>
    <tcl_file>$tcl</tcl_file>
    <show_on_toolbar>true</show_on_toolbar>
    <run_proc>false</run_proc>
    <source name=\"USER\"/>
  </custom_command>"
}

set xml "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<custom_commands major=\"1\" minor=\"0\">
[button_xml 0 git_push {GitHub Push} $scripts_dir/git_push.tcl]
[button_xml 1 git_pull {GitHub Pull} $scripts_dir/git_pull.tcl]
</custom_commands>
"
set fh [open $cmd_xml w]
fconfigure $fh -encoding utf-8
puts -nonewline $fh $xml
close $fh

puts "=========================================================="
puts " Buttons installed (Vivado $ver): $cmd_xml"
puts " Restart Vivado: \"GitHub Push\" and \"GitHub Pull\" appear on the toolbar."
puts "=========================================================="
