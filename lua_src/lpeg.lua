local lpeg = require("lpeg")
local luagrapheme = require("luagrapheme")

local _M = {}

_M._VERSION = luagrapheme._VERSION

local _G = lpeg.Cmt(lpeg.P(1), function(subject, index_plus_one)
   -- Capture one byte so LPeg knows our pattern cannot match the empty string,
   -- so it allows us to use it as a loop body.
   local index = index_plus_one - 1
   return luagrapheme.graphemes.index_after(subject, index)
end)

function _M.G()
   -- Reuse singleton.
   return _G
end

local _L = lpeg.Cmt(lpeg.P(1), function(subject, index_plus_one)
   local index = index_plus_one - 1
   return luagrapheme.lines.index_after(subject, index)
end)

function _M.L()
   -- Reuse singleton.
   return _L
end

local _S = lpeg.Cmt(lpeg.P(1), function(subject, index_plus_one)
   local index = index_plus_one - 1
   return luagrapheme.sentences.index_after(subject, index)
end)

function _M.S()
   -- Reuse singleton.
   return _S
end

local _W = lpeg.Cmt(lpeg.P(1), function(subject, index_plus_one)
   local index = index_plus_one - 1
   return luagrapheme.words.index_after(subject, index)
end)

function _M.W()
   -- Reuse singleton.
   return _W
end

return _M
