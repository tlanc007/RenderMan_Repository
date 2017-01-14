/* Copyrighted Pixar 1989 */
/* Used with the RenderMan Companion chapter 16 */

#include <ri.h>
#include <stdio.h>
#include <math.h>

#define TRUE 1
#define FALSE 0

typedef void (*atptr)();

void  lead(), wood(), paint(), paintedmetal(),
      rubber();
atptr leadattributes = lead,
      woodattributes = wood,
      shaftattributes = paint,
      ferruleattributes = paintedmetal,
      eraserattributes = rubber;

RtColor erasercolor = {.27, .081, .04};
RtColor ferrulecolor = {0, .125, 0};
RtColor shaftcolor = {0.56, 0.23, 0.0};
RtColor lettercolor = {0.0, 0.2, 0.0};
RtColor woodcolor = {.32, .13, .036};
RtColor leadcolor = {.1, .1, .1};

RtColor black = {0.0, 0.0, 0.0};

RtPoint poly1[4] = { 1.0, 0.0, 28.0,
                     0.5, 0.866, 28.0,
                     0.5, 0.866, 35.0,
                     1.0, 0.0, 35.0};
RtPoint poly2[4] = { 0.5, 0.8660, 28.0,
                    -0.5, 0.8660, 28.0,
                    -0.5, 0.8660, 35.0,
                     0.5, 0.8660, 35.0};
RtPoint poly3[4] = {-0.5, 0.8660, 28.0,
                    -1.0, 0.0, 28.0,
                    -1.0, 0.0, 35.0,
                    -0.5, 0.8660, 35.0};
RtPoint poly4[4] = {-1.0, 0.0, 28.0,
                    -0.5, -0.8660, 28.0,
                   -0.5, -0.8660, 35.0,
                   -1.0, 0.0, 35.0};
RtPoint poly5[4] = {-0.5, -0.8660, 28.0,
                     0.5, -0.8660, 28.0,
                     0.5, -0.8660, 35.0,
                    -0.5, -0.8660, 35.0};
RtPoint poly6[4] = { 0.5, -0.8660, 28.0,
                     1.0, 0.0, 28.0,
                     1.0, 0.0, 35.0,
                     0.5, -0.8660, 35.0};
RtPoint poly7[6] = { 1.0, 0.0, 28.0,
                     0.5, 0.8660, 28.0,
                    -0.5, 0.8660, 28.0,
                    -1.0, 0.0, 28.0,
                    -0.5, -0.8660, 28.0,
                    0.5, -0.8660, 28.0};
RtPoint poly8[6] = { 1.0, 0.0, 35.0,
                     0.5, 0.8660, 35.0,
                    -0.5, 0.8660, 35.0,
                    -1.0, 0.0, 35.0,
                    -0.5, -0.8660, 35.0,
                     0.5, -0.8660, 35.0};

RtPoint poly9[4] = { 1.0, 0.0, -0.2,
                     0.5, 0.866, -0.2,
                     0.5, 0.866, 28.0,
                     1.0, 0.0, 28.0};
RtPoint poly10[4] = { 0.5, 0.8660, -0.2,
                     -0.5, 0.8660, -0.2,
                     -0.5, 0.8660, 28.0,
                      0.5, 0.8660, 28.0};
RtPoint poly11[4] = {-0.5, 0.8660, -0.2,
                     -1.0, 0.0, -0.2,
                     -1.0, 0.0, 28.0,
                     -0.5, 0.8660, 28.0};
RtPoint poly12[4] = {-1.0, 0.0, -0.2,
                     -0.5, -0.8660, -0.2,
                     -0.5, -0.8660, 28.0,
                     -1.0, 0.0, 28.0};
RtPoint poly13[4] = { 0.5, -0.8660, -0.2,
                     -0.5, -0.8660, -0.2,
                     -0.5, -0.8660, 28.0,
                      0.5, -0.8660, 28.0};
RtPoint poly14[4] = { 0.5, -0.8660, -0.2,
                      1.0, 0.0, -0.2,
                      1.0, 0.0, 28.0,
                      0.5, -0.8660, 28.0};

RtFloat textcoords[] = {1.2, .11,  1.2, -.01,  -.2, -.01,  -.2, .11};

