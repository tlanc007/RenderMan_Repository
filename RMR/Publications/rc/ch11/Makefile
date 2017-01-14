#
#       Makefile for PhotoRealistic RenderMan Tutorial Chapter 11
#
#RMAN_LIB -- Give RenderMan library
RMAN_LIB= /caltech/Local/usr/lib/libribout.a
#RMAN_LIB=

#RIDIR -- Include directory where ri.h is located
RIDIR=-I/caltech/Local/usr/include
#RIDIR=

#RUN_RMAN -- Render, ie. prman, rendrib
RUN_RMAN=prman
#RUN_RMAN=

#OTHER_LIBS -- Any other libraries needed at link time
OTHER_LIBS=-lg++ -lm
#OTHER_LIBS=

#CC -- Compiler
#CC= cc
CC= cc 

CFLAGS =  -I. $(RIDIR) -DHEADER=\"../ch11/$*.h\"

## Shouldn't be any need to change anything below here
LIBS = $(RMAN_LIB) $(OTHER_LIBS)
 
.SUFFIXES: .tiff .rib .gen .o .c
VIEWFILES= main.c ../misc/placecam.o ../misc/framecam.o

SRC= listing11_1.c
OBJ= listing11_1.o
EXEC= listing11_1.gen
RIB= listing11_1.rib
PICS= listing11_1.tiff

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

.o.gen:
	$(CC) $(CFLAGS) -o $@ $(VIEWFILES) $< $(LIBS)

.gen.rib:
	$< >$@

.rib.tiff:
	$(RUN_RMAN) listing11_1.rib

#listing11_1.o: listing11_1.c listing11_1.h

listing11_1.gen: listing11_1.o listing11_1.h $(VIEWFILES)
 
clean:    
	@echo 'Removing all .slo, .o, .gen, .rib, and .tiff files in this directory'
	-rm -f *.slo
	-rm -f *.o
	-rm -f *.gen
	-rm -f *.tiff
	-rm -f *.rib
