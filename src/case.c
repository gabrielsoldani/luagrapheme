#include "uni.h"

#include <grapheme.h>

typedef size_t (* const to_case_fn)(const char *, size_t, char *, size_t);

static inline int case_(lua_State *L, to_case_fn to_case)
{
    // Retrieve the source string and its length
    size_t src_len;
    const char *src = luaL_checklstring(L, 1, &src_len);

    // Calculate the length of the destination string with the null terminator
    // NOTE: `grapheme_to_*case_utf8` expects to place a null terminator at the
    // end of the destination buffer, but does *not* expect one at the end of
    // the source buffer.
    size_t dest_len = to_case(src, src_len, NULL, 0) + 1;

    // Prepare the destination buffer
    luaL_Buffer b;
    char *dest = luaL_buffinitsize(L, &b, dest_len);

    // Convert the source string to the desired case
    to_case(src, src_len, dest, dest_len);

    // Push the destination string onto the stack without the null terminator
    luaL_pushresultsize(&b, dest_len - 1);

    return 1;
}

int lower(lua_State *L)
{
    return case_(L, grapheme_to_lowercase_utf8);
}

int upper(lua_State *L)
{
    return case_(L, grapheme_to_uppercase_utf8);
}

int title(lua_State *L)
{
    return case_(L, grapheme_to_titlecase_utf8);
}
