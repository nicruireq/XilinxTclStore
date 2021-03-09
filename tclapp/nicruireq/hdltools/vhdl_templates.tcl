###############################################################################
#
# vhdl_templates.tcl
#
# Script created on JANUARY 2021 by Nicolas Ruiz Requejo
#
# https://github.com/nicruireq
#
###############################################################################

package require Vivado 1.2018.1

# tclapp/nicruireq/hdltools/vhdl_templates.tcl
namespace eval ::tclapp::nicruireq::hdltools {
    namespace export vhdl_get_template
}


# Trick to silence the linter
eval [list namespace eval ::tclapp::nicruireq::hdltools::vhdl_utils {
	# holds string with the entity
	variable entity
	# holds string with the entity name
	variable entity_name
	# string where is formated the component
	variable tp_component
	# list of ports names and types of ports
	# extracted from entity, using same index
	# for the same pair (port name, type) 0...n
	variable ports_names
	variable ports_types
	# string where is formated the component
	# instantiation statement
	variable tp_instantiation
	# to know if entity has generic list
	variable has_generic_list
	# to know if design has clocked process
	variable is_clocked
	variable clock_name
	variable reset_name
}]


proc ::tclapp::nicruireq::hdltools::vhdl_get_template {filepath {outputdir "."} {template_type "-tp"}} {

	# Summary: Generates VHDL instantiation or testbench templates

    # Argument Usage:
	# filepath : VHDL source file path to analyze
	# [outputdir = .] : Directory where template file will be generated 
	# [template_type = -tp] : Type of template to be generated. Allowed values: -tp (component and instantiation template) or -tb (testbench template)

    # Return Value:
	# return full path of generated template file (instantiation or testbench)

    # Categories: xilinxtclstore, hdltools

	# It is only a wrapper
	return [uplevel ::tclapp::nicruireq::hdltools::vhdl_utils::get_template \
						$filepath $outputdir $template_type]
}


proc ::tclapp::nicruireq::hdltools::vhdl_utils::extract_entity {data} {

    # Summary:

    # Argument Usage:

    # Return Value:

    # Categories: xilinxtclstore, hdltools


    # Extracts an vhdl entity declaration
    #  data - Text string with VHDL code
    # The command will try to match an VHDL entity 
    # declaration and extract it
    #
    # Returns 0 if there isn't an entity declaration
    # else returns 1. The entity declaration is stored 
    # in namespace variable 'entity' and its name
    # in namespace variable 'entity_name'


    # variables to be used in this proc
	variable entity
	variable entity_name
	
	set entity_is_matched [regexp -nocase -- \
				 {entity\s+([A-Za-z0-9_]+)\s+is.*end\s+[A-Za-z0-9_]+\s*;\s+(?=architecture)} \
				 $data entity entity_name \
	]
	
	return $entity_is_matched
}


proc ::tclapp::nicruireq::hdltools::vhdl_utils::generate_component {entity_text} {

    # Summary:

    # Argument Usage:

    # Return Value:

    # Categories: xilinxtclstore, hdltools


    # Generates the component template
    #  entity_text - String with the entity's representation
    #
    # Returns 0 if it hasn't been to possible generate the template
    # else returns 1. The component template is stored in the namespace
    # variable 'tp_component'. An entity with empty port list is valid.

	# variables to be used in this proc
	variable tp_component
	
	# replace 'entity' by 'component'
	set number_of_replacements [regsub -nocase -- {^entity} \
					$entity_text "component" tp_aux \
	]
	if {$number_of_replacements} {
		# replace 'end entity_name;' by 'end component;'
		set number_of_replacements [regsub -nocase -- \
						{end\s+([A-Za-z0-9_]+\s*);} \
						$tp_aux {end component;} tp_component \
		]
	}
	
	return $number_of_replacements
}


