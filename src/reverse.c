#include "luagrapheme.h"

#include <grapheme.h>

int reverse_graphemes(lua_State *L)
{
    size_t byte_len;
    const char *src = luaL_checklstring(L, 1, &byte_len);

    luaL_Buffer b;
    char *dest = luaL_buffinitsize(L, &b, byte_len);

    for (size_t offset = 0, inc; offset < byte_len; offset += inc) {
        inc = grapheme_next_character_break_utf8(src + offset, byte_len - offset);
        memcpy(dest + byte_len - offset - inc, src + offset, inc);
    }

    luaL_pushresultsize(&b, byte_len);
    return 1;
}
