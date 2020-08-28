local assert = require 'busted'.assert
local before_each = require 'busted'.before_each
local describe = require 'busted'.describe
local it = require 'busted'.it

local function TestOptionAsserts(options_fn, init_fn, field, _type, is_optional)
    describe("when the options." .. field, function()
        describe("is not passed", function()
            before_each(function()
                options_fn()[field] = nil
            end)

            if is_optional then
                it("shouldn't error", function()
                    assert.has_not_error(function()
                        init_fn(options_fn())
                    end)
                end)
            else
                it("should error", function()
                    assert.has_error(function()
                        init_fn(options_fn())
                    end, "Option " .. field .. " is required")
                end)
            end
        end)

        describe("is passed", function()
            before_each(function()
                local data = {
                    number = 42,
                    table = {},
                }

                options_fn()[field] = data[_type]
            end)

            it("shouldn't error when valid", function()
                assert.has_not_error(function()
                    init_fn(options_fn())
                end)
            end)

            describe("but not a " .. _type, function()
                before_each(function()
                    options_fn()[field] = true
                end)

                it("should error", function()
                    assert.has_error(function()
                        init_fn(options_fn())
                    end, "Option " .. field .. " should be a " .. _type)
                end)
            end)
        end)
    end)
end

local function TestToString(option, label, expected, expected_nil)
    label = label ~= nil and label or "Test"
    expected = expected ~= nil and expected or "Test"
    expected_nil = expected_nil ~= nil and expected_nil or "???"

    describe("when the options.label", function()
        describe("is a string", function()
            before_each(function()
                option.label = label
            end)

            it("should return the string", function()
                assert.is_equal(expected, option:__tostring())
            end)
        end)

        describe("is a function", function()
            before_each(function()
                option.label = ReturnValueFn(label)
            end)

            it("should return the function result", function()
                assert.is_equal(expected, option:__tostring())
            end)
        end)

        describe("is nil", function()
            before_each(function()
                option.label = nil
            end)

            it("should return " .. expected_nil, function()
                assert.is_equal(expected_nil, option:__tostring())
            end)
        end)

        describe("is a table", function()
            before_each(function()
                option.label = {}
            end)

            describe("and the name", function()
                describe("is a string", function()
                    before_each(function()
                        option.label.name = label
                    end)

                    it("should return the string", function()
                        assert.is_equal(expected, option:__tostring())
                    end)
                end)

                describe("is a function", function()
                    before_each(function()
                        option.label.name = ReturnValueFn(label)
                    end)

                    it("should return the function result", function()
                        assert.is_equal(expected, option:__tostring())
                    end)
                end)

                describe("is nil", function()
                    before_each(function()
                        option.label.name = nil
                    end)

                    it("should return " .. expected_nil, function()
                        assert.is_equal(expected_nil, option:__tostring())
                    end)
                end)
            end)
        end)
    end)
end

return {
    TestOptionAsserts = TestOptionAsserts,
    TestToString = TestToString,
}
