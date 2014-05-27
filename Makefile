CXX=g++
CC=gcc
BISON=bison30
COMMON=-ggdb -Wall -D_POSIX_C_SOURCE=200809L
OPTIMISE_FLAGS=-DNDEBUG -O3 -march=native

ifdef OPT
  CFLAGS+=$(OPTIMISE_FLAGS)
  CXXFLAGS+=$(OPTIMISE_FLAGS)
endif

CXXFLAGS+=$(COMMON) -std=c++11 $(CXXEXTRA)
CFLAGS+=$(COMMON) -std=c11 $(CEXTRA)

all: barbaric

barbaric.c: barbaric.l barbaric.tab.h
	flex -o $@ $<

barbaric.tab.h: barbaric.y
	bison30 -v -d -o $*.c $< 

barbaric.tab.c: barbaric.tab.h
	:

barbaric: barbaric.c barbaric.tab.c
	$(CC) $(CFLAGS) -o $@ $^

clean:
	rm -f barbaric.tab.* barbaric.c barbaric.output barbaric
