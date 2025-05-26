local luagrapheme = require("luagrapheme")
local utils = require("spec.utils")
local as_codepoints = utils.as_codepoints

describe("luagrapheme.upper", function()
   it("should be callable", function()
      assert.is_callable(luagrapheme.upper)
   end)

   describe("should check arguments", function()
      it("should error when no arguments are provided", function()
         assert.has_error(function()
            luagrapheme.upper()
         end, "bad argument #1 to 'upper' (string expected, got no value)")
      end)

      it("should error when argument #1 is nil", function()
         assert.has_error(function()
            luagrapheme.upper(nil)
         end, "bad argument #1 to 'upper' (string expected, got nil)")
      end)

      local inputs = {
         true,
         {},
         function() end,
         coroutine.create(function() end),
      }

      for _, input in ipairs(inputs) do
         it("should error when argument #1 is " .. type(input), function()
            local expected_error = "bad argument #1 to 'upper' (string expected, got " .. type(input) .. ")"
            assert.has_error(function()
               luagrapheme.upper(input)
            end, expected_error)
         end)
      end
   end)

   it("works with empty strings", function()
      assert.are.same("", luagrapheme.upper(""))
   end)

   it("works with integers", function()
      assert.are.same("123", luagrapheme.upper(123))
   end)

   it("works with non-integer numbers", function()
      assert.are.same("123.45", luagrapheme.upper(123.45))
   end)

   it("works with ASCII text", function()
      assert.are.same(as_codepoints("HELLO"), as_codepoints(luagrapheme.upper("heLLo")))
   end)

   it("works with Cyrillic text", function()
      assert.are.same(as_codepoints("РУССКИЙ"), as_codepoints(luagrapheme.upper("русский")))
   end)

   it("works with combining diacritics", function()
      assert.are_same(as_codepoints("À"), as_codepoints(luagrapheme.upper("à")))
   end)

   it("works with null sequences", function()
      assert.are_same(as_codepoints("A\0B"), as_codepoints(luagrapheme.upper("a\0b")))
   end)
end)
