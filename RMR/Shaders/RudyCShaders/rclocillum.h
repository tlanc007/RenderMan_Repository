/*******************************************************************
 * RCillum.h
 * A collection of functions used for calculating illumination models
 * by Rudy Cortes  (c) Copyright 2003
 * created:
 *        April 16 2003
 *
 * includes adapted  code from Rob Bredow, Mat Pharr
 * May include code by Rudy Cortes
 *******************************************************************/

#ifndef   RCILLUM_H
#define   RCILLUM_H

/* Wrapped diffuse light. A lighting model that allows you to control
 * how fast light fades away on the shadow area of an object
 * taken from sig 2002 - Rob Bredow */

color wrappedDiffuse( normal n; float wrappedAngle;)
{
  extern point P;
  extern vector L;
  extern color Cl;
  normal Nn = normalize (n);
  color c = 0;
  illuminance (P,Nn,PI/2)
    {
      vector Ln = normalize(L);
      c = Cl * ( 1- acos(Ln.Nn)/wrappedAngle);
    }
  return c;
}


/*
 * Glossy- a glossy BRDF, written by Mat Pharr. 
 * Sig 2002
 * modified by Rudy Cortes to support __nonspecular lights
 */

color glossy(normal Nf; vector V;
       float roughness, sharpness, Ks; 
       color specularcolor;)

{
  color C= 0;
  float w  = .18 * (1- sharpness);  
  illuminance (P,Nf,PI/2){
  extern vector L ; 
  extern color Cl;
  varying float nonspec = 0;
  lightsource("__nonspecular", nonspec);
  vector Ln = normalize(L);
  vector H = normalize (Ln + -V);
  C = Cl * specularcolor * Ks *
      smoothstep (.72 - w, 0.72 + w, pow(max(H . Nf, 0), 1/roughness)) * (1 - nonspec);
  }
  return C;
}



#endif
