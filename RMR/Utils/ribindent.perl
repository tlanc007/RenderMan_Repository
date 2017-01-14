#!/usr/local/bin/perl

# Will need to change line 1 if your perl location is different

########################################################################
###
###   This is a simple Perl script to indent a RenderMan .RIB file.
###   It reads the file and outputs the resulting formatted
###   text on STDOUT.
###
###   If for some reason you wish to use this with STDIN as in with pipes
###   use -.  ie. cat foo.rib | ribindent - >spam.rib
###
###   It uses a very simple algorithm:
###
###      Increase the indent level if the line contains 'Begin'
###
###      Decrease the indent level if the line contains 'End'
###
###
###   The width of the indentation can be altered by changing
###   $indent_string - this could be set to be a tab character for
###   example.
###
###   Author: Paul Blampied (ma2pab@bath.ac.uk)
###   Date  : 29/03/95
###
###   Any corrections/improvements welcomed...
###
###
###   MODIFIED: Tal Lancaster  4/10/95
#	Now reads in normal files rather than just STDIN.  If want to
#	read in STDIN: ribindent - ie. cat foo.rib | ribindent -
#	Also changed location of perl script on line 1.
###
########################################################################

$indent = 0;				# Initial indent level

$indent_string = "  ";			# String used for indentation



while (<>) {
   $line = $_;				# Read in line
   chop ($line);			# Remove newline char

   $next_indent = $indent;

   if ($line !~ /\#.*/) {		# Make sure the line is not a comment

      $line =~ s/^\s*(.*)/$1/;		# Strip leading whitespace

      if ($line =~ /.*Begin.*/) {	# If it contains 'Begin'
         $next_indent += 1;		# Indent a level
      }

      if ($line =~ /.*End.*/) {		# If line contains 'End'
         $next_indent -= 1;		# Unindent a level
         $indent -= 1;
      }

      print $indent_string x $indent;	# Output indentation
   }

   print "$line\n";			# Output the line

   $indent = $next_indent;		# Update the indent level
}


