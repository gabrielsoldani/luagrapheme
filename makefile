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
	$(LIBGRAPHEME_LDFLAGS) \
	$(LDFLAGS)

SRC = \
	c_src/case.c \
	c_src/luagrapheme.c \
	c_src/segments.c

HDR = \
	c_src/luagrapheme.h

all: $(SONAME)

install: all
	$(MKDIR) -p $(DESTDIR)$(INST_LIBDIR)
	$(CP) -f $(SONAME) $(DESTDIR)$(INST_LIBDIR)/$(SONAME)
	$(MKDIR) -p $(DESTDIR)$(INST_LUADIR)/luagrapheme
	$(CP) -Rf lua_src/. $(DESTDIR)$(INST_LUADIR)/luagrapheme

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

c_src/case.$(O): c_src/case.c c_src/luagrapheme.h makefile config.mk
c_src/luagrapheme.$(O): c_src/luagrapheme.c c_src/luagrapheme.h makefile config.mk
c_src/segments.$(O): c_src/segments.c c_src/luagrapheme.h makefile config.mk

$(SRC:.c=.$(O)):
	$(CC) -c -o $@ $(ALL_CFLAGS) $(@:.$(O)=.c)

.PHONY: all install uninstall clean format format-stylua format-clang-format lint lint-luacheck lint-stylua lint-clang-format test
