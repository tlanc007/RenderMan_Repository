/* Author Thomas Burge -- burge@apple.com */
/* Tal Lancaster tal@cs.caltech.edu -- fixed core dump problem and added
 * to RMR 10/24/98 
 */

#include <stdio.h>
#include <stdlib.h>
#include <ri.h>


typedef struct _DSO_PROCPRIM {
   RtInt    level;
   /* The min and max height values are items of data that could be used to
    *    convert the given patch into a bumpy height field, but for this example
    *    these values are just set but not used.
    */
   RtFloat  minheight;
   RtFloat  maxheight;
   RtFloat  x0, y0, z0;
   RtFloat  x1, y1, z1;
   RtFloat  x2, y2, z2;
   RtFloat  x3, y3, z3;
} DSO_PROCPRIM;
typedef DSO_PROCPRIM  *PDSO_PROCPRIM;


/*
 * Rename Free() to anything else and you get:
 *   R16002 Incomplete procedural primitive DSO (dlsym: Unable to locate \
 *          symbol Free
 * But rename the other two and you get:
 *   R16002 Incomplete procedural primitive DSO ((null))
 * Note that the HTML -- version 3.7 -- documentation is incorrect regarding the exported
 *   function it calls "Convert".  It appears that prman really wants
 *   the name "ConvertParameters" to be exported, not "Convert".  Using
 *   "Convert", you get the R16002 error shown above.  PRMan 3.7 only gives the more
 *   informative error for a missing Free(), not the other two functions if they are missing.
 */
RtVoid Subdivide( RtPointer data, RtFloat levelofdetail );
RtVoid  Free( RtPointer data );
RtPointer ConvertParameters( RtString initialstring );


RtVoid Subdivide( RtPointer data, RtFloat levelofdetail )
{
   if ( !data )
      return;

   /* For this example, we'll just write a patch and be done.
    *    Note that of course this is a rather elaborate way to
    *    write out only one patch.  You would normally do a
    *    bit more than this such as call children procedurals with
    *      RiProcedural(data,bound,Subdivide,Free);
    */
   printf("data:%p levelofdetail: %g\n", data, levelofdetail );
   /* The last parameter needs to be RI_NULL or may get a core dump */
   RiPatch( "bilinear", "P", &(((PDSO_PROCPRIM)data)->x0), RI_NULL );
}


RtVoid Free( RtPointer data )
{
   (void)data;
   printf("free:%p\n",data);
   free( data );
}

RtPointer ConvertParameters( RtString initialstring )
{
   PDSO_PROCPRIM  p;
   int  n;

   p = (PDSO_PROCPRIM)malloc( sizeof( DSO_PROCPRIM) );
   printf("malloc:%p\n",p);
   p->level = 0;
   n = sscanf( initialstring,
        "%g %g  %g %g %g %g %g %g %g %g %g %g %g %g \n",
        &(p->minheight), &(p->maxheight),
        &(p->x0), &(p->y0), &(p->z0),
        &(p->x1), &(p->y1), &(p->z1),
        &(p->x2), &(p->y2), &(p->z2),
        &(p->x3), &(p->y3), &(p->z3) );
   if ( n!=14 )
   {
      free( p );
      return NULL;
   }

   return p;
}
