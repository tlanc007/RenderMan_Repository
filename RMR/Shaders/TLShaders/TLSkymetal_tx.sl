/* skymetal shader 
 * from p. 103 of Siggraph 1991 Course 21
 * The RenderMan Interface and Shading Language
 */
/*
 * TLSkymetal.sl -- procedural chrome shader based on Sig91_Skymetal.sl
 *
 * DESCRIPTION:
 *	Produces a chrome like effect procedurally.  It places the color
 *  based on the angle for P compared to some external vector.
 *
 *  By default it is assumed that this vector is based on "world" space.
 *  The only other space currently supported is "object" space.
 *
 *  This shader is based on the skymetal shader given on p. 103 of the
 *  Siggraph '91 RenderMan Course notes.
 *
 *  The sky_ and land_ variables should really be parameters.
 *
 * PARAMETERS:
 *	Ka, Ks    - the usual
 *  roughness - the usual
 *  Kr        - reflection factor
 *  sky_zenith- color of north pole
 *  sky_horiz - color above equator
 *  land_zenith- color of south pole
 *  land_horiz - color below equator
 *  up        - up comparison vector (default "world" space )
 *  upSpaceString - string denoting space that up should be used as.
 *
 * HINTS:
 *  Can work with versions of that don't have support for the vector
 *  type by setting the #define PREVECTOR to 1.
 *
 *  Use "object" space to attach the pattern to the object.  Use "world"
 *  to let the pattern move according relative to the objects orintation
 *  to "world" space.
 *
 * AUTHOR: Tal Lancaster
 *	tal AT renderman DOT org
 *
 * History:
 *	Created: 10/5/97
 *
 *  tal 10/8/07 added texture
 *
 */

/* 
 * Added macros to work with pre/post vector type.  Added code
 * to always assume that up is passed as world space.
 * Should really just add param telling what space up really is.
 *
 */
 
#define PREVECTOR 1

/* Define a set of macros to give the same interface for both versions
 * of renderman that have the vector type and those that don't.
 */
#if PREVECTOR
#	define vectorT point
#	define vtransform1(toSpace, v) \
 (transform (toSpace, v) - point toSpace (0, 0, 0))
#	define vtransform(fromSpace, toSpace, v) \
 (transform (fromSpace, toSpace, v) - point toSpace (0, 0, 0))
#	define vectorCvt(cvtSpace, v) \
 (point cvtSpace (v) - point cvtSpace (0, 0, 0))
#else
#	define vectorT vector
#	define vtransform1(toSpace, v) \
 (vtransform (toSpace, v))
#	define vectorCvt(cvtSpace, v) \
 (vector cvtSpace (v))
#endif

/*
 * Tests to see what space to convert to and returns the vector in
 * "current" space.
 *
 * SpaceString - string containg space to assign space as.
 * upSpace - vector for up vector
 * upCurr - vector in "current space
 */
#define SH_SPACE2_CURR(SpaceString, upSpace, upCurr) \
{ \
	if (SpaceString == "world") { \
		upSpace = vectorCvt ("world", upShader); \
		upCurr = vtransform ("world", "current", upSpace); \
	} \
	else if (SpaceString == "object") { \
		upSpace = vectorCvt ("object", upShader); \
		upCurr = vtransform ("object", "current", upSpace); \
	} \
	else /* if all else fails assume camera */ { \
		upSpace = vectorCvt ("camera", upShader); \
		upCurr = vtransform ("camera", "current", upSpace); \
	} \
}

surface TLSkymetal_tx (
  float Ka = 1, Ks = 1, Kr = .2;
  float roughness = .1;
  color sky_zenith = color (0.125, 0.162, 0.5);
  color sky_horiz = color (.4, .45, .8);
  color land_horiz = color (.0281, 0.0287, 0.0220);
  color land_zenith = color (0, 0, 0);
  vectorT up = vectorT (0, 1, 0);
  string upSpaceString = "world";
  string txMap = "";
)
{
	point Nf;                  /* normalized N */
	color Ct;                  /* Current color for P */
	color refl;                /* color based on reflection vector */
	float costheta;            /* angle of reflection vector and up */
	uniform vectorT upShader;  /* up in "shader" space */
	uniform vectorT upSpace;   /* up in someSpace based on upSpaceString */
	uniform vectorT upCurr;    /* up in "current" space (after re-converted) */
	uniform vectorT Nup;       /* normalized up */
	
	if (txMap != "") {
		Ct = texture (txMap, s, 1-t);
		Ct = mix (color (1, 1, 1), Ct, .5);
	}
	else {
		Ct = Cs;
	}
	/* Since the vector (or any point or normal) gets converted from the
	   space in effect when the shader was instantiated to the render's
	   native space ("camera for prman, "world" for BMRT), need to undo
	   these effects so it can be used in the way it was intended.
	   
	   All this assumes that the way the the RIB was generated we don't
	   know (or don't care) what the current transformations are in effect
	   to preconvert the value into shader space.  If that was the case
	   then the conversion that the renderer just did was what we wanted
	   and the rest of stuff wouldn't be needed.  Confused yet?  */
	   
	upShader = vtransform ("current", "shader", up);
	/* OK now have the value back to the value (or close enough) to what
	   it was for the shader instantiation.  So now perform the 
	   transformations to make the value usable.  
	   What are these?  First change it to the space we want (ie. value
	   was relative to "world", "object", etc.  Then change it to "current"
	   space to make it usable for the rest of the shader.
	   Why?  Well, all of the elements in a statement should be in the same
	   space or the results will be incorrect.  It is easier to convert one,
	   upCurr, rather two I and  Nf.
	 */ 
	SH_SPACE2_CURR (upSpaceString, upSpace, upCurr);
	
	/* normalize important */
	Nup = normalize (upCurr);
	Nf = normalize (faceforward (N, I));

	costheta = normalize (reflect (I, Nf)) . Nup;

	if (costheta >= 0.0)
		/* northen hemisphere */
		refl = mix (sky_horiz, sky_zenith, costheta);
	else 
		/* southen hemisphere */
		refl = mix (land_horiz, land_zenith, -costheta);
		
	Oi = Os;
	Ci = Os * Ct * (Kr*refl + (1-Kr) * (Ka * ambient () +
		Ks * specular (Nf, -I, roughness)));
}
