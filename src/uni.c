#include "uni.h"

static luaL_Reg funcs[] = {
    {                  "lower",                  lower},
    {                  "upper",                  upper},
    {                  "title",                  title},
    {                    "len",        count_graphemes},
    {      "is_grapheme_break",      is_grapheme_break},
    {     "_match_n_graphemes",      match_n_graphemes},
    {"_match_one_of_graphemes", match_one_of_graphemes},
    {        "grapheme_breaks",        grapheme_breaks},
    {              "graphemes",              graphemes},
    {                "reverse",      reverse_graphemes},
    {                    "sub",          graphemes_sub},
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
