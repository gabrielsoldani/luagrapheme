local luagrapheme = require("luagrapheme")
local utils = require("spec.utils")
local as_codepoints = utils.as_codepoints

describe("luagrapheme.title", function()
   it("exists", function()
      assert.is_not_nil(luagrapheme.title)
   end)

   it("errors when argument #1 is not a string", function()
      assert.has_error(function()
         luagrapheme.title()
      end, "bad argument #1 to 'title' (string expected, got no value)")
      assert.has_error(function()
         luagrapheme.title(nil)
      end, "bad argument #1 to 'title' (string expected, got nil)")
      assert.has_no_error(function()
         luagrapheme.title("hello")
      end)
   end)

   it("works with ASCII text", function()
      assert.are.same(as_codepoints("Hello World"), as_codepoints(luagrapheme.title("heLLo world")))
   end)

   it("works with Cyrillic text", function()
      assert.are.same(as_codepoints("Русский"), as_codepoints(luagrapheme.title("РУССКИЙ")))
   end)

   it("works with combining diacritics", function()
      assert.are_same(as_codepoints("Àa Bb"), as_codepoints(luagrapheme.title("àa bb")))
   end)

   it("works with null sequences", function()
      assert.are_same(as_codepoints("Aa\0Bb"), as_codepoints(luagrapheme.title("aa\0bb")))
   end)
end)