proc ::tclapp::nicruireq::hdltools::vhdl_utils::generate_instantiation_template {entity_text entity_name} {

    # Summary:

    # Argument Usage:

    # Return Value:

    # Categories: xilinxtclstore, hdltools


	# Generates the component instantiation statement
	#  entity_text - String with the entity's representation
	#  entity_name - The name of the entity
	# Try to match for generic statement and port statement.
	# If success, extracts port names and generic names and
	# makes the template
	#
	# Returns 0 if it hasn't been to possible generate the template,
	# else returns 1. The template is stored in the namespace
	# variable *tp_instantiation*, also generates list with
	# ports names in *ports_names* and ports types in *ports_types*.
	# Another namespace side effects: *has_generic_list*

	# variables to be used in this proc
	variable ports_names
	variable ports_types
	variable has_generic_list
	variable tp_instantiation
	
	# count number of ports and extract their names
	# the regular expression expects first 'port ('
	# and finish with the first ');'
	# stub is discarded 
	set has_port_list [regexp -nocase -- {port\s*\((.*?)\)\s*;} \
						$entity_text stub str_port_list \
	]	
	# now $str_port_list has only the ports
	if {$has_port_list} {
		# split port list by ';'
		set port_list [split $str_port_list {;}]
		# declare empty list to store only ports's names
		set ports_names [list]
		foreach port $port_list {
			# split by ':' and get the names in index zero 
			# and types in index 1
			set pair_port_type [split $port {:}]
			# extracts separate ports from types
			lappend ports_names [string trim [lindex $pair_port_type 0]]
			lappend ports_types [string trim [lindex $pair_port_type 1]]
		} 
	}

	# test if there is generic list in entity_text
	# try a regular expression which begins 
	# with 'generic' and maybe spaces and '('
	# and finish with ';' and spaces and 'port'
	# stub is discarded
	set has_generic_list [regexp -nocase -- \
							{generic\s*\(((?:\s*\w+\s*:\s*\w+\s*:=\s*([\d]+\s*;?|".*";?)\s*)*)\)\s*;} \
							$entity_text stub str_generic_list \
	]
	# now $str_generic_list may have a generic list
	if {$has_generic_list} {
		# idem to above code
		set generic_list [split $str_generic_list {;}]
		set generics_names [list]
		foreach param $generic_list {
			lappend generics_names [string trim [lindex [split $param {:}] 0]]
		}
	}

	# the template is generate with 'append'
	set tp_instantiation "my_"
	append tp_instantiation [string tolower $entity_name] " : " $entity_name "\n"
	# add generic instantiation
	if {$has_generic_list} {
		append tp_instantiation "\tgeneric map("
		set num_params [llength $generics_names]
		# if there is only one param
		if {$num_params == 1} {
			append tp_instantiation [lindex $generics_names 0] " => )\n"
		} else {
			# several params 
			for {set i 0} {$i < $num_params} {incr i} {
				if {$i == 0} {
					append tp_instantiation "\n"
				}

				if {$i == [expr ($num_params - 1)]} {
					# last param
					append tp_instantiation "\t\t" [lindex $generics_names $i] " => )\n"
				} else {
					# rest of params
					append tp_instantiation "\t\t" [lindex $generics_names $i] " => ,\n"
				}
			}
			
		}
	}

	# add ports instantiation 
	if {$has_port_list} {
		append tp_instantiation "\tport map(\n"
		set num_ports [llength $ports_names]
		for {set i 0} {$i < $num_ports} {incr i} {
			if {$i == [expr ($num_ports - 1)]} {
				# last param
				append tp_instantiation "\t\t" [lindex $ports_names $i] " => );\n"
			} else {
				# rest of params
				append tp_instantiation "\t\t" [lindex $ports_names $i] " => ,\n"
			}
		}
	}

	# return 'true' if any of port list or generic list
	# are available
	return [expr ($has_port_list || $has_generic_list)]
}


