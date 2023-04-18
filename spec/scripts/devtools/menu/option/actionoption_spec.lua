require("busted.runner")()

describe("ActionOption", function()
    -- before_each initialization
    local options
    local ActionOption, actionoption

    before_each(function()
        -- initialization
        options = {
            label = "Test",
            on_accept_fn = spy.new(Empty),
            on_cursor_fn = spy.new(Empty),
        }

        ActionOption = require("devtools/menu/option/actionoption")
        actionoption = ActionOption(options)
    end)

    insulate("when initializing", function()
        local function AssertDefaults(self)
            -- Option
            assert.is_equal(options.label, self.label)
            assert.is_equal(options.label, self.name)
            assert.is_equal(options.on_accept_fn, self.on_accept_fn)
            assert.is_equal(options.on_cursor_fn, self.on_cursor_fn)
        end

        it("should have the default fields", function()
            AssertDefaults(actionoption)
        end)
    end)
end)
