/* Orig shader uberlight.sl by Larry Gritz from BMRT distribution 2.5
 * renamed to l_uber.sl and modified by Tal Lancaster
 */

/****************************************************************************
 * l_uber.sl - a light with many fun controls.
 *
 * Description:
 *   Based on Ronen Barzel's paper "Lighting Controls for Computer
 *   Cinematography" (in Journal of Graphics Tools, vol. 2, no. 1: 1-20).
 *
 * Rather than explicitly pass "from" and "to" points to indicate the
 * position and direction of the light (as spotlight does), this light
 * emits from the origin of the local light shader space and points
 * toward the +z axis (also in shader space).  Thus, to position and
 * orient the light source, you must translate and rotate the
 * coordinate system in effect when the light source is declared.
 * Perhaps this is a new idea for some users, but it isn't really
 * hard, and it vastly simplifies the math in the shader.
 *
 * Basic color/brightness controls:
 *   intensity - overall intensity scaling of the light
 *   lightcolor - overall color filtering for the light
 *
 * Light type:
 *   lighttype - one of "spot", "omni", or "arealight".  Spot lights are
 *       those that point in a particular direction (+z in local light
 *       space, for this light).  Omni lights throw light in all directions.
 *       Area lights are emitted from actual geometry (this only works on
 *       BMRT area lights for the time being).  Also now has "directional"
 *       type which is identical to "spot" but does not apply superellipse.
 *
 * Distance shaping and falloff controls:
 *   cuton, cutoff - define the depth range (z range from the origin, in
 *       light coordinates) over which the light is active.  Outside
 *       this range, no energy is transmitted.
 *   nearedge, faredge - define the width of the transition regions
 *       for the cuton and cutoff.  The transitions will be smooth.
 *   falloff - defines the exponent for falloff.  A falloff of 0 (the
 *       default) indicates that the light is the same brightness
 *       regardless of distance from the source.  Falloff==1 indicates
 *       linear (1/r) falloff, falloff==2 indicates 1/r^2 falloff
 *       (which is physically correct for point-like sources, but
 *       sometimes hard to use).
 *   falloffdist - the distance at which the incident energy is actually
 *       equal to intensity*lightcolor.  In other words, the intensity
 *       is actually given by:   I = (falloffdist / distance) ^ falloff
 *   maxintensity - to prevent the light from becoming unboundedly
 *       large when the distance < falloffdist, the intensity is
 *       smoothly clamped to this maximum value.
 *   parallelrays - when 0 (the default), the light appears to emanate
 *       from a single point (i.e., the rays diverge).  When nonzero, 
 *       the light rays are parallel, as if from an infinitely distant
 *       source (like the sun).
 *
 * Shaping of the cross-section.  The cross-section of the light cone
 * is actually described by a superellipse with the following
 * controls:
 *   shearx, sheary - define the amount of shear applied to the light
 *       cone direction.  Default is 0, meaning that the center of the
 *       light cone is aligned with the z-axis in local light space.
 *   width, height - define the dimensions of the "barn door" opening.
 *       They are the cross-sectional dimensions at a distance of 1
 *       from the light.  In other words, width==height==1 indicates a
 *       90 degree cone angle for the light.
 *   wedge, hedge - the amount of width and height edge fuzz,
 *       respectively.  Values of 0 will make a sharp cutoff, larger
 *       values (up to 1) will make the edge softer.
 *   roundness - controls how rounded the corners of the superellipse
 *       are.  If this value is 0, the cross-section will be a perfect
 *       rectangle.  If the value is 1, the cross-section will be a
 *       perfect ellipse.  In-between values control the roundness of
 *       the corners in a fairly obvious way.
 *   beamdistribution - controls intensity falloff due to angle.
 *       A value of 0 (the default) means no angle falloff.  A value
 *       of 1 is roughly physically correct for a spotlight and 
 *       corresponds to a cosine falloff.  For a BMRT area light, the
 *       cosine falloff happens automatically, so 0 is the right physical
 *       value to use.  In either case, you may use larger values to
 *       make the spot more bright in the center than the outskirts.
 *       This parameter has no effect for omni lights.
 *
 * Cookie or slide filter:
 *   slidename - if a filename is supplied, a texture lookup will be
 *       done and the light emitted from the source will be filtered
 *       by that color, much like a slide projector.  If you want to
 *       make a texture map that simply blocks light, just make it
 *       black-and-white, but store it as an RGB texture.  For
 *       simplicity, the shader assumes that the texture file will
 *       have at least three channels.
 *
 * Projected noise on the light:
 *   noiseamp - amplitude of the noise.  A value of 0 (the default) 
 *       means not to use noise.  Larger values increase the blotchiness
 *       of the projected noise.
 *   noisefreq - frequency of the noise.
 *   noiseoffset - spatial offset of the noise.  This can be animated,
 *       for example, you can use the noise to simulate the
 *       attenuation of light as it passes through a window with 
 *       water drops dripping down it.
 * 
 * Shadow mapped shadows.  For PRMan (and perhaps other renderers),
 * shadows are mainly computed by shadow maps.  Please consult the
 * PRMan documentation for more information on the meanings of these
 * parameters.
 *   shadowname - the name of the texture containing the shadow map.  If
 *       this value is "" (the default), no shadow map will be used.
 *   shadowblur - how soft to make the shadow edge, expressed as a
 *       percentage of the width of the entire shadow map.
 *   shadowbias - the amount of shadow bias to add to the lookup.
 *   shadownsamps - the number of samples to use.
 *
 * Ray-traced shadows.  These options work only for BMRT:
 *   raytraceshadow - if nonzero, cast rays to see if we are in shadow.
 *       The default is zero, i.e., not to try raytracing.
 *   nshadowrays - The number of rays to trace to determine shadowing.
 *   shadowcheat - add this offset to the light source position.  This
 *       allows you to cause the shadows to emanate as if the light
 *       were someplace else, but without changing the area
 *       illuminated or the appearance of highlights, etc.
 *
 * "Fake" shadows from a blocker object.  A blocker is a superellipse
 * in 3-space which effectively blocks light.  But it's not really
 * geometry, the shader just does the intersection with the
 * superellipse.  The blocker is defined to lie on the x-y plane of
 * its own coordinate system (which obviously needs to be defined in
 * the RIB file using the CoordinateSystem command).
 *   blockercoords - the name of the coordinate system that defines the
 *       local coordinates of the blocker.  If this is "", it indicates 
 *       that the shader should not use a blocker at all.
 *   blockerwidth, blockerheight - define the dimensions of the blocker's
 *       superellipse shape.
 *   blockerwedge, blockerhedge - define the fuzzyness of the edges.
 *   blockerround - how round the corners of the blocker are (same
 *       control as the "roundness" parameter that affects the light
 *       cone shape.
 *
 * Joint shadow controls:
 *   shadowOpacity - default 1, shadows will be fully opaque.  Values less
 *      than this will become lighter.
 *   shadowcolor - Shadows (i.e., those regions with "occlusion" as
 *       defined by any or all of the shadow map, ray cast, or
 *       blocker) don't actually have to block light.  In fact, in
 *       this shader, shadowed regions actually just change the color
 *       of the light to "shadowcolor".  If this color is set to
 *       (0,0,0), it effectively blocks all light.  But if you set it
 *       to, say (.25,.25,.25), it will make the shadowed regions lose
 *       their full brightness but not go completely dark.  Another
 *       use is if you are simulating sunlight: set the lightcolor to
 *       something yellowish and make the shadowcolor dark but
 *       somewhat bluish.  Another effect of shadows is to set the
 *       __nonspecular flag so that the shadowed regions are lit only
 *       diffusely, without highlights.
 * 
 * Other controls:
 *   nonspecular - when set to 1, this light does not create
 *       specular highlights!  The default is 0, which means it makes
 *       highlights just fine (except for regions in shadows, as
 *       explained above).  This is very handy for lights that are
 *       meant to be fill lights, rather than key lights.
 *       NOTE: This depends on the surface shader looking for, and
 *       correctly acting upon, this parameter.  The built-in functions
 *       diffuse(), specular() and phong() all do this, for PRMan 3.5
 *       and later, as well as BMRT 2.3.5 and later.  But if you write
 *       your own illuminance loops in your surface shader, you've got
 *       to account for it yourself.  The PRMan user manual explains how
 *       to do this.
 *   __nondiffuse - the analog to nonspecular; if this flag is set to
 *       1, this light will only cast specular highlights but not
 *       diffuse light.  This is useful for making a light that only
 *       makes specular highlights, without affecting the rest of the
 *       illumination in the scene.  All the same caveats apply with
 *       respect to the surface shader, as described above for
 *       __nonspecular.
 *   __foglight - the "noisysmoke" shader distributed with BMRT will add
 *       atmospheric scattering only for those lights that have this
 *       parameter set to 1 (the default).  In other words, if you use
 *       this light with noisysmoke, you can set this flag to 0 to
 *       make a particular light *not* cause illumination in the fog.
 *       Note that the noisysmoke shader is distributed with BMRT but
 *       will also work just fine with PRMan (3.7 or later).
 *
 * NOTE: this shader has one each of: blocker, shadow map, slide, and
 * noise texture.  Some advanced users may want more than one of some or
 * all of these.  It is left as an exercise for the reader to make such
 * extensions to the shader.
 *
 ***************************************************************************
 *
 * This shader was written as part of the course notes for ACM
 * SIGGRAPH '98, course 11, "Advanced RenderMan: Beyond the Companion"
 * (co-chaired by Tony Apodaca and Larry Gritz).  Feel free to use and
 * distribute the source code of this shader, but please leave the
 * original attribution and all comments.
 *
 * This shader was tested using Pixar's PhotoRealistic RenderMan 3.7
 * and the Blue Moon Rendering Tools (BMRT) release 2.3.6.  I have
 * tried to avoid Shading Language constructs which wouldn't work on
 * older versions of these renderers, but I do make liberal use of the
 * "vector" type and I often declare variables where they are used,
 * rather than only at the beginning of blocks.  If you are using a
 * renderer which does not support these new language features, just
 * substitute "point" for all occurrances of "vector", and move the
 * variable declarations to the top of the shader.
 *
 * Author: coded by Larry Gritz, 1998
 *         based on paper by Ronen Barzel, 1997
 *
 *
 *
 * Revision: 1.3    Date: 1999/11/11 23:22:44
 *
 * $Id: l_uber.sl,v 1.3 2002/04/02 08:01:03 tal Exp $
 ****************************************************************************/


