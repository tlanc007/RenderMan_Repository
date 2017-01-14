/*  IDhair.sl written by Ivan DeWolf
 *  total abuse of technology
 *  feel free to copy, distribute, hack and/or abuse this code 
 *  in any way you see fit
 */

surface 
IDhair(	float spacing 		= .05; /*spacing between hairs*/
   	float endsoft 		=  1;  /*softness of the taper*/
   	float lengthfactor 	=  5;  /*counterintuitive hair length factor*/
){

   float DST = spacing;             /*distance between lines*/
   float param = mod(u, 1);         /*parameter*/
   float stretch =length(dPdu);     /*stretch factor*/
   float firstdist = abs(param-.5); /*distance to first line*/
   float firsthalver= 1;            /*keeps halving*/
   float nexthalver = 1;   /*halver value for the next line over*/
   float firstdir = (param-.5);     /*signed distance to first line*/
   float nextdir;                   /*            "      next line*/
   float bestdir;                   /*            "      best line*/
   float bestdist, nextdist = 1;    /*distance to the next line over*/
   float ender = clamp(endsoft, 0, 1) * DST; /*an intermediate variable*/
   float pinch = 1;                          /*pinches the line down when it's 
					       neighbors are too close*/
   float firstHconstant=.5;          /*per hair constant for the first line*/
   float nextHconstant;             /*per hair constant for the next line*/
   float bestHconstant;             /*per hair constant for the best line*/
   float dist,hairea,uniformrandom,downlength,trim;

         /*distance to hair, area for color shading, per hair random number,
           distance down the length of the hair, a trimmer to disconnect 
	   the tips from the roots*/

   float normaldisp, thickness;
   color grey = .1;
   normal NN = normalize(N);
   vector down = normalize(vtransform("world","current",vector (0,1,0)));
   float hang = 1-smoothstep(-.9,0.1,NN.down);

      /*compute the distance to the first line*/
      while(firstdist*stretch > DST){
	  firsthalver*= .5;
	  firstHconstant = firstHconstant + (firsthalver*.5*sign(firstdir));
	  firstdist = firstdist - firsthalver;
	  firstdir = firstdist;
	  firstdist = abs(firstdist);
     }

     nexthalver = firsthalver;
     nextdir = firstdir;
     nextHconstant = firstHconstant;

     /* compute the halver value for the next line over*/
     while((nexthalver*stretch) > DST*2){
	  nexthalver *= .5;
	  nextHconstant = nextHconstant + (nexthalver*.5*sign(nextdir));
	  nextdir = abs(nextdir) - nexthalver;
     }
 
      /*figure out which line is in fact closest*/
      nextdist = nexthalver - firstdist;
      bestdist = firstdist;
      bestdir = firstdir;
      bestHconstant = firstHconstant;
      if (nextdist<bestdist){
	  bestdist = nextdist;
	  bestdir = nextdir;
          bestHconstant = nextHconstant;
      }

     /*determine pinch*/
     if (nexthalver * stretch < DST + ender ){
	  if(bestdist != firstdist || nexthalver == firsthalver){
	      pinch = ((nexthalver*stretch) - DST)/ender;
	  }
     }
     pinch = pow(smoothstep(0,.5,pinch),.5);

     uniformrandom = cellnoise(bestHconstant*1000);
     downlength = mod((v+uniformrandom)*lengthfactor,1);
     trim =  1-smoothstep(0.4,.45,abs(downlength-.5));
     dist = 1-((1-(bestdist/DST*stretch))*pinch*trim);
     hairea = 1-smoothstep(0.1,.5,dist);
     thickness = (1-(2*clamp(dist,0,.5)))*.1;
     normaldisp = thickness + (downlength * .5);


  /*displace*/
  P += NN * normaldisp *.5;
  P += down*hang*-.5*downlength;

  /*some fancy coloration*/
  Ci = color cellnoise(bestHconstant*1000)*hairea*downlength*.5;
  Ci = mix(Ci,grey,.5);

  Oi = 1-smoothstep(0.3,.31,dist);
  Ci *= Oi;   /*often a good last line*/
}




























