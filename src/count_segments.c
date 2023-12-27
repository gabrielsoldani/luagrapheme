#include "uni.h"
#include "utf8.h"

#include <grapheme.h>

static inline size_t c_count_segments(const char *str, size_t byte_len, next_segment_break_fn next_segment_break)
{
    size_t count = 0;

    for (size_t offset = 0, inc; offset < byte_len; offset += inc) {
        inc = next_segment_break(str + offset, byte_len - offset);
        count++;
    }

    return count;
}

size_t c_count_graphemes(const char *str, size_t byte_len)
{
    return c_count_segments(str, byte_len, grapheme_next_character_break_utf8);
}

static inline int count_segments(lua_State *L, next_segment_break_fn next_segment_break)
{
    // Retrieve the source string and its length
    size_t byte_len;
    const char *str = luaL_checklstring(L, 1, &byte_len);

    size_t count = c_count_segments(str, byte_len, next_segment_break);

    lua_pushinteger(L, count);
    return 1;
}

int count_graphemes(lua_State *L)
{
    return count_segments(L, grapheme_next_character_break_utf8);
}

int count_lines(lua_State *L)
{
    return count_segments(L, grapheme_next_line_break_utf8);
}

int count_words(lua_State *L)
{
    return count_segments(L, grapheme_next_word_break_utf8);
}

int count_sentences(lua_State *L)
{
    return count_segments(L, grapheme_next_sentence_break_utf8);
}
