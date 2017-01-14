/****************************************************************************
 * woodblockprint.sl -- surface shader for carved wood block printing
 *
 * (c) Copyright 1998 by Fleeting Image Animation, Inc.
 * All rights reserved.
 *
 * Permission is hereby granted, without written agreement and without
 * license or royalty fees, to use, copy, modify, and distribute this
 * software and for any purpose, provided that the above copyright
 * notice appear in all copies of this software.
 *
 * Author: Scott F. Johnston
 *
 * Reference:
 *   _Advanced RenderMan: Creating CGI for Motion Picture_, 
 *   by Anthony A. Apodaca and Larry Gritz, Morgan Kaufmann, 1999.
 *
 ****************************************************************************/


surface
woodblockprint ( float freq = 2;
		 float duty = 0.50;
		 float normal_dropoff = 1.0;
		 float dpscale = 0.1;
		 color stripe_color = 0;
		 float Ka = 0.2;
		 float Kd = 0.8;
		 float lo = 0.0;
		 float hi = 1.0;
		 string mapname = "";
		 float aspect = 1.0; )
{
    color diffuzeC;
    float diffuze;
    
    point Pscreen = transform("screen", P);
    vector dp = dpscale * vtransform("screen", dPdv);
    setzcomp(dp, 0);

    float lendp = mix (length(dp), length(dPdv), normal_dropoff);

    float logdp = log(freq * lendp, 2.0);
    float ilogdp = floor(logdp);
    float stripes = pow(2,ilogdp);

    float sawtooth = mod(v * stripes, 1);
    float triangle = abs(2.0 * sawtooth - 1.0);
    float transition = logdp - ilogdp;
    float transtriangle = abs((1 + transition) * triangle - transition);

    if (mapname != "") {
	float screenx = xcomp(Pscreen) / aspect;
	float screeny = ycomp(Pscreen);
	screenx = 0.5 * (screenx + 1.0);
	screeny = 1.0 - 0.5 * (screeny + 1.0);
	diffuze = float texture(mapname[0], screenx, screeny);
    } else {
	diffuzeC = Ka * ambient() + Kd * diffuse(faceforward(normalize(N),I));
	diffuze = (comp(diffuzeC,0) + comp(diffuzeC,1) + comp(diffuzeC,2))/3.0;
    }
    diffuze = (diffuze - lo)/(hi - lo);
    
    float square = filterstep(duty * diffuze, transtriangle);
    
    color CC = mix(Cs, stripe_color, square);
  
    Oi = Os;
    Ci = Os * CC;
}
