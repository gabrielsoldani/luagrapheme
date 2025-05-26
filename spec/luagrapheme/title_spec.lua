local luagrapheme = require("luagrapheme")
local utils = require("spec.utils")
local as_codepoints = utils.as_codepoints

describe("luagrapheme.title", function()
   it("should be callable", function()
      assert.is_callable(luagrapheme.title)
   end)

   describe("should check arguments", function()
      it("should error when no arguments are provided", function()
         assert.has_error(function()
            luagrapheme.title()
         end, "bad argument #1 to 'title' (string expected, got no value)")
      end)

      it("should error when argument #1 is nil", function()
         assert.has_error(function()
            luagrapheme.title(nil)
         end, "bad argument #1 to 'title' (string expected, got nil)")
      end)

      local inputs = {
         true,
         {},
         function() end,
         coroutine.create(function() end),
      }

      for _, input in ipairs(inputs) do
         it("should error when argument #1 is " .. type(input), function()
            local expected_error = "bad argument #1 to 'title' (string expected, got " .. type(input) .. ")"
            assert.has_error(function()
               luagrapheme.title(input)
            end, expected_error)
         end)
      end
   end)

   it("works with empty strings", function()
      assert.are.same("", luagrapheme.title(""))
   end)

   it("works with integers", function()
      assert.are.same("123", luagrapheme.title(123))
   end)

   it("works with non-integer numbers", function()
      assert.are.same("123.45", luagrapheme.title(123.45))
   end)

   it("works with ASCII text", function()
      assert.are.same(as_codepoints("Hello World"), as_codepoints(luagrapheme.title("heLLo world")))
   end)

   it("works with Cyrillic text", function()
      assert.are.same(as_codepoints("Русский"), as_codepoints(luagrapheme.title("РУССКИЙ")))
   end)

   it("works with combining diacritics", function()
      assert.are_same(as_codepoints("Àa Bb"), as_codepoints(luagrapheme.title("àa bb")))
   end)

   it("works with null sequences", function()
      assert.are_same(as_codepoints("Aa\0Bb"), as_codepoints(luagrapheme.title("aa\0bb")))
   end)
end)
