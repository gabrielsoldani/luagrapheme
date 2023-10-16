#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include <stdio.h>
#include <stdlib.h>

#include <grapheme.h>

int uni_lower(lua_State *L)
{
    luaL_argcheck(L, lua_isstring(L, 1), 1, "string expected");

    size_t srclen;
    const char *src = lua_tolstring(L, 1, &srclen);

    size_t destlen = grapheme_to_lowercase_utf8(src, srclen, NULL, 0);
    char *dest = malloc(destlen + 1);

    grapheme_to_lowercase_utf8(src, srclen, dest, destlen + 1);
    dest[destlen] = '\0';

    lua_pushlstring(L, dest, destlen);

    free(dest);
    return 1;
}

typedef void(uni_foreach_grapheme_callback)(const char *str, size_t len, void *state);

static void uni_foreach_grapheme(const char *str, size_t len, void *state, uni_foreach_grapheme_callback *fn)
{
    size_t off, ret;
    for (off = 0; off < len; off += ret)
    {
        ret = grapheme_next_character_break_utf8(str + off, len - off);
        fn(str + off, ret, state);
    }
}

static uni_foreach_grapheme_callback uni_len_callback;
static void uni_len_callback(const char *str, size_t len, void *state)
{
    size_t *grapheme_len = (size_t *)state;
    (*grapheme_len)++;
}

int uni_len(lua_State *L)
{
    luaL_argcheck(L, lua_isstring(L, 1), 1, "string expected");

    size_t byte_len;
    const char *str = lua_tolstring(L, 1, &byte_len);

    size_t grapheme_len = 0;

    uni_foreach_grapheme(str, byte_len, &grapheme_len, uni_len_callback);

    lua_pushinteger(L, grapheme_len);
    return 1;
}

int luaopen_uni(lua_State *L)
{
    lua_newtable(L);

    lua_pushliteral(L, "0.1.0");
    lua_setfield(L, -2, "_VERSION");

    lua_pushcclosure(L, uni_lower, 0);
    lua_setfield(L, -2, "lower");

    lua_pushcclosure(L, uni_len, 0);
    lua_setfield(L, -2, "len");

    return 1;
}
