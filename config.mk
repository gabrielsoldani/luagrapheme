# Target configuration
SONAME = uni.so

# Compiler
CC = cc
CFLAGS_BASE = -std=c99 -Wall -Werror -pedantic
CFLAGS_EXTRA = -O2 -fPIC
LDFLAGS_EXTRA = -shared

# Lua paths
LUA_BINDIR = /usr/local/bin
LUA_INCDIR = /usr/local/include
LUA = lua5.4

# Grapheme paths
GRAPHEME_LIBDIR = /usr/local/lib
GRAPHEME_INCDIR = /usr/local/include

# Install
INST_PREFIX = /usr/local
INST_BINDIR = $(INST_PREFIX)/bin
INST_LIBDIR = $(INST_PREFIX)/lib/lua/5.4
INST_LUADIR = $(INST_PREFIX)/share/lua/5.4
INST_CONFDIR = $(INST_PREFIX)/etc

# Test
BUSTED = busted
BUSTEDFLAGS = -Xoutput "--color"

# Miscellaneous
RM = rm
CP = cp
LUACHECK = luacheck
