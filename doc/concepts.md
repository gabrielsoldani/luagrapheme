# Concepts

## <a name="grapheme-cluster">Grapheme cluster</a>

A _grapheme cluster_ (as the Unicode standards calls it) represents a unit of text that is perceived by the user as a single entity. It is what the user normally conceives as a "character" (for example, when counting or advancing cursor positions).

> **Example**: The word "Lua" consists of 3 grapheme clusters: "L", "u", and "a". Each is composed of a single code point: U+004C (LATIN CAPITAL LETTER L), U+0075 (LATIN SMALL LETTER U), and U+0061 (LATIN SMALL LETTER A), respectively.

A grapheme cluster may be a single code point, or it may be a sequence of code points that are rendered as a single unit.

> **Example**: The emoji "👩‍🚀" (WOMAN ASTRONAUT) is a single grapheme cluster that is composed of multiple code points, "👩" (U+1F469 - WOMAN), "ZWJ" (U+200D - ZERO WIDTH JOINER
> and "🚀" (U+1F680 - ROCKET).

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

A _line break opportunity_ is a position in text where a renderer is permitted to wrap onto a new line. The [Unicode Line Breaking Algorithm (UAX #14)][uax-14] defines these opportunities based on character classes and context.

The simplest case is the ordinary space character. The algorithm allows a break after a space, so two words separated by a space will be returned as two segments.

> **Example**: The string `"Hello world"` is segmented into `"Hello "` and `"world"`.

Hyphens behave differently depending on context. When digits surround a hyphen, as in a date, the algorithm treats the sequence as numeric and forbids breaking inside it. In contrast, an alphabetic hyphen permits a break.

Hyphens behave differently depending on context. When digits surround a hyphen, as in a date, the algorithm treats the sequence as numeric and forbids breaking inside it. In contrast, an alphabetic hyphen permits a break.

> **Example**: The string `"On 2020-06-29 a well-known story began"` is segmented into `"On "`, `"2020-06-29 "`, `"a "`, `"well-"`, `"known "`, `"story "`, and `"began"`. The date stays intact, while `"well-known"` may break after the hyphen.

Some characters have alternative code points that disallow breaks. A common case is the non-breaking space (U+00A0), which looks like an ordinary space but never permits a line break.

> **Example**: The string `"Lua␣5.4 released"` (`␣` = U+00A0 NO-BREAK SPACE) is segmented into `"Lua␣5.4 "` and `"released"`. The word “Lua” and its version number cannot be split apart. (We've highlighted the non-breaking space with a visible character for clarity.)

Some characters always force a break. The newline (U+000A) is a mandatory break, splitting the text into separate lines.

> **Example**: The string `"First␣line⏎Second␣line"` (⏎ = U+000A LINE FEED) is segmented into `"First␣"`, `"line⏎"`, `"Second␣"`, and `"line"`.

For characters that don’t have a dedicated non-breaking alternative, the WORD JOINER (U+2060) can be used. It is an invisible character that blocks breaks on either side. A common use is with the em dash, where otherwise a break might occur before or after the dash.

> **Example**: The string `"Alice⁠⁀—⁀⁠Bob"` (`⁀` = U+2060 WORD JOINER) is segmented into `"Alice⁠—⁠Bob"`. The EM DASH (U+2014) cannot be separated from the surrounding text, so “Alice—Bob” always stays on the same line. (We've highlighted the word joiner with a visible character for clarity.)

[uax-14]: https://www.unicode.org/reports/tr14/

## <a name="sentence">Sentence</a>

...

## <a name="word">Word</a>

...
