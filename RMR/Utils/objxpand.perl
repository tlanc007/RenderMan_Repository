#!/usr/bin/perl

########################################################################
# objxpand
#
# This script reads RIB from stdin and writes to stdout.  Its purpose
# is to eliminate Object Instancing by expanding the object definitions
# into the main part of the RIB stream.
#
# Example usage:
#
#          objxpand <objinst.rib >noobjinst.rib
#
# It works by mostly echoing the RIB.  When it sees an Object block,
# it records the object definition in the associative array %objects.
# When it sees an ObjectInstance, it outputs the stored definition
# instead of the ObjectInstance line.
#
# Important limitations:
#    1. It assumes that all ObjectInstances will have corresponding
#       Object definitions for that object tag number.
#    2. It assumes that ObjectBegin, ObjectEnd, and ObjectInstance
#       statements are the only RIB on those lines in the input file.
#       For example, the folling input line would lose the sphere:
#               ObjectInstance 5 Sphere 1 -1 1 360
#       But the following two lines would work fine:
#               ObjectInstance 5
#               Sphere ...
#
# Written by Larry Gritz, gritzl@acm.com, 1995.
#
# last updated 11 Aug 1995
########################################################################


# $state is 0 when echoing, 1 when inside an Object definition block.
$state = 0;

# debug prints some debugging info that I used when writing this script.
$debug = 0;

# $curobj indicates the object we're defining when state is 1
$curobj = 0;


$inputline = <STDIN>;
while ($inputline) {

    if ($state == 1) {    # we're inside an object block
        # if we hit ObjectEnd, change state, otherwise catenate it to
        # the current object definition.
        if ($inputline =~ /ObjectEnd/) {
            $state = 0;
            print "\t<ObjectEnd>\n" if ($debug);
        } else {
            $objects{$curobj} .= $inputline;
        }
    } else {  # we're not currently inside an object block
        # if this is an ObjectBegin, change state
        if ($inputline =~ /ObjectBegin\s+(\d+)/) {
            # we matched ObjectBegin
            $curobj = $1;
            $state = 1;
            print "\t<ObjectBegin: $curobj>\n" if ($debug);
        } elsif ($inputline =~ /ObjectInstance\s+(\d+)/) {
            print "\t<ObjectInstance: $1>\n" if ($debug);
            print $objects{$1};
        } else {
            print $inputline;
        }
    }

    # get the next line of input and continue
    $inputline = <STDIN>;
}

# we're done!
