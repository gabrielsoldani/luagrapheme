#include <assert.h>
#include <stdlib.h>
#include <string.h>

#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>

#include <compat-5.3.h>
#include <grapheme.h>

#define ASSERT_UNREACHABLE() assert(!"unreachable")

static int uni_lower(lua_State *L)
{
    // Retrieve the source string and its length
    size_t src_len;
    const char *src = luaL_checklstring(L, 1, &src_len);

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
    // Retrieve the source string and its length
    size_t src_len;
    const char *src = luaL_checklstring(L, 1, &src_len);

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
    // Retrieve the source string and its length
    size_t byte_len;
    const char *str = luaL_checklstring(L, 1, &byte_len);

    // Count graphemes
    size_t grapheme_len = s_grapheme_len(str, byte_len);

    // Push the number of graphemes onto the stack
    lua_pushinteger(L, grapheme_len);

    return 1;
}

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
    size_t grapheme_len = s_grapheme_len(src, byte_len);

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

static int uni_graphemes_next(lua_State *L)
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

    size_t inc = grapheme_next_character_break_utf8(str + off, byte_len - off);

    // Update the byte offset for the next iteration
    lua_pushinteger(L, off + inc);
    lua_replace(L, lua_upvalueindex(2));

    // Push the next grapheme onto the stack
    lua_pushlstring(L, str + off, inc);

    return 1;
}

static int uni_graphemes(lua_State *L)
{
    (void)luaL_checkstring(L, 1);
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

static inline int is_utf8_continuation_byte(char c)
{
    return (c & 0xC0) == 0x80;
}

static int is_grapheme_break(lua_State *L)
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

    // Fast path: 1 past the end of the string is always a grapheme break.
    if (offset == byte_len) {
        lua_pushboolean(L, 1);
        return 1;
    }

    // Fast path: if we're in the middle of a codepoint, it can't be a grapheme break.
    if (is_utf8_continuation_byte(str[offset])) {
        lua_pushboolean(L, 0);
        return 1;
    }

    // Otherwise, advance linearly until we reach the desired offset.
    size_t break_offset = 0;
    for (size_t inc; break_offset < offset; break_offset += inc) {
        inc = grapheme_next_character_break_utf8(str + break_offset, byte_len - break_offset);
    }

    // Two cases follow: either we've reached the desired offset, so it's a
    // grapheme break, or we've gone past it, so it's not.
    lua_pushboolean(L, break_offset == offset);

    return 1;
}

static int lpeg_ext_GraphemeCount_closure(lua_State *L)
{
    // Retrieve the grapheme count from the closure
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

    // Fast path: since every grapheme is at least 1 byte long, we can avoid
    // counting graphemes if str[start_offset] is shorter than `count` bytes.
    if (count + start_offset > byte_len) {
        lua_pushboolean(L, 0);
        return 1;
    }

    // Check if byte_index is a grapheme break? Maybe.

    // Advance linearly.
    size_t i, offset, inc;
    for (i = 0, offset = start_offset; i < count && offset < byte_len; ++i, offset += inc) {
        inc = grapheme_next_character_break_utf8(str + offset, byte_len - offset);
    }

    // If we stopped because we reached the end of the string, we don't have
    // enough graphemes.
    if (i != count) {
        // Return false
        lua_pushboolean(L, 0);
        return 1;
    }

    // Otherwise, `offset` contains the offset of the grapheme in the string
    // after `count` graphemes. Convert it to a 1-based index.
    lua_pushinteger(L, offset + 1);
    return 1;
}

static int lpeg_ext_GraphemeCount(lua_State *L)
{
    // Retrieve the grapheme count.
    lua_Integer byte_index = luaL_checkinteger(L, 1);

    luaL_argcheck(L, byte_index > 0, 1, "count must be positive");

    lua_pushcclosure(L, lpeg_ext_GraphemeCount_closure, 1);
    return 1;
}

static int lpeg_ext_GraphemeOneOf_closure(lua_State *L)
{
    int needle_count = lua_tointeger(L, lua_upvalueindex(1));

    // Retrieve the string and its length
    size_t haystack_len;
    const char *haystack = luaL_checklstring(L, 1, &haystack_len);

    // Retrieve the byte index, 1-based.
    lua_Integer haystack_start_index = luaL_checkinteger(L, 2);

    // Bounds check, but allow indexing 1 past the end of the string.
    luaL_argcheck(L, haystack_start_index >= 1 && (size_t)haystack_start_index <= haystack_len + 1, 2,
        "index out of range");

    // Correct for 0-based indexing
    size_t haystack_start_offset = (size_t)haystack_start_index - 1;

    // Fast path: 1 past the end of the string never matches a grapheme.
    if (haystack_start_offset == haystack_len) {
        lua_pushboolean(L, 0);
        return 1;
    }

    for (int i = 0; i < needle_count; ++i) {
        size_t needle_len;
        const char *needle = lua_tolstring(L, lua_upvalueindex(2 + i), &needle_len);

        // Fast path: There's no need to compare if the needle does not
        // fit within the haystack.
        if (haystack_start_offset + needle_len > haystack_len) {
            continue;
        }

        size_t haystack_next_grapheme_len =
            grapheme_next_character_break_utf8(haystack + haystack_start_offset, haystack_len - haystack_start_offset);

        // Fast path: If the needle is longer than the next grapheme, it can't
        // match.
        if (needle_len != haystack_next_grapheme_len) {
            continue;
        }

        // If the haystack's next grapheme is the same length as the needle,
        // we can compare their bytes directly.
        if (memcmp(needle, haystack + haystack_start_offset, needle_len) == 0) {
            // Match! Return the 1-based index of the next grapheme.
            lua_pushinteger(L, haystack_start_offset + needle_len + 1);
            return 1;
        }
    }

    // No match :(
    lua_pushboolean(L, 0);
    return 1;
}

static int lpeg_ext_GraphemeOneOf(lua_State *L)
{
    int n_args = lua_gettop(L);

    if (n_args <= 0) {
        luaL_error(L, "expected at least 1 string argument");
        ASSERT_UNREACHABLE();
    }

    // Validate strings
    for (int i = 0; i < n_args; i++) {
        size_t byte_len;
        const char *str = luaL_checklstring(L, i + 1, &byte_len);

        luaL_argcheck(L, byte_len > 0, i + 1, "expected 1 grapheme, got 0");

        size_t inc = grapheme_next_character_break_utf8(str, byte_len);
        luaL_argcheck(L, inc == byte_len, i + 1, "expected 1 grapheme, got many");
    }

    // Push the number of strings onto the stack
    lua_pushinteger(L, n_args);

    // Rotate the number of strings to the top of the stack
    lua_rotate(L, 1, 1);

    // Return the closure
    lua_pushcclosure(L, lpeg_ext_GraphemeOneOf_closure, n_args + 1);
    return 1;
}

static luaL_Reg funcs[] = {
    {                  "lower",              uni_lower},
    {                  "upper",              uni_upper},
    {                    "len",                uni_len},
    {                "reverse",            uni_reverse},
    {                    "sub",                uni_sub},
    {        "grapheme_breaks",    uni_grapheme_breaks},
    {              "graphemes",          uni_graphemes},
    {      "is_grapheme_break",      is_grapheme_break},
    {"_lpeg_ext_GraphemeCount", lpeg_ext_GraphemeCount},
    {"_lpeg_ext_GraphemeOneOf", lpeg_ext_GraphemeOneOf},
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
