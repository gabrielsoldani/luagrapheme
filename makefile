.POSIX:
.SUFFIXES:

VERSION_MAJOR = 0
VERSION_MINOR = 1
VERSION_PATCH = 0

VERSION = $(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_PATCH)

include config.mk

CFLAGS = \
	$(CFLAGS_BASE) \
	-DVERSION_MAJOR=$(VERSION_MAJOR) \
	-DVERSION_MINOR=$(VERSION_MINOR) \
	-DVERSION_PATCH=$(VERSION_PATCH) \
	-DVERSION=\"$(VERSION)\" \
	-I $(LUA_INCDIR) \
	-I $(GRAPHEME_INCDIR) \
	-I vendor/lua-compat-5.3 \
	$(CFLAGS_EXTRA)

LDFLAGS = \
	-L $(GRAPHEME_LIBDIR) \
	-l grapheme \
	$(LDFLAGS_EXTRA)

SOFLAGS = $(LDFLAGS)

SRC = \
	src/uni.c

all: $(SONAME)

install: $(SONAME)
	cp $(SONAME) $(INST_LIBDIR)/$(SONAME)

clean:
	$(RM) -f $(ANAME) $(SONAME) $(SRC:.c=.o)

lint:
	$(LUACHECK) .

test:
	$(BUSTED) $(BUSTEDFLAGS)

$(SONAME): $(SRC:.c=.o)
	$(CC) -o $@ $(SOFLAGS) $(SRC:.c=.o)

src/uni.o: src/uni.c makefile config.mk

$(SRC:.c=.o):
	$(CC) -c -o $@ $(CFLAGS) $(@:.o=.c)

.PHONY: all install clean lint test
