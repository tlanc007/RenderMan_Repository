/* Copyrighted Pixar 1989 */
/* From the RenderMan Companion p. 128 */ 
/* Listing 7.2  Generating solid partial spheres and cylinders */

/* SolidWedge(radius, zmin, zmax, thetamax): make a solid from a (partial)
 *      sphere as the intersection or union of two hemispheres. 
 */
SolidWedge(radius, zmin, zmax, thetamax)
float radius, zmin, zmax, thetamax;
{
    if (thetamax == 180.0) {
        SolidHemisphere(radius, zmin, zmax);
    } else if (thetamax == 360.0) {
        SolidSphere(radius, zmin, zmax);
    } else if (thetamax < 180.0) {
        RiSolidBegin(RI_INTERSECTION);
            SolidHemisphere(radius, zmin, zmax);
            RiRotate(thetamax-180.0, 0.0, 0.0, 1.0);
            SolidHemisphere(radius, zmin, zmax);
        RiSolidEnd();
    } else if (thetamax < 360.0) {
        RiSolidBegin(RI_UNION);
            SolidHemisphere(radius, zmin, zmax);
            RiRotate(thetamax, 0.0, 0.0, 1.0);
            SolidHemisphere(radius, zmin, zmax);
        RiSolidEnd();
    }
}

/* SolidHemisphere: create a solid hemisphere from a sphere and a cylinder*/
SolidHemisphere(radius, zmin, zmax)
float radius, zmin, zmax;
{
    RiSolidBegin(RI_INTERSECTION);
        SolidSphere(radius, zmin, zmax);
        /*
         * A cylinder is defined with the same radius as the sphere and
         * rotated so that its bottom bisects the sphere in the x/z plane.
         */
        RiRotate(90.0, 1.0, 0.0, 0.0); 
        /* Rotate the cylinder 90 degrees in x */
        SolidCylinder(radius, 0.0, radius);
    RiSolidEnd();                 /* intersection */
}

/* SolidSphere: create a closed sphere */
SolidSphere(radius, zmin, zmax)
RtFloat radius, zmin, zmax;
{
    RiSolidBegin(RI_PRIMITIVE);

        RiSphere(radius, zmin, zmax, 360.0, RI_NULL);

        if(fabs(zmax) < radius)        /* The top is chopped off       */
            RiDisk(zmax, sqrt(radius*radius - zmax*zmax), 360.0, RI_NULL);
        
        if(fabs(zmin) < radius)        /* The bottom is chopped off    */ 
            RiDisk(zmin, sqrt(radius*radius - zmin*zmin), 360.0, RI_NULL);
        
    RiSolidEnd();
}

    /*
     *  SolidCylinder() makes a solid cylinder of the given radius, extending
     *  from zmin to zmax along the z axis.
     */
SolidCylinder(radius, zmin, zmax)
float radius, zmin, zmax;
{
    RiSolidBegin(RI_PRIMITIVE);

        RiCylinder(radius, zmin, zmax, 360.0, RI_NULL);

        RiDisk(zmax, radius, 360.0, RI_NULL);       /* Close the top    */
        RiDisk(zmin, radius, 360.0, RI_NULL);       /* Close the bottom */

    RiSolidEnd(); 
}
