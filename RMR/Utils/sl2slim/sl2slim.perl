#!/usr/bin/perl
# $Id: sl2slim.perl,v 1.1 2005/05/04 04:02:06 tal Exp $

#Tal Lancaster
#06/29/00

#constants
#set CPP to point to the location of your C preprocessor
$CPP = '/usr/bin/cpp';
#$ichar = "(\A|[^a-zA-Z_0-9\\-])";
$fieldSep = "\cD";
$fieldSep2 = "\cF";
$ichar = "\\s";
$pchar = "[^a-zA-Z_0-9\\-]";
$stypesPat = "^surface${ichar}|^displacement${ichar}|^light${ichar}|^imager${ichar}";
$ptypesPat = "${ichar}float${ichar}|${ichar}string${ichar}|${ichar}point${ichar}|${ichar}normal${ichar}|${ichar}vector${ichar}|${ichar}color${ichar}|${ichar}matrix${ichar}";
#$pencodesPat = "${pchar}name${pchar}|${pchar}desc${pchar}|${pchar}type${pchar}|${pchar}range${pchar}|${pchar}cat${pchar}|${pchar}vis${pchar}|${pchar}def${pchar}|${pchar}provider${pchar}|${pchar}expr${pchar}";
$pencodesPat = "${pchar}name${pchar}|${pchar}desc${pchar}|${pchar}type${pchar}|${pchar}range${pchar}|${pchar}cat${pchar}|${pchar}vis${pchar}|${pchar}def${pchar}|${pchar}provider${pchar}|${pchar}expr${pchar}*\{";

$stypes = "surface|displacement|light|imager";
$ptypes = "float|string|point|normal|vector|color|matrix";
$tupleTypes = "point|normal|vector|color";
$singleTypes = "float|string";
$pencodes = "name|desc|type|range|cat|vis|def|provider|expr";

$startToks = "\\(|\\)|\\/\\*|\\*\\/|[=!+-]=|[=;]|$stypesPat|$ptypesPat";

$datPrefix = "sl2slim";
$surface_dat = "surface_dat";
$displacement_dat = "displacement_dat";
$light_dat = "light_dat";
$volume_dat = "volume_dat";

$incomment = 0;
$stype;
$sname;
$sdesc;

@tokens;
@params;
@keys;
%cats;

@cppParms;
$cppOpts;

while (@ARGV) {
  $_ = shift (@ARGV);
  if (/-I|-D/i) {
    push (@cppParms, $_);
  }
  elsif (/-h/i) {
    &printHelp;
    exit 0;
  }
  else {
    #no more options
    unshift (@ARGV, $_);
    last;
  }
}
$cppOpts = join (' ', @cppParms);

foreach $file (@ARGV) {
  print "Creating .slim file from $file\n";
  $src = &readFile ($file);
  #print "$src\n";
  parseTokens ($src);
  #print "$jvals\n";
  #print "stype $stype sname $sname sdesc $sdesc params @params\n";
  &buildGroups (@params);
  &emitSlim ($file);
  undef @tokens;
  undef @params;
  undef @keys;
  undef %cats;
  undef $stype;
  undef $sname;
  undef $sdesc;

  $incomment = 0;
}

sub printHelp {
  local ($base, $dir);

  use File::Basename;

  $base = basename ($0);
  print "\nUSAGE: $base [-IcppDir|...] SLFILES\n\n";
  print "\tcppDir is directory to search for include files.\n";
  print "\tSLFILES is one or more shader files to process.\n\n";
  print "$base will read through a shader source file looking for optional\n";
  print "slim encodings to create a .slim file with the same base name as\n";
  print "the shader.\n\n";
}

