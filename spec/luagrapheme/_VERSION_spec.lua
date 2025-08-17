local luagrapheme = require("luagrapheme")

describe("luagrapheme._VERSION", function()
   it("should be a valid version", function()
      assert.is_version(luagrapheme._VERSION)
   end)
end)
