local luagrapheme = require("luagrapheme")
local utils = require("spec.utils")
local as_codepoints = utils.as_codepoints

describe("luagrapheme.reverse", function()
   it("exists", function()
      assert.is_not_nil(luagrapheme.lower)
   end)

   it("errors when argument #1 is not a string", function()
      assert.has_error(function()
         luagrapheme.reverse()
      end, "bad argument #1 to 'reverse' (string expected, got no value)")
      assert.has_error(function()
         luagrapheme.reverse(nil)
      end, "bad argument #1 to 'reverse' (string expected, got nil)")
      assert.has_no_error(function()
         luagrapheme.reverse("hello")
      end)
   end)

   it("works with ASCII characters", function()
      assert.are.same(as_codepoints("olleh"), as_codepoints(luagrapheme.reverse("hello")))
   end)

   it("works with multi-code point grapheme clusters", function()
      assert.are.same(as_codepoints("👩‍🚀 auL"), as_codepoints(luagrapheme.reverse("Lua 👩‍🚀")))
   end)
end)
