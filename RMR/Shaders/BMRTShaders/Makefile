# Blue Moon Rendering Tools implementation of the RenderMan standard
# Makefile for the example shaders and scenes
#
# Blue Moon Rendering Tools, version 2.3
# (c) Copyright 1990-1997 by Larry I. Gritz.  All rights reserved.
#
#       The RenderMan (R) Interface Procedures and RIB Protocol are:
#           Copyright 1988, 1989, Pixar.  All rights reserved.
#       RenderMan (R) is a registered trademark of Pixar.
#


BMRTROOT = ..
include ../Make-config


# The rule for compiling shading language programs
.SUFFIXES: .slc .so .sl
.sl.slc:
	$(SLC) $*.sl
SLC= $(BINAREA)/slc
RENDER= $(BINAREA)/rendrib


SHADERS = background.sl brick.sl brickbump.sl castucco.sl \
	clamptoalpha.sl dented.sl funkyglass.sl glass.sl \
	gmarbtile_polish.sl noisysmoke.sl \
	screen.sl screen_aa.sl shiny.sl stucco.sl superplank.sl \
	wallpaper_2stripe.sl windowlight.sl wood2.sl

COMPILED_SHADERS = $(SHADERS:.sl=.slc)

RIBS = cornell.rib disptest.rib dresser.rib limbo.rib shadtest.rib \
	smokebox.rib teapots.rib texbox1.rib tpdisp.rib

SRC = $(SHADERS) $(RIBS) README 


all: $(COMPILED_SHADERS)


times:
	time $(RENDER) shadtest.rib
	time $(RENDER) disptest.rib
	time $(RENDER) cornell.rib
	time $(RENDER) texbox1.rib
	time $(RENDER) tpdisp.rib
	time $(RENDER) teapots.rib
	time $(RENDER) smokebox.rib
	time $(RENDER) dresser.rib


clean::
	@- rm *~ *.tif *.so *.slc
