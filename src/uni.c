#include <assert.h>
#include <stdlib.h>
#include <string.h>

#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>

#include <compat-5.3.h>
#include <grapheme.h>

int uni_lower(lua_State *L)
{
    luaL_argcheck(L, lua_isstring(L, 1), 1, "string expected");

    // Retrieve the source string and its length
    size_t srclen;
    const char *src = lua_tolstring(L, 1, &srclen);

    // Calculate the length of the destination string with the null terminator
    // NOTE: `grapheme_to_lowercase_utf8` expects to place a null terminator at
    // the end of the destination buffer, but does *not* expect one at the end
    // of the source buffer.
    size_t destlen = grapheme_to_lowercase_utf8(src, srclen, NULL, 0) + 1;

    // Prepare the destination buffer
    luaL_Buffer b;
    char *dest = luaL_buffinitsize(L, &b, destlen);

    // Convert the source string to lowercase
    grapheme_to_lowercase_utf8(src, srclen, dest, destlen);

    // Push the destination string onto the stack without the null terminator
    luaL_pushresultsize(&b, destlen - 1);

    return 1;
}

typedef int(uni_foreach_grapheme_callback)(const char *str, size_t len,
    size_t off, size_t ret, void *state);

static void uni_foreach_grapheme(const char *str, size_t len, void *state,
    uni_foreach_grapheme_callback *fn)
{
    size_t off, ret;
    int stop = 0;
    for (off = 0; off < len && !stop; off += ret) {
        ret = grapheme_next_character_break_utf8(str + off, len - off);
        stop = fn(str, len, off, ret, state);
    }
}

static uni_foreach_grapheme_callback uni_len_callback;

static int uni_len_callback(const char *str, size_t len, size_t off, size_t ret,
    void *state)
{
    size_t *grapheme_len = (size_t *)state;
    (*grapheme_len)++;
    return 0;
}

int uni_len(lua_State *L)
{
    luaL_argcheck(L, lua_isstring(L, 1), 1, "string expected");

    // Retrieve the source string and its length
    size_t byte_len;
    const char *str = lua_tolstring(L, 1, &byte_len);

    // Call helper to count graphemes
    size_t grapheme_len = 0;
    uni_foreach_grapheme(str, byte_len, &grapheme_len, uni_len_callback);

    // Push the number of graphemes onto the stack
    lua_pushinteger(L, grapheme_len);

    return 1;
}

static uni_foreach_grapheme_callback uni_reverse_callback;

static int uni_reverse_callback(const char *str, size_t len, size_t off,
    size_t ret, void *state)
{
    char *dest = (char *)state;
    assert(len >= off + ret);
    memcpy(dest + len - off - ret, str + off, ret);
    return 0;
}

int uni_reverse(lua_State *L)
{
    luaL_argcheck(L, lua_isstring(L, 1), 1, "string expected");

    size_t srclen;
    const char *src = lua_tolstring(L, 1, &srclen);

    // TODO: Verify if the destination is always the same size as the source.
    size_t destlen = srclen;

    // Prepare the destination buffer
    luaL_Buffer b;
    char *dest = luaL_buffinitsize(L, &b, destlen);

    // Call helper to reverse the string
    uni_foreach_grapheme(src, srclen, dest, uni_reverse_callback);

    // Push the destination string onto the stack without the null terminator
    luaL_pushresultsize(&b, destlen);

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

    lua_pushcclosure(L, uni_reverse, 0);
    lua_setfield(L, -2, "reverse");

    return 1;
}
