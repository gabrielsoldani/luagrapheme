#include "luagrapheme.h"
#include "utf8.h"

#include <grapheme.h>

static inline int is_segment_break(lua_State *L, next_segment_break_fn next_segment_break)
{
    // Retrieve the string and its length
    size_t byte_len;
    const char *str = luaL_checklstring(L, 1, &byte_len);

    // Retrieve the byte index, 1-based.
    lua_Integer byte_index = luaL_checkinteger(L, 2);

    // Bounds check, but allow indexing 1 past the end of the string.
    luaL_argcheck(L, byte_index >= 1 && (size_t)byte_index <= byte_len + 1, 2, "index out of range");

    // Correct for 0-based indexing
    size_t offset = (size_t)byte_index - 1;

    // Fast path: 1 past the end of the string is always a segment break.
    if (offset == byte_len) {
        lua_pushboolean(L, 1);
        return 1;
    }

    // Fast path: if we're in the middle of a codepoint, it can't be a segment
    // break.
    if (is_utf8_continuation_byte(str[offset])) {
        lua_pushboolean(L, 0);
        return 1;
    }

    // Otherwise, advance linearly until we reach the desired offset.
    size_t break_offset = 0;
    for (size_t inc; break_offset < offset; break_offset += inc) {
        inc = next_segment_break(str + break_offset, byte_len - break_offset);
    }

    // Two cases follow: either we've reached the desired offset, so it's a
    // segment break, or we've gone past it, so it's not.
    lua_pushboolean(L, break_offset == offset);

    return 1;
}

int is_grapheme_break(lua_State *L)
{
    return is_segment_break(L, grapheme_next_character_break_utf8);
}

int is_line_break(lua_State *L)
{
    return is_segment_break(L, grapheme_next_line_break_utf8);
}

int is_word_break(lua_State *L)
{
    return is_segment_break(L, grapheme_next_word_break_utf8);
}

int is_sentence_break(lua_State *L)
{
    return is_segment_break(L, grapheme_next_sentence_break_utf8);
}
