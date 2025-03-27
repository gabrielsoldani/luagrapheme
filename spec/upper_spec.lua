local luagrapheme = require("luagrapheme")
local utils = require("spec.utils")
local as_codepoints = utils.as_codepoints

describe("luagrapheme.upper", function()
   it("exists", function()
      assert.is_not_nil(luagrapheme.upper)
   end)

   it("errors when argument #1 is not a string", function()
      assert.has_error(function()
         luagrapheme.upper()
      end, "bad argument #1 to 'upper' (string expected, got no value)")
      assert.has_error(function()
         luagrapheme.upper(nil)
      end, "bad argument #1 to 'upper' (string expected, got nil)")
      assert.has_no_error(function()
         luagrapheme.upper("hello")
      end)
   end)

   it("works with ASCII text", function()
      assert.are.same(as_codepoints("HELLO"), as_codepoints(luagrapheme.upper("heLLo")))
   end)

   it("works with Cyrillic text", function()
      assert.are.same(as_codepoints("РУССКИЙ"), as_codepoints(luagrapheme.upper("русский")))
   end)

   it("works with combining diacritics", function()
      assert.are_same(as_codepoints("À"), as_codepoints(luagrapheme.upper("à")))
   end)

   it("works with null sequences", function()
      assert.are_same(as_codepoints("A\0B"), as_codepoints(luagrapheme.upper("a\0b")))
   end)
end)
