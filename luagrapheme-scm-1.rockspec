rockspec_format = "3.0"
package = "luagrapheme"
version = "scm-1"
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
   GRAPHEME = {
      header = "grapheme.h",
      library = "grapheme",
   },
}

build_dependencies = {}

build = {
   type = "make",
   build_variables = {
      CFLAGS_EXTRA = "$(CFLAGS)",
      LDFLAGS_EXTRA = "$(LIBFLAG)",
      LUA_BINDIR = "$(LUA_BINDIR)",
      LUA_INCDIR = "$(LUA_INCDIR)",
      LUA = "$(LUA)",
      GRAPHEME_LIBDIR = "$(GRAPHEME_LIBDIR)",
      GRAPHEME_INCDIR = "$(GRAPHEME_INCDIR)",
   },
   install_variables = {
      INST_PREFIX = "$(PREFIX)",
      INST_BINDIR = "$(BINDIR)",
      INST_LIBDIR = "$(LIBDIR)",
      INST_LUADIR = "$(LUADIR)",
      INST_CONFDIR = "$(CONFDIR)",
   },
}

test_dependencies = {
   "busted ~> 2.1",
   "compat53 >= 0.11, < 0.12",
   "lpeg ~> 1.1",
}

test = {
   type = "command",
   command = "make",
   flags = { "test" },
}
