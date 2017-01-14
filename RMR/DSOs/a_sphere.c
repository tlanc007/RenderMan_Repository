/* Code from prman AppNote#23 for DSOs */

#include <stdlib.h>
#include <malloc.h>
#include <ri.h>

#ifdef __cplusplus
extern "C" RtPointer ConvertParameters(RtString paramstr);
extern "C" RtVoid Subdivide(RtPointer data, RtFloat detail);
extern "C" RtVoid Free(RtPointer data);
#endif

RtPointer
ConvertParameters(RtString paramstr)
{
  RtFloat *radius_p;

  /* convert the string to a float */
  radius_p = (RtFloat *)malloc(sizeof(RtFloat));
  *radius_p = atof(paramstr);
  
  /* return the blind data pointer */
  return (RtPointer)radius_p;
}

RtVoid
Subdivide(RtPointer data, RtFloat detail)
{
  RtFloat *radius_p = (RtFloat *)data;
  
  /* output a sphere with the given radius */
  RiSphere( *radius_p, -*radius_p, *radius_p, 360.0, RI_NULL );
}

RtVoid
Free(RtPointer data)
{
  free(data);
}