# Top level parser.
# It looks for shader type, shader name, shader description, and
# then the start of the parameter list
# ie. surface s_surf /* shader desc. */ (
#
sub parseTokens {
  local ($src) = @_;
  local (@tmpToks);
  local ($tok, $ntok, $ttype);
  local ($ptype, $tptype, $inparameters);
  local ($go);
  
  $go = 1;
  @tokens = splits ($src);

  while ($go && @tokens) {
    $tok = getNextToken (1);
    $_ = $tok;
    #print "tok :$tok: incomment $incomment\n";


    if (/($stypesPat)/) {
      $stype = $1;
      $stype =~ s/^(\s*)(\S+)/$2/;
      $stype =~ s/\n//;
      # should be shader name
      $sname = getNextToken (1);
      $sname =~ s/\s//g;
      #print "\tstype $stype($tok): sname: $sname\n";
      &getMasterDesc ();
    }
    elsif (/\(/) {
      #start of parameter list
      if (!$incomment && $sname) {
	$inparamters++;
	&parseParms ();
	$go = 0;
	$inparamters--;
      }
    }

    #other
 ##   elsif ($stype && !$sname) {
      #should be the shader name
 ##     $sname = $tok;
 ##     &getMasterDesc ();
 ##   }
  }
}

# Sets the shader description
# Which should be a comment in between the shader name and the start of 
# the parameter list.
# ie. s_surf /* shader desc. */ (
#
sub getMasterDesc {
  local ($go);
  local (@desc);
  local ($mytok);

  $_ = getNextToken (0);
  $mytok = $tokens[0];
  #print "getMasterDesc tok incomment($incomment):$_:$mytok:\n";
  #put back if don't have a comment.  Means shader doesn't have a description
  unshift (@tokens, $_) if (!$incomment);

  while ($incomment) {
    $_ = getNextToken (0);
    push (@desc, $_) if ($incomment);
  }
  #print "getMasterDesc desc :@desc:\n";
  $sdesc = join (' ', @desc);
}

# Go through the shader parameteter list.  Everything between (...)
# Currently assumes that only one parameter per type definition.  It also
# looks for a comment after ';' which is assumed to contain the slim encoding
# float f1 = 0; /* desc {float paramter} */
#
sub parseParms {
  local ($ptype, $tptype);
  local ($tok, $ntok);
  local ($pinfo);
  local ($go, $isarray);
  $go = 1;
  
  $len = length (@tokens);
  #print "parseParms $len tokens: ~@tokens~\n";
  $len = 0;
#  foreach $tok (@tokens) {
#    print "-->[$len]: $tok\n";
#    $len++;
#  }
  while ($go && @tokens) {
    #$tok = shift (@tokens);
    $tok = getNextToken (1);
    $_ = $tok;
    
    if (/\)/) {
      #end of parameter list
      if (!$incomment) {
	$go = 0;
      }
    }
    elsif (/($ptypes)/) {
      #should be parameter type
      $tptype = $1;
      #if (!$incomment) {
      $ptype = $tptype;
      $pname = &get_pname ();
      if ($pname =~ /\[\s*(\d+)\s*\]/) {
	$isarray = 1;
      }
      else {
	$isarray = 0;
      }
      $pdef = &get_pdef ($ptype, $isarray);
      #print "\tparsParms- pdef :$pdef:\n";
      if ($ptype =~ /color|vector|normal|point/ && length ($pdef) <5) {
	$pdef = "{$pdef $pdef $pdef }";
      }
      &get_pend();
      $p_encode = &get_p_encode_str ();
      $p_encode =~ s/\s+/ /g;
      $p_encode =~ s/\t|\n//g;
      #print "ptype $ptype pname $pname pdef $pdef encode $p_encode\n";
      $pinfo = join ($fieldSep, $pname, $ptype, $pdef, $p_encode);
      push (@params, $pinfo);
      undef $ptype;
      undef $tptype;
      undef $pinfo;
      #}
    }
  }
}

sub check_defs {
  local ($type, $isarray, @tokens) = @_;
  local (@defs, @ntoks);
  local ($def, $ptype, $toks, $inparen, $inbraces, $debug);

  #hack
  $def = join (' ', @tokens);
  #@ntoks = split (/($ptypes|\(|\)|,|;|\{|\})/, $def);
  @ntoks = split (/($ptypes|;)/, $def);
  $_ = join ($fieldSep2, @ntoks);
  if (!/$fieldSep2/) {
    s/\"\s*\,/\"$fieldSep2,$fieldSep2/g;
  }
  #this may need to be changed for matrix
  if (!/$fieldSep2/) {
    s/\s*\,/$fieldSep2,$fieldSep2/g;
  }
  s/\)\s*\,/\)$fieldSep2\,$fieldSep2/g;