/* Comment out the following line if you do *not* wish to use BMRT and
 * PRMan together.
 */
/* for now #include "rayserver.h" */

#define SHAD_WBIAS(sname, psurf, sblur, ssamples, sopacity, sbias) \
  (sopacity * (sbias != -1)? \
     shadow (sname, psurf, "blur", sblur, "samples", ssamples, "bias", sbias):\
     shadow (sname, psurf, "blur", sblur, "samples", ssamples))

#define SOFTSHAD_WBIAS(sname, psurf, pl1, pl2, pl3, pl4, sblur, ssamples, sopacity, sbias, sgapbias) \
  (sopacity * (sbias != -1)? \
     shadow (sname, psurf, "source", pl1, pl2, pl3, pl4, "blur", sblur, "samples", ssamples, "bias", sbias, "gapbias", sgapbias):\
     shadow (sname, psurf, "source", pl1, pl2, pl3, pl4, "blur", sblur, "samples", ssamples, "gapbias", sgapbias))


/* Superellipse soft clipping
 * Input:
 *   - point Q on the x-y plane
 *   - the equations of two superellipses (with major/minor axes given by
 *        a,b and A,B for the inner and outer ellipses, respectively)
 * Return value:
 *   - 0 if Q was inside the inner ellipse
 *   - 1 if Q was outside the outer ellipse
 *   - smoothly varying from 0 to 1 in between
 */
