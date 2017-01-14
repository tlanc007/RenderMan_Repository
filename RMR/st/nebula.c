#define BMRT 0  /* Set to 0 if using prman also will need to 
                   create a texturemap */

#include <ri.h>
#include <stdio.h>
#include <math.h>
/***********************************************************
 * nebula.c -- Generates an Renderman RIB animation of a nebula cloud and
 *   thick cloud covered planet (venus-like)
 *
 * DESCRIPTION:
 *	Uses RCGlow, LGStarfield, KMVenus, and TLSpaceCloud (Note this shader
 *  expects to use a texturemap) to create an animation a rotation around a
 *  a cloud planet with a nebula background.
 *
 *  This is using much of the same code as found in the terran.c animation.
 *
 * PARAMETERS:
 *	Currently the only parameter that is accepted is the number of frames to
 * generate.
 *
 * AUTHOR: Tal Lancaster
 *	tal@cs.caltech.edu
 *
 * History:
 *	Created: 6/1/95
 *  Last Modified:
 *
 *  tal 3/2/97 -- Clean up some code and added comments.
 *  tal 2/23/97 -- Lots-O-Changes.  Namely new and improved space-cloud
 *    shader.  Rotation is now a constant radius with planet as the center.
 *    Moved light.  Changed scale on everything.
 *
************************************************************/
#define NFRAMES 5
#define MINFRAMES 6
#define XOFFSET 0.5
#define YOFFSET 0.51     /* The offset of the curve in the function */
#define XPOS 0           /* X element in point array */
#define YPOS 1           /* Y element in point array */
#define ZPOS 2           /* Z element in point array */

#define SUNPOS -60.0, -15 /*0.05*/, 10  /* World positon of SUN */

/* From RC Listing 8.2 p. 142 */
extern void PlaceCamera (RtPoint position, RtPoint direction, float roll);

RtLightHandle ambi1, distant1;        /* ambient and distant lights */
RtColor color = {.8, .8, .8};    /* Current color */

/****
 * dostars() -- generate a starfield
 ****/
void dostars()
{
  RiAttributeBegin();
    RiDeclare ("pswidth", "float");
    RiDeclare ("frequency", "float");
    RiDeclare ("casts_shadows", "string");

	{
		float pswid = 0.25;  /* .2 .4 */
		float freq = 3; /* .005 .025 .0035*/
		float intensity = 6 /* 1.5 2.0 */;
		char* cshadows = "none";
		
	/* RiIdentity(); */
	RiDeclare ("intensity", "float");
    RiAttribute ("render", "casts_shadows", &cshadows, RI_NULL);

#if 1	
	RiShadingRate (.5); /* 0.25 */
    RiSurface ("LGStarfield", "pswidth", &pswid, "frequency", &freq, "intensity", &intensity, RI_NULL);
#else
	{
		char* tmap = "grid.tx";
		RiDeclare ("texturename", "string");
	RiSurface ("paintedplastic", "texturename", &tmap, RI_NULL);
		}
#endif	
	
    RiSphere (65, -65, 65, 360.0, RI_NULL);
    /* RiSphere (10000, -10000, 10000, 360.0, RI_NULL); */
	}
  RiAttributeEnd ();
} /* dostars */

/****
 * dolights() -- Add the lights to the scene
 ****/
void dolights ()
{
	float intensity = 0.025;
	char* shadows = "off" /* "on"*/;
	RtPoint from = {SUNPOS}; 
	RtPoint to = {0.0, 0.0, 0.0};

	RiDeclare ("intensity", "float");
  ambi1 = RiLightSource ("ambientlight", "intensity", & intensity, RI_NULL);
  RiDeclare ("shadows", "string");
  RiAttribute ("light", "shadows", &shadows, RI_NULL);
  intensity = 2;
  distant1 = RiLightSource ("distantlight", "intensity", &intensity, "from", &from, "to", &to, RI_NULL);
} /* dolights */

/*****
 * dosun() -- Add a visual reference for the sun
 *****/
void dosun()
{
	float atten = 2; /* .5 */
	char* cshadows = "none";

	RiAttributeBegin ();		
	    RiAttribute ("render", "casts_shadows", &cshadows, RI_NULL);
		
		RiTranslate (SUNPOS);
		color[0] = .984; color[1] = .996; color[2] = .703;
		RiColor (color);
		RiDeclare ("attenuation", "float");
		RiSurface ("RCGlow", "attenuation", &atten, RI_NULL);
		RiSphere (4, -4, 4, 360.0, RI_NULL);
	RiAttributeEnd ();
} /* dosun */

RtPoint blpatch [2][2] = {
   { {-1, -5, 0}, {-1, 5, 0}},
   { {1, -5, 0}, {1, 5, 0}}
};

