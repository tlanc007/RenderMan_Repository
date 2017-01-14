/* Copyrighted Pixar 1989 */
/* To be used with listing6_2.c from the RenderMan Companion p.94 */

/* #define FILENAME if you want output to a file */
#define FILENAME "listing6_2.tiff"
#ifndef PICXRES
#define PICXRES 256     /* Horizontal output resolution */
#endif

#ifndef PICYRES 
#define PICYRES 192     /* Vertical output resolution   */
#endif

#define CROPMINX 0.0    /* RiCropWindow() parameters    */
#define CROPMAXX 1.0
#define CROPMINY 0.0
#define CROPMAXY 1.0

#define CAMXPOS -3.0    /* Camera position              */
#define CAMYPOS 2.0
#define CAMZPOS -6.0

#define CAMXDIR 0.0     /* Camera direction             */
#define CAMYDIR 0.0
#define CAMZDIR 0.0

#define CAMROLL 0.0     /* Camera roll                  */

#define CAMZOOM 7.0     /* Camera zoom rate             */
