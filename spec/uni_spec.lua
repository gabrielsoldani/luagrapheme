local luagrapheme = require("luagrapheme")

describe("luagrapheme._VERSION", function()
   it("is a string", function()
      assert.is_string(luagrapheme._VERSION)
   end)

   describe("is valid", function()
      local version_pattern = "^(%d+)%.(%d+)%.(%d+)$"

      it("matches the pattern", function()
         assert.matches(version_pattern, luagrapheme._VERSION)
      end)

      it("does not contain leading zeroes", function()
         local major, minor, patch = luagrapheme._VERSION:match(version_pattern)
         assert.is_true(major == "0" or not major:match("^0"))
         assert.is_true(minor == "0" or not minor:match("^0"))
         assert.is_true(patch == "0" or not patch:match("^0"))
      end)
   end)
end)
