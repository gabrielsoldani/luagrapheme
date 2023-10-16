local uni = require("uni")

describe("uni.lower", function()
   it("exists", function()
      assert.is_not_nil(uni.lower)
   end)

   it("errors when the input is not a string", function()
      assert.has_error(function()
         uni.lower(nil)
      end, "bad argument #1 to 'lower' (string expected)")
   end)

   it("works with ASCII text", function()
      assert.are.equal("hello", uni.lower("heLLo"))
   end)

   it("works with Cyrillic text", function()
      assert.are.equal("русский", uni.lower("РУССКИЙ"))
   end)

   it("works with combining diacritics", function()
      assert.are_equal("à", uni.lower("À"))
   end)

   it("works with null sequences", function()
      assert.are_equal("a\0b", uni.lower("A\0B"))
   end)
end)
