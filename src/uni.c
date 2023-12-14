#include <assert.h>
#include <stdlib.h>
#include <string.h>

#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>

#include <compat-5.3.h>
#include <grapheme.h>

static int uni_lower(lua_State *L)
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

static int uni_upper(lua_State *L)
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

static int uni_len(lua_State *L)
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

static int uni_reverse(lua_State *L)
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

static inline size_t normalize_start_pos(lua_Integer pos, size_t len)
{
    if (pos > 0) {
        return (size_t)pos;
    }
    else if (pos == 0) {
        return 1;
    }
    else if (pos < -(lua_Integer)len) {
        return 1;
    }
    else if (pos < 0) {
        return (size_t)(len + pos + 1);
    }
    assert(!"unreachable");
}

static inline size_t normalize_end_pos(lua_Integer pos, size_t len)
{
    if (pos > (lua_Integer)len) {
        return len;
    }
    else if (pos >= 0) {
        return pos;
    }
    else if (pos < -(lua_Integer)len) {
        return 0;
    }
    else if (pos < 0) {
        return len + pos + 1;
    }
    assert(!"unreachable");
}

static size_t s_grapheme_sub(const char * restrict src, size_t src_len, char * restrict dest, size_t dest_len,
    size_t start, size_t end)
{
    assert(start <= end);

    size_t i = 1;

    // Count graphemes until we reach the start position
    size_t src_off = 0;
    while (i < start && src_off < src_len) {
        size_t inc = grapheme_next_character_break_utf8(src + src_off, src_len - src_off);
        src_off += inc;
        i++;
    }

    // Copy graphemes until we reach the end position (or the buffers end)
    size_t dest_off = 0;
    while (i <= end && src_off < src_len && dest_off < dest_len) {
        size_t inc = grapheme_next_character_break_utf8(src + src_off, src_len - src_off);
        if (dest != NULL) {
            memcpy(dest + dest_off, src + src_off, inc);
        }
        src_off += inc;
        dest_off += inc;
        i++;
    }

    return dest_off;
}

static int uni_sub(lua_State *L)
{
    luaL_argcheck(L, lua_isstring(L, 1), 1, "string expected");
    luaL_argcheck(L, lua_isinteger(L, 2), 2, "integer expected");
    luaL_argcheck(L, lua_isinteger(L, 3) || lua_isnoneornil(L, 3), 3, "integer or nil expected");

    // Retrieve the source string and its length
    size_t byte_len;
    const char *src = lua_tolstring(L, 1, &byte_len);

    // Count graphemes. This is necessary to normalize the start and end positions.
    size_t grapheme_len = s_grapheme_len(src, byte_len);

    // Retrieve the start and end positions
    size_t start = normalize_start_pos(lua_tointeger(L, 2), grapheme_len);
    size_t end = normalize_end_pos(lua_isnoneornil(L, 3) ? -1 : lua_tointeger(L, 3), grapheme_len);

    // Bail out if the start offset is greater than the end offset
    if (start > end) {
        lua_pushliteral(L, "");
        return 1;
    }

    // First pass: determine the length of the substring
    size_t dest_len = s_grapheme_sub(src, byte_len, NULL, SIZE_MAX, start, end);

    // Prepare the destination buffer
    luaL_Buffer b;
    char *dest = luaL_buffinitsize(L, &b, dest_len);

    // Second pass: copy the substring into the destination buffer
    s_grapheme_sub(src, byte_len, dest, dest_len, start, end);

    // Push the destination string onto the stack
    luaL_pushresultsize(&b, dest_len);

    return 1;
}

static int uni_graphemes_next(lua_State *L)
{
    // Retrieve the iterated over string and its length
    size_t byte_len;
    const char *str = lua_tolstring(L, lua_upvalueindex(1), &byte_len);

    // Retrieve the byte offset for the next iteration
    lua_Integer off = lua_tointeger(L, lua_upvalueindex(2));

    if (off >= byte_len) {
        // The iterator is exhausted
        lua_pushnil(L);
        return 1;
    }

    size_t inc = grapheme_next_character_break_utf8(str + off, byte_len - off);

    if (inc == 0) {
        // The iterator is exhausted
        lua_pushnil(L);
        return 1;
    }

    // Update the byte offset for the next iteration
    lua_pushinteger(L, off + inc);
    lua_replace(L, lua_upvalueindex(2));

    // Push the next grapheme onto the stack
    lua_pushlstring(L, str + off, inc);

    return 1;
}

static int uni_graphemes(lua_State *L)
{
    luaL_argcheck(L, lua_isstring(L, 1), 1, "string expected");

    // Byte offset for the next iteration
    lua_pushinteger(L, 0);

    // Push the iterator, closed over the string and the byte offset
    lua_pushcclosure(L, uni_graphemes_next, 2);

    return 1;
}

static int uni_grapheme_breaks_next(lua_State *L)
{
    // Retrieve the iterated over string and its length
    size_t byte_len;
    const char *str = lua_tolstring(L, lua_upvalueindex(1), &byte_len);

    // First iteration
    if (lua_isnoneornil(L, lua_upvalueindex(2))) {
        // If the string is empty, the iterator is immediately exhausted
        if (byte_len == 0) {
            lua_pushnil(L);
            return 1;
        }

        // Otherwise, the first break is at the beginning of the string
        lua_pushinteger(L, 0);
        lua_replace(L, lua_upvalueindex(2));

        lua_pushinteger(L, 1);
        return 1;
    }

    // Second and subsequent iterations

    // Retrieve the byte offset for the next iteration
    lua_Integer off = lua_tointeger(L, lua_upvalueindex(2));

    // Check if the iterator is exhausted
    if (off >= byte_len) {
        lua_pushnil(L);
        return 1;
    }

    // Find the next grapheme break
    size_t inc = grapheme_next_character_break_utf8(str + off, byte_len - off);

    off += inc;

    // Check if the iterator is exhausted
    if (off >= byte_len) {
        lua_pushnil(L);
        return 1;
    }

    // Update the byte offset for the next iteration
    lua_pushinteger(L, off);
    lua_replace(L, lua_upvalueindex(2));

    // Push the result, corrected for 1-based indexing
    lua_pushinteger(L, off + 1);

    return 1;
}

static int uni_grapheme_breaks(lua_State *L)
{
    (void)luaL_checkstring(L, 1);
    lua_pushnil(L); // initial byte offset
    lua_pushcclosure(L, uni_grapheme_breaks_next, 2);
    return 1;
}

static luaL_Reg funcs[] = {
    {          "lower",           uni_lower},
    {          "upper",           uni_upper},
    {            "len",             uni_len},
    {        "reverse",         uni_reverse},
    {            "sub",             uni_sub},
    {"grapheme_breaks", uni_grapheme_breaks},
    {      "graphemes",       uni_graphemes},
    {             NULL,                NULL}
};

int luaopen_uni(lua_State *L)
{
    lua_newtable(L);

    lua_pushliteral(L, VERSION);
    lua_setfield(L, -2, "_VERSION");

    luaL_setfuncs(L, funcs, 0);

    return 1;
}
