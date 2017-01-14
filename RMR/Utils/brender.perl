#!/usr/bin/perl

# brender.pl  
#
# A simple batch render script to render a set of RIBS.
#
# Usage: brender.pl FS FE BASENAME 
#
#  FS -- frame start ie. 1
#  FE -- frame end  ie. 100
#  BASENAME -- prefix for RIB sequence
#
# ex.  brender.pl 1 30 myanim
#
# will look for RIBS myanim.0001.rib - myanim.0039.rib to render.
# 
# You will need to set which render and options to use before starting
# the script.
#
# Culpret: Tal Lancaster tal@cs.caltech.edu 1998
#

if (@ARGV != 3) {
	print "Renders a sequence of frames -- myanim.0012.rib\n";
	die "Usage: $0 FS FE BASENAME\n";
}

$fs = shift (@ARGV);
$fe = shift (@ARGV);
$base = shift (@ARGV);

print "$base:$fs $fe\n";
for ($i=$fs; $i <= $fe;  $i++) {
  $file = sprintf ("%s.%04.0d.rib", $base, $i);
  print "Rendering $file\n";
  $command = "render $file";
#  $command = "rendrib -var .01 2  16 -safe $file";

  system ($command);
#  $command = "rm *.z";
#  system ($command);
}
