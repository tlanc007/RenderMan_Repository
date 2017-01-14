#!/usr/bin/perl

#assume run from RMR

chdir ("Shaders") || die ("can't cd to Shaders/");

$talMail = 'tal AT renderman DOT org';
@surface = ();
@displacement = ();
@light = ();
@imager = ();
@volume = ();

($dev, $ino, $mode, $nlink) = stat ('.');
&findAndGroupShaders ('.', $nlink);
#print "main: surface @surface\n";
&createHTMLFiles;
exit 0;

###############
sub findAndGroupShaders {
    local ($dir, $nlink) = @_;
    local ($dev, $ino, $mode, $time);

    opendir (DIR, $dir) || die "Can't open $dir";
    local (@filenames) = readdir (DIR);
    closedir (DIR);
    local (@subdirs);

    foreach (@filenames) {
	next if /^bk|^bak/;

	($dev, $ino, $mode, $nl, $vid, $gid, $rdev,
	 $size, $atime, $mtime, $etime) = stat ("$dir/$_");

	$fullname = "$dir/$_";
	$t1 = -f $fullname;
	$d1 = -d $fullname;
#	print "$dir/$_\n:$t1:$d1\n";
	if (-d _) { #directory
	    push (@subdirs, $_);
	}
	elsif (-f _ && /.sl$/) { # shader file
#	    print "findAndGroupShaders: calling searchShader\n";
	    &searchShader ($dir, "$_");
	}
	else {
	    # print STDERR ;
	}
    }
    if ($nlink != 2) { #has subdirs
	foreach (@subdirs) {
	    next if $_ eq '.';
	    next if $_ eq '..';
	    
	    $name = "$dir/$_";
	    ($dev, $ino, $mode, $nlink) = stat ($name);
	    next unless -d _;
	    &findAndGroupShaders ($name, $nlink);
	}
    }
}

