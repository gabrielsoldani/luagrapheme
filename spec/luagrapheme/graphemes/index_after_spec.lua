local luagrapheme = require("luagrapheme")
local graphemes = luagrapheme.graphemes

describe("luagrapheme.graphemes.index_after", function()
   -- TODO: Check if it is callable
   it("should be callable", function()
      assert.is_callable(graphemes.index_after)
   end)

   describe("should check arguments", function()
      it("should error when no arguments are provided", function()
         assert.has_error(function()
            graphemes.index_after()
         end, "bad argument #1 to 'index_after' (string expected, got no value)")
      end)

      it("should error when argument #1 is nil", function()
         assert.has_error(function()
            graphemes.index_after(nil, 1)
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
               graphemes.index_after(input, 1)
            end, expected_error)
         end)
      end
   end)

   local cases = {
      {
         input = "hello",
         subcases = {
            { after = 1, expected = 2 },
            { after = 2, expected = 3 },
            { after = 3, expected = 4 },
            { after = 4, expected = 5 },
            { after = 5, expected = nil },
         },
      },
   }

   for _, case in ipairs(cases) do
      local input = case.input
      for _, subcase in ipairs(case.subcases) do
         local after = subcase.after
         local expected = subcase.expected

         it("(" .. input .. ", " .. after .. ") should return " .. tostring(expected), function()
            local result = graphemes.index_after(input, after)
            assert.are.same(expected, result)
         end)
      end
   end
end)
