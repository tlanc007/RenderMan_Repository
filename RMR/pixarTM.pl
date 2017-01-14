#!/usr/bin/perl

#go through RMR and find html files 

&pixarTM ('.');
exit 1;


sub pixarTM {
  local ($cdir) = @_;
  local ($f, $ff, @newDirs);
  local ($dir);
  local (@files, @tempFiles);

  @newDirs = ();
  @tempFiles = ();

  print "cdir $cdir\n";
  chdir ($cdir) || die "Unable to cd to $cdir\n";
  my (@tempFiles) = &getfiles ('.');
  #my (@files) = ('index.html');
  @files = reverse (&removeLinks ($cdir, @tempFiles));
  foreach $f (@files) {
    $ff = $f; #"$cdir/$f";
    next if ($ff =~ /CVS|Pics|pixarTM.pl|pixarTM.pl\~|nav|search/);
    if (-e $ff && -d $ff) {
      next if ($ff =~ /CVS|Pics|pixarTM.pl|nav|search/);
      push (@newDirs, $ff);
    }
    elsif ($ff =~ /\.html$/) {
      print "Processing: $ff\n";
      &processFile ($ff);
    }
  }

  print "dirs @newDirs\n";

  foreach $dir (@newDirs) {
    &pixarTM ($dir)  if (-d $dir);
  }
  chdir ('..');
}

sub processFile {
  my ($f) = @_;
  my ($tmp) = "${f}_tmp";
  my ($afterBody) = 0;
  my ($usedRM) = 0;


  open (IN, $f) || die "Unable to open $f\n";
  open (OUT, ">$tmp") || die "Unable to open $tmp\n";

  while (<IN>) {
    if (/\<BODY/) {
      $afterBody = 1;
    }
    elsif (/CONTENT/) {
    }
    elsif (/RenderMan Repository|RenderMan\-/) {
      ;
    }
    elsif (/\s+RenderMan\s+|^RenderMan\s+|\s+RenderMan\.|\s+RenderMan\?/) {
      $usedRM = 1;
      s/RenderMan/<a href="#pixarTM">RenderMan®<\/a>/g;
    }
    elsif (/The RMR .+copyright/ && $usedRM) {
      print OUT qq|<A NAME="pixarTM"></A>\n|;
      print OUT "<h3>RenderMan is a registered trademark of Pixar</h3>.\n<p>\n";      
    }
    print OUT $_;
  }
  
  close IN;
  close OUT;

  if ($usedRM) {
    system ("rm $f");
    system ("mv $tmp $f");
  }
  else {
    system ("rm $tmp");
  }
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
