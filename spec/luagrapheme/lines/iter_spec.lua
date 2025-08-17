local luagrapheme = require("luagrapheme")
local lines = luagrapheme.lines

local tests = {
   { name = "luagrapheme.lines.iter", sut = lines.iter },
   { name = "luagrapheme.lines.__call", sut = lines },
}

for _, test in ipairs(tests) do
   local sut = test.sut
   describe(test.name, function()
      -- TODO: Check if it is callable
      it("should be callable", function()
         assert.is_callable(sut)
      end)

      describe("should check arguments", function()
         it("should error when no arguments are provided", function()
            assert.has_error(function()
               sut()
            end, "bad argument #1 to 'sut' (string expected, got no value)")
         end)

         it("should error when argument #1 is nil", function()
            assert.has_error(function()
               sut(nil)
            end, "bad argument #1 to 'sut' (string expected, got nil)")
         end)

         local inputs = {
            true,
            {},
            function() end,
            coroutine.create(function() end),
         }

         for _, input in ipairs(inputs) do
            it("should error when argument #1 is " .. type(input), function()
               local expected_error = "bad argument #1 to 'sut' (string expected, got " .. type(input) .. ")"
               assert.has_error(function()
                  sut(input)
               end, expected_error)
            end)
         end
      end)

      describe("should return an iterator", function()
         local cases = {
            {
               text = "that iterates over integers",
               input = 123,
               expected = {
                  { "123", 1, 3 },
               },
            },
            {
               text = "that iterates over non-integer numbers",
               input = 123.45,
               expected = {
                  { "123.45", 1, 6 },
               },
            },
            {
               text = "that iterates over an empty string",
               input = "",
               expected = {},
            },
            {
               text = "that iterates over line break opportunities",
               input = "Lua 5.4 was released on 2020-06-29, adding to-be-closed variables (see § 3.3.8).",
               expected = {
                  { "Lua 5.4 ", 1, 9 },
                  { "was ", 10, 13 },
                  { "released ", 14, 22 },
                  { "on ", 23, 25 },
                  { "2020-06-29, ", 26, 37 },
                  { "adding ", 38, 44 },
                  { "to-", 45, 47 },
                  { "be-", 48, 50 },
                  { "closed ", 51, 57 },
                  { "variables ", 58, 67 },
                  { "(see ", 68, 72 },
                  { "§ 3.3.8).", 73, 84 },
               },
            },
         }

         for _, case in ipairs(cases) do
            it(case.text, function()
               local n = 0
               for i, j in sut(case.input) do
                  n = n + 1
                  local output = { tostring(case.input):sub(i, j), i, j }
                  local expected = case.expected[n]
                  assert.are.same(expected, output)
               end
               assert.are.equal(#case.expected, n)
            end)
         end
      end)
   end)
end
