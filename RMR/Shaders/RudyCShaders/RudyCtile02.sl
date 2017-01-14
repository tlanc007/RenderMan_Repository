/* SHADER INFO
 *
 * rudyctile02.sl
 *
 * Copyright (c)2003, Rudy Cortes  rudy AT rudycortes DOT com 
 * created 06/03/03
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
 * NOTES -
 * This shader requires the ARMan libraries and a modified version of rmannotes.sl 
 * to compile. The ARMan libraries can be downloaded at www.renderman.org and the
 * modified rmannotes.sl can be downloaded at www.rudycortes.com
 */

#include "patterns.h"
#include "noises.h"
#include "reflections.h"
#include "rmannotes.h"

surface RudyCtile02(
        float Ka = 0.25,
        Kd = 0.75,
        Ks = 0.5,
        roughness =0.1,
        Kr = 0.5;
        float blur = 0.1;
        float textFreq = 1;
	float noiFreq = 40;
        float noiScale  = 0.004;
        color baseDarkColor = color (0.741,0.769,0.045),
        baseLightColor = color(0.816,0.890,0.056),
        baseVeinsColor = color (0.949,0.949,0.184);
        color squaresDarkColor = color (0.12,0.15,0.4),
        squaresLightColor = color (0.22,0.25,0.5),
        squaresVeinsColor = color (0.35,.55,.75);
        color linesColor = color (0.716,0.6,0.19);
        float marbleFreq = 1;
        float veinFreq = 2;
        float sharpness = 25;
        string reflectMap = "";
	float reflBlur = 0.01;
	output varying color Camb=0, Cspec = 0,Cdif = 0, Crefl =0;)

{
  
/* initialize shader variables*/
  color  sc, lc;
  float lo;
  normal Nf;
  vector V;
  float ss,ssw,tt,ttw,ssnoi,ttnoi,ssnoiw,ttnoiw;
  float tileindex;
  float noi;
  point Pshad; 
  float Pshadw;
  float turb, turbsum, freq, i;
  float aplha;

  ss = repeat(s,textFreq);
  tt = repeat(t,textFreq);
  ssw = filterwidth(ss);
  ttw = filterwidth(tt);
  tileindex = whichtile(s,textFreq) + 13 * whichtile(t,textFreq);

  /**********
   * layer 01 - Marble background 
   **********/

  /* create veining pattern for marble*/ 

 Pshad = tileindex + marbleFreq * 2 * transform ("shader", P);
 Pshadw = filterwidthp(Pshad);

    /*
     * First calculate the underlying color of the substrate
     *    Use turbulence - use frequency clamping*/
     
   
 turb = 0.5 * turbulence (Pshad , Pshadw, 5, 2, 0.5);
 sc = mix (baseDarkColor,baseLightColor, smoothstep(0.1,.35,turb));

 
 /*Now we layer the veins over*/
     

 /* perturb the lookup*/ 
    Pshad += vector(35.2,-21.9,6.25) + 0.5 * vfBm (Pshad, Pshadw, 6, 2, 0.5);

    /* Now calculate the veining function for the lookup area*/ 
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



 /********
  * Layer 02 - Marble square in the center
  *******/
    
  /*petrutb ss,tt coordinates to make pattern less "perfect"
    compute base noise based on texture coords*/ 

    noi = noise(s * noiFreq *textFreq, t * noiFreq * textFreq);

    /* perturb ss, tt */

  ssnoi = ss + snoise(noi + 912) * noiScale * textFreq;
  ttnoi = tt + snoise(noi + 333) * noiScale * textFreq;

  /* create veining pattern for marble*/ 

 Pshad = tileindex + marbleFreq * 2 * transform ("shader", P);
 Pshadw = filterwidthp(Pshad);

    /*
     * First calculate the underlying color of the substrate
     *    Use turbulence - use frequency clamping*/
     
   
 turb = 0.5 * turbulence (Pshad , Pshadw, 5, 2, 0.5);
 lc = mix (squaresDarkColor,squaresLightColor, smoothstep(0.1,.35,turb));

 
  /*Now we layer on the veins*/
   

  /* perturb the lookup*/ 
    Pshad += vector(35.2,-21.9,6.25) + 0.5 * vfBm (Pshad, Pshadw, 6, 2, 0.5);

  /* Now calculate the veining function for the lookup area*/
    turbsum = 0;  freq = 1;
    Pshad *= veinFreq;
    for (i = 0;  i < 3;  i += 1) {
  turb = abs (filteredsnoise (Pshad*freq, Pshadw*freq));
  turb = pow (smoothstep (0.8, 1, 1 - turb), sharpness) / freq;
  turbsum += (1-turbsum) * turb;
  freq *= 2;
    }
    turbsum *= smoothstep (-0.1, 0.05, snoise(2*(Pshad+vector(-4.4,8.34,27.1))));

   lc = mix (lc, squaresVeinsColor, turbsum); 

  /*conbine to create center square*/
  lo = intersection(filteredpulse(0.25,0.75,ss,ssw),filteredpulse(0.25,0.75,tt,ttw));
  sc = mix(sc,lc,lo); 


 /***********
  *layer 03 - crossing lines
  **********/
  ssnoiw = filterwidth(ssnoi);
  ttnoiw = filterwidth(ttnoi);
  lc = linesColor;  
  lo = union(filteredpulse(0.245,0.255,ssnoi,ssnoiw) + filteredpulse(0.745,0.755,ssnoi,ssnoiw),
       filteredpulse(0.245,0.255,ttnoi,ttnoiw) + filteredpulse(0.745,0.755,ttnoi,ttnoiw));

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
  
/*output*/
  Nf = faceforward(normalize(N),I);
  V = -normalize(I);
 Camb = sc * Ka * ambient();
 Cdif = sc * Kd * diffuse(Nf);
 Cspec = Ks * specular(Nf,V,roughness);
 Crefl = reflcolor;

Oi = Os;
Ci = Oi *  (Camb + Cdif + Cspec + Crefl) ;


}

