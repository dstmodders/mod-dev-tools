require("busted.runner")()

local Helper = require("spec/scripts/devtools/menu/option/helper")

describe("SubmenuOption", function()
    -- setup
    local match

    -- before_each initialization
    local options, submenu
    local SubmenuOption, submenuoption

    setup(function()
        match = require("luassert.match")
    end)

    before_each(function()
        -- initialization
        options = {
            label = "Test",
            on_accept_fn = spy.new(Empty),
            on_cursor_fn = spy.new(Empty),
            options = { 1, 2, 3, 4, 5 },
        }

        submenu = {}

        SubmenuOption = require("devtools/menu/option/submenuoption")
        submenuoption = SubmenuOption(options, submenu)
    end)

    insulate("when initializing", function()
        local options_fn = function()
            return options
        end

        local init_fn = function()
            SubmenuOption(options, submenu)
        end

        local function AssertDefaults(self)
            -- Option
            assert.is_equal(options.label, self.label)
            assert.is_equal(options.label, self.name)
            assert.is_equal(options.on_accept_fn, self.on_accept_fn)
            assert.is_equal(options.on_cursor_fn, self.on_cursor_fn)
        end

        it("should have the default fields", function()
            AssertDefaults(submenuoption)
        end)

        Helper.TestOptionAsserts(options_fn, init_fn, "options", "table")
    end)

    describe("general", function()
        describe("OnAccept", function()
            local menu

            setup(function()
                _G.shallowcopy = spy.new(ReturnValueFn(options))
            end)

            teardown(function()
                _G.shallowcopy = nil
            end)

            before_each(function()
                menu = { PushOptions = spy.new(Empty) }
            end)

            describe("when is passed in options", function()
                it("should call the shallowcopy()", function()
                    assert.spy(shallowcopy).was_not_called()
                    submenuoption:OnAccept(menu)
                    assert.spy(shallowcopy).was_called(1)
                    assert.spy(shallowcopy).was_called_with(match.is_ref(submenuoption.options))
                end)

                it("should call the options.on_accept_fn()", function()
                    assert.spy(options.on_accept_fn).was_not_called()
                    submenuoption:OnAccept(menu)
                    assert.spy(options.on_accept_fn).was_called(1)
                    assert
                        .spy(options.on_accept_fn)
                        .was_called_with(match.is_ref(submenuoption), match.is_ref(submenu), match.is_ref(menu))
                end)

                it("should push options to the menu", function()
                    assert.spy(menu.PushOptions).was_not_called()
                    submenuoption:OnAccept(menu)
                    assert.spy(menu.PushOptions).was_called(1)
                    assert
                        .spy(menu.PushOptions)
                        .was_called_with(match.is_ref(menu), match.is_table(options), submenuoption.name)
                end)
            end)
        end)
    end)

    describe("__tostring", function()
        Helper.TestToString(submenuoption, "Test", "Test...", "???...")
    end)
end)
