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
    size_t src_len;
    const char *src = lua_tolstring(L, 1, &src_len);

    // Calculate the length of the destination string with the null terminator
    // NOTE: `grapheme_to_lowercase_utf8` expects to place a null terminator at
    // the end of the destination buffer, but does *not* expect one at the end
    // of the source buffer.
    size_t dest_len = grapheme_to_lowercase_utf8(src, src_len, NULL, 0) + 1;

    // Prepare the destination buffer
    luaL_Buffer b;
    char *dest = luaL_buffinitsize(L, &b, dest_len);

    // Convert the source string to lowercase
    grapheme_to_lowercase_utf8(src, src_len, dest, dest_len);

    // Push the destination string onto the stack without the null terminator
    luaL_pushresultsize(&b, dest_len - 1);

    return 1;
}

int uni_upper(lua_State *L)
{
    luaL_argcheck(L, lua_isstring(L, 1), 1, "string expected");

    // Retrieve the source string and its length
    size_t src_len;
    const char *src = lua_tolstring(L, 1, &src_len);

    // Calculate the length of the destination string with the null terminator
    // NOTE: `grapheme_to_uppercase_utf8` expects to place a null terminator at
    // the end of the destination buffer, but does *not* expect one at the end
    // of the source buffer.
    size_t dest_len = grapheme_to_uppercase_utf8(src, src_len, NULL, 0) + 1;

    // Prepare the destination buffer
    luaL_Buffer b;
    char *dest = luaL_buffinitsize(L, &b, dest_len);

    // Convert the source string to uppercase
    grapheme_to_uppercase_utf8(src, src_len, dest, dest_len);

    // Push the destination string onto the stack without the null terminator
    luaL_pushresultsize(&b, dest_len - 1);

    return 1;
}

static inline size_t s_grapheme_len(const char *str, size_t byte_len)
{
    size_t grapheme_len = 0;
    for (size_t offset = 0, inc; offset < byte_len; offset += inc) {
        inc = grapheme_next_character_break_utf8(str + offset, byte_len - offset);
        grapheme_len++;
    }
    return grapheme_len;
}

int uni_len(lua_State *L)
{
    luaL_argcheck(L, lua_isstring(L, 1), 1, "string expected");

    // Retrieve the source string and its length
    size_t byte_len;
    const char *str = lua_tolstring(L, 1, &byte_len);

    // Count graphemes
    size_t grapheme_len = s_grapheme_len(str, byte_len);

    // Push the number of graphemes onto the stack
    lua_pushinteger(L, grapheme_len);

    return 1;
}

int uni_reverse(lua_State *L)
{
    luaL_argcheck(L, lua_isstring(L, 1), 1, "string expected");

    // Retrieve the source string and its length
    size_t byte_len;
    const char *src = lua_tolstring(L, 1, &byte_len);

    // Prepare the destination buffer
    luaL_Buffer b;
    char *dest = luaL_buffinitsize(L, &b, byte_len);

    // Iterate over the source string
    for (size_t offset = 0, inc; offset < byte_len; offset += inc) {
        inc = grapheme_next_character_break_utf8(src + offset, byte_len - offset);

        // Copy to the end of the destination buffer
        memcpy(dest + byte_len - offset - inc, src + offset, inc);
    }

    // Push the destination string onto the stack
    luaL_pushresultsize(&b, byte_len);

    return 1;
}

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

    lua_pushcclosure(L, uni_upper, 0);
    lua_setfield(L, -2, "upper");

    lua_pushcclosure(L, uni_len, 0);
    lua_setfield(L, -2, "len");

    lua_pushcclosure(L, uni_reverse, 0);
    lua_setfield(L, -2, "reverse");

    return 1;
}
