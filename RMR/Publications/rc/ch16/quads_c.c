/* Copyrighted Pixar 1989 */
/* Used with the RenderMan Companion chapter 16 */

/* Listing 16c - Routine generating quadric surfaces shown in Figure 4.1 */

#include <ri.h>
#include <math.h>

RtPoint to = { 0.0, 1.0, -3.0},
        from = { 0.0, 0.0, 1.0};

Go()
{
    RtFloat intensity;

    intensity = 0.2;

    RiDeclare("intensity", "uniform float");
    RiDeclare("from", "uniform point");
    RiLightSource("ambientlight", 
        (RtToken)"intensity",(RtPointer)&intensity, RI_NULL);

    intensity = 1.0;
    RiLightSource("distantlight", (RtToken)"intensity", (RtPointer)&intensity, 
    /*  (RtToken)"from", (RtPointer)from, */
    /*  (RtToken)"to", (RtPointer)to,  */
        RI_NULL);
    ShowQuads();
}

#define OFFSET 1.2

RtPoint  center = {0.0, 6.0, 1.0},
        in = {0.0, -1.0, 0.0},
        up = {0.0, 0.0, 1.0};
RtFloat panewidth = 2.0,
        paneheight = 2.0,
        framewidth = 0.14,
        fuzz = 0.03;

ShowQuads()
{
    static RtColor blue = { 0.2, 0.4, 0.8};
    RtFloat disp;
    RtPoint hyperpt1, hyperpt2;

    RiColor(blue);
    RiRotate(-90.0, 1.0, 0.0, 0.0);

    RiTranslate(-OFFSET, 0.0, (OFFSET/2));
    RiDeclare("center", "uniform point");
    RiDeclare("in", "uniform point");
    RiDeclare("up", "uniform point");
    RiDeclare("panewidth", "uniform float");
    RiDeclare("paneheight", "uniform float");
    RiDeclare("framewidth", "uniform float");
    RiDeclare("fuzz", "uniform float");
    RiSurface("windowhighlight",
        (RtToken)"center", center, (RtToken)"in", in,
        (RtToken)"up", up,
        (RtToken)"panewidth", &panewidth,
        (RtToken)"paneheight", &paneheight,
        (RtToken)"framewidth", &framewidth,
        (RtToken)"fuzz", &fuzz,
        RI_NULL);
    RiSphere(0.5, -0.5, 0.5, 360.0, RI_NULL);   /* Declare a sphere  */
            
    RiTranslate(OFFSET, 0.0, 0.0);
    RiTranslate(0.0, 0.0, -0.5);

    RiSurface("blue_marble", RI_NULL);
    RiCone(1.0, 0.5, 360.0, RI_NULL);           /* Declare a cone    */

    RiTranslate(0.0, 0.0, 0.5);
    RiTranslate(OFFSET, 0.0, 0.0);
    RiSurface("easysurface", RI_NULL);
    RiCylinder(0.5, -0.5, 0.5, 360.0, RI_NULL); /* Declare cylinder  */

    RiTranslate(-OFFSET, 0.0, -OFFSET); 
    RiRotate(15.0, -1.0, 1.0, 1.0);
    RiRotate(15.0, 0.0, 0.0, 1.0);
    RiSurface("plastic", RI_NULL);
    disp = 0.15;
    RiAttribute("bound", "displacement", &disp, RI_NULL);
    RiDisplacement("round", RI_NULL);
    UnitCube();                       /* Declare rounded Cube */
  }

#define L -.5                /* For x: left side   */
#define R  .5                /* For x: right side  */
#define D -.5                /* For y: down side   */
#define U  .5                /* For y: upper side  */
#define F  .5                /* For z: far side    */
#define N -.5                /* For z: near side   */
/* UnitCube(): define a cube in the graphics environment */
UnitCube()
{
    static RtPoint Cube[6][4] = {
        { {L,D,F},{L,D,N},{R,D,F},{R,D,N} },    /* Bottom face */
        { {L,D,F},{L,U,F},{L,D,N},{L,U,N} },    /* Left face   */
        { {R,U,N},{L,U,N},{R,U,F},{L,U,F} },    /* Top  face   */
        { {R,U,N},{R,U,F},{R,D,N},{R,D,F} },    /* Right face  */
        { {R,D,F},{R,U,F},{L,D,F},{L,U,F} },    /* Far face    */
        { {L,U,N},{R,U,N},{L,D,N},{R,D,N} }     /* Near face   */
    };

    int i;
    for(i = 0; i < 6; i++)                      /* Declare the cube  */
        RiPatch(RI_BILINEAR, RI_P, (RtPointer) Cube[i], RI_NULL);
}

