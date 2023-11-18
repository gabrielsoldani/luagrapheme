local uni = require("uni")
local utils = require("spec.utils")
local as_codepoints = utils.as_codepoints

describe("uni.upper", function()
   it("exists", function()
      assert.is_not_nil(uni.upper)
   end)

   it("errors when the input is not a string", function()
      assert.has_error(function()
         uni.upper(nil)
      end, "bad argument #1 to 'upper' (string expected)")
   end)

   it("works with ASCII text", function()
      assert.are.same(as_codepoints("HELLO"), as_codepoints(uni.upper("heLLo")))
   end)

   it("works with Cyrillic text", function()
      assert.are.same(as_codepoints("РУССКИЙ"), as_codepoints(uni.upper("русский")))
   end)

   it("works with combining diacritics", function()
      assert.are_same(as_codepoints("À"), as_codepoints(uni.upper("à")))
   end)

   it("works with null sequences", function()
      assert.are_same(as_codepoints("A\0B"), as_codepoints(uni.upper("a\0b")))
   end)
end)
