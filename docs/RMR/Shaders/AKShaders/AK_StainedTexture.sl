/*
   AK_StainedTexture.sl
   Andrew V. Klishin
   avk107 AT yahoo DOT com 
*/

void
voronoi_extra (	uniform float numS, numT;
		float jitter;
		output float ss, tt;
		output float border)
{
    float SS = ss * numS;
    float TT = tt * numT;
    float sthiscell = floor(SS)+0.5;
    float tthiscell = floor(TT)+0.5;
    float f1 = 1000;
    float f2 = 1000;
    uniform float i, j;
    for (i = -1;  i <= 1;  i += 1) {
	float stestcell = sthiscell + i;
        for (j = -1;  j <= 1;  j += 1) {
	    float ttestcell = tthiscell + j;
	    float spos = stestcell +
		   jitter * (cellnoise(stestcell, ttestcell) - 0.5);
	    float tpos = ttestcell +
		   jitter * (cellnoise(stestcell+23, ttestcell-87) - 0.5);
	    float soffset = spos - SS;
	    float toffset = tpos - TT;
	    float dist = soffset*soffset + toffset*toffset;
	    if (dist < f1) {
		f2 = f1;
		f1 = dist;
    		ss =  spos/numS;
    		tt =  tpos/numT;
	    } else if (dist < f2)
		f2 = dist;
	}
    }
    border = sqrt(f2) - sqrt(f1);
}

surface
AK_StainedTexture     (	float Ka = 0.2;
			float Kd = 0.8;
			float Ks = 0.5;
			float roughness = 0.2;
			string Texture = "";
			float Angle = 0;
			float FlipS = 0;
			float FlipT = 0;
			color GapColor = 0.5;
			color Specular = 1.0;
			float Opacity = 1.0;
			uniform float Rows = 10;
			uniform float Cols = 10;
			float Jitter = 0.75;
			float GapWidth = 0.2;
			float GapBump = 0.0 )
 {
    Ci = Cs;
    Oi = Os * Opacity;

    if (Texture != "") {
	normal Nf;
	vector V;
	color GlassColor;
	color GlassOpac;
	float Border = 0;
	float ss = s, tt = t;
	voronoi_extra (Rows, Cols, Jitter, ss, tt, Border);
	ss = clamp(abs(ss),0,1);
	tt = clamp(abs(tt),0,1);
	if (Angle != 0){
		point Temp;
		setxcomp (Temp,ss);
		setycomp (Temp,tt);
		Temp = rotate(Temp, radians(Angle), point(0,0,0), point(0,0,1));
		ss = xcomp(Temp);
		tt = ycomp(Temp);} 
	if (FlipS != 0)
		ss = 1 - ss;
	if (FlipT != 0)
		tt = 1 - tt;
	float Gap = smoothstep (0,GapWidth,Border);
	GlassColor = color texture(Texture, ss, tt);
	GlassColor = color mix(GapColor, GlassColor, Gap);
	GlassOpac = color mix(color 1, color Opacity, Gap);

    N = calculatenormal(P + (Gap * GapBump * normalize(N)));
    Nf = faceforward( normalize(N), I );
    V = -normalize(I);

    Oi = GlassOpac;
    Ci = Oi * ( GlassColor * (Ka*ambient() + Kd*diffuse(Nf)) +
	 	Specular * Ks * specular(Nf,V,roughness) );
    }	
 }
