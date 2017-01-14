/*
 * MRmand.sl -- Mandelbrot texture
 *
 * DESCRIPTION:
 * Creates a Mandelbrot set as a texture
 *
 * PARAMETERS:
 * Ka, Kd, Ks, roughness - the usual
 *
 * HINTS:
 *
 * AUTHOR: Michael Rivero
 * rivero AT squareusa DOT com 
 *
 * History:
 * Created: 12/18/98
 */


surface MRmand (
 float Kd = .5,
       Ka = .1;
 float maxiteration = 500;
 float useUV = 0.0;
)
{
 float lt;
 float ls;

/* Map the U and V values to the bounds of the Mandelbrot set. */

 if(useUV != 0.0)
 {
  lt = v;
  ls = u;
/* printf("lt = %f  ls = %f\n",lt,ls); */
 }
 else
 {
  lt = t;
  ls = s;
/* printf("lt = %f  ls = %f  pre correction   ",lt,ls); */
  ls = mod(ls, 1.0);
  lt = mod(lt, 1.0);
/* printf("lt = %f  ls = %f post correction \n",lt,ls);  */
 }



 float real = ( ls * 3.0 ) - 2.0;
 float imag = ( lt * 3.0 ) - 1.5;
 float tmpval;
 float got_away = 0, iter;
 float tempreal, tempimag, Creal, Cimag;
 float r2;
   Creal = real;
 Cimag = imag;
 color whitecolor = color (1, 1, 1);
 color blackcolor = color (0, 0, 0);


 for (iter=0; iter<maxiteration && got_away == 0; iter+=1)
 {
         /* z = z^2 + c */
     tempreal = real;
  tempimag = imag;
         real = (tempreal * tempreal) -  (tempimag * tempimag);
         imag = 2 * tempreal * tempimag;
         real += Creal;
         imag += Cimag;
  r2 = (real*real) + (imag*imag);
  if(r2 >= 4) got_away = 1;
 }

 Oi = Os;

 if ( iter >= maxiteration )
 {
   Ci = blackcolor;
 }
 else
 {
  tmpval = mod((iter / 10), 1.0);
  Ci = (tmpval, tmpval, tmpval);

 }
}
