/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p. 204 */
/* Listing 10.3  A procedural fractal generator */

/* Fractal(): procedural model for a fractal triangle.  If the triangle's 
 *   level of detail is below a threshhold, it is presented directly as a 
 *   triangle; otherwise it is divided into seven smaller triangles 
 */
#include <ri.h>
#include <stdio.h>
#include <math.h>
#ifdef __STDC__
#include <stdlib.h>
#else
extern char *malloc();
#endif
#include "frac.h"
#define RiProcedural(t, b, fd, ff) FractalDiv(t, 2.0)
int FractalDiv(), FractalFree();

static int randLen = 0;

void getRandLen()
{
    unsigned long check;

    check = rand();
    check |= rand();
    check |= rand();
    check |= rand();
    check |= rand();
    check |= rand();
    check |= rand();
    if (check <= (1 << 16)) randLen = 15;
    else		    randLen = 31;
}

Go() 
{
    int childnum;
    FractalTriangle mytriangle;
    FractalPoint *pVertex;
    RtBound bound;

    getRandLen();

    pVertex = &(mytriangle.vertices[0]);
    pVertex->location[0] = -1;
    pVertex->location[1] = -0.5;
    pVertex->location[2] = 0;
    (pVertex++)->seed = rand();
    pVertex->location[0] = 1;
    pVertex->location[1] = -0.5;
    pVertex->location[2] = 0;
    (pVertex++)->seed = rand();
    pVertex->location[0] = 0;
    pVertex->location[1] = 0.5;
    pVertex->location[2] = 1;
    (pVertex++)->seed = rand();
    mytriangle.level = 0;
    mytriangle.children = (FractalTriangle *) NULL;
    TriangleBound(&mytriangle, bound);
    RiProcedural(&mytriangle, bound, FractalDiv, FractalFree); 
}

#define MAXLEVELS 4

/* ^^^^^^^^^^^^^^^^^^^^^^^^^^^ */
/* Listing 10.3  A procedural fractal generator */
/* Fractal(): procedural model for a fractal triangle.  If the triangle's level
 *    of detail is below a threshold, or the triangle has been subdivided more
 *    than a certain number of levels, it is presented directly as a
 *    triangle; otherwise it is divided into seven smaller triangles 
 */

#define MOVEPT(src,dst) {dst[0]=src[0]; dst[1]=src[1]; dst[2]=src[2]; }

/* FractalDiv(): RenderMan refinement procedure for subdividing a fractal
 *    triangle. */
FractalDiv(data, levelofdetail)
RtPointer data;
RtFloat levelofdetail;
{
    FractalTriangle *pTriangle = (FractalTriangle *)data, *pChild;
    RtPoint vertices[3];
    RtBound bound;
    int nchildren;

    if (levelofdetail<1.0 || pTriangle->level>MAXLEVELS) {         
        /* Small enough to be rendered */
        MOVEPT(pTriangle->vertices[0].location, vertices[0]);
        MOVEPT(pTriangle->vertices[1].location, vertices[1]);
        MOVEPT(pTriangle->vertices[2].location, vertices[2]);
        RiPolygon( (RtInt) 3, RI_P, (RtPointer) vertices, RI_NULL);
    } else {        /* Too large; subdivide */
        if (!pTriangle->children)
            TriangleSplit(pTriangle);
        pChild = pTriangle->children;
        nchildren = 4;
        while (nchildren--) {
        /* TriangleBound() computes the bounding box for a triangle */
        TriangleBound(pChild, bound);
        RiProcedural(pChild++, bound, FractalDiv, FractalFree);
        }
    }
}
/* TriangleSplit(): subdivide a FractalTriangle, giving it an array of
 *    four dynamically-allocated children. */
