#ifdef RCSIDS
static char rcsid[] = "$Id: clamptoalpha.sl,v 1.1.1.1 2002/02/10 02:35:49 tal Exp $";
#endif

/*
 * $RCSfile: clamptoalpha.sl,v $
 * $Revision: 1.1.1.1 $
 * $Date: 2002/02/10 02:35:49 $
 *
 * $Log: clamptoalpha.sl,v $
 * Revision 1.1.1.1  2002/02/10 02:35:49  tal
 * RenderMan Repository
 *
 * Revision 1.1  1995-12-05 15:05:47-08  lg
 * Initial revision
 *
 */

imager
clamptoalpha ()
{
  Ci = clamp (Ci, color(0,0,0), color(alpha,alpha,alpha));
}
