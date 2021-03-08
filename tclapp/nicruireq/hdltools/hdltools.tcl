# tclapp/nicruireq/hdltools/hdltools.tcl
package require Tcl 8.5

namespace eval ::tclapp::nicruireq::hdltools {

    # Allow Tcl to find tclIndex
    variable home [file join [pwd] [file dirname [info script]]]
    if {[lsearch -exact $::auto_path $home] == -1} {
        lappend ::auto_path $home
    }
    
}
package provide ::tclapp::nicruireq::hdltools 1.0