proc ::tclapp::nicruireq::hdltools::vhdl_utils::make_full_instantiation_template {component_template instantiation_template} {

	# Summary:

    # Argument Usage:

    # Return Value:

    # Categories: xilinxtclstore, hdltools


	# Generate text with component and component
	# instantiation template together
	#  component_template - String with component
	#  instantiation_template - String with instantiation template
	#  
	# Returns text of full template

	set full_template [format {
-- VHDL Component Instantiation Template 
-- Autogenerated from nicruireq::hdltools app 
-- Written by Nicolas Ruiz Requejo
-- 
-- Notice:
-- Copy and paste the templates in your destination file(s) and then edit
-- Please if you discover a bug submit an Issue in
-- https://github.com/nicruireq/XilinxTclStore
--

%s

%s

	} $component_template $instantiation_template]

	return $full_template
}


proc ::tclapp::nicruireq::hdltools::vhdl_utils::write_to_file {source_vhdl_file output_directory text_to_write filename_tail} {

    # Summary:

    # Argument Usage:

    # Return Value:

    # Categories: xilinxtclstore, hdltools


	# Writes text in the output file
	#  source_vhdl_file - Path to source vhdl file
	#  output_directory - Path to output directory
	#  text_to_write - text to be written to the file
	#  filename_tail - String with desired file name end (i.e.: _tp.vho, _tb.vhd)
	#
	# Returns the output path where new file
	# has been written

	# check if source_vhdl_file is null
	if {[string trim $source_vhdl_file] eq ""} {
		error " Error - the source file path is an empty string. "
	}
	# check if output_directory is null
	if {[string trim $output_directory] eq ""} {
		error " Error - the output directory file is an empty string. "
	}
	# check if output_directory is a directory
	if {![file isdirectory [file dirname $output_directory]]} {
		error " Error - dir : $output_directory - is not a valid directory. "
	}

	# gets only the filename from the source path
	# the last element of a list got by splitting the path
	# by slash
	set srcname [lindex [split [string trim $source_vhdl_file] {/}] end]

	# write in file
	if {[catch {
		# create file name
		append fname [lindex [split $srcname {.}] 0] $filename_tail
		append output_directory "/" $fname
		set tpfile [open $output_directory "w"]
		puts $tpfile $text_to_write
		close $tpfile
	} werror]} {
		error " Error - Output file could not be wrote : $werror "
	}

	return $output_directory
}


proc ::tclapp::nicruireq::hdltools::vhdl_utils::get_instantiation_template {filepath {outputdir "."} } {

    # Summary:

    # Argument Usage:

    # Return Value:

    # Categories: xilinxtclstore, hdltools


	# Generates component instantiation templates
	#  filepath - vhdl source file path to analyze
	#  outputdir - directory where template file *.vho* is generated 
	# 
	#
	# Generates a file in the directory *outputdir*
    # with the component and component instantiation
    # templates generated from **.vhd** file *filepath*.
	# Returns 1 if succed else throw an error


	# variables to be used in this proc
	variable entity
	variable entity_name
	variable tp_component
	variable tp_instantiation
	
	# try to open the '.vhd' file in '$filepath'
	if {[catch {
		set srcstream [open $filepath "r"]
		set vhdlsrc [read $srcstream]
		close $srcstream
	} ferror]} {
		error " File $filepath couldn't be opened : $ferror "
	}
	
	# try to match an entity declaration
	set exists_entity [extract_entity $vhdlsrc]
	
	if {$exists_entity} {
		# try to generate the component template
		set exists_comp [generate_component $entity]
		if {$exists_comp} {
			# try to generate the component instantiation template
			set exists_insttp [generate_instantiation_template $entity $entity_name]
			if {$exists_insttp} {
				# all templates have been generated
				# write in a file
				set file_text [make_full_instantiation_template \
							   $tp_component $tp_instantiation]
				write_to_file $filepath $outputdir $file_text "_tp.vho"
			} else {
				error " Error - component instantiation\
						statement template could not be\
						generated. "
			}
		} else {
			error " Error - component template could not\
					be generated. "
		}
	} else {
		error "The entity declaration could not be recognized\
			   in the file : $filepath"
	}
	# success
	return 1
}


