local list = require("examples.list")

describe("examples.list", function()
   local stdin, expected, stdout, stderr

   before_each(function()
      stdin = nil
      expected = nil
      stdout = io.tmpfile()
      stderr = io.tmpfile()
   end)

   after_each(function()
      if stdin then
         stdin:close()
      end
      if expected then
         expected:close()
      end
      stdout:close()
      stderr:close()
   end)

   it("should print usage when called with invalid arguments", function()
      local arg = { "invalid" }
      local result = list(arg, stdin, stdout, stderr)

      assert.are.same(1, result)
      stderr:seek("set")
      local error_message = stderr:read("*a")
      assert.matches("^Usage:", error_message)
   end)

   local cases = {
      "basic-english",
      "basic-portuguese",
   }

   for _, case in ipairs(cases) do
      it("should handle case " .. case, function()
         stdin = io.open("spec/examples/list/data/" .. case .. "/input.txt", "r")
         assert.is_not_nil(stdin)

         local result = list(arg, stdin, stdout, stderr)
         assert.are.same(0, result)

         stdout:seek("set")

         expected = io.open("spec/examples/list/data/" .. case .. "/expected.html", "r")
         assert.is_not_nil(expected)

         repeat
            local expected_line = expected:read("*l")
            local output_line = stdout:read("*l")
            assert.are.equal(expected_line, output_line)
         until expected_line == nil or output_line == nil
      end)
   end
end)
