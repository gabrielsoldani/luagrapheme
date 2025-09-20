#!/usr/bin/env lua
--[[
   list.lua: Convert a markdown-like language to HTML, supporting lists
   with custom bullets.

   Usage: ./list.lua < input.txt > output.html
   or:    lua list.lua < input.txt > output.html

   The input format is a simplified markdown-like syntax:

   - A list item starts with a grapheme cluster, followed by a space,
     and then any text until the end of the line.
   - The grapheme cluster at the start of a list item is used as
     the bullet for that item.
   - Consecutive list items form a list block.
   - Other lines are treated as paragraphs.
   - Empty lines separate blocks (lists or paragraphs).

   Example input:

      👩‍🚀 This is a list item
      ✅ and this is another one.

      ✅ This is a separate list.

      This is a paragraph.
      This is part of the same paragraph.

      And this is another paragraph.

   Example output:
      ...
      <ul>
        <li data-bullet="👩‍🚀">This is a list item</li>
        <li data-bullet="✅">and this is another one.</li>
      </ul>
      <ul>
        <li data-bullet="✅">This is a separate list.</li>
      </ul>
      <p>
         This is a paragraph.
         This is part of the same paragraph.
      </p>
      <p>
        And this is another paragraph.
      </p>
      ...
]]--

local lglpeg = require("luagrapheme.lpeg")
local lpeg = require("lpeg")
local P, V = lpeg.P, lpeg.V
local C, Ct = lpeg.C, lpeg.Ct
local G = lglpeg.G

local EOL = P("\n") + P("\r\n")
local Space = P(" ")

local Document = V("Document")
local Block = V("Block")
local ListBlock = V("ListBlock")
local ListItem = V("ListItem")
local ParagraphBlock = V("ParagraphBlock")
local ParagraphLine = V("ParagraphLine")

local grammar = P({
   Document,
   Document = Ct(Block ^ 0) * -1,
   Block = (ListBlock + ParagraphBlock) * (EOL ^ 0),
   ListBlock = (ListItem ^ 1) / function(...)
      return { type = "list", ... }
   end,
   ListItem = (C(G()) * Space * C((1 - EOL) ^ 1)) / function(bullet, text)
      return { bullet = bullet, text = text }
   end * EOL,
   ParagraphBlock = ((ParagraphLine ^ 1) / function(...)
      return { type = "paragraph", ... }
   end),
   ParagraphLine = C((1 - EOL) ^ 1) * EOL,
})

local function render_html(ast, file)
   file:write("<!DOCTYPE html>\n")
   file:write("<html>\n")
   file:write("<head>\n")
   file:write("  <meta charset='utf-8'>\n")
   file:write("  <style>\n")
   file:write("    li[data-bullet]::marker { content: attr(data-bullet) '\\a0'; }\n")
   file:write("  </style>\n")
   file:write("</head>\n")
   file:write("<body>\n")

   for _, block in ipairs(ast) do
      if block.type == "list" then
         file:write("<ul>\n")
         for _, item in ipairs(block) do
            file:write('  <li data-bullet="', item.bullet, '">', item.text, "</li>\n")
         end
         file:write("</ul>\n")
      elseif block.type == "paragraph" then
         file:write("<p>\n")
         for _, line in ipairs(block) do
            file:write("  ", line, "\n")
         end
         file:write("</p>\n")
      else
         error("Unknown block type: " .. tostring(block.type))
      end
   end

   file:write("</body>\n")
   file:write("</html>\n")
end

local function main(arg, stdin, stdout, stderr)
   if #arg > 0 then
      local script_name = arg[0] or "./list.lua"
      stderr:write("Usage: ", script_name, " < input.txt > output.html\n")
      return 1
   end

   local text = stdin:read("*a")

   local ast = grammar:match(text)
   if ast == nil then
      stderr:write("Failed to parse input\n")
      return 1
   end

   render_html(ast, stdout)

   return 0
end

if not pcall(debug.getlocal, 4, 1) then
   return main(arg, io.stdin, io.stdout, io.stderr)
else
   return main
end
