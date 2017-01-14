/* RudyCplasmaball.sl
 * 
 * Copyright (C) 2003, Rudy Cortes   rcortes AT kc DOT rr DOT com 
 * created  05/14/2003
 * 
 * This software is placed in the public domain and is provided as is 
 * without express or implied warranty. 
 * 
 * Surface shader that implements a displacement model that should have a visual
 * appearence general similar to that of SCI-FI plasma spheres. Usually used for 
 * portals, gravity fields and other SCI-FI cliches.
 *
 * Feel free to use this shader to create SCI-FI cliches anywhere and
 * everywhere, just list me on the credits under "Shading Team"
 *
 ****************************************
 * PARAMETERS
 * textFreq = How often will the texture repeat over the surface
 * noiFreq = How strong is the noise applied to the texture
 * turbPower = A higher number will make sharper "plasma rays"
 * rimEdge = The surface gets brigther towards the edges (did you notice it?)
 *           this parameter controls how big that edge is
 * additive = This will make the plasma look more "glowy"
 * FRAME = here you must plug some king of expression that changes over time,
 *         usually a frame number (otherwise your plasma will be static). You
 *         will probably need to slow down your frame increment by a simple division
 *         " frameNumber / 10".
 ****************************************
 * Tested with 3delight. www.3delight.com
 *
 * Comments, sugestions or questions welcomed at rcortes AT kc DOT rr DOT com 
 * 
 * ENJOY!!! 
 */



/* Pre-proc */
#ifndef MINFILTWIDTH
#define MINFILTWIDTH 1.0e-6
#endif

#define snoise(p) (2 * (float noise(p)) - 1)
#define filterwidthp(p) max (sqrt(area(p)), MINFILTWIDTH)
#define filteredsnoise(p,width) (snoise(p) * (1-smoothstep (0.2,0.75,width)))


/* shader*/
surface RudyCplasmaball (
		 float textFreq = 4,
		 noiFreq = 12,
		 turbPower = 4,
		 rimEdge = 0.8,
		 additive = 1,
		 FRAME = 0;
		 )
{
 point PP;
 float PPwidth;
 float turb, f, noi ;
 float freq;
 color sc,lc;
 float lo, lo1;
 normal Nf;

 /* Initialize Color (sc) and transform to shader space (PP)*/
sc = Cs;
PP = transform("shader", P) * textFreq;
/* estimate a filter width to use for antialiasing*/ 
PPwidth = filterwidthp(PP);



/* Layer 1 - Plasma Layer */

/* compute layer opacity (lo) using a filterednoise*/
turb = 0;
freq = noiFreq;  /* add a " + frame" to get plasma movement*/ 
turb += abs( filteredsnoise( PP + freq  * PI + FRAME, PPwidth ));
turb = pow((1-turb), turbPower);
lo = turb ;

/*compute layer color (lc) using noise (noi) to lookup a color spline
 * function */
color dar = sc * 0.15,
      middar = sc * 0.25,
      mid = sc * 0.5,
      midhi = sc * 0.75,
      hi = sc * 0.9;

noi = 0;
noi += noise( PP  *  PI + FRAME);
 noi = pow(noi,2);
lc = spline ("catmull-rom",noi,
	     dar,
	     dar,
	     middar,
	     mid,
	     midhi,
	     hi,
	     midhi,
	     middar,
	     mid,
	     hi,
	     midhi,
	     dar,
	     dar);


/* composite layers */ 
sc = mix(sc,lc,lo);

/*layer 2 - rim opacity*/

/*compute rim opacity using a dot product of N.I*/
lo1 = 1 - smoothstep(0,rimEdge,abs(normalize(N).normalize(I))); 

/*Dim the colors of the backside of the object*/
 if (N.I > 0)
   lo *= lo1 + (lo / 1.5);
 else 
   lo *= lo1 + (lo / 2.5);

 /* composite layers and make additive*/
sc = mix(sc,lc,lo) + (lo * additive) ;

/*output*/ 
Oi = Os * lo;
Ci = lo *  sc;

}
