## -*- tcl -*-
# # ## ### ##### ######## ############# #####################
## (c) 2013-2014 Andreas Kupries
## Linenoise OO REPL base class.

# @@ Meta Begin
# Package linenoise::repl 0.2
# Meta author   {Andreas Kupries}
# Meta location https://core.tcl.tk/akupries/linenoise-utilities
# Meta platform tcl
# Meta summary Object-oriented linenoise-based read-eval-print-loop.
# Meta description Base class for a linenoise-based read-eval-print-loop.
# Meta description Essentially an object-oriented equivalent of 'linenoise::cmdloop'
# Meta description provided by the core 'linenoise' package/binding. Customize
# Meta description the command loop by sub-classing.
# Meta subject {command loop} repl {read eval print loop} {command dispatcher}
# Meta subject linenoise {line editor} readline editline {edit line} tty console
# Meta subject terminal {read line} {line reader}
# Meta require {Tcl 8.5-}
# Meta require TclOO  
# Meta require {linenoise 1.1}
# Meta require oo::util
# @@ Meta End

# # ## ### ##### ######## ############# #####################
## Requisites

package require Tcl 8.5
package require TclOO
package require linenoise 1.1 ;# We need/use "linenoise history set"
package require oo::util

# # ## ### ##### ######## ############# #####################
## 

oo::class create ::linenoise::repl {
    # # ## ### ##### ######## #############
    ## Lifecycle

    constructor {} {
	set myhistory  0
	set myhentries {}
	return
    }

    # # ## ### ##### ######## #############
    ## Public APIs:
    # - history flag accessor (set|get).
    # - REPL

    method history {{thehistory {}}} {
	if {[llength [info level 0]] == 3} {
	    set myhistory $thehistory
	}
	return $myhistory
    }

    method history= {hentries} {
	# Load a list of history entries into the instance, for use by
	# the repl. Note that the history is loaded into linenoise
	# only when the repl is started.

	set myhentries $hentries
	return
    }

    method history? {} {
	return $myhentries
    }

    method repl {} {
	# Hidden input does not make sense for a command loop. But
	# save the current state (and restore it at the end), in case
	# this is nested with some other prompt.
	set savedhidden [linenoise hidden]

	# Notes on history handling:
	# - Before the prompt is made any existing history is saved
	#   and our history added.
	# - After the prompt our extended history is saved back to
	#   our instance and any previously existing history loaded back.
	#
	# These two complementary actions ensure that nested command lines
	# each have their own history without bleed-over 

	set run on
	while {$run && ![my exit]} {
	    set prompt [my prompt1]
	    set buffer {}
	    while 1 {
		linenoise hidden 0

		# Save preceding history, and swap in our own.
		set outerhistory [linenoise history list]
		linenoise history set $myhentries

		if {[catch {
		    # Inlined low-level command.
		    linenoise::Prompt $prompt [mymethod complete]
		} line]} {
		    # Stop not only the collection loop, but the outer
		    # prompt loop as well. Nothing is dispatched.
		    set run off
		    break
		}
		append buffer $line
		if {[my continued $buffer\n]} {
		    append buffer \n
		    set prompt [my prompt2]
		    continue
		}
		# Stop collection loop.
		break
	    }

	    if {!$run} break

	    # Save command.
	    if {$myhistory} {
		linenoise history add $buffer
		# Save back our modified history
		set myhentries [linenoise history list]
	    }
	    # Restore the outer history
	    linenoise history set $outerhistory

	    # Dispatch for execution.
	    set type fail
	    set fail [catch {
		set result [my dispatch $buffer]
		set type ok
		set result $result
	    } result]

	    # Report results.
	    my report $type $result
	}

	# Restore outer status of hidden
	linenoise hidden $savedhidden
	return
    }

    # # ## ### ##### ######## #############
    ## REPL hook methods. Override in sub-classes.

    method prompt1  {} { return "% " }
    method prompt2  {} { return "> " }
    method complete {line} {}

    method continued {line} {
	expr {![info complete $line]}
    }

    method dispatch {cmd} { uplevel 2 $cmd }

    method report {what data} {
	switch -exact -- $what {
	    ok {
		if {$data eq {}} return
		puts stdout $data
	    }
	    fail { puts stderr $data }
	    default {
		return -code error \
		    "Internal error, bad result type \"$what\", expected ok, or fail"
	    }
	}
    }

    method exit {} { return 0 }

    # # ## ### ##### ######## #############
    ## Boolean state flag. Record history or not. Default is not.

    variable myhistory myhentries

    ##
    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## ############# #####################
## Ready
package provide linenoise::repl 0.2
