#Makefile for prman DSOs
#Tal Lancaster for RMR -- 10/24/98
#
# May need to set INCPATHS and set CC and LD
INCPATHS= -I. -I/usr/local/prman/include
#SGI
#CC=cc -c
#LD=ld -shared -B dynamic

#Linux
CC=cc -c -fPIC
LD=ld -shared
#CC=g++

.c.o:
	${CC} -fPIC -c $<  ${INCPATHS}

%.so : %.o
	${LD} $< -o $@

%.slo: %.sl
	shader $<

all: a_sphere.so dsoproc.so bbox.slo bbox.so

clean:
	rm *.o 
	rm *.so
