local luagrapheme = require("luagrapheme")
local utils = require("spec.utils")
local as_codepoints = utils.as_codepoints

describe("luagrapheme.lower", function()
   it("should be callable", function()
      assert.is_callable(luagrapheme.lower)
   end)

   describe("should check arguments", function()
      it("should error when no arguments are provided", function()
         assert.has_error(function()
            luagrapheme.lower()
         end, "bad argument #1 to 'lower' (string expected, got no value)")
      end)

      it("should error when argument #1 is nil", function()
         assert.has_error(function()
            luagrapheme.lower(nil)
         end, "bad argument #1 to 'lower' (string expected, got nil)")
      end)

      local inputs = {
         true,
         {},
         function() end,
         coroutine.create(function() end),
      }

      for _, input in ipairs(inputs) do
         it("should error when argument #1 is " .. type(input), function()
            local expected_error = "bad argument #1 to 'lower' (string expected, got " .. type(input) .. ")"
            assert.has_error(function()
               luagrapheme.lower(input)
            end, expected_error)
         end)
      end
   end)

   it("works with empty strings", function()
      assert.are.same("", luagrapheme.lower(""))
   end)

   it("works with integers", function()
      assert.are.same("123", luagrapheme.lower(123))
   end)

   it("works with non-integer numbers", function()
      assert.are.same("123.45", luagrapheme.lower(123.45))
   end)

   it("works with ASCII text", function()
      assert.are.same(as_codepoints("hello"), as_codepoints(luagrapheme.lower("heLLo")))
   end)

   it("works with Cyrillic text", function()
      assert.are.same(as_codepoints("русский"), as_codepoints(luagrapheme.lower("РУССКИЙ")))
   end)

   it("works with combining diacritics", function()
      assert.are_same(as_codepoints("à"), as_codepoints(luagrapheme.lower("À")))
   end)

   it("works with null sequences", function()
      assert.are_same(as_codepoints("a\0b"), as_codepoints(luagrapheme.lower("A\0B")))
   end)
end)
