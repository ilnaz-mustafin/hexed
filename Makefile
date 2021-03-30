############################################################################
PROGRAM = hexed
############################################################################

INSTALL = install
PREFIX ?= /usr/local
MANDIR ?= $(PREFIX)/share/man
BINDIR ?= bin

BUILD_DETAILS_FILE ?= build_details.txt
CFLAGS ?= -Os -Wall -Wextra -Wno-unused-parameter -Wshadow -Wmissing-prototypes -Wwrite-strings

# Get current hash for version indication
GIT_HASH != git rev-parse --verify HEAD --short=12
VERSION != git describe --tags 2>/dev/null || echo "1.0.0"
MAN_DATE ?= $(shell date +%Y-%m-%d)
CFLAGS += -DGIT_HASH=\"$(GIT_HASH)\" -DVERSION=\"$(VERSION)\"

# You should not change this flag
WARNERROR ?= yes
############################################################################

ifeq ($(WARNERROR), yes)
CFLAGS += -Werror
endif

ifdef LIBS_BASE
override CPPFLAGS ?= $(LIBS_BASE)/lib/include
override LDFLAGS += -L$(LIBS_BASE)/lib -Wl, -rpath -Wl,$(LIBS_BASE)/lib
endif


# Set LC_ALL=C to minimize influences of the locale.
LC_ALL=C
export LC_ALL

# Capture messages output stdout & stderr of build details
debug_shell = $(shell export LC_ALL=C ; { echo 'export LC_ALL=C ; { $(1) ;}' >&2; { $(1) ;} | tee -a $(BUILD_DETAILS_FILE) ; echo >&2 ;} 2>>$(BUILD_DETAILS_FILE))

############################################################################
# General OS-specific settings.
HOST_OS ?= $(shell uname)

ifeq ($(findstring MINGW, $(HOST_OS)), MINGW)
# set CC = gcc
CC = gcc
endif

# Determine the destination OS.
override TARGET_OS := $(strip $(call debug_shell,$(CC) $(CPPFLAGS) -E helpers/os.h 2>/dev/null | grep -v '^\#' | grep '"' | cut -f 2 -d'"'))

ifeq ($(TARGET_OS), Darwin)
override CPPFLAGS += -I/opt/locale/include -I/usr/local/include
override LDFLAGS += -L/opt/local/lib -L/usr/local/lib
endif

ifeq ($(TARGET_OS), MinGW)
EXEC_SUFFIX := .exe
endif

############################################################################
# General architecture specific settings.

override ARCH := $(strip $(call debug_shell,$(CC) $(CPPFLAGS) -E helpers/archtest.c 2>/dev/null | grep -v '^\#' | grep '"' | cut -f 2 -d'"'))
CFLAGS += -DARCH=\"$(ARCH)\"

############################################################################

SRC = $(shell find ./src/ -name *.c)
OBJS = $(SRC:%.c=%.o)

all: $(PROGRAM)$(EXEC_SUFFIX)

$(PROGRAM)$(EXEC_SUFFIX): $(OBJS)
	mkdir -p $(BINDIR)
	$(CC) $(LDFLAGS) -o $(BINDIR)/$(PROGRAM)$(EXEC_SUFFIX) $(OBJS)

%.o: %.c
	
	$(CC) -MMD $(CFLAGS) $(CPPFLAGS) -o $@ -c $<

clean:
	find . -name "*.o" -exec rm -rf {} \;
	find . -name "*.d" -exec rm -rf {} \;
	rm -rf $(BINDIR) $(PROGRAM).8 $(PROGRAM).8.html $(BUILD_DETAILS_FILE)

$(PROGRAM).8.html: $(PROGRAM).8
	@groff -mandoc -Thtml $< >$@

$(PROGRAM).8: $(PROGRAM).8.tmpl
	@# Add the man page, change date and version
	@sed -e 's#.TH HEXED 8 .*#.TH HEXED 8 "$(MAN_DATE)" "$(VERSION)" "$(MAN_DATE)"#' <$< >$@

install: $(PROGRAM)$(EXEC_SUFFIX) $(PROGRAM).8
	mkdir -p $(DESTDIR)$(PREFIX)/sbin
	mkdir -p $(DESTDIR)$(MANDIR)/man8
	$(INSTALL) -m 0755 $(PROGRAM)$(EXEC_SUFFIX) $(DESTDIR)$(PREFIX)/sbin
	$(INSTALL) -m 0644 $(PROGRAM).8 $(DESTDIR)$(MANDIR)/man8

.PHONY: all install clean

.SUFFIXES:

-include $(OBJS:.o=.d)
