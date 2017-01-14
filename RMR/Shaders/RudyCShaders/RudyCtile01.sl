/* SHADER INFO
 *
 * rudyctile01.sl
 *
 * Copyright (c)2003, Rudy Cortes  rudy AT rudycortes DOT com 
 * created 05/22/03
 *
 * A floor tile shader. Part of the Rudy Cortes Tiles library
 *
 * This software is placed in the public domain and is provided as is 
 * without express or implied warranty.
 *
 *
 * Feel free to use this shader to create tiled surfaces  anywhere and
 * everywhere, Just list me on the credits under "Shading Team" if you use the
 * hader as is, or under "shader info" if you do any minor modifications to
 * this code.
 ******************************
 * Ka, Kd, Ks, roughness = the ususal
 * colors are self explanatory
 * tileFreq = how many times will the tiles repeat
 * marbleFreq, veinFreq = frequency of the marble and vein pattern
 * sharpness = how sharp are the veins?
 ******************************
 * Comments, questions, suggestions, job offers welcome at shaders AT rudycortes DOT com 
 * NOTES-
 * This shader requires the ARMan libraries and a modified version of rmannotes.sl 
 * to compile. The ARMan libraries can be downloaded at www.renderman.org and the
 * modified rmannotes.sl can be downloaded at www.rudycortes.com
 */

#include "patterns.h"
#include "noises.h"
#include "reflections.h"
#include "rmannotes.h"

surface RudyCtile01(
		    float Ka = 0.5,
		    Kd = 0.7,
		    Ks = 0.5,
		    roughness = 0.01;
		    float Kr = 0.2;
		    color baseDarkColor = color (0.741,0.569,0.345),
		    baseLightColor = color(0.816,0.690,0.486),
		    baseVeinsColor = color (0.949,0.749,0.584);
		    color squaresDarkColor = color (0.776,0.376,0.377),
		    squaresLightColor = color (0.878,0.490,0.482),
		    squaresVeinsColor = color (0.929,0.585,0.584);
		    color linesColor = color (.57,.27,.037);
		    float tileFreq = 1;
		    float marbleFreq = 1;
		    float veinFreq = 1;
		    float sharpness = 25;
		    string reflectMap = "";
		    float reflBlur = 0.01;
		    output varying color Camb=0, Cspec = 0,Cdif = 0, Crefl =0;)

