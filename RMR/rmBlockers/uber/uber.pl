#!/usr/bin/perl

open (IN, "index.html");
open (OUT, ">temp.html");

while (<IN>) {
  if (/^<A HREF=\"(fig\d+)\.tiff/) {
    $base = $1;
    print OUT qq!<HR>\n<A NAME="$base"></A>\n!;
    print OUT qq!<H3>$base</H3>\n!;
  }
  elsif (/^<A HREF=\"(fig\d+.)\.tiff/) {
    $base = $1;
    print OUT qq!<HR>\n<A NAME="$base"></A>\n!;
    print OUT qq!<H3>$base</H3>\n!;
  }
  print OUT $_;
}
