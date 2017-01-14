#!/usr/bin/perl

$TI = "<TITLE>";
$ETI = "</TITLE>";
$H1 = "<H1>";
$EH1 = "</H1>";
$H2 = "<H2>";
$EH2 = "</H2>";
$H3 = "<H3>";
$EH3 = "</H3>";
$H5 = "<H5>";
$EH5 = "</H5>";
$HR = "<HR>\n";
$B = "<B>";
$EB = "</B>";
$new = "new.jpg";
$newDir = "Pics";
$currNewPath = "";
$subtitle = "";
$prenote = "";
$firstSection = 1;
$hdocSep = '\t';
$talMail = 'tal AT renderman DOT org';

#@suffix = (".tiff", ".jpg", ".sl", ".rib", ".slo", "");
@suffix = (".tiff", ".sl", ".rib", ".slo", ".slim", "");
%dir_db = ();
$dir_data = ();

&read_dir_db ("RMR_dir_db");

$startDir = `pwd`;
chop ($startDir);

while ($_ = shift (@ARGV)) {
    #assuming $_ must be a shader dir
    $title = 0;
    $xpic = 100;
    $ypic = 100;
    $xout = 100;
    $yout = 100;
    
    $shaderKey = $_;
    $shadersDir = "Shaders";
    $hdoc = "$shadersDir/$_/$_.hdoc";

    open (SHADER_FILE, $hdoc) || die "Can't open $hdoc";

    $go = 1;
    $pat = "^$_";
    for ($i = 0; $i < $#dir_data && $go; $i++) {
	if ($dir_data[$i] =~ /$pat/) {
	    ($t, $edir, $t, $ename) = split (':', $dir_data[$i]);
#	    $htmlFile = "$shadersDir/$edir";
	    $htmlFile = "$edir";
	    $dirPath = $edir;
	    if ($ename eq "") {
		$ename = "index.html";
	    }
	    $htmlFile .= "/$ename";
	    open (HTML_FILE, ">$htmlFile") || die "Can't create $htmlFile";
#	    print "Ready to open $htmlFile\n";
	    $go = 0;
	}
    }
    if ($i == $#dir_data) {
	#entry not found
	die "Couldn't find entry for $pat";
    }
	    
    #set up shader list
    select (HTML_FILE);

    &do_listAndTitle;
    close (SHADER_FILE);
    open (SHADER_FILE, $hdoc) || die "Can't open $hdoc";
    &build_shaders (dir_db);
    close (HTML_FILE);
}

exit (0);

#++++++++++++++++
sub read_dir_db {
    local ($dbName) = @_;
    local ($key, $val, $parent, $name, $entry, $i);

    open (DB, $dbName) || die "Can't open $dbName for reading";

    $i = 0;
    while (<DB>) {
	chop;
	$entry = $_;
#	print "DB: $_\n";

	($key, $val, $parent, $val) = split;
	$dir_db {$key} = $val;
	$dir_data [$i++] = $entry;
    }
    close (DB);
}