{
  color sc,lc;
  float lo, los,lot;
  normal Nf;
  vector V,R;
  point Pshad;
  float ss,ssw,tt,ttw,stile,ttile,ss2,ss2w,tt2,tt2w;
  float tileindex;
  float rss2, rtt2;
  float turb, turbsum, freq, i;


/* Layer 1 */

/*tile OVERALL pattern*/
  ss = repeat(s,tileFreq);
  tt = repeat(t,tileFreq);
  ssw = filterwidth(ss);
  ttw = filterwidth(tt);
  stile = whichtile(s, tileFreq);
  ttile = whichtile(t,tileFreq);
  tileindex = stile +  ttile;

  /* create veining pattern for marble */

 Pshad = tileindex + marbleFreq * 2 * transform ("shader", P);
 float Pshadw = filterwidthp(Pshad);

    /*
     * First calculate the underlying color of the substrate
     *    Use turbulence - use frequency clamping
     */
   
 turb = 0.5 * turbulence (Pshad , Pshadw, 5, 2, 0.5);
    sc = mix (baseDarkColor,baseLightColor, smoothstep(0.1,.35,turb));


    /*
     * Now we layer on the veins
     */

    /* perturb the lookup */
    Pshad += vector(35.2,-21.9,6.25) + 0.5 * vfBm (Pshad, Pshadw, 6, 2, 0.5);

    /* Now calculate the veining function for the lookup area */
    turbsum = 0;  freq = 1;
    Pshad *= veinFreq;
    for (i = 0;  i < 3;  i += 1) {
  turb = abs (filteredsnoise (Pshad*freq, Pshadw*freq));
  turb = pow (smoothstep (0.8, 1, 1 - turb), sharpness) / freq;
  turbsum += (1-turbsum) * turb;
  freq *= 2;
    }
    turbsum *= smoothstep (-0.1, 0.05, snoise(2*(Pshad+vector(-4.4,8.34,27.1))));

    sc = mix (sc, baseVeinsColor, turbsum);



 /***********************
  * Layer 2 
  *******************/

 /* create the edge lines*/
 lc = linesColor;
 lo = union(1 - filterstep(0.005,ss) + filterstep(0.992,ss),
        1 - filterstep(0.005,tt) + filterstep(0.992,tt));
 sc = mix (sc,lc,lo);
 
 /* create the center square lines */
  lo = filteredpulse(0.245,0.255,ss,ssw) + filteredpulse(0.745,0.755,ss,ssw)
      + filteredpulse(0.245,0.255,tt,ttw) + filteredpulse(0.745,0.755,tt,ttw);
  los = filteredpulse (.2,.8,ss,ssw)  * filteredpulse(0.2,0.8,tt,ttw); 
  sc = mix (sc,lc,lo * los);

 /* create those small lines at the center of the square edges*/
 lo = filteredpulse(0.495,0.505,ss,ssw);
 los = 1 - (filteredpulse(-0.1,0.1,tt,ttw) + filteredpulse(0.245,0.755,tt,ttw)
	    + filteredpulse(0.9,1.1,tt,ttw));
 sc = mix (sc,lc,lo * los);

 lo = filteredpulse(0.495,0.505,tt,ttw);
 los = 1 - (filteredpulse(-0.1,0.1,ss,ssw) + filteredpulse(0.245,0.755,ss,ssw)
	    + filteredpulse(0.9,1.1,ss,ssw));
 sc = mix (sc,lc,lo * los);

 /*****************************************
  * Layer 3
  */

 /* Create rotated squares, compute its veining and composite */
 /*break EACH tile in 4 */

 ss2 = repeat(ss,2);
 tt2 = repeat(tt,2);
 rotate2d(ss2,tt2,radians(45),0.5,0.5,rss2,rtt2);
 ss2w = filterwidth(rss2);
 tt2w = filterwidth(rtt2);

  /* create veining pattern for marble */

 Pshad = tileindex + marbleFreq * 4 * transform ("shader", P);
 Pshadw = filterwidthp(Pshad);

    /*
     * First calculate the underlying color of the substrate
     *    Use turbulence - use frequency clamping
     */
   
 turb = 0.5 * turbulence (Pshad , Pshadw, 5, 2, 0.5);
 lc = mix (squaresDarkColor,squaresLightColor, smoothstep(0.1,.35,turb));


 
 lo = filteredpulse (.25,.75,rss2,ss2w)  * filteredpulse(0.25,0.75,rtt2,tt2w);


    /*
     * Now we layer on the veins
     */

    /* perturb the lookup */
    Pshad += vector(35.2,-21.9,6.25) + 0.5 * vfBm (Pshad, Pshadw, 6, 2, 0.5);

    /* Now calculate the veining function for the lookup area */
    turbsum = 0;  freq = 1;
    Pshad *= veinFreq;
    for (i = 0;  i < 3;  i += 1) {
  turb = abs (filteredsnoise (Pshad*freq, Pshadw*freq));
  turb = pow (smoothstep (0.8, 1, 1 - turb), sharpness) / freq;
  turbsum += (1-turbsum) * turb;
  freq *= 2;
    }
    turbsum *= smoothstep (-0.1, 0.05, snoise(2*(Pshad+vector(-4.4,8.34,27.1))));

   lc = mix (lc, baseVeinsColor, turbsum);
  
   sc = mix (sc,lc,lo);




 /* add rotated squares outlines*/ 
 lc = linesColor;
 los = filteredpulse (0.24,.26,rss2,ss2w) + filteredpulse (.74,.76,rss2,ss2w); 
 lot = filteredpulse(0.24,0.26,rtt2,tt2w) + filteredpulse(0.74,0.76,rtt2,tt2w); 
 lo = filteredpulse (.24,.76,rss2,ss2w)  * filteredpulse(0.24,0.76,rtt2,tt2w);
 lo *= union(los,lot);
 sc = mix (sc,lc,lo);


 /* add reflections to our texture
  * commented out to use reflections from MtoR */
 color reflcolor;
 float reflout;
 if (Kr != 0){
 reflcolor = color (0,0,0);
 if (reflectMap != "");
     reflcolor = ReflMap (reflectMap, P, reflBlur, reflout) * Kr;
 }

/* output */
 Nf = faceforward(normalize(N),I);
 V = -normalize(I);
 Camb = sc * Ka * ambient();
 Cdif = sc * Kd * diffuse(Nf);
 Cspec = Ks * specular(Nf,V,roughness);
 Crefl = reflcolor;
 Oi = Os;
 Ci = Oi * (Camb + Cdif + Cspec + Crefl) ;
}
