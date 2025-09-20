# Version information
LUAGRAPHEME_VERSION = scm

# Library name
SONAME = luagrapheme.$(SO)

# Paths
LUA_DIR = /usr/local
LUA_BINDIR = $(LUA_DIR)/bin
LUA_INCDIR = $(LUA_DIR)/include

# libgrapheme paths
LIBGRAPHEME_DIR = /usr/local
LIBGRAPHEME_LIBDIR = $(LIBGRAPHEME_DIR)/lib
LIBGRAPHEME_INCDIR = $(LIBGRAPHEME_DIR)/include

# libgrapheme static linking (comment out if dynamic linking)
LIBGRAPHEME_LDFLAGS = $(LIBGRAPHEME_LIBDIR)/libgrapheme.a

# libgrapheme dynamic linking (comment out if static linking)
# LIBGRAPHEME_LDFLAGS = -L$(LIBGRAPHEME_LIBDIR) -lgrapheme

# Install paths
LUA_VERSION = 5.4
DESTDIR =
INST_PREFIX = /usr/local
INST_LIBDIR = $(INST_PREFIX)/lib
INST_LUADIR = $(INST_PREFIX)/share/lua/$(LUA_VERSION)

# Flags
CFLAGS = -std=c99 -pedantic -O2 -fPIC -Wall -Wextra -Werror
LDFLAGS = -shared
BUSTEDFLAGS = -Xoutput "--color"

# Extensions
SO = so
O = o

# Tools
CP = cp
MKDIR = mkdir
RM = rm
CC = gcc
LD = ld
BUSTED = busted
LUACHECK = luacheck
STYLUA = stylua
CLANG_FORMAT = clang-format
