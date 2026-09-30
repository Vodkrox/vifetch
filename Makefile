CC ?= cc
CFLAGS ?= -O2
PREFIX ?= /usr/local
LDFLAGS ?=
LDLIBS = -lm
CODENAME ?= Overclocked ASCII

UNAME_S := $(shell uname -s)
UNAME_M := $(shell uname -m)
ifeq ($(UNAME_S),Darwin)
  LDLIBS += -framework IOKit -framework CoreFoundation
endif

vifetch: fetch.c logos.h
	$(CC) $(CFLAGS) $(LDFLAGS) -DFETCH_CODENAME='"$(CODENAME)"' -DFETCH_ARCH='"$(UNAME_M)"' -DFETCH_OS='"$(UNAME_S)"' -o $@ $< $(LDLIBS)

install: vifetch
	install -d $(DESTDIR)$(PREFIX)/bin
	install -m 755 vifetch $(DESTDIR)$(PREFIX)/bin/vifetch

clean:
	rm -f vifetch

.PHONY: install clean
