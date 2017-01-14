#
#       Makefile for PhotoRealistic RenderMan Tutorial Chapter 12
#
#RMAN_LIB -- Give RenderMan library
RMAN_LIB= /usr/local/BMRT/lib/libribout.a
#RMAN_LIB=

#RIDIR -- Include directory where ri.h is located
RIDIR=-I/usr/local/BMRT/include
#RIDIR=

#RUN_RMAN -- Render, ie. prman, rendrib
RUN_RMAN=prman
#RUN_RMAN=

#SHADER -- Shader compiler (prman (shader) rendrib (slc)
SHADER=shader
#SHADER=

#SHADER_EXT-- the extenstion that the shader produces (shader (slo) slc (so))
SHADER_EXT=slo
#SHADER_EXT=

#OTHER_LIBS -- Any other libraries needed at link time
OTHER_LIBS=-lg++ -lm
#OTHER_LIBS=

#CC -- Compiler
#CC= cc
CC= cc 

CFLAGS =  -I. $(RIDIR) -DHEADER=\"../ch12/$*.h\"

## Shouldn't be any need to change anything below here
LIBS = $(RMAN_LIB) $(OTHER_LIBS)
 
.SUFFIXES: .tiff .rib .gen .o .c .$(SHADER_EXT) .sl
VIEWFILES= ../misc/main.c ../misc/placecam.o ../misc/framecam.o

CUBEFILES= ../ch2/listing2_3.o ../ch2/listing2_7.o

SRC= listing12_1.c listing12_2.c envr12_3.c listing12_5.c
OBJ= listing12_1.o listing12_2.o envr12_3.o listing12_5.o
EXEC= listing12_1.gen listing12_2.gen envr12_3.gen listing12_5.gen
RIB= listing12_1.rib listing12_2.rib envr12_3.rib listing12_5.rib
PICS= listing12_1.tiff listing12_2.tiff envr12_3.tiff listing12_5.tiff

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
	
.c.o:
	$(CC) $(CFLAGS) -c $< 


listing12_1.gen: listing12_1.o $(VIEWFILES)
envr12_3.gen: envr12_3.o
	$(CC) -o $@ $(CFLAGS) envr12_3.o ../physcam.o ../placecam.o $(LIBS)

listing12_5.gen: listing12_5.o shadowspot.slo $(CUBEFILES)
	$(CC) -o $@ $(CFLAGS) listing12_5.o $(CUBEFILES) $(LIBS)

.o.gen:
	$(CC) $(CFLAGS) -o $@ $< $(VIEWFILES) $(LIBS)

.gen.rib:
	$< >$@

.rib.tiff:
	$(RUN_RMAN) $*.rib
# To save images after $(RUN_RMAN)ing, replace this comment
# with the appropriate image saving command for your system.

.sl.$(SHADER_EXT):
	$(SHADER) $<

listing12_1.gen: listing12_1.o listing12_1.h mytexture.$(SHADER_EXT)
listing12_2.gen: listing12_2.o listing12_2.h hcontour.h mytexture.$(SHADER_EXT)
envr12_3.gen: envr12_3.o shiny.slo
 
clean:    
	@echo 'Removing all environment images, .slo, .so, .o, .gen, .rib,'
	@echo 'and .tiff files in this directory'
	-rm -f env.xp
	-rm -f env.xm
	-rm -f env.yp
	-rm -f env.ym
	-rm -f env.zp
	-rm -f env.zm
	-rm -f env
	-rm -f shdw.z
	-rm -f shadfile
	-rm -f *.$(SHADER_EXT)
	-rm -f *.o
	-rm -f *.gen
	-rm -f *.rib
#	-rm -f *.tiff
