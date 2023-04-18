require("busted.runner")()

describe("CheckboxOption", function()
    -- setup
    local match

    -- before_each initialization
    local options, submenu
    local CheckboxOption, checkboxoption

    setup(function()
        match = require("luassert.match")
    end)

    before_each(function()
        -- initialization
        options = {
            label = "Test",
            on_accept_fn = spy.new(Empty),
            on_cursor_fn = spy.new(Empty),
            on_get_fn = spy.new(Empty),
            on_set_fn = spy.new(Empty),
        }

        submenu = {}

        CheckboxOption = require("devtools/menu/option/checkboxoption")
        checkboxoption = CheckboxOption(options, submenu)
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
            AssertDefaults(checkboxoption)
        end)

        describe("when the options.label is a table", function()
            before_each(function()
                options.label = {
                    name = "Test",
                }
            end)

            describe("and left", function()
                describe("is not passed", function()
                    before_each(function()
                        options.label.left = nil
                    end)

                    it("shouldn't error", function()
                        assert.has_not_error(function()
                            CheckboxOption(options, submenu)
                        end)
                    end)
                end)

                describe("is passed", function()
                    before_each(function()
                        options.label.left = true
                    end)

                    it("shouldn't error when valid", function()
                        assert.has_not_error(function()
                            CheckboxOption(options, submenu)
                        end)
                    end)

                    describe("but not a boolean", function()
                        before_each(function()
                            options.label = { name = "Test", left = "" }
                        end)

                        it("should error", function()
                            assert.has_error(function()
                                CheckboxOption(options, submenu)
                            end, "Option label.left should be a boolean")
                        end)
                    end)
                end)

                describe("and prefix", function()
                    describe("is not passed", function()
                        before_each(function()
                            options.label.prefix = nil
                        end)

                        it("shouldn't error", function()
                            assert.has_not_error(function()
                                CheckboxOption(options, submenu)
                            end)
                        end)
                    end)

                    describe("is passed", function()
                        before_each(function()
                            options.label.prefix = "Prefix"
                        end)

                        it("shouldn't error when valid", function()
                            assert.has_not_error(function()
                                CheckboxOption(options, submenu)
                            end)
                        end)

                        describe("but not a boolean", function()
                            before_each(function()
                                options.label.prefix = true
                            end)

                            it("should error", function()
                                assert.has_error(function()
                                    CheckboxOption(options, submenu)
                                end, "Option label.prefix should be a string")
                            end)
                        end)
                    end)
                end)
            end)
        end)
    end)

    describe("general", function()
        describe("Left", function()
            it("should call the options.on_set_fn() with false", function()
                assert.is_false(checkboxoption.current)
                assert.spy(options.on_set_fn).was_not_called()
                checkboxoption:Left()
                assert.is_false(checkboxoption.current)
                assert.spy(options.on_set_fn).was_called(1)
                assert
                    .spy(options.on_set_fn)
                    .was_called_with(match.is_ref(checkboxoption), match.is_ref(submenu), false)
            end)
        end)

        describe("Right", function()
            it("should call the options.on_set_fn() with true", function()
                assert.is_false(checkboxoption.current)
                assert.spy(options.on_set_fn).was_not_called()
                checkboxoption:Right()
                assert.is_true(checkboxoption.current)
                assert.spy(options.on_set_fn).was_called(1)
                assert
                    .spy(options.on_set_fn)
                    .was_called_with(match.is_ref(checkboxoption), match.is_ref(submenu), true)
            end)
        end)
    end)

    describe("__tostring", function()
        local function TestOnGetCall()
            it("should call the options.on_get_fn()", function()
                assert.spy(checkboxoption.on_get_fn).was_not_called()
                checkboxoption:__tostring()
                assert.spy(checkboxoption.on_get_fn).was_called(1)
                assert
                    .spy(checkboxoption.on_get_fn)
                    .was_called_with(match.is_ref(checkboxoption), match.is_ref(submenu))
            end)
        end

        local function TestLabelDefault(value, name)
            value = tostring(value)
            name = name ~= nil and name or "Test"

            it("should return the label with " .. value, function()
                assert.is_equal(
                    string.format("%s    [ %s ]", name, value),
                    checkboxoption:__tostring()
                )
            end)
        end

        local function TestLabelPrefix(value, name, prefix)
            value = tostring(value)
            name = name ~= nil and name or "Test"
            prefix = prefix ~= nil and prefix or "(Prefix) "

            it("should return the prefixed label with " .. value, function()
                assert.is_equal(
                    string.format("%s%s    [ %s ]", prefix, name, value),
                    checkboxoption:__tostring()
                )
            end)
        end

        describe("when the options.label", function()
            describe("is a string", function()
                before_each(function()
                    checkboxoption.label = "Test"
                end)

                TestLabelDefault(false)
            end)

            describe("is a function", function()
                before_each(function()
                    checkboxoption.label = ReturnValueFn("Test")
                end)

                TestLabelDefault(false)
            end)

            describe("is nil", function()
                before_each(function()
                    checkboxoption.label = nil
                end)

                it("should return ??? with a value", function()
                    assert.is_equal("???    [ false ]", checkboxoption:__tostring())
                end)
            end)

            describe("is a table", function()
                before_each(function()
                    checkboxoption.label = {
                        name = "Test",
                    }
                end)

                describe("and the prefix", function()
                    describe("is a string", function()
                        before_each(function()
                            checkboxoption.label.prefix = "(Prefix) "
                        end)

                        describe("+ the options.on_get_fn()", function()
                            describe("returns true", function()
                                before_each(function()
                                    checkboxoption.on_get_fn = ReturnValueFn(true)
                                end)

                                TestLabelPrefix(true)
                            end)

                            describe("returns false", function()
                                before_each(function()
                                    checkboxoption.on_get_fn = ReturnValueFn(false)
                                end)

                                TestLabelPrefix(false)
                            end)
                        end)

                        describe("+ the left is true", function()
                            before_each(function()
                                checkboxoption.label.left = true
                            end)

                            TestLabelPrefix(false)
                        end)
                    end)

                    describe("is nil", function()
                        before_each(function()
                            checkboxoption.label.prefix = nil
                        end)

                        describe("+ the left is false", function()
                            before_each(function()
                                checkboxoption.label.left = true
                            end)

                            it("should return the label with false", function()
                                assert.is_equal("[ false ]  Test", checkboxoption:__tostring())
                            end)
                        end)
                    end)
                end)
            end)
        end)

        describe("when the options.on_get_fn()", function()
            local function TestCurrent(value_true, value_false, test_calls)
                describe("and the current", function()
                    describe("is true", function()
                        before_each(function()
                            checkboxoption.current = true
                        end)

                        if test_calls then
                            TestOnGetCall()
                        end

                        TestLabelDefault(value_true)
                    end)

                    describe("is false", function()
                        before_each(function()
                            checkboxoption.current = false
                        end)

                        if test_calls then
                            TestOnGetCall()
                        end

                        TestLabelDefault(value_false)
                    end)
                end)
            end

            describe("is false", function()
                before_each(function()
                    checkboxoption.on_get_fn = spy.new(ReturnValueFn(false))
                end)

                TestCurrent(false, false, true)
            end)

            describe("is true", function()
                before_each(function()
                    checkboxoption.on_get_fn = spy.new(ReturnValueFn(true))
                end)

                TestCurrent(true, true, true)
            end)

            describe("is nil", function()
                before_each(function()
                    checkboxoption.on_get_fn = nil
                end)

                TestCurrent(true, false)
            end)
        end)
    end)
end)
