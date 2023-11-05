# Target configuration
SONAME = uni.so

# Compiler
CC = cc
CFLAGS_BASE = -std=c99 -Wall -Werror -pedantic
CFLAGS_EXTRA = -O2 -fPIC
LDFLAGS_EXTRA = -shared

# Lua paths
LUA_BINDIR = /Users/gabriel/.asdf/installs/lua/5.4.6/bin
LUA_INCDIR = /Users/gabriel/.asdf/installs/lua/5.4.6/include
LUA = lua5.4

# Grapheme paths
GRAPHEME_LIBDIR = /opt/homebrew/lib
GRAPHEME_INCDIR = /opt/homebrew/include

# Install
INST_PREFIX = /Users/gabriel/.asdf/installs/lua/5.4.6/luarocks/lib/luarocks/rocks-5.4/uni/scm-1
INST_BINDIR = $(INST_PREFIX)/bin
INST_LIBDIR = $(INST_PREFIX)/lib
INST_LUADIR = $(INST_PREFIX)/lua
INST_CONFDIR = $(INST_PREFIX)/conf

# Test
BUSTED = busted
BUSTEDFLAGS = -Xoutput "--color"

# Miscellaneous
RM = rm
CP = cp
LUACHECK = luacheck
CLANG_FORMAT = clang-format