void donebula()
{
#if BMRT
  char* txtFile = "ori2.tiff";
#else
  char* txtFile = "ori2.tx";
#endif
  RiAttributeBegin();

  RiRotate (90, 0, 0, 1);
  RiTranslate (0, 0, -10); /* -4 */
  /* RiRotate (-45, 1, 0, 0); */
  RiDeclare ("txtFile", "string");
  RiDeclare ("casts_shadows", "string");
  {
    char* opt = "none";
    RiAttribute ("render", "casts_shadows", &opt, RI_NULL);
  }
  RiScale (5, 2.5, 1); /* 3 1,5 */
  RiSurface ("TLSpaceCloud", "txtFile", &txtFile, RI_NULL);
  RiPatch (RI_BILINEAR, RI_P, (RtPointer) blpatch, RI_NULL);
  RiAttributeEnd();
}

/*****
 * doplanet() -- add the planet
 *****/
void doplanet()
{
	RiAttributeBegin();
	RiScale (0.5, 0.5, 0.5);
	RiDeclare ("casts_shadows", "string");
	{
		char* opt = "none";
		RiAttribute ("render", "casts_shadows", &opt, RI_NULL);
	}

	{
		float ka = 0.6, kd = .5;
		RtColor color = {.7, .7, .5};
		
		RiColor (color);
		RiSurface ("KMVenus", "Ka", &ka, "Kd", &kd, RI_NULL);
		RiSphere (1, -1, 1, 360.0, RI_NULL);
	}
	RiAttributeEnd();
} /* doplanet() */

/****
* void doline (int, float, float) --
* 	int maxFrames -- number of frames in animation.
*	float startz -- Starting Z position
*	float endz -- Ending Z position
*
*	This is the work-horse... It contains the animation path .
*
*	The animation rotates with a constant radius using the planet as the
*   center. 
*
****/
void doline (int maxFrames, float startz, float endz)
{
	int frame = 0;       /* Current animation frame */
	char filename [20];  /* Name of frame */
	RtPoint position = {0.0, 0.0, 0.0};   /* Camera position */
	RtPoint direction = {0.0, 0.0, 0.0};  /* camera viewing vector */
	float roll = 0.0;                     /* camera roll angle */
	double degRad = M_PI / 180.0;         /* degree to radians */

	/* Amount to increment rotation angle */
	double thetaInc = (2 * M_PI) / (double) maxFrames;
	double theta = 0.0;                   /* Rotation angle */

	double outermin = (1.02 /* radius of planet + buffer */ / 2 /* scaling 1/2 */)+ endz;		
	double Rstart = startz;
	double R = Rstart;
	double Rmin = (Rstart - .51);
	double midFrame = (int) maxFrames / 2;
	double Rincr = (Rmin) / (midFrame);
	double hthetaInc = thetaInc / 2;
	float yrot = 0.0, yinc = 360.0 / maxFrames;
	RtFloat fov = 40;
	
	RiBegin (RI_NULL);
		RiProjection ("perspective", RI_FOV, &fov, RI_NULL);
#if 1
		RiFormat (200, 100, 1.0);
		RiShadingRate (10.0);
		/* RiPixelSamples (2, 2); */
#else
		RiFormat (600, 440, 1.0);
		RiShadingRate (1);
		RiPixelFilter (RiCatmullRomFilter, 5, 5);
		/* RiPixelSamples (3, 3); */
#endif
	
		while (frame < maxFrames) {			 
			sprintf (filename, "nebula.%d.tiff", frame);
			RiFrameBegin (frame);
				RiDisplay (filename, RI_FILE, RI_RGB, RI_NULL);

			/* This way so can render frames independently */
			theta = frame * thetaInc;
			
			R = Rstart;

			position[XPOS] =  R * sin (theta);
			position[ZPOS] =  R * cos (theta);
			{
				double xp =  R * sin (theta);
										
				direction[XPOS] = -(xp);
				direction[ZPOS] = -(R * cos (theta));
			}
#if DEBUG
			fprintf (stderr, "cell %d: angle %f %f %f %f\n", frame,
			 theta * 180.0 / M_PI, position[0], position[1], position[2]);
#endif

			PlaceCamera (position, direction, roll);
			RiWorldBegin ();

			RiColor (color);
#if 1
			dostars();       /* Add the stars */
#endif
			dolights();      /* Add the lights */
#if 1
			dosun();         /* Add the sun    */
			doplanet();      /* Add the planet */
			donebula ();     /* Add the nebula */
#endif

			RiWorldEnd ();
			RiFrameEnd ();

			frame++;
		}
	RiEnd();	
}

void main (int argc, char** argv)
{		
if (argc==1)
	/* No arguments */
	doline (360, 2.0, 0.3); /* 10,2, .3 */
else if (argc == 2)
	doline (atoi (argv[1]), 3.0, 0.2);
/*** Doesn't work ************
else if  (argc == 4) {
	doline (atoi (argv[1]), (float) atof (argv[2]), (float) atof (argv[3]));
}
*******************************/
else {
	printf ("Error:Unexpected arguments\n");
	printf ("Usage: nebula   (build default animation).\n");
	printf ("\tnebula nFrames (build nFrame animation).\n");
	printf ("\tnebula nFrames startZ endZ  (build nFrame animation\n");
	printf ("\t    with Z starting at startZ and nFrame/2 will be at\n");
	printf ("\t    endZ+offset.\n\n");
	exit(1);
	}
}