Go()
{
    RtInt       IntVal;
    RtFloat     FltVal;
    RtPoint     Pnt1, Pnt2;

    FltVal = 0.1;
    RiLightSource("ambientlight", "intensity", &FltVal, RI_NULL);
    FltVal = 0.9;
    Pnt1[0] = Pnt1[1] = Pnt1[2] = -50;
    Pnt2[0] = Pnt2[1] = 0; Pnt2[2] = 18;
    RiLightSource("distantlight", "from", Pnt1, "to", Pnt2,
                  "intensity", &FltVal, RI_NULL);
    FltVal = 0.3;
    Pnt1[0] = 0; Pnt1[1] = -50; Pnt1[2] = 18;
    RiLightSource("distantlight", "from", Pnt1, "to", Pnt2,
                  "intensity", &FltVal, RI_NULL);

    RiTranslate((RtFloat)0.0, (RtFloat)0.0, (RtFloat)18.0);
    RiRotate((RtFloat)135.0, (RtFloat)0.0, (RtFloat)1.0, (RtFloat)0.0);
    RiTranslate((RtFloat)0.0, (RtFloat)0.0, (RtFloat)-15.0);

    RiShadingRate(2.0);
    RiSurface("matte", RI_NULL);

    /* The visible lead. */
    RiSolidBegin("intersection");
    RiSolidBegin("primitive");
        RiAttributeBegin();
        (*leadattributes)(leadcolor);
        RiTransformBegin();
        RiTranslate(0.0, 0.0, 27.0);
        RiRotate(-1.0, 0.707, 0.707, 0.0);
        RiTranslate(0.0, 0.0, 4.0);
        RiCone(4.0, 0.57145, 360.0, RI_NULL);
        RiDisk(0.0, 0.57145, 360.0, RI_NULL);
        RiTransformEnd();
        RiAttributeEnd();
    RiSolidEnd();
    RiSolidBegin("primitive");
        RiAttributeBegin();
        (*leadattributes)(leadcolor);
        RiCylinder(0.2857, 27.0, 35.0, 360.0, RI_NULL);
        RiDisk(27.0, 0.2857, 360.0, RI_NULL);
        RiDisk(35.0, 0.2857, 360.0, RI_NULL);
        RiAttributeEnd();
    RiSolidEnd();
    RiSolidEnd();

    /* The sharpened End. */
    RiSolidBegin("difference");
    RiSolidBegin("intersection");
        RiSolidBegin("primitive");
        RiAttributeBegin();
        (*woodattributes)(woodcolor);
        RiTransformBegin();
        RiTranslate(0.0, 0.0, 27.0);
        RiRotate(-1.0, 0.707, 0.707, 0.0);
        RiCone(8.0, 1.1429, 360.0, RI_NULL);
        RiDisk(0.0, 1.1429, 360.0, RI_NULL);
        RiTransformEnd();
        RiAttributeEnd();
        RiSolidEnd();
        RiSolidBegin("primitive");
        RiAttributeBegin();
        (*shaftattributes)(shaftcolor);
        RiPolygon((RtInt)4, "P", poly1, RI_NULL);
        RiPolygon((RtInt)4, "P", poly2, RI_NULL);
        RiPolygon((RtInt)4, "P", poly3, RI_NULL);
        RiPolygon((RtInt)4, "P", poly4, RI_NULL);
        RiPolygon((RtInt)4, "P", poly5, RI_NULL);
        RiPolygon((RtInt)4, "P", poly6, RI_NULL);
        RiPolygon((RtInt)6, "P", poly7, RI_NULL);
        RiPolygon((RtInt)6, "P", poly8, RI_NULL);
        RiAttributeEnd();
        RiSolidEnd();
    RiSolidEnd();
    RiSolidBegin("primitive");
        RiAttributeBegin();
        (*leadattributes)(leadcolor);
        RiCylinder(0.2857, 27.0, 35.0, 360.0, RI_NULL);
        RiDisk(27.0, 0.2857, 360.0, RI_NULL);
        RiDisk(35.0, 0.2857, 360.0, RI_NULL);
        RiAttributeEnd();
    RiSolidEnd();
    RiSolidEnd();

    /* The shaft. */
    RiAttributeBegin();
    (*shaftattributes)(shaftcolor);
    RiPolygon((RtInt)4, "P", poly9, RI_NULL);
    RiPolygon((RtInt)4, "P", poly10, RI_NULL);
    RiPolygon((RtInt)4, "P", poly11, RI_NULL);
    RiPolygon((RtInt)4, "P", poly12, RI_NULL);

    RiAttributeBegin();
    RiShadingRate(1.0);
    RiDisplacement("emboss", RI_NULL);
    FltVal = 1.0;
    RiAttribute("bound", "displacement", &FltVal, RI_NULL);
    RiDeclare("green", "uniform color");
    RiDeclare("yellow", "uniform color");
    RiSurface("sdixon", "green", lettercolor, "yellow", shaftcolor, RI_NULL);
    RiPolygon((RtInt)4, "P", poly13, "st", textcoords, RI_NULL);
    RiAttributeEnd();
    RiPolygon((RtInt)4, "P", poly14, RI_NULL);
    RiAttributeEnd();

    /* The ferrule. */
    RiAttributeBegin();
    (*ferruleattributes)(ferrulecolor);
    RiDisplacement("dferrule", RI_NULL);
    FltVal = 1.0;
    RiAttribute("bound", "displacement", &FltVal, RI_NULL);
    RiCylinder(1.0, -4.0, 0.0, 360.0, RI_NULL);
    RiAttributeEnd();
    RiAttributeBegin();
    RiColor(black);
    RiDisk(-0.2, 1.0, 360.0, RI_NULL);
    RiDisk(-4.0, 1.0, 360.0, RI_NULL);
    RiAttributeEnd();

    /* The eraser. */
    RiAttributeBegin();
    (*eraserattributes)(erasercolor);
    RiCylinder(.95, -5.5, -4.0, 360.0, RI_NULL);
    RiTransformBegin();
    RiTranslate(0.0, 0.0, -5.5);
    RiTorus(0.75, 0.2, 0.0, 360.0, 360.0, RI_NULL);
    RiTransformEnd();
    RiDisk(-5.7, 0.75, 360.0, RI_NULL);
    RiAttributeEnd();

}

void lead(color)
    RtColor color;
{
    RtColor     graphite;

    RiSurface("metal", RI_NULL);
    graphite[0] = graphite[1] = graphite[2] = .1;
    RiColor(graphite);
}

void wood(color)
    RtColor color;
{
    RtFloat     d = 1.0;
    RtColor     brown;

    RiSurface("wood", RI_NULL);
}

void paint(color)
    RtColor color;
{
    RiShadingRate(8.0);
    RiColor(color);
}

void paintedmetal(color)
    RtColor color;
{
    RtFloat     s = 1.2;

#if 0
    RiSurface("sferrule", "Ks", &s, RI_NULL);
#else
	RiSurface ("shiny", "Ks", &s, RI_NULL); 
#endif
    RiColor(color);
}

void rubber(color)
    RtColor color;
{
    RiSurface("rubber", RI_NULL);
    RiColor(color);
}

