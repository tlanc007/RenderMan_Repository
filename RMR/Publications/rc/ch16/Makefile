#
#       Makefile for PhotoRealistic RenderMan Tutorial Chapter 16
#
#RMAN_LIB -- Give RenderMan library
#RMAN_LIB=  /caltech/Local/usr/lib/libribout.a
RMAN_LIB=

#RIDIR -- Include directory where ri.h is located
#RIDIR=-I/caltech/Local/usr/include
RIDIR=

#RUN_RMAN -- Render, ie. prman, rendrib
#RUN_RMAN=prman
RUN_RMAN=

#SHADER -- Shader compiler (prman (shader) rendrib (slc)
#SHADER=shader
SHADER=

#SHADER_EXT-- the extenstion that the shader produces (shader (slo) slc (so))
#SHADER_EXT=slo
SHADER_EXT=

#OTHER_LIBS -- Any other libraries needed at link time
#OTHER_LIBS=-lg++ -lm
OTHER_LIBS=

#CC -- Compiler
#CC= cc
CC = cc

CFLAGS =  -I. $(RIDIR) -DHEADER=\"../ch16/$*.h\"

## Shouldn't be any need to change anything below here
LIBS = $(RMAN_LIB) $(OTHER_LIBS)

.SUFFIXES: .tiff .rib .gen .o .c .$(SHADER_EXT) .sl
VIEWFILES= ../misc/main.c ../misc/placecam.o ../misc/framecam.o

SRC= quads_a.c quads_b.c quads_c.c pins_a.c pins_b.c pins_c.c pins_d.c \
	pinshad.c pins_e.c bulb.c realpin.c pencil.c
OBJ= quads_a.o quads_b.o quads_c.o pins_a.o pins_b.o pins_c.o pins_d.o \
	pinshad.o pins_e.o bulb.o realpin.o pencil.o
EXEC= quads_a.gen quads_b.gen quads_c.gen pins_a.gen pins_b.gen pins_c.gen \
	pins_d.gen pinshad.gen pins_e.gen bulb.gen realpin.gen pencil.gen
RIB= quads_a.rib quads_b.rib quads_c.rib pins_a.rib pins_b.rib pins_c.rib \
	pins_d.rib pinshad.rib pins_e.rib bulb.rib realpin.rib pencil.rib
PICS= quads_a.tiff quads_b.tiff quads_c.tiff pins_a.tiff pins_b.tiff pins_c.tiff \
	pins_d.tiff pins_e.tiff bulb.tiff realpin.tiff pencil.tiff

PICXSIZE=512
PICYSIZE=384

pics:	exec rib $(PICS)

rib:	exec $(RIB)

exec:	$(EXEC)

all:	$(PICS)

../misc/placecam.o: 
	make -f ../misc/Makefile build_camera
	mv placecam.o framecam.o ../misc
	
../misc/framecam.o:
	make -f ../misc/Makefile build_camera
	mv placecam.o framecam.o ../misc
	
.c.o:	$*.h $*.c
	$(CC) $(CFLAGS) -c $<

pinshad.gen: pinshad.o pinshad.h ../misc/placecam.o ../misc/framecam.o
	$(CC) $(CFLAGS) -o pinshad.gen pinshad.o ../misc/framecam.o ../misc/placecam.o $(LIBS)

.o.gen:
	$(CC) $(CFLAGS) -o $@ $< $(VIEWFILES) $(LIBS)

.gen.rib:
	$< >$@

#Not too, helpful unless you have a texture you wish to put here
#pinshad.rib: pinshad.gen
#pinshad.txt: pinshad.rib
#	$(RUN_RMAN) pinshad.rib
#	txmake -shadow pinshad.z pinshad.txt

realpin.tiff:
	$(RUN_RMAN) $*.rib

.rib.tiff:
	$(RUN_RMAN) $*.rib

.sl.$(SHADER_EXT):
	$(SHADER) $*.sl

quads_a.gen: quads_a.o quads_a.h $(VIEWFILES)
quads_a.tiff: quads_a.rib constant.$(SHADER_EXT) \
	matte.$(SHADER_EXT) metal.$(SHADER_EXT) plastic.$(SHADER_EXT) \
	show_st.$(SHADER_EXT) checker.$(SHADER_EXT) ambientlight.$(SHADER_EXT) \
	distantlight.$(SHADER_EXT)

