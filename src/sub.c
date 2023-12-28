#include "uni.h"

#include <grapheme.h>

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

    ASSERT_UNREACHABLE();
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

static size_t c_graphemes_sub(const char * restrict src, size_t src_len, char * restrict dest, size_t dest_len,
    size_t start, size_t end)
{
    assert(start <= end);

    size_t pos = 1;

    // Skip over graphemes until we reach the start position
    size_t src_off = 0;
    while (pos < start && src_off < src_len) {
        size_t inc = grapheme_next_character_break_utf8(src + src_off, src_len - src_off);
        src_off += inc;
        pos++;
    }

    // Copy graphemes until we reach the end position
    size_t dest_off = 0;
    while (pos <= end && src_off < src_len && dest_off < dest_len) {
        size_t inc = grapheme_next_character_break_utf8(src + src_off, src_len - src_off);
        if (dest != NULL) {
            memcpy(dest + dest_off, src + src_off, inc);
        }
        src_off += inc;
        dest_off += inc;
        pos++;
    }

    return dest_off;
}

int graphemes_sub(lua_State *L)
{
    size_t byte_len;
    const char *src = luaL_checklstring(L, 1, &byte_len);

    size_t grapheme_count = c_count_graphemes(src, byte_len);

    size_t start = normalize_start_pos(luaL_checkinteger(L, 2), grapheme_count);
    size_t end = normalize_end_pos(luaL_optinteger(L, 3, -1), grapheme_count);

    if (start > end) {
        lua_pushliteral(L, "");
        return 1;
    }

    // Null pass to determine the length of the substring
    size_t dest_len = c_graphemes_sub(src, byte_len, NULL, SIZE_MAX, start, end);

    luaL_Buffer b;
    char *dest = luaL_buffinitsize(L, &b, dest_len);

    // Effectively copy the substring into the buffer
    size_t copied_len = c_graphemes_sub(src, byte_len, dest, dest_len, start, end);

    assert(copied_len == dest_len);

    luaL_pushresultsize(&b, dest_len);
    return 1;
}