sub searchShader {
    local ($dir, $shader) = @_;
    local ($insep, @words, $go, $i, $found, $pds);

    $insep = $/;
    open (SHADER, "${dir}/${shader}") || die "unable to open $dir/$shader";
#    print "Opened ${dir}/${shader}\n";
    $go = 1;
    $/ = '{';  # want something like TYPE SHADER (...) {
    while ($go && ($_ = <SHADER>)) {
	@words = split (' ', $_);
#	print "searchShader: num words $#words\n";
	$found = 0;
#	print "\n";
	$nwords = @words;
	for ($i = 0; $i < $nwords && !$found; $i++) {
	    if ($words[$i] =~ /\(/) {
#		print "searchShader: $i:$words[$i]\n";
		$pos = index ($words [$i], '(');
		if ($pos == 0) { #shader name is previous
		    $name = $words [$i-1];
		    $type = $words [$i-2];
		}
		else { #need to split name from (
		    $name = substr ($words [$i], 0, $pos);
		    $type = $words [$i-1];
		}
		
#		print "name:type:$pos:$name:$type\n";
		if ($type =~ /surface|displacement|light|imager|volume/) {
		    $found = 1;
		    $/ = $insep;
		    &buildTypeAndLink ($dir, $shader, $type, $name);
		    $go = 0;
		}
	    }
	}
    }
    close (SHADER);
    $/ = $insep;
}

sub buildTypeAndLink {
    my ($dir, $shader, $type, $name) = @_;
    #assuming certain structure

#    print "buildTypeAndLink: $dir:$shader:$type:$name\n";
    $piclink = '';
    $shaderDesc = '';
    &readShaderHTML ($dir, $shader);
    $entry = join (':',  $name, $piclink, $dir, $shaderDesc);
#    print "buildTypeAndLink: entry $entry\n:$piclink:$dir:$name:$shaderDesc\n";

    if ($type eq 'surface') {
	push (@surface, $entry);
#	print "buildTypeAndLink: pushing surface:$entry\n";
    }
    elsif ($type eq 'displacement') {
	push (@displacement, $entry);
    }
    elsif ($type eq 'light') {
	push (@light, $entry);
    }
    elsif ($type eq 'imager') {
	push (@imager, $entry);
    }
    elsif ($type eq 'volume') {
	push (@volume, $entry);
    }
    else {
	print STDERRR "Unknown type: $type\n";
    }
}

sub createHTMLFiles {
    &doHTMLFile ("surface", @surface);
    &doHTMLFile ("displacement", @displacement);
    &doHTMLFile ("light", @light);
    &doHTMLFile ("imager", @imager);
    &doHTMLFile ("volume", @volume);
}

sub doHTMLFile {
    local ($type, @shaders) = @_;
    local ($link, $dir, $name, $desc, $date);

    $date = `date`;
    open (OUT, ">${type}.html") || die "unable to create Shaders/${type}.html";
#    print STDERR "doHTMLFILE: Creating $type.html\n";
    select (OUT);
    print "<HTML>\n<HEAD>\n<TITLE>\U$type\E Shaders</TITLE>\n";
    print qq|</HEAD>\n<BODY  bgcolor="#ffffff">\n|;
    print "<H1>\U$type\E Shaders</H1>\n";
    print "The following is a compilation of $type Shaders found in the RMR as of $date.\n<HR>\n";

    if (@shaders > 0) {
	print "<UL>\n";
	foreach (sort (@shaders)) {
	    ($name, $link, $dir, $desc) = split (':', $_);
#	print STDERR "doHTMLFile: $_\n";
	    $len = length ("Shaders");
	    $subdir = substr ($dir, $len+1);
#	print qq|<A HREF = "$dir/index.html#$name">$desc</A>\n|;
	    print qq|<LI><A HREF = "$dir/index.html#$name">$name</A>$desc\n|;
	    print "$link<P>\n";
	}
	print "</UL>\n";
    }
    else {
	print "No $type shaders available.\n";
    }

    &do_tal_mail;
    &do_parent_sibs;
    &do_copyright;
    print "\n</BODY>\n</HTML>\n";
    close OUT;
    select STDOUT;
}

sub readShaderHTML { #not best way of opening and closing for each shader
    local ($dir, $shader) = @_;
    local ($newdir, $basename);

    return if ($dir =~ /WWShaders/);

    open (IN, "$dir/index.html") || die "unable to open $dir/index.html";
    $basename = $shader;
    $basename =~ s/(.+)\.sl/$1/;
#    print "readShaderHTML: opened $dir/index.html. shader $basename\n";
    $shaderDesc = '';
    $picLink = '';
    while (<IN>) {
	if (/<LI>.+>(\w+)<\/[aA]>(.*)/) {
#	    print "$_:$1:$2\n";
	    if ($1 eq $basename) {
		$shaderDesc = $2;
#		print "readShaderHTML: desc: $shaderDesc\n";
	    }
	}
	elsif (/HREF=.(\w+).tiff/) {
#	    print "readShaderHTML: $_:$1\n";
	    if ($1 eq $basename) {
#		$len = length ("Shaders");
#		$subDir = substr ($dir, $len+1);
#		$link = "$subDir/$basename";
#		s/\n//g;
		$piclink = $_;
		if (!/<\/[aA]>/) { #don't have entire block
		    while (!/<\/[aA]>/) {
			$_ = <IN>;
			$piclink .= $_;
		    }
#		    $piclink .= $_;
		}
		$link = "$dir/$basename";
		$piclink =~ s/$basename/$link/g;
#		print "readShaderHTML: basename $basename:$link:$piclink\n";
		last;
	    }
	}
    }
    close (IN);
}

sub do_tal_mail {
    print "<HR>\n";
    print "$H3 Any comments or suggestions? Send them to:\n";
    print qq|<A HREF="mailto:$talMail">$talMail<\/A>\n|;
    print "$EH3\n";
}

sub do_parent_sibs {
    print "<!-- TRAILER -->\n";
    print "<HR>";
    print "<DL COMPACT>\n";
    print "Parent: ";
    &do_link ("../RMRShaders.html", "", "RMRShaders");
    print "<\/DL>\n";
}

sub do_link {
    local ($link, $jump, $desc) = @_;
    local ($linkStr);

    $linkStr = qq|<A HREF="$link$jump">$desc<\/A>|;
    print "\n$linkStr\n";
}

sub do_copyright {
    print "<HR><small>\n";
    print "<P><I>\n";
    print qq|The RMR is <A HREF="\/copyright.html">Copyright<\/A> &copy; 1995-2005 <A HREF="$talMail">Tal L. Lancaster<\/A> all rights reserved<\/I><\/P><\/small>\n|;
}
