/* renamed to SHW_brushedmetal for RMR -- tal@SpamSucks_cs.caltech.edu */

/*
 * brushdemetal.sl -- brushed metal (anisotropic)
 *
 * DESCRIPTION:
 *   An attempt at an anisotropic surface.
 *   The surface is idealized as a bed of slightly rough parallel
 *   cylinders. For the cylinders,
 *   I use Kajiya's Phong-like highlight from a cylinder (SIGGRAPH '89),
 *   coupled with an arbitrary shadowing/masking function. Direction
 *   of anisotropy (i.e. the axis of the cylinders) is simply the "U"
 *   direction of patch parameter.
 *
 * PARAMETERS:
 *   Ka, Kd, Ks, roughness, specularcolor - work just like the plastic
 *
 * ANTIALIASING: should antialias itself fairly well
 *
 * AUTHOR: written by Stephen H. Westin, Ford Motor Company Corporate Design
 *
 * last modified  02 December 1995 S. H. Westin
 *
 *
 * HISTORY:
 *   12/24/98 tal -- Updated to newer rman syntax
 *
 */

surface
SHW_brushedmetal (float Ka = 0.03,
                    Kd = 0.03,
                    Ks = 1.0;
              float roughness = .04;
              color specularcolor = 1;
  )
{

  normal Nf;
  vector tangent;                /* Unit vector in "u" direction */
  color env;
  float Kt;
  vector V;                      /* Normalized eye vector */
  vector H;                      /* Bisector vector for Phong/Blinn */
  float spec;                    /* Total "specular" intensity */
  float aniso;                   /* Anisotropic scale factor */
  float shad;                    /* Phong-like shadow/masking function */
  float sin_light, sin_eye;      /* Sines of angles from tangent vector */
  float cos_light, cos_eye;      /* Cosines of angles from tangent vector */
  vector Ln;                     /* Normalized vector to light */

  /* Get unit vector in "u" parameter direction */
  tangent = normalize ( dPdu );

  Nf = faceforward (normalize(N), I);
  V = -normalize (I);

  /* "Specular" highlight in the Phong sense: directional-diffuse */
  cos_eye = -tangent.V;
  sin_eye = sqrt ( 1.0 - cos_eye * cos_eye );
  spec = 0;
  illuminance ( P, Nf, 1.57079632679489661923 /* Hemisphere */ ) {
    Ln = normalize ( L );
    H = 0.5 * ( V + Ln );
    cos_light = tangent.Ln;
    sin_light = sqrt ( 1.0 - cos_light * cos_light );
    aniso = max ( cos_light*cos_eye + sin_light*sin_eye, 0.0 );
    shad = max ( Nf.V, 0.0 ) * max ( Nf.Ln, 0.0 );
    spec += Ks * pow ( aniso, 1.0/roughness ) * shad;
  }

  env = Ks * spec * specularcolor;

  Ci = Os * (Ka*ambient() + Kd*diffuse(Nf)) * Cs + env;

}

