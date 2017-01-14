#
# Simplified [wPrefix]
#
#
# when $SHOTINFO is not empty, it will contain the prefix of the currently-executing
#    referenced shotinfo.tcl attribute, if such shotinfo commands are executing.
#
global SHOTINFO
set SHOTINFO ""

#
# does the current scene have the named node?
#
proc has_node { nodeName } {
    if {"$nodeName" == ""} {
	return 0
    }
    if {[catch {set fnd [mel "objExists $nodeName"]} msg]} {
	sqLog Problem with $nodeName msg $msg
	return 0
    }
    return $fnd
}


#
# get prefix from $OBJPATH and attach to coordsys names
#
# nodeName - original name
# args - optional list of prefered prefixes, to permit
#	multiple referencing of a shared coordsys
#
proc wPrefix { nodeName args } {
    global OBJPATH SHOTINFO
    #
    # If we are executing within a Glimpse palette, Maya nodes are invisible,
    #   so just return the node name
    #
    if {("$nodeName" == "world") ||
	("$nodeName" == "glimpse")||
	("$nodeName" == "")||
	("$OBJPATH" == "glimpse")||
	("$OBJPATH" == "world")||
	("$OBJPATH" == "")} {
	    return $nodeName
    }
    #
    # if name is already valid node, do nothing
    #
    if {[has_node $nodeName]} {
	return $nodeName
    }
    #
    # See if the prefered prefixes (if any) are existing Maya namespaces
    #
    regsub -all {[\{\}]} $args "" aa
    foreach path [split $aa] {
	set qualified "${path}:$nodeName"
	if {[has_node $qualified]} {
	    return $qualified
	}
	set qualified "${path}_$nodeName"
	if {[has_node $qualified]} {
	    return $qualified
	}
    }
    set path {}
    #
    # see if we are executing a referenced file's shotinfo data
    #
    if {"$SHOTINFO" != ""} {
	set qualified "${SHOTINFO}:$nodeName"
	if {[has_node $qualified]} {
	    return $qualified
	}
	set qualified "${SHOTINFO}_$nodeName"
	if {[has_node $qualified]} {
	    return $qualified
	}
    }
    if {[string first "|" $OBJPATH] < 0 } {
	#
	# rare case -- no "|" in the name
	#
	if {[regsub {([^:]+):.*} $OBJPATH {\1} path] < 1 } {
	    # no namespace, maybe a prefix
	    if {[regsub {([^_]+)_.*} $OBJPATH {\1} path] < 1 } {
		return $nodeName
	    }
	} else {
	    # found a namespace
	    return "${path}:$nodeName"
	}
    } else {
	#
	# if there's no prefix in the current $OBJPATH, do nothing
	#
	set q [string range $OBJPATH [string last "|" $OBJPATH] end]
	if {[regsub {\|([^:]+):.*} $q {\1} path] < 1 } {
	    # no namespace, maybe a prefix
	    if {[regsub {\|([^_]+)_.*} $q {\1} path] < 1 } {
		return $nodeName
	    }
	} else {
	    # found a namespace
	    return "${path}:$nodeName"
	}
    }
    # tried everything else....
    return ${path}_$nodeName
}



