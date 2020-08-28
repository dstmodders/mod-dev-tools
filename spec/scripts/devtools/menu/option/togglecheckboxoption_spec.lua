require "busted.runner"()

describe("ToggleCheckboxOption", function()
    -- before_each initialization
    local options
    local ToggleCheckboxOption, togglecheckboxoption

    before_each(function()
        -- initialization
        options = {
            label = "Test",
            on_accept_fn = spy.new(Empty),
            on_cursor_fn = spy.new(Empty),
            on_get_fn = spy.new(Empty),
            on_set_fn = spy.new(Empty),
        }

        ToggleCheckboxOption = require "devtools/menu/option/togglecheckboxoption"
        togglecheckboxoption = ToggleCheckboxOption(options)
    end)

    insulate("when initializing", function()
        local function AssertDefaults(self)
            -- Option
            assert.is_equal(options.label, self.label)
            assert.is_equal(options.label, self.name)
            assert.is_equal(options.on_accept_fn, self.on_accept_fn)
            assert.is_equal(options.on_cursor_fn, self.on_cursor_fn)

            -- general
            assert.is_false(self.current)

            -- options
            assert.is_equal(options.on_get_fn, self.on_get_fn)
            assert.is_equal(options.on_set_fn, self.on_set_fn)
        end

        it("should have the default fields", function()
            AssertDefaults(togglecheckboxoption)
        end)
    end)
end)
