/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p. 72 */
/* Listing 5.1   Polygonal approximation of a hyperboloid */

#include <ri.h>
#include <stdio.h>
#include "hcontour.h"

RtColor color = {.9,.9,.5};
Go() { 
    RiColor(color);
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
    
    pp1 = point1;
    pp2 = point2;
    /*  
     * For each adjacent pair of points in the surface profile,
     *  draw a hyperboloid by sweeping the line segment defined by 
     *  those points about the z axis.
     */
    pp1[0] = points[0].y;
    pp1[1] = 0;
    pp1[2] = points[0].x;
    for (pt = 1; pt < npoints-1; pt++) {
        pp2[0] = points[pt].y;
        pp2[1] = 0;
        pp2[2] = points[pt].x;
        RiColor(colors[pt]);
        PolyBoid(pp1, pp2, NDIVS, pt-1);
        tmp = pp1; pp1 = pp2; pp2 = tmp; 
    }
    pt = npoints-1;
    pp2[0] = points[pt].y;
    pp2[1] = 0;
    pp2[2] = points[pt].x;
    RiColor(colors[pt]);
    PolyBoid(pp1, pp2, NDIVS, pt-1);
}

/* Listing 5.1  Polygonal approximation of a hyperboloid  */
/*   
 * PolyBoid(): approximate a hyperboloid using triangles.  
 *      point0, point1: three-dimensional points as in RiHyperboloid()  
 *      ndivs: number of triangles to generate  
 *      parity: phase factor (0 or 1) to mate triangles from adjacent bands   
 */ 
PolyBoid(point0,point1,ndivs,parity) 
RtFloat *point0,*point1; int ndivs, parity; 
{ 
    RtPoint        vertexpair0[2], 
                   vertexpair1[2], 
                   *ptrnextpair = vertexpair0, 
                   *ptrlastpair = vertexpair1, 
                   *temp, 
                   triangle[3]; 
    int i; 
#define SWAP(a,b,temp) temp = a; a = b; b = temp; 
#define COPY_POINT(d, s)       {d[0]=s[0]; d[1]=s[1]; d[2]=s[2];} 
    getnextpair(0+parity/2.0, ptrnextpair, point0, point1, ndivs); 
    for (i = 1; i <= ndivs; i++) { 
        SWAP(ptrlastpair, ptrnextpair, temp) 
        getnextpair(i+parity/2.0, ptrnextpair, point0, point1, ndivs); 
        COPY_POINT(triangle[0], ptrlastpair[0]); 
        COPY_POINT(triangle[1], ptrlastpair[1]); 
        COPY_POINT(triangle[2], ptrnextpair[1]); 
        RiPolygon( (RtInt) 3, RI_P, (RtPointer) triangle, RI_NULL); 
        COPY_POINT(triangle[0], ptrnextpair[0]); 
        COPY_POINT(triangle[1], ptrnextpair[1]); 
        COPY_POINT(triangle[2], ptrlastpair[0]); 
        RiPolygon( (RtInt) 3,  RI_P, (RtPointer) triangle, RI_NULL); 
    } 
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
