/* SHADER INFO 
 *
 * RudyCstones.sl
 * 
 * Copyright (C) 2002, Rudy Cortes   rcortes AT kc DOT rr DOT com 
 * created  06/12/2002
 * 
 * This software is placed in the public domain and is provided as is 
 * without express or implied warranty.
 *
 * Shader that creates a surface covered with stones of different sizes,
 * trying to replicate the shader usr for the ground in "A BUGS LIFE".
 * Uses st to create the rocks and "shader" space to create the grunge.
 *
 * Feel free to use this shader to create floors covered with small pebbles, anywhere and
 * everywhere, Just list me on the credits under "Shading Team" if you use the
 * shader as is, or under "shader info" if you do any minor modifications to
 * this code.
 ********************************************
 *
 * ka, Kd, Ks, roughness = The usual
 * Km = amount of displacement
 * displace = should the surface be bumped(0) or displaced (1)?
 * minfreq & maxfreq = limits to the rock loop excecution
 * tilefreq = how much will the texture tile. ***Combine with minfreq and maxfreq
 * to reduce rendering times.
 * grungefreq, grunge_Pow, grunginess = freqeuncy, power and depth of grunge
 * stonecolor, groundcolor = this is obvious, isn't it?
 * varyhue, varysat,varylum  = how much will the color change?
 *
 ********************************************
 * ENJOY!
 * modified 10/17/02 Changed algorithms arround to make it render a little faster.
 *
 * NOTE .- This shader is SLOW when you enable bumping, even SLOWER with
 * displacements.
 *
 */


#define repeat(x,freq)    (mod((x) * (freq), 1.0))

#define rotate2d(x,y,rad,ox,oy,rx,ry) \
  rx = ((x) - (ox)) * cos(rad) - ((y) - (oy)) * sin(rad) + (ox); \
  ry = ((x) - (ox)) * sin(rad) + ((y) - (oy)) * cos(rad) + (oy)


#define fuzzpulse(a,b,fuzz,x) (smoothstep((a)-(fuzz),(a),(x)) - \
         smoothstep((b)-(fuzz),(b),(x)))

#define snoise(x)    (noise(x) * 2 - 1)
#define snoise2(x,y) (noise(x,y) * 2 - 1)
#define whichtile(x,freq) (floor((x) * (freq)))
#define MINFILTERWIDTH  1e-7
#define filterwidth_point(p) (max(sqrt(area(p)), MINFILTERWIDTH))
#define udn(x,lo,hi) (smoothstep(.25, .75, noise(x)) * ((hi) - (lo)) + (lo))


/* varyEach takes a computed color, then tweaks each indexed item
 * separately to add some variation.  Hue, saturation, and lightness
 * are all independently controlled.  Hue adds, but saturation and
 * lightness multiply.
 * Original by Larry Gritz. Modified to "hsv" by Rudy Cortes
 */
color varyEach (color Cin; float index, varyhue, varysat, varyval;)
{
    /* Convert to "hsv" space, it's more convenient */
    color Chsv = ctransform ("hsv", Cin);
    float h = comp(Chsv,0), s = comp(Chsv,1), v = comp(Chsv,2);
    /* Modify Chsv by adding Cvary scaled by our separate h,s,v controls */
    h += varyhue * (cellnoise(index+3)-0.5);
    s *= 1 - varysat * (cellnoise(index-14)-0.5);
    v *= 1 - varyval * (cellnoise(index+37)-0.5);
    Chsv = color (mod(h,1), clamp(s,0,1), clamp(v,0,1));
    /* Clamp hsl and transform back to rgb space */
    return ctransform ("hsv", "rgb", clamp(Chsv,color 0, color 1));
}






surface RudyCstones (
    float Ka = .6, Kd = .85,
          Ks = 0, roughness = 1,
          Km = 0.01,
          displace = 0;
    float minfreq = 1,
          maxfreq = 10,
          tilefreq = 6,
          grungefreq = 30, grunge_Pow = 3, grunginess = - 0.8;
   color  stonecolor = color(.7,.6,.4);
   color  groundcolor = color (.45,0.35,0.2);
   float varyhue = .03, varysat = .2, varylum = .25;)

