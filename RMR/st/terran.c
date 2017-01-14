#include <ri.h>
#include <stdio.h>
#include <math.h>
/***********************************************************
 * terran.c -- Generates a Earth like Renderman RIB animation.
 *
 * DESCRIPTION:
 *	Uses RCGlow, LGStarfield, KMTerranbump, KMPlanetClouds, and TLTerranNwhite
 *  to create an animation of a earch like planet flyby.
 *
 *  This is a much more improved version over the one found in saturn.c
 *  Namely all of the surfaces have been moved out into their own functions.
 *  This way is is much easier using the same framework for other planets
 *  An even better approach would be to move them into their own files.
 *  This way you could decide which animation to build by choising which
 *  files to link up.
 *
 * PARAMETERS:
 *	Currently the only parameter that is accepted is the number of frames to
 * generate.
 *
 * AUTHOR: Tal Lancaster
 *	tal@cs.caltech.edu
 *
 * History:
 *	Created: 5/31/95
 *
************************************************************/
#define NFRAMES 5
#define MINFRAMES 6
#define XOFFSET 0.5
#define YOFFSET 0.51     /* The offset of the curve in the function */
#define XPOS 0           /* X element in point array */
#define YPOS 1           /* Y element in point array */
#define ZPOS 2           /* Z element in point array */
#define SUNPOS -2.0, 0.5, 100  /* World positon of SUN */

/* From RC Listing 8.2 p. 142 */
extern void PlaceCamera (RtPoint position, RtPoint direction, float roll);

RtLightHandle ambi1, distant1;        /* ambient and distant lights */
RtColor color = {.8, .8, .8};    /* Current color */

/****
 * dostars() -- generate a starfield
 ****/
void dostars()
{
#if 1
  RiAttributeBegin();
    RiDeclare ("pswidth", "float");
    RiDeclare ("frequency", "float");
    RiDeclare ("casts_shadows", "string");

	{
		float pswid = 0.2;  /* .4 */
		float freq = .005; /* .025 .0035*/
		float intensity = 1.5 /* 2.0 */;
		char* cshadows = "none";
		
	/* RiIdentity(); */
	RiDeclare ("intensity", "float");
    RiAttribute ("render", "casts_shadows", &cshadows, RI_NULL);

#if 1
	/* RiRotate (90, 1, 0, 0); */
	
/* 	RiShadingRate (0.25); */ /* 0.25 */
    RiSurface ("LGStarfield", "pswidth", &pswid, "frequency", &freq, "intensity", &intensity, RI_NULL);
#else
		{
						char* tmap = "/Users/tal/grid.tx";
						RiDeclare ("texturename", "string");
					RiSurface ("paintedplastic", "texturename", &tmap, RI_NULL);
		}
#endif	
	
    RiSphere (10000, -10000, 10000, 360.0, RI_NULL);
	}
  RiAttributeEnd ();
#else
	RiAttributeBegin();
	{
#if 0
		char* tname = "/Users/tal/Pics/oria.tiff";
#else
		char* tname = "/Users/tal/oria.tx";
#endif
		float kd = 0.0, ks = 0.0, ka = 10.0;
		RtColor color = {1.0, 1.0, 1.0};
		
		RiDeclare ("texturename", "string");
		RiColor (color);
	RiSurface ("paintedplastic", "texturename", &tname, "Kd", &kd, "Ks", &ks, "Ka", &ka, RI_NULL);
	RiConcatTransform (mat);
	RiPatch (RI_BILINEAR, RI_P, patch, RI_NULL);
	
	}
	RiAttributeEnd ();

#endif
} /* dostars */

/****
 * doclouds() -- add some clouds to the planet
 ****/
doclouds()
{
	RiAttributeBegin();
		RiDeclare ("casts_shadows", "string");
		{
			char* opt = "shade";
			RiAttribute ("render", "casts_shadows", &opt, RI_NULL);
		}
		RiDeclare ("offset", "float");
		{
			float clouds = 0.25;
			RiSurface ("KMPlanetclouds", "offset", &clouds, RI_NULL);
		}
		RiSphere (1.02, -1.02, 1.02, 360.0, RI_NULL);
		RiAttributeEnd();
} /* doclouds */