TriangleSplit(pFT)
FractalTriangle *pFT;
{
    int childnum;
    RtBound bound;
    FractalTriangle *pChildren;

    pFT->children = 
        pChildren = (FractalTriangle *)malloc(4*sizeof(FractalTriangle));
    /* Give each child a level number  */
    for (childnum = 0; childnum < 4; childnum++) {
        pChildren[childnum].children = NULL;
        pChildren[childnum].level = pFT->level+1;
    }
    /* Give the first three children one vertex from the parent and one
     *       edge midpoint as vertices */
    for (childnum = 0; childnum < 3; childnum++) {
        pChildren[childnum].vertices[0] = pFT->vertices[childnum];
        EdgeSplit(&(pFT->vertices[childnum]),
                  &(pFT->vertices[(childnum+1)%3]),
                  &(pChildren[childnum].vertices[1]));
    }
    /* Give the fourth (inside) child vertices from the split edges, and give
     *        the other three children their third vertex. */
    for (childnum = 0; childnum < 3; childnum++) {
        pChildren[3].vertices[childnum] = 
            pChildren[(childnum+1)%3].vertices[2] =
                pChildren[childnum].vertices[1];
    }
}
#define SEEDTODISPLACEMENT(seed) (seed/((double)((unsigned long)1<<randLen)))
double EdgeLen();
/* EdgeSplit(): split an edge between two vertices to derive a third vertex */
EdgeSplit(pFP1, pFP2, pFPOut)
FractalPoint *pFP1, *pFP2, *pFPOut;
{
    double displacement = 
        SEEDTODISPLACEMENT((pFP1->seed + pFP2->seed)/2);

    srand((pFP1->seed + pFP2->seed)/2);
    pFPOut->seed = rand();
    EdgeMidpt(pFP1->location, pFP2->location, pFPOut->location);
    pFPOut->location[2] += 0.25 * displacement *
            EdgeLen(pFP1->location, pFP2->location);
}
/* EdgeMidpt(): return the midpoint of an edge */
EdgeMidpt(pt1, pt2, midPt)
RtPoint pt1, pt2, midPt;
{
    midPt[0] = (pt1[0]+pt2[0])/2;
    midPt[1] = (pt1[1]+pt2[1])/2;
    midPt[2] = (pt1[2]+pt2[2])/2;
}
/* EdgeLen(): return the Euclidean length of an edge */
double EdgeLen(pt1, pt2)
RtPoint pt1, pt2;
{
    double xdel = pt2[0]-pt1[0],
           ydel = pt2[1]-pt1[1],
           zdel = pt2[2]-pt1[2];
    double len = sqrt(xdel*xdel + ydel*ydel + zdel*zdel);
    return(len);
}
/* TriangleBound(): calculate the fractal bounding box of a triangle as 
 *    the union of the bounding boxes of its edges  */
TriangleBound(pFT, bound)
FractalTriangle *pFT;
RtBound bound;
{
    RtBound tmpBound;
    EdgeBound(pFT->vertices[0].location, pFT->vertices[1].location, bound);
    EdgeBound(pFT->vertices[1].location, 
              pFT->vertices[2].location, tmpBound);
    BBoxUnion(bound, tmpBound, bound);
    EdgeBound(pFT->vertices[2].location, 
              pFT->vertices[0].location, tmpBound);
    BBoxUnion(bound, tmpBound, bound);
}
#define min(a,b) ((a)<(b)?(a):(b))
#define max(a,b) ((a)>(b)?(a):(b))
#define SPHEREBUMP 1.4

/* EdgeBound: calculate the fractal bounding box of an edge, with its y 
 *    range expanded to allow for midpoint perturbation. */
EdgeBound(pt1, pt2, bound)
RtPoint pt1, pt2;
RtBound bound;
{
    double radius;
    RtPoint midpt;

    bound[0] = min(pt1[0], pt2[0]); bound[1] = max(pt1[0], pt2[0]); 
    bound[2] = min(pt1[1], pt2[1]); bound[3] = max(pt1[1], pt2[1]); 
    EdgeMidpt(pt1, pt2, midpt);
    radius = (EdgeLen(pt1, pt2)/2)*SPHEREBUMP;
    bound[4] = midpt[2] - radius; bound[5] = midpt[2] + radius;
}
/* BBoxUnion: set a bound to be the union of two other bounds */
BBoxUnion(bound1, bound2, ubound)
RtBound bound1, bound2, ubound;
{
    ubound[0] = min(bound1[0], bound2[0]);
    ubound[1] = max(bound1[1], bound2[1]);
    ubound[2] = min(bound1[2], bound2[2]);
    ubound[3] = max(bound1[3], bound2[3]);
    ubound[4] = min(bound1[4], bound2[4]);
    ubound[5] = max(bound1[5], bound2[5]);
}


FractalFree(data)            /* N E W */
RtPointer data;
{
    FractalTriangle *pTriangle = (FractalTriangle *)data;
    if (pTriangle->level == 0) 
        FreeChildren(pTriangle->children);
}

FreeChildren(pFTChildren)
FractalTriangle *pFTChildren;
{
    if (pFTChildren) {
        FreeChildren(pFTChildren);   
        free(pFTChildren++);
        FreeChildren(pFTChildren);   
        free(pFTChildren++);
        FreeChildren(pFTChildren);   
        free(pFTChildren++);
        FreeChildren(pFTChildren);   
        free(pFTChildren++);
    }
}
