#
#       Makefile for PhotoRealistic RenderMan Tutorial Chapter 10
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

SRC= listing10_1.c listing10_3.c
OBJ= listing10_1.o listing10_3.o
EXEC= listing10_1.gen listing10_3.gen
RIB= listing10_1.rib listing10_3.rib
PICS= listing10_1.tiff listing10_3.tiff

PICXSIZE=512
PICYSIZE=384

pics:	rib $(PICS)

rib:	exec $(RIB)

exec:	$(EXEC) 

all:	$(PICS)

$(EXEC): $(VIEWFILES)

../misc/placecam.o: 
	make -f ../misc/Makefile build_camera
	mv placecam.o framecam.o ../misc
	
../misc/framecam.o:
	make -f ../misc/Makefile build_camera
	mv placecam.o framecam.o ../misc
	

.c.o:
	$(CC) -c $(CFLAGS) $<

.gen.rib:
	$< >$@

.rib.tiff:
	$(RUN_RMAN) $*.rib
# To save images after $(RUN_RMAN)ing, replace this comment
# with the appropriate image saving command for your system.

listing10_3.gen: listing10_3.o listing10_3.h frac.h
	$(CC) $(CFLAGS) -o $@ -DHEADER=\"../ch10/listing10_3.h\" listing10_3.o $(VIEWFILES) $(LIBS)

listing10_1.gen: listing10_1.o ../ch2/listing2_7.o ../ch2/listing2_3.o
	$(CC) $(CFLAGS) -o $@ listing10_1.o ../ch2/listing2_7.o ../ch2/listing2_3.o $(LIBS)
 
clean:    
	@echo 'Removing all .slo,.o,.gen,.rib,and.tiff files in this directory'
	-rm -f *.slo
	-rm -f *.o
	-rm -f *.gen
	-rm -f *.rib
	-rm -f *.tiff
