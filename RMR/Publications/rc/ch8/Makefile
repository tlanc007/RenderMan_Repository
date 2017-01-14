#
#       Makefile for PhotoRealistic RenderMan Tutorial Chapter 8
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

CFLAGS =  -I. $(RIDIR) -DHEADER=\"../ch8/$*.h\"

## Shouldn't be any need to change anything below here
LIBS = $(RMAN_LIB) $(OTHER_LIBS)
 
.SUFFIXES: .tiff .rib .gen .o .c
VIEWFILES= ../misc/main.c ../misc/placecam.o ../misc/framecam.o

SRC= listing8_1.c listing8_3.c listing8_4.c
OBJ= listing8_1.o listing8_3.o listing8_4.o
EXEC= listing8_1.gen listing8_3.gen listing8_4.gen
RIB= listing8_1.rib listing8_3.rib listing8_4.rib
PICS= listing8_1.tiff listing8_3.tiff listing8_4.tiff

PICXSIZE=640
PICYSIZE=480

pics:	exec rib $(PICS)

rib:	exec $(RIB)

exec:	$(EXEC)

all:	$(PICS)

.c.o:
	$(CC) $(CFLAGS) -c $<

listing8_3.gen:
	$(CC) $(CFLAGS) listing8_5.o listing8_2.o listing8_3.o -o listing8_3.gen $(LIBS)

listing8_4.gen:
	$(CC) $(CFLAGS) listing8_5.o listing8_2.o listing8_4.o -o listing8_4.gen $(LIBS)

.o.gen:
	$(CC) $(CFLAGS) -o $@ $< $(LIBS)

.gen.rib:
	$< >$@

.rib.tiff:
	$(RUN_RMAN) $*.rib
# To save images after $(RUN_RMAN)ing, replace this comment
# with the appropriate image saving command for your system.

listing8_1.gen: listing8_1.o
listing8_3.gen: listing8_5.o listing8_2.o listing8_3.o
listing8_4.gen: listing8_5.o listing8_2.o listing8_4.o
 
clean:    
	@echo 'Removing all .slo, .o, .gen, .rib, and .tiff files in this directory'
	-rm -f *.slo
	-rm -f *.o
	-rm -f *.gen
	-rm -f *.rib
	-rm -f *.tiff
