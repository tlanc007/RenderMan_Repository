#!/usr/bin/perl

#go through RMR and find html files to build index page 6/14/99

#push (@INC, '/home/tal/bin');
#require "f_dirs.pl";
 
$page = "RMR Site Index";
$emitFile = "site_index.html";
$styleFile = "/RMR/nav.css";
#$navTableFile = "/RMR/navtable.html";
$navTableFile = "navtable.html";

open (IN, $navTableFile);
@navTable = <IN>;
close (IN);

&findHTMLs ('.');
&printTitles ();


sub findHTMLs {
  local ($cdir) = @_;
  local ($htmlTitle, $f, $ffile);
  local (@files, @newDirs);

  @files = &getfiles ($cdir);
  @files = reverse (&removeLinks ($cdir, @files));
  #print "@files\n";
  #exit 1;
  foreach $f (@files) {
    next if ($f =~ /$emitFile/);
    next if ($f =~ /navtable.html/);
    next if ($f =~ /site_index.html/);
    next if ($f =~ /rmrTable.html/);

    $ffile = "$cdir/$f";
    if (-d $ffile) {
      push (@newDirs, $ffile);
    }
    elsif ($ffile =~ /\.html$/) {
      push (@htmlFiles, $ffile);
      $htmlTitle = &getTitle ($ffile);
      push (@titles, $htmlTitle);
    }
  }
  foreach $f (@newDirs) {
    &findHTMLs ($f);
  }
}

sub getTitle {
  local ($file) = @_;
  local ($title, $go);

  $go = 1;
  open (IN, $file);
  while (<IN>) {
    if (/\<title\>(.*)$/i) {
      $title = $1;
      #print "$title\n";
      if ($title ne "" && $title =~ /\w+/) {
	#got a title
	#print "$title\n";
	if ($title =~ /^(.+)\<\/title\>/i) {
	  $title = $1;
	  #print "$title|\n";
	  $go = 0;
	}
      }
      else {
	while ($go && ($_ = <IN>)) {
	  if (/(.*)\<\/title\>/i) {
	    $title .= $1;
	    $go = 0;
	  }
	  else {
	    $title .= $_;
	  }
	}
      }
    }
  }
  close IN;
  return $title;
}

sub printTitles {
  local ($i);

  open (OUT, ">$emitFile");

  print OUT "<html>\n";
  print OUT "<head>\n";
  print OUT qq|<LINK rel="stylesheet" type="text/css" href="$styleFile" title="navtitle">\n|;
  print OUT "<title>$page</title>\n";
  print OUT qq|<body bgcolor="white">\n|;
  print OUT "@navTable";

  print OUT "<center><h1>$page</h1></center>\n";
  print OUT "<pre><h3>\n";
  for $i (0..$#htmlFiles) {
#    print "$htmlFiles[$i]: $titles[$i]\n";
    $hfile = $htmlFiles[$i];
    $levels = &countLevels ($hfile);
    for $i (0..$levels) {
      print OUT "\t";
    }
    print OUT qq|<A HREF="$htmlFiles[$i]">$titles[$i]</A>\n|;
  }
  print OUT "</h3></pre>";
  &do_copyright;

  print OUT "</body>\n</html>\n";
  close OUT;
}

sub do_copyright {
    print OUT "<HR><small>\n";
    print OUT "<P><I>\n";
    print OUT qq|The RMR is <A HREF="\/RMR\/copyright.html">Copyright<\/A> &copy; 1995-2005 <A HREF="mailto:tal @ renderman DOT org">Tal L. Lancaster<\/A> all rights reserved<\/I><\/P><\/small>\n|;
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
