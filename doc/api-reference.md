# API Reference

## <a name="toc">Table of Contents</a>

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

## <a name="luagrapheme">`luagrapheme` Module</a>

### <a name="luagrapheme.graphemes">`graphemes(s, start)`</a>

Shorthand for [`graphemes.iter(s, start)`](#luagrapheme.graphemes.iter).

### <a name="luagrapheme.graphemes.index_after">`graphemes.index_after(s, start)`</a>

Returns the index of the first [grapheme cluster] strictly after the given index in the string.

#### Parameters

- `s` (`string`): The string to search in.
- `start` (`integer`, optional): The starting index in `s`. Must satisfy `start >= 1` and `start <= #s + 1`. Defaults to `1`.

#### Returns

An integer representing the index of the first grapheme cluster strictly after `start`. Returns `#s + 1` if the end of the string is reached. If `start` is exactly `#s + 1`, returns `nil`.

#### Example

```lua
graphemes = require("luagrapheme").graphemes

text = "Hello, 세상"
start = 8    --^
next_index = graphemes.index_after(text, start)
print(next_index)
--> 14
print(text:sub(start, next_index - 1))
--> 세
```

In contrast, using `string.find` with `utf8.charpattern` returns only the first jamo (a component of a Hangul syllable):

```lua
utf8 = require("utf8")

text = "Hello, 세상"
start = 8    --^
next_index = text:find(utf8.charpattern, next_index + 1)
print(next_index)
--> 11
print(text:sub(start, next_index - 1))
--> ᄉ
```

### <a name="luagrapheme.graphemes.iter">`graphemes.iter(s, start)`</a>

Creates an iterator that returns the start and end indices of each [grapheme cluster] in the given string on each iteration.

#### Parameters

- `s` (`string`): The string to iterate over.
- `start` (`integer`, optional): The starting index in `s`. Defaults to `1`.

#### Returns

An iterator function, suitable for use in [_generic for statements_][generic-for-statements].

#### Example

```lua
graphemes = require("luagrapheme").graphemes

text = "Hello, 세상"
t = {}
for i, j in graphemes.iter(text) do
   t[#t + 1] = text:sub(i, j)
end

print(table.concat(t, "|"))
--> H|e|l|l|o|,| |세|상
```

In contrast, using `string.gmatch` with the pattern `utf8.charpattern` returns
individual jamos (the components of Hangul syllables):

```lua
utf8 = require("utf8")

text = "Hello, 세상"
t = {}
for c in text:gmatch(utf8.charpattern) do
   t[#t + 1] = c
end
print(table.concat(t, "|"))
--> H|e|l|l|o|,| |ᄉ|ᅦ|ᄉ|ᅡ|ᆼ
```

### <a name="luagrapheme.lines">`lines(s, start)`</a>

Shorthand for [`lines.iter(s, start)`](#luagrapheme.lines.iter).

### <a name="luagrapheme.lines.index_after">`lines.index_after(s, start)`</a>

Returns the index of the first [line break opportunity] strictly after the given index in the string.

#### Parameters

- `s` (`string`): The string to search in.
- `start` (`integer`, optional): The starting position in `s`. Must satisfy `start >= 1` and `start <= #s + 1`. Defaults to `1`.

#### Example

```lua
lines = require("luagrapheme").lines

text = "Time-keeping began on 1970-01-01."

a = lines.index_after(text, 1)
print(a, string.format("%q", text:sub(1, a - 1)))
--> 6       "Time-"
b = lines.index_after(text, a)
print(b, string.format("%q", text:sub(a, b - 1)))
--> 12      "keeping "
c = lines.index_after(text, b)
print(c, string.format("%q", text:sub(b, c - 1)))
--> 20      "began "
d = lines.index_after(text, c)
print(d, string.format("%q", text:sub(c, d - 1)))
--> 23      "on "
e = lines.index_after(text, d)
print(e, string.format("%q", text:sub(d, e - 1)))
--> 34      "1970-01-01."
```

#### Example

```lua
lines = require("luagrapheme").lines

print(lines.index_after("a\r\nb\n", 1))
--> 4
print(lines.index_after("a\r\nb\n", 2))
--> 4
print(lines.index_after("a\r\nb\n", 3))
--> 4
print(lines.index_after("a\r\nb\n", 4))
--> 6
print(lines.index_after("a\r\nb\n", 5))
--> 6
print(lines.index_after("a\r\nb\n", 6))
--> nil
```

#### Returns

An integer representing the index of the first line break opportunity strictly after `start`. Returns `#s + 1` if the end of the string is reached. If `start` is exactly `#s + 1`, returns `nil`.

### <a name="luagrapheme.lines.iter">`lines.iter(s, start)`</a>

Creates an iterator that returns the start and end indices of each [line break opportunity] in the given string on each iteration.

#### Parameters

- `s` (`string`): The string to iterate over.
- `start` (`integer`, optional): The starting position in `s`. Defaults to `1`.

#### Returns

An iterator function, suitable for use in [_generic for statements_][generic-for-statements].

#### Example

```lua
lines = require("luagrapheme").lines

text = "Lua\u{00a0}5.4 was released in 2020-06-29, adding " ..
  "to-be-closed variables (see §\u{202f}3.3.8)"
for i, j in lines.iter(text) do
   print(text:sub(i, j) .. "⏎")
end
```

Output:

```
Lua 5.4 ⏎
was ⏎
released ⏎
in ⏎
2020-06-29, ⏎
adding ⏎
to-⏎
be-⏎
closed ⏎
variables ⏎
(see ⏎
§ 3.3.8)⏎
```

### <a name="luagrapheme.sentences">`sentences(s, start)`</a>

Shorthand for `sentences.iter(s, start)`.

### <a name="luagrapheme.sentences.index_after">`sentences.index_after(s, start)`</a>

Returns the index of the first [sentence break][sentence] strictly after the given index in the string.

#### Parameters

- `s` (`string`): The string to search in.
- `start` (`integer`, optional): The starting position in `s`. Must satisfy `start >= 1` and `start <= #s + 1`. Defaults to `1` .

#### Returns

An integer representing the index of the first sentence break strictly after `start`. Returns `#s + 1` if the end of the string is reached. If `start` is exactly `#s + 1`, returns `nil`.

### <a name="luagrapheme.sentences.iter">`sentences.iter(s, start)`</a>

Creates an iterator that returns the start and end indices of each [sentence] in the given string on each iteration.

#### Parameters

- `s` (`string`): The string to iterate over.
- `start` (`integer`, optional): The starting position in `s`. Defaults to `1`.

#### Returns

An iterator function, suitable for use in [_generic for statements_][generic-for-statements].

### <a name="luagrapheme.words">`words(s, start)`</a>

Shorthand for [`words.iter(s, start)`](#luagrapheme.words.iter).

### <a name="luagrapheme.words.index_after">`words.index_after(s, start)`</a>

Returns the index of the first [word break][word] strictly after the given index in the string.

#### Parameters

- `s` (`string`): The string to search in.
- `start` (`integer`, optional): The starting index in `s`. Must satisfy `start >= 1` and `start <= #s + 1`. Defaults to `1`.

#### Returns

An integer representing the index of the first word break strictly after `start`. Returns `#s + 1` if the end of the string is reached. If `start` is exactly `#s + 1`, returns `nil`.

### <a name="luagrapheme.words.iter">`words.iter(s, start)`</a>

Creates an iterator that returns the start and end indices of each [word] in the given string on each iteration.

#### Parameters

- `s` (`string`): The string to iterate over.
- `start` (`integer`, optional): The starting position in `s`. Defaults to `1`.

#### Returns

An iterator function, suitable for use in [_generic for statements_][generic-for-statements].

### <a name="luagrapheme.upper">`upper(s)`</a>

Converts the given string to uppercase.

#### Parameters

- `s` (`string`): The string to convert.

#### Returns

A new string with all grapheme clusters in `s` converted to uppercase.

#### Example

```lua
input = "HeLLo, мИр!"

-- Using Lua's built-in string.upper yields incorrect results for
-- non-ASCII grapheme clusters.
print(string.upper(input))
--> HELLO, мИр!

-- Using luagrapheme.upper instead :)
print(luagrapheme.upper(input))
--> HELLO, МИР!
```

### <a name="luagrapheme.lower">`lower(s)`</a>

Converts the given string to lowercase.

#### Parameters

- `s` (`string`): The string to convert.

#### Returns

A new string with all grapheme clusters in `s` converted to lowercase.

#### Example

```lua
input = "HeLLo, мИр!"

-- Using Lua's built-in string.lower yields incorrect results for
-- non-ASCII grapheme clusters.
print(string.lower(input))
--> hello, ���!

-- Using luagrapheme.lower instead :)
print(luagrapheme.lower(input))
--> hello, мир!
```

### <a name="luagrapheme.title">`title(s)`</a>

Converts the given string to title case.

#### Parameters

- `s` (`string`): The string to convert.

#### Returns

A new string with the first grapheme cluster of each word in `s` converted to uppercase and the rest converted to lowercase.

#### Example

```lua
input = "HeLLo, мИр!"

-- Using Lua's built-in string.upper and string.lower yields incorrect
-- results for non-ASCII grapheme clusters.
print(string.gsub(input, "(%a)(%w*)", function(first, rest)
    return first:upper() .. rest:lower()
end))
--> Hello, мИр!

-- Using luagrapheme.title instead :)
print(luagrapheme.title(input))
--> Hello, Мир!
```

### <a name="luagrapheme._VERSION">`_VERSION`</a>

The current version of the `luagrapheme` module.

[generic-for-statements]: https://www.lua.org/manual/5.1/manual.html#2.4.5

## <a name="luagrapheme.lpeg">`luagrapheme.lpeg` Module</a>

### <a name="luagrapheme.lpeg.G">`G()`</a>

#### Returns

A pattern that matches exactly 1 [grapheme cluster].

### <a name="luagrapheme.lpeg.L">`L()`</a>

#### Returns

A pattern that matches exactly 1 [line break opportunity].

### <a name="luagrapheme.lpeg.S">`S()`</a>

#### Returns

A pattern that matches exactly 1 [sentence].

### <a name="luagrapheme.lpeg.W">`W()`</a>

#### Returns

A pattern that matches exactly 1 [word].

### <a name="luagrapheme.lpeg._VERSION">`_VERSION`</a>

The current version of the `luagrapheme.lpeg` module.

[grapheme cluster]: concepts.md#grapheme-cluster
[line break opportunity]: concepts.md#line-break-opportunity
[sentence]: concepts.md#sentence
[word]: concepts.md#word
