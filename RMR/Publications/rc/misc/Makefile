#
# Makefile for the misc directory -- to provide placecam.o and framecam.o
#

#RIDIR -- Include directory where ri.h is located
RIDIR=-I/usr/local/BMRT/include
#RIDIR=

#CC -- Compiler
#CC= cc
CC= cc 

build_camera: placecam.o framecam.o

placecam.o: ../ch8/listing8_2.c
	$(CC) $(RIDIR) -c ../ch8/listing8_2.c
	mv listing8_2.o placecam.o

framecam.o: ../ch8/listing8_4.c
	$(CC) $(RIDIR) -c ../ch8/listing8_4.c
	mv listing8_4.o framecam.o
