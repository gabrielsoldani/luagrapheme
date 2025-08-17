local luagrapheme = require("luagrapheme")
local graphemes = luagrapheme.graphemes

local tests = {
   { name = "luagrapheme.graphemes.iter", sut = graphemes.iter },
   { name = "luagrapheme.graphemes.__call", sut = graphemes },
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
                  { "1", 1, 1 },
                  { "2", 2, 2 },
                  { "3", 3, 3 },
               },
            },
            {
               text = "that iterates over non-integer numbers",
               input = 123.45,
               expected = {
                  { "1", 1, 1 },
                  { "2", 2, 2 },
                  { "3", 3, 3 },
                  { ".", 4, 4 },
                  { "4", 5, 5 },
                  { "5", 6, 6 },
               },
            },
            {
               text = "that iterates over an empty string",
               input = "",
               expected = {},
            },
            {
               text = "that iterates over ASCII text",
               input = "hello",
               expected = {
                  { "h", 1, 1 },
                  { "e", 2, 2 },
                  { "l", 3, 3 },
                  { "l", 4, 4 },
                  { "o", 5, 5 },
               },
            },
            {
               text = "that iterates over multi-code point grapheme clusters",
               input = "he👩‍🚀llo",
               expected = {
                  { "h", 1, 1 },
                  { "e", 2, 2 },
                  { "👩‍🚀", 3, 13 },
                  { "l", 14, 14 },
                  { "l", 15, 15 },
                  { "o", 16, 16 },
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
                  assert.are.same(output, expected)
               end
               assert.are.equal(n, #case.expected)
            end)
         end
      end)
   end)
end
