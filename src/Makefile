cc=gcc 
CFLAGS=-Wall -DNO_DLL_DEFS -fPIC
LDLIBS=-lm

OBJECTS=HKW_cubic.o HKW_sg.o matrix.o moments.o sg_HKW.o sg_functions.o

all: scengen_HKW

scengen_HKW: $(OBJECTS)
	$(LINK.o) $^ $(LOADLIBES) $(LDLIBS) -o $@

libHKW_sg.so: HKW_cubic.o HKW_sg.o matrix.o moments.o sg_functions.o
	$(LINK.o) -shared $^ -o $@

clean:
	rm -f scengen_HKW $(OBJECTS) *~
