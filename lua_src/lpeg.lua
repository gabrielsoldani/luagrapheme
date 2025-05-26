local lpeg = require("lpeg")
local luagrapheme = require("luagrapheme")

local _M = {}

_M._VERSION = luagrapheme._VERSION

local _G =
   -- Capture one byte so LPeg knows our pattern cannot match the empty string,
   -- so it allows us to use it as a loop body.
   lpeg.Cmt(lpeg.P(1), function(subject, index_plus_one)
      local index = index_plus_one - 1
      return luagrapheme.graphemes.index_after(subject, index) or #subject + 1
      -- for _, j in graphemes.iter(subject, index) do
      --    print("\ns", subject, "index", index, "j", j, "after", graphemes.index_after(subject, index))
      --    return j + 1
      -- end
      -- print("\ns", subject, "index", index, "ret", false, "after", graphemes.index_after(subject, index))
      -- return false
   end)

function _M.G()
   return _G
end

local _L = lpeg.Cmt(lpeg.P(1), function(subject, index_plus_one)
   local index = index_plus_one - 1
   return luagrapheme.lines.index_after(subject, index) or #subject + 1
end)

function _M.L()
   return _L
end

local _S = lpeg.Cmt(lpeg.P(1), function(subject, index_plus_one)
   local index = index_plus_one - 1
   return luagrapheme.sentences.index_after(subject, index) or #subject + 1
end)

function _M.S()
   return _S
end

local _W = lpeg.Cmt(lpeg.P(1), function(subject, index_plus_one)
   local index = index_plus_one - 1
   return luagrapheme.words.index_after(subject, index) or #subject + 1
end)

function _M.W()
   return _W
end

return _M