sub do_listAndTitle {
    local (@entry, $key, $haveShader, $haveDesc, $haveExample, $tmp);

    $haveShader = $haveDesc = 0;
    $subtitle = "";
    $prenote = "";
    $mailto = "";
    $firstSection = 1;
    print "<HTML>\n";
    
    while (<SHADER_FILE>) {
	chop;
	@entry = split ($hdocSep, $_);
#	print "SF:@entry\n";
#	next if $key eq "";

	$key = shift (@entry);
	if ($key =~ /^SUBTITLE_H5/) {
	    # hack for now must come before title in hdoc file
#	    $temptitle = shift (@entry);
	    $subtitle = &build_subtitle ($subtitle, $H5, $EH5, @entry);
	}
	elsif ($key =~ /^SUBTITLE_B/) {
	    # hack for now must come before title in hdoc file
	    $subtitle = &build_subtitle ($subtitle, $B, $EB, @entry);
	}
	elsif ($key =~ /^SUBTITLE_LEFT/) {
	    # hack for now must come before title in hdoc file
	    $subtitle = &build_subtitle ($subtitle, "LEFT", "", @entry);
	}
	elsif ($key =~ /^SUBTITLE/) {
	    # hack for now must come before title in hdoc file
	    $subtitle = &build_subtitle ($subtitle, "", "", @entry);
	}
	elsif ($key =~ /^TITLE/) {
	    &get_title (@entry);
	}
	elsif ($key =~ /^PRENOTE/) {
	    #This entry must be seen before the title in the hdoc file.
	    $tmp = shift (@entry);
	    if ($prenote eq "") {
		$prenote = $tmp;
	    }
	    else {
		$prenote .= $tmp;
	    }
#	    print STDERR "prenote:$prenote:\n";
	}
	elsif ($key =~ /^MAILTO/) {
	    #must before title
	    &get_mailto (@entry);
	}
	elsif ($key =~ /^SHADER/ && !$haveShader) {
	   $name = shift (@entry);
	   $haveShader = 1;
#	   print "$key: @entry\n";
       }
	elsif ($key =~ /^DESC/ && !$haveDesc) {
	    $desc = shift (@entry);
	    $haveDesc = 1;
#	   print "\t$key: @entry\n";
	}
	elsif ($key =~ /^EXAMPLE/ && !$haveExample) {
	  $name = shift (@entry);
	  $haveExample = 1;
	}
	elsif ($key =~ /^SHADER|^DESC/) {
	    #problem
	    print STDERR "do_listAndTitle: $name:$desc:-- mismatched. Missing either a SHADER or DESC keyword\n";
	}
	elsif ($key =~ /^TOC/) {
	    $toc = shift (@entry);
	    $tocdesc = shift (@entry);
	    &do_jump ("index.html", $toc, $tocdesc);
	}
	elsif ($key =~ /^DIR|^SECTION|^DO_LINE|^NEW|^SUBTITLE/) {
	    # ignore
	    next;
	}
	else {
	    print STDERR "do_listAndTitle: Unknown keyword $key\n";
	}

	if ($haveDesc && $haveShader) {
	    $haveDesc = $haveShader = 0;
	    &do_jump ("index.html", $name, $desc);
	}
	elsif ($haveDesc && $haveExample) {
	    $haveDesc = $haveExample = 0;
	    &do_jump ("index.html", $name, $desc);
	}

    }
    # done wrap up
    print "<\/UL>\n";
    print $mailto if $mailto ne "";
    print "<HR>\n";
}

sub build_subtitle {
    local ($stitle, $pre, $suf, @entry) = @_;
    local ($ttitle);

    $ttitle = shift (@entry);
    if ($pre eq "LEFT") {
	#want left justified instead of center
	$ttitle = "</CENTER><LEFT>$ttitle</LEFT><P>\n<CENTER>";
    }
    elsif ($pre ne "") {
	$ttitle = $pre . $ttitle . $suf . "<P>\n";
    }
    else {
	$title .= "<P>\n";
    }
    if ($stitle eq "") {
	$stitle = $ttitle;
    }
    else {
	$stitle .= $ttitle;
    }
#    print STDERR "build_sub: $stitle:$ttitle.\n";
    return $stitle;
}

sub get_mailto {
    local ($email, $name);

    $email = shift (@_);
    $name = shift (@_);
    if ($name =~ /^NAME/) {
	$name = shift (@_);
    }
    $mailto = qq|<A HREF="mailto:$email">$name<\/A><P>\n|;
}

sub get_title {
    local ($val, $h1);

#    $prenote = shift (@_);
    $title = shift (@_);
    $val = shift (@_);
    if ($val =~ /^H1/) {
	$h1 = shift (@_);
    }
    else {
	$h1 = $title;
    }

    print "<HEAD>\n";
    #emit stylesheet
    print qq|<LINK rel="stylesheet" type="text/css" href="/RMR/nav.css" title="navtitle">\n|;

    print "$TI $shaderKey $ETI\n";


    #emit nav table
    &emit_nav_table;

    print "<\/HEAD>\n";
    print qq|<BODY  bgcolor="#ffffff">\n|;
    print "<CENTER>\n";
    print "$H1$h1$EH1<P>\n";
    print $subtitle if $subtitle ne "";
    print "<\/CENTER>\n";
    print $prenote if $prenote ne "";
    print "<H4>What's on this page:<\/H4>\n";
    print "<UL>\n";
}

