/* $Id: opt_8.c,v 1.1.1.1 2002/02/10 02:35:42 tal Exp $  (Pixar - RenderMan Division)  $Date: 2002/02/10 02:35:42 $ */
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
#include <ri.h>
#include "setup.h"

/*
 * Set options and attributes that are specific to the example at hand.
 * Example 8:    Shadow Map With Good Bias Values
 */

static RtPoint From = {0.0, 0.0, 0.0}, To = {1.0, 0.0, 0.9};
static RtToken Zfile = "shad17.z",
               Shadow = "shad17.shd";
void
ShadowSetup(void)
{
    RiFormat( (RtInt) 128, (RtInt) 128, 1.0);
    RiScreenWindow(-1.0, 1.0, -1.0, 1.0);
    RiProjection("orthographic", RI_NULL);
    RiDisplay(Zfile, "zfile", "z", RI_NULL);
}

void
SpecialSetup(void)
{
    RtFloat NumSamples = 16.0, ResFactor = 2.0, Bias0 = 0.3, Bias1 = 0.4;

    RiMakeShadow(Zfile, Shadow, RI_NULL);
    RiPixelSamples(2.0, 2.0);
    RiScreenWindow(-1.3, -0.1, -0.45, 0.45);
    RiProjection("orthographic", RI_NULL);
    RiOption("shadow", "bias0", (RtPointer)&Bias0,
                       "bias1", (RtPointer)&Bias1, RI_NULL);
    RiDeclare("nsamples", "uniform float");
    RiDeclare("resfact", "uniform float");
    RiDeclare("shadname", "uniform string");
    RiLightSource("shadowlight", "nsamples", (RtPointer)&NumSamples,
                                 "resfact", (RtPointer)&ResFactor,
                                 "shadname", (RtPointer)&Shadow,
                                 "from", (RtPointer)From,
                                 "to", (RtPointer)To, RI_NULL);
}
