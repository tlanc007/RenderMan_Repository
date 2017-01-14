/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p. 266 and 267 */

/* Listing 12.3  Function for creating environment maps for an object  */
/*               in a scene   */

/* MakeRefl.c: create and use an environment map at a given viewpoint. */

#include <stdio.h>
#include <ri.h>
#define BUFSIZE 256
RtPoint CameraFrom;
char filename[BUFSIZE];
#define PICXRES 256
#define PICYRES 192

main()
{
    RtFloat fov;
    RtInt resolution;
    char tfilenames[6][BUFSIZE+4];

    GetCubeParms(CameraFrom, filename, &resolution);
    RiBegin(RI_NULL);                     /* As always */

        RiDeclare("mapname", "uniform string");
	RiShadingRate(1.0);
        /* Render the faces of the cube */
        Snap("x+", tfilenames[0], resolution);
        Snap("x-", tfilenames[1], resolution);
        Snap("y+", tfilenames[2], resolution);
        Snap("y-", tfilenames[3], resolution);
        Snap("z+", tfilenames[4], resolution);
        Snap("z-", tfilenames[5], resolution);
        RiMakeCubeFaceEnvironment(
            tfilenames[0], tfilenames[1],
            tfilenames[2], tfilenames[3],
            tfilenames[4], tfilenames[5], 
            filename, 90.0, RiGaussianFilter, 2.0, 2.0, RI_NULL);
	RiFormat((RtInt) PICXRES, (RtInt) PICYRES, -1.0);
        RiFrameBegin( (RtInt) 7);
	RiDisplay("envr12_3.tiff", RI_FILE, RI_RGB, RI_NULL);
            fov = 25.0;
            RiProjection("perspective", RI_FOV, &fov, RI_NULL);
            RiRotate(24.0948, 1.0, 0.0, 0.0);
            RiRotate(-26.5651, 0.0, 1.0, 0.0);
            RiTranslate(2.5, 2.5, 5.0);
            RiWorldBegin();
                Go(filename);
            RiWorldEnd();
        RiFrameEnd();
    RiEnd();

    return 0;
}

GetCubeParms(EnvCenter, filename, resolution)
RtPoint EnvCenter;
char *filename;
RtInt *resolution;
{
    EnvCenter[0] = 0.0; EnvCenter[1] = 0.0; EnvCenter[2] = 0.0;
    strcpy(filename, "env");
    *resolution = 64;
}

Snap(direction, tfilename, resolution)
char *direction, *tfilename;
RtInt resolution;
{
    int axis;
    static int framenum = 1;
    RtPoint CameraTo;

    sprintf(tfilename, "%s.%c%c", filename, direction[0],
					(direction[1]=='-')? 'm':'p');
    
    RiFrameBegin( (RtInt) framenum++);

        RiDisplay(tfilename, RI_FILE, RI_RGB, RI_NULL);      
        RiFormat(resolution, resolution, 1.0);        /* image resolution */
        /* Nature of the projection to the image plane */
        RiProjection("perspective", RI_NULL);         /* perspective view */

        /* Camera characteristics */
        FrameCamera(resolution/2.0, (float)resolution, (float)resolution);
    
        /* Camera position and orientation */
        CameraTo[0] = CameraFrom[0];
        CameraTo[1] = CameraFrom[1];
        CameraTo[2] = CameraFrom[2];
        switch(direction[0]) {
        case 'x': axis = 0; break;
        case 'y': axis = 1; break;
        case 'z': axis = 2; break;
        }
        CameraTo[axis] += (direction[1]=='-') ? -1 : 1;
        PlaceCamera(CameraFrom, CameraTo, 0.0);

        /* Now describe the world */
        RiWorldBegin();
            Go(NULL);
        RiWorldEnd();
    RiFrameEnd();
}

/* =====================================================================*/

