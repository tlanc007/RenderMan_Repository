#!/usr/bin/perl

$tmp = 'tmp';
foreach $f (<*.rib>) {
  open (IN, $f);
  open (OUT, ">$tmp");

  $found = 0;
  while (<IN>) {
    if (/KMStarfield/) {
      s/KMStarfield/LGStarfield/;
      $found = 1;
    }
    print OUT $_;
    
  }
  close IN;
  close OUT;
  if ($found) {
    print "found KMStarfield chaning $f\n";
    unlink $f;
    rename ($tmp, $f);
  }
}
