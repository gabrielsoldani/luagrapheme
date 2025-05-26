# Version information
LUAGRAPHEME_VERSION = scm

# Library name
SONAME = luagrapheme.$(SO)

# Paths
LUA = lua
LUA_BINDIR =  /Users/gabriel/.asdf/installs/lua/5.4.6/bin
LUA_LIBDIR =  /Users/gabriel/.asdf/installs/lua/5.4.6/lib
LUA_INCDIR =  /Users/gabriel/.asdf/installs/lua/5.4.6/include

# libgrapheme paths
GRAPHEME_LIBDIR = /opt/homebrew/lib
GRAPHEME_INCDIR = /opt/homebrew/include

# Install paths
INST_PREFIX = /Users/gabriel/.asdf/installs/lua/5.4.6
INST_BINDIR = $(INST_PREFIX)/bin
INST_LIBDIR = $(INST_PREFIX)/lib
INST_LUADIR = $(INST_PREFIX)/lua/5.4

# Flags
CFLAGS_EXTRA =
LDFLAGS_EXTRA = -bundle -undefined dynamic_lookup
BUSTEDFLAGS = -Xoutput "--color"

# Extensions
SO = so
O = o

# Tools
CP = cp
MKDIR = mkdir
RM = rm
CC = c99
LD = gcc
BUSTED = busted
LUACHECK = luacheck
STYLUA = stylua
CLANG_FORMAT = clang-format