sub emit_nav_table {
    print qq|<body bgcolor="white">\n|;
    print qq|<center>\n|;
    print "<table cellspacing=0 cellpadding=3 border=0>\n";
    print qq|<tr valign="bottom">\n|;
    print qq|<td bgcolor="#305073">&nbsp;&nbsp;&nbsp;<span class="navtitle">RenderMan Repository</span></td>\n|;
    print qq|<td bgcolor="#305073" align="right">&nbsp;&nbsp;</td>\n|;
    print "</tr>\n";
    print qq|<tr><td bgcolor="#305073" colspan=2>\n|;
    print "<table cellspacing=0 cellpadding=5 border=0>\n";
    
    print qq|<tr bgcolor="#B8C8E0">\n|;
    print qq|<td><a CLASS="none" href="/RMR/index.html">Home</a></td>\n|;
 
    print qq|<td><a CLASS="none" href="/RMR/site_index.html">Index</a></td>\n|;
    print qq|<td><a CLASS="none" href="/RMR/Search.html">Search</a></td>\n|;
    print qq|<td><a CLASS="none" href="/RMR/cgrrFAQ.html">FAQ</a></td>\n|;
    print qq|<td><a CLASS="none" href="/RMR/OtherLinks/index.html">Offsite</a></td>\n|;
    print qq|<td><a CLASS="none" href="/RMR/RMRShaders.html">Shaders</a></td>\n|;
    print qq|<td><a CLASS="none" href="/RMR/Examples/index.html">Examples</a></td>\n|;
    print qq|<td><a CLASS="none" href="/RMR/Publications/index.html">Pubs</a></td>\n|;
    print qq|<td><a CLASS="none" href="/RMR/Utils/index.html">Utils</a></td>\n|;
    print qq|</tr>\n|;
    print qq|</td></tr></table>\n|;
    print qq|</td></tr></table>\n|;
    print qq|</center>\n|;
}

sub get_note {
    local ($note) = @_;

    print "$note\n";
}

sub get_dir {
    local (@rest, $val);

    @rest = @_;
    $dirName = shift (@rest);
#    print "get_dir: @rest\n";
    while ($_ = shift (@rest)) {
#	print "get_dir: $_\n";
	if (/PIC/) {
	    $xpic = shift (@rest);
	    $ypic = shift (@rest);
	}
	elsif (/ALIGN/) {
	    $picAlign = $_;
	}
	else {
	    print STDERR "Not sure what to do with: $_\n";
	}
    }
#    print "get_dir: $xpic $ypic $picAlign\n";
}

sub get_section {
    local ($pic, $sectionName);

    $pic = 0;
    while ($_ = shift (@_)) {
	if (/^PIC/) {
	    $pic = shift (@_);
	}
	else {
	    $sectionName = $_;
	}

    }
    if (!$firstSection) {
	#To prevent double HRs
#	print "$HR\n";  5/2/98 prevent double hrs
    }
    else {
	$firstSection = 0;
    }
    print "$H1";
    $pic && do_IMG_SRC ($pic);
    print qq|<A NAME="$sectionName"><\/A>$sectionName\n|;
    print "$EH1\n";
}

sub get_h1 {
    local ($h1) = @_;
    print qq|<BODY bgcolor="#ffffff">\n|;
    print "<H1>$h1<\/H1>\n";
}

sub do_IMG_SRC {
    local ($pic) = @_;
    print qq|<IMG SRC="$pic" ALT="">\n|;
}

