cc=gcc 
CFLAGS=-Wall -DNO_DLL_DEFS -fPIC
LDLIBS=-lm

OBJECTS=HKW_cubic.o HKW_sg.o matrix.o moments.o sg_HKW.o sg_functions.o

libHKW_sg.so: HKW_cubic.o HKW_sg.o matrix.o moments.o sg_functions.o
	$(LINK.o) -shared $^ -o $@

scengen_HKW: $(OBJECTS)
	$(LINK.o) $^ $(LOADLIBES) $(LDLIBS) -o $@

clean:
	rm -f scengen_HKW $(OBJECTS) *~
