local lglpeg = require("luagrapheme.lpeg")
local lpeg = require("lpeg")

describe("luagrapheme.lpeg.G", function()
   it("should be callable", function()
      assert.is_callable(lglpeg.G)
   end)

   it("should return a pattern", function()
      local p = lglpeg.G()
      assert.are_equal("pattern", lpeg.type(p))
   end)

   it("should capture graphemes", function()
      local p = lpeg.C(lglpeg.G()) ^ 0 * -1
      local s = "he👩‍🚀llo"

      local expected = { "h", "e", "👩‍🚀", "l", "l", "o" }
      assert.are.same(expected, { p:match(s) })
   end)

   it("should not crash when given the empty string", function()
      local p = lglpeg.G() * -1
      local s = ""

      assert.are.same(nil, p:match(s))
   end)
end)