proc ::tclapp::nicruireq::hdltools::vhdl_utils::clock_reset_exists_and_extract {vhdl_text} {

    # Summary:

    # Argument Usage:

    # Return Value:

    # Categories: xilinxtclstore, hdltools


	# Checks existence of clocked design
	#  vhdl_text - String with vhdl code
	# Checks for vhdl entity (from
    # the string 'data') if includes 
    # a clock signal and extracts clock 
	# name and reset name
	#
	# Namespace variables changed:
	# *is_clocked*, *clock_name*, *reset_name*


    # variables to be used in this proc
    variable is_clocked
	variable clock_name
	variable reset_name

	set matches [list]
    # test if clock signal is present by
    # matching rising_edge([clock]), 
	# falling_edge([clock]),
	# [clock]'event and [clock] = 0, 
	# [clock]'event and [clcok] = 1
    switch -regexp -nocase -matchvar matches -- $vhdl_text {
        {if\s+([A-Za-z0-9_]+)\s*=\s*'[01]+'\s+then\s+(?:.*)\s*elsif\s+(?:rising_edge|falling_edge)\s*\(\s*([A-Za-z0-9_]+)\s*\)\s*then} {
            set is_clocked 1;
        }
        {if\s+([A-Za-z0-9_]+)\s*=\s*'[01]+'\s*then\s+(?:.*)\s*elsif\s+([A-Za-z0-9_]+)\s*'\s*event\s+and\s+([A-Za-z0-9_]+)\s*=\s*'[01]'\s*then} {
            set is_clocked 1;
        }
        default {
            set is_clocked 0;
        }
    }

	# extracts reset and clock names
	set matchches_size [llength $matches]
	if {($matchches_size == 3) || ($matchches_size == 4)} {
		# index 1: 1st capturing group in re
		# index 2: 2st capturing group in re
		set reset_name [lindex $matches 1]
		set clock_name [lindex $matches 2]
	}
}


proc ::tclapp::nicruireq::hdltools::vhdl_utils::make_testbench {void1 void2} {

    # Summary:

    # Argument Usage:

    # Return Value:

    # Categories: xilinxtclstore, hdltools


	# Generates testbench text
	#  void1 - dumb arg to complain with strategy interface
	#  void2 - dumb arg to complain with strategy interface
	#
	# Write testbench template as string
	# from namespace variables: *entity_name*, 
	# *tp_component*, *ports_names*, *ports_types*,
	# *tp_instantiation*, *is_clocked*, *clock_name*,
	# *reset_name*. See *make_full_instantiation_template* 
	# and *get_template* to better understanding of 
	# arguments 
	# 
	# Returns testbench template as string
	# from templates variables. 

	variable entity_name
	variable tp_component
	variable ports_names
	variable ports_types
	variable tp_instantiation
	variable is_clocked
	variable clock_name
	variable reset_name

	# Instantiates a component with its template
	foreach port $ports_names {
		regsub -nocase -- "$port\\s+=>" $tp_instantiation \
			   "$port => $port" tp_instantiation
	}
	# sets entity name of testbench
	append testbench_name $entity_name "_tb"
	# Generates list of signals in a string
	for {set i 0} {$i < [llength $ports_names]} {incr i} {
		append signals "\tsignal [lindex $ports_names $i] : [string trim [regsub -nocase -- {(in|out|inout|buffer|linkage)} [lindex $ports_types $i] {}]];\n"
	}

    set testbench_text "
-- VHDL Testbench Template 
-- Autogenerated from nicruireq::hdltools app 
-- Written by Nicolas Ruiz Requejo
-- 
-- Notice:
-- Fill this template with your test code
-- Please if you discover a bug submit an Issue in
-- https://github.com/nicruireq/XilinxTclStore
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY $testbench_name IS
END $testbench_name;

ARCHITECTURE behavior OF $testbench_name IS 

	-- Component Declaration for the Unit Under Test (UUT)
[string trim $tp_component]

	-- Inputs and Outputs
$signals
"

if {$is_clocked} {
	append testbench_text \
"
	-- Clock period definitions
	constant CLK_period : time := 20 ns\;
"
}

append testbench_text \
"
BEGIN

	-- Instantiate the Unit Under Test (UUT)
	-- UUT:
	$tp_instantiation
"

# Semicolon separates two commands in Tcl.
# Using a semicolon in a quoted string results
# in an error. Semicolon must be escaped
# by putting a backward slash (\)
# in front of the semicolon
if {$is_clocked} {
	append testbench_text \
"
	CLK_process : process
	begin
		$clock_name <= '0'\;
		wait for CLK_period/2\;
		$clock_name <= '1'\;
		wait for CLK_period/2\;
	end process\;
"
}

append testbench_text \
"
   -- Stimulus process
   stim_proc: process
   begin
"

if {$is_clocked} {
	append  testbench_text \
"
      -- hold reset state for 100 ns.
      wait for 100 ns\;	

      --wait for CLK_period*10\;

      -- insert stimulus here 
		$reset_name <= '1'\;
		wait for 50 ns\;
		$reset_name <= '0'\;
		wait for 50 ns\;
"
} else {
	append  testbench_text \
"
	-- Put initialisation code here

	-- Put test bench stimulus code here

"
}

append testbench_text \
"
      wait\;
   end process\;

END\;
"

	return $testbench_text
}


