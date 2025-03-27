#include "uni.h"

static luaL_Reg funcs[] = {
    {                  "lower",                  lower},
    {                  "upper",                  upper},
    {                  "title",                  title},
    {                    "len",        count_graphemes},
    {      "is_grapheme_break",      is_grapheme_break},
    {          "is_line_break",          is_line_break},
    {          "is_word_break",          is_word_break},
    {      "is_sentence_break",      is_sentence_break},
    {     "_match_n_graphemes",      match_n_graphemes},
    {"_match_one_of_graphemes", match_one_of_graphemes},
    {        "grapheme_breaks",        grapheme_breaks},
    {            "line_breaks",            line_breaks},
    {            "word_breaks",            word_breaks},
    {        "sentence_breaks",        sentence_breaks},
    {              "graphemes",              graphemes},
    {                  "lines",                  lines},
    {                  "words",                  words},
    {              "sentences",              sentences},
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
