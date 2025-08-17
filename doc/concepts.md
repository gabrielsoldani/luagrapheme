# Concepts

## <a name="grapheme-cluster">Grapheme cluster</a>

A _grapheme cluster_ (as the Unicode standards calls it) represents a unit of text that is perceived by the user as a single entity. It is what the user normally  conceives as a "character" (for example, when counting or advancing cursor positions).

> **Example**: The word "Lua" consists of 3 grapheme clusters: "L", "u", and "a". Each is composed of a single code point: U+004C (LATIN CAPITAL LETTER L), U+0075 (LATIN SMALL LETTER U), and U+0061 (LATIN SMALL LETTER A), respectively.

A grapheme cluster may be a single code point, or it may be a sequence of code points that are rendered as a single unit.

> **Example**: The emoji "👩‍🚀" (WOMAN ASTRONAUT) is a single grapheme cluster that is composed of multiple code points, "👩" (U+1F469 - WOMAN), "ZWJ" (U+200D - ZERO WIDTH JOINER
and "🚀" (U+1F680 - ROCKET).

The converse is not true, however. Not all sequences of code points that are rendered as a single unit are grapheme clusters.

> **Example**: The string "ﬁ" can form a ligature and be rendered as a single glyph if the font and text rendering engine supports it, yet it is composed of two grapheme clusters, "f" and "i".

## <a name="codepoint">Code points</a>

A code point is a number which is given some meaning by the Unicode standard. This library is designed to abstract away code points as much as possible.

If you're using Lua 5.3 or later, you can include Unicode code points in string literals using the `\u{X}` escape sequence, where `X` is the code point in hexadecimal notation. Note that the curly braces are required. See the [Lua manual][unicode-espace-sequences] for more information.

[unicode-espace-sequences]: https://www.lua.org/manual/5.3/manual.html#3.1

## <a name="utf-8">UTF-8 encoded strings</a>

UTF-8 is the most commonly used way to encode a sequence of Unicode code points as a sequence of bytes in a compact way. It is designed to be backwards compatible with ASCII, so any ASCII-encoded string is also a valid UTF-8 encoded string. As of the time of this writing, it is the dominant encoding for the World Wide Web and most modern systems.

It's a _variable-length encoding_, meaning some code points have longer representations than others.

> **Example**: The string "café" consists of four grapheme clusters: "c", "a", "f", and "é". Its code points are, respectively, U+0063 (LATIN SMALL LETTER C), U+0061 (LATIN SMALL LETTER A), U+0066 (LATIN SMALL LETTER F), and U+00E9 (LATIN SMALL LETTER E WITH ACUTE). In UTF-8, it is encoded as `0x63 0x61 0x66 0xC3 0xA9`. Note that the first three code points are encoded as a single byte each, while the last one is encoded as two bytes.

> **Example**: The string "Lua 👩‍🚀" is encoded as `0x4C 0x75 0x61 0x20 0xF0 0x9F 0x91 0xA9 0xE2 0x80 0x8D 0xF0 0x9F 0x9A 0x80`. This string consists of five grapheme clusters, "L", "u", "a", " ", and "👩‍🚀". The first four consist of a single code point each, and are encoded to a single byte each. The last one, "👩‍🚀", consists of three code points which are encoded to the remaining eleven (!) bytes.

If the system locale on the interpreter is set to UTF-8, you should have no problem saving your Lua source files in UTF-8 encoding. In Lua 5.3 and later, you can also use a escape sequence, as described above.

## <a name="character">Character</a>

The term "character" is explicitly avoided in these definitions to prevent ambiguity with the computer use of the term. In user perception, a "character" might be more intuitively understood as a [grapheme cluster](#grapheme-cluster).

## <a name="line-break-opportunity">Line break opportunity</a>

...

## <a name="sentence">Sentence</a>

...

## <a name="word">Word</a>

...
