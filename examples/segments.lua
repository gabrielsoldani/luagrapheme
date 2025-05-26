#!/usr/bin/env lua
local luagrapheme = require("luagrapheme")

local function segment_text(segment_fn, input_file, output_file)
   local input_text = input_file:read("*a")
   for i, j in segment_fn(input_text) do
      local segment = input_text:sub(i, j)
      local quoted_segment = string.format("%q", segment):gsub("\\\n", "\\n")
      output_file:write(i, "\t", j, "\t", quoted_segment, "\n")
   end
end

local segment_type_to_fn = {
   ["graphemes"] = luagrapheme.graphemes,
   ["g"] = luagrapheme.graphemes,
   ["lines"] = luagrapheme.lines,
   ["l"] = luagrapheme.lines,
   ["sentences"] = luagrapheme.sentences,
   ["s"] = luagrapheme.sentences,
   ["words"] = luagrapheme.words,
   ["w"] = luagrapheme.words,
}

local function main(arg, stdin, stdout, stderr)
   local segment_type = #arg > 0 and arg[1] or "g"
   local segment_fn = segment_type_to_fn[segment_type]
   if #arg > 1 or segment_fn == nil then
      stderr:write("Usage: segments [gwls]\n")
      return 1
   end

   segment_text(segment_fn, stdin, stdout)
   return 0
end

if not pcall(debug.getlocal, 4, 1) then
   return main(arg, io.stdin, io.stdout, io.stderr)
else
   return main
end