float
clipSuperellipse (point Q;          /* Test point on the x-y plane */
		  float a, b;       /* Inner superellipse */
		  float A, B;       /* Outer superellipse */
		  float roundness;  /* Same roundness for both ellipses */
		 )
{
    float result = 0;
    float x = abs(xcomp(Q)), y = abs(ycomp(Q));
    if (x != 0 || y != 0) {  /* avoid degenerate case */
	if (roundness < 1.0e-6) {
	    /* Simpler case of a square */
	    result = 1 - (1-smoothstep(a,A,x)) * (1-smoothstep(b,B,y));
	} else if (roundness > 0.9999) {
	    /* Simple case of a circle */
	    float sqr (float x) { return x*x; }
	    float q = a * b / sqrt (sqr(b*x) + sqr(a*y));
	    float r = A * B / sqrt (sqr(B*x) + sqr(A*y));
	    result = smoothstep (q, r, 1);
	} else {
	    /* Harder, rounded corner case */
	    float re = 2/roundness;   /* roundness exponent */
	    float q = a * b * pow (pow(b*x, re) + pow(a*y, re), -1/re);
	    float r = A * B * pow (pow(B*x, re) + pow(A*y, re), -1/re);
	    result = smoothstep (q, r, 1);
	}
    }
    return result;
}





/* Volumetric light shaping
 * Inputs:
 *   - the point being shaded, in the local light space
 *   - all information about the light shaping, including z smooth depth
 *     clipping, superellipse x-y shaping, and distance falloff.
 * Return value:
 *   - attenuation factor based on the falloff and shaping
 */
float
ShapeLightVolume (point PL;                      /* Point in light space */
		  string lighttype;              /* what kind of light */
		  vector axis;                   /* light axis */
                  float znear, zfar;             /* z clipping */
		  float nearedge, faredge;
		  float falloff, falloffdist;    /* distance falloff */
		  float maxintensity;
		  float shearx, sheary;          /* shear the direction */
		  float width, height;           /* xy superellipse */
		  float hedge, wedge, roundness;
		  float beamdistribution;        /* angle falloff */
		  )
{	
    /* Examine the z depth of PL to apply the (possibly smooth) cuton and
     * cutoff.
     */
    float atten = 1;
    float PLlen = length(PL);
    float Pz;
    if (lighttype == "spot" || lighttype == "directional") {
	Pz = zcomp(PL);
    } else {
	/* For omni or area lights, use distance from the light */
	Pz = PLlen;
    }
    atten *= smoothstep (znear-nearedge, znear, Pz);
    atten *= 1 - smoothstep (zfar, zfar+faredge, Pz);
    
    /* Distance falloff */
    if (falloff != 0) {
	if (PLlen > falloffdist) {
	    /*atten *= pow (falloffdist/PLlen, falloff); */
	    atten *= pow (1/(PLlen-falloffdist), falloff);
	} else {
	    float s = log (1/maxintensity);
	    float beta = -falloff/s;
	    atten *= (maxintensity * exp (s * pow(PLlen/falloffdist, beta)));
	}
    }

    /* Clip to superellipse */
    if (lighttype != "omni" && beamdistribution > 0)
	atten *= pow (zcomp(normalize(vector PL)), beamdistribution);
    if (lighttype == "spot") {
	atten *= 1 - clipSuperellipse (point (PL/Pz-point(shearx,sheary,0)),
				       width, height,
				       width+wedge, height+hedge, roundness);
    }
    return atten;
}




/* Evaluate the occlusion between two points, P1 and P2, due to a fake
 * blocker.  Return 0 if the light is totally blocked, 1 if it totally
 * gets through.
 */
float
BlockerContribution (point P1, P2;
		     string blockercoords;
		     float blockerwidth, blockerheight;
		     float blockerwedge, blockerhedge;
		     float blockerround;
                    )
{
    float unoccluded = 1;
    /* Get the surface and light positions in blocker coords */
    point Pb1 = transform (blockercoords, P1);
    point Pb2 = transform (blockercoords, P2);
    /* Blocker works only if it's straddled by ray endpoints. */
    if (zcomp(Pb2)*zcomp(Pb1) < 0) {
	vector Vlight = (Pb1 - Pb2);
	point Pplane = Pb1 - Vlight*(zcomp(Pb1)/zcomp(Vlight));
	unoccluded *= clipSuperellipse (Pplane, blockerwidth, blockerheight,
					blockerwidth+blockerwedge,
					blockerheight+blockerhedge,
					blockerround);
    }
    return unoccluded;
}