sub do_new {
    local ($linkPath, $fullPath);
    local ($dirName, $dir_db) = @_;

    $linkPath = &parse_link ($dirName, $newDir, $dir_db);
#    $fullPath = "$linkPath/$new";
#  hack should find out why off my one level. 12/13/98
    #$fullPath = "../../$linkPath/$new";
    $fullPath = "../$linkPath/$new";
    print STDERR "new:$fullPath:$dirName, $newDir, $dir_db\n";
    &do_IMG_SRC ($fullPath);
}

sub prep_new {
    local ($linkPath, $fullPath);
    local ($dirName, $dir_db) = @_;

    $linkPath = &parse_link ($dirName, $newDir, $dir_db);
    #Need to find out why this isn't working -- 12/13/98
    ##$fullPath = "../$linkPath/$new";
    $fullPath = "$linkPath/$new";
    $currNewPath = $fullPath;
    print STDERR "$fullPlath:$dirName, $newDir $dir_db\n";

#    &do_IMG_SRC ($fullPath);
}
sub do_jump {
    local ($link, $jump, $desc) = @_;
    local ($linkStr);

    $linkStr = qq|<LI><A HREF="$link#$jump">$jump<\/A>|;
    $linkStr .= "-- $desc" if $desc ne "";
    print "$linkStr\n";
}

sub do_link {
    local ($link, $jump, $desc) = @_;
    local ($linkStr);

    $linkStr = qq|<A HREF="$link$jump">$desc<\/A>|;
    print "\n$linkStr\n";
}

sub do_linkNN {
    local ($link, $jump, $desc) = @_;
    local ($linkStr);

    $linkStr = qq|<A HREF="$link$jump">$desc<\/A>|;
    print "$linkStr";
}

sub build_shaders {
    local (@entry, $key);
    $currNewPath = "";

    while (<SHADER_FILE>) {
	chop;
	@entry = split ($hdocSep, $_);
	$key = shift (@entry);

#	print "build_shaders: $key: @entry\n";
	if ($key =~ /^DIR/) {
	    &get_dir (@entry);
	}
	elsif ($key =~ /^SECTION/) {
	    &get_section (@entry);
	}
	elsif ($key =~ /^H1/) {
	    &get_h1 (@entry);
	}
	elsif ($key =~ /^SHADER/) {
	    &get_shader (@entry);
	}
	elsif ($key =~ /^EXAMPLE/) {
	    &get_example (@entry);
	}
	elsif ($key =~ /^DO_LINE/) {
	    &do_line;
	}
	elsif ($key =~ /^NEW/) {
	    &prep_new ($dirName, $newDir, $dir_db);
#	    &do_new ($dirName, $newDir, $dir_db);
	}
	elsif ($key =~ /^TOC/) {
	    &do_toc (@entry);
	}
    }
    &do_tal_mail;
    @vals = values(%dir_db);
    &do_parentSiblings ($shaderKey, $dir_db);
    &do_copyright;

    #wrap up
    print "<\/BODY>\n</HTML>\n";
}

sub get_shader {
    local ($link, $name) = 0;

    $shaderName = shift (@_);
    #emit heading and nameplace
    print qq|<A NAME="$shaderName"><\/A>\n|;
    print qq|<H2>|;
    if ($currNewPath ne "") {
	&do_IMG_SRC ($currNewPath);
    $currNewPath = "";

    }
    print qq|${shaderName}.sl<\/H2><P>\n|;
    while ($_ = shift (@_)) {
	if (/^NOTE/) {
	    $_ = shift (@_);
	    print "$_ ";
	}
	elsif (/^LINK/) {
	    $name = "";
	    $link = shift (@_);
	    $link = &find_link ($link);
	    $_ = shift (@_);
	    if (/^NAME/) {
		$name = shift (@_);
	    }
	    &do_link ($link, "", $name);
	}
	elsif (/^QLINK/) {
	  # a link on same page and desc is name
	  #+++++++++++++++++
	  $name = shift (@_);
	  $jump = "#$name";
	  print STDERR "\n--- QLINK $jump:$name\n\n";
	  &do_link ($jump, , "", $name);
	}
	else {
	    #must be rest of note
	    print $_;
	}
    }
}

