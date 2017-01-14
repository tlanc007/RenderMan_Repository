/* $Id: eyesplit.c,v 1.1.1.1 2002/02/10 02:35:42 tal Exp $  (Pixar - RenderMan Division)  $Date: 2002/02/10 02:35:42 $ */
/*
** Copyright (c) 1998 PIXAR.  All rights reserved.  This program or
** documentation contains proprietary confidential information and trade
** secrets of PIXAR.  Reverse engineering of object code is prohibited.
** Use of copyright notice is precautionary and does not imply publication.
**
**                      RESTRICTED RIGHTS NOTICE
**
** Use, duplication, or disclosure by the Government is subject to the
** following restrictions:  For civilian agencies, subparagraphs (a) through
** (d) of the Commercial Computer Software--Restricted Rights clause at
** 52.227-19 of the FAR; and, for units of the Department of Defense, DoD
** Supplement to the FAR, clause 52.227-7013 (c)(1)(ii), Rights in
** Technical Data and Computer Software.
**
** Pixar
** 1001 West Cutting Blvd.
** Richmond, CA  94804
*/
#include <stdio.h>
#include <ri.h>
#include "setup.h"

#define NSPIKES    10
#define DEPTH    200

static RtColor Color = { 1.0, 1.0, 0.0 };
static RtPoint From = {0.0, 0.0, 0.0};
static RtFloat patch[12] = {-1.0, 0.0, -30.0,  1.0, 0.0, -30.0,
                             0.0, 0.0, 0.0,  0.0, 0.0, 0.0};

/*
 * This generates a scene that has trouble splitting at camera plane.
 * Gives error messages if eyesplits < 8, but still renders okay.
 * Renders incompletely if eyesplits < 6.
 *
 */
int
main(void)
{
    int i;
    char string[64];
    char *name = string;

    RiBegin(RI_NULL);        /* Start the renderer */
	RiDisplay("RenderMan", RI_FRAMEBUFFER, "rgb", RI_NULL);
	RiFormat((RtInt) 256, (RtInt) 192, -1.0);
	RiShadingRate(1.0);
	RiProjection("perspective", RI_NULL);
        SpecialSetup();
        RiLightSource("pointlight", "from", (RtPointer)From, RI_NULL);
        RiTranslate(0.0, 0.0, 2.5);
        RiWorldBegin();
            RiSurface("matte", RI_NULL);
            RiColor(Color);        /* Declare the color */
            for (i=0; i<NSPIKES; i++) {
              RiAttributeBegin();
		sprintf(name, "Spike.%d", i);
		RiAttribute("identifier", "name", &name, RI_NULL);
                RiRotate(360.0*i/NSPIKES, 0.0, 0.0, 1.0);
                RiTranslate(0.0, 0.8, 0.4*i);
                RiPatch("bilinear", "P", (RtPointer)patch, RI_NULL);
              RiAttributeEnd();
            }
        RiWorldEnd();
    RiEnd();            /* Clean up after the renderer */

    return 0;
}
