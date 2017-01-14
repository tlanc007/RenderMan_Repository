/* Copyrighted Pixar 1989 */
/* To be used with listing6_3.c from the RenderMan Companion p.101 */

/* #define FILENAME if you want output to a file */
#define FILENAME "listing6_3.tiff"

#ifndef PICXRES
#define PICXRES 80     /* Horizontal output resolution */
#endif 

#ifndef PICYRES
#define PICYRES 200     /* Vertical output resolution   */
#endif 

#define CROPMINX 0.0    /* RiCropWindow() parameters    */
#define CROPMAXX 1.0
#define CROPMINY 0.0
#define CROPMAXY 1.0

#define CAMXPOS 0.0     /* Camera position              */
#define CAMYPOS 0.75
#define CAMZPOS -3.0

#define CAMXDIR 0.0     /* Camera direction             */
#define CAMYDIR 0.75
#define CAMZDIR 0.0

#define CAMROLL 0.0     /* Camera roll                  */

#define CAMZOOM 4.5     /* Camera zoom rate             */
