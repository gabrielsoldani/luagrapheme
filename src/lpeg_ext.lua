local lpeg = require("lpeg")
local uni = require("uni")

local lpeg_ext = {}

lpeg_ext.GraphemeBreak = lpeg.P(uni.is_grapheme_break)

lpeg_ext.GraphemeCount = function(count)
   local match_count_graphemes = uni._match_n_graphemes(count)
   return lpeg.Cmt(lpeg.P(count), function(s, i)
      return match_count_graphemes(s, i - count)
   end)
end

lpeg_ext.GraphemeOneOf = function(...)
   local first_characters = {}
   for i, grapheme in ipairs({ ... }) do
      first_characters[i] = grapheme:sub(1, 1)
   end
   local set_pattern = lpeg.S(table.concat(first_characters))

   local match_one_of_graphemes = uni._match_one_of_graphemes(...)
   return lpeg.Cmt(set_pattern, function(s, i)
      return match_one_of_graphemes(s, i - 1)
   end)
end

return lpeg_ext
