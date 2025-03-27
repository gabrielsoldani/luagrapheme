#include "luagrapheme.h"

#include <grapheme.h>

static inline int segment_breaks_iter(lua_State *L, next_segment_break_fn next_segment_break)
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

    // Find the next segment break
    size_t inc = next_segment_break(str + off, byte_len - off);

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

static int grapheme_breaks_iter(lua_State *L)
{
    return segment_breaks_iter(L, grapheme_next_character_break_utf8);
}

static int line_breaks_iter(lua_State *L)
{
    return segment_breaks_iter(L, grapheme_next_line_break_utf8);
}

static int word_breaks_iter(lua_State *L)
{
    return segment_breaks_iter(L, grapheme_next_word_break_utf8);
}

static int sentence_breaks_iter(lua_State *L)
{
    return segment_breaks_iter(L, grapheme_next_sentence_break_utf8);
}

static inline int segment_breaks(lua_State *L, lua_CFunction iter_fn)
{
    (void)luaL_checkstring(L, 1);
    lua_pushnil(L); // initial byte offset
    lua_pushcclosure(L, iter_fn, 2);
    return 1;
}

int grapheme_breaks(lua_State *L)
{
    return segment_breaks(L, grapheme_breaks_iter);
}

int line_breaks(lua_State *L)
{
    return segment_breaks(L, line_breaks_iter);
}

int word_breaks(lua_State *L)
{
    return segment_breaks(L, word_breaks_iter);
}

int sentence_breaks(lua_State *L)
{
    return segment_breaks(L, sentence_breaks_iter);
}
