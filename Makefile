#
# Set CROSS_PREFIX to prepend to all compiler tools at once for easier
# cross-compilation.
CROSS_PREFIX =
CC           = $(CROSS_PREFIX)gcc
AR           = $(CROSS_PREFIX)ar
RANLIB       = $(CROSS_PREFIX)ranlib
SIZE         = $(CROSS_PREFIX)size
STRIP        = $(CROSS_PREFIX)strip
SHLIB        = $(CC) -shared
STRIPLIB     = $(STRIP) --strip-unneeded

SOVERSION    = 1

CFLAGS	+= -O3 -Wall -pthread

PROGRAM = linux_daemon

LIB      = 

ALL     = $(LIB) $(PROGRAM)

prefix = /usr/local
exec_prefix = $(prefix)
bindir = $(exec_prefix)/bin
includedir = $(prefix)/include
libdir = $(prefix)/lib
mandir = $(prefix)/man

all:	$(ALL)

lib:	$(LIB)

$(PROGRAM):	linux_daemon.o
	$(CC) -o $(PROGRAM) linux_daemon.o -L. -pthread
	$(STRIP) $(PROGRAM)

clean:
	rm -f *.o *.i *.s *~ $(ALL) *.so.$(SOVERSION)

ifeq ($(DESTDIR),)
  PYINSTALLARGS =
else
  PYINSTALLARGS = --root=$(DESTDIR)
endif

install: $(ALL)
	install -m 0755 $(PROGRAM)                      $(DESTDIR)$(bindir)
	if which python2; then python2 setup.py install $(PYINSTALLARGS); fi
	if which python3; then python3 setup.py install $(PYINSTALLARGS); fi
ifeq ($(DESTDIR),)
	ldconfig
endif

uninstall:
	rm -f $(DESTDIR)$(bindir)/$(PROGRAM)
	if which python2; then python2 setup.py install $(PYINSTALLARGS) --record /tmp/$(PROGRAM) >/dev/null; sed 's!^!$(DESTDIR)!' < /tmp/pigpio | xargs rm -f >/dev/null; fi
	if which python3; then python3 setup.py install $(PYINSTALLARGS) --record /tmp/$(PROGRAM) >/dev/null; sed 's!^!$(DESTDIR)!' < /tmp/pigpio | xargs rm -f >/dev/null; fi
ifeq ($(DESTDIR),)
	ldconfig
endif

# generated using gcc -MM *.c

linux_daemon.o: linux_daemon.c