sub get_example {
    local ($link, $name) = 0;

    $shaderName = shift (@_);
    #emit heading and nameplace
    print qq|<A NAME="$shaderName"><\/A>\n|;
    print qq|<H2>|;
    if ($currNewPath ne "") {
	&do_IMG_SRC ($currNewPath);
    }
    print qq|${shaderName}<\/H2><P>\n|;
    while ($_ = shift (@_)) {
	if (/^NOTE/) {
	    $_ = shift (@_);
	    print "$_ ";
	}
	elsif (/^LINK/) {
	    $name = "";
	    $link = shift (@_);
	    $link = &find_link ($link);
	    $_ = shift (@_);
	    if (/^NAME/) {
		$name = shift (@_);
	    }
	    &do_link ($link, "", $name);
	}
	elsif (/^QLINK/) {
	  # a link on same page and desc is name
	  #+++++++++++++++++
	  $name = shift (@_);
	  $jump = "#$name";
#	  print STDERR "\n--- QLINK $jump:$name\n";
	  &do_link ($jump, , "", $name);
	}
	else {
	    #must be rest of note
	    print $_;
	}
    }
}

sub find_link {
    local ($origlink) = @_;
    local ($ekey ,$edir, $epar, $ename);
    local ($i, $levels, $link, $path);

    $link = $origlink;
    $link =~ s/(.+)(\#.+)/$1/;
    $jump = $2;
#    print STDERR "link:jump $link:$jump\n";
    foreach (@dir_data) {
	if (/$link/) {
	    ($ekey, $edir, $epar, $ename) = split (':', $_);
	    last;
	}
    }
    $levels = 0;
    $start = length ($dirPath)+1;
    while ($start = rindex ($dirPath, '/', $start) > 0) {
	$levels++;
    }
    $path = "../";
    for ($i = 0; $i < $levels; $i++) {
	$path .= "../";
    }
    if ($ename eq "") {
	$ename = "index.html";
    }
    else {
	$ename .= ".html";
    }
    if ($edir ne "" && $edir =~ /\//) {
	$path .= $edir;
    }
    $path .= $ename . $jump;
    print STDERR "path: $path.\n";
    return $path;
}

sub do_toc {
    local ($note, $name);

    $name = shift (@_);
    shift (@_); #desc
    shift (@_); #NOTE tag
    $note = shift (@_);
    print qq|<A NAME="$name"><\/A>\n|;
    print qq|<H2>|;
    if ($currNewPath ne "") {
	&do_IMG_SRC ($currNewPath);
    }
    print qq|$name<\/H2><P>\n|;
    print $note;
    print $HR;
}
   
sub getTiffInfo {
    local ($fname) = @_;
    `tiffinfo $fname`;
}

sub getTiff_XY {
    local ($tiffinfo);

    ($fname, $x, $y) = @_;
    $tiffinfo = &getTiffInfo ($fname);
    if ($tiffinfo =~ /Width: (\d+) .* Length: (\d+)/) {
	$x = $1;
	$y = $2;
    }
}

sub getPNMInfo {
    local ($fname) = @_;
    `pnmfile $fname`;
}

sub getPNM_XY {
    local ($fname) = @_;
    local ($pnminfo);

    $pnminfo = &getPNMInfo ($fname);
    if ($pnminfo =~ /(\d+) by (\d+)/) {
	$xout = $1;
	$yout = $2;
    }
}

sub do_line {
    local ($fname, $i, $suffix, $x, $y);
    local ($jpg, $command);

    #first go to the shader directory
    chdir ("$edir") || die "Could cd to $edir";

    print "\n<P>\n";
    #emit shader
    for ($i = 0; $suffix = $suffix[$i]; $i++) {
	$fname = "$shaderName$suffix";
#	if ($suffix =~ /tiff|tif/ && -e $fname) {
	if ($suffix =~ /tif/) {
	  # see if file is tif or tiff
	  $havetif = 0;
	  if (! -e $fname) {
	    #ok .tiff doesn't exist.  Try .tif
	    chop ($fname);
	    if (-e $fname) {
	      $havetif = 1;
	    }
	  }
	  else {
	    $havetif = 1;
	  }
	  
	  if ($havetif) {
	    #check to see if jpeg exists and get its size
	    &getTiff_XY ($fname, $x, $y);
#	    print "do_line: $fname $x, $y\n";
	    $jpg = $fname;
	    $jpg =~ s/\.tiff|\.tif/_sm\.jpg/;
	    if (! -e $jpg) {
		#jpg doesn't exist.  Make one.
#		$command = "tifftopnm $fname | pnmscale -xysize $xpic $ypic |cjpeg -quality 90 -progressive > $jpg";
		$command = "tifftopnm $fname | pnmscale -xysize $xpic $ypic >tmp.pnm";
		system ($command);
		&getPNM_XY ("tmp.pnm");
		$command = "cjpeg -quality 90 -progressive tmp.pnm > $jpg";
		system ($command);
		die "fail creating $jpg" if !-e $jpg;
	    }
	    else {
		#jpeg already exists
		$pnminfo = `djpeg -pnm $jpg|pnmfile`;
		if ($pnminfo =~ /(\d+) by (\d+)/) {
		    $xout = $1;
		    $yout = $2;
		}
	    }
	    $jpg_sm = $jpg;
	    
	    #convert tiff to jpeg
	    $jpg =~ s/_sm\.jpg$/\.jpg/; 
	    if (!-e $jpg) {
	      $command = "tifftopnm $fname | cjpeg -quality 90 -progressive > $jpg";
	      system ($command);
	    }

	    print qq|<A HREF="$jpg">\n|;
#	    print qq|<IMG SRC=$jpg_sm WIDTH=$xpic HEIGHT=$ypic $picAlign\n|;
# for now don't want the ALIGN as in ALIGN=LEFT as that is what messes
# up the picture layout. However ever want the clear part to take that out
# and use it.
	    print qq|<IMG SRC=$jpg_sm WIDTH=$xout HEIGHT=$yout CLEAR\n|;
	    print qq|<ALT="$jpg"></A>\n|;
	  }
	}
	elsif ($suffix =~ /sl/ && -e $fname) {
	    print qq|<A HREF="$fname">$fname</A>\n|;
	}
	elsif ($suffix =~ /rib/ && -e $fname) {
	    print qq|<A HREF="$fname">Sample RIB</A>\n|;
	}
	elsif ($suffix =~ /slo/ && -e $fname) {
	    print qq|<A HREF="$fname">prman shader</A>\n|;
	}
	else {
	    print STDERR "Warning:$fname:$suffix: maybe missing\n";
	}
    }
    print $HR;
    unlink ("tmp.pnm");
    chdir ("$startDir") || die "Couldn't go back to $startDir.";
}

sub get_dir_data_entry {
    local ($key) = @_;
    local ($i, $end, $result);
    
    $end = $#dir_data;
    for ($i = 0; $i < $end; $i++) {
	last if $dir_data[$i] =~ /^$key/;
    }
    if ($i == $end) {
	#didn't find a match
	$result = "";
    }
    else {
	$result = $dir_data[$i];
    }
    return $result;
}

sub parse_link {
    local ($curdir, $linkdir, $done, $name);
    local ($src, $dst, $pos, $dirpath, $dirName, $linkName);
    local ($level, $i, $result, $t);

    ($dirName, $linkName, $dir_db) = @_;
#    $curdir = $dir_db{$dirName};
#    $linkdir = $dir_db{$linkName};
    $result = &get_dir_data_entry ($dirName);
    ($t, $curdir, $t, $t) = split (':', $result);
    $result = &get_dir_data_entry ($linkName);
    ($t, $linkdir, $t, $t) = split (':', $result);

    $done = $level = 0;
    $src = $curdir;
    $dst = $linkdir;
    while (!$done) {
	print STDERR "\nLEVEL: $level; src: $src; dst: $dst.\n";
	if ($src eq $dst) {
	    $done = 1;
	}
	elsif ($src =~ /\//) {
	    $level++;
	    $pos = rindex ($src, "/");
	    $src = substr ($src, 0 , $pos);
	    #another way would be to just keep calling rindex with offset
	}
	else {
	    # not sure what is going on here
	    $done = 1;
	}
    }	
    if ($level > 0) { # was if ($len > 0 not sure what this was suppose to do
#	$dirPath = "../";
	$dirPath = "";
    }
    for ($i = 0; $i < $level; $i++) {
	$dirPath .= "../";
    }
    $dirPath .= $linkdir;

    return $dirPath;
}

sub do_tal_mail {
    print "$H3 Any comments or suggestions? Send them to:\n";
    print qq|<A HREF="mailto:$talMail">$talMail<\/A>\n|;
    print "$EH3\n";
}

sub do_parentSiblings {
    local ($keyName, $dir_db) = @_;
    local ($dir, @siblings);
    local ($parent, $ekey, $eparent, $edir, $ename);
    local ($pos, $len, $edirName, $siblingsName);
    local ($i, $parentLink, $parentName);

    foreach (@dir_data) {
	if (/^$keyName/) {
	    #match
	    ($ekey, $edir, $eparent, $ename) = split(':', $_);
	    $dir = $edir;
	    last;
	}
    }
    $pdir = $eparent;
    

    $levels = 0;
    $subDir = $dir;
    while (($pos = rindex ($subDir, "/")) > 0) {
	$levels++;
	$subDir = substr ($dir, 0, $pos);
    }
#    $parentLink = "../";
    $parentLink = "";
    for ($i = 0; $i < $levels; $i++) {
	$parentLink .= "../";
    }
    
    foreach (@dir_data) {
	if (/^$pdir/) {
	    #found parent entry
	    ($ekey, $edir, $eparent, $ename) = split (':', $_);
	    $parentName = $ename;
#	    print STDERR "$pdir:name $parentName: link $parentLink\n";
	    if ($parentName eq "") {
		$parentLink .= "index.html";
		$parentName = $ekey;
	    }
	    else {
		$parentLink .= "${parentName}.html";
	    }
	    last;
	}
    }

    foreach (@dir_data) {
	next if /^$keyName/;  #skip if entry is us

	($ekey, $edir, $eparent, $ename) = split(':', $_);
	if ($ename eq "") {
	    $ename = "index.html";
	}
	$parent = $eparent;
	$parent .= $ename;

#	print "EP $eparent; P $parent; sub $subDir\n";
#	if ($edir =~ /$subDir/) {
	if ($eparent eq $pdir) {
	    #find dirs that match up
	    #could call parse link or know hat have same parent
#	    $pos = rindex ($edir, "/");
#	    $len = length ($edir);
#	    $edirName = substr ($edir, $pos, $len-$pos);
## either ../$ename (relative) or $edir/ename (absolute)
#	    $siblingName = "..${ediredir}${ename}";

	    # OK specific for shaders subdir.  Need a better way
	    $edir =~ s/Shaders\/(.*)/$1/;
	    $siblingName = "../$edir${ename}";
#	    print STDERR "SIBS $edir:$ename:$siblingName\n";
	    push (@siblings, join (':', $siblingName, $ekey));
	}
    }
#    print "Siblings: $#siblings @siblings\n";
    print "<!-- TRAILER -->\n";
    print "$HR";
    print "<DL COMPACT>\n";
    print "Parent: ";
    &do_link ($parentLink, "", $parentName); #$pdir
    print "<P>\n";
    if ($#siblings >= 0) {
	print "Siblings: \n";
	foreach (@siblings) {
	    ($siblingName, $ekey) = split (':', $_);
	    &do_linkNN ($siblingName, "", $ekey);
	    print " ";
	}
    }
    print "<\/DL>\n";
}

sub do_copyright {
    print "<HR><small>\n";
    print "<P><I>\n";
    print qq|The RMR is <A HREF="\/copyright.html">Copyright<\/A> &copy; 1995-2005 <A HREF="mailto:tal AT renderman DOT org">Tal L. Lancaster<\/A> all rights reserved<\/I><\/P><\/small>\n|;
}
	   
