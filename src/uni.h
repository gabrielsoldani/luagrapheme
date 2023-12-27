#ifndef UNI_H
#define UNI_H

#include <assert.h>

#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>

#include <compat-5.3.h>

int lower(lua_State *);
int upper(lua_State *);
int title(lua_State *);

int is_grapheme_break(lua_State *L);
int is_line_break(lua_State *L);
int is_word_break(lua_State *L);
int is_sentence_break(lua_State *L);

int grapheme_breaks(lua_State *);
int line_breaks(lua_State *);
int word_breaks(lua_State *);
int sentence_breaks(lua_State *);

int graphemes(lua_State *);
int lines(lua_State *);
int words(lua_State *);
int sentences(lua_State *);

int match_n_graphemes(lua_State *);
int match_n_lines(lua_State *);
int match_n_words(lua_State *);
int match_n_sentences(lua_State *);

int match_oneof_graphemes(lua_State *);

typedef size_t (* const next_segment_break_fn)(const char *, size_t);

#define ASSERT_UNREACHABLE() assert(!"unreachable")

#endif // UNI_H
