require "busted.runner"()
require "class"
require "devtools/utils"

describe("Utils", function()
    -- setup
    local match

    -- before_each initialization
    local Utils

    setup(function()
        -- match
        match = require "luassert.match"

        -- debug
        DebugSpyTerm()
        DebugSpyInit(spy)
    end)

    teardown(function()
        -- debug
        DebugSpyTerm()

        -- globals
        _G.TheNet = nil
        _G.TheSim = nil
    end)

    before_each(function()
        -- initialization
        Utils = require "devtools/utils"

        -- debug
        DebugSpyClear()

        -- globals
        _G.TheNet = MockTheNet()
        _G.TheSim = MockTheSim()
    end)

    describe("general", function()
        describe("AddMethodsToAnotherClass", function()
            local TestClassDestination, TestClassSource
            local src, dest

            setup(function()
                TestClassDestination = Class(function()
                end)

                TestClassSource = Class(function(self)
                    self.test = true
                end)

                function TestClassSource:TestOne(value)
                    return value, self.test
                end

                function TestClassSource:TestTwo()
                    return self
                end

                -- luacheck: no unused args
                function TestClassSource:TestThree(value)
                    return value
                end
                -- luacheck: unused args
            end)

            local TestBeforeAfter = function()
                assert.is_not_nil(src.TestOne)
                assert.is_not_nil(src.TestTwo)
                assert.is_not_nil(src.TestThree)

                local value, test = src:TestOne("test")
                assert.is_equal("test", value)
                assert.is_true(test)

                assert.is_equal(src, src:TestTwo())

                assert.is_equal("test", src:TestThree("test"))
            end

            before_each(function()
                src = TestClassSource()
                dest = TestClassDestination()
                TestBeforeAfter()
            end)

            after_each(function()
                TestBeforeAfter()
            end)

            describe("should add class functions from one class to another", function()
                it("when no destination names provided", function()
                    assert.is_nil(dest.TestOne)
                    assert.is_nil(dest.TestTwo)
                    assert.is_nil(dest.TestThree)

                    Utils.AddMethodsToAnotherClass(src, dest, {
                        "TestOne",
                        "TestTwo",
                        "TestThree",
                    })

                    local value, test = dest:TestOne("test")
                    assert.is_equal("test", value)
                    assert.is_true(test)

                    assert.is_equal(src, dest:TestTwo())
                end)

                it("when destination names provided", function()
                    assert.is_nil(dest.NewTestOne)
                    assert.is_nil(dest.TestTwo)
                    assert.is_nil(dest.TestThree)

                    Utils.AddMethodsToAnotherClass(src, dest, {
                        NewTestOne = "TestOne",
                        "TestTwo",
                        "TestThree",
                    })

                    local value, test = dest:NewTestOne("test")
                    assert.is_equal("test", value)
                    assert.is_true(test)

                    assert.is_equal(src, dest:TestTwo())
                    assert.is_equal("test", dest:TestThree("test"))
                end)
            end)
        end)

        describe("ConsoleRemote", function()
            local GetPosition, ProjectScreenPos, SendRemoteExecute

            before_each(function()
                GetPosition = TheSim.GetPosition
                ProjectScreenPos = TheSim.ProjectScreenPos
                SendRemoteExecute = TheNet.SendRemoteExecute
            end)

            it("should call the TheSim:GetPosition()", function()
                assert.spy(GetPosition).was_not_called()
                Utils.ConsoleRemote('TheWorld:PushEvent("ms_setseason", "%s")', { "autumn" })
                assert.spy(GetPosition).was_called(1)
                assert.spy(GetPosition).was_called_with(match.is_ref(TheSim))
            end)

            it("should call the TheSim:GetPosition()", function()
                assert.spy(ProjectScreenPos).was_not_called()
                Utils.ConsoleRemote('TheWorld:PushEvent("ms_setseason", "%s")', { "autumn" })
                assert.spy(ProjectScreenPos).was_called(1)
                assert.spy(ProjectScreenPos).was_called_with(match.is_ref(TheSim))
            end)

            it("should call the TheSim:SendRemoteExecute()", function()
                assert.spy(SendRemoteExecute).was_not_called()
                Utils.ConsoleRemote('TheWorld:PushEvent("ms_setseason", "%s")', { "autumn" })
                assert.spy(SendRemoteExecute).was_called(1)
                assert.spy(SendRemoteExecute).was_called_with(
                    match.is_ref(TheNet), 'TheWorld:PushEvent("ms_setseason", "autumn")', 1, 3
                )
            end)

            it("should add data correctly", function()
                Utils.ConsoleRemote('%d, %0.2f, "%s"', { 1, .12345, "test" })
                assert.spy(SendRemoteExecute).was_called_with(
                    match.is_ref(TheNet), '1, 0.12, "test"', 1, 3
                )
            end)
        end)
    end)
end)