# this next line is the problem.  vector "shader" ... vector "shader"
# try matching just alphabet characters inside ""
#  s/\".+\"//g if ($type =~ /$tupleTypes/);
  s/\"\w+\"//g if ($type =~ /$tupleTypes/);
  #print "check_defs ntoks C: type = $type, \$_ = $_\n";
  #s/\"//g if ($type =~ /string/);
  s/\s+$fieldSep2|$fieldSep2\s+/$fieldSep2/g;
  s/$fieldSep2+/$fieldSep2/g;
  $debug = $_;
  #print "check_defs ntoks :$debug:\n";
  
  while (@ntoks) {
    $_ = shift (@ntoks);
    next if (/^\s+$/ || length ($_) eq 0);

    #really should check to ignore comments
    if (/($ptypes)/) {
      #type cast
      $ptype = $1;
      $toks = join ($fieldSep, @ntoks);
      #print "check_defs: ptype $ptype $toks\n";
    }
    elsif (/\(/) {
      $inparen++;
    }
    elsif (/\)/) {
      $inparen--;
    }
    #elsif (/\,/ && $inparen) {
      #do nothing
    #  next;
    #}
    else {
      #next if (/\,/ && $inparen);
      push (@defs, $_);
    }
  }
  $def = join (' ', @defs);  #$fieldSep
  $def = $debug;
  return ($def);
}

sub parseParenDef {
  local ($type, @defs) = @_;
  local ($def, $len, $tdef);
  local (@tdefs);

  if ($type eq 'color') {
    #$tdef = $defs [0];
    #$tdef = join (':', @defs);
    #$tdef =~ s/\s+/:/g;
    #@tdefs = split (':', $tdef);
    $len = @defs;
    
    #print "def: len $len :@defs\n";
    if ($len == 1) {
      $_ = shift (@defs);
      $_ = "$_ $_ $_";
    }
    else {
      $_ = join (' ', @defs);
#      s/\s\s+/:/g;
#      s/\{\s*/\{:/;
 #     s/\s*\}/:\}/;
      s/,\s*/ /g;
    }
  }
  elsif ($type =~ /point|vector|normal/) {
    $_ = shift (@defs);
    if (!/\"\w+\"/) {
      #not a space so put back
      unshift (@defs, $_);
    }
    $_ = join (' ', @defs);
    s/,\s*/ /g;
  }
  else {
    #hack
    $_ = join (' ', @defs);
  }
  #other stuff points, etc.
  $def = "{$_}";
  return ($def);
}

