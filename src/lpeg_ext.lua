local lpeg = require("lpeg")
local uni = require("uni")

local lpeg_ext = {}

lpeg_ext.GraphemeBreak = lpeg.P(uni.is_grapheme_break)

return lpeg_ext
