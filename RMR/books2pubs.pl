#!/usr/bin/perl

# go through RMR and change Books to Publications/Pubs

push (@INC, '/home/tal/perl');
require "f_dirs.pl";

$tmpHTML = "/tmp/tmp.html";

&findHTMLs ('.');

sub findHTMLs {
  local ($cdir) = @_;
  local ($htmlTitle, $f, $ffile);
  local (@files, @newDirs);
  local ($foundBooks);

  @files = &getfiles ($cdir);
  @files = reverse (&removeLinks ($cdir, @files));
  #print "@files\n";
  #exit 1;
  foreach $f (@files) {
      next if ($f =~ /CVS/);

    $ffile = "$cdir/$f";
    if (-d $ffile) {
      push (@newDirs, $ffile);
    }
    elsif ($ffile =~ /\.html$/) {
	open (IN, $ffile);
	open (OUT, ">$tmpHTML");
	print "Opening $ffile\n";
	$foundBooks = 0;

	while (<IN>) {
	    if (m|href="/RMR/Books/index.html">Books</a>|) {
		s|/Books/|/Publications/|;
		s|>Books<|>Pubs<|;
		#$_ = q|<td><a CLASS="none" href="/RMR/Publications/index.html">Pubs</a></td>\n|;
		print "$ffile:   $_\n";
		$foundBooks = 1;
	    }
	    if (/Books/) {
		print "Still found : $_\n";
	    }

	    if ($foundBooks && /copyright.html/) {
		s/\-+/\-/;
		s/(1995\-)(\d\d\d\d)/${1}2005/;		
		#print "\nFound copyright: $_\n";
	    }
	    print OUT $_;

	}
	close IN;
	close OUT;

	if ($foundBooks) {
	    #ok file actually changed, so overwrite
	    system ("mv $tmpHTML $ffile");
	}
    }
  }
  foreach $f (@newDirs) {
    &findHTMLs ($f);
  }
}
