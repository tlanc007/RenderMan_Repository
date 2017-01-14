/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p. 270 */

#include <ri.h>
#include <stdio.h>

/* Listing 12.5  Function for creating and using a shadow map */
/*               for a light source   */
/* Create and use a shadow map for a spot light. */
main()
{
  char *shadowfile = "shadfile";
  RtFloat fov = 10;
  RtFloat bias0 = .1;
  RtFloat bias1 = .1;
  RtToken RI_KS;
  RtFloat Ks;
  RtFloat intensity;

  RiBegin(RI_NULL);

    RiFormat((RtInt) 512, (RtInt) 512, 1.0);
    RiFrameBegin( (RtInt) 1);
        RiDisplay("shdw.z", "zfile", RI_Z, RI_NULL);
		RiProjection ("orthographic", RI_NULL);
        SetupInv();
        RiWorldBegin();
            DoScene();
        RiWorldEnd();
    RiFrameEnd();

    RiMakeShadow("shdw.z", "shadfile", RI_NULL);

    RiFormat((RtInt) 400, (RtInt) 300, -1.0);
	RiOption ("shadow", "bias0", &bias0, RI_NULL);
	RiOption ("shadow", "bias1", &bias1, RI_NULL);
    RiShadingRate(1.0);
    RiDeclare("shadowfile", "uniform string");
    RiFrameBegin( (RtInt) 2);
	RiDisplay("listing12_5.tiff", RI_FILE, RI_RGB, RI_NULL);
	/* RiDisplay("listing12_5.tiff", RI_FILE, RI_RGBA, RI_NULL); */
		RiProjection ("perspective", RI_FOV, &fov, RI_NULL);
        View();
        RiWorldBegin();
            intensity = 0.2;
            RiLightSource("ambientlight", "intensity", &intensity, RI_NULL);
            RiTransformBegin();
                Setup();
                RiLightSource("shadowspot", 
                    (RtToken)"shadowfile", (RtPointer)&shadowfile,
                    RI_NULL);
            RiTransformEnd();
            RI_KS = RiDeclare("Ks", "uniform float");
            Ks = 0.1;
            RiSurface("plastic", RI_KS, &Ks, RI_NULL);
            DoScene();
        RiWorldEnd();
    RiFrameEnd();

  RiEnd();

  return 0;
}

SetupInv()
{
    RiTranslate(0.0, 0.0, 4.5);
    RiRotate(30.0, 0.0, 1.0, 0.0);
    RiRotate(-30.0, 1.0, 0.0, 0.0);
}

Setup()
{
    RiRotate(30.0, 1.0, 0.0, 0.0);
    RiRotate(-30.0, 0.0, 1.0, 0.0);
    RiTranslate(0.0, 0.0, -4.5);
}

DoScene()
{
    ColorCube(3, .5);            /* Define the cube */
}

View()
{
    RiTranslate(0.0, 0.0, 9.5);
    RiRotate(-30.0, 0.0, 1.0, 0.0);
    RiRotate(-15.0, 1.0, 0.0, 0.0);
}
