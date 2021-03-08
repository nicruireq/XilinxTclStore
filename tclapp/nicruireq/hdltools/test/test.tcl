###############################################################################
#
# test.tcl
#
# Script created on JANUARY 2021 by Nicolas Ruiz Requejo
#
# https://github.com/nicruireq
#
###############################################################################

package require tcltest 2.3
namespace import ::tcltest::*

source "../vhdl_templates.tcl"
package require ::tclapp::nicruireq::hdltools


#==================================================#
#   TEST AUXILIARY PROCS                           #
#==================================================#

proc load_mock_file {fname} {
    set fmock [open $fname "r"]
    set mock [read $fmock]
    return $mock
}


proc lequal {xs ys} {
    if {[llength $xs] != [llength $ys]} { return 0 }
    foreach x $xs y $ys {
        if {![string equal $x $y]} { return 0 }
    }
    return 1
}


proc clean_vars_namespaces {} {
    set ::tclapp::nicruireq::hdltools::vhdl_utils::entity {}
    set ::tclapp::nicruireq::hdltools::vhdl_utils::entity_name {}
    set ::tclapp::nicruireq::hdltools::vhdl_utils::tp_component {}
    set ::tclapp::nicruireq::hdltools::vhdl_utils::ports_names {}
    set ::tclapp::nicruireq::hdltools::vhdl_utils::ports_types {}
    set ::tclapp::nicruireq::hdltools::vhdl_utils::tp_instantiation {}
    set ::tclapp::nicruireq::hdltools::vhdl_utils::has_generic_list {}
    set ::tclapp::nicruireq::hdltools::vhdl_utils::is_clocked {}
    set ::tclapp::nicruireq::hdltools::vhdl_utils::clock_name {}
    set ::tclapp::nicruireq::hdltools::vhdl_utils::reset_name {}
}


#==================================================#
#   CONFIGURE AND RUN TESTS                        #
#==================================================#

# configure -verbose bpel -debug 3 -singleproc 1
configure -singleproc 1 \
          -testdir [pwd] \
          -file "test_vhdl_utils.test"
runAllTests
