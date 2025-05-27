# Version information
LUAGRAPHEME_VERSION = scm

# Library name
SONAME = luagrapheme.$(SO)

# Paths
DESTDIR =
PREFIX = /usr/local
BINDIR = $(PREFIX)/bin
LIBDIR = $(PREFIX)/lib
INCDIR = $(PREFIX)/include
LUADIR = $(PREFIX)

LUA_VERSION = 5.4
LUA_DIR = $(PREFIX)
LUA_BINDIR =  $(BINDIR)
LUA_LIBDIR =  $(LIBDIR)
LUA_INCDIR =  $(INCDIR)
LUADIR = $(PREFIX)/share/lua/$(LUA_VERSION)

# libgrapheme paths
LIBGRAPHEME_DIR = $(PREFIX)
LIBGRAPHEME_LIBDIR = $(LIBDIR)
LIBGRAPHEME_INCDIR = $(INCDIR)

# Flags
CFLAGS =
LDFLAGS =
BUSTEDFLAGS = -Xoutput "--color"

# Extensions
SO = so
O = o

# Tools
CP = cp
MKDIR = mkdir
RM = rm
CC = c99
LD = ld
BUSTED = busted
LUACHECK = luacheck
STYLUA = stylua
CLANG_FORMAT = clang-format
