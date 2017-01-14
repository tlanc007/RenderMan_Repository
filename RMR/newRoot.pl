#!/usr/bin/perl

#go through RMR and fix root in html files 5/22/03

#push (@INC, '/home/tal/bin');
#require "f_dirs.pl";

$new = "newroot.html";
$oldRoot = '/renderman.org/RMR';
$newRoot = '/RMR';

&findHTMLs ('.');

sub findHTMLs {
  local ($cdir) = @_;
  local ($htmlTitle, $f, $ffile);
  local (@files, @newDirs);

  @files = &getfiles ($cdir);
  @files = reverse (&removeLinks ($cdir, @files));
  #print "@files\n";
  #exit 1;
  foreach $f (@files) {
    #next if ($f =~ /$emitFile/);
    #next if ($f =~ /navtable.html/);
    #next if ($f =~ /site_index.html/);
    #next if ($f =~ /rmrTable.html/);

    $ffile = "$cdir/$f";
    if (-d $ffile) {
      push (@newDirs, $ffile);
    }
    elsif ($ffile =~ /\.html$/) {
      print "$ffile\n";
      open (IN, $ffile);
      open (OUT, ">$new");

      print "File: $ffile\n";

      while (<IN>) {
	if (/href\=\"$oldRoot/i) {
	  s/(href=\")$oldRoot/$1$newRoot/i;
	}
	if (/\"$oldRoot\//) {
	  s/(\")$oldRoot\//$1$newRoot\//g;
        }
	if (/copyright.html/) {
		s/\-+/\-/;
	  s/(1995\-)(\d\d\d\d)/${1}2005/;
	}
        print OUT $_;	  
      }
      close IN;
      close OUT;
      #exit 1;
    `rm -f $ffile`;
    rename ($new, $ffile);
    }
  }
  foreach $f (@newDirs) {
    &findHTMLs ($f);
  }
}


sub do_copyright {
    print OUT "<HR><small>\n";
    print OUT "<P><I>\n";
    print OUT qq|The RMR is <A HREF="\/RMR\/copyright.html">Copyright<\/A> &copy; 1995-2005 <A HREF="mailto:tal AT renderman DOT org">Tal L. Lancaster<\/A> all rights reserved<\/I><\/P><\/small>\n|;
}
  
sub countLevels {
  local ($f) = @_;
  local ($levels);
  local ($start, $path);

  #from buildShader.html
  $levels = 0;
  $start = length ($f);
  while (($start = rindex ($f, '/', $start)) >= $[) {
    $levels++;
    $start--;
  }
  #print "$levels:$f\n";
  return $levels;
}

#
# getfiles ('.')  -- returns a list of files found at the current dir (or
#   whereever the directory parameter points to.  The function will die if
#   it can't open the directory.
#
sub getfiles {
  local ($dir) = @_;
  local (@files);

  opendir (DIR, $dir) || die "Unable to open dir: $dir\n";
  @files = readdir (DIR);
  closedir (DIR);
  # don't want . and ..
  ##shift (@files);
  ##shift (@files);
  return @files;
}

#
# removeLinks (CURDIR, @FILES) -- Goes through the list of files (@FILES) and
#   removes symbolic links, '.', and '..' from the list.  The first parameter
#   CURDIR is the directory in which the @FILES list exists.  The function
#   returns a new list without symbolic-links, '.', or '..'
#
sub removeLinks {
  local ($dir, @files) = @_;
  local (@result, $i, $subdir, $f);

  for ($i = 0; $i < @files; $i++) {
    $f = $files[$i];
    $subdir = "$dir/$f";
    next if (-l $subdir || $f eq '.' || $f eq '..');

    unshift (@result, $f);
  }
  return (@result);
}