quads_b.gen: quads_b.o quads_b.h $(VIEWFILES)
quads_b.tiff: quads_b.rib show_xyz.$(SHADER_EXT) \
	screen.$(SHADER_EXT) wood.$(SHADER_EXT) dented.$(SHADER_EXT) \
	eroded.$(SHADER_EXT) granite.$(SHADER_EXT) ambientlight.$(SHADER_EXT) \
	metal.$(SHADER_EXT) pointlight.$(SHADER_EXT)

quads_c.gen: quads_c.o quads_c.h $(VIEWFILES)
quads_c.tiff: quads_c.rib windowhighlight.$(SHADER_EXT) \
	blue_marble.$(SHADER_EXT) easysurface.$(SHADER_EXT) round.$(SHADER_EXT) \
	ambientlight.$(SHADER_EXT) distantlight.$(SHADER_EXT)

pins_a.gen: pins_a.o pins_a.h $(VIEWFILES)
pins_a.tiff: pins_a.rib wood.$(SHADER_EXT) \
	plastic.$(SHADER_EXT) ambientlight.$(SHADER_EXT) \
	spotlight.$(SHADER_EXT) pointlight.$(SHADER_EXT)

pins_b.gen: pins_b.o pins_b.h $(VIEWFILES)
pins_b.tiff: pins_b.rib wood.$(SHADER_EXT) \
	plastic.$(SHADER_EXT) depthcue.$(SHADER_EXT) \
	ambientlight.$(SHADER_EXT) spotlight.$(SHADER_EXT) \
	pointlight.$(SHADER_EXT)

pins_c.gen: pins_c.o pins_c.h $(VIEWFILES)
pins_c.tiff: pins_c.rib wood.$(SHADER_EXT) \
	plastic.$(SHADER_EXT) fog.$(SHADER_EXT) ambientlight.$(SHADER_EXT) \
	spotlight.$(SHADER_EXT) pointlight.$(SHADER_EXT)

pins_d.gen: pins_d.o pins_d.h $(VIEWFILES)
pins_d.tiff: pins_d.rib wood.$(SHADER_EXT) \
	plastic.$(SHADER_EXT) fog.$(SHADER_EXT) ambientlight.$(SHADER_EXT) \
	windowlight.$(SHADER_EXT) pointlight.$(SHADER_EXT)

pins_e.gen: pins_e.o pins_e.h $(VIEWFILES)
pins_e.tiff: pins_e.rib pinshad.txt \
	wood.$(SHADER_EXT) plastic.$(SHADER_EXT) ambientlight.$(SHADER_EXT) \
	shadowspot.$(SHADER_EXT) pointlight.$(SHADER_EXT)

bulb.gen: bulb.o bulb.h
bulb.tiff: bulb.rib threads.$(SHADER_EXT) \
	filament.$(SHADER_EXT) droop.$(SHADER_EXT) metal.$(SHADER_EXT) \
	glow.$(SHADER_EXT) ambientlight.$(SHADER_EXT) pointlight.$(SHADER_EXT)

realpin.gen: realpin.o realpin.h $(VIEWFILES)
realpin.tiff: realpin.rib pcontour.h \
	pin_color.$(SHADER_EXT) gouge.$(SHADER_EXT) pointlight.$(SHADER_EXT) \
	ambientlight.$(SHADER_EXT)

pencil.gen: pencil.o pencil.h
pencil.tiff: pencil.rib ambientlight.$(SHADER_EXT) \
	distantlight.$(SHADER_EXT) matte.$(SHADER_EXT) emboss.$(SHADER_EXT) \
	sdixon.$(SHADER_EXT) wood.$(SHADER_EXT) dferrule.$(SHADER_EXT) 
#	sferrule.$(SHADER_EXT) rubber.$(SHADER_EXT)
 
clean:    
	@echo 'Removing all .$(SHADER_EXT), .o, .gen, .rib, and .tiff files in this directory'
	-rm -f *.$(SHADER_EXT)
	-rm -f *.o
	-rm -f *.gen
	-rm -f *.rib
	-rm -f *.tiff
	-rm -f pinshad.z pinshad.txt
