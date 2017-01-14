/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p. 81 */ 
/* Listing 5.3  Bowling pin with normals assigned to vertices, defined using RiPointsPolygons  */

#include <ri.h>
#include "hcontour.h"

RtColor color = {.9,.9,.5};
Go() { 
    RiColor(color);
    /*RiTranslate(0.0,-0.5,0.0);*/
    RiRotate(-90.0, 1.0, 0.0, 0.0);
    PolySurfOR(points, colors, NPOINTS);
}


PolySurfOR(points, colors, npoints)
Point2D points[];
RtColor colors[];
int npoints;
{
#define NDIVS 8
    int pt;
    RtPoint point1, point2;
    RtFloat *pp1, *pp2, *tmp;
    RtPoint normal1, normal2;
    RtFloat *pm1, *pm2;
    
    pp1 = point1;
    pp2 = point2;
    pm1 = normal1;
    pm2 = normal2;
    /*  
     * For each adjacent pair of points in the surface profile,
     *  draw a hyperboloid by sweeping the line segment defined by 
     *  those points about the z axis.
     */
    pp1[0] = points[0].y;
    pp1[1] = 0;
    pp1[2] = points[0].x;
    pm1[0] = points[0].x - points[1].x;
    pm1[1] = 0;
    pm1[2] = points[1].y - points[0].y;
    for (pt = 1; pt < npoints-1; pt++) {
        pp2[0] = points[pt].y;
        pp2[1] = 0;
        pp2[2] = points[pt].x;
        pm2[0] = points[pt-1].x - points[pt+1].x;
        pm2[1] = 0;
        pm2[2] = points[pt+1].y - points[pt-1].y;
        RiColor(colors[pt]);
        PolyBoid(pp1, pp2, pm1, pm2, NDIVS, pt-1);
        tmp = pp1; pp1 = pp2; pp2 = tmp; 
        tmp = pm1; pm1 = pm2; pm2 = tmp; 
    }
    pt = npoints-1;
    pp2[0] = points[pt].y;
    pp2[1] = 0;
    pp2[2] = points[pt].x;
    pm2[0] = points[pt-1].x - points[pt].x;
    pm2[1] = 0;
    pm2[2] = points[pt].y - points[pt-1].y;
    RiColor(colors[pt]);
    PolyBoid(pp1, pp2, pm1, pm2, NDIVS, pt-1);
}

#define PI 3.14159 
getnextpair(offset, ptrnextpair, point0, point1, ndivs) 
float offset; 
RtPoint *ptrnextpair; 
RtFloat *point0,*point1; 
int ndivs; 
{   float r; 
    double sin(), cos(); 

    r = 2*PI*offset/ndivs; 
    ptrnextpair[0][0] = point0[0]*sin(r); 
    ptrnextpair[0][1] = point0[0]*cos(r); 
    ptrnextpair[0][2] = point0[2]; 

    r = 2*PI*(offset-.5)/ndivs; 
    ptrnextpair[1][0] = point1[0]*sin(r); 
    ptrnextpair[1][1] = point1[0]*cos(r); 
    ptrnextpair[1][2] = point1[2]; 
} 



/* Listing 5.3  Bowling pin with normals assigned to vertices, */
/*              defined using RiPointsPolygons()    */
#define MAXVERTS 100 

RtPoint vertexstrip[MAXVERTS][2]; 
RtPoint normalstrip[MAXVERTS][2]; 
RtInt nverts[MAXVERTS][2], indices[MAXVERTS][2][3]; 

/*  
 * PolyBoid(): declare a polygonal "hyperboloid" using RiPointsPolygons()
 */
PolyBoid(point0, point1, normal0, normal1, ndivs, parity)
RtFloat *point0, *point1, *normal0, *normal1; 
int ndivs, parity;
{ 
    int i;

    for (i = 0; i <= ndivs; i++) { 
        getnextpair(i+parity/2.0, vertexstrip[i], point0, point1, ndivs); 
        getnextpair(i+parity/2.0, normalstrip[i], normal0, normal1, ndivs); 
    } 
    for (i = 0; i < ndivs; i++) { 
        nverts[i][0] = nverts[i][1] = 3; 
        indices[i][0][0] = i*2; 
        indices[i][0][1] = i*2+1; 
        indices[i][0][2] = (i+1)*2+1; 
        indices[i][1][0] = (i+1)*2+1; 
        indices[i][1][1] = (i+1)*2; 
        indices[i][1][2] = i*2; 
    } 
    RiPointsPolygons( (RtInt) (ndivs*2), (RtInt *) nverts, (RtInt *) indices,  
        RI_P, (RtPointer) vertexstrip,  
        RI_N, (RtPointer) normalstrip,  
        RI_NULL);
} 

