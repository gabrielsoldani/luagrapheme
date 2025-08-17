#include "luagrapheme.h"

#include <grapheme.h>

typedef size_t (* const next_segment_break_fn)(const char *, size_t);

static inline int segments_index_after(lua_State *L, next_segment_break_fn next_segment_break)
{
    // Retrieve the string and its length
    size_t len;
    const char *str = luaL_checklstring(L, 1, &len);

    // Retrieve the current index
    const lua_Integer index = luaL_checkinteger(L, 2);
    luaL_argcheck(L, index >= 1, 2, "index out of range");

    // Calculate the 0-based offset of the current index
    size_t offset = (size_t)index - 1;

    // Check that it's within the bounds of the string, allowing the
    // "sentinel" offset at the end of the string
    luaL_argcheck(L, offset <= len, 2, "index out of range");

    // If the offset is at the end of the string, return nil
    if (offset == len) {
        lua_pushnil(L);
        return 1;
    }

    // Find the next segment break
    const size_t inc = next_segment_break(str + offset, len - offset);

    // Return the index of the next segment
    lua_pushinteger(L, index + inc);
    return 1;
}

static inline int segments_iter_next(lua_State *L, next_segment_break_fn next_segment_break)
{
    // Retrieve the iterated over string and its length
    size_t len;
    const char *str = lua_tolstring(L, lua_upvalueindex(1), &len);

    // Retrieve the index of the current segment
    const lua_Integer start = (size_t)lua_tointeger(L, lua_upvalueindex(2));

    // If the iterator is exhausted, end the iteration by returning nil
    if (start >= 1 && (size_t)start > len) {
        lua_pushnil(L);
        return 1;
    }

    const size_t offset = (size_t)(start - 1);

    // Otherwise, find the next segment break
    const size_t inc = next_segment_break(str + offset, len - offset);
    assert(inc > 0);

    // Update the index for the next iteration
    lua_pushinteger(L, start + inc);
    lua_replace(L, lua_upvalueindex(2));

    // Return the start and end indices of the segment
    lua_pushinteger(L, start);
    lua_pushinteger(L, start + inc - 1);

    return 2;
}

static inline int segments_iter(lua_State *L, lua_CFunction iter_fn)
{
    size_t len;
    const char *str = luaL_checklstring(L, 1, &len);

    lua_Integer start;

    // If the second argument is an integer, use it as the starting index and
    // check that it is within the bounds of the string.
    if (lua_isinteger(L, 2)) {
        start = luaL_checkinteger(L, 2);
        luaL_argcheck(L, start >= 1 && (size_t)start <= len, 2, "index out of range");
    }
    // Otherwise, use 1 as the starting index, even if the string is empty.
    else {
        start = 1;
    }

    // Push the next function, closed over the given string and the index of
    // the first segment.
    lua_pushstring(L, str);
    lua_pushinteger(L, start);
    lua_pushcclosure(L, iter_fn, 2);

    // State, control and closing variables are unused.
    return 1;
}

#define FOREACH_SEGMENT_TYPE(DO)                      \
    DO(graphemes, grapheme_next_character_break_utf8) \
    DO(lines, grapheme_next_line_break_utf8)          \
    DO(sentences, grapheme_next_sentence_break_utf8)  \
    DO(words, grapheme_next_word_break_utf8)

#define DEF_SEGMENT_INDEX_AFTER(name, next_segment_break)   \
    static int name##_index_after(lua_State *L)             \
    {                                                       \
        return segments_index_after(L, next_segment_break); \
    }

#define DEF_SEGMENT_ITER_NEXT(name, next_segment_break)   \
    static int name##_iter_next(lua_State *L)             \
    {                                                     \
        return segments_iter_next(L, next_segment_break); \
    }

#define DEF_SEGMENT_ITER(name, next_segment_break) \
    static int name##_iter(lua_State *L)           \
    {                                              \
        return segments_iter(L, name##_iter_next); \
    }

#define DEF_SEGMENT_CALL(name, next_segment_break) \
    static int name##_call(lua_State *L)           \
    {                                              \
        lua_remove(L, 1);                          \
        return name##_iter(L);                     \
    }

#define DEF_SEGMENT_OPEN(name, next_segment_break)                                 \
    static luaL_Reg name##_funcs[] = {                                             \
        {"index_after", name##_index_after}, \
        {       "iter",        name##_iter}, \
        {         NULL,               NULL} \
    }; \
                                                                                   \
    int name##_open(lua_State *L)                                                  \
    {                                                                              \
        lua_newtable(L);                                                           \
        lua_pushvalue(L, -1);                                                      \
        lua_setmetatable(L, -2);                                                   \
        lua_pushcfunction(L, name##_call);                                         \
        lua_setfield(L, -2, "__call");                                             \
        luaL_setfuncs(L, name##_funcs, 0);                                         \
        return 1;                                                                  \
    }

FOREACH_SEGMENT_TYPE(DEF_SEGMENT_INDEX_AFTER)
FOREACH_SEGMENT_TYPE(DEF_SEGMENT_ITER_NEXT)
FOREACH_SEGMENT_TYPE(DEF_SEGMENT_ITER)
FOREACH_SEGMENT_TYPE(DEF_SEGMENT_CALL)
FOREACH_SEGMENT_TYPE(DEF_SEGMENT_OPEN)

#undef DEF_SEGMENT_OPEN
#undef DEF_SEGMENT_CALL
#undef DEF_SEGMENT_ITER
#undef DEF_SEGMENT_ITER_NEXT
#undef DEF_SEGMENT_INDEX_AFTER
#undef FOREACH_SEGMENT_TYPE
