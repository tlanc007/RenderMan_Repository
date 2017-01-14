#
#       Makefile for PhotoRealistic RenderMan Tutorial Chapter 6
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

#OTHER_LIBS -- Any other libraries needed at link time
#OTHER_LIBS=-lg++ -lm
OTHER_LIBS=

#CC -- Compiler
#CC= cc
CC= cc 

CFLAGS =  -I. $(RIDIR) -DHEADER=\"../ch6/$*.h\"

## Shouldn't be any need to change anything below here
LIBS = $(RMAN_LIB) $(OTHER_LIBS)

.SUFFIXES: .tiff .rib .gen .o .c
VIEWFILES= ../misc/main.c ../misc/placecam.o ../misc/framecam.o

SRC= listing6_1.c listing6_2.c listing6_3.c listing6_4.c
OBJ= listing6_1.o listing6_2.o listing6_3.o listing6_4.o
EXEC= listing6_1.gen listing6_2.gen listing6_3.gen listing6_4.gen
RIB= listing6_1.rib listing6_2.rib listing6_3.rib listing6_4.rib
PICS= listing6_1.tiff listing6_2.tiff listing6_3.tiff listing6_4.tiff

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

listing6_3.tiff:
	$(RUN_RMAN) listing6_3.rib
# To save images after $(RUN_RMAN)ing, replace this comment
# with the appropriate image saving command for your system.

listing6_4.tiff:
	$(RUN_RMAN) $*.rib
# To save images after $(RUN_RMAN)ing, replace this comment
# with the appropriate image saving command for your system.

.rib.tiff:
	$(RUN_RMAN) $*.rib
# To save images after $(RUN_RMAN)ing, replace this comment
# with the appropriate image saving command for your system.

listing6_1.gen: listing6_1.o listing6_1.h $(VIEWFILES)
listing6_2.gen: listing6_2.o listing6_2.h $(VIEWFILES)
listing6_3.gen: listing6_3.o listing6_3.h pcontour.h $(VIEWFILES)
listing6_4.gen: listing6_4.o listing6_4.h pcontour.h $(VIEWFILES)
 
clean:    
	@echo 'Removing all .slo, .o, .gen, .rib, and .tiff files in this directory'
	-rm -f *.slo
	-rm -f *.o
	-rm -f *.gen
	-rm -f *.rib
	-rm -f *.tiff
