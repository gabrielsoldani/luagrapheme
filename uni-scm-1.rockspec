rockspec_format = "3.0"
package = "uni"
version = "scm-1"
source = {
   url = "git+https://github.com/gabrielsoldani/uni.git"
}

description = {
   summary = "Unicode-aware text manipulation library.",
   detailed = [[
      Unicode-aware text manipulation library.
   ]],
   license = "UNLICENSED",
   homepage = "https://github.com/gabrielsoldani/uni",
   issues_url = "https://github.com/gabrielsoldani/uni/issues",
   maintainer = "Gabriel Soldani <gabriel@gabrielsoldani.com>",
   labels = { "unicode", "grapheme", "text", "utf-8" }
}

dependencies = {
   "lua >= 5.1, <= 5.4"
}

external_dependencies = {
   GRAPHEME = {
      header = "grapheme.h",
      library = "grapheme",
   }
}

build_dependencies = {
   "luarocks-build-extended"
}

build = {
   type = "extended",
   modules = {
      ["uni"] = {
         sources = { "vendor/lua-compat-5.3/compat-5.3.c", "src/uni.c" },
         libraries = { "grapheme" },
         defines = {},
         incdirs = { "vendor/lua-compat-5.3", "$(GRAPHEME_INCDIR)" },
         libdirs = { "$(GRAPHEME_LIBDIR)" },
         variables = {
            CFLAG_EXTRAS = {
               "-Wall", "-Werror", "-pedantic"
            }
         }
      }
   }
}

test_dependencies = {
   "busted ~> 2.1",
   "compat53 >= 0.11, < 0.12"
}

test = {
   type = "busted"
}
