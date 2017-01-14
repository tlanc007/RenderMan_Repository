/************************************************************
 *   renamed PSbarnacle.sl for RMR -- tal 3/6/03
 * file: barnacle.sl
 * author: Peter Stuart
 * date: 11/3/2002
 * $Id: PSbarnacle.sl,v 1.1 2003/03/07 04:01:09 tal Exp $
 * description: Shader to produce a bunch of barnacles on a 
 * wood-like surface.
 *
 * ---- surface parameters ----------
 * max_height: height of barnacles. Adjust based on frequency.
 * ncones: number of bulges in barnacle.
 * spikiness: length of spikes on top ridge of barnacle
 * sfreq, tfreq: number of barnacles in s and t
 * sparse: control sparseness of barnacles across surface
 * variation: controls how sparseness parameter varies
 * seed: controls random attributes
 * Ka: ambient lighting attribute
 ************************************************************/

#include "rmannotes.sl"
#include "PSshapes.h"
#include "PSxforms.h"

/* ---- macro to help seed random numbers ------
 * it serves two purposes:
 *  - allows easy searching to ensure non-repeating numbers
 *  - automatically uses seed
 */
#define RN(x) (seed+(x)+0.5)

/* ---- function to create random transformation -----
 * scale_min, scale_max: range of scaling
 * rot_min, rot_max: range of rotation
 * seed: controls transformation
 * row, col: row and column of current tile
 * s, t: current position
 * ss, tt: returned position
 */
void rand_xform(float scale_min, scale_max;
		float rot_min, rot_max;
		float seed;
		float row, col, s, t; output float ss, tt;)
{
  float scale1 = udn2(col+RN(91224), row+RN(11224), scale_min, scale_max);
  float scale2 = udn2(col+RN(99191), row+RN(19191), scale_min, scale_max);
  xform(scale1, scale2,
	udn2(col+RN(52219), row+RN(42219), scale1/2-0.5, 0.5-scale1/2),
	udn2(col+RN(3287), row+RN(4287), scale2/2-0.5, 0.5-scale2/2),
	udn2(col+RN(69), row+RN(74), rot_min, rot_max),
	s, t, ss, tt);
}

/* ---- function to draw barnacle ------
 * ncones: number of bulges
 * spikiness: changes the height of the spikes
 * seed: controls random attributes
 * s, t: current position
 * opacity: returned mask
 * disp: returned displacement
 */
color draw_barnacle(uniform float ncones;
		    float spikiness;
		    float minrad, maxrad, fuzz;
		    float seed;
		    float s, t;
		    output color opacity;
		    output float disp;)
{
  uniform float period = 2*PI*ncones;

  color layer_opac, layer_color, surface_color;
  float layer_disp;
  float bot_rad, top_rad;
  float r, theta;
  float ss, tt;

  ss = xtranslate(0.5, s);
  tt = xtranslate(0.5, t);
  topolar2d(ss, tt, r, theta);


  surface_color = 0;
  layer_color = 0;
  layer_disp = 0;
  opacity = 0;
  disp = 0;

  /* repeat noise along theta to avoid breaks */
  bot_rad = maxrad +
    maxrad*abs(pnoise((theta*ncones/(2*PI)) + RN(98), 2*PI*ncones)*2 - 1);
  top_rad = minrad +
    minrad*abs(pnoise((theta*ncones/(2*PI)) + RN(100), 2*PI*ncones)*2 - 1);

  layer_opac = draw_cone(point(0.5,0.5,0), bot_rad, top_rad, fuzz, s, t);

  /********** displacement *******************/

  /* distort cone to look like several cones */
  disp = comp(layer_opac, 0) + comp(layer_opac, 0) *
    spikiness*abs(snoise((theta*ncones)/(2*PI) + RN(102)));

  /* ridges */
  disp += comp(layer_opac, 0) *
    0.5*abs(snoise(r*10/bot_rad + RN(106)));

  /* subtract out the middle, so it looks like mini volcano */
  disp *= 1-(draw_circle(point(0.5,0.5,0), minrad*2, fuzz, s, t));

  /* add critter mound */
  disp = max(disp, cos(clamp(r/maxrad*0.7*PI, 0, PI)));

  /* take out lip */
  disp -= minrad*(draw_line(point(0.5,0.5+minrad*2,0),
			    point(0.5,0.5-minrad*2,0),
			    fuzz, minrad/3, s, t));

  /*********** outside color *************************/  

  layer_color = color "hsv" (udn(RN(8007), 0.1, 0.2),
			     udn(RN(8009), 0.1, 0.3),
			     udn(RN(8011), 0.8, 1));
  layer_opac = draw_circle(point(0.5,0.5,0), bot_rad-fuzz, fuzz, s, t);
  surface_color = blend(surface_color, layer_color, layer_opac);

  opacity = layer_opac;

  /*********** inside color *************************/

  layer_color = color "hsv" (udn(RN(8014), 0.1, 0.2),
			     udn(RN(8017), 0.1, 0.3),
			     udn(RN(8019), 0.4, 0.6));
  layer_opac = 1-draw_circle(point(0.5,0.5,0), minrad*2, minrad*2, s, t);
  surface_color = blend(surface_color, layer_color, layer_opac);

  return surface_color;
}

