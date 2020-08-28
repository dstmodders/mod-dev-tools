require "busted.runner"()

local Helper = require "spec/scripts/devtools/menu/option/helper"

describe("CheckboxOption", function()
    -- before_each initialization
    local options
    local ChoicesOption, choicesoption

    before_each(function()
        -- initialization
        options = {
            choices = {},
            label = "Test",
            on_accept_fn = spy.new(Empty),
            on_cursor_fn = spy.new(Empty),
            on_get_fn = spy.new(Empty),
            on_set_fn = spy.new(Empty),
        }

        ChoicesOption = require "devtools/menu/option/choicesoption"
        choicesoption = ChoicesOption(options)
    end)

    insulate("when initializing", function()
        local options_fn = function()
            return options
        end

        local init_fn = function()
            ChoicesOption(options)
        end

        local function AssertDefaults(self)
            -- Option
            assert.is_equal(options.label, self.label)
            assert.is_equal(options.label, self.name)
            assert.is_equal(options.on_accept_fn, self.on_accept_fn)
            assert.is_equal(options.on_cursor_fn, self.on_cursor_fn)

            -- general
            assert.is_nil(self.key)

            -- options
            assert.is_equal(options.choices, self.choices)
            assert.is_equal(options.on_get_fn, self.on_get_fn)
            assert.is_equal(options.on_set_fn, self.on_set_fn)
        end

        it("should have the default fields", function()
            AssertDefaults(choicesoption)
        end)

        Helper.TestOptionAsserts(options_fn, init_fn, "choices", "table")
    end)
end)
