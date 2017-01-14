#!/usr/bin/env python

import os, sys
import matplotlib
from pylab import *
from math import *

def s(n, w):
    step = 1.0/n
    if n & 1:
        return arange(ceil(-w*n/2.0)/n, w/2.0 + step/2.0, step)
    else:
        return arange(-w/2.0 + step/2.0, w/2.0, step)

def mitchell(x, B=0.3333333):
    C = (1-B)/2
    x = abs(x)
    if x < 1: return ((12-9*B-6*C) * x**3 + (-18+12*B+6*C) * x**2 + (6-2*B)) / 6
    elif x < 2: return ((-B-6*C)*x**3 + (6*B+30*C)*x**2 + (-12*B-48*C)*x + (8*B+24*C)) / 6
    return 0

def catrom(x, w): return mitchell(x, 0.0)

def box(x, w):
    return 1.0

def gaussian(x, w):
    x *= 2.0/w
    return exp(-2*x**2)

def fig(name, f, w, showlabel=0):
    kx = arange(-w/2.0, w/2.0 + .01, .05)
    ky = amap(lambda x: f(x,w), kx)
    ky /= sum(ky) * w/len(ky)
    for i in range(1,7):
        global fnum
        subplot(nfigs,6,fnum); fnum += 1
        x = s(i, w)
        y = amap(lambda x: f(x,w), x)
        y /= sum(y)
        x2 = array(0.0); x2.resize(len(x)+4);
        x2[2:-2] = x
        x2[0] = -w; x2[-1] = w; x2[1] = x2[2]; x2[-2] = x2[-3]
        y2 = array(0.0); y2.resize(len(x2))
        y2[2:-2] = y
        plot(x, y, 'b.')
        plot(x2, y2, 'b')
        plot(kx, ky / i, 'r--')
        axis([-w/2.0-.5, w/2.0+.5, -.3/i, 1.3 / i])
        xticks(arange(-w/2.0,w/2.0 + .5,1))
        yticks([0.0, 1.0 / i], ['0', i > 1 and '1/%d'%i or '1'])
        if showlabel:
            title('PixelSamples=%d'%i, fontsize='smaller')
        if i == 1: ylabel('%s %.1f' % (name, w))


figure(1, (12, 6))
fnum = 1
nfigs = 3
fig('gaussian', gaussian, 2.0, showlabel=1)
fig('catmull-rom', catrom, 2.0)
fig('catmull-rom', catrom, 4.0)
subplots_adjust(left=.05, right=.95, wspace = .3)
savefig('pixel_samples.png', dpi=100)
