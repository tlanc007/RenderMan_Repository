#!/usr/local/bin/perl
#Create a prman texture-map (by calling prman + using MakeTexture)
# If two arguments then the swrap,twrap, filterfunc, and swidth, twidth
# will use default values.  To find out more check out RC p. 256
#
#NOTE: the swrap/twrap and swidth/twidth parameters are assumed to be the same as their counter part.
#
# wrap -- periodic, clamp
# filter -- gaussian, catmull-rom, sinc, triangle, box
#
# Author: Tal Lancater (tal@cs.caltech.edu)
# Date: 6/22/95
#
# Usage: mktmap.pl src dst

$len = @ARGV;

if ($len != 2 && $len != 5) {
	print "Usage mktmap.pl sourceImage textureMap [wrap filter pixel]\n";
	exit 1;
}

#defaults for wrap filter and pixel
$Wrap="periodic";
$Filter="box";
$Pixel=2.0;

@myargs = reverse(@ARGV);
$src = pop(@myargs);
$dst = pop(@myargs);

if ($len == 5) {
	$wrap = pop(@myargs);
	$filter = pop(@myargs);
	$pixel = pop(@myargs);
}
else {
# Must be just the source and destination files
# use defaults
	$wrap = $Wrap;
	$filter = $Filter;
	$pixel=$Pixel;
}
$tmpName = "mk" . time . ".rib";

open(tmpfile, ">$tmpName");

#try addint 3 more params periodic box pixels
#Create RIB file
print (tmpfile "MakeTexture \"$src\" \"$dst\" \"$wrap\" \"$wrap\" \"$filter\" $pixel $pixel\n");
close(tmpfile);

#Call prman to create the texturefile.

print "Creating texture map $dst from image $src\n";
system "prman $tmpName";
unlink $tmpName;

 