/****
 * dolights() -- Add the lights to the scene
 ****/
void dolights ()
{
	float intensity = 0.025;
	char* shadows = "on" /* "on"*/;
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
		RiSphere (8, -8, 8, 360.0, RI_NULL);
	RiAttributeEnd ();
} /* dosun */

/*****
 * doplanet() -- add the planet
 *****/
void doplanet()
{
#if 1				
					RiScale (0.5, 0.5, 0.5);
					RiAttributeBegin();
						RiDeclare ("sea_level", "float");
						RiRotate (-15.0, 0, 0, 1);
						RiRotate (-95.0, 1, 0, 0);
						{
							float sea = 0.15;
							float ice = .98;
							float multifractal = 0.0;
							RiDeclare ("ice_caps", "float");
							RiDeclare ("multifractal", "float");
						
						/* Displace the surface */	
							RiDisplacement ("KMTerranBump", "sea_level", 
							 &sea,  RI_NULL);
							RiSurface ("TLTerranNwhite", "sea_level",
							 &sea, /* "ice_caps", &ice, */ RI_NULL);
						}

						color[0] = color[1] = 0.05;
						color[2] = 0.4;
						RiColor(color);
						RiSphere (1, -1, 1, 360.0, RI_NULL);
					RiAttributeEnd();
					
					/* Add the clouds */
					doclouds();
				
#else
					RiAttributeBegin();
					RiScale (0.5, 0.5, 0.5);

					{
						char* tmap = "/Users/tal/grid.tx";
						RiDeclare ("texturename", "string");
					RiSurface ("paintedplastic", "texturename", &tmap, RI_NULL);

						RiSphere (1, -1, 1, 360.0, RI_NULL);
					}
					RiAttributeEnd();
#endif /* shapes */
} /* doplanet() */

/****
* void doline (int, float, float) --
* 	int maxFrames -- number of frames in animation.
*	float startz -- Starting Z position
*	float endz -- Ending Z position
*
*	This is the work-horse... It contains the animation path and 
*	all of the objects.  Should look into breaking these down.
*
*	The animation starts from a given starting Radius and then moves in a
* circular orbit spiraling in to a minium Radius (reached at midway through the 
* animation) then back out to the starting Radius. 
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
/*		RiLightSource ("distantlight", RI_NULL);
		*/
#if 1
		RiFormat (200, 100, 1.0);
#else
		RiFormat (600, 440, 1.0);
#endif
	
		while (frame < maxFrames) {			 
			sprintf (filename, "ter.%d.tiff", frame);
			RiFrameBegin (frame);
				RiDisplay (filename, RI_FILE, RI_RGB, RI_NULL);
	/* 			RiShadingRate(20.0); */
	/*			RiPixelSamples (2, 2); */

			/* This way so can render frames independently */
			theta = frame * thetaInc;
			if (theta < M_PI)
				R = Rstart - Rincr* frame;
			else
				R = outermin + Rincr* (frame - midFrame);	

			if (R < outermin)
				R = outermin;			
								
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
					dostars();       /* Add the stars */
					dolights();      /* Add the lights */
					dosun();         /* Add the sun    */
					doplanet();      /* Add the planet */

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
	doline (10, 2.0, 0.3);
else if (argc == 2)
	doline (atoi (argv[1]), 3.0, 0.2);
/*** Doesn't work ************
else if  (argc == 4) {
	doline (atoi (argv[1]), (float) atof (argv[2]), (float) atof (argv[3]));
}
*******************************/
else {
	printf ("Error:Unexpected arguments\n");
	printf ("Usage: terran   (build default animation).\n");
	printf ("\tterran nFrames (build nFrame animation).\n");
	printf ("\tterran nFrames startZ endZ  (build nFrame animation\n");
	printf ("\t    with Z starting at startZ and nFrame/2 will be at\n");
	printf ("\t    endZ+offset.\n\n");
	exit(1);
	}
}
