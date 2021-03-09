###############################################################################
#
# gui_hooks.tcl
#
# Script created on JANUARY 2021 by Nicolas Ruiz Requejo
#
# https://github.com/nicruireq
#
###############################################################################

package require Vivado 1.2018.1

# tclapp/nicruireq/hdltools/gui_hooks.tcl
namespace eval ::tclapp::nicruireq::hdltools {
    namespace export gui_run-vhdl_get_instantiation_template \
        gui_run-vhdl_get_testbench_template install uninstall
}

proc ::tclapp::nicruireq::hdltools::gui_run-vhdl_get_instantiation_template {} {

    # Summary: Launch the process to obtain VHDL instantiation template from a source file in the current project opened in GUI

    # Argument Usage:

    # Return Value:
    # Adds the generated template to current opened project

    # Categories: xilinxtclstore, hdltools

    # gets selected source file from the gui
    set selected_vhd [lindex [get_selected_objects] 0]
    # we need to ensure that the vhdl code is syntactically
    # correct then
    if {![string equal [check_syntax -return_string] {}]} {
        error " Error - check VHDL source files syntax and save them. "
    }
    # generate template
    set success {}
    if {[catch {
        set template_path [vhdl_get_template \
            $selected_vhd [file dirname $selected_vhd] "-tp"]
    } template_error]} {
        error " Error - generating template failed: $template_error"
    }
    # add template file to project fileset,
    # by default configuration your current_fileset
    # will be 'sources_1'
    if {[regexp {\s+} $template_path]} {
        # if the dir string has spaces we need to eval
        # the command with the dir between double {{}}
        eval add_files -norecurse "{{$template_path}}"
    } else {
        # this works only for dir strings don't contains
        # spaces
        eval add_files -norecurse "\"$template_path\""
    }
    #update_compile_order -fileset sources_1
}

proc ::tclapp::nicruireq::hdltools::gui_run-vhdl_get_testbench_template {} {

    # Summary: Launch the process to obtain VHDL testbench templates from a source file in the current project opened in GUI

    # Argument Usage:

    # Return Value:
    # Adds the generated template to current opened project

    # Categories: xilinxtclstore, hdltools

    # gets selected source file from the gui
    set selected_vhd [lindex [get_selected_objects] 0]
    # we need to ensure that the vhdl code is syntactically
    # correct then
    if {![string equal [check_syntax -return_string] {}]} {
        error " Error - check VHDL source files syntax and save them. "
    }
    # generate template
    set project_dir [get_property DIRECTORY [current_project]]
    set sim_1_path "$project_dir/[current_project].srcs/sim_1/new"
    # add template file to project simulation fileset sim_1
    file mkdir $sim_1_path
    if {[catch {
        set template_path [vhdl_get_template \
            $selected_vhd $sim_1_path "-tb"]
    } template_error]} {
        error " Error - generating template failed: $template_error"
    }

    if {[regexp {\s+} $template_path]} {
        # if the dir string has spaces we need to eval
        # the command with the dir between double {{}}
        eval add_files -fileset sim_1 -norecurse "{{$template_path}}"
    } else {
        # this works only for dir strings don't contains
        # spaces
        eval add_files -fileset sim_1 -norecurse "\"$template_path\""
    }
    #update_compile_order -fileset sim_1
}

proc ::tclapp::nicruireq::hdltools::install { args } {
    # Summary :
    # Argument Usage:
    # Return Value:

    ## Add Vivado GUI button for the app
    if { ([lsearch [get_gui_custom_commands] vhdlInstantiationTemplate] >= 0) || \
         ([lsearch [get_gui_custom_commands] vhdlTestbenchTemplate] >= 0)
    } {
        puts "INFO: Vivado GUI button for the app is already installed. Exiting ..."
        return -code ok
    }
    # button instantiation
    set xilinx_tclapp_repo_path $::env(XILINX_TCLAPP_REPO)
    puts "INFO: Adding Vivado GUI button for the app"
    create_gui_custom_command -name "vhdlInstantiationTemplate" \
        -menu_name "Generate VHDL instantiation template" \
        -description "Generate VHDL instantiation template from\
                      selected source .vhd file in GUI" \
        -command "::tclapp::nicruireq::hdltools::gui_run-vhdl_get_instantiation_template" \
        -toolbar_icon "$xilinx_tclapp_repo_path/tclapp/nicruireq/hdltools/icon/vhdl_instantiation.png" \
        -show_on_toolbar \
        -run_proc true
    # button testbench
    puts "INFO: Adding Vivado GUI button for the app"
    create_gui_custom_command -name "vhdlTestbenchTemplate" \
        -menu_name "Generate VHDL testbench template" \
        -description "Generate VHDL testbench template from\
                      selected source .vhd file in GUI" \
        -command "::tclapp::nicruireq::hdltools::gui_run-vhdl_get_testbench_template" \
        -toolbar_icon "$xilinx_tclapp_repo_path/tclapp/nicruireq/hdltools/icon/vhdl_testbench.png" \
        -show_on_toolbar \
        -run_proc true
    return -code ok
}

proc ::tclapp::nicruireq::hdltools::uninstall { args } {
    # Summary :
    # Argument Usage:
    # Return Value:

    # remove instantiation button
    if { [lsearch [get_gui_custom_commands] vhdlInstantiationTemplate] >= 0 } {
        puts "INFO: Vivado GUI button for this app is removed."
        remove_gui_custom_commands "vhdlInstantiationTemplate"
    } else {
        puts "INFO: Vivado GUI button for this app is not installed."
    }
    # remove testbench button
    if { [lsearch [get_gui_custom_commands] vhdlTestbenchTemplate] >= 0 } {
        puts "INFO: Vivado GUI button for this app is removed."
        remove_gui_custom_commands "vhdlTestbenchTemplate"
    } else {
        puts "INFO: Vivado GUI button for this app is not installed."
    }
    return -code ok
}
