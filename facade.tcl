## -*- tcl -*-
# # ## ### ##### ######## ############# #####################
## Linenoise OO REPL facade class (delegation).

# @@ Meta Begin
# Package linenoise::facade 0
# Meta author   {Andreas Kupries}
# Meta location https://core.tcl.tk/akupries/linenoise-utilities
# Meta platform tcl
# Meta summary Delegation-based linenoise-based read-eval-print-loop.
# Meta description Sub-class of 'linenoise::repl' enabling customization
# Meta description by delegation.
# Meta subject {command loop} repl {read eval print loop} {command dispatcher}
# Meta subject linenoise {line editor} readline editline {edit line} tty console
# Meta subject terminal {read line} {line reader}
# Meta require {Tcl 8.5-}
# Meta require TclOO  
# Meta require linenoise::repl
# @@ Meta End

# # ## ### ##### ######## ############# #####################
## Requisites

package require Tcl 8.5
package require TclOO
package require linenoise::repl

# # ## ### ##### ######## ############# #####################
##

oo::class create ::linenoise::facade {
    superclass linenoise::repl
    # # ## ### ##### ######## #############
    ## Lifecycle

    constructor {actor} {
	set myactor $actor
	next
	return
    }

    # # ## ### ##### ######## #############
    ## REPL hook methods.
    ## We override the base class implementations to delegate them to
    ## the chosen actor.

    # TclOO forward'ing usable for this ?

    method prompt1   {}          { $myactor prompt1 }
    method prompt2   {}          { $myactor prompt2 }
    method complete  {line}      { $myactor complete $line }
    method continued {line}      { $myactor continued $line }
    method dispatch  {cmd}       { $myactor dispatch $cmd }
    method report    {what data} { $myactor report $what $data }
    method exit      {}          { $myactor exit }

    # # ## ### ##### ######## #############
    ## Instance command of the object the facade delegates the REPL
    ## hooks to.

    variable myactor

    ##
    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## ############# #####################
## Ready
package provide linenoise::facade 0.1
