#
#       Makefile for PhotoRealistic RenderMan Tutorial Chapter 13
#
#RMAN_LIB -- Give RenderMan library
#RMAN_LIB= /caltech/Local/usr/lib/libribout.a
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
CC= cc 

CFLAGS =  -I. $(RIDIR) -DHEADER=\"../ch13/$*.h\"

## Shouldn't be any need to change anything below here
LIBS = $(RMAN_LIB) $(OTHER_LIBS)
 
.SUFFIXES: .tiff .rib .gen .o .c .$(SHADER_EXT) .sl
VIEWFILES= ../misc/main.c ../misc/placecam.o ../misc/framecam.o

SRC= surf13_1.c
OBJ= surf13_1.o
EXEC= surf13_1.gen
RIB= surf13_1.rib
PICS= surf13_1.tiff

PICXSIZE=256
PICYSIZE=640

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
	
.sl.$(SHADER_EXT):
	$(SHADER) $<

.c.o:
	$(CC) $(CFLAGS) -c $<

.o.gen:
	$(CC) $(CFLAGS) -o $@ $(VIEWFILES) $< $(LIBS)

.gen.rib:
	$< >$@

.rib.tiff:
	$(RUN_RMAN) $*.rib
# To save images after $(RUN_RMAN)ing, replace this comment
# with the appropriate image saving command for your system.
	
surf13_1.gen: surf13_1.o surf13_1.h clouds.$(SHADER_EXT) pcontour.h $(VIEWFILES)
	$(CC) -o $@ $(CFLAGS) surf13_1.o $(VIEWFILES) $(LIBS)
 
clean:    
	@echo 'Removing all .slo, .o, .gen, .rib, and .tiff files in this directory'
	-rm -f *.slo
	-rm -f *.o
	-rm -f *.gen
	-rm -f *.rib
	-rm -f *.tiff
