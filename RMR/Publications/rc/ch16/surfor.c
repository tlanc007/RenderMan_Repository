/* Copyrighted Pixar 1989 */
/* Used with the RenderMan Companion chapter 16 */

#define NU    13
#define MAXNPTS 100
#define F .5522847
float coeff[NU][2] = { 
{ 1, 0 }, { 1, F }, { F, 1 }, { 0, 1 }, {-F, 1 }, {-1, F }, 
{-1, 0 }, {-1,-F }, {-F,-1 }, { 0,-1 }, { F,-1 }, { 1,-F }, { 1, 0} };

RtPoint         mesh[MAXNPTS][NU];

SurfOR(points, npoints)
Point2D points[];
int npoints;
{
    int             u, v;

/*    coeff holds a matrix of coefficients for sweeping a point on the XZ plane
 *    circularly around the Z axis, with the circle approximated by 
 *    4 bezier patches
 */
    for (v = 0; v < npoints; v++) {    
        /* 
         *  Start at the upper left of the mesh.  For each 
         *  control point on the circle being swept out, 
         *  rotate every point on the XZ curve into position
         */
        for (u = 0; u < NU; u++) {    
            /*  Here comes each point on the XZ curve */
            mesh[v][u][0] = points[v].x * coeff[u][0];
            mesh[v][u][1] = points[v].x * coeff[u][1];
            mesh[v][u][2] = points[v].z;
        }
    }
    RiBasis(RiBezierBasis, RI_BEZIERSTEP, RiBezierBasis, RI_BEZIERSTEP);
    RiPatchMesh(RI_BICUBIC, 
            (RtInt) NU, RI_NONPERIODIC, 
            (RtInt) npoints, RI_NONPERIODIC, 
            RI_P, (RtPointer) mesh, 
            RI_NULL);
}
