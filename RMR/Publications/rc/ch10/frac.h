/* Copyrighted Pixar 1989 */
/* Used with listing10_3.c from the RenderMan Companion p.204 */


typedef struct fractalpoint { 
    RtPoint location;
    int seed;
} FractalPoint;

typedef struct fractaltriangle {
    FractalPoint vertices[3];
    struct fractaltriangle *children;
    int level;
} FractalTriangle;
