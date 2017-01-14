#########################################################################
#
# Makefile for texsrc directory of auxiliary materials
#
# _Advanced RenderMan: Creating CGI for Motion Picture_, 
# by Anthony A. Apodaca and Larry Gritz, Morgan Kaufmann, 1999.
#
# This file implements 'gnu make' rules to generate optimized texture
# for both PRMan and BMRT.
#
# The RenderMan (R) Interface Procedures and RIB Protocol are:
#     Copyright 1988, 1989, Pixar.  All rights reserved.
# RenderMan (R) is a registered trademark of Pixar.
#
#########################################################################


TEXTUREDIR=../texture
TIFFTEXTUREDIR=../tifftexture


TIFFS = mandrill.tif rmemboss.tif

# Comment out the following line if you don't use PRMan
TX += $(patsubst %.tif,$(TEXTUREDIR)/%.tx,$(TIFFS))

# Comment out the following line if you don't use BMRT
TX += $(patsubst %.tif,$(TIFFTEXTUREDIR)/%.tx,$(TIFFS)) 


# txmake rule
$(TEXTUREDIR)/%.tx: %.tif
	txmake $< $@ 

# mkmip rule
$(TIFFTEXTUREDIR)/%.tx: %.tif
	mkmip $< $@ 




all: $(TX)



# Special instructions for specific textures
