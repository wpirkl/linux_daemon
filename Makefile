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

CFLAGS	 = -O3
CFLAGS  += -Wall
CFLAGS  += -pthread

CPPFLAGS = $(CFLAGS) -lgcc

PROGRAM = linux_daemon

LIB     = 

ALL     = $(LIB) $(PROGRAM)

OBJS   += linux_daemon.o
OBJS   += app_interface.o

prefix = /usr/local
exec_prefix = $(prefix)
bindir = $(exec_prefix)/bin
includedir = $(prefix)/include
libdir = $(prefix)/lib
mandir = $(prefix)/man

all:	$(ALL)

lib:	$(LIB)

$(PROGRAM): $(OBJS)
	$(CC) -o $(PROGRAM) $(OBJS) -L. -pthread
	$(STRIP) $(PROGRAM)

clean:
	rm -f *.o *.i *.s *~ $(ALL) *.so.$(SOVERSION) *.dep

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

%.o : %.c
	$(CC) $(CFLAGS) -c -o $@ -MMD -MP -MF $(@:.o=.dep) $<

-include $(wildcard *.dep)
