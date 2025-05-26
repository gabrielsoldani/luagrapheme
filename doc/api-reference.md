# API Reference

## Table of Contents

- [`luagrapheme` Module](#luagrapheme)
  - [`graphemes(s, start)`](#luagrapheme.graphemes)
  - [`graphemes.index_after(s, start)`](#luagrapheme.graphemes.index_after)
  - [`graphemes.iter(s, start)`](#luagrapheme.graphemes.iter)
  - [`lines(s, start)`](#luagrapheme.lines)
  - [`lines.index_after(s, start)`](#luagrapheme.lines.index_after)
  - [`lines.iter(s, start)`](#luagrapheme.lines.iter)
  - [`sentences(s, start)`](#luagrapheme.sentences)
  - [`sentences.index_after(s, start)`](#luagrapheme.sentences.index_after)
  - [`sentences.iter(s, start)`](#luagrapheme.sentences.iter)
  - [`words(s, start)`](#luagrapheme.words)
  - [`words.index_after(s, start)`](#luagrapheme.words.index_after)
  - [`words.iter(s, start)`](#luagrapheme.words.iter)
  - [`upper(s)`](#luagrapheme.upper)
  - [`lower(s)`](#luagrapheme.lower)
  - [`title(s)`](#luagrapheme.title)
  - [`_VERSION`](#luagrapheme._VERSION)
- [`luagrapheme.lpeg` Module](#luagrapheme.lpeg)
  - [`G()`](#luagrapheme.lpeg.G)
  - [`L()`](#luagrapheme.lpeg.L)
  - [`S()`](#luagrapheme.lpeg.S)
  - [`W()`](#luagrapheme.lpeg.W)
  - [`_VERSION`](#luagrapheme.lpeg._VERSION)

---

## <a name="luagrapheme">`luagrapheme` Module

### <a name="luagrapheme.graphemes"></a>`graphemes(s, start)`

Shorthand for [`graphemes.iter(s, start)`](#luagrapheme.graphemes.iter).

### <a name="luagrapheme.graphemes.index_after"></a>`graphemes.index_after(s, start)`

Returns the index of the first [grapheme] after the given position in the string.

#### Parameters

- `s` (`string`): The string to search in.
- `start` (`integer`, optional): The starting position in `s`. Defaults to `1`.

#### Returns

An integer representing the starting index of the first grapheme after `start`.
If there are no more graphemes, returns `nil`.

#### Example

```lua
local luagrapheme = require("luagrapheme")
local graphemes = luagrapheme.graphemes

local text = "Hello, 世界"
local start = 8
local next_index = graphemes.index_after(text, start)
print(next_index)
--> 10
print(text:sub(start, next_index - 1))
--> 世
```

### <a name="luagrapheme.graphemes.iter"></a>`graphemes.iter(s, start)`

Creates an iterator that returns the start and end indices of each [grapheme] in
the given string on each iteration.

#### Parameters

- `s` (`string`): The string to iterate over.
- `start` (`integer`, optional): The starting position in `s`. Defaults to `1`.

#### Returns

An iterator function, suitable for use in [_generic for statements_][generic-for-statements].

#### Example

```lua
local luagrapheme = require("luagrapheme")
local graphemes = luagrapheme.graphemes

local text = "Hello, 世界"
local t = {}
for i, j in graphemes.iter(text) do
   t[#t + 1] = text:sub(i, j)
end

print(table.concat(t, "|"))
--> H|e|l|l|o|,| |世|界
```

### <a name="luagrapheme.lines"></a>`lines(s, start)`

Shorthand for [`lines.iter(s, start)`](#luagrapheme.lines.iter).

### <a name="luagrapheme.lines.index_after"></a>`lines.index_after(s, start)`

Returns the index of the first [line] after the given position in the string.

#### Parameters

- `s` (`string`): The string to search in.
- `start` (`integer`, optional): The starting position in `s`. Defaults to `1`.

#### Returns

An integer representing the starting index of the first line after `start`. If
there are no more lines, returns `nil`.

### <a name="luagrapheme.lines.iter"></a>`lines.iter(s, start)`

Creates an iterator that returns the start and end indices of each [line] in the
given string on each iteration.

#### Parameters

- `s` (`string`): The string to iterate over.
- `start` (`integer`, optional): The starting position in `s`. Defaults to `1`.

#### Returns

An iterator function, suitable for use in [_generic for statements_][generic-for-statements].

### <a name="luagrapheme.sentences"></a>`sentences(s, start)`

Shorthand for `sentences.iter(s, start)`.

### <a name="luagrapheme.sentences.index_after"></a>`sentences.index_after(s, start)`

Returns the index of the first [sentence] after the given position in the string.

#### Parameters

- `s` (`string`): The string to search in.
- `start` (`integer`, optional): The starting position in `s`. Defaults to `1`.

#### Returns

An integer representing the starting index of the first sentence after `start`.
If there are no more sentences, returns `nil`.

### <a name="luagrapheme.sentences.iter"></a>`sentences.iter(s, start)`

Creates an iterator that returns the start and end indices of each [sentence] in
the given string on each iteration.

#### Parameters

- `s` (`string`): The string to iterate over.
- `start` (`integer`, optional): The starting position in `s`. Defaults to `1`.

#### Returns

An iterator function, suitable for use in [_generic for statements_][generic-for-statements].

### <a name="luagrapheme.words"></a>`words(s, start)`

Shorthand for [`words.iter(s, start)`](#luagrapheme.words.iter).

### <a name="luagrapheme.words.index_after"></a>`words.index_after(s, start)`

Returns the index of the first [word] after the given position in the string.

#### Parameters

- `s` (`string`): The string to search in.
- `start` (`integer`, optional): The starting position in `s`. Defaults to `1`.

#### Returns

An integer representing the starting index of the first word after `start`. If
there are no more words, returns `nil`.

### <a name="luagrapheme.words.iter"></a>`words.iter(s, start)`

Creates an iterator that returns the start and end indices of each [word] in the
given string on each iteration.

#### Parameters

- `s` (`string`): The string to iterate over.
- `start` (`integer`, optional): The starting position in `s`. Defaults to `1`.

#### Returns

An iterator function, suitable for use in [_generic for statements_][generic-for-statements].

### <a name="luagrapheme.upper"></a>`upper(s)`

Converts the given string to uppercase.

#### Parameters

- `s` (`string`): The string to convert.

#### Returns

A new string with all graphemes in `s` converted to uppercase.

#### Example

```lua
local luagrapheme = require("luagrapheme")
local input = "HeLLo, мИр!"

-- Using Lua's built-in string.upper yields incorrect results for
-- non-ASCII graphemes.
print(string.upper(input))
--> HELLO, мИр!

-- Using luagrapheme.upper instead :)
print(luagrapheme.upper(input))
--> HELLO, МИР!
```

### <a name="luagrapheme.lower"></a>`lower(s)`

Converts the given string to lowercase.

#### Parameters

- `s` (`string`): The string to convert.

#### Returns

A new string with all graphemes in `s` converted to lowercase.

#### Example

```lua
local luagrapheme = require("luagrapheme")
local input = "HeLLo, мИр!"

-- Using Lua's built-in string.lower yields incorrect results for
-- non-ASCII graphemes.
print(string.lower(input))
--> hello, ���!

-- Using luagrapheme.lower instead :)
print(luagrapheme.lower(input))
--> hello, мир!
```

### <a name="luagrapheme.title"></a>`title(s)`

Converts the given string to title case.

#### Parameters

- `s` (`string`): The string to convert.

#### Returns

A new string with the first grapheme of each word in `s` converted to uppercase
and the rest of the graphemes in each word converted to lowercase.

#### Example

```lua
local luagrapheme = require("luagrapheme")
local input = "HeLLo, мИр!"

-- Using Lua's built-in string.upper and string.lower yields incorrect
-- results for non-ASCII graphemes.
print(string.gsub(input, "(%a)(%w*)", function(first, rest)
    return first:upper() .. rest:lower()
end))
--> Hello, мИр!

-- Using luagrapheme.title instead :)
print(luagrapheme.title(input))
--> Hello, Мир!
```

### <a name="luagrapheme._VERSION"></a>`_VERSION`

The current version of the `luagrapheme` module.

[generic-for-statements]: https://www.lua.org/manual/5.1/manual.html#2.4.5

## <a name="luagrapheme.lpeg"></a>`luagrapheme.lpeg` Module

### <a name="luagrapheme.lpeg.G"></a>`G()`

#### Returns

A pattern that matches exactly 1 [grapheme].

### <a name="luagrapheme.lpeg.L"></a>`L()`

#### Returns

A pattern that matches exactly 1 [line].

### <a name="luagrapheme.lpeg.S"></a>`S()`

#### Returns

A pattern that matches exactly 1 [sentence].

### <a name="luagrapheme.lpeg.W"></a>`W()`

#### Returns

A pattern that matches exactly 1 [word].

### <a name="luagrapheme.lpeg._VERSION"></a>`_VERSION`

The current version of the `luagrapheme.lpeg` module.

[grapheme]: concepts.md#Grapheme
[line]: concepts.md#Line
[sentence]: concepts.md#Sentence
[word]: concepts.md#Word