light l_uber /* A light with many fun controls. See the source code for attributions and comments. */
(
  /* Shadow mapped shadows */
  string shadowname = ""; /* type shadow desc {Under MTOR the common setting for this is [shdname $OBJNAME].} */

  /* pointlight shadows -- first pass and not following Pixar standard Tal 1/29/02 */

#ifdef USE_POINT_SHADOW
  string spx = "";
  /* cat pointShadows type shadow name {Shd Pos X} 
     desc { point light shadow in positive X direction. Typical usage: [shdmap $OBJNAME px] } */
  string snx = "";
  /* cat pointShadows type shadow name {Shd Neg X} 
     desc { point light shadow in negative X direction. Typical usage: [shdmap $OBJNAME nx] } */
  string spy = "";
  /* cat pointShadows type shadow name {Shd Pos Y} 
     desc { point light shadow in positive Y direction. Typical usage: [shdmap $OBJNAME py] } */
  string sny = "";
  /* cat pointShadows type shadow name {Shd Neg Y} 
     desc { point light shadow in negative Y direction. Typical usage: [shdmap $OBJNAME ny] } */
  string spz = "";
  /* cat pointShadows type shadow name {Shd Pos Z} 
     desc { point light shadow in positive Z direction. Typical usage: [shdmap $OBJNAME pz] } */
  string snz = "";
  /* cat pointShadows type shadow name {Shd Neg Z} 
     desc { point light shadow in negative Z direction. Typical usage: [shdmap $OBJNAME nz] } */
#endif /*  USE_POINT_SHADOW */


  float shadowblur = 0.01; /* range {0 1 .001} type slider
			      desc {how soft to make the shadow edge, expressed as a percentage of the width of the entire shadow map.}  cat miscShadow */
  float shadowbias = -1; /* desc {the amount of shadow bias to add to the lookup. A value of -1 means to use the global shadowbias.  A value of 0 should be used when "midpoint" is turned on. } cat miscShadow */
  float shadownsamps = 16; /* range {
	"1" 1
	"4" 4
	"9" 9
	"16" 16
	"25" 25
	"36" 36
	"64" 64
      }
    type selector desc {Controls supersampling of the shadowmap.} cat miscShadow */
  color shadowcolor = 0; /* provider expression
			    expr {[mattr $OBJNAME.shadowColor $f]}
			   desc {Shadows (i.e. those regions with occlusion as defined by any or all of the shadow map, ray cast, or blocker) don't actually have to block light. In fact, in this shader, shadowed regions actually just change the color of the light to shadowcolor. If this color is set to (0,0,0), it effectively blocks all light. But if you set it to, say (.25,.25,.25), it will make the shadowed regions lose their full brightness, but not go completely dark. Another use is if you are simulating sunlight: set the lightcolor to something yellowish, and make the shadowcolor dark but somewhat bluish. Another effect of shadows is to set the __nonspecular flag, so that the shadowed regions are lit only diffusely, without highlights.} cat miscShadow */
  float shadowOpacity = 1.0; /* range {0 1} type slider
    desc {Lightens the shadow map, making it look less opaque.} cat miscShadow */

#ifdef USE_PRMAN_SOFTS
  float want_softShadows = 0;
  /* cat SoftShadows type switch desc {Turn switch on to enable softshadows}*/
  float softShadowSize = 1.0;
  /* cat SoftShadows desc {Size of 'arealight'.  The larger the size the
     faster the shadow will appear softer.  Make sure that this size matches
     the "softsize" paramter in the Soft Shadow Controls of the shadowmap.} */
  float softShadow_gapBias = 0;
  /* cat SoftShadows */
#endif

  /* Basic intensity and color of the light */
  uniform float lighttype = 0; /* type selector
				range {
				"spot" 0
				"omni(point)" 1
				"area(BMRT)" 2
				"directional" 3
				}
				def {0}
				provider expression
				expr {[if {[mel "objectType $OBJNAME"] == "pointLight"}
				{return 1}
				else
				{[if {[mel "objectType $OBJNAME"] == "spotLight"}
				{return 0}
				else
				{return 3}]}
				]}
				desc {The type of light source.  Use spot for lights that point in a particular direction, from a particular position (ie. spot).  Use omni for light to cast light in all directions (ie. point).  Use distant for lights that point in a particular direction, from any position (ie. distant).} */
				
  float parallelrays = 0; /* range {0 1} type switch
			     provider expression
			     expr {[if {[mel "objectType $OBJNAME"] == "directionalLight"} {return 1} else {return 0}]}
			     desc {when off, the light apepar to eminate from 
			     a single point (i.e. the rays diverge). When on, 
			     the light rays are parallel, as if from an 
			     infinitely distant source (like the sun).} */
  color lightcolor = color (1,1,1); /* desc {overall color filtering 
				       for the light.} 
				       provider expression
				       expr {[mattr $OBJNAME.color $f]} 
				    */
  float intensity = 1; /* desc {overall intensity scaling of the 
			  light.}  
			  expr {[if {$OBJNAME == "slimobj"}
			  {return 1}
			  else {mattr $OBJNAME.intensity $f}
			  ]}
			  provider expression
			  cat Light_Falloff
		       */
  float coneAngle = .006; /* range {0 89.97} type slider
			   expr { [if {[mel "attributeQuery -node $OBJNAME -exists coneAngle"] == "1"}
			   {expr [mattr $OBJNAME.coneAngle $f]}
			   else {
			   return 0.006}]}
			   provider expression 
			  desc {This parameter only has any meaning for true spot lights.  Hotter core of the light.  A surface point that lies withing this coneAngle will not have any cosine falloff.} 
 cat Light_Falloff */
  float penumbraAngle = 5; /* range {0 89.97} type slider
			      expr { [if {[mel "attributeQuery -node $OBJNAME -exists penumbraAngle"] == "1"}
			      {expr [mattr $OBJNAME.penumbraAngle $f]}
			      else {
			      return 5} ]}
			      provider expression 
			   desc {This parameter only has any meaning for true spot lights.  A surface point that lies outside coneAngle+penumbraAngle will not recieve any light from this light source.  A surface point that is somewhere in between those two angles will have a cosine falloff.} 
 cat Light_Falloff */


  float falloff = 0;  /*  range {0 4} type slider
			  name decayRate
			  desc {defines the exponent for falloff. A falloff of 
			  0 indicates that the light is the same brightness 
			  regardless of distance from source. falloff == 1 
			  indicates linear, falloff == 2 indicates 
			  physically-correct inverse squared falloff.} 
			  provider expression
			  expr {[if {$OBJNAME == "slimobj"}
			  {return 0} else {mattr $OBJNAME.decayRate $f}]}
			  cat Light_Falloff */
  float falloffdist = 1; /* range {0 100} type slider
			    name dropoff
			    desc {the distance at which the incident energy is 
			    actually equal to the intensity * lightcolor. In 
			    other words, the intensity is actually given by: 
			    I = (falloffdist / distance) ^ falloff} 
			    expr {[if {[mel "attributeQuery -node $OBJNAME -exists dropoff"] == "1"}
			    {expr [mattr $OBJNAME.dropoff $f]}
			    else
			    {return 0}
			    ]}
			    provider expression
			    cat Light_Falloff */
  float maxintensity = 1; /* range {0 4} type slider
			     desc {to prevent the light from becoming 
			     unboundedly large when the distance < fallofdist, 
			     the intensity is smoothly clamped to this maximum 
			     value.} cat Light_Falloff */

  float blocker_leftdoor = 90; /* range {0 90} type slider cat BlockerDoors 
			       expr { [if {[mel "attributeQuery -node $OBJNAME -exists barnDoors"] == "1"}
			       {[if {[mattr $OBJNAME.barnDoors $f]}
			       {return [mattr $OBJNAME.leftBarnDoor $f]}
			       else {return 90}]}
			       else {return 90}]}
			       provider expression */
  float blocker_rightdoor = 90; /* range {0 90} type slider cat BlockerDoors 
			       expr { [if {[mel "attributeQuery -node $OBJNAME -exists barnDoors"] == "1"}
			       {[if {[mattr $OBJNAME.barnDoors $f]}
			       {return [mattr $OBJNAME.rightBarnDoor $f]}
			       else {return 90}]}
			       else {return 90}]}
				provider expression */
  float blocker_topdoor = 90; /* range {0 90} type slider cat BlockerDoors 
			       expr { [if {[mel "attributeQuery -node $OBJNAME -exists barnDoors"] == "1"}
			       {[if {[mattr $OBJNAME.barnDoors $f]}
			       {return [mattr $OBJNAME.topBarnDoor $f]}
			       else {return 90}]}
			       else {return 90}]}
			      provider expression */
  float blocker_bottomdoor = 90; /* range {0 90} type slider cat BlockerDoors 
			       expr { [if {[mel "attributeQuery -node $OBJNAME -exists barnDoors"] == "1"}
			       {[if {[mattr $OBJNAME.barnDoors $f]}
			       {return [mattr $OBJNAME.bottomBarnDoor $f]}
			       else {return 90}]}
			       else {return 90}]}
				 provider expression */
  float blocker_dooredge = 0.02; /* range {0 1} type slider cat BlockerDoors */

  /* Z shaping and distance falloff */
  float cuton = 0.01;  /* range {0 100} type slider
			  desc {defines the minimum z value of the depth range 
			  over which the light is active. Outside this range, 
			  no energy is transmitted.} cat Shaping_falloff 
			  expr { [if {[mel "attributeQuery -node $OBJNAME -exists useDecayRegions"] == "1"}
			  { [if {[mattr $OBJNAME.useDecayRegions $f]}
			  { return [mattr $OBJNAME.startDistance1 $f]}
			  else { return 0.01 }]}
			  else { return 0.01 }]}
			  provider expression */
  float cutoff = 1.0e6;  /* range {0 100} type slider
			    desc {defines the maximum z value of the depth 
			    range over which the light is active. Outside 
			    this range, no energy is transmitted.} 
			    cat Shaping_falloff 
			  expr { [if {[mel "attributeQuery -node $OBJNAME -exists useDecayRegions"] == "1"}
			  { [if {[mattr $OBJNAME.useDecayRegions $f]}
			  { return [mattr $OBJNAME.endDistance1 $f]} 
			  else { return  1.0e6 }]}
			  else { return  1.0e6 }]}
			    provider expression */
  float nearedge = 0;  /* range {0 10} type slider
			  desc {with faredge, defines the width of the 
			  transition regions for the cuton and cutoff. The 
			  transitions will be smooth.} cat Shaping_falloff */
  float faredge = 0;  /*  range {0 10} type slider
			  desc {with nearedge, defines the width of the 
			  transition regions for the cuton and cutoff. The 
			  transitions will be smooth.} cat Shaping_falloff */

  /* xy shaping of the cross-section and angle falloff */
  float shearx = 0; /* range {0 4} type slider
		       desc {one of many controls for shaping the light 
		       cross-section. The cross-section is actually described 
		       by a superellipse where shearx defines the amount of 
		       shear applied to the light cone direction.} cat Shaping_falloff */
  float sheary = 0; /* range {0 4} type slider
		       desc {one of many controls for shaping the light 
		       cross-section. The cross-section is actually described 
		       by a superellipse where sheary defines the amount of 
		       shear applied to the light cone direction.} cat Shaping_falloff */
  float beamdistribution = 0; /* range {0 1} type slider
				 desc {NOTE: penumbraAngle replaces this.  One of many controls for shaping the light cross-section. The cross-section is actually described by a superellipse where beamdistribution controls intensity falloff due to angle. A value of 0 (the default) means no angle falloff. A value of 1 is roughly physically correct for a spotlight, and corresponds to a cosine falloff. For a BMRT area light, the cosine falloff happens automatically, so 0 is the right physical value to use. In either case, you may use larger values to make the spot more bright in the center than the outskirts. This parameter has no effect for omni lights.} cat Shaping_falloff */

  /* Cookie or slide to control light cross-sectional color */
  string slidename = "";  /* type texture
			     desc {if a filename is supplied, a texture lookup will be done and the light emitted from the source will be filtered by that color, much like a slide projector. If you want to make a texture map that simply blocks light, just make it black-and-white, but store it as a RGB texture. For simplicity, the shader assumes that the texture file will have at least three channels.} */

  /* Noisy light */
  float noiseamp = 0; /* range {0 4} type slider
			 desc {amplitude of the noise projected onto the light. A value of 0 means not to use noise. Larger values increase the blotchiness of the projected noise.} cat Noisey_light */
  float noisefreq = 4; /* range {0 50} type slider
			  desc {frequency of the noise projected onto the 
			  light.} cat Noisey_light */
  vector noiseoffset = 0; /* desc {spatial offset of the noise. This can be animated, for example if you are using the noise to simulate the attenuation of light as it passes through a window with water drops dripping down it.} cat Noisey_light */

  float width = 1;  /* range {0 4} type slider
		       desc {one of many controls for shaping the light cross-section. The cross-section is actually described by a superellipse where width defines the dimensions of the barn door opening. They are the cross-sectional dimensions at a distance of 1 from the light. In other words, width==height==1 indicates a 90 degree cone angle for the light.} cat Sellipse */
/* expr {[mattr $OBJNAME.coneAngle $f]/90} provider variable
 */
  float height = 1; /* range {0 4} type slider
		       desc {one of many controls for shaping the light cross-section. The cross-section is actually described by a superellipse where height defines the dimensions of the barn door opening. They are the cross-sectional dimensions at a distance of 1 from the light. In other words, width==height==1 indicates a 90 degree cone angle for the light.} cat Sellipse */
/* expr {[mattr $OBJNAME.coneAngle $f]/90} provider variable
 */
  float wedge = 0; /* range {0 1} type slider
		       desc {one of many controls for shaping the light cross-section. The cross-section is actually described by a superellipse where wedge controls the amount of width edge fuzz. Values of 0 will make a sharp cutoff, large values make the edge softer.} cat Sellipse */
/* expr {1 - ([mattr $OBJNAME.coneAngle $f] - [mattr $OBJNAME.penumbraAngle $f])/[mattr $OBJNAME.coneAngle $f]} 
provider variable
 */
  float hedge = 0; /* range {0 1} type slider
		       desc {one of many controls for shaping the light cross-section. The cross-section is actually described by a superellipse where wedge controls the amount of height edge fuzz. Values of 0 will make a sharp cutoff, large values make the edge softer.}  cat Sellipse */
  /* expr {1 - ([mattr $OBJNAME.coneAngle $f] - [mattr $OBJNAME.penumbraAngle $f])/[mattr $OBJNAME.coneAngle $f]} 
provider variable
cat Sellipse */

  float roundness = 1; /* range {0 1} type slider
			  desc {one of many controls for shaping the light cross-section. The cross-section is actually described by a superellipse where roundness controls how rounded the corners of the superellipse are. If this value is 0, the cross-section will be a perfect rectangle. If the value is 1, the cross-section will be a perfect circle. In between values control the roundness of the corners in a fairly obvious way.} cat Sellipse */

  /* Ray traced shadows */
  float raytraceshadow = 0; /* range {0 1} type switch
			       desc {if nonzero, cast a ray to see if we are in shadow. The default is zero, i.e. not to try raytracing. This option only works if your renderer supports ray tracing.} cat Raytrace */
  float nshadowrays = 1; /* desc {Number of shadow rays to cast. This option only works if your renderer supports ray tracing.} cat Raytrace */ 
  vector shadowcheat = vector "shader" (0,0,0); /* desc {add this offset to the light source position. This allows you to cause the shadows to eminate as if the light were someplace else, but without changing the area illuminated or the appearance of highlights, etc. This option only works if your renderer supports ray tracing.} cat Raytrace */

  /* Fake blocker shadow */
  string blockercoords = ""; /* desc {Fake shadows from a blocker object. A blocker is a superellipse in 3-space which effectively blocks light. But it's not really geometry, the shader just does the intersection with the superellipse. The blocker is defined to lie on the x-y plane of its own coordinate system (which obviously needs to be defined in the RIB file using the CoordinateSystem command).} cat Blocker vis hidden */
  float blockerwidth=1; /* range {0 4} type slider
			   desc {define the dimensions of the blocker's 
			   superellipse shape.} cat Blocker  vis hidden */

  float blockerheight=1; /* range {0 4} type slider
			    desc {define the dimensions of the blocker's 
			    superellipse shape.} cat Blocker  vis hidden */

  float blockerwedge=.1; /* range {0 1} type slider
			    desc {define the fuzzyness of the blockers
			    edges.} cat Blocker  vis hidden */

  float blockerhedge=.1; /* range {0 1} type slider
			    desc {define the fuzzyness of the blockers edges.} cat Blocker  vis hidden */

  float blockerround=1; /*  range {0 1} type slider
			    desc {how round the corners of the blocker are (same control as the roundness parameter that affects the light cone shape).} cat Blocker  vis hidden */


  /* Miscellaneous controls */
  float nonspecular = 0; /* range {0 1} type switch
			    name __nonspecular
			    desc {If true, light will not contribute 
			    to specularity} cat Contributes */

  output varying float __nonspecular = 0; /* vis hidden
					     cat Contributes */
  output float __nondiffuse = 0; /* range {0 1} type switch
				    desc {If true, light will not contribute to diffuse.} cat Contributes */
  output float __eyeHighlight = 0;   /* type switch
					desc {If true, light will contribute 
					to the eye highlight. } 
					cat Contributes */
  output float __emitTones = 0;     /* type switch
				       desc {If true, light will contribute
				       to tone shading. }
					cat Contributes */
				       
  output float __foglight = 0;   /* range {0 1} type switch
				    desc {If true, light is a fog light} 
				    cat Contributes */
  output uniform float __useGooch = 0; /* vis hidden */ /* not used anymore */

  output varying float out_intensity = 1; /* vis hidden */
  output uniform float max_intensity = 1; /* vis hidden */
  output varying float __inShadow = 0; /* vis hidden */
  output uniform float fill_Contrib = 0; /*  type switch cat Contributes */ 

)
{
    /* For simplicity, assume that the light is at the origin of shader
     * space and aimed in the +z direction.  So to move or orient the
     * light, you transform the coordinate system in the RIB stream, prior
     * to instancing the light shader.  But that sure simplifies the
     * internals of the light shader!  Anyway, let PL be the position of
     * the surface point we're shading, expressed in the local light
     * shader coordinates.
     */
    point PL = transform ("shader", Ps);

#ifdef BMRT
    /* If it's an area light, we want the point and normal of the light
     * geometry.  If not an area light, BMRT guarantees P,N will be the
     * origin and z-axis of shader space.
     */
    point from = P;
    point int_from = from;
    vector axis = normalize(N);
#else
    /* For PRMan, we've gotta do it the hard way */
    point int_from = point "shader" (0,0,0);
    vector axis = normalize(vector "shader" (0,0,1));
#endif

    uniform float shadowOpacityAdj = 1 - clamp (shadowOpacity, 0, 1);
    uniform float angle;
    /* .006 is maya's mininum value for coneAngles */
    uniform float haveConeAngle = (coneAngle > .006)? 1 : 0;
    uniform float rad_angle = radians (coneAngle/2);
    uniform float rad_deltaAngle = radians (penumbraAngle/2);
    uniform float cos_inner = cos (rad_angle);
    uniform float cos_outer = cos (rad_angle + rad_deltaAngle);
    uniform string lighttypeStr;

    if (lighttype == 0) {                  /* Spot light */
	uniform float maxradius = 1.4142136 * max(height+hedge+abs(sheary),
						  width+wedge+abs(shearx));
	angle = (haveConeAngle == 1)? acos (cos_outer) : atan(maxradius);
	lighttypeStr = "spot";
    } else if (lighttype == 2) {	/* BMRT area light */
	angle = PI/2;
	lighttypeStr = "arealight";
    } else if (lighttype == 3) {                /* Directional light */
	angle = PI;
	lighttypeStr = "directional";
    } else {                                    /* Omnidirectional light */
	angle = PI;
	lighttypeStr = "omni";
    }
    __nonspecular = nonspecular;
    __inShadow = 0;

    float intens = 1;

#ifdef USE_PRMAN_SOFTS 

	uniform float softSize = softShadowSize * 0.5;

	uniform point Pl1 = point "shader" (-softSize, -softSize, 0);
	uniform point Pl2 = point "shader"(-softSize, softSize, 0);
	uniform point Pl3 = point "shader"(softSize, -softSize, 0);
	uniform point Pl4 = point "shader"(softSize, softSize, 0);

#endif
#if 1
    illuminate (int_from, axis, angle) {
#else


illuminate (point (vector Pl1+ vector Pl2+ vector Pl3+ vector Pl4)*0.25) {


#endif

	/* Accumulate attenuation of the light as it is affected by various
	 * blockers and whatnot.  Start with no attenuation (i.e., a 
	 * multiplicative attenuation of 1.
	 */
	float atten = 1.0;
	color lcol = lightcolor;

	/* Basic light shaping - the volumetric shaping is all encapsulated
	 * in the ShapeLightVolume function.
	 */
	atten *= ShapeLightVolume (PL, lighttypeStr, axis, cuton, cutoff,
				   nearedge, faredge, falloff, falloffdist,
				   maxintensity/intensity, shearx, sheary,
				   width, height, hedge, wedge, roundness,
				   beamdistribution);

	/* Project a slide or use a cookie */
	if (slidename != "") {
	    point Pslide = PL / point (width+wedge, height+hedge, 1);
	    float zslide = zcomp(Pslide);
	    float xslide = 0.5+0.5*xcomp(Pslide)/zslide;
	    float yslide = 0.5-0.5*ycomp(Pslide)/zslide;
	    lcol *= color texture (slidename, 1-xslide, yslide);
	}
	
#if 1 /* barn door and penumbraAngle controls for Maya */
	if (haveConeAngle == 1) {

	    /* cos falloff for penumbraAngle */
	    vector Lns = normalize (vtransform ("shader", L));
	    float cosangle =  normalize (L) .  axis;
	    atten *= smoothstep (cos_outer, cos_inner, cosangle);

#define v3 1
#if 0
	    point Pproj = PL / point (cosangle, cosangle, 1) /*point (cos_outer, cos_outer, 1)*/ /* / point (1, 1, 1)*/;
	    float z = zcomp (Pproj);
	    float sloc = xcomp (Pproj)/z;
	    float tloc = ycomp (Pproj)/z;
#elif v2
	    float spread = 0.5 / tan (radians (coneAngle/2));
	    vector up = vector "shader" (0, 1, 0);
	    vector relT = normalize (axis - int_from);
	    vector relU = relT^up;
	    vector relV = normalize (relT^relU);
	    relU = relV^relT;
	    
	    vector myL = Ps - int_from;
	    float Pt = myL . relT;
	    float Pu = myL . relU;
	    float Pv = myL . relV;
	    float sloc = spread * Pu/Pt;
	    float tloc = spread * Pv/Pt;
#elif v3
	    float spread = 0.5 / tan (radians (coneAngle/2));
	    point Pls = /* transform ("shader", P); */ point "shader" (0, 0, 0);
	    Pls = transform ("shader", Pls);
	    point Pss = point (transform ("shader", Ps) - Pls);
	    float tau = (1 - zcomp (Pls)) / zcomp (Pss);
	    float sloc = xcomp (Pls) + tau * xcomp (Pss);
	    float tloc = ycomp (Pls) + tau * ycomp (Pss);
#if 0
	    printf ("P %.2p Pls %.2p tau %.2f Pss %.2p sloc %.2f tloc %.2f\n",
		    P, Pls, tau, Pss, sloc, tloc);
#endif
#endif

	    
	    /* barn door traps */
	    /* flipped btdoor and bbdoor */
#if v2
	    uniform float bbdoor = blocker_topdoor / (coneAngle);
	    uniform float btdoor = blocker_bottomdoor / (coneAngle);
#else
	    uniform float btdoor = blocker_topdoor / (coneAngle);
	    uniform float bbdoor = blocker_bottomdoor / (coneAngle);
#endif
	    uniform float bldoor = blocker_leftdoor / (coneAngle);
	    uniform float brdoor = blocker_rightdoor / (coneAngle);
	    atten *= smoothstep (-brdoor, -brdoor + blocker_dooredge, sloc) - smoothstep (bldoor - blocker_dooredge, bldoor, sloc);
	    atten *= smoothstep (-bbdoor, -bbdoor + blocker_dooredge, tloc) - smoothstep (btdoor - blocker_dooredge, btdoor, tloc);
	    
	}
#endif
	/* If the volume says we aren't being lit, skip the remaining tests */
	if (atten > 0) {
	    /* Apply noise */
	    if (noiseamp > 0) {
#pragma nolint
		float n = noise (noisefreq * (PL+noiseoffset) * point(1,1,0));
		n = smoothstep (0, 1, 0.5 + noiseamp * (n-0.5));
		atten *= n;
	    }

	    /* Apply shadow mapped shadows */
	    float unoccluded = 1;
	    if (shadowname != "") {

#ifdef USE_PRMAN_SOFTS 
		if (want_softShadows == 1) {

		    unoccluded *= 1 - 
			SOFTSHAD_WBIAS (shadowname, Ps, Pl1, Pl2, Pl3, Pl4,
					shadowblur, shadownsamps,
					shadowOpacity,
					shadowbias, softShadow_gapBias);

		    
		}
		else {
#endif /* USE_PRMAN_SOFTS */
		    unoccluded *= 
			1 - SHAD_WBIAS (shadowname, Ps, shadowblur, 
					shadownsamps, shadowOpacity, 
					shadowbias);

#ifdef USE_PRMAN_SOFTS 
		}
#endif /* USE_PRMAN_SOFTS */

	    }

#ifdef USE_POINT_SHADOW
	    {
	      vector Lrel;
	      float Lx, Ly, Lz, AbsLx, AbsLy, AbsLz;
	      uniform float i;
	      uniform string shdname;

	      /* From PRMan shadowpoint.sl */
	      Lrel = vtransform ("world", L);
	      Lx = xcomp (Lrel);
	      AbsLx = abs (Lx);
	      Ly = ycomp (Lrel);
	      AbsLy = abs (Ly);
	      Lz = zcomp (Lrel);
	      AbsLz = abs (Lz);

	      if ((AbsLx > AbsLy) && (AbsLx > AbsLz)) {
		if ((Lx > 0.0) && spx != "")
		  unoccluded *= 
		    1 - SHAD_WBIAS (spx, Ps, shadowblur, 
				   shadownsamps, shadowOpacity, shadowbias);
		else if (snx != "")
		  unoccluded *= 
		    1 - SHAD_WBIAS (snx, Ps, shadowblur, 
				   shadownsamps, shadowOpacity, shadowbias);
	      }
	      else if ((AbsLy > AbsLx) && (AbsLy > AbsLz)) {
		if ((Ly > 0.0) && spy != "")
		  unoccluded *= 
		    1 - SHAD_WBIAS (spy, Ps, shadowblur, 
				   shadownsamps, shadowOpacity, shadowbias);
		else if (sny != "")
		  unoccluded *= 
		    1 - SHAD_WBIAS (sny, Ps, shadowblur, 
				    shadownsamps, shadowOpacity, shadowbias);
	      }
	      else if ((AbsLz > AbsLy) && (AbsLz > AbsLx)) {
		if ((Lz > 0.0) && spz != "")
		  unoccluded *= 
		    1 - SHAD_WBIAS (spz, Ps, shadowblur, 
				   shadownsamps, shadowOpacity, shadowbias);
		else if (snz != "")
		  unoccluded *= 
		    1 - SHAD_WBIAS (snz, Ps, shadowblur, 
				    shadownsamps, shadowOpacity, shadowbias);
	      }
	    }
#endif /* USE_POINT_SHADOW */


	    point shadoworigin;
	    if (parallelrays == 0)
		 shadoworigin = int_from;
	    else shadoworigin = point "shader" (xcomp(PL), ycomp(PL), cuton);
#if (defined(BMRT) || defined(RAYSERVER_H))
	    /* If we can, apply ray cast shadows.  Force a ray trace if
	     * we're in BMRT and the user wanted a shadow map.
	     */
	    if (raytraceshadow != 0) {
		color vis = 0;
		uniform float i;
		for (i = 0;  i < nshadowrays;  i += 1)
		    vis += visibility (Ps, shadoworigin+shadowcheat);
		vis /= nshadowrays;
		unoccluded *= (comp(vis,0)+comp(vis,1)+comp(vis,2))/3;
	    }
#endif
	    /* Apply blocker fake shadows */
	    if (blockercoords != "") {
		unoccluded *= 
		    BlockerContribution (Ps, shadoworigin, blockercoords,
					 blockerwidth, blockerheight,
					 blockerwedge, blockerhedge,
					 blockerround);
	    }

	    /* adjust shadow opacity */
	    /*lcol = mix (shadowcolor, lcol, unoccluded);*/
#if 0
	    color tmpshadowcolor = clamp (color (shadowOpacityAdj) + shadowcolor, 
					  color 0, color 1);
	    /*printf ("sc %.3c; sopac %.3c newsh %.3c\n",
	      shadowcolor, color (shadowOpacityAdj), tmpshadowcolor); */

	    lcol = mix (tmpshadowcolor, lcol, unoccluded);
#else
	    lcol = mix (shadowcolor, lcol, /*(1+shadowOpacityAdj) * */unoccluded);
#endif
	    __inShadow = (1 - unoccluded);
	    __nonspecular = 1 - unoccluded * (1 - __nonspecular);
	}
	Cl = (atten*intensity) * lcol;
	if (parallelrays != 0)
	    L = axis * length(Ps-int_from);
	intens = atten;
    }

    max_intensity = intensity;
    out_intensity = intens;
}
