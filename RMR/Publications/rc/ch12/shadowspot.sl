light
shadowspot( 
    float intensity = 1;
    color lightcolor = 1;
    string shadowfile = "shadowfile";
)
{
    illuminate(P) {
        Cl = intensity * lightcolor;
        Cl *= 1 - shadow(shadowfile, Ps);
    }
}
