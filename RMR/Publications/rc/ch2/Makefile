#
#       Makefile for PhotoRealistic RenderMan Tutorial Chapter 2
#
RMAN=  /caltech/Local/usr/lib/libribout.a
PRMAN= prman
RUN_RMAN=prman

CC= cc
CFLAGS =  -I/caltech/Local/usr/include
LIBS = $(RMAN) -lg++ -lm
.SUFFIXES: .tiff .rib .gen .o .c

SRC=basic2_1.c color2_2.c cubemain.c cube2_3.c cube2_4.c cube2_5.c \
	colrmain.c ccube2_6.c ccube2_7.c anim2_8.c
OBJ=basic2_1.o color2_2.o cubemain.o cube2_3.o cube2_4.o cube2_5.o \
	colrmain.o ccube2_6.o ccube2_7.o anim2_8.o
EXEC=basic2_1.gen color2_2.gen cube2_3.gen cube2_4.gen cube2_5.gen \
	ccube2_6.gen ccube2_7.gen anim2_8.gen
RIB=basic2_1.rib color2_2.rib cube2_3.rib cube2_4.rib cube2_5.rib \
	ccube2_6.rib ccube2_7.rib anim2_8.rib
PICS=basic2_1.tiff color2_2.tiff cube2_3.tiff cube2_4.tiff cube2_5.tiff \
	ccube2_6.tiff ccube2_7.tiff anim2_8.tiff

PICXSIZE=640
PICYSIZE=480

pics:	exec rib $(PICS)

rib:    exec $(RIB)

exec:	$(EXEC)

all:	$(PICS)

.c.o:
	$(CC) $(CFLAGS) -c $<

.o.gen:
	$CC) $(CFLAGS) -o $@ $< $(LIBS)

.gen.rib:
	$< >$@

anim2_8.tiff:
	$(RUN_RMAN) anim2_8.rib

.rib.tiff:
	$(RUN_RMAN) $*.rib
# To save images after $(RUN_RMAN)ing, replace this comment
# with the appropriate image saving command for your system.

ccube2_6.gen: colrmain.o ccube2_6.o cube2_3.o
	$(CC) $(CFLAGS) -o $@ colrmain.o ccube2_6.o cube2_3.o $(LIBS)
ccube2_7.gen: colrmain.o ccube2_7.o cube2_3.o
	$(CC) $(CFLAGS) -o $@ colrmain.o ccube2_7.o cube2_3.o $(LIBS)

cube2_3.gen: cubemain.o cube2_3.o
	$(CC) $(CFLAGS) -o $@ cubemain.o cube2_3.o $(LIBS)
cube2_4.gen: cubemain.o cube2_4.o
	$(CC) $(CFLAGS) -o $@ cubemain.o cube2_4.o $(LIBS)
cube2_5.gen: cubemain.o cube2_5.o
	$(CC) $(CFLAGS) -o $@ cubemain.o cube2_5.o $(LIBS)

basic2_1.gen: basic2_1.o
	$(CC) $(CFLAGS) -o $@ basic2_1.o $(LIBS)
color2_2.gen: color2_2.o
	$(CC) $(CFLAGS) -o $@ color2_2.o $(LIBS)

anim2_8.gen: anim2_8.o ccube2_7.o cube2_3.o
	$(CC) $(CFLAGS) -o $@ anim2_8.o ccube2_7.o cube2_3.o $(LIBS)

clean:
	@echo 'Removing all .slo, .o, .gen, .rib, and .tiff files in this directory'
	-rm -f *.slo
	-rm -f *.o
	-rm -f *.gen
	-rm -f *.rib
	-rm -f *.tiff
