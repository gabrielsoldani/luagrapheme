#include "luagrapheme.h"

// static void luagrapheme_dump_stack(lua_State *L)
// {
//     int top = lua_gettop(L);
//     printf("Lua stack (top = %d):\n", top);
//     for (int i = 1; i <= top; ++i) {
//         int t = lua_type(L, i);
//         printf("  [%d] %s: ", i, lua_typename(L, t));
//         switch (t) {
//             case LUA_TSTRING:
//                 printf("'%s'\n", lua_tostring(L, i));
//                 break;
//             case LUA_TBOOLEAN:
//                 printf(lua_toboolean(L, i) ? "true\n" : "false\n");
//                 break;
//             case LUA_TNUMBER:
//                 printf("%g\n", lua_tonumber(L, i));
//                 break;
//             case LUA_TTABLE:
//             case LUA_TFUNCTION:
//             case LUA_TUSERDATA:
//             case LUA_TLIGHTUSERDATA:
//             case LUA_TTHREAD:
//                 printf("%p\n", lua_topointer(L, i));
//                 break;
//             case LUA_TNIL:
//                 printf("nil\n");
//                 break;
//             default:
//                 printf("unknown\n");
//                 break;
//         }
//     }
// }

static luaL_Reg funcs[] = {
    {"lower", case_lower},
    {"upper", case_upper},
    {"title", case_title},
    {   NULL,       NULL},
};

int luaopen_luagrapheme(lua_State *L)
{
    lua_newtable(L);

    lua_pushliteral(L, LUAGRAPHEME_VERSION);
    lua_setfield(L, -2, "_VERSION");

    luaL_setfuncs(L, funcs, 0);

    graphemes_open(L);
    lua_setfield(L, -2, "graphemes");

    lines_open(L);
    lua_setfield(L, -2, "lines");

    sentences_open(L);
    lua_setfield(L, -2, "sentences");

    words_open(L);
    lua_setfield(L, -2, "words");

    return 1;
}
