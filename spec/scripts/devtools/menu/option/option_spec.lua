require "busted.runner"()

local Helper = require "spec/scripts/devtools/menu/option/helper"

describe("Option", function()
    -- setup
    local match

    -- before_each
    local options, submenu
    local Option, option

    setup(function()
        match = require("luassert.match")
    end)

    before_each(function()
        -- initialization
        options = {
            label = "Test",
            name = "TestName",
            on_accept_fn = spy.new(Empty),
            on_cursor_fn = spy.new(Empty),
        }

        submenu = {}

        Option = require "devtools/menu/option/option"
        option = Option(options, submenu)
    end)

    insulate("when initializing", function()
        local function AssertDefaults(self)
            -- options
            assert.is_equal(options.label, self.label)
            assert.is_equal(options.name, self.name)
            assert.is_equal(options.on_accept_fn, self.on_accept_fn)
            assert.is_equal(options.on_cursor_fn, self.on_cursor_fn)
        end

        it("should have the default fields", function()
            AssertDefaults(option)
        end)

        describe("when the options.label is a table", function()
            before_each(function()
                options.label = {}
            end)

            describe("and the name", function()
                describe("is not passed", function()
                    before_each(function()
                        options.label.name = nil
                    end)

                    it("should error", function()
                        assert.has_error(function()
                            Option(options, submenu)
                        end, "Option label.name is required")
                    end)
                end)

                describe("is not a string", function()
                    before_each(function()
                        options.label = { name = true }
                    end)

                    it("should error", function()
                        assert.has_error(function()
                            Option(options, submenu)
                        end, "Option label.name should be a string")
                    end)
                end)
            end)
        end)
    end)

    describe("should have the", function()
        describe("getter", function()
            local getters = {
                label = "GetLabel",
                name = "GetName",
            }

            for field, getter in pairs(getters) do
                it(getter, function()
                    AssertGetter(option, field, getter)
                end)
            end
        end)

        describe("setter", function()
            it("SetLabel", function()
                AssertSetter(option, "label", "SetLabel")
            end)
        end)

        it("empty Left", function()
            option:Left()
        end)

        it("empty Right", function()
            option:Right()
        end)
    end)

    describe("general", function()
        local menu

        before_each(function()
            menu = {
                Pop = spy.new(Empty),
                PushOptions = spy.new(Empty),
            }
        end)

        describe("OnAccept", function()
            describe("when is passed in options", function()
                it("should call the options.on_accept_fn()", function()
                    assert.spy(options.on_accept_fn).was_not_called()
                    option:OnAccept(menu)
                    assert.spy(options.on_accept_fn).was_called(1)
                    assert.spy(options.on_accept_fn).was_called_with(
                        match.is_ref(option),
                        match.is_ref(submenu),
                        match.is_ref(menu)
                    )
                end)
            end)
        end)

        describe("OnCursor", function()
            describe("when is passed in options", function()
                it("should call the options.on_cursor_fn()", function()
                    assert.spy(options.on_cursor_fn).was_not_called()
                    option:OnCursor(menu)
                    assert.spy(options.on_cursor_fn).was_called(1)
                    assert.spy(options.on_cursor_fn).was_called_with(
                        match.is_ref(option),
                        match.is_ref(submenu),
                        match.is_ref(menu)
                    )
                end)
            end)
        end)

        describe("OnCancel", function()
            it("should call the passed menu Pop()", function()
                assert.spy(menu.Pop).was_not_called()
                option:OnCancel(menu)
                assert.spy(menu.Pop).was_called(1)
                assert.spy(menu.Pop).was_called_with(match.is_ref(menu))
            end)
        end)
    end)

    describe("__tostring", function()
        Helper.TestToString(option)
    end)
end)
