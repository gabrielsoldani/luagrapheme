#include <string.h>

#include "uni.h"
#include "utf8.h"

#include <grapheme.h>

static int match_one_of_graphemes_closure(lua_State *L)
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

    // Fast path: if we're in the middle of a codepoint, it can't be a segment
    // break.
    if (is_utf8_continuation_byte(haystack[haystack_start_offset])) {
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

int match_one_of_graphemes(lua_State *L)
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
    lua_pushcclosure(L, match_one_of_graphemes_closure, n_args + 1);
    return 1;
}
