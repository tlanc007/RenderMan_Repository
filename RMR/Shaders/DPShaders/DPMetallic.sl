/* I took wave's lead and renamed metallic to DPMetallic.sl -- tal AT renderman DOT org */

/* 
 * metallic.sl
 *
 * AUTHOR: Darwyn Peachy
 *
 * REFERENCES:
 *    _Texturing and Modeling: A Procedural Approach_, by David S. Ebert, ed.,
 *    F. Kenton Musgrave, Darwyn Peachey, Ken Perlin, and Steven Worley.
 *    Academic Press, 1994.  ISBN 0-12-228760-6.
 */
 
#define BROWN     color (0.1307,0.0609,0.0355)
#define BLUE0     color (0.4274,0.5880,0.9347)
#define BLUE1     color (0.1221,0.3794,0.9347)
#define BLUE2     color (0.1090,0.3386,0.8342)
#define BLUE3     color (0.0643,0.2571,0.6734)
#define BLUE4     color (0.0513,0.2053,0.5377)
#define BLUE5     color (0.0326,0.1591,0.4322)
#define BLACK     color (0,0,0)

surface
DPMetallic()
{
    point Nf = normalize(faceforward(N, I));
    point V = normalize(-I);
    point R;        /* reflection direction */
    point Rworld;   /* R in world space */
    color Ct;
    float altitude;

    R = 2 * Nf * (Nf . V) - V;
    Rworld = normalize(vtransform("world", R));
    altitude = 0.5 * zcomp(Rworld) + 0.5;
    Ct = spline(altitude,
        BROWN, BROWN, BROWN, BROWN, BROWN,
        BROWN, BLUE0, BLUE1, BLUE2, BLUE3,
        BLUE4, BLUE5, BLACK);
    Oi = Os;
    Ci = Os * Cs * Ct;
}
