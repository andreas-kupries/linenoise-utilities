## -*- tcl -*-
# # ## ### ##### ######## ############# #####################
## Linenoise OO REPL facade class (delegation, multiple targets).

# # ## ### ##### ######## ############# #####################
## Requisites

package require Tcl 8.5
package require TclOO
package require linenoise::repl

# # ## ### ##### ######## ############# #####################
##

oo::class create ::linenoise::mfacade {
    superclass linenoise::repl
    # # ## ### ##### ######## #############
    ## Lifecycle

    constructor {args} {
	set myactors $args
	return
    }

    # Add remove actors at runtime ?

    # # ## ### ##### ######## #############
    ## REPL hook methods.
    ## We override the base class implementations to delegate them to
    ## the chosen actor.

    method prompt1 {} {
	foreach a $myactors {
	    set p [$a prompt1]
	    if {$p ne {}} { return $p }
	}
	return "% "
    }

    method prompt2 {} {
	foreach a $myactors {
	    set p [$a prompt2]
	    if {$p ne {}} { return $p }
	}
	return "% "
    }

    method complete  {line}      {
	set completions {}
	foreach a $myactors {
	    lappend completions {*}[$a complete $line]
	}
	return $completions
    }

    method continued {line} {
	foreach a $myactors {
	    if {[$a continued]} { return 1 }
	}
	return 0
    }

    method dispatch {cmd} {
	set errors {}
	foreach a $myactors {
	    if {![catch {
		$a dispatch $cmd
	    } r]} {
		return $r
	    }
	    lappend errors $r
	}
	return -code error [join $errors \n]
    }

    method report {what data} {
	foreach a $myactors {
	    $a report $what $data
	}
	return
    }

    method exit {} {
	foreach a $myactors {
	    if {[$a exit]} { return 1 }
	}
	return 0
    }

    # # ## ### ##### ######## #############
    ## Instance command of the object the facade delegates the REPL
    ## hooks to.

    variable myactors

    ##
    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## ############# #####################
## Ready
package provide linenoise::mfacade 0.1
