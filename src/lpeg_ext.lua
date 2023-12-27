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
   return lpeg.P(uni._match_one_of_graphemes(...))
end

return lpeg_ext
