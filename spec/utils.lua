require("compat53")
local utf8 = require("utf8")

local utils = {}

function utils.as_codepoints(s)
   local result = {}
   for _, codepoint in utf8.codes(s) do
      result[#result + 1] = string.format("U+%04X %s", codepoint, utf8.char(codepoint))
   end
   return result
end

return utils