{
 color surface_color, layer_color;
 float layer_opac;
 float ss, tt, stile,ttile;
 float freq,mag;
 float r,theta,angle;
 float d,d0,d1;
 float cx,cy;
 float noifreq = 10, noiscale = 0.3;
 float bub;
 vector V;
 normal Nf;
 float grunge;

 surface_color = groundcolor;
 float surface_mag = 0;

 /*loop for creating color layers of rocks*/
 for (freq = maxfreq ; freq>minfreq;freq -=0.5)
  {
   angle = PI * snoise(freq * 16.31456);  /*randomize angle index*/
  
   rotate2d(s,t,angle,0.5,0.5,cx,cy);    /*randomize rotations*/

   /*repeat tiles and find out in which tile we are at?*/
   ss = repeat(cx,freq * tilefreq);
   tt = repeat(cy,freq * tilefreq);
   stile = whichtile(cx,freq * tilefreq);
   ttile = whichtile(cy,freq * tilefreq);

   /*tile index to be use in vary each*/
   float stoneindex = stile + 13 * ttile;

   /*create buble shapes*/
   bub = 0.5 + snoise2(10 * freq,10 * freq);
   ss += noiscale * snoise(snoise2(s * noifreq, t * noifreq) + 912);
   tt += noiscale * snoise(snoise2(s * noifreq, t * noifreq) + 333);
   /*cx = 0.5 + 0.1 * snoise2( 12.312,  21.773);
   cy = 0.5 + 0.1 * snoise2( 28.398, 62.112); */
   cx = 0.5 + 0.1 * snoise2( freq * 8.456, freq * 18.773);
   cy = 0.5 + 0.1 * snoise2( freq * 28.398, freq * 42.112);
   point p1 =(cx,cy,0);
   point p2 = (ss,tt,0);
   d = distance(p1, p2);
   /*mag= ((0.5 * .8 - abs(bub - 0.5)) / .8) * 60 *(.09 - d * d) *
              ((maxfreq - freq)/maxfreq); */
   mag= (0.5 - abs(bub - 0.5)) * 90 *(.09 - d * d)*((maxfreq - freq)/maxfreq);

   layer_opac = clamp( mag,0,1);
   /*create a diferent color for each rock*/
   layer_color = varyEach(stonecolor, stoneindex,varyhue,varysat,varylum);
   surface_color = mix(surface_color,layer_color,layer_opac);


   /*calculate displacement if Km > .01*/
     if(Km != 0)
   {
    surface_mag = max(surface_mag,mag);
    }
}

   /*apply if grunginess != 0 */
   if(grunginess != 0)
      {
      /* compute turbulence  for grunge*/
       point PP = transform("shader", P) * grungefreq;
       float width = filterwidth_point(PP);
       float cutoff = clamp(0.5 / width, 0, maxfreq);

        float turb = 0, f;
        for (f = 1; f < 0.5 * cutoff; f *= 2)
        turb += abs(snoise(PP * f)) / f;
        float fade = clamp(2 * (cutoff - f) / cutoff, 0, 1);
        turb += fade * abs(snoise(PP * f)) / f;

        grunge = pow(turb, grunge_Pow);
        surface_mag += grunge * grunginess;
        
        }

  if (displace == 1)
  {
  P += Km * surface_mag * normalize(N);
  N = normalize(calculatenormal(P)); 
  }
  else {
  N = normalize(calculatenormal(P + Km * surface_mag * normalize(N)));
  }
 /*compute normals and vectors for shading*/
  Nf = faceforward(normalize(N),I);
  V = - normalize(I);

/*color output*/

Oi = Os;
Ci = surface_color * Oi * (Ka * ambient() + Kd * diffuse(Nf))+
      Ks * specular(Nf,V,roughness);

}

