/******************************************************
 * Shader Info
 *************
 * rudycconcretestripes_d.sl
 * by Rudy Cortes
 * Created 06.04.03
 * copyright (C)2003 Rudy Cortes
 *************
 * 
 * This shader is provided "as is" with no waranties of any kind.
 * The author assumes no responsibility for any malfuction of this
 * shader or any problems the shader might cause on rendered scenes
 *
 * This DISPLACEMENT shader generates an appearance similar to those
 * "concrete stripes" found in buildings sometimes.
 *
 ****************************************
 * Params -
 * Km = The usual
 * rot = rotation of the stripes on the pattern
 * lineFreq = At what frequency should the lines be drawn?
 * crumpleFreq, crumple = How frequent and how strong should the 
 * crumpling be.
 * trueDisp = "0" = bump mapping, > 0 = displacement.
 ****************************************
 *
 * Feel free to use this shader anytime and anywhere. Just remember to 
 * drop me a line thanking me if you use it in production
 *
 * Comments, suggestions, questions and bug reports welcom at
 * shaders AT rudycortes DOT com 
 *
 * Enjoy!
 ******************************************************/ 

#include "patterns.h"
#include "noises.h"
#include "rmannotes.h"

displacement RudyCconcretestripes_d(
	float Km= 0.1;
	float rot = 0;
	float lineFreq = 4;
	float crumpleFreq = 2;
	float crumple = 1;
	float trueDisp = 0;)

{
  /*shader local variables*/
 float sm,lm,lm1;
 float ss,tt,sss,ttt,sssw;
 point PP;
 float PPw, turb,turb2,f;
 float noi;
 float noifreq, noiscale;
 
 /* init */ 
 sm = 0;

 /******
  * layer 1   stripes
  * use rot to rotate stripes
  ******/ 
    
  /*petrutb ss,tt coordinates to make pattern less "perfect"
    computenoise based on texture coords*/ 
 noifreq = lineFreq * 4;
 noi = noise(s  * noifreq , t * noifreq );

  /* perturb ss */
  noiscale = s  * crumple * 0.0015;
  ss = s  + snoise(noi + 912) * noiscale;
  noiscale = t  * crumple * 0.0015;
  tt = t  + snoise(noi + 512) * noiscale ;  
  rotate2d(ss,tt,radians(rot),0.5,0.5,sss,ttt);
  sss = repeat(sss,lineFreq);  
  sssw = filterwidth(sss);

 lm = filteredpulsetrain(0.3,1,sss,sssw);
 sm +=  lm;

 /******
  * Layer 2   Crumple
  ******/

 /*add noise holes*/
PP = transform ("shader",P) * crumpleFreq * lineFreq;
PPw = filterwidthp(PP);

turb = 0;
for ( f = 1; f < 8 ; f *= 2)
 turb += abs(filteredsnoise(PP * f,PPw * f) / f);
 turb = smoothstep(0.1,0.8,turb);
 lm1 = clamp(lm + 0.2,0,1); 
 lm = turb  * crumple  * lm1;
 sm += lm;
 


 /*output*/
 if(trueDisp == 0 )
   {
   N = calculatenormal(P + Km * sm * normalize(N));
   }else{
   vector Nn = normalize(N);
   P += Nn * ((Km * sm) / length(vtransform("shader", Nn))) ;
   N = calculatenormal(P);
   }
}
