local lpeg = require("lpeg")

local utils = {}

function utils.anywhere(p)
   return lpeg.P({ lpeg.Cp() * p * lpeg.Cp() + 1 * lpeg.V(1) })
end

return utils
