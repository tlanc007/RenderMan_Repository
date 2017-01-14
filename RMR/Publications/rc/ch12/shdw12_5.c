#include <ri.h>

/* Listing 12.5  Function for creating and using a shadow map */
/*               for a light source   */
/* Create and use a shadow map for a spot light. */
main()
{
  char *shadowfile = "shadfile";
  RtToken RI_KS;
  RtFloat Ks;
  RtFloat intensity;

  RiBegin(RI_NULL);

    RiFormat((RtInt) 128, (RtInt) 128, 1.0);
    RiFrameBegin( (RtInt) 1);
        RiDisplay("shdw.z", "zfile", RI_Z, RI_NULL);
        SetupInv();
        RiWorldBegin();
            DoScene();
        RiWorldEnd();
    RiFrameEnd();

    RiMakeShadow("shdw.z", "shadfile", RI_NULL);

    RiFormat((RtInt) 256, (RtInt) 192, -1.0);
    RiShadingRate(1.0);
    RiDeclare("shadowfile", "uniform string");
    RiFrameBegin( (RtInt) 2);
	RiDisplay("shdw12_5.tiff", RI_FILE, RI_RGBA, RI_NULL);
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
