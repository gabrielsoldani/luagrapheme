.POSIX:
.SUFFIXES:

include config.mk

ALL_CFLAGS = \
	-DLUAGRAPHEME_VERSION=\"$(LUAGRAPHEME_VERSION)\" \
	-I$(LUA_INCDIR) \
	-I$(LIBGRAPHEME_INCDIR) \
	-Ivendor/lua-compat-5.3 \
	$(CFLAGS)

ALL_LDFLAGS = \
	-L$(LIBGRAPHEME_LIBDIR) \
	-lgrapheme \
	$(LDFLAGS)

SRC = \
	src/case.c \
	src/luagrapheme.c \
	src/lpeg.c \
	src/segments.c

HDR = \
	src/luagrapheme.h

LUASRC = \
	src/_lpeg.lua

all: $(SONAME)

install: all
	$(MKDIR) -p $(DESTDIR)$(LIBDIR)
	$(CP) -f $(SONAME) $(DESTDIR)$(LIBDIR)/$(SONAME)
	$(MKDIR) -p $(DESTDIR)$(LUADIR)/luagrapheme
	$(CP) -f $(LUASRC) $(DESTDIR)$(LUADIR)/luagrapheme

uninstall:
	$(RM) -f $(INST_LIBDIR)/$(SONAME)
	$(RM) -rf $(INST_LUADIR)/luagrapheme

clean:
	$(RM) -f $(SONAME) $(SRC:.c=.$(O))

format: format-stylua format-clang-format

format-stylua:
	$(STYLUA) .

format-clang-format:
	$(CLANG_FORMAT) -i $(SRC) $(HDR)

lint: lint-luacheck lint-stylua lint-clang-format

lint-luacheck:
	$(LUACHECK) .

lint-stylua:
	$(STYLUA) --check .

lint-clang-format:
	$(CLANG_FORMAT) --dry-run -Werror $(SRC) $(HDR)

test:
	$(BUSTED) $(BUSTEDFLAGS)

$(SONAME): $(SRC:.c=.$(O))
	$(LD) -o $@ $(SRC:.c=.$(O)) $(ALL_LDFLAGS)

src/case.$(O): src/case.c src/luagrapheme.h makefile config.mk
src/luagrapheme.$(O): src/luagrapheme.c src/luagrapheme.h makefile config.mk
src/segments.$(O): src/segments.c src/luagrapheme.h makefile config.mk

$(SRC:.c=.$(O)):
	$(CC) -c -o $@ $(ALL_CFLAGS) $(@:.$(O)=.c)

.PHONY: all install uninstall clean format format-stylua format-clang-format lint lint-luacheck lint-stylua lint-clang-format test
