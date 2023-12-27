#include "uni.h"

#include <assert.h>
#include <stdlib.h>
#include <string.h>

#include <grapheme.h>

static int uni_reverse(lua_State *L)
{
    // Retrieve the source string and its length
    size_t byte_len;
    const char *src = luaL_checklstring(L, 1, &byte_len);

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

    ASSERT_UNREACHABLE();
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
    // Retrieve the source string and its length
    size_t byte_len;
    const char *src = luaL_checklstring(L, 1, &byte_len);

    // Count graphemes. This is necessary to normalize the start and end positions.
    size_t grapheme_len = c_count_graphemes(src, byte_len);

    // Retrieve the start and end positions
    size_t start = normalize_start_pos(luaL_checkinteger(L, 2), grapheme_len);
    size_t end = normalize_end_pos(luaL_optinteger(L, 3, -1), grapheme_len);

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

static luaL_Reg funcs[] = {
    {                  "lower",                  lower},
    {                  "upper",                  upper},
    {                    "len",        count_graphemes},
    {      "is_grapheme_break",      is_grapheme_break},
    {     "_match_n_graphemes",      match_n_graphemes},
    {"_match_one_of_graphemes", match_one_of_graphemes},
    {        "grapheme_breaks",        grapheme_breaks},
    {              "graphemes",              graphemes},
    {                "reverse",            uni_reverse},
    {                    "sub",                uni_sub},
    {                     NULL,                   NULL}
};

int luaopen_uni(lua_State *L)
{
    lua_newtable(L);

    lua_pushliteral(L, VERSION);
    lua_setfield(L, -2, "_VERSION");

    luaL_setfuncs(L, funcs, 0);

    return 1;
}
