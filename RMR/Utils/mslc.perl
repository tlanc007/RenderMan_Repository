#!/usr/local/bin/perl
# NOTE: You may need to change the first line depending where perl
# has been installed

# Author: Tal Lancaster tal@cs.caltech.edu
# Creation Date: 3/22/95
# Usage: mslc filename ... 
# mslc --(Manyslc) Perl script to do multiple shader complies with BMRT's slc
# Will take a list of shaders to compile
#

foreach (@ARGV) {
	system("slc $_");
}
