#!/usr/local/bin/perl


$outfile = "taltmp";

foreach $f (@ARGV) {
    $origfile = $f;
    $infile = $f."/index.html";

	$pos = 0;
	$oldpos = $pos;
	$count = 0;
	while ($pos != -1) {
		$pos = index ($infile, "/", $pos);
		if ($pos != -1) {
			$count++;
			$oldpos = $pos;
			$pos += 1;
		}
	}
	$level = $count;		
    print "$infile\n";
    open(OUT, ">taltmp");
    open(IN, $infile);

    if ($f  =~ /^(.*)\.htmld/) {
	$fname = $1;
	$pos = rindex($fname, "/");
#	if ($pos > 0) {
#	    $pos++;
#	}
	$newstr = substr ($fname, $pos+1);
	$action = $track{$newstr};
    }
#    print "fname $fname pos $pos newstr $newstr action $action.\n";

	$background = "gifs/WhitePaper.gif";
	for ($count = 0; $count < $level; $count++) {
		$background = "../" . $background;
	}
	print "Using BACKGROUND $background\n";
	
    while (<IN>) {		
	s^<BODY.*>^<BODY background="$background">^;
	print OUT $_;
    }
    close IN;
    close OUT;

#    rename ($outfile, $infile);
}
