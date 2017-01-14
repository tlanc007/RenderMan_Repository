/* shader for putting a texture map on a surface */

surface
mytexture(string tmap = "grid.txt"; float Kd=.8, Ka=.2)
{
    float txt, diffuse, kd;

    diffuse = I . N ;
    if (diffuse  < 0) 
        kd = Kd * .3;
    else
        kd = Kd;
    diffuse = (diffuse * diffuse) / (I.I * N.N) ;

    txt = texture ( tmap, s, t) ;
    Ci = (Ka + kd * diffuse ) * txt;
    Ci = Cs * txt;
    Oi = Os;
}
