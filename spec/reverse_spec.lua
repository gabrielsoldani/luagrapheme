local uni = require("uni")
local utils = require("spec.utils")
local as_codepoints = utils.as_codepoints

describe("uni.reverse", function()
   it("exists", function()
      assert.is_not_nil(uni.lower)
   end)

   it("errors when the input is not a string", function()
      assert.has_error(function()
         uni.reverse(nil)
      end, "bad argument #1 to 'reverse' (string expected)")
   end)

   it("works with ASCII characters", function()
      assert.are.same(as_codepoints("olleh"), as_codepoints(uni.reverse("hello")))
   end)

   it("works with multi-code point grapheme clusters", function()
      assert.are.same(as_codepoints("👩‍🚀 auL"), as_codepoints(uni.reverse("Lua 👩‍🚀")))
   end)
end)