# Returns the name of the current parameter
sub get_pname {
  local ($pname);
  local ($tok);

  $tok = join ($fieldSep, @tokens);
  $pname = &getNextToken (1);

  #remove extra spaces otherwise will not have right param names
  $pname =~ s/^\s+|\s+$|(\S)\s+(\[)/$1$2/g;
  return ($pname);
}

# Returns the default value for the current parameter
sub get_pdef {
  local ($type, $isarray) = @_;
  local ($pdef, $tok, $go);
  local (@defs);

  $_ = &getNextToken (1);
  if (/=/) {
    #ok have equal sign next should be value
    #need to deal with matrix and array defaults!
    #assume that everything between the = and ; are to be used
    $go = 1;
    while ($go) {
      $_ = &getNextToken (1);
      if ($_ eq ';') {
	$go = 0;
	unshift (@tokens, $_); #maybe should just get rid of pend()
	last;
      }
      push (@defs, $_);
    }
    #print "get_pdef defs :@defs:\n";
    $pdef = &check_defs ($type, $isarray, @defs);
  }
  else {
    #no default value
    unshift (@tokens, $_);
  }
  $pdef =~ s/\n//;
  return ($pdef);
}

# Eats up tokens until a ';' is reached
sub get_pend {
  local ($pname);
  local ($tok, $go);

  $go = 1;
  while ($go && @tokens) {
    $_ = &getNextToken (1);
    if (/;/) {
      #that's what we want
      $go = 0;
    }
  }
}
    
# Goes through the comment looking for slim encodings
sub get_p_encode_str {
  local ($encode_str);
  local ($tok, $ntok, $go);
  local (@encoded);

  $_ = getNextToken (0);
  unshift (@tokens, $_) if (!$incomment);

  while ($incomment) {
    $_ = getNextToken (0);
    if ($incomment) {
      #build up encoded params
      push (@encoded, $_);
    }
  }
  $encode_str = join (' ', @encoded);
  #print "encode_str $encode_str\n";

  return ($encode_str);
}

# Returns the next valid token.
# Values that are 0 length or blank spaces are gobbled up.
# This function has a parameter to control if comments are ignored or
# not -- 1 ignored or if 0 then tokens inside comments are returned.
#
sub getNextToken {
  local ($ignoreComments) = @_;
  local ($pname);
  local ($tok, $ntok, $val, $go, $len);
  #local ($incomment);

  $go = 1;
  while ($go && @tokens) {
    $tok = shift (@tokens);
    #print "tok $tok\n" if (
    $_ = $tok;
    $len = length ($tok);
    #print "getval: tok $len :$tok:\n" if ($len > 0 && $tok ne ' ');

    if (/\/\*/) {
      $tok = '';
      $incomment++;
      $go = 0 if (!$ignoreComments);
    }
    elsif (/\*\//) {
      $tok = '';

      #print "maybe end of comment\n";
      if ($incomment) {
	$incomment--;
	$go = 0 if (!$ignoreComments);
	#print "subed incomment $incomment\n";
      }
    }
    elsif ($len eq 0 && (/^\s+$/m)) {
      next;
    }
    else {
      #should be the value
      #$val = $tok;
      if ($incomment && !$ignoreComments) {
	$go = 0;
      }
      elsif (!$incomment) {
	$go = 0;
      }
    }
  }
  #print "tok $tok\n";
  return $tok;
}
  
# Goes through the entire file and tokenizes it.
# The result is stored in @tokens
# The split is based on the string startToks
#
sub splits {
  local ($src) = @_;
  local (@tokens, @tmptoks);
  local ($tok);

  @tmptoks = split (/($startToks)/m, $src);
  foreach $tok (@tmptoks) {
    next if (length ($tok) eq 0 || $tok =~ /^\s+$/);
    push (@tokens, $tok);
  }
  $mytoks = join ($fieldSep, @tokens);
  $mytoks =~ s/\n//g;
  ##print "tokens $mytoks\n";
  
  return (@tokens);
}

# Goes through the parameter list and then groups categories together
# This function builds up @keys and %cats arrays.
#
sub buildGroups {
  local (@parms) = @_;
  local ($p, $cat, $val, $pname, $pos);

  foreach $p (@parms) {
    $pos = index ($p, 'cat ');
    #print "bg: p $p:$pos\n";
    if ($pos >= 0) {
      if (($pos eq 0 && $p[0] eq 'c') || 
	  (substr ($p, $pos-1, 1) eq ' ')) {
	$_ = substr ($p, $pos+4);
	/^(\w+)/;
	$cat = $1;
	$val = $cats {$cat};
	if (!$val) {
	  push (@keys, $cat);
	  $cats {$cat} = $p;
	}
	else {
	  #already have key
	  $val .= "|$p";
	  $cats {$cat} = $val;
	}
      }
    }
    else {
      #no cat
      ($pname, @tmp) = split ($fieldSep, $p);
      push (@keys, $pname);
      $cats {$pname} = $p;
    }
  }
}

# Opens up the slim file and dumps out the slim information
#
sub emitSlim {
  local ($file) = @_;
  local ($sfile);

  #$sfile = $file;
  $sfile = "$sname.slim";
  #$sfile =~ s/\.sl$/\.slim/;

  open (OUT, ">$sfile");
  #emit header
  print OUT "slim 1 appearance sl2slim {\n";
  print OUT qq|instance $stype "$sname" "$sname" \{\n\n|;
  #shader description goes here
  print OUT "\tdescription {$sdesc}\n\n" if ($sdesc);

  &emitdefaults ($stype);
  &emitParams ();

  #close out instance and slim
  print OUT "}\n}\n";

  close OUT;
}

# Goes through %cats and @keys arrays and dumps out slim data
# for each of the parameters.
#
sub emitParams {
  local ($p, $key, $val);
  local ($pname, $ptype, $pdefault, $encodeMisc, $asize);
  local (@params);
  local ($haveCat, $haveDef);

  $haveCat = 0;
  foreach $key (@keys) {
    $val = $cats {$key};
    #print "key $key: val $val\n";
    #next;
    @params = split (/\|/, $val);
    if (@params > 1) {
      $haveCat++;
      print OUT "collection $key {$key} {\n";
      #need to deal with giving information for group
    }

    foreach $p (@params) {
      ($pname, $ptype, $pdefault, $encodeMisc) = split ($fieldSep, $p);
      $asize = &check_if_array (\$pname);
      #print "emitParms: pname $pname; pdefault :$pdefault: encodeMisc :$encodeMisc:\n";
      $haveDef = &emit_default ($pname, $ptype, $pdefault, $encodeMisc, $asize);
    }
    if ($haveCat) {
      $haveCat = 0;
      print OUT "}\n";
    }
  }
}

sub emit_default {
  local ($name, $type, $def, $encodeMisc, $size) = @_;
  local (@adefs, @origdefs);
  local ($pos, $threeType, $val);

  $size =~ s/\s+//g;
  @adefs = split (/$fieldSep2/, $def);
  $_ = join (':', @adefs);
  s/:,:/:/g;
  s/\s*\{|\s*\}\s*|\s*\(\s*|\s*\)\s*//g;
  ##s/\:\s\"/\:\"/g;  # for strings remove unwanted blank in front of "
  ##s/\"\s+\:/\"\:/g;  #  "
  s/^\s+|\s+$//g;
  s/^:|:$//g;
  #$_ = '' if (/^\s+$/);  # handle empty strings
  s/::/:/g;
  @adefs = split (':', $_);

  #print "emit_default size $size $name $def adef :$_:\n";
  if ($size) {
    #in array
    print OUT "collection $type($size) {$name} {\n";
    print OUT "\tdrawmode all\n";
  }

  $pos = 0;
  $val = @adefs;
  #print "\temit_def len $val adefs @adefs\n";
  while (@adefs) {
    $_ = shift (@adefs);
    next if (/$ptypes/);
    if ($type =~ /$tupleTypes/) {
      $threeType = 1;
    }
    else {
      $threeType = 0;
    }

    #print "\temit_def threetype $threeType :$_:\n";
    
    if ($threeType) {
      if (/\,.+\,/) {
	s/\,/ /g;
      }
      #if (!/\s+[0-9eE.]+\s+/) {
      if (!/\S+\s+\S+\s+\S+/) {
	#missing elements
	$_ = "$_ $_ $_";
      }
    }

    #just use as is
    #what about matrices?
    &emit_def_encode ($_, $pos, $name, $type, $size, $encodeMisc);
    $pos++;
  }

  #print "emit_default pos $pos size $size threetype $threeType type $type\n";
  if ($pos < $size - 1) {
    #missing defs
    for ($i = $pos; $i < $size; $i++) {
      if ($threeType) {
	$val = " 0 0 0";
      }
      elsif ($type =~ /float/) {
	$val = 0;
      }
      elsif ($type =~ /string/) {
	$val = '';
      }
      &emit_def_encode ($val, $i, $name, $type, $size, $encodeMisc);
    }
  }
  if ($size) {
    #close up array collection
    print OUT "}\n";
  }
  #what about nonarray params?
  return 1; # hack for now
}

sub emit_def_encode {
  #local ($val, $pos, $name, $type, $isarray, $encodes) = @_;
  local ($val, $pos, $name, $type, $isarray, $encodesMisc) = @_;
  local ($havedef);

  if ($type =~ /string/) {
    $val =~ s/^\s+$//g;
    $val =~ s/\"//g;
  }
  if ($isarray) {
    print OUT "\tparameter $type $name {\n";
    if ($type =~ /string/ && $val =~ /^\s+$/) {
      print OUT "\t\tdefault {}\n";
    }
    else {
      print OUT "\t\tdefault {$val}\n";
    }
    print OUT "\t\tindex $pos\n";
    $_ = "${name}[$pos]";
    print OUT "\t\tlabel {$_}\n";
  }
  else {
    print OUT "parameter $type $name {\n";
  }
  $havedef = &emit_encodes ($encodeMisc);
  
  #close parameter list
  if ($isarray) {
    print OUT "\t}\n";
  }

  if (!$isarray && !$havedef) {
    if ($type =~ /string/) {
      if ($val =~ /^\s*\"\s+\"\s*$/) {
	$val = '';
      }
      else {
	$val =~ s/\"//g;
      }
    }
    print OUT "\tdefault {$val}\n";
  }
  if (!$isarray) {
    print OUT "}\n";
  }
}

sub emit_encodes {
  local ($encodeMisc) = @_;
  local (@encodeTokens);
  local ($mytoks, $haveDef);

  #print "emit_encodes :$encodeMisc:\n";
  @encodeTokens = split (/($pencodesPat)/, $encodeMisc);
  $mytoks = join ($fieldSep, @encodeTokens);
  #print "encodeTokens $mytoks\n";
  $haveDef = 0;
  while (@encodeTokens) {
    $_ = shift (@encodeTokens);
    next if (!/\w/);  #skip if not a word
    
    #print "tok $_\n";
    if (/desc/) {
      #print "emitParams, in desc:$_:\n";
      &emitSlimField ('description', shift (@encodeTokens));
    }
    elsif (/name/) {
      &emitSlimField ('label', shift (@encodeTokens));
    }
    elsif (/type/) {
      &emitSlimField ('subtype', shift (@encodeTokens));
    }
    elsif (/range/) {
      &emitSlimField ('range', shift (@encodeTokens));
    }
    elsif (/vis/) {
      &emitSlimField ('display', shift (@encodeTokens));
    }
    elsif (/provider/) {
      &emitSlimField ('provider', shift (@encodeTokens));
    }
    elsif (/expr/) {
      #now globbing up { so need to add it to the output.
      &emitSlimField ('expression {', shift (@encodeTokens));
    }
    elsif (/cat/) {
      #do stuff
      #loose the category name
      shift (@encodeTokens);
    }
    elsif (/def/) {
      #print "encodeTokens @encodeTokens\n";
      &emitSlimField ('default', shift (@encodeTokens));
      $haveDef++;
    }
    else {
      #don't know maybe just pure slim so dump out
      print "DIDN'T match: $_:@encodeTokens\n";
      &emitSlimField ($_, shift (@encodeTokens));
    }
  }
  return ($haveDef);
}

sub check_if_array {
  local ($rpname) = @_;
  local ($pname, $size);
  local (@atoks, @rest);
  
  ($pname, $size, @rest) = split (/\[|\]/, $$rpname);
  #print "\tcheck_if_array: rpname $$rpname:$pname:$size:@rest:\n";
  $$rpname = $pname if ($pname ne $$rpname);
  return ($size);
}


# Emits a slim field.  The function is passed a slim token and a slim value
# pair.
sub emitSlimField {
  local ($slimtok, $slimval) = @_;

  #get rid of empty spaces at begining of line
  $slimval =~ s/^\s+//;
  print OUT "\t$slimtok $slimval\n";
}

# Emits a bunch of standard attribute defaults based on shader type.
sub emitdefaults {
  local ($stype) = @_;
  
  if ($stype =~ /surface/) {
    &readDefAtts ($surface_dat);
  }
  elsif ($stype =~ /displacement/) {
    &readDefAtts ($displacement_dat);
  }
  elsif ($stype =~ /light/) {
    &readDefAtts ($light_dat);
  }
}

sub readDefAtts {
  local ($fnameTail) = @_;
  local ($datFile);
  local ($base, $dir);

  use File::Basename;

  $dir = dirname ($0);

  #really need to process $0 to get full path of these files.
  $datFile = "$dir/$datPrefix.$fnameTail";
  #print "datfile $datFile\n";
  open (IN, $datFile) || die "Unable to open required data file: $datFile\n";

  while ($_ = <IN>) {
    print OUT $_;
  }
  close (IN);
}

# open up the shader file and dump everything into one line
sub readFile {
  local ($fname) = @_;
  local (@cont, $line);
  local (@FIN);
  local ($ignoreStr, $tmpfile, $command);
  local ($base, $dir);

  use File::Basename;
  
  $base = basename ($fname);
  $ignoreStr = "\#\s*include|\#\s*if|\#\s*els|\#\s*end|\#\s+\d+\s+\"[^\"]+";
  $tmpfile = "${base}_$$";
  $command = "$CPP $cppOpts -C $fname > $tmpfile";
  #print "command $command\n";
  system ($command);
  open (FIN, $tmpfile);

  while (<FIN>) {
    #chop;
    #push (@cont, $_);
    next if (/\#\s*include|\#\s*if|\#\s*els|\#\s*end|^\#\s/);
    #Need to remove \\ character that is used to continue macro lines.
    #s/\x5c\x0a//;   in hex
    $_ =~ s/\\\n//;
    #print "$_\n" if (/^\#\s/);
    $line .= $_;
  }
  close (FIN);
  unlink ($tmpfile);
  return ($line);
}
