local luagrapheme = require("luagrapheme")
local utils = require("spec.utils")
local as_codepoints = utils.as_codepoints

describe("luagrapheme.lower", function()
   it("exists", function()
      assert.is_not_nil(luagrapheme.lower)
   end)

   it("errors when argument #1 is not a string", function()
      assert.has_error(function()
         luagrapheme.lower()
      end, "bad argument #1 to 'lower' (string expected, got no value)")
      assert.has_error(function()
         luagrapheme.lower(nil)
      end, "bad argument #1 to 'lower' (string expected, got nil)")
      assert.has_no_error(function()
         luagrapheme.lower("hello")
      end)
   end)

   it("works with ASCII text", function()
      assert.are.same(as_codepoints("hello"), as_codepoints(luagrapheme.lower("heLLo")))
   end)

   it("works with Cyrillic text", function()
      assert.are.same(as_codepoints("русский"), as_codepoints(luagrapheme.lower("РУССКИЙ")))
   end)

   it("works with combining diacritics", function()
      assert.are_same(as_codepoints("à"), as_codepoints(luagrapheme.lower("À")))
   end)

   it("works with null sequences", function()
      assert.are_same(as_codepoints("a\0b"), as_codepoints(luagrapheme.lower("A\0B")))
   end)
end)
