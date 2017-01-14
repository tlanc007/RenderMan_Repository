#!/usr/bin/perl

########################################################################
# bobjxpand
#  This is lifted from Larry's (lg@pixar.com) objxpand script.  This one
#  is much more dangerous, in that it will overwrite the orginal file.
#  What it does do is expand a group of files.
#
# Its purpose is to eliminate Object Instancing by expanding the object 
# definitions into the main part of the RIB stream.
#
# Example usage:
#
#          bobjxpand GROUP_OF_RIBS  -- overwrites orginal files!
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
#  orig objxpand -- Written by Larry Gritz, gritzl@acm.com, 1995.
#
# objxpand last updated 11 Aug 1995
#
# bobjxpand -- butchered by Tal Lancaster tal@cs.calteche.du 1998
########################################################################


# $state is 0 when echoing, 1 when inside an Object definition block.
$state = 0;

# debug prints some debugging info that I used when writing this script.
$debug = 0;

# $curobj indicates the object we're defining when state is 1
$curobj = 0;

$tfile = "bobj_xpand_$$";
foreach $f (@ARGV) {
  print "Expanding ObjInstance for $f\n";

  open (IN, $f);
  close (OUT, ">$tfile");

while (<IN>) {

    if ($state == 1) {    # we're inside an object block
        # if we hit ObjectEnd, change state, otherwise catenate it to
        # the current object definition.
        if (/ObjectEnd/) {
            $state = 0;
            print OUT "\t<ObjectEnd>\n" if ($debug);
        } else {
            $objects{$curobj} .= $_;
        }
    } else {  # we're not currently inside an object block
        # if this is an ObjectBegin, change state
        if (/ObjectBegin\s+(\d+)/) {
            # we matched ObjectBegin
            $curobj = $1;
            $state = 1;
            print OUT "\t<ObjectBegin: $curobj>\n" if ($debug);
        } elsif (/ObjectInstance\s+(\d+)/) {
            print OUT "\t<ObjectInstance: $1>\n" if ($debug);
            print OUT $objects{$1};
        } else {
            print OUT $_;
        }
    }
}
close IN;
close OUT;
rename ($tfile, $f);
# we're done!
}

