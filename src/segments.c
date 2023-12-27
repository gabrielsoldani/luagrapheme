#include "uni.h"

#include <grapheme.h>

static inline int segments_iter(lua_State *L, next_segment_break_fn next_segment_break)
{
    // Retrieve the iterated over string and its length
    size_t byte_len;
    const char *str = lua_tolstring(L, lua_upvalueindex(1), &byte_len);

    // Retrieve the byte offset for the next iteration
    size_t off = (size_t)lua_tointeger(L, lua_upvalueindex(2));

    // Check if the iterator is exhausted
    if (off >= byte_len) {
        lua_pushnil(L);
        return 1;
    }

    size_t inc = next_segment_break(str + off, byte_len - off);

    // Update the byte offset for the next iteration
    lua_pushinteger(L, off + inc);
    lua_replace(L, lua_upvalueindex(2));

    // Push the next segment onto the stack
    lua_pushlstring(L, str + off, inc);

    return 1;
}

static int graphemes_iter(lua_State *L)
{
    return segments_iter(L, grapheme_next_character_break_utf8);
}

static int lines_iter(lua_State *L)
{
    return segments_iter(L, grapheme_next_line_break_utf8);
}

static int words_iter(lua_State *L)
{
    return segments_iter(L, grapheme_next_word_break_utf8);
}

static int sentences_iter(lua_State *L)
{
    return segments_iter(L, grapheme_next_sentence_break_utf8);
}

static inline int segments(lua_State *L, lua_CFunction iter_fn)
{
    (void)luaL_checkstring(L, 1);
    // Byte offset for the next iteration
    lua_pushinteger(L, 0);

    // Push the iterator, closed over the string and the byte offset
    lua_pushcclosure(L, iter_fn, 2);

    return 1;
}

int graphemes(lua_State *L)
{
    return segments(L, graphemes_iter);
}

int lines(lua_State *L)
{
    return segments(L, lines_iter);
}

int words(lua_State *L)
{
    return segments(L, words_iter);
}

int sentences(lua_State *L)
{
    return segments(L, sentences_iter);
}
