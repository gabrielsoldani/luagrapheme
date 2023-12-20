local GraphemeCount = require("uni.lpeg_ext").GraphemeCount

describe("uni.lpeg_ext.GraphemeCount", function()
   it("exists", function()
      assert.is_not_nil(GraphemeCount)
   end)

   it("works with ASCII text", function()
      local pattern = GraphemeCount(2)
      local s = "hello"

      local pos = pattern:match(s)
      assert.are.equal(3, pos)
   end)

   it("works with multi-code point grapheme clusters", function()
      local pattern = GraphemeCount(4)
      local s = "he👩‍🚀llo"

      local pos = pattern:match(s)
      assert.are_equal(15, pos)
   end)
end)
