require "busted.runner"()

describe("DoActionOption", function()
    -- before_each initialization
    local options
    local DoActionOption, doactionoption

    before_each(function()
        -- initialization
        options = {
            label = "Test",
            on_accept_fn = spy.new(Empty),
            on_cursor_fn = spy.new(Empty),
        }

        DoActionOption = require "devtools/menu/option/doactionoption"
        doactionoption = DoActionOption(options)
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
            AssertDefaults(doactionoption)
        end)
    end)
end)
