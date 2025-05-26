// clang-format Language: C
#ifndef LUAGRAPHEME_H
#define LUAGRAPHEME_H

#include <assert.h>
#include <stdlib.h>
#include <string.h>

#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>

#include <compat-5.3.h>

int case_lower(lua_State *L);
int case_upper(lua_State *L);
int case_title(lua_State *L);

int graphemes_open(lua_State *L);
int lines_open(lua_State *L);
int sentences_open(lua_State *L);
int words_open(lua_State *L);

#define ASSERT_UNREACHABLE() assert(!"unreachable")

#endif // LUAGRAPHEME_H
