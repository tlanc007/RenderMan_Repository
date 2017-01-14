/***************************************************************

  s_fancysurf.sl - fancy surface shader

  DESCRIPTION:
  A fancy surface shader that incorporates the
  Oren-Nayar diffuse lighting model with rim lighting 
  and translucency. Also has one color texture and one bump texture.
  Nothing really new here, but it puts it all in one place for
  convenience.

  Oren-Nayar diffuse model originally written by Larry Gritz.
  I just took his shader and made a function out of it.

  The rim lighting model was found through experimentation. I'm sure
  I could explain it if I really thought about it, but for now
  I just use it cause it seems to work. Has problems if you try
  shadowing the rim light.

  PARAMETERS:
  Ka		ambient contribution
  Kd		diffuse contribution
  Ks		specular contribution
  Krim		rimlight contribution
  Ktranslucent	translucent backlight contribution
  specularcolor	color of specular highlight
  diffuserough	roughness parameter for Oren-Nayar diffuse
  specularrough roughness parameter for specular() function
  rimscatter    controls rim "wraparound"
		0 for small rim, 1 for whole surface
  colormap	name of color texture map
  bumpmap	name of greyscale bump map
  bumpdepth	amplitude of bump
  bumpmidval	bias value for bumpmap values
  s_offset	texturemap s offset
  t_offset	texturemap t offset
  s_scale	texturemap s scaling factor
  t_scale	texturemap t scaling factor 

  AUTHOR: Mike King

  REVISION HISTORY:
  11/09/1999: Removed conditional compilation that worked around
              an old BMRT bug. Added clamping to the alpha and
              beta angles to avoid instability around 90 degree
              grazing angles. This is not a correct solution, but
              it should at least avoid bright speckles most of
              the time.

***************************************************/ 

#define thetaMin ((-PI/2)+.01)
#define thetaMax ((PI/2)-.01)

/* grazing specular function controls rim lighting from
   lights that face towards the camera. backscatter controls
   the size and intensity of the rim lighting. */
color grazing_specular(normal Nn; vector V; uniform float backscatter;)
{
    extern point P;
    extern vector L;
    extern color Cs;
    extern color Cl;

    color lightC = 0;
    uniform color black = 0;

    float blendval;
    float ldotn;
    float idotn;
    vector Ln;
    vector In = -V;
    vector NN = normalize(Nn);
    /* roughfactor controls brightness of rimlight */
    uniform float roughfactor;
    /* scatter controls how big an area the rimlight covers */
    uniform float scatter;
    uniform float rimlight;

   /* these values were found empirically. can adjust to get
      get different results. */
    roughfactor = 0.5-0.5*backscatter;
    scatter = (1-backscatter) * 0.1;

    illuminance(P,Nn,PI) {
        if( lightsource("__rimlight",rimlight) == 0)
        { 
            rimlight = 0;
        }
        if(rimlight>0)
        {
            Ln = normalize(L);
            /* idotn tells us angle between normal and view direction */
            idotn = In.Nn;
            /* ldotn tells us angle between normal and light direction */
            ldotn = Ln.Nn;
            /* put both dot products in range [0,1] and multiply. */
            blendval = ((ldotn+1)/2) * ((idotn+1)/2);
           /* only want to use values in [0, 0.5] to cause rim lighting. 
              changing the range will alter the effect */
            blendval = smoothstep(scatter,roughfactor,blendval);
            lightC += mix(black,Cl,blendval);
        }
    }
    return lightC;
}

/* orennayart diffuse function contains code originally
   written by Larry Gritz. I just added the check for
   non diffuse lights */
color orennayar_diffuse( normal Nn; vector V; float sigma;)
{
    extern point P;
    extern vector L;
    extern color Cs;
    extern color Cl;

    vector LN;
    color lightC = 0;
    color L1, L2;
    float C1, C2, C3;
    float theta_r, theta_i, cos_theta_i;
    float alpha, beta, sigma2, cos_phi_diff;

    theta_r = acos( V . Nn);
    sigma2 = sigma * sigma;
    uniform float nondiffuse = 0;
    illuminance (P, Nn, PI/2) {
        if( lightsource("__nondiffuse",nondiffuse) == 0)
        { 
            nondiffuse = 0;
        }
        if(nondiffuse==0)
        {
            LN = normalize(L);
            cos_theta_i = LN . Nn;
            cos_phi_diff = normalize(V-Nn*(V.Nn)) . normalize(LN - Nn*(LN.Nn));
            theta_i = acos (cos_theta_i);
            alpha = max (theta_i, theta_r);
            beta = min (theta_i, theta_r);
            alpha = clamp(alpha, thetaMin, thetaMax);
            beta = clamp (beta, thetaMin, thetaMax);
            C1 = 1 - 0.5 * sigma2/(sigma2+0.33);
            C2 = 0.45 * sigma2 / (sigma2 + 0.09);
            if (cos_phi_diff >= 0)
                C2 *= sin(alpha);
            else C2 *= (sin(alpha) - pow(2*beta/PI,3));
            C3 = 0.125 * sigma2 / (sigma2+0.09) * pow ((4*alpha*beta)/(PI*PI),2);
            L1 = Cs * (cos_theta_i * (C1 + cos_phi_diff * C2 * tan(beta) +
                                      (1 - abs(cos_phi_diff)) * C3 * tan((alpha+beta)/2)));
            L2 = (Cs * Cs) * (0.17 * cos_theta_i * sigma2/(sigma2+0.13) *
                              (1 - cos_phi_diff*(4*beta*beta)/(PI*PI)));
            lightC += (L1 + L2) * Cl;
        }
    }
    return lightC;
}

surface
MKfancysurf (float Ka = 1;
             float Kd = .6;
             float Ks = .4;
             float Krim = 1;
             float Ktranslucent = 0;
             color specularcolor = 1;
             float diffuserough = 0.0;
             float specularrough = .2;
             float rimscatter = 0.5;
             string colormap="";
             string bumpmap="";
             float bumpdepth = 0.0;
             float bumpmidval = 0.5;
             float s_offset = 0;
             float t_offset = 0;
             float s_scale = 1;
             float t_scale = 1;
    )
{
    color rimcolor;
    color Ct;
    float bumpMagnitude;

    point PP = P;
    normal Nn = normalize(N);
    normal Nf = Nn;
    vector V = -normalize(I);
    color Cback = 0;

    if(colormap != "")
    {
        Ct = 
            color texture(colormap,(s_scale*s)+s_offset, (t_scale*t)+t_offset);
    } else
    {
        Ct = 1.0;
    }

    if(bumpmap != "")
    {
        bumpMagnitude = 
            texture(bumpmap,(s_scale*s)+s_offset,(t_scale*t)+t_offset);
        PP -= Nn * bumpdepth * (bumpMagnitude-bumpmidval);
        Nf = normalize(calculatenormal(PP));
    }

    Nf = faceforward(Nf,I);

    if(Ktranslucent > 0)
    {
        Cback = Cs * Ct * diffuse(-Nf);
    }

    rimcolor = grazing_specular(Nf,V,rimscatter);
    Oi = Os;
    Ci = Os * (Cs * Ct * (Ka*ambient())
               + Kd*orennayar_diffuse(Nf,V,diffuserough)
               + Ks*specular(Nf,V,specularrough)*specularcolor
               + Krim*rimcolor
               + Ktranslucent*Cback); 
}


