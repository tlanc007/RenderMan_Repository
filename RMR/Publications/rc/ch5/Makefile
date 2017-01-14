#
#       Makefile for The RenderMan Companion Chapter 5
#
#RMAN_LIB -- Give RenderMan library
#RMAN_LIB=   /caltech/Local/usr/lib/libribout.a
RMAN_LIB=

#RIDIR -- Include directory where ri.h is located
#RIDIR=-I/caltech/Local/usr/include
RIDIR=

#RUN_RMAN -- Render, ie. prman, rendrib
#RUN_RMAN=prman
RUN_RMAN=

#OTHER_LIBS -- Any other libraries needed at link time
#OTHER_LIBS=-lg++ -lm
OTHER_LIBS=

#CC -- Compiler
#CC= cc
CC= cc 

CFLAGS =  -I. $(RIDIR) -DHEADER=\"../ch5/$*.h\"

## Shouldn't be any need to change anything below here
LIBS = $(RMAN_LIB) $(OTHER_LIBS)

 
.SUFFIXES: .tiff .rib .gen .o .c
VIEWFILES= ../misc/main.c ../misc/placecam.o ../misc/framecam.o

SRC= listing5_1.c listing5_2.c listing5_3.c
OBJ= listing5_1.o listing5_2.o listing5_3.o
EXEC= listing5_1.gen listing5_2.gen listing5_3.gen
RIB= listing5_1.rib listing5_2.rib listing5_3.rib
PICS= listing5_1.tiff listing5_2.tiff listing5_3.tiff

PICXSIZE=255
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

flat5_1.gen: flat5_1.o flat5_1.h hcontour.h $(VIEWFILES)
listing5_2.gen: listing5_2.o listing5_2.h hcontour.h $(VIEWFILES)
listing5_3.gen: listing5_3.o listing5_3.h hcontour.h $(VIEWFILES)
 
clean:    
	@echo 'Removing all .slo, .o, .gen, .rib, and .tiff files in this directory'
	-rm -f *.slo
	-rm -f *.o
	-rm -f *.gen
	-rm -f *.rib
	-rm -f *.tiff
