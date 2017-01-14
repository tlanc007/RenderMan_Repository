#!/usr/local/bin/perl

#USE at your own risk.  This is just meant as an example.  Unless, there is 
#something really stupid here, I don't plan on supporting it. But if you do
#improve it, I will be more than happy to add it to the RMR.
#
#convert RIB RiSpheres and RiCurves to RIB blobbys
#Created for the RenderMan Repository Oct. 09, 1999  Tal Lancaster
#  talrmr@pacbell.net
#
#This just a quick hack to convert RiSpheres and RiCurves to RiBlobbys.  It
#assumes that the RIB was created from Houdini and the geometry was
#particles generated as spheres or curves.
#
#RiSpheres will be emitted as ellipsoid type blobbys
#RiCurves will be emitted as segment type blobbys
#
#Also the geometry should not be instanced.
#
#Usage: part2blb.pl DST_PREFIX RIB_FILES

$sectPattern = 'Object bl_';
$tmp = "bltmp.rib";
$blb_dst_prefix = shift (@ARGV);

foreach $arg (@ARGV) {
  $arg =~ /^(\w+)(.+)$/;
  $tmp = "${blb_dst_prefix}$2";
  print "Converting file $arg to blobby $tmp\n";
  #print "tmp $tmp\n";
  open (IN, $arg);
  open (OUT, ">$tmp");
  ##open (D, ">&STDOUT");
#  open (OUT, ">&STDOUT");

  $ingeo = 0;
  $startblob = 0;
  $lineno = 0;
  $skip = 0;
  $firstFrame = ($skip)? 1: 0;
  $wantSkip = 0;
  undef @blTrans;
  undef @blTrans2;
  undef @blgeo;
  undef @repl;
  while (<IN>) {
    $lineno++;
    if (/Display (".+\.z")/) {
      push (@repl, $1);
    }
    if (/^version/) {
      #add imager
      print OUT $_;
      print OUT qq|Imager "background" "color" [.5 .5 .6]\n|;
      next;
    }
    elsif ($wantSkip && $firstFrame && /FrameBegin/) {
      #print "$lineno Skip on: $_\n";
      $skip = 1;
      next;
    }
    elsif ($firstFrame && /FrameEnd/) {
      #print "$lineno Skip off: $_\n";
      $skip = 0;
      $firstFrame = 0;
      next;
    }
    elsif ($skip) {
      print "skipping\n";
      next;
    }
    elsif ($firstFrame && /^(.+ "jitter" [0]) (.+)$/) {
      #don't want the midpoint jitter
      $_= "$1\n";
    }
    
#    if (/TransformBegin/) 
#    {
#      print "tx\n";
#    }
    
    #$startblob = 1;
    if (/$sectPattern/) {
      $startblob = 1;
      #print "$lineno: sectpatter $_\n";
    }
    elsif (!$startblob) {
      #just emit blindly
      print OUT $_;
    }    
    elsif (/EndObject/) {
      print "$lineno: end blob $_\n";
      $startblob = 0;
      #do blob build
      if ($sphereBlob) {
        $n = @blgeo;
        &emitSphereBlobMain;
        $sphereBlob = 0;
        print OUT "\tTransformEnd\n";
        print OUT "AttributeEnd\n";
      }
      print OUT $_;
    }
    elsif (/TransformBegin/) {
      $ingeo = 1;
      $_ = <IN>;
      $lineno++;
      
      if (/MotionBegin/) {
        #print "moblur\n";
        $haveMotion = 1;
        $_ = <IN>;
        $lineno++;
      }
      
      if (/ConcatTransform/) {
        $firstline = $_;
        chomp( $firstline );
        $_ = <IN>;  # read in second line of concattransform
        $lineno++;
        print "whole line is $firstline$_\n";
        push (@blTrans, "$firstline$_");                
        $_ = <IN>;
        $lineno++;
      }
      else {
        #gotta put something
        push (@blTrans, '');
        print "$lineno: Expected translate but got: $_";
      }
      
      if ($haveMotion && /ConcatTransform/) {
        $firstline = $_;
        chomp( $firstline );
        $_ = <IN>;  # read in second line of concattransform
        $lineno++;
        push (@blTrans, "$firstline$_");                
        $_ = <IN>;
        $lineno++;
      }
      if ($haveMotion && /MotionEnd/) {
        $_ = <IN>;
        $lineno++;
      } 
      if (/Sphere/) {
        push (@blgeo, $_);
        $sphereBlob = 1;
        print "$lineno: $_";
      }
      else {
        die ("$lineno: No sphere found: $_\n");
      }
    }
    elsif (/TransformEnd/) {
      $ingeo = 0;
      
    }
    elsif (/Curves/) {
      /"(\w+)"\s+\[([^\]]+)\]/;
      $curvetype = $1;
      @verts = split (' ', $2);
      $nverts = @verts;
      if ($curvetype =~ /linear/ && $verts[0] == 2) {
        $/ = "]";
        $_ = <IN>;
        $lineno++;
        $/ = "\n";
        s/\]//;
        #$_  "P" [ ...
        s/\s+"P\w*"\s+\[\s+//;
        @points = split();
        $_ = <IN>; # should be \n from previous block
        $lineno++;
        $_ = <IN>;
        $lineno++;
        if (/"constantwidth" \[(.+)\]/) {
          $width = $1;
          &emitCurveBlobMain;
        }
        else {
          die ("RiCurve wasn't constantwidth:$_");
        }
      }
      else {
        die "only support RiCurves that are linear and have 2 vertices";
      }
    }
    elsif ($sphereBlob && /AttributeEnd/) {
      #do nothing
      next;
    }
    else {
      #not sure so emit
      print OUT $_;
    }
    
  }
  close (IN);
  close (OUT);
  #unlink $arg;
  #rename ($tmp, $arg);
  
}

