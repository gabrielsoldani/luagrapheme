#!/usr/bin/env lua
local lglpeg = require("luagrapheme.lpeg")
local lpeg = require("lpeg")
local luagrapheme = require("luagrapheme")

local function increment_count(counts, word)
   counts[word] = (counts[word] or 0) + 1
   return counts
end

local function count_words(input_text)
   local W = lglpeg.W()
   local pattern = lpeg.Cc({}) * ((lpeg.C(W) / luagrapheme.lower) % increment_count) ^ 0
   return pattern:match(input_text)
end

local function sort_counts(counts)
   local keys = {}
   for word in pairs(counts) do
      keys[#keys + 1] = word
   end
   table.sort(keys, function(a, b)
      local count_a = counts[a]
      local count_b = counts[b]
      return count_a > count_b or (count_a == count_b and a < b)
   end)
   return keys
end

local function print_words(stdout, counts, sorted_words)
   for _, word in ipairs(sorted_words) do
      local quoted_word = string.format("%q", word):gsub("\\\n", "\\n")
      stdout:write(counts[word], "\t", quoted_word, "\n")
   end
end

local function main(arg, stdin, stdout, stderr)
   if #arg > 0 then
      stderr:write("Usage: wordcount\n")
      return 1
   end

   local input_text = stdin:read("*a")
   local counts = count_words(input_text)
   local sorted_words = sort_counts(counts)
   print_words(stdout, counts, sorted_words)

   return 0
end

if not pcall(debug.getlocal, 4, 1) then
   return main(arg, io.stdin, io.stdout, io.stderr)
else
   return main
end