proc ::tclapp::nicruireq::hdltools::vhdl_utils::get_template {filepath {outputdir "."} {template_type "-tp"}} {

    # Summary:

    # Argument Usage:

    # Return Value:

    # Categories: xilinxtclstore, hdltools


	# Generates instantiation or testbench templates
	#  filepath - vhdl source file path to analyze
	#  outputdir - directory where template file will be generated 
	#  template_type - String with type of template to be generated. 
	#				   Allowed values: 
	#					-tp (component and instantiation template)
	#					-tb (testbench template)
	#
	# Generates a file in the directory *outputdir*
    # with the instantiation or testbench template 
	# generated from **.vhd** file *filepath*.
	# Returns full file path of generate template 
	# if success else throw an error


	# variables to be used in this proc
	variable entity
	variable entity_name
	variable tp_component
	variable tp_instantiation
	
	# try to open the '.vhd' file in '$filepath'
	if {[catch {
		set srcstream [open $filepath "r"]
		set vhdlsrc [read $srcstream]
		close $srcstream
	} ferror]} {
		error " File $filepath couldn't be opened : $ferror "
	}

	# select strategy, which proc will be executed
	# according to template type argument value
	set strategy {}
	set arg1 {}
	set arg2 {}
	set filename_tail {}
	switch -exact -- $template_type {
		-tp {
			set strategy {make_full_instantiation_template}
			set arg1 {tp_component}
			set arg2 {tp_instantiation}
			set filename_tail {_tp.vho}
		}
		-tb {
			set strategy {make_testbench}
			# arg1 and arg2 must be setting due to
			# dereferencing variables like [set $var]
			# throw an error of type 
			# errorInfo: can't read "": no such variable
			# whrn var is empty -> {}
			set arg1 {tp_component}
			set arg2 {tp_instantiation}
			set filename_tail {_tb.vhd}
		}
		default {
			error " Unknown template type "
		}
	}
	
	# try to match an entity declaration
	set exists_entity [extract_entity $vhdlsrc]
	
	if {$exists_entity} {
		# try to generate the component template
		set exists_comp [generate_component $entity]
		if {$exists_comp} {
			# try to generate the component instantiation template
			set exists_insttp [generate_instantiation_template $entity $entity_name]
			if {$exists_insttp} {
				# all templates have been generated
				# write in a file
				clock_reset_exists_and_extract $vhdlsrc
				set file_text [$strategy [set $arg1] [set $arg2]]
				return [write_to_file $filepath $outputdir $file_text $filename_tail]

			} else {
				error " Error - component instantiation\
						statement template could not be\
						generated. "
			}
		} else {
			error " Error - component template could not\
					be generated. "
		}
	} else {
		error "The entity declaration could not be recognized\
			   in the file : $filepath"
	}
	# return empty, never executed
	return {}
}
