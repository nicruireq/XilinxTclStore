# Hdltools App
## Description
This directory is a collection of scripts and
utility application to help perform repetitive
tasks when you work with HDL files in your projects
such as templates generation.

At this time the app provide support for VHDL language,
with these tasks:
-Component instantiation templates generation
-Testbench templates generation from entities in
 .vhd source files

 Automatic templates generation is based on regular expression.
 The above tasks are integrated with Vivado GUI by creation of
 a button per task in the toolbar.

 ## Useful instructions
- All exported procs must be defined within the
  ::tclapp::nicruireq::hdltools
- Namespace variables and helper procs must be defined
  within its own subnamespace as:
  ::tclapp::nicruireq::hdltools::<subnamespace>
- subnamespace must be defined as:
  eval [list namespace eval ::tclapp::nicruireq::hdltools::<subnamespace> {
      ...
  }
- test folder include test based on tcltest utility
