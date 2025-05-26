local lglpeg = require("luagrapheme.lpeg")

describe("luagrapheme.lpeg._VERSION", function()
   it("should be a valid version", function()
      assert.is_version(lglpeg._VERSION)
   end)
end)
