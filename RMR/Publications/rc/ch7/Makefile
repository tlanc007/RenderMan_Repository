#
#       Makefile for PhotoRealistic RenderMan Tutorial Chapter 7
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

CFLAGS =  -I. $(RIDIR) -DHEADER=\"../ch7/$*.h\"

## Shouldn't be any need to change anything below here
LIBS = $(RMAN_LIB) $(OTHER_LIBS)
 
.SUFFIXES: .tiff .rib .gen .o .c
VIEWFILES= ../misc/main.c ../misc/placecam.o ../misc/framecam.o

SRC= listing7_1.c surf_go.c listing7_2.c wedge_go.c listing7_3.c listing7_4.c
OBJ= listing7_1.o listing7_2.o listing7_3.o listing7_4.o
EXEC= listing7_1.gen listing7_2.gen listing7_3.gen listing7_4.gen
RIB= listing7_1.rib listing7_2.rib listing7_3.rib listing7_4.rib
PICS= listing7_1.tiff listing7_2.tiff listing7_3.tiff listing7_4.tiff

PICXSIZE=256
PICYSIZE=192

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

listing7_1.o: surf_go.c listing7_1.h listing7_1.c hcontour.h 
	$(CC) $(CFLAGS) -c surf_go.c
	mv surf_go.o listing7_1.o

listing7_2.o: wedge_go.c listing7_2.h listing7_2.c hcontour.h 
	$(CC) $(CFLAGS) -c wedge_go.c
	mv wedge_go.o listing7_2.o

listing7_1.gen: listing7_1.o $(VIEWFILES)
listing7_2.gen: listing7_2.o $(VIEWFILES)
listing7_3.gen: listing7_3.o listing7_3.h listing7_2.c $(VIEWFILES)
listing7_4.gen: listing7_4.o listing7_4.h listing7_1.c hcontour.h $(VIEWFILES)
 
clean:    
	@echo 'Removing all .slo, .o, .gen, .rib, and .tiff files in this directory'
	-rm -f *.slo *.o *.gen *.rib *.tiff