surface PSbarnacle(float max_height=0.2, ncones=5, spikiness=0.5;
		 float sfreq=20, tfreq=10;
		 float sparse=1, variation=5;
		 float seed = 1299;
		 float Ka = 0.1;)
{
  color layer_opac, layer_color, surface_color;
  float layer_disp, surface_disp;
  color barn_opac, barn_color;
  float barn_disp;
  float ss, tt, xs, xt;
  float row, col, bomb;
  float true_row, true_col;
  float density;

  float barnrad1 = 0.5;
  float barnrad2 = 0.1;

  barn_color = 0;
  barn_disp = 0;
  barn_opac = 0;
  surface_disp = 0;
  surface_color = 0;

  /********* base **********************************/

  layer_color = Cs;
  layer_opac = float noise((t+snoise(s*40 + RN(44251)))*20 + RN(6672));

  normal Nf = faceforward (normalize(N),I);
  layer_color = layer_color * (Ka*ambient() + 0.5*diffuse(Nf))
    + 0.8*layer_opac*specular(Nf, -normalize(I), 0.05);

  surface_color = blend(surface_color, layer_color, layer_opac);

  /********** barnacles ****************************/

  true_col = whichtile(s, sfreq);
  true_row = whichtile(t, tfreq);

  /* take care of barnacle moving into other regions */
  float i, j;
  for (i=-1; i<=1; i+=1) {
    for (j=-1; j<=1; j+=1) {

      ss = repeat(s, sfreq) - i;
      tt = repeat(t, tfreq) - j;
      col = mod((true_col + i), sfreq);
      row = mod((true_row + j), tfreq);

      bomb = noise(col+RN(199209), row+RN(76721));

      ss += udn(bomb+RN(2981), -1.5, 1.5);
      tt += udn(bomb+RN(651511), -1.5, 1.5);

      /* barnacle density */
      density = 1-sparse * 
	smoothstep(0.25, 0.75, float noise(col*variation/sfreq,
					   row*variation/tfreq));

      if (noise(bomb+RN(2989101)) <= density) {

	rand_xform(0.7, 0.9, 0, 2*PI, seed, row, col, ss, tt, xs, xt);
	layer_color = draw_barnacle(ncones, spikiness,
				    barnrad2, barnrad1, 0.05,
				    (seed+RN(299287))*cellnoise(row, col),
				    xs, xt, layer_opac, layer_disp);
      
	barn_color = blend(barn_color, layer_color, layer_opac);
	barn_disp = max(max_height*layer_disp/max(sfreq, tfreq), barn_disp);
	barn_opac = union(layer_opac, barn_opac);
      }
    }
  }

  /* barnacle displacement */
  vector Nn = normalize(N);
  P += Nn * (barn_disp / length(vtransform("shader", Nn)));
  N = calculatenormal(P);

  /* barnacle lighting */
  Nf = faceforward (normalize(N),I);
  barn_color = barn_color * (Ka*ambient() + 0.8*diffuse(Nf))
    + 0.1*specular(Nf, -normalize(I), 0.5);
  surface_color = blend(surface_color, barn_color, barn_opac);

  Ci = surface_color;
}

