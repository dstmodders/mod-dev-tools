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
        local test_debug_string

        setup(function()
            test_debug_string = [[117500 - wendy age 7.43]] .. "\n" ..
                [[GUID:117500 Name:  Tags: _sheltered trader _health inspectable freezable player idle _builder]] .. "\n" .. -- luacheck: only
                [[Prefab: wendy]] .. "\n" ..
                [[AnimState: bank: wilson build: wendy_rose anim: idle_loop anim/player_idles.zip:idle_loop Frame: 47.00/66 Facing: 3]] .. "\n" .. -- luacheck: only
                [[Transform: Pos=(-59.07,0.00,179.48) Scale=(1.00,1.00,1.00) Heading=-45.00]]
        end)

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

        describe("AnimState", function()
            local entity

            setup(function()
                entity = {
                    AnimState = {},
                    GetDebugString = ReturnValueFn(test_debug_string),
                }
            end)

            describe("GetAnimStateBank", function()
                it("should return the entity animation state bank", function()
                    assert.is_equal("wilson", Utils.GetAnimStateBank(entity))
                end)
            end)

            describe("GetAnimStateBuild", function()
                setup(function()
                    entity.AnimState = {
                        GetBuild = ReturnValueFn("test"),
                    }
                end)

                it("should return the entity animation state build", function()
                    assert.is_equal("test", Utils.GetAnimStateBuild(entity))
                end)
            end)

            describe("GetAnimStateAnim", function()
                it("should return the entity animation state animation", function()
                    assert.is_equal("idle_loop", Utils.GetAnimStateAnim(entity))
                end)
            end)
        end)

        describe("StateGraph", function()
            local entity

            setup(function()
                entity = {
                    sg = 'sg="wilson", state="idle", time=1.57, tags = "idle,canrotate,"',
                }
            end)

            describe("GetStateGraphName", function()
                it("should return the state graph name", function()
                    assert.is_equal("wilson", Utils.GetStateGraphName(entity))
                end)
            end)

            describe("GetStateGraphState", function()
                it("should return the state graph state", function()
                    assert.is_equal("idle", Utils.GetStateGraphState(entity))
                end)
            end)
        end)

        describe("GetTags", function()
            local entity

            setup(function()
                entity = {
                    GetDebugString = ReturnValueFn(test_debug_string),
                }
            end)

            it("should return tags", function()
                assert.is_equal(8, #Utils.GetTags(entity))
            end)
        end)
    end)

    describe("chain", function()
        local value, netvar, GetTimeUntilPhase, clock, TheWorld

        before_each(function()
            value = 42
            netvar = { value = spy.new(ReturnValueFn(value)) }
            GetTimeUntilPhase = spy.new(ReturnValueFn(value))

            clock = {
                boolean = true,
                fn = ReturnValueFn(value),
                netvar = netvar,
                number = 1,
                string = "test",
                table = {},
                GetTimeUntilPhase = GetTimeUntilPhase,
            }

            TheWorld = {
                net = {
                    components = {
                        clock = clock,
                    },
                },
            }
        end)

        describe("ChainGet", function()
            describe("when an invalid src is passed", function()
                it("should return nil", function()
                    assert.is_nil(Utils.ChainGet(nil, "net"))
                    assert.is_nil(Utils.ChainGet("nil", "net"))
                    assert.is_nil(Utils.ChainGet(42, "net"))
                    assert.is_nil(Utils.ChainGet(true, "net"))
                end)
            end)

            describe("when some chain fields are missing", function()
                it("should return nil", function()
                    AssertChainNil(function()
                        assert.is_nil(Utils.ChainGet(
                            TheWorld,
                            "net",
                            "components",
                            "clock",
                            "GetTimeUntilPhase"
                        ))
                    end, TheWorld, "net", "components", "clock", "GetTimeUntilPhase")
                end)
            end)

            describe("when the last parameter is true", function()
                it("should return the last field call (function)", function()
                    assert.is_equal(value, Utils.ChainGet(
                        TheWorld,
                        "net",
                        "components",
                        "clock",
                        "fn",
                        true
                    ))
                end)

                it("should return the last field call (table as a function)", function()
                    assert.is_equal(value, Utils.ChainGet(
                        TheWorld,
                        "net",
                        "components",
                        "clock",
                        "GetTimeUntilPhase",
                        true
                    ))

                    assert.spy(GetTimeUntilPhase).was_called(1)
                    assert.spy(GetTimeUntilPhase).was_called_with(match.is_ref(clock))
                end)

                it("should return the last netvar value", function()
                    assert.is_equal(value, Utils.ChainGet(
                        TheWorld,
                        "net",
                        "components",
                        "clock",
                        "netvar",
                        true
                    ))

                    assert.spy(netvar.value).was_called(1)
                    assert.spy(netvar.value).was_called_with(match.is_ref(netvar))
                end)

                local fields = {
                    "boolean",
                    "number",
                    "string",
                    "table",
                }

                for _, field in pairs(fields) do
                    describe("and the previous parameter is a " .. field, function()
                        it("should return nil", function()
                            assert.is_nil(Utils.ChainGet(
                                TheWorld,
                                "net",
                                "components",
                                "clock",
                                field,
                                true
                            ), field)
                        end)
                    end)
                end

                describe("and the previous parameter is a nil", function()
                    it("should return nil", function()
                        assert.is_nil(Utils.ChainGet(
                            TheWorld,
                            "net",
                            "components",
                            "test",
                            true
                        ))
                    end)
                end)
            end)

            it("should return the last field", function()
                assert.is_equal(GetTimeUntilPhase, Utils.ChainGet(
                    TheWorld,
                    "net",
                    "components",
                    "clock",
                    "GetTimeUntilPhase"
                ))

                assert.spy(GetTimeUntilPhase).was_not_called()
            end)
        end)

        describe("ChainValidate", function()
            describe("when an invalid src is passed", function()
                it("should return false", function()
                    assert.is_false(Utils.ChainValidate(nil, "net"))
                    assert.is_false(Utils.ChainValidate("nil", "net"))
                    assert.is_false(Utils.ChainValidate(42, "net"))
                    assert.is_false(Utils.ChainValidate(true, "net"))
                end)
            end)

            describe("when some chain fields are missing", function()
                it("should return false", function()
                    AssertChainNil(function()
                        assert.is_false(Utils.ChainValidate(
                            TheWorld,
                            "net",
                            "components",
                            "clock",
                            "GetTimeUntilPhase"
                        ))
                    end, TheWorld, "net", "components", "clock", "GetTimeUntilPhase")
                end)
            end)

            describe("when all chain fields are available", function()
                it("should return true", function()
                    assert.is_true(Utils.ChainValidate(
                        TheWorld,
                        "net",
                        "components",
                        "clock",
                        "GetTimeUntilPhase"
                    ))
                end)
            end)
        end)
    end)

    describe("table", function()
        describe("TableCompare", function()
            it("should return true when both tables have the same reference", function()
                local test = {}
                assert.is_true(Utils.TableCompare(test, test))
            end)

            it("should return true when both tables with nested ones are the same", function()
                local first = { first = {}, second = { third = {} } }
                local second = { first = {}, second = { third = {} } }
                assert.is_true(Utils.TableCompare(first, second))
            end)

            it("should return false when one of the tables is nil", function()
                local test = {}
                assert.is_false(Utils.TableCompare(nil, test))
                assert.is_false(Utils.TableCompare(test, nil))
            end)

            it("should return false when one of the tables is not a table type", function()
                local test = {}
                assert.is_false(Utils.TableCompare("table", test))
                assert.is_false(Utils.TableCompare(test, "table"))
            end)

            it("should return false when both tables with nested ones are not the same", function()
                local first = { first = {}, second = { third = {} } }
                local second = { first = {}, second = { third = { "fourth" } } }
                assert.is_false(Utils.TableCompare(first, second))
            end)
        end)

        describe("TableCount", function()
            it("should return false when the passed parameter is not a table", function()
                assert.is_false(Utils.TableCount("test"))
            end)

            describe("in the table with default indexes", function()
                it("should count the number of elements", function()
                    local test = { one = 1, two = 2, three = 3, four = 4, five = 5 }
                    assert.is_equal(5, Utils.TableCount(test))
                end)
            end)

            describe("in the table with custom indexes", function()
                it("should count the number of elements", function()
                    local test = { 1, 2, 3, 4, 5 }
                    assert.is_equal(5, Utils.TableCount(test))
                end)
            end)
        end)

        describe("TableHasValue", function()
            it("should return false when the passed parameter is not a table", function()
                assert.is_false(Utils.TableHasValue("test"))
            end)

            describe("in the table with default indexes", function()
                it("should return true when the element is in the table", function()
                    local test = { one = 1, two = 2, three = 3, four = 4, five = 5 }
                    assert.is_true(Utils.TableHasValue(test, 3))
                end)

                it("should return false when the element is not in the table", function()
                    local test = { one = 1, two = 2, three = 3, four = 4, five = 5 }
                    assert.is_false(Utils.TableHasValue(test, 6))
                end)
            end)

            describe("in the table with custom indexes", function()
                it("should return true when the element is in the table", function()
                    local test = { 1, 2, 3, 4, 5 }
                    assert.is_true(Utils.TableHasValue(test, 3))
                end)

                it("should return false when the element is not in the table", function()
                    local test = { one = 1, two = 2, three = 3, four = 4, five = 5 }
                    assert.is_false(Utils.TableHasValue(test, 6))
                end)
            end)
        end)

        describe("TableKeyByValue", function()
            it("should return false when the passed parameter is not a table", function()
                assert.is_false(Utils.TableKeyByValue("test"))
            end)

            it("should return the key when the valid table and value passed", function()
                local test = { one = 1, two = 2, three = 3, four = 4, five = 5 }
                assert.is_equal("two", Utils.TableKeyByValue(test, 2))
            end)
        end)

        describe("TableMerge", function()
            it("should return two combined simple tables", function()
                local a = { a = "a", b = "b", c = "c" }
                local b = { d = "d", e = "e", a = "f" }
                assert.is_same(
                    { a = "f", b = "b", c = "c", d = "d", e = "e" },
                    Utils.TableMerge(a, b)
                )
            end)

            it("should return two combined simple ipaired tables", function()
                local a = { "a", "b", "c" }
                local b = { "d", "e", "f" }
                assert.is_same({ "a", "b", "c", "d", "e", "f" }, Utils.TableMerge(a, b))
            end)
        end)

        describe("TableNextValue", function()
            it("should return the next value", function()
                local t = { "a", "b", "c" }
                assert.is_equal("c", Utils.TableNextValue(t, "b"))
            end)

            it("should return the first value when there is no next one", function()
                local t = { "a", "b", "c" }
                assert.is_equal("a", Utils.TableNextValue(t, "c"))
            end)
        end)

        describe("TableSortAlphabetically", function()
            it("should return false when the passed parameter is not a table", function()
                assert.is_false(Utils.TableSortAlphabetically("test"))
            end)

            it("should return true when both tables with nested ones are the same", function()
                local test = { "one", "two", "three", "four", "five" }
                local expected = { "five", "four", "one", "three", "two" }
                local result = Utils.TableSortAlphabetically(test)

                assert.is_equal(#expected, #result)
                for k, v in pairs(result) do
                    assert.is_equal(expected[k], v)
                end
            end)
        end)
    end)
end)
