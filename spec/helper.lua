local assert = require("luassert.assert")

local function is_callable(_, arguments, _)
   table.insert(arguments, 2, "function or callable object")
   arguments.nofmt = arguments.nofmt or {}
   arguments.nofmt[2] = true

   if #arguments ~= 2 then
      return false
   end

   if type(arguments[1]) == "function" then
      return true
   end

   local mt = debug.getmetatable(arguments[1])
   if not mt then
      return false
   end

   return type(rawget(mt, "__call")) == "function"
end

assert:register("assertion", "callable", is_callable, "assertion.same.positive", "assertion.same.negative")

local branch_pattern = "^[^%.%d]+$"
local semver_pattern = "^(%d+)%.(%d+)%.(%d+)$"

local function is_version(_, arguments, _)
   table.insert(arguments, 2, "string")
   arguments.nofmt = arguments.nofmt or {}
   arguments.nofmt[2] = true

   if #arguments ~= 2 then
      return false
   end

   local version = arguments[1]

   if type(arguments[1]) ~= "string" then
      return false
   end

   if not (version:match(branch_pattern) or version:match(semver_pattern)) then
      return false
   end

   local major, minor, patch = version:match(semver_pattern)
   if major and minor and patch then
      if not (major == "0" or not major:match("^0")) then
         return false
      end

      if not (minor == "0" or not minor:match("^0")) then
         return false
      end

      if not (patch == "0" or not patch:match("^0")) then
         return false
      end
   end

   return true
end

assert:register("assertion", "version", is_version, "assertion.version.positive", "assertion.version.negative")
