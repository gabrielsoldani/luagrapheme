local GraphemeOneOf = require("uni.lpeg_ext").GraphemeOneOf

describe("uni.lpeg_ext.GraphemeOneOf", function()
   it("exists", function()
      assert.is_not_nil(GraphemeOneOf)
   end)

   it("works with ASCII text", function()
      local grapheme = GraphemeOneOf("h", "e", "l", "o")
      local pattern = grapheme * grapheme * grapheme
      local s = "hello"

      local pos = pattern:match(s)
      assert.are.equal(4, pos)
   end)

   it("works with multi-code point grapheme clusters", function()
      local grapheme = GraphemeOneOf("h", "e", "👩‍🚀")
      local pattern = grapheme * grapheme * grapheme
      local s = "he👩‍🚀llo"

      local pos = pattern:match(s)
      assert.are_equal(14, pos)
   end)
end)
