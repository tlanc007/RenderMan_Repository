/* $Id: opt_10.c,v 1.1.1.1 2002/02/10 02:35:42 tal Exp $  (Pixar - RenderMan Division)  $Date: 2002/02/10 02:35:42 $ */
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
 * Example 10:	Patch Cracking
 */
static RtInt  bucketsize[2] = {24, 24};

void
SpecialSetup(void)
{
    RtInt  flag = 0, gridsize = 144;

    RiOption("limits", "gridsize", (RtPointer)&gridsize,
                       "bucketsize", (RtPointer)bucketsize, RI_NULL);
    RiAttribute("dice", "binary", (RtPointer)&flag, RI_NULL);
}
