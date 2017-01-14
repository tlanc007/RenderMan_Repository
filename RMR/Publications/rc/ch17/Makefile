#
# Makefile for PhotoRealistic RenderMan Tutorial Section 17
#
RMAN	= /usr/local/prman
CFLAGS	= -I$(RMAN)/include $(COPT)
LIBS	= -L$(RMAN)/lib -lrib -lzip -lm

.SUFFIXES: .pic .rib .gen .o .c .sl .slo

EXEC =	buck17_1.gen buck17_2.gen splt17_3.gen splt17_4.gen jitt17_5.gen \
	jitt17_6.gen shad17_7.gen shad17_8.gen off17_9.gen bnd17_10.gen \
	bnd17_11.gen dsp17_12.gen dsp17_13.gen
RIB =	buck17_1.rib buck17_2.rib splt17_3.rib splt17_4.rib jitt17_5.rib \
	jitt17_6.rib shad17_7.rib shad17_8.rib off17_9.rib bnd17_10.rib \
	bnd17_11.rib dsp17_12.rib dsp17_13.rib
PICS =	buck17_1.pic buck17_2.pic splt17_3.pic splt17_4.pic jitt17_5.pic \
	jitt17_6.pic shad17_7.pic shad17_8.pic off17_9.pic bnd17_10.pic \
	bnd17_11.pic dsp17_12.pic dsp17_13.pic

pics:	rib all
rib:    exec $(RIB)
exec:	$(EXEC)
all:	$(PICS)

shad17_7.pic: shad17_7.rib shadowlight.slo
shad17_8.pic: shad17_8.rib shadowlight.slo
dsp17_12.pic: dsp17_12.rib wave.slo
dsp17_13.pic: dsp17_13.rib wave.slo

buck17_1.gen:	sphere.o opt_1.o
	$(CC) $(CFLAGS) -o $@ sphere.o opt_1.o $(LIBS)
buck17_2.gen:	sphere.o opt_2.o
	$(CC) $(CFLAGS) -o $@ sphere.o opt_2.o $(LIBS)
splt17_3.gen:	eyesplit.o opt_3.o
	$(CC) $(CFLAGS) -o $@ eyesplit.o opt_3.o $(LIBS)
splt17_4.gen:	eyesplit.o opt_4.o
	$(CC) $(CFLAGS) -o $@ eyesplit.o opt_4.o $(LIBS)
jitt17_5.gen:	jitter.o opt_5.o
	$(CC) $(CFLAGS) -o $@ jitter.o opt_5.o $(LIBS)
jitt17_6.gen:	jitter.o opt_6.o
	$(CC) $(CFLAGS) -o $@ jitter.o opt_6.o $(LIBS)
shad17_7.gen:	shadow.o opt_7.o
	$(CC) $(CFLAGS) -o $@ shadow.o opt_7.o $(LIBS)
shad17_8.gen:	shadow.o opt_8.o
	$(CC) $(CFLAGS) -o $@ shadow.o opt_8.o $(LIBS)
off17_9.gen:	offset.o opt_9.o
	$(CC) $(CFLAGS) -o $@ offset.o opt_9.o $(LIBS)
bnd17_10.gen:	bindice.o opt_10.o
	$(CC) $(CFLAGS) -o $@ bindice.o opt_10.o $(LIBS)
bnd17_11.gen:	bindice.o opt_11.o
	$(CC) $(CFLAGS) -o $@ bindice.o opt_11.o $(LIBS)
dsp17_12.gen:	cylinder.o opt_12.o
	$(CC) $(CFLAGS) -o $@ cylinder.o opt_12.o $(LIBS)
dsp17_13.gen:	cylinder.o opt_13.o
	$(CC) $(CFLAGS) -o $@ cylinder.o opt_13.o $(LIBS)

.o.gen:
	$(CC) $(CFLAGS) -o $@ $< $(LIBS)

.sl.slo:
	shader $<

.gen.rib:
	$< >$@

.rib.pic:
	render $<

clean allclean:
	-rm -f *.o *.gen *.rib *.slo *.tif shad17.z shad17.shd
