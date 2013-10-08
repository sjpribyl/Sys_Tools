.SUFFIXES:
.SUFFIXES: .c .o

PMG= ds_suusrmgt
PARTS= ds_suusrmgt.o

CFLAGS=-O
UNAME		:= $(shell uname)
CPU		:= $(shell uname -p)

TARGET := ${PMG}.${UNAME}.${CPU}

all:ds_suusrmgt

ds_suusrmgt: ${PARTS}
	$(CC) -I. $(CFLAGS) ${PARTS} -o $@

.c.o: ${PARTS:.o=.c}
	$(CC) -I. $(CFLAGS) $< -c -o $@


clean:
	rm -f ${PARTS} ds_suusrmgt
