local luagrapheme = require("luagrapheme")
local utils = require("spec.utils")
local as_codepoints = utils.as_codepoints

describe("luagrapheme.sub", function()
   it("exists", function()
      assert.is_not_nil(luagrapheme.sub)
   end)

   it("errors when argument #1 is not a string", function()
      assert.has_error(function()
         luagrapheme.sub(nil, 1)
      end, "bad argument #1 to 'sub' (string expected, got nil)")
      assert.has_no_error(function()
         luagrapheme.sub("hello", 1)
      end)
   end)

   it("errors when argument #2 is not an integer", function()
      assert.has_error(function()
         luagrapheme.sub("hello")
      end, "bad argument #2 to 'sub' (number expected, got no value)")
      assert.has_error(function()
         luagrapheme.sub("hello", "world")
      end, "bad argument #2 to 'sub' (number expected, got string)")
      assert.has_no_error(function()
         luagrapheme.sub("hello", 2)
      end)
      assert.has_no_error(function()
         luagrapheme.sub("hello", "2")
      end)
   end)

   it("errors when argument #3 is not an integer, nil or no value", function()
      assert.has_error(function()
         luagrapheme.sub("hello", 1, "world")
      end, "bad argument #3 to 'sub' (number expected, got string)")
      assert.has_no_error(function()
         luagrapheme.sub("hello", 1, 2)
      end)
      assert.has_no_error(function()
         luagrapheme.sub("hello", 1, "2")
      end)
      assert.has_no_error(function()
         luagrapheme.sub("hello", 1, nil)
      end)
      assert.has_no_error(function()
         luagrapheme.sub("hello", 1)
      end)
   end)

   it("extracts a simple ASCII substring", function()
      assert.are.same(as_codepoints("ell"), as_codepoints(luagrapheme.sub("hello", 2, 4)))
   end)

   it("handles negative start index", function()
      assert.are.same(as_codepoints("llo"), as_codepoints(luagrapheme.sub("hello", -3)))
   end)

   it("handles negative end index", function()
      assert.are.same(as_codepoints("hell"), as_codepoints(luagrapheme.sub("hello", 1, -2)))
   end)

   it("defaults to the end of the string when end index is omitted", function()
      assert.are.same(as_codepoints("hello"), as_codepoints(luagrapheme.sub("hello", 1)))
   end)

   it("corrects start index less than 1", function()
      assert.are.same(as_codepoints("hello"), as_codepoints(luagrapheme.sub("hello", 0, 5)))
   end)

   it("corrects end index beyond string length", function()
      assert.are.same(as_codepoints("hello"), as_codepoints(luagrapheme.sub("hello", 1, 10)))
   end)

   it("returns empty string when start index is greater than end index", function()
      assert.are.same(as_codepoints(""), as_codepoints(luagrapheme.sub("hello", 5, 4)))
   end)

   it("returns empty string for empty input", function()
      assert.are.same(as_codepoints(""), as_codepoints(luagrapheme.sub("", 1, 1)))
   end)

   it("handles grapheme clusters correctly", function()
      assert.are.same(as_codepoints("👩‍🚀"), as_codepoints(luagrapheme.sub("he👩‍🚀llo", 3, 3)))
   end)
end)
