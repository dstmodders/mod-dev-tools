require("busted.runner")()

describe("DividerOption", function()
    -- before_each initialization
    local label
    local DividerOption, divideroption

    before_each(function()
        -- initialization
        label = ""

        DividerOption = require("devtools/menu/option/divideroption")
        divideroption = DividerOption()
    end)

    insulate("when initializing", function()
        local function AssertDefaults(self)
            -- Option
            assert.is_equal(label, self.label)
            assert.is_equal(label, self.name)
            assert.is_nil(self.on_accept_fn)
            assert.is_nil(self.on_cursor_fn)

            -- general
            assert.is_true(self.is_divider)
        end

        it("should have the default fields", function()
            AssertDefaults(divideroption)
        end)
    end)
end)
