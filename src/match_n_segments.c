#include "uni.h"
#include "utf8.h"

#include <grapheme.h>

static inline int match_n_segments_closure(lua_State *L, next_segment_break_fn next_segment_break)
{
    // Retrieve the segment count from the closure
    size_t count = lua_tointeger(L, lua_upvalueindex(1));

    // Retrieve the string and its length
    size_t byte_len;
    const char *str = luaL_checklstring(L, 1, &byte_len);

    // Retrieve the byte index, 1-based.
    lua_Integer start_byte_index = luaL_checkinteger(L, 2);

    // Bounds check, but allow indexing 1 past the end of the string.
    luaL_argcheck(L, start_byte_index >= 1 && (size_t)start_byte_index <= byte_len + 1, 2, "index out of range");

    // Correct for 0-based indexing
    size_t start_offset = (size_t)start_byte_index - 1;

    // Fast path: since every segment is at least 1 byte long, we can avoid
    // counting segments if str[start_offset] is shorter than `count` bytes.
    if (count + start_offset > byte_len) {
        lua_pushboolean(L, 0);
        return 1;
    }

    // Fast path: if we're in the middle of a codepoint, it can't be a segment
    // break.
    if (is_utf8_continuation_byte(str[start_offset])) {
        lua_pushboolean(L, 0);
        return 1;
    }

    // Advance linearly.
    size_t i, offset, inc;
    for (i = 0, offset = start_offset; i < count && offset < byte_len; ++i, offset += inc) {
        inc = next_segment_break(str + offset, byte_len - offset);
    }

    // If we stopped because we reached the end of the string, we don't have
    // enough segments.
    if (i != count) {
        // Return false
        lua_pushboolean(L, 0);
        return 1;
    }

    // Otherwise, `offset` contains the offset of the segment in the string
    // after `count` segments. Convert it to a 1-based index.
    lua_pushinteger(L, offset + 1);
    return 1;
}

static int match_n_graphemes_closure(lua_State *L)
{
    return match_n_segments_closure(L, grapheme_next_character_break_utf8);
}

static int match_n_lines_closure(lua_State *L)
{
    return match_n_segments_closure(L, grapheme_next_line_break_utf8);
}

static int match_n_words_closure(lua_State *L)
{
    return match_n_segments_closure(L, grapheme_next_word_break_utf8);
}

static int match_n_sentences_closure(lua_State *L)
{
    return match_n_segments_closure(L, grapheme_next_sentence_break_utf8);
}

static inline int match_n_segments(lua_State *L, lua_CFunction closure)
{
    // Retrieve the segment count.
    lua_Integer byte_index = luaL_checkinteger(L, 1);

    luaL_argcheck(L, byte_index > 0, 1, "count must be positive");

    lua_pushcclosure(L, closure, 1);
    return 1;
}

int match_n_graphemes(lua_State *L)
{
    return match_n_segments(L, match_n_graphemes_closure);
}

int match_n_lines(lua_State *L)
{
    return match_n_segments(L, match_n_lines_closure);
}

int match_n_words(lua_State *L)
{
    return match_n_segments(L, match_n_words_closure);
}

int match_n_sentences(lua_State *L)
{
    return match_n_segments(L, match_n_sentences_closure);
}
