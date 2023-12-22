local lpeg = require("lpeg")
local uni = require("uni")

local lpeg_ext = {}

lpeg_ext.GraphemeBreak = lpeg.P(uni.is_grapheme_break)

lpeg_ext.GraphemeCount = function(count)
   return lpeg.P(uni._lpeg_ext_GraphemeCount(count))
end

lpeg_ext.GraphemeOneOf = function(...)
   return lpeg.P(uni._lpeg_ext_GraphemeOneOf(...))
end

return lpeg_ext
