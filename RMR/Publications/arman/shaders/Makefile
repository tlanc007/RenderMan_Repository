#########################################################################
#
# Makefile for shaders directory of auxiliary materials for:
#
# _Advanced RenderMan: Creating CGI for Motion Picture_, 
# by Anthony A. Apodaca and Larry Gritz, Morgan Kaufmann, 1999.
#
# This file implements 'gnu make' rules to generate compiled shaders
# for both PRMan and BMRT.
#
# The RenderMan (R) Interface Procedures and RIB Protocol are:
#     Copyright 1988, 1989, Pixar.  All rights reserved.
# RenderMan (R) is a registered trademark of Pixar.
#
#########################################################################

SLC= slc
SHADER= shader
# Note for rayserver users: you may need to add -I to the previous line
# to correctly point to your rayserver.so file.
# If you're not interested in the ray server, then comment out the
# places in the shaders that say: #include "rayserver.h"

#Use this if you want to use BMRT and PRMan together in rayserver mode
#SHADER_INCLUDE = -DWANT_RAYSERVER
SHADER_INCLUDE =

# The rule for compiling shading language programs
.SUFFIXES: .sl .slo .slc

.sl.slc:
	$(SLC) $(SHADER_INCLUDE) $*.sl
.sl.slo:
	$(SHADER) $(SHADER_INCLUDE) $*.sl



CHAP_8_SHADERS  = simpletexmap.sl supertexmap.sl emboss.sl lumpy.sl
CHAP_9_SHADERS  = shiny.sl shinyplastic.sl shadowspot.sl clay.sl \
		  brushedmetal.sl 
CHAP_12_SHADERS = ceramictiles.sl oak.sl oakplank.sl smoke.sl \
		  lensflare.sl cel.sl starball.sl
CHAP_14_SHADERS = uberlight.sl
CHAP_15_SHADERS = gcloud.sl texdust.sl shadowedclouds.sl cellclouds.sl \
		  hypertexture.sl
CHAP_16_SHADERS = panorama.sl areacam.sl woodblockprint.sl nizid.sl
CHAP_17_SHADERS = glass.sl
TM_SHADERS      = planetatmo.sl planetclouds.sl platlight.sl \
		  starfield.sl terran.sl

SHADERS = $(CHAP_8_SHADERS) $(CHAP_9_SHADERS) $(CHAP_12_SHADERS) \
	  $(CHAP_14_SHADERS) $(CHAP_15_SHADERS) $(CHAP_16_SHADERS) \
	  $(CHAP_17_SHADERS) $(TM_SHADERS)

# Comment out the following line if you don't use PRMan
COMPILED_SHADERS += $(SHADERS:.sl=.slo)

# Comment out the following line if you don't use BMRT
COMPILED_SHADERS += $(SHADERS:.sl=.slc)

#   If you use BMRT 2.5 or later and want to truly compile your shaders
#   to be DSO's, try uncommenting (removing the #) the following 5 lines:
#ARCH=$(shell $(SLC) -arch)
#.SUFFIXES: .$(ARCH).slc
#.sl.$(ARCH).slc:
#	$(SLC) -dso $*.sl
#COMPILED_SHADERS += $(SHADERS:.sl=.$(ARCH).slc)


SRC = $(SHADERS) 


all: $(COMPILED_SHADERS)



clean::
	@- rm *~ *.slc *.slo
