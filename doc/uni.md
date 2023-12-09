# uni

## Definitions

### Grapheme Clusters

A grapheme cluster represents a unit of text that is perceived by the user as a single entity. It is what the user normally  conceives as a "character" (for example, when counting or advancing cursor positions).

**Example**: The word "Lua" consists of 3 grapheme clusters: "L", "u", and "a". Each is composed of a single code point: U+004C (LATIN CAPITAL LETTER L), U+0075 (LATIN SMALL LETTER U), and U+0061 (LATIN SMALL LETTER A), respectively.

A grapheme cluster may be a single code point, or it may be a sequence of code points that are rendered as a single unit.

**Example**: The emoji "👩‍🚀" (WOMAN ASTRONAUT) is a single grapheme cluster that is composed of multiple code points, "👩" (U+1F469 - WOMAN), "ZWJ" (U+200D - ZERO WIDTH JOINER
and "🚀" (U+1F680 - ROCKET).

The converse is not true, however. Not all sequences of code points that are rendered as a single unit are grapheme clusters.

**Example**: The string "ﬁ" can form a ligature and be rendered as a single glyph if the font and text rendering engine supports it, yet it is composed of two grapheme clusters, "f" and "i".

### Code points

A code point is a number which is given some meaning by the Unicode standard. This library is designed to abstract away code points as much as possible.

If you"re using Lua 5.3 or later, you can include Unicode code points in string literals using the `\u{X}` escape sequence, where `X` is the code point in hexadecimal notation. Note that the curly braces are required. For more information, see the Lua manual.

### UTF-8 Encoded Strings

UTF-8 is the most commonly used way to encode a sequence of Unicode code points as a sequence of bytes in a compact way. It is designed to be backwards compatible with ASCII, so any ASCII-encoded string is also a valid UTF-8 encoded string. As of the time of this writing, it is the dominant encoding for the World Wide Web and most modern systems.

It's a _variable-length encoding_, meaning some code points have longer representations than others.

**Example**: The string "café" consists of four grapheme clusters: "c", "a", "f", and "é". Its code points are, respectively, U+0063 (LATIN SMALL LETTER C), U+0061 (LATIN SMALL LETTER A), U+0066 (LATIN SMALL LETTER F), and U+00E9 (LATIN SMALL LETTER E WITH ACUTE). In UTF-8, it is encoded as `0x63 0x61 0x66 0xC3 0xA9`. Note that the first three code points are encoded as a single byte each, while the last one is encoded as two bytes.

**Example**: The string "Lua 👩‍🚀" is encoded as `0x4C 0x75 0x61 0x20 0xF0 0x9F 0x91 0xA9 0xE2 0x80 0x8D 0xF0 0x9F 0x9A 0x80`. This string consists of five grapheme clusters, "L", "u", "a", " ", and "👩‍🚀". The first four consist of a single code point each, and are encoded to a single byte each. The last one, "👩‍🚀", consists of three code points which are encoded to the remaining eleven bytes.

If the system locale on the interpreter is set to UTF-8, you should have no problem saving your Lua source files in UTF-8 encoding. In Lua 5.3 and later, you can also use a escape sequence, as described above.

### Character

The term "character" is explicitly avoided in these definitions to prevent ambiguity with the computer use of the term. In user perception, a "character" might be more intuitively understood as a grapheme cluster.

## Functions

### `uni.sub(s, i [, j])`

Returns the substring of `s` that starts at the `i`-th grapheme cluster and continues until `j` (also specified in grapheme clusters). Both `i` and `j` can be negative, indicating positions starting from the end of the string.

#### Parameters

- `s`: The UTF-8-encoded string from which to extract the substring.
- `i`: The starting position of the substring, expressed in grapheme clusters.
- `j` (optional): The ending position of the substring, also expressed in grapheme clusters. If absent, it defaults to `-1`, which signifies the last grapheme cluster in the string.

#### Behavior

When `i` and/or `j` are negative, they are translated to positive indices by counting from the end of the string: `-1` refers to the last grapheme cluster, `-2` to the second-to-last, and so on.

If `i` is less than `1` after any necessary translations, it is corrected to `1`. Similarly, if `j` exceeds the total grapheme clusters in the string, it is corrected to that number. If, after these corrections, `i` is greater than `j`, the function returns an empty string.

#### Examples

```lua
-- Outputs "ell", as it includes grapheme clusters 2, 3, and 4
print(uni.sub("hello", 2, 4))

-- Outputs "o", as -1 refers to the last grapheme cluster
print(uni.sub("hello", -1))

-- Outputs an empty string, as 5 is greater than 4
print(uni.sub("hello", 5, 4))

-- Example with a grapheme cluster (Emoji: 👩‍🚀 WOMAN ASTRONAUT) composed of multiple code points
-- String is "he👩‍🚀llo", and "👩‍🚀" occupies the 3rd grapheme cluster position
-- Outputs "👩‍🚀", as it includes the grapheme cluster at position 3
print(uni.sub("he👩‍🚀llo", 3, 3))

-- (Lua >= 5.3) Using escape sequences for Unicode code points
-- The code points for the emoji 👩‍🚀 WOMAN ASTRONAUT are \u{1F469}\u{200D}\u{1F680}
-- String is "he\u{1F469}\u{200D}\u{1F680}llo", and "👩‍🚀" occupies the 3rd grapheme cluster position
-- Outputs "👩‍🚀", as it includes the grapheme cluster at position 3
print(uni.sub("he\u{1F469}\u{200D}\u{1F680}llo", 3, 3))
```

### `uni.len(s)`

Receives a UTF-8 encoded string s and returns its length in grapheme clusters.

#### Parameters

- `s`: The UTF-8 encoded string whose length you want to find.

#### Behavior

The function counts the length of the string in terms of grapheme clusters rather than individual Unicode code points or bytes. The empty string "" has a length of 0. Embedded zeros are also counted; each embedded zero counts as one grapheme cluster.

#### Examples

```lua
-- Outputs "3", as the string has 3 grapheme clusters
print(uni.len("Lua"))

-- Outputs "6", as the string has 6 grapheme clusters including embedded zeros
print(uni.len("a\000bc\000\000"))

-- Outputs "0", as it"s an empty string
print(uni.len(""))

-- Example with a grapheme cluster (Emoji: 👩‍🚀 WOMAN ASTRONAUT)
-- String is "he👩‍🚀llo", and "👩‍🚀" is counted as a single grapheme cluster
-- Outputs "6", as the string has 6 grapheme clusters
print(uni.len("he👩‍🚀llo"))

-- (Lua >= 5.3) Using escape sequences for Unicode code points
-- The code points for the emoji 👩‍🚀 WOMAN ASTRONAUT are \u{1F469}\u{200D}\u{1F680}
-- String is "he\u{1F469}\u{200D}\u{1F680}llo"
-- Outputs "6", as the string has 6 grapheme clusters
print(uni.len("he\u{1F469}\u{200D}\u{1F680}llo"))
```

### `uni.reverse(s)`

Returns a new UTF-8-encoded string with the order of grapheme clusters in `s` reversed.

#### Parameters

- `s`: The UTF-8-encoded string to reverse.

#### Behavior

Each grapheme cluster in the string `s` is identified and reversed in its entirety, ensuring that multi-code point grapheme clusters like emojis are not broken apart.

#### Examples

```lua
-- Outputs "olleh", reversing the 5 grapheme clusters
print(uni.reverse("hello"))

-- Outputs "👩‍🚀 uaL", as the grapheme cluster "👩‍🚀" is preserved in its entirety
print(uni.reverse("Lua 👩‍🚀"))

-- (Lua >= 5.3) Using escape sequences for Unicode code points
-- The code points for the emoji 👩‍🚀 WOMAN ASTRONAUT are \u{1F469}\u{200D}\u{1F680}
-- Outputs "👩‍🚀 uaL", preserving the emoji as a single grapheme cluster
print(uni.reverse("Lua \u{1F469}\u{200D}\u{1F680}"))
```

### `uni.lower(s)`

Returns a new UTF-8-encoded string with all the alphabetic grapheme clusters in `s` converted to lowercase.

#### Parameters

- `s`: The UTF-8-encoded string to convert to lowercase.

#### Behavior

The function identifies each grapheme cluster in the string s and transforms all alphabetic segments to their lowercase counterpart, in accordance with Unicode case mappings.

#### Examples

```lua
-- Outputs "hello", converting ASCII to lowercase
print(uni.lower("HeLLo"))

-- Outputs "русский", converting Cyrillic to lowercase
print(uni.lower("РУССКИЙ"))

-- "À" ("A" + COMBINING GRAVE ACCENT)
-- Outputs "à", transforming "A" to "a" and maintaining the COMBINING GRAVE ACCENT
print(uni.lower("A\u{0300}"))
```

### `uni.upper(s)`

Returns a new UTF-8-encoded string with all the alphabetic grapheme clusters in `s` converted to uppercase.

#### Parameters

- `s`: The UTF-8-encoded string to convert to uppercase.

#### Behavior

The function identifies each grapheme cluster in the string s and transforms all alphabetic segments to their uppercase counterpart, in accordance with Unicode case mappings.

#### Examples

```lua
-- Outputs "HELLO", converting ASCII to uppercase
print(uni.upper("HeLLo"))

-- Outputs "РУССКИЙ", converting Cyrillic to uppercase
print(uni.upper("русский"))

-- "à" ("a" + COMBINING GRAVE ACCENT)
-- Outputs "À", transforming "a" to "A" and maintaining the COMBINING GRAVE ACCENT
print(uni.upper("a\u{0300}"))
```

### `uni.graphemes(s)`

Returns a generator function that returns the grapheme clusters in `s` one at a time.

#### Parameters

- `s`: The UTF-8-encoded string to iterate over.

#### Behavior

The function returns a generator function that, when called, returns the next grapheme cluster in the string `s` on each call. If there are no more grapheme clusters to return, it returns `nil`.

The return of this function can be used in a generic `for` statement.

#### Examples

```lua
-- Outputs "h", "e", "l", "l", "o"
for grapheme in uni.graphemes("hello") do
  print(grapheme)
end

-- Outputs "👩‍🚀", " ", "L", "u", "a"
for grapheme in uni.graphemes("👩‍🚀 Lua") do
  print(grapheme)
end

local next = uni.graphemes("Hi 🧑‍💻")
print(next()) -- Outputs "H"
print(next()) -- Outputs "i"
print(next()) -- Outputs " "
print(next()) -- Outputs "🧑‍💻"
print(next()) -- Outputs nil
```