/* Listing 12.4  Function for using an environment map  in a scene */
/* 
 * Object description function for creating and using a reflection 
 *    map on a sphere. If mapname is non-NULL, the function 
 *    assumes it to be the name of a reflection map. Otherwise,
 *    the function ignores the object and simply declares the rest 
 *    of the world.
 */
/* =====================================================================*/

Go(mapname) 
char *mapname;
{ 
    RtFloat intensity;
    RtPoint from;

    intensity = 0.05;
    RiLightSource("ambientlight", RI_INTENSITY, &intensity, RI_NULL);
    intensity = 40.0;
    from[0] = -4.0; from[1] = -5.0; from[2] = -7.0;
    RiLightSource("pointlight", 
                   RI_INTENSITY, &intensity,
                   RI_FROM, from, RI_NULL);
    intensity = 40.0;
    from[0] = 3.5; from[1] = 6.5; from[2] = -6.0;
    RiLightSource("pointlight", 
                   RI_INTENSITY, &intensity,
                   RI_FROM, from, RI_NULL);
    intensity = 10.0;
    from[0] = 4.0; from[1] = 7.0; from[2] = 6.0;
    RiLightSource("pointlight", 
                   RI_INTENSITY, &intensity,
                   RI_FROM, from, RI_NULL);

    if(mapname != NULL) {
        RiAttributeBegin();
              RiSurface("shiny", 
                        (RtToken) "mapname", (RtPointer) &mapname,
                        RI_NULL);
              RiTranslate(CameraFrom[0],CameraFrom[1],CameraFrom[2]);
              RiSphere(1.0, -1.0, 1.0, 360.0, RI_NULL);
        RiAttributeEnd();
    }
    ShowRestOfWorld();
}

/* =====================================================================*/

#define L -.5                /* For x: left side   */
#define R  .5                /* For x: right side  */
#define D -.5                /* For y: down side   */
#define U  .5                /* For y: upper side  */
#define F  .5                /* For z: far side    */
#define N -.5                /* For z: near side   */

ShowRestOfWorld()
{
    static RtPoint Cube[6][4] = {
        { {L,D,F},{R,D,F},{R,D,N},{L,D,N} },    /* Bottom face  */
        { {L,D,F},{L,D,N},{L,U,N},{L,U,F} },    /* Left face    */
        { {R,U,N},{R,U,F},{L,U,F},{L,U,N} },    /* Top  face    */
        { {R,U,N},{R,D,N},{R,D,F},{R,U,F} },    /* Right face   */
        { {R,D,F},{L,D,F},{L,U,F},{R,U,F} },    /* Far face     */
        { {L,U,N},{L,D,N},{R,D,N},{R,U,N} }     /* Near face    */
    };

    static RtColor red = {1.0, 0.0, 0.0};
    static RtColor blue = {0.0, 1.0, 0.0};
    static RtColor green = {0.0, 0.0, 1.0};
    static RtColor purple = {1.0, 0.0, 1.0};
    static RtColor yellow = {1.0, 1.0, 0.0};
    static RtColor grey = {0.6, 0.6, 0.6};

    RiSurface("plastic", RI_NULL);
    RiTransformBegin();
        RiScale(20.0, 20.0, 20.0);
        RiColor(red);
        RiPolygon( (RtInt) 4, RI_P, (RtPointer) Cube[0], RI_NULL);    
        RiColor(green);
        RiPolygon( (RtInt) 4, RI_P, (RtPointer) Cube[1], RI_NULL);    
        RiColor(blue);
        RiPolygon( (RtInt) 4, RI_P, (RtPointer) Cube[2], RI_NULL);    
        RiColor(purple);
        RiPolygon( (RtInt) 4, RI_P, (RtPointer) Cube[3], RI_NULL);    
        RiColor(yellow);
        RiPolygon( (RtInt) 4, RI_P, (RtPointer) Cube[4], RI_NULL);    
        RiColor(grey);
        RiPolygon( (RtInt) 4, RI_P, (RtPointer) Cube[5], RI_NULL);    
    RiTransformEnd();
}
