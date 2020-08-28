require "busted.runner"()

describe("Console", function()
    -- setup
    local _print

    -- before_each initialization
    local DevToolsConsole

    setup(function()
        _print = print
        _G.MOD_DEV_TOOLS_TEST = true
        _G.print = spy.new(Empty)
    end)

    teardown(function()
        _G.MOD_DEV_TOOLS_TEST = nil
        _G.TheNet = nil
        _G.print = _print
    end)

    before_each(function()
        -- initialization
        DevToolsConsole = require "devtools/console"

        print:clear()
    end)

    describe("local", function()
        describe("Error", function()
            local Error

            before_each(function()
                Error = DevToolsConsole._Error
            end)

            describe("when the description is passed", function()
                it("should print an error", function()
                    assert.spy(print).was_not_called()
                    Error("test")
                    assert.spy(print).was_called(1)
                    assert.spy(print).was_called_with("Error: test")
                end)
            end)
        end)

        describe("IsRequiredParameterMissing", function()
            local IsRequiredParameterMissing

            before_each(function()
                IsRequiredParameterMissing = DevToolsConsole._IsRequiredParameterMissing
            end)

            describe("when the name is passed", function()
                describe("and the value is passed", function()
                    it("should return true", function()
                        assert.is_false(IsRequiredParameterMissing("test", true))
                    end)
                end)

                describe("and the value is not passed", function()
                    describe("without number", function()
                        it("should print error", function()
                            assert.spy(print).was_not_called()
                            IsRequiredParameterMissing("test", nil)
                            assert.spy(print).was_called(1)
                            assert.spy(print).was_called_with(
                                'Error: required parameter "test" not provided'
                            )
                        end)

                        it("should return false", function()
                            assert.is_true(IsRequiredParameterMissing("test", nil))
                        end)
                    end)

                    describe("with number", function()
                        it("should print error", function()
                            assert.spy(print).was_not_called()
                            IsRequiredParameterMissing("test", nil, 1)
                            assert.spy(print).was_called(1)
                            assert.spy(print).was_called_with(
                                'Error: required #1 parameter "test" not provided'
                            )
                        end)

                        it("should return false", function()
                            assert.is_true(IsRequiredParameterMissing("test", nil, 1))
                        end)
                    end)
                end)
            end)
        end)

        describe("DecodeFileSuccess", function()
            local DecodeFileSuccess

            before_each(function()
                DecodeFileSuccess = DevToolsConsole._DecodeFileSuccess
            end)

            describe("when the path is passed", function()
                it("should print message", function()
                    assert.spy(print).was_not_called()
                    DecodeFileSuccess("test")
                    assert.spy(print).was_called(1)
                    assert.spy(print).was_called_with("Decoded successfully: test")
                end)
            end)
        end)

        describe("DecodeFileLoad", function()
            local TheSim, RunInSandboxSafe
            local DecodeFileLoad

            teardown(function()
                _G.TheSim = nil
                _G.print = print
            end)

            before_each(function()
                RunInSandboxSafe = spy.new(Empty)
                TheSim = MockTheSim(mock)

                _G.RunInSandboxSafe = RunInSandboxSafe
                _G.TheSim = TheSim

                DecodeFileLoad = DevToolsConsole._DecodeFileLoad
            end)

            describe("when is_loaded is false", function()
                it("should print error", function()
                    assert.spy(print).was_not_called()
                    DecodeFileLoad("test", false)
                    assert.spy(print).was_called(1)
                    assert.spy(print).was_called_with("Error: file test not found")
                end)

                it("should return nil", function()
                    assert.is_nil(DecodeFileLoad("test", false))
                end)
            end)

            describe("when is_loaded is true", function()
                -- TODO: Add missing DecodeFileLoad() tests
            end)
        end)
    end)

    describe("d_decodefile", function()
        describe("when the path is not passed", function()
            it("should print error", function()
                assert.spy(print).was_not_called()
                d_decodefile()
                assert.spy(print).was_called(1)
                assert.spy(print).was_called_with('Error: required parameter "path" not provided')
            end)

            it("should return nil", function()
                assert.is_nil(d_decodefile())
            end)
        end)

        describe("when the path is passed", function()
            -- TODO: Add missing d_decodefile() tests
        end)
    end)
end)
