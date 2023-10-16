local uni = require("uni")

describe("uni.len", function()
   it("exists", function()
      assert.is_not_nil(uni.len)
   end)

   it("errors when the input is not a string", function()
      assert.has_error(function()
         uni.len(nil)
      end, "bad argument #1 to 'len' (string expected)")
   end)

   it("works with an empty string", function()
      assert.are.equal(0, uni.len(""))
   end)

   it("works with ASCII text", function()
      assert.are.equal(3, uni.len("Lua"))
   end)

   it("works with multi-code point grapheme clusters", function()
      assert.are.equal(6, uni.len("he👩‍🚀llo"))
   end)
end)
