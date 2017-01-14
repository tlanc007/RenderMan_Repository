#!/usr/bin/perl

#$names {'l1'} = 1;
#$names {'l2'} = 2;

#@v1 = keys (%names);

sub Note1 {
print qq|<B>NOTE:This page has been HTMLified for the RMR.  It is based off of the CGRR FAQ, which is still maintained by <A HREF="mailto:lg\@pixar.com">Larry Gritz</A>.  As such this version may be out of date or contain typos and other formating problems.  If in doubt check in the <A HREF="http://www.bmrt.org/cgr.renderman.faq">offical FAQ</A>, \n|;
print qq|Please do not bother Larry with problems that you find in this version of the document.  If there is a difference between them, let me know and I will try and fix it. --  <A HREF="mailto:talrmr\@pacbell.net">Tal Lancaster</A>\n</B>|;

}

print "<HTML>\n<HEAD>\n<TITLE>CGRR FAQ</TITLE>\n</HEAD>\n";
print "<!-- Built with faq2html.pl Tal Lancaster -->\n";
print qq|<BODY bgcolor="#ffffff">\n|;
&Note1;
print qq|<PRE>\n|;

print "<CENTER><H1>\ncomp.graphics.rendering.renderman FAQ\n</H1></CENTER>\n";

#...

$qcount = 1;
$inContents = 0;
$inTopList = 0;
$inList = 0;
$preContents = 1;
$firstAnswer = 1;
$newSection = 0;
#$newFontColorStart = qq|<font color="mediumspringgreen">|;
#$newFontColorStart = qq|<font color="teal">|;
#$newFontColorStart = qq|<font color="red">|;
$newFontColorStart = qq|<font color="#FF9900">|;

while (<>) {


  if (/(^Contents: )\(\* (indicate.+)/) {
    print "</PRE>\n";
    $inContents++;
    $preContents = 0;

    $_ = "(${newFontColorStart}this color</font> $2";
#    s/\)//;
    print "<CENTER><H3>$1<BR>\n";
    print $_;
    print "</H3></CENTER>\n";
    next;
  }

  if ($preContents) {
    #top Section before contents
    s|(^.+:)|<I>$1</I>|;
    s|(news-answers-request\@MIT.EDU)|<A HREF="mailto:$1">$1</A>|;
    s!(comp.graphics.rendering.renderman|comp.answers|news.answers\s)!<A HREF="news:$1">$1</A>!g;
    print $_;
    next;
  }

  if ($inContents) {
    if (/^Administrivia:/) {
      # start of mail list
      $inTopList++;
      print "<OL type=I>\n";
      print "<LI>$_";
      print "<OL start=$qcount>\n";
      next;
    }
    if ($inTopList) {
      if (/ +(Q:.+$)/) {
	chop;  # hope last char was \n
	$head = $1;
	if (/^\* /) {
	  # new section
	  $newSection = 1;
	}
	$_ = $head;
	if (!/\?$/) {
	  #question is on multiple lines
	  #hack only handles one more line
	  $_ .= <>;
	  if (m|/ How can PRMan do reflections if it|) {
	    #question is formated different than answer section reformat
	    s| / |  |g;
#	    print STDERR "___$_ ____\n";
	  }
	}
	if (m|Macintosh/DOS/Window|) {
	  #another hack right now lg has another question on next line
          #that is a part of this one.
	  chop;
	  $_ .= <>;
	  print STDERR " --- $_ ---\n";
	}
	if (m|in Toy Story|) {
	  #another hack right now lg has another question on next line
          #that is a part of this one.
	  chop;
	  $_ .= <>;
	  print STDERR " --- $_ ---\n";
	}
	if (m|When I try|) {
	  #another hack right now lg has another question on next line
          #that is a part of this one.
	  chop;
	  $_ .= <>;
	  print STDERR " --- $_ ---\n";
	}


#	chop;  #assuming last char was \n
	if ($newSection) {
	  print "$newFontColorStart";
	}
	print qq|<LI><A HREF="#$qcount">|;
	print qq|$_</A>|;
	if ($newSection) {
	  print "</font>\n";
	  $newSection = 0;
	}
	$len = length ($_);
	$end = ($len < 30)? $len: 30;
	$names {substr ($_, 0, $end)} = $qcount++;
	$key = substr ($_, 0, $end);
	$val = $names {$key};
	print STDERR "$key:$len:$val\n";
      }
      elsif (/Nomenclature:/) {
	$inContents--;
	print "</OL>\n";
	print "<PRE>\n\n$_";
	while (<>) {
	  # keep going until next section
	  if (/=======/) {
	    print "</PRE>\n";
	    print "<BR>\n<HR>\n";
	    last;
	  }
	  print $_;
	}
      }
      elsif (/:/) {
	#another section
	print "</OL>\n";
	print "<LI>$_";
	print "<OL start=$qcount>\n";
      }
      else {
	print $_;
      }
    }
  }
  else {
    if (/^Q:/) {
      # join up lines until ----
      chop;
      $orig = $_;
      while (<>) {
	if (/-----/) {
	  if ($orig =~ /to call my software \"RenderMan/) {
	    #hack because this question doesn't follow the pattern
	    $_ = <>;  #assuming new line is 'compliant'
	    chop;
	    $orig .= " $_";
	    <>;  # should be '-----'
	  }
	  $_ = $orig;
	  $len = length ($orig);
	  $end = ($len < 30)? $len: 30;
	  $name = $names { substr ($orig, 0, $end)};
	  $key =  substr ($orig, 0, $end);
	  print STDERR "$key:$len:$name\n";
	  if (!$firstAnswer) {
	    #Don't want a header for the first question as there already
	    #is one.
	    $firstAnswer = 0;
	    print "<HR width=50%>\n";
	  }
	  print qq|<A NAME="$name"></A>\n|;
	  print "<H4>$orig</H4>\n";
#	  print "<H4>$name\-\-$orig</H4>\n";
	  print "<PRE>\n";
	  last;
	}
	else {
	  #merge up
	  chop;
	  $orig .= $_;
	}
      }
    }
    else {
      #regular
      #check for html
      chop;
      if (/(.*)(http:|ftp:)(\S+)(.*$)/) {
	$link = $_;
#	print STDERR "$1:$2:$3:$4:\n";
	$_ = qq|$1\<A HREF="$2$3"\>$2$3\<\/A\>$4|;
      }
	  elsif (/(.*)(www\.dejanews\.com)(.*)/) {
	    #assuming web link
#	    print STDERR "\n\n>>>>$1:$2:$2\n";
	    $_ = sprintf (qq!%s<A HREF="http://%s">%s</A>%s\n!,
			  $1, $2, $2, $3);
#	    print STDERR ">>>>$_";
	  }
	  elsif (/(.*)(www\.sidefx\.com)(.*)/) {
	    #assuming web link 
	    $_ = sprintf (qq|%s<A HREF="http://%s">%s</A>%s\n|,
			  $1, $2, $2, $3);
	  }
	  else {
	    s!(RI|RC|SL|PRMan|BMRT)!<B>$1</B>!;

	  }
      
	  
      print "$_ \n";
    }
  }
}
	  
	
print "</PRE><HR>\n";  
&Note1;
print "<P><I>\n";
print q|The RMR is <A HREF="/copyright.html">Copyright</A> &copy; 1995-1999 <A HREF="mailto:talrmr@pacbell.net">Tal L. Lancaster</A> all rights reserved</I></P></small>|;

print "\n</BODY>\n</HTML>\n";
