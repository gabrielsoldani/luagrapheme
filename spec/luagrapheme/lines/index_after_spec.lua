local luagrapheme = require("luagrapheme")
local lines = luagrapheme.lines

describe("luagrapheme.lines.index_after", function()
   -- TODO: Check if it is callable
   it("should be callable", function()
      assert.is_callable(lines.index_after)
   end)

   describe("should check argument types", function()
      it("should error when no arguments are provided", function()
         assert.has_error(function()
            lines.index_after()
         end, "bad argument #1 to 'index_after' (string expected, got no value)")
      end)

      it("should error when argument #1 is nil", function()
         assert.has_error(function()
            lines.index_after(nil, 1)
         end, "bad argument #1 to 'index_after' (string expected, got nil)")
      end)

      local inputs = {
         true,
         {},
         function() end,
         coroutine.create(function() end),
      }

      for _, input in ipairs(inputs) do
         it("should error when argument #1 is " .. type(input), function()
            local expected_error = "bad argument #1 to 'index_after' (string expected, got " .. type(input) .. ")"
            assert.has_error(function()
               lines.index_after(input, 1)
            end, expected_error)
         end)
      end
   end)

   describe("should check index bounds", function()
      it("should error when index is negative", function()
         assert.has_error(function()
            lines.index_after("hello", -1)
         end, "bad argument #2 to 'index_after' (index out of range)")
      end)

      it("should error when index is zero", function()
         assert.has_error(function()
            lines.index_after("hello", 0)
         end, "bad argument #2 to 'index_after' (index out of range)")
      end)

      it("should error when index is greater than string length + 1", function()
         assert.has_error(function()
            lines.index_after("hello", 7)
         end, "bad argument #2 to 'index_after' (index out of range)")
      end)
   end)

   local cases = {
      {
         input = "Lua 5.4 was released on 2020-06-29, adding to-be-closed variables (see § 3.3.8).",
         subcases = {
            { after = 1, expected = 10 },
            { after = 10, expected = 14 },
            { after = 14, expected = 23 },
            { after = 23, expected = 26 },
            { after = 26, expected = 38 },
            { after = 38, expected = 45 },
            { after = 45, expected = 48 },
            { after = 48, expected = 51 },
            { after = 51, expected = 58 },
            { after = 58, expected = 68 },
            { after = 68, expected = 73 },
            { after = 73, expected = 85 },
            { after = 85, expected = nil },
         },
      },
   }

   for _, case in ipairs(cases) do
      local input = case.input
      for _, subcase in ipairs(case.subcases) do
         local after = subcase.after
         local expected = subcase.expected

         it("(" .. input .. ", " .. after .. ") should return " .. tostring(expected), function()
            local result = lines.index_after(input, after)
            assert.are.same(expected, result)
         end)
      end
   end
end)
