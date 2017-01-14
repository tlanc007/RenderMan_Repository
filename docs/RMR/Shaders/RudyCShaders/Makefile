## Tal Lancaster for RMR  11/23/03
##
##Makefile for building shaders from the RenderMan Repository 
##  (www.renderman.org/RMR).  It assumes you have downloaded the
##  necessary library files and makes relative path assumptions.
##  If you want a different structure than you may need to adjust
##  these first set of Make variables

##  May need to edit these first few variables to match up with your setup
#TOP_SHADERS_DIR = ..
TOP_SHADERS_DIR = /RMR/shaders

SHADER_LIBS = -I. -I$(TOP_SHADERS_DIR)/arman

#PRMan shader compiler
SHADER = shader
#BMRT shader compiler
SLC = slc

#PRMAN renderer
RENDER = render
###
INCLUDES = rclocillum.h

.SUFFIXES: .sl .slo .slc

#SHADERS = *.sl
SHADERS = RudyCconcretestripes_d.sl RudyCstripeCeramic.sl \
	RudyCtile02.sl \
	RudyCplasmaball.sl RudyCtile01.sl


SLOFILES =  $(SHADERS:.sl=.slo)
SLCFILES =  $(SHADERS:.sl=.slc)

TIFFS = $(SHADERS:.sl=.tif)

#all: $(SLOFILES) $(SLCFILES)
all: $(SLOFILES)

#slo: $(SLOFILES)       #gmake slo  ;will only make prman shaders
#slc: $(SLCFILES)       #gmake slc  ;will only make bmrt shaders

tiffs: $(SLOFILES) $(TIFFS)

#Note: currently no build dependencies on the library files.
#It is assumed that they won't be changing.  But if they do, then the fact
#that they change won't trigger a rebuild of the dependent shaders.

RudyCstripeceramic.slo: RudyCstripeceramic.sl  rclocillum.h
	$(SHADER) $(SHADER_LIBS) $<

RudyCstripeceramic.slc: RudyCstripeceramic.sl rclocillum.h
	$(SLC) $(SHADER_INC) $<

%.slo : %.sl
	$(SHADER) $(SHADER_LIBS) $<

%.slc : %.sl
	$(SLC) $(SHADER_LIBS) $<

%.tif : %.rib
	$(RENDER) $<

clean:
	rm *.slo *.slc

spotless: clean
	rm *~