sub emitSphereBlobMain {  
  if ($haveMotion) {
    print OUT "MotionBegin [0 1]\n";
  }

  &emitSphereBlob (@blTrans);

  if ($haveMotion) {
    &emitSphereBlob (@blTrans2);
    print OUT "MotionEnd\n";
  }
  $hasMotion = 0;
}

sub emitSphereBlob {
  local (@trans) = @_;
  local ($i, $blobPos, $coord, $scale, $nentries);
  local ($headMatrix);
  $nentries = @blgeo;

  print "trans: @trans\n";
  print OUT "Blobby $nentries [\n";
  $blobPos = 0;
  for ($i = 0; $i < $nentries; $i++) {    
    print OUT "\t1001 $blobPos\n";
    $blobPos += 16;
  }
  print OUT "0 $nentries ";
  for ($i = 0; $i < $nentries; $i++) {    
    print OUT "$i ";
  }
  print OUT "\n] [\n";
  for ($i = 0; $i < $nentries; $i++) {    
    $coord = $trans[$i];
    $coord =~ /\[(.*?)\]/;
    $coord = $1;
    print "poo: $coord\n";
    $scale = $blgeo [$i];
    $scale =~ s/Sphere (\S+)(.+)\n$/$1/;

    print OUT "$coord \n";
  }
  print OUT "]\n \t[\t\n";
  print OUT "\n\t]\n";
}

sub emitCurveBlobMain {
  local ($iter, $x, $y, $z, $iseven, $idmatrix);
  local (@lseg);
  
  $idmatrix = "1 0 0 0  0 1 0 0  0 0 1 0  0 0 0 1";

  print OUT "Blobby $nverts [\n";
  $blobPos = 0;
  for ($i = 0; $i < $nverts; $i++) {
    print OUT "\t1002 $blobPos\n";
    $blobPos += 23;
  }
  print OUT "0 $nverts ";
  for ($i = 0; $i < $nverts; $i++) {
    print OUT "$i ";
  }
  print OUT "\n] [\n";
  $iter = 0;
  while ($x = shift (@points)) {
    $isodd = ($iter % 2);
    #print "iter $iter $isodd\n";
    $iter++;
    $y = shift (@points);
    $z = shift (@points);

    $lseg [$isodd] = "$x $y $z";
    if ($isodd) {
      print OUT "@lseg $width $idmatrix\n";
    }
  }
  print OUT "\n] []\n";
  #print OUT "\n] [\n @repls \n]\n";
  print OUT "\tTransformEnd\n";

}
