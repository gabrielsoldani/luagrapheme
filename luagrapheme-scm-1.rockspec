local package_version = "scm"
local rockspec_revision = "1"

rockspec_format = "3.0"
package = "luagrapheme"
version = package_version .. "-" .. rockspec_revision
source = {
   url = "git+https://github.com/gabrielsoldani/luagrapheme.git",
}

description = {
   summary = "Unicode-aware text manipulation library.",
   detailed = [[
      Unicode-aware text manipulation library.
   ]],
   license = "UNLICENSED",
   homepage = "https://github.com/gabrielsoldani/luagrapheme",
   issues_url = "https://github.com/gabrielsoldani/luagrapheme/issues",
   maintainer = "Gabriel Soldani <gabriel@gabrielsoldani.com>",
   labels = { "unicode", "grapheme", "text", "utf-8" },
}

dependencies = {
   "lua >= 5.1, <= 5.4",
}

external_dependencies = {
   LIBGRAPHEME = {
      header = "grapheme.h",
      library = "grapheme",
   },
}

build_dependencies = {}

build = {
   type = "make",
   variables = {
      SO = "$(LIB_EXTENSION)",
   },
   build_variables = {
      O = "$(OBJ_EXTENSION)",
      LUAGRAPHEME_VERSION = package_version,
      CC = "$(CC)",
      LD = "$(LD)",
      CFLAGS = "$(CFLAGS)",
      LDFLAGS = "$(LIBFLAG)",
      LUA_DIR = "$(LUA_DIR)",
      LUA_BINDIR = "$(LUA_BINDIR)",
      LUA_INCDIR = "$(LUA_INCDIR)",
      LIBGRAPHEME_DIR = "$(LIBGRAPHEME_DIR)",
      LIBGRAPHEME_LIBDIR = "$(LIBGRAPHEME_LIBDIR)",
      LIBGRAPHEME_INCDIR = "$(LIBGRAPHEME_INCDIR)",
   },
   install_variables = {
      CP = "$(CP)",
      MKDIR = "$(MKDIR)",
      RM = "$(RM)",
      PREFIX = "$(PREFIX)",
      BINDIR = "$(BINDIR)",
      LIBDIR = "$(LIBDIR)",
      LUADIR = "$(LUADIR)",
   },
}

test_dependencies = {
   "busted >= 2.1, <= 3.0",
   "compat53 >= 0.11, <= 1.0",
   "lpeg >= 1.1, <= 2.0",
}

test = {
   type = "busted",
}
