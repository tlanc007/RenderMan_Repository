#!/usr/bin/perl

open (IN, "i.html");
open (OUT, ">fi.html");

while (<IN>) {
  if (/\<A NAME="Renderers"/) {
    &formatLinks
  }
  else {
    print OUT $_;
  }
}

close IN;
close OUT;

sub formatLinks {
  while (<IN>) {
    #  if (/^(\<A HREF.+\<\/A\>)(.+\<P\>)/i) {
    if (/<IMG/) {
      #image leave alone
      print OUT $_;
    }
    elsif (/\<A HREF/i) {
      ($left, $right, @rest) = split ('</A>|</a>', $_);
      #print "${left}</A>-->$right\n";
      if ($right =~ /^<A HREF/i) {
	$right .= '</A>';
      }
      $right =~ s/(<p>)/<\/dd>$1/;
      print OUT "<dt><br>${left}</A>\n<dd>$right\n";
      print "rest: @rest\n" if (@rest);
      foreach $elem (@rest) {
	$elem =~ s/(<p>)/<\/dd>$1/;
	$elem .= "</a>";
	print "$elem";
      }
      undef @rest;
    }
    else {
      #print "$_:  Didn't match\n";
      print OUT $_;
    }
    #exit 1 if (/Iverson/);
  }
}
