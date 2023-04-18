require("busted.runner")()

describe("DebugEvents", function()
    -- setup
    local match

    -- initialization
    local DebugEvents, debugevents
    local debug

    setup(function()
        -- match
        match = require("luassert.match")

        -- debug
        DebugSpyInit()

        -- globals
        _G.MOD_DEV_TOOLS_TEST = true
    end)

    teardown(function()
        -- debug
        DebugSpyTerm()

        -- globals
        _G.MOD_DEV_TOOLS_TEST = nil
        _G.ThePlayer = nil
    end)

    before_each(function()
        -- test data
        _G.ThePlayer = MockPlayerInst()

        -- initialization
        debug = mock({
            name = "Debug",
        })

        DebugEvents = require("devtools/debug/debugevents")
        debugevents = DebugEvents(debug)

        DebugSpyClear()
    end)

    insulate("initialization", function()
        before_each(function()
            DebugEvents = require("devtools/debug/debugevents")
        end)

        local function AssertDefaults(self)
            -- general
            assert.is_equal(debug, self.debug)

            -- selection
            assert.is_table(self.activated_player)
            assert.is_table(self.activated_player_classified)
        end

        describe("using the constructor", function()
            before_each(function()
                debugevents = DebugEvents(debug)
            end)

            it("should have the default fields", function()
                AssertDefaults(debugevents)
            end)
        end)
    end)

    describe("helper", function()
        describe("DebugEvent", function()
            local _print
            local DebugEvent

            setup(function()
                _print = print
                _G.print = spy.new(Empty)
            end)

            teardown(function()
                _G.print = _print
            end)

            before_each(function()
                DebugEvent = debugevents._DebugEvent
            end)

            it("should print the debug event", function()
                assert.spy(print).was_not_called()
                DebugEvent("name", "value")
                assert.spy(print).was_called(1)
                assert.spy(print).was_called_with("[debug] [event] [name] value")
            end)
        end)

        describe("CheckIfAlreadyActivated", function()
            local _print
            local CheckIfAlreadyActivated

            setup(function()
                _print = print
                _G.print = spy.new(Empty)
            end)

            teardown(function()
                _G.print = _print
            end)

            before_each(function()
                CheckIfAlreadyActivated = debugevents._CheckIfAlreadyActivated
            end)

            describe("when there are activated events", function()
                local activated

                before_each(function()
                    activated = { one = Empty, two = Empty }
                end)

                it("should debug error", function()
                    DebugSpyClear("DebugError")
                    CheckIfAlreadyActivated(debugevents, "Test", activated)
                    AssertDebugSpyWasCalled("DebugError", 1, {
                        "DebugEvents:Test():",
                        "already 2 activated, deactivate first",
                    })
                end)

                it("should return true", function()
                    assert.is_true(CheckIfAlreadyActivated(debugevents, "Test", activated))
                end)
            end)

            describe("when there are no activated events", function()
                local activated

                before_each(function()
                    activated = {}
                end)

                it("shouldn't debug error", function()
                    DebugSpyClear("DebugError")
                    CheckIfAlreadyActivated(debugevents, "Test", activated)
                    AssertDebugSpyWasCalled("DebugError", 0)
                end)

                it("should return false", function()
                    assert.is_false(CheckIfAlreadyActivated(debugevents, "Test", activated))
                end)
            end)
        end)

        describe("CheckIfAlreadyDeactivated", function()
            local _print
            local CheckIfAlreadyDeactivated

            setup(function()
                _print = spy.new(Empty)
                _G.print = _print
            end)

            teardown(function()
                _G.print = print
            end)

            before_each(function()
                CheckIfAlreadyDeactivated = debugevents._CheckIfAlreadyDeactivated
            end)

            describe("when there are no activated events", function()
                local activated

                before_each(function()
                    activated = { one = Empty, two = Empty }
                end)

                it("shouldn't debug error", function()
                    DebugSpyClear("DebugError")
                    CheckIfAlreadyDeactivated(debugevents, "Test", activated)
                    AssertDebugSpyWasCalled("DebugError", 0)
                end)

                it("should return false", function()
                    assert.is_false(CheckIfAlreadyDeactivated(debugevents, "Test", activated))
                end)
            end)

            describe("when there are activated events", function()
                local activated

                before_each(function()
                    activated = {}
                end)

                it("should debug error", function()
                    DebugSpyClear("DebugError")
                    CheckIfAlreadyDeactivated(debugevents, "Test", activated)
                    AssertDebugSpyWasCalled("DebugError", 1, {
                        "DebugEvents:Test():",
                        "already deactivated, activate first",
                    })
                end)

                it("should return true", function()
                    assert.is_true(CheckIfAlreadyDeactivated(debugevents, "Test", activated))
                end)
            end)
        end)

        describe("Activate", function()
            local ListenForEvent, entity
            local Activate

            before_each(function()
                ListenForEvent = spy.new(Empty)
                entity = {
                    ListenForEvent = ListenForEvent,
                    event_listeners = { one = Empty, two = Empty },
                }

                Activate = debugevents._Activate
            end)

            it("should listen for all events", function()
                assert.spy(ListenForEvent).was_not_called()
                Activate(debugevents, "Test", entity)
                assert.spy(ListenForEvent).was_called(2)
                assert
                    .spy(ListenForEvent)
                    .was_called_with(match.is_ref(entity), "one", match.is_function())

                assert
                    .spy(ListenForEvent)
                    .was_called_with(match.is_ref(entity), "two", match.is_function())
            end)

            it("should debug string", function()
                DebugSpyClear("DebugString")
                Activate(debugevents, "Test", entity)
                AssertDebugSpyWasCalled("DebugString", 1, {
                    "Activated debugging of the",
                    2,
                    "Test",
                    "event listeners",
                })
            end)

            it("should return the activated table with added events", function()
                local result = Activate(debugevents, "Test", entity)
                assert.is_equal(2, TableCount(result))
            end)
        end)

        describe("Deactivate", function()
            local RemoveEventCallback, activated, entity
            local Deactivate

            before_each(function()
                RemoveEventCallback = spy.new(Empty)
                activated = { one = Empty, two = Empty }
                entity = { RemoveEventCallback = RemoveEventCallback }
                Deactivate = debugevents._Deactivate
            end)

            it("should remove all events", function()
                assert.spy(RemoveEventCallback).was_not_called()
                Deactivate(debugevents, "Test", entity, activated)
                assert.spy(RemoveEventCallback).was_called(2)
                assert
                    .spy(RemoveEventCallback)
                    .was_called_with(match.is_ref(entity), "one", match.is_function())

                assert
                    .spy(RemoveEventCallback)
                    .was_called_with(match.is_ref(entity), "two", match.is_function())
            end)

            it("should debug string", function()
                DebugSpyClear("DebugString")
                Deactivate(debugevents, "Test", entity, activated)
                AssertDebugSpyWasCalled("DebugString", 1, {
                    "Deactivated debugging of the",
                    2,
                    "Test",
                    "event listeners",
                })
            end)

            it("should return the cleared activated table", function()
                assert.is_equal(2, TableCount(activated))
                local result = Deactivate(debugevents, "Test", entity, activated)
                assert.is_equal(2, TableCount(activated))
                assert.is_equal(0, TableCount(result))
            end)
        end)
    end)

    describe("general", function()
        describe("ActivatePlayer", function()
            describe("when the player is not available", function()
                before_each(function()
                    _G.ThePlayer = nil
                end)

                it("should return false", function()
                    assert.is_false(debugevents:ActivatePlayer())
                end)
            end)

            describe("when the player is available", function()
                describe("without event listeners", function()
                    it("should return false", function()
                        _G.ThePlayer.event_listeners = {}
                        assert.is_false(debugevents:ActivatePlayer())
                        _G.ThePlayer.event_listeners = nil
                        assert.is_false(debugevents:ActivatePlayer())
                    end)
                end)

                describe("and the corresponding activated table", function()
                    describe("is empty", function()
                        before_each(function()
                            debugevents.activated_player = {}
                        end)

                        it("should add events", function()
                            assert.is_equal(0, TableCount(debugevents.activated_player))
                            debugevents:ActivatePlayer()
                            assert.is_equal(3, TableCount(debugevents.activated_player))
                        end)

                        it("should return true", function()
                            assert.is_true(debugevents:ActivatePlayer())
                        end)
                    end)

                    describe("is not empty", function()
                        before_each(function()
                            debugevents.activated_player = { one = Empty, two = Empty }
                        end)

                        it("should debug error", function()
                            DebugSpyClear("DebugError")
                            debugevents:ActivatePlayer()
                            AssertDebugSpyWasCalled("DebugError", 1, {
                                "DebugEvents:ActivatePlayer():",
                                "already 2 activated, deactivate first",
                            })
                        end)

                        it("should return false", function()
                            assert.is_false(debugevents:ActivatePlayer())
                        end)
                    end)
                end)
            end)
        end)

        describe("DeactivatePlayer", function()
            describe("when the player is not available", function()
                before_each(function()
                    _G.ThePlayer = nil
                end)

                it("should return false", function()
                    assert.is_false(debugevents:DeactivatePlayer())
                end)
            end)

            describe("when the player is available", function()
                describe("and the corresponding activated table", function()
                    describe("is empty", function()
                        before_each(function()
                            debugevents.activated_player = {}
                        end)

                        it("should debug error", function()
                            DebugSpyClear("DebugError")
                            debugevents:DeactivatePlayer()
                            AssertDebugSpyWasCalled("DebugError", 1, {
                                "DebugEvents:DeactivatePlayer():",
                                "already deactivated, activate first",
                            })
                        end)

                        it("should return false", function()
                            assert.is_false(debugevents:DeactivatePlayer())
                        end)
                    end)

                    describe("is not empty", function()
                        before_each(function()
                            debugevents.activated_player = { one = Empty, two = Empty }
                        end)

                        it("should remove all events", function()
                            assert.is_equal(2, TableCount(debugevents.activated_player))
                            debugevents:DeactivatePlayer()
                            assert.is_equal(0, TableCount(debugevents.activated_player))
                        end)

                        it("should return true", function()
                            assert.is_true(debugevents:DeactivatePlayer())
                        end)
                    end)
                end)
            end)
        end)

        describe("ActivatePlayerClassified", function()
            describe("when the player is not available", function()
                before_each(function()
                    _G.ThePlayer = nil
                end)

                it("should return false", function()
                    assert.is_false(debugevents:ActivatePlayerClassified())
                end)
            end)

            describe("when the player is available", function()
                describe("without event listeners", function()
                    it("should return false", function()
                        _G.ThePlayer.player_classified.event_listeners = {}
                        assert.is_false(debugevents:ActivatePlayerClassified())
                        _G.ThePlayer.player_classified.event_listeners = nil
                        assert.is_false(debugevents:ActivatePlayerClassified())
                        _G.ThePlayer.player_classified = nil
                        assert.is_false(debugevents:ActivatePlayerClassified())
                    end)
                end)

                describe("and the corresponding activated table", function()
                    describe("is empty", function()
                        before_each(function()
                            debugevents.activated_player_classified = {}
                        end)

                        it("should add events", function()
                            assert.is_equal(0, TableCount(debugevents.activated_player_classified))
                            debugevents:ActivatePlayerClassified()
                            assert.is_equal(3, TableCount(debugevents.activated_player_classified))
                        end)

                        it("should return true", function()
                            assert.is_true(debugevents:ActivatePlayerClassified())
                        end)
                    end)

                    describe("is not empty", function()
                        before_each(function()
                            debugevents.activated_player_classified = { one = Empty, two = Empty }
                        end)

                        it("should debug error", function()
                            DebugSpyClear("DebugError")
                            debugevents:ActivatePlayerClassified()
                            AssertDebugSpyWasCalled("DebugError", 1, {
                                "DebugEvents:ActivatePlayerClassified():",
                                "already 2 activated, deactivate first",
                            })
                        end)

                        it("should return false", function()
                            assert.is_false(debugevents:ActivatePlayerClassified())
                        end)
                    end)
                end)
            end)
        end)

        describe("DeactivatePlayerClassified", function()
            describe("when the player is not available", function()
                before_each(function()
                    _G.ThePlayer = nil
                end)

                it("should return false", function()
                    assert.is_false(debugevents:DeactivatePlayerClassified())
                end)
            end)

            describe("when the player is available", function()
                describe("and the corresponding activated table", function()
                    describe("is empty", function()
                        before_each(function()
                            debugevents.activated_player_classified = {}
                        end)

                        it("should debug error", function()
                            DebugSpyClear("DebugError")
                            assert.is_false(debugevents:DeactivatePlayerClassified())
                            AssertDebugSpyWasCalled("DebugError", 1, {
                                "DebugEvents:DeactivatePlayerClassified():",
                                "already deactivated, activate first",
                            })
                        end)

                        it("should return false", function()
                            assert.is_false(debugevents:DeactivatePlayerClassified())
                        end)
                    end)

                    describe("is not empty", function()
                        before_each(function()
                            debugevents.activated_player_classified = { one = Empty, two = Empty }
                        end)

                        it("should remove all events", function()
                            assert.is_equal(2, TableCount(debugevents.activated_player_classified))
                            debugevents:DeactivatePlayerClassified()
                            assert.is_equal(0, TableCount(debugevents.activated_player_classified))
                        end)

                        it("should return true", function()
                            assert.is_true(debugevents:DeactivatePlayerClassified())
                        end)
                    end)
                end)
            end)
        end)
    end)
end)
