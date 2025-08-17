local segments = require("examples.segments")

describe("example.segments", function()
   local stdin, stdout, stderr

   before_each(function()
      stdin = io.tmpfile()
      stdout = io.tmpfile()
      stderr = io.tmpfile()
   end)

   after_each(function()
      stdin:close()
      stdout:close()
      stderr:close()
   end)

   it("should print usage when called with invalid arguments", function()
      local arg = { "paragraphs" }
      local result = segments(arg, stdin, stdout, stderr)

      assert.are.same(1, result)
      stderr:seek("set")
      local error_message = stderr:read("*a")
      assert.matches("^Usage:", error_message)
   end)

   local cases = {
      {
         args = { "g" },
         input = "Hello, 世界",
         expected = {
            '1\t1\t"H"',
            '2\t2\t"e"',
            '3\t3\t"l"',
            '4\t4\t"l"',
            '5\t5\t"o"',
            '6\t6\t","',
            '7\t7\t" "',
            '8\t10\t"世"',
            '11\t13\t"界"',
         },
      },
      {
         args = { "lines" },
         input = "foo bar baz",
         expected = {
            '1\t4\t"foo "',
            '5\t8\t"bar "',
            '9\t11\t"baz"',
         },
      },
      {
         args = { "sentences" },
         input = "Hello, world! How are you? I am fine.",
         expected = {
            '1\t14\t"Hello, world! "',
            '15\t27\t"How are you? "',
            '28\t37\t"I am fine."',
         },
      },
      {
         args = { "words" },
         input = "Sphinx of black quartz: judge my vow.",
         expected = {
            '1\t6\t"Sphinx"',
            '7\t7\t" "',
            '8\t9\t"of"',
            '10\t10\t" "',
            '11\t15\t"black"',
            '16\t16\t" "',
            '17\t22\t"quartz"',
            '23\t23\t":"',
            '24\t24\t" "',
            '25\t29\t"judge"',
            '30\t30\t" "',
            '31\t32\t"my"',
            '33\t33\t" "',
            '34\t36\t"vow"',
            '37\t37\t"."',
         },
      },
   }

   for caseno, case in ipairs(cases) do
      it("should handle case #" .. caseno, function()
         local arg = case.args
         local input_text = case.input

         stdin:write(input_text)
         stdin:flush()
         stdin:seek("set")

         local result = segments(arg, stdin, stdout, stderr)

         assert.are.same(0, result)

         stdout:seek("set")
         for i = 1, #case.expected do
            local line = stdout:read("*l")
            assert.are.same(case.expected[i], line)
         end
      end)
   end
end)
