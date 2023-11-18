local uni = require("uni")
local utils = require("spec.utils")
local as_codepoints = utils.as_codepoints

describe("uni.sub", function()
   it("exists", function()
      assert.is_not_nil(uni.sub)
   end)

   it("errors when the input is not a string", function()
      assert.has_error(function()
         uni.sub(nil)
      end, "bad argument #1 to 'sub' (string expected)")
   end)

   -- 1. Basic Functionality
   it("extracts a simple ASCII substring", function()
      assert.are.same(as_codepoints("ell"), as_codepoints(uni.sub("hello", 2, 4)))
   end)

   -- 2. Negative Indices
   it("handles negative start index", function()
      assert.are.same(as_codepoints("llo"), as_codepoints(uni.sub("hello", -3)))
   end)

   it("handles negative end index", function()
      assert.are.same(as_codepoints("hell"), as_codepoints(uni.sub("hello", 1, -2)))
   end)

   it("defaults to the end of the string when end index is omitted", function()
      assert.are.same(as_codepoints("hello"), as_codepoints(uni.sub("hello", 1)))
   end)

   it("corrects start index less than 1", function()
      assert.are.same(as_codepoints("hello"), as_codepoints(uni.sub("hello", 0, 5)))
   end)

   it("corrects end index beyond string length", function()
      assert.are.same(as_codepoints("hello"), as_codepoints(uni.sub("hello", 1, 10)))
   end)

   it("returns empty string when start index is greater than end index", function()
      assert.are.same(as_codepoints(""), as_codepoints(uni.sub("hello", 5, 4)))
   end)

   it("returns empty string for empty input", function()
      assert.are.same(as_codepoints(""), as_codepoints(uni.sub("", 1, 1)))
   end)

   -- 6. Grapheme Clusters
   it("handles grapheme clusters correctly", function()
      assert.are.same(as_codepoints("👩‍🚀"), as_codepoints(uni.sub("he👩‍🚀llo", 3, 3)))
   end)
end)
