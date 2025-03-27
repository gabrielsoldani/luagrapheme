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

SRC = \
	src/case.c \
	src/count_segments.c \
	src/is_segment_break.c \
	src/match_n_segments.c \
	src/match_one_of_graphemes.c \
	src/reverse.c \
	src/segment_breaks.c \
	src/segments.c \
	src/sub.c \
	src/luagrapheme.c

HDR = \
	src/luagrapheme.h

LUASRC = \
	src/lpeg_ext.lua


all: $(SONAME)

install: $(SONAME) $(LUASRC)
	mkdir -p $(INST_LIBDIR)
	cp -f $(SONAME) $(INST_LIBDIR)/$(SONAME)
	mkdir -p $(INST_LUADIR)/luagrapheme
	for file in $(LUASRC); do \
		mkdir -p $(INST_LUADIR)/luagrapheme/$$(dirname $${file#src/}); \
		cp -f $$file $(INST_LUADIR)/luagrapheme/$${file#src/}; \
	done

clean:
	$(RM) -f $(ANAME) $(SONAME) $(SRC:.c=.o)

format: format-stylua format-clang-format

format-stylua:
	stylua spec/ *.rockspec

format-clang-format:
	$(CLANG_FORMAT) -i $(SRC) $(HDR)

lint: lint-luacheck lint-stylua lint-clang-format

lint-luacheck:
	$(LUACHECK) .

lint-stylua:
	$(STYLUA) --check spec/ *.rockspec

lint-clang-format:
	$(CLANG_FORMAT) --dry-run -Werror $(SRC) $(HDR)

test:
	$(BUSTED) $(BUSTEDFLAGS)

$(SONAME): $(SRC:.c=.o)
	$(CC) -o $@ $(SRC:.c=.o) $(LDFLAGS)

src/case.o: src/case.c src/luagrapheme.h makefile config.mk
src/is_segment_break.o: src/is_segment_break.c src/luagrapheme.h src/utf8.h makefile config.mk
src/count_segments.o: src/count_segments.c src/luagrapheme.h makefile config.mk
src/match_n_segments.o: src/match_n_segments.c src/luagrapheme.h src/utf8.h makefile config.mk
src/match_oneof_graphemes.o: src/match_oneof_graphemes.c src/luagrapheme.h src/utf8.h makefile config.mk
src/reverse.o: src/reverse.c src/luagrapheme.h makefile config.mk
src/segment_breaks.o: src/segment_breaks.c src/luagrapheme.h makefile config.mk
src/segments.o: src/segments.c src/luagrapheme.h makefile config.mk
src/sub.o: src/sub.c src/luagrapheme.h makefile config.mk
src/luagrapheme.o: src/luagrapheme.c src/luagrapheme.h makefile config.mk

$(SRC:.c=.o):
	$(CC) -c -o $@ $(CFLAGS) $(@:.o=.c)

.PHONY: all install clean format format-stylua format-clang-format lint lint-luacheck lint-stylua lint-clang-format test
