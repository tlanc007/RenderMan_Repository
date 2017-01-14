/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p. 76 */ 
/* Listing 5.2  Bowling pin with normals assigned to vertices  */

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
    int pt;
    RtPoint point1, point2, normal1, normal2;
    RtFloat *pp1, *pp2,  *pm1, *pm2, *tmp;
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
        PolyBoid(pp1, pp2, pm1, pm2, 8, pt-1);
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
    PolyBoid(pp1, pp2, pm1, pm2, 8, pt-1);
}

PolyBoid(point0, point1, normal0, normal1, ndivs, parity) 
RtFloat *point0, *point1, *normal0, *normal1; int ndivs, parity; 
{ 
    RtPoint vertexpair0[2], vertexpair1[2], 
            *ptrnextvertex = vertexpair0, 
            *ptrlastvertex = vertexpair1, 
            *temp, 
            vertextriangle[3]; 
    RtPoint normalpair0[2], normalpair1[2], 
            *ptrnextnormal = normalpair0, 
            *ptrlastnormal = normalpair1, 
            normaltriangle[3]; 
    int i; 
#define SWAP(a,b,temp) temp = a; a = b; b = temp; 
#define COPY_POINT(d, s)      {d[0]=s[0]; d[1]=s[1]; d[2]=s[2];} 
    getnextpair(0+parity/2.0, ptrnextvertex, point0, point1, ndivs); 
    getnextpair(0+parity/2.0, ptrnextnormal, normal0, normal1, ndivs); 
    for (i = 1; i <= ndivs; i++) { 
        SWAP(ptrlastvertex, ptrnextvertex, temp) 
        SWAP(ptrlastnormal, ptrnextnormal, temp) 
        getnextpair(i+parity/2.0, ptrnextvertex, point0, point1, ndivs); 
        getnextpair(i+parity/2.0, ptrnextnormal, normal0, normal1, ndivs); 
        COPY_POINT(vertextriangle[0], ptrlastvertex[0]); 
        COPY_POINT(vertextriangle[1], ptrlastvertex[1]); 
        COPY_POINT(vertextriangle[2], ptrnextvertex[1]); 
        COPY_POINT(normaltriangle[0], ptrlastnormal[0]); 
        COPY_POINT(normaltriangle[1], ptrlastnormal[1]); 
        COPY_POINT(normaltriangle[2], ptrnextnormal[1]); 
        RiPolygon( (RtInt) 3, RI_P, (RtPointer) vertextriangle, 
                     RI_N, (RtPointer) normaltriangle, 
                     RI_NULL); 
        COPY_POINT(vertextriangle[0], ptrnextvertex[0]); 
        COPY_POINT(vertextriangle[1], ptrnextvertex[1]); 
        COPY_POINT(vertextriangle[2], ptrlastvertex[0]); 
        COPY_POINT(normaltriangle[0], ptrnextnormal[0]); 
        COPY_POINT(normaltriangle[1], ptrnextnormal[1]); 
        COPY_POINT(normaltriangle[2], ptrlastnormal[0]); 
        RiPolygon( (RtInt) 3, RI_P, (RtPointer) vertextriangle, 
                     RI_N, (RtPointer) normaltriangle, 
                     RI_NULL); 
    } 
} 

getnextpair(offset,ptrnextpair,point0,point1,ndivs)
float offset;
RtPoint *ptrnextpair;
RtFloat *point0,*point1;
int ndivs;
{
    float r; double sin(), cos();

    r = 2*3.14159*offset/ndivs;
    ptrnextpair[0][0] = point0[0]*sin(r);
    ptrnextpair[0][1] = point0[0]*cos(r);
    ptrnextpair[0][2] = point0[2];

    r = 2*3.14159*(offset-.5)/ndivs;
    ptrnextpair[1][0] = point1[0]*sin(r);
    ptrnextpair[1][1] = point1[0]*cos(r);
    ptrnextpair[1][2] = point1[2];
}

