#include <ri.h>
#include <stdio.h>
#include <math.h>
/***********************************************************
 * saturn.c -- Generates a saturn like Renderman RIB animation.
 *
 * DESCRIPTION:
 *	Uses RCGlow, LGStarfield, TLSaturn, and TLRing shaders to create an
 * animation of a saturn like planet flyby.
 *
 * PARAMETERS:
 *	Should add parameters to tell it how many frames to generate.  Right now 
 * it uses a constant.
 *
 * AUTHOR: Tal Lancaster
 *	tal@cs.caltech.edu
 *
 * History:
 *	Created: 5/21/95
 *
************************************************************/
#define NFRAMES 5
#define MINFRAMES 6
#define XOFFSET 0.5
#define YOFFSET 0.51     /* The offset of the curve in the function */
#define XPOS 0           /* X element in point array */
#define YPOS 1           /* Y element in point array */
#define ZPOS 2           /* Z element in point array */
#define OUTER_RADIUS 1.0 /* size of ring  */

/* From RC Listing 8.2 p. 142 */
extern void PlaceCamera (RtPoint position, RtPoint direction, float roll);

/****
* void doline (int, float, float) --
* 	int maxFrames -- number of frames in animation.
*	float startz -- Starting Z position (Not used )
*	float endz -- Ending Z position (Not used)
*
*	This is the work-horse... It contains the nimation path and 
*	all of the objects.  Should look into breaking these down.
*
*	The animation starts from a given starting Radius and then moves in a
* circular orbit spiraling in to a minium Radius (reached at midway through the 
* animation) then back out to the starting Radius.  Currently these are all
* fixed.  They should be parameterized.
*
****/
void doline (int maxFrames, float startz, float endz)
{
	int frame = 0;       /* Current animation frame */
	char filename [20];  /* Name of frame */
	RtColor color = {.8, .8, .8};    /* Current color */
#if 0
	RtPoint position = {-XOFFSET, 0.0, -0.50};
#else
	RtPoint position = {0.0, 0.0, 0.0};   /* Camera position */
#endif
	RtPoint direction = {0.0, 0.0, 0.0};  /* camera viewing vector */
	RtLightHandle ambi1, distant1;        /* ambient and distant lights */
	float roll = 0.0;                     /* camera roll angle */
	double degRad = M_PI / 180.0;         /* degree to radians */

	/* Amount to increment rotation angle */
	double thetaInc = (2 * M_PI) / (double) maxFrames;
	double theta = 0.0;                   /* Rotation angle */

	/* 
	double outermin = OUTER_RADIUS + 0.10;		
	double Rstart = 2.0;
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
#if 0
		RiFormat (200, 100, 1.0);
#else
		RiFormat (600, 440, 1.0);
#endif
#if 1 /* Lights */
	{
		float intensity = 0.025;
		char* shadows = "on" /* "on"*/;
		RtPoint from = {-2.0, .5, -2}; /* 1, 1, .1 */
		RtPoint to = {0.0, 0.0, 0.0};

	RiDeclare ("intensity", "float");
  ambi1 = RiLightSource ("ambientlight", "intensity", & intensity, RI_NULL);
  RiDeclare ("shadows", "string");
  RiAttribute ("light", "shadows", &shadows, RI_NULL);
  intensity = 2;
  distant1 = RiLightSource ("distantlight", "intensity", &intensity, "from", &from, "to", &to, RI_NULL);
	}
#endif /* Lights */
	
		while (frame < maxFrames) {			 
			sprintf (filename, "sat.%d.tiff", frame);
			RiFrameBegin (frame);
				RiDisplay (filename, RI_FILE, RI_RGB, RI_NULL);
				RiPixelSamples (2, 2);


#define INTER2
#define MOVER2
#ifdef INTER
			theta += thetaInc;
#else
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
#ifdef MOVER
			if (theta < M_PI)
				R -= Rincr;
			else
				R += Rincr;
#endif
#endif				
			{
				double xp =  R * sin (theta);
										
				direction[XPOS] = -(xp);
				direction[ZPOS] = -(R * cos (theta));
			}
#if DEBUG
				fprintf (stderr, "cell %d: angle %f %f %f %f\n", frame,
				 theta * 180.0 / M_PI, position[0], position[1], position[2]);
#endif

#if 1					
				PlaceCamera (position, direction, roll);
#else
/*
			RiTranslate (0.0, 0.0, 2.0); 
			*/
			RiTranslate (position[XPOS], 0.0, position[ZPOS]); 
			
			yrot += yinc;
			RiRotate (yrot, 0.0, 1.0, 0.0);
#endif
				RiWorldBegin ();
					RiColor (color);
#define STARS	
#ifdef STARS

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
	
/*	RiShadingInterpolation (RI_SMOOTH); */
	RiShadingRate (0.25); /* 0.25 */
    RiSurface ("Tstarfield", "pswidth", &pswid, "frequency", &freq, "intensity", &intensity, RI_NULL);
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
#endif /* STARS */

#define SUN
#ifdef SUN
	RiAttributeBegin ();
	{
		float atten = 2; /* .5 */
		
		RiTranslate (2, -.5, 2);
		color[0] = .984; color[1] = .996; color[2] = .703;
		RiColor (color);
		RiDeclare ("attenuation", "float");
		RiSurface ("RCGlow", "attenuation", &atten, RI_NULL);
		RiSphere (.4, -.4, .4, 360.0, RI_NULL);
	}

	RiAttributeEnd ();
#endif /* SUN */

#define PLANET
#ifdef PLANET
#if 1				
					RiAttributeBegin();
						RiRotate (-15.0, 0, 0, 1);
						RiRotate (-95.0, 1, 0, 0);
#if 1
						RiDeclare ("casts_shadows", "string");

						{
						char* opt = "shade";
						RiAttribute ("render", "casts_shadows", &opt, RI_NULL);
						}
#endif

						RiSurface ("saturn3", RI_NULL);

						color[0] = color[1] = 0.05;
						color[2] = 0.4;
						RiColor(color);
						RiSphere (.45, -.45, .45, 360.0, RI_NULL);
					RiAttributeEnd();
				
					RiAttributeBegin();
						/* RiIdentity(); */
						RiRotate (-15.0, 0, 0, 1); 	
						RiRotate (-95.0, 1.0, 0.0, 0.0); 
#if 1
						RiDeclare ("casts_shadows", "string");
						{
						char* opt = "shade";
						RiAttribute ("render", "casts_shadows", &opt, RI_NULL);
						}
#endif
						RiSides(2);
						RiSurface ("ring3", RI_NULL);
						RiDisk (0.0, OUTER_RADIUS, 360.0, RI_NULL);
					RiAttributeEnd();
#else
					{
						char* tmap = "/Users/tal/grid.tx";
						RiDeclare ("texturename", "string");
					RiSurface ("paintedplastic", "texturename", &tmap, RI_NULL);

						RiSphere (OUTER_RADIUS, -1, 1, 360.0, RI_NULL);
					}
#endif /* shapes */
#endif /* PLANET */										

				RiWorldEnd ();
			RiFrameEnd ();

			frame++;
#ifndef INTER
	/* Should be obsolete
			theta += thetaInc;
			*/
#ifdef MOVER
/*
			if (theta < M_PI)
				R -= Rincr;
			else
				R += Rincr;
				**/
#endif
#endif			
		}
	RiEnd();	
}

void main ()
{
#if 1
	doline (60, -2.0, -0.001);
/* 
	doline (40, -0.001, -2.0);
*/
#else
	doline (5, -0.4, -2.0);

#endif
}
