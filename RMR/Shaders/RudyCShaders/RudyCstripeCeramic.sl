/***********************************
 * rudycstripeceramic.sl
 *
 * By Rudy Cortes   copyright(c)2003
 * Copyright (C) 2002, Rudy Cortes   rcortes AT hntb DOT com 
 * created  07/23/2003
 * 
 * This software is placed in the public domain and is provided as is 
 * without express or implied warranty. 
 *
 * A Shader designed to give the appearance of a ceramic object
 * that was painted while roating on the molding table 
 *
 * Feel free to use this shader anywhere and
 * everywhere. Just drop me a line to let me know you are using it.
 *
 * Comments, crits and suggestions welcome at shaders AT rudycortes DOT com 
 *
 ***********************************
 * PARAMETERS .-
 * CERAMICPARAMS = Ka, Kd,Ks,roughness,sharpness, specularcolor. These values are
 *                declared on "rcmats.h"
 * seed = randomizes the stripes so that not 2 vases are the same.
 * stripeColor = color of the stripes.
 * bgColor = background color.
 * stripeThresh = a threshold to control how fast the stripes fade to bgColor
 * stripeFade = how intese are the lines?
 * Km =  displacement of the lines
 *
 ***********************************
 *
 * Notes - You will need to download my header file library to compile this shader.
 * 	Place the files in the shaders directory. If you place them somewhere else, the
 *	compiler might not find the header files. To solve this use the -I flag when 
 *	compiling. Ex   "shader -I/usr/rcortes/prman/lib/rclibs thisShader.sl" or
 *      "shader d:\Prman\lib\rclibs thisShader.sl". RClibs being where you copied the
 * 	header files.
 *
 * Enjoy!!
 *
 *
 *************************************/


#include "rclocillum.h"
#include "noises.h"
#include "patterns.h"



surface RudyCstripeCeramic(
			   float Ka = 0.8;
			   float Kd = 0.65;
			   float Ks = 1;
			   float roughness = 0.02;
			   float sharpness = 0.01;
			   float Kr =  0.5;
			   color stripeColor=color (0,0,1);
			   color bgColor = color (1,1,1);
			   color specularColor= color (1,1,1);
			   string envMap = "";
			   string envSpace = "world";
			   float ior = 1.5;
			   float envRad = 100;
			   float reflBlur = 0.01;
			   float seed = 0;
			   float stripeFreq = 4;
			   float stripeThresh = 0.5;
			   float stripeFade = 0;
			   float Km = 1;)

{
  /* Init shader variables*/
  normal Nf ;
  vector V = normalize(I);
  color sc, Cr;
  vector R;	
  float twidth = filterwidth(t);
  float alpha;
  float j, fresKr,fresKt; 
  

 /*** Layer 1 striped color ***/
 

 /* Start by creating a noise function to use for lookup*/
   j = filteredsnoise ((stripeFreq * t * PI  + seed), twidth);
   /* Threshold the function to add control*/
     j = smoothstep( -1 + stripeThresh, 1 ,j);


  sc = mix(bgColor,stripeColor,j * (1 - stripeFade));
    
 
    /* Use the spline value to control the small bumps
    P +=  j * N  * Km ;*/  
    point PP = P + j * normalize(N) * Km;
    N = calculatenormal(PP);
    Nf = faceforward(normalize(N),I);

    /* Add reflections from an environment*/


	if (envMap != "") 
	{
	  
	  R = reflect(I, Nf);  
	  fresnel(normalize(I),Nf,(I.Nf > 0)? ior: 1/ior,fresKr,fresKt);
	    R = vtransform(envSpace, R);
	    Cr = Kr *  environment(envMap,R,"filter","gaussian","width",reflBlur)*fresKr;
	}
	 else 
	{
		Cr = 0;
	}; 

 /* Output */
  Oi = Os;
  Ci = Oi * sc * (Ka * ambient() + Kd * diffuse(Nf)) + 
    glossy(Nf,V,roughness,sharpness,Ks,specularColor) + Cr;
  
}
			   


