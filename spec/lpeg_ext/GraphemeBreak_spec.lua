local GraphemeBreak = require("uni.lpeg_ext").GraphemeBreak
local anywhere = require("spec.lpeg_ext.utils").anywhere

describe("uni.lpeg_ext.GraphemeBreak", function()
   it("exists", function()
      assert.is_not_nil(GraphemeBreak)
   end)

   it("matches the end of the string", function()
      local pattern = "hi" * GraphemeBreak * -1
      local s = "hi"
      local pos = pattern:match(s)
      assert.are.equal(3, pos)
   end)

   it("works with an empty string", function()
      local pattern = GraphemeBreak * -1
      local s = ""
      local pos = pattern:match(s)
      assert.are.equal(1, pos)
   end)

   it("works with ASCII text", function()
      local pattern = GraphemeBreak
         * "h"
         * GraphemeBreak
         * "e"
         * GraphemeBreak
         * "l"
         * GraphemeBreak
         * "l"
         * GraphemeBreak
         * "o"
         * -1

      local s = "hello"

      local pos = pattern:match(s)
      assert.are.equal(6, pos)
   end)

   it("works with multi-code point grapheme clusters", function()
      local pattern = anywhere(GraphemeBreak * "🚀")
      local s = "he👩‍🚀ll🚀o"

      local pos = pattern:match(s)
      assert.are_equal(16, pos)
   end)
end)
