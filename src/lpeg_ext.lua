local lpeg = require("lpeg")
local uni = require("uni")

local lpeg_ext = {}

lpeg_ext.GraphemeBreak = lpeg.P(uni.is_grapheme_break)

lpeg_ext.GraphemeCount = function(count)
   return lpeg.P(uni._match_n_graphemes(count))
end

lpeg_ext.GraphemeOneOf = function(...)
   return lpeg.P(uni._match_one_of_graphemes(...))
end

return lpeg_ext
