require "busted.runner"()

local Helper = require "spec/scripts/devtools/menu/option/helper"

describe("NumericToggleOption", function()
    -- before_each initialization
    local options
    local NumericToggleOption, numerictoggleoption

    before_each(function()
        -- initialization
        options = {
            label = "Test",
            max = 100,
            min = 1,
            on_accept_fn = spy.new(Empty),
            on_cursor_fn = spy.new(Empty),
            on_get_fn = spy.new(Empty),
            on_set_fn = spy.new(Empty),
            step = 1,
        }

        NumericToggleOption = require "devtools/menu/option/numerictoggleoption"
        numerictoggleoption = NumericToggleOption(options)
    end)

    insulate("when initializing", function()
        local options_fn = function()
            return options
        end

        local init_fn = function()
            NumericToggleOption(options)
        end

        local function AssertDefaults(self)
            -- Option
            assert.is_equal(options.label, self.label)
            assert.is_equal(options.label, self.name)
            assert.is_equal(options.on_accept_fn, self.on_accept_fn)
            assert.is_equal(options.on_cursor_fn, self.on_cursor_fn)

            -- general
            assert.is_equal(options.max, self.max)
            assert.is_equal(options.min, self.min)
            assert.is_equal(options.step, self.step)
        end

        it("should have the default fields", function()
            AssertDefaults(numerictoggleoption)
        end)

        Helper.TestOptionAsserts(options_fn, init_fn, "max", "number")
        Helper.TestOptionAsserts(options_fn, init_fn, "min", "number")
        Helper.TestOptionAsserts(options_fn, init_fn, "step", "number", true)
    end)
end)
