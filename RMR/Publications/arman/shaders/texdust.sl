/****************************************************************************
 * texdust.sl - apply an animated texture to a sphere primitive.
 *
 * Parameters:
 *   Ka, Kd - the usual meaning
 *   falloff - Controls softness of sphere edge: higher == softer
 *   texturename - base texture name: it will add ".0001.tx" for example
 *   id - a "label" for each sphere to make it easy for each to differ
 *   life - 0-1 controls the animation of the texture.  If life goes 
 *          outside of the range 0-1, the texture will stop animating.
 *   maxLife - how many texture frames are there out there?
 *   texScaleU, texScaleV - U and V scale.  Use a large texture and set 
 *          these scale parameters small and the shader will offset 
 *          randomly into the texture differently for each sphere.
 *
 * Reference:
 *   _Advanced RenderMan: Creating CGI for Motion Picture_, 
 *   by Anthony A. Apodaca and Larry Gritz, Morgan Kaufmann, 1999.
 *
 ****************************************************************************/


surface
texdust ( float Ka = 1.0, Kd = 1.0;
	  float falloff = 3;
	  string texturename = "";
	  float id = 1.0;
	  float life = 1.0, maxLife = 70.0;
	  float texScaleU = .3, texScaleV = .3; )
{
    color Ct = Cs;
    normal Nf = faceforward(normalize(N),I);
    vector V = normalize(I);
  
    if (texturename != "") {  
	/* Assign ss and tt to be textured on the sphere and pointed 
	 * at the camera.  The texture will look the same from any direction
	 */
	normal NN = normalize(N);
	vector Cr = V ^ NN;
	float ss = ycomp(Cr)+.5;
	float tt = xcomp(Cr)+.5;
	/* Scale and offset into the texture - randomly for each "id" */
	ss = ss * texScaleU + float cellnoise(id)*(1.0-texScaleU);
	tt = tt * texScaleV + float cellnoise(id+12)*(1.0-texScaleV);
	/* Build the texture filename and read it.  It's going to look 
	 * for a filename in this format: "basename.0001.tx" 
	 */
	string name = format("%s.%04d.tx",texturename,
			     clamp(round(life*maxLife)+1.0,1,maxLife));
	Ct = color texture(name,ss,tt);
    }

    /* Shade it */
    Oi = Os * pow(abs(Nf . V),falloff) * Ct;
    Ci = Oi * Cs * (Ka*ambient() + Kd*diffuse(Nf)); 
}
