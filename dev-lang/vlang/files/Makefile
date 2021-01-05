CC ?=
CFLAGS ?=
LDFLAGS ?=
VC     ?= ./vc
VCFILE := v.c

all: selfcompile

selfcompile:
	$(CC) $(CFLAGS) -g -std=gnu11 -w -o v $(VC)/$(VCFILE) $(LDFLAGS) -lm -lpthread
	./v -cg -cflags '--static' -o v cmd/v
