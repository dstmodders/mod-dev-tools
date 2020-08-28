require "busted.runner"()

describe("Events", function()
    -- setup
    local match

    -- before_each test data
    local player

    -- initialization
    local DebugError, DebugString, debug
    local Events, events

    setup(function()
        -- match
        match = require "luassert.match"

        -- debug
        DebugSpyTerm()
        DebugSpyInit(spy)

        -- globals
        _G.MOD_DEV_TOOLS_TEST = true
    end)

    teardown(function()
        -- debug
        DebugSpyTerm()

        -- globals
        _G.MOD_DEV_TOOLS_TEST = nil
    end)

    before_each(function()
        -- test data
        player = MockPlayerInst(mock)

        -- initialization
        debug = mock({
            -- fields
            name = "Debug",

            -- general
            IsDebug = ReturnValueFn(false),

            -- messages
            DebugError = Empty,
            DebugInit = Empty,
            DebugString = Empty,
        })

        DebugError = debug.DebugError
        DebugString = debug.DebugString

        Events = require "devtools/debug/events"
        events = Events(debug)

        DebugSpyClear()
    end)

    insulate("initialization", function()
        before_each(function()
            Events = require "devtools/debug/events"
        end)

        local function AssertDefaults(self)
            -- general
            assert.is_equal(debug, self.debug)
            assert.is_equal("Events", self.name)

            -- selection
            assert.is_table(self.activated_player)
            assert.is_table(self.activated_player_classified)
        end

        describe("using the constructor", function()
            before_each(function()
                events = Events(debug)
            end)

            it("should have the default fields", function()
                AssertDefaults(events)
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
                DebugEvent = events._DebugEvent
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
                CheckIfAlreadyActivated = events._CheckIfAlreadyActivated
            end)

            describe("when there are activated events", function()
                local activated

                before_each(function()
                    activated = { one = Empty, two = Empty }
                end)

                it("should debug error", function()
                    assert.spy(DebugError).was_not_called()
                    CheckIfAlreadyActivated(events, "Test", activated)
                    assert.spy(DebugError).was_called(1)
                    assert.spy(DebugError).was_called_with(
                        match.is_ref(debug),
                        "Events:Test():",
                        "already 2 activated, deactivate first"
                    )
                end)

                it("should return true", function()
                    assert.is_true(CheckIfAlreadyActivated(events, "Test", activated))
                end)
            end)

            describe("when there are no activated events", function()
                local activated

                before_each(function()
                    activated = {}
                end)

                it("shouldn't debug error", function()
                    assert.spy(DebugError).was_not_called()
                    CheckIfAlreadyActivated(events, "Test", activated)
                    assert.spy(DebugError).was_not_called()
                end)

                it("should return false", function()
                    assert.is_false(CheckIfAlreadyActivated(events, "Test", activated))
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
                CheckIfAlreadyDeactivated = events._CheckIfAlreadyDeactivated
            end)

            describe("when there are no activated events", function()
                local activated

                before_each(function()
                    activated = { one = Empty, two = Empty }
                end)

                it("shouldn't debug error", function()
                    assert.spy(DebugError).was_not_called()
                    CheckIfAlreadyDeactivated(events, "Test", activated)
                    assert.spy(DebugError).was_not_called()
                end)

                it("should return false", function()
                    assert.is_false(CheckIfAlreadyDeactivated(events, "Test", activated))
                end)
            end)

            describe("when there are activated events", function()
                local activated

                before_each(function()
                    activated = {}
                end)

                it("should debug error", function()
                    assert.spy(DebugError).was_not_called()
                    CheckIfAlreadyDeactivated(events, "Test", activated)
                    assert.spy(DebugError).was_called(1)
                    assert.spy(DebugError).was_called_with(
                        match.is_ref(debug),
                        "Events:Test():",
                        "already deactivated, activate first"
                    )
                end)

                it("should return true", function()
                    assert.is_true(CheckIfAlreadyDeactivated(events, "Test", activated))
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

                Activate = events._Activate
            end)

            it("should listen for all events", function()
                assert.spy(ListenForEvent).was_not_called()
                Activate(events, "Test", entity)
                assert.spy(ListenForEvent).was_called(2)
                assert.spy(ListenForEvent)
                      .was_called_with(match.is_ref(entity), "one", match.is_function())

                assert.spy(ListenForEvent)
                      .was_called_with(match.is_ref(entity), "two", match.is_function())
            end)

            it("should debug string", function()
                assert.spy(DebugString).was_not_called()
                Activate(events, "Test", entity)
                assert.spy(DebugString).was_called(1)
                assert.spy(DebugString).was_called_with(
                    match.is_ref(debug),
                    "Activated debugging of the",
                    2,
                    "Test",
                    "event listeners"
                )
            end)

            it("should return the activated table with added events", function()
                local result = Activate(events, "Test", entity)
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
                Deactivate = events._Deactivate
            end)

            it("should remove all events", function()
                assert.spy(RemoveEventCallback).was_not_called()
                Deactivate(events, "Test", entity, activated)
                assert.spy(RemoveEventCallback).was_called(2)
                assert.spy(RemoveEventCallback)
                      .was_called_with(match.is_ref(entity), "one", match.is_function())

                assert.spy(RemoveEventCallback)
                      .was_called_with(match.is_ref(entity), "two", match.is_function())
            end)

            it("should debug string", function()
                assert.spy(DebugString).was_not_called()
                Deactivate(events, "Test", entity, activated)
                assert.spy(DebugString).was_called(1)
                assert.spy(DebugString).was_called_with(
                    match.is_ref(debug),
                    "Deactivated debugging of the",
                    2,
                    "Test",
                    "event listeners"
                )
            end)

            it("should return the cleared activated table", function()
                assert.is_equal(2, TableCount(activated))
                local result = Deactivate(events, "Test", entity, activated)
                assert.is_equal(2, TableCount(activated))
                assert.is_equal(0, TableCount(result))
            end)
        end)
    end)

    describe("general", function()
        describe("ActivatePlayer", function()
            describe("when the player is not passed", function()
                it("should return false", function()
                    assert.is_false(events:ActivatePlayer())
                end)
            end)

            describe("when the player is passed", function()
                describe("without event listeners", function()
                    it("should return false", function()
                        player.event_listeners = {}
                        assert.is_false(events:ActivatePlayer(player))
                        player.event_listeners = nil
                        assert.is_false(events:ActivatePlayer(player))
                    end)
                end)

                describe("and the corresponding activated table", function()
                    describe("is empty", function()
                        before_each(function()
                            events.activated_player = {}
                        end)

                        it("should add events", function()
                            assert.is_equal(0, TableCount(events.activated_player))
                            events:ActivatePlayer(player)
                            assert.is_equal(3, TableCount(events.activated_player))
                        end)

                        it("should return true", function()
                            assert.is_true(events:ActivatePlayer(player))
                        end)
                    end)

                    describe("is not empty", function()
                        before_each(function()
                            events.activated_player = { one = Empty, two = Empty }
                        end)

                        it("should debug error", function()
                            assert.spy(DebugError).was_not_called()
                            events:ActivatePlayer(player)
                            assert.spy(DebugError).was_called(1)
                            assert.spy(DebugError).was_called_with(
                                match.is_ref(debug),
                                "Events:ActivatePlayer():",
                                "already 2 activated, deactivate first"
                            )
                        end)

                        it("should return false", function()
                            assert.is_false(events:ActivatePlayer(player))
                        end)
                    end)
                end)
            end)
        end)

        describe("DeactivatePlayer", function()
            describe("when the player is not passed", function()
                it("should return false", function()
                    assert.is_false(events:DeactivatePlayer())
                end)
            end)

            describe("when the player is passed", function()
                describe("and the corresponding activated table", function()
                    describe("is empty", function()
                        before_each(function()
                            events.activated_player = {}
                        end)

                        it("should debug error", function()
                            assert.spy(DebugError).was_not_called()
                            events:DeactivatePlayer(player)
                            assert.spy(DebugError).was_called(1)
                            assert.spy(DebugError).was_called_with(
                                match.is_ref(debug),
                                "Events:DeactivatePlayer():",
                                "already deactivated, activate first"
                            )
                        end)

                        it("should return false", function()
                            assert.is_false(events:DeactivatePlayer(player))
                        end)
                    end)

                    describe("is not empty", function()
                        before_each(function()
                            events.activated_player = { one = Empty, two = Empty }
                        end)

                        it("should remove all events", function()
                            assert.is_equal(2, TableCount(events.activated_player))
                            events:DeactivatePlayer(player)
                            assert.is_equal(0, TableCount(events.activated_player))
                        end)

                        it("should return true", function()
                            assert.is_true(events:DeactivatePlayer(player))
                        end)
                    end)
                end)
            end)
        end)

        describe("ActivatePlayerClassified", function()
            describe("when the player is not passed", function()
                it("should return false", function()
                    assert.is_false(events:ActivatePlayerClassified())
                end)
            end)

            describe("when the player is passed", function()
                describe("without event listeners", function()
                    it("should return false", function()
                        player.player_classified.event_listeners = {}
                        assert.is_false(events:ActivatePlayerClassified(player))
                        player.player_classified.event_listeners = nil
                        assert.is_false(events:ActivatePlayerClassified(player))
                        player.player_classified = nil
                        assert.is_false(events:ActivatePlayerClassified(player))
                    end)
                end)

                describe("and the corresponding activated table", function()
                    describe("is empty", function()
                        before_each(function()
                            events.activated_player_classified = {}
                        end)

                        it("should add events", function()
                            assert.is_equal(0, TableCount(events.activated_player_classified))
                            events:ActivatePlayerClassified(player)
                            assert.is_equal(3, TableCount(events.activated_player_classified))
                        end)

                        it("should return true", function()
                            assert.is_true(events:ActivatePlayerClassified(player))
                        end)
                    end)

                    describe("is not empty", function()
                        before_each(function()
                            events.activated_player_classified = { one = Empty, two = Empty }
                        end)

                        it("should debug error", function()
                            assert.spy(DebugError).was_not_called()
                            events:ActivatePlayerClassified(player)
                            assert.spy(DebugError).was_called(1)
                            assert.spy(DebugError).was_called_with(
                                match.is_ref(debug),
                                "Events:ActivatePlayerClassified():",
                                "already 2 activated, deactivate first"
                            )
                        end)

                        it("should return false", function()
                            assert.is_false(events:ActivatePlayerClassified(player))
                        end)
                    end)
                end)
            end)
        end)

        describe("DeactivatePlayerClassified", function()
            describe("when the player is not passed", function()
                it("should return false", function()
                    assert.is_false(events:DeactivatePlayerClassified())
                end)
            end)

            describe("when the player is passed", function()
                describe("and the corresponding activated table", function()
                    describe("is empty", function()
                        before_each(function()
                            events.activated_player_classified = {}
                        end)

                        it("should debug error", function()
                            assert.spy(DebugError).was_not_called()
                            assert.is_false(events:DeactivatePlayerClassified(player))
                            assert.spy(DebugError).was_called(1)
                            assert.spy(DebugError).was_called_with(
                                match.is_ref(debug),
                                "Events:DeactivatePlayerClassified():",
                                "already deactivated, activate first"
                            )
                        end)

                        it("should return false", function()
                            assert.is_false(events:DeactivatePlayerClassified(player))
                        end)
                    end)

                    describe("is not empty", function()
                        before_each(function()
                            events.activated_player_classified = { one = Empty, two = Empty }
                        end)

                        it("should remove all events", function()
                            assert.is_equal(2, TableCount(events.activated_player_classified))
                            events:DeactivatePlayerClassified(player)
                            assert.is_equal(0, TableCount(events.activated_player_classified))
                        end)

                        it("should return true", function()
                            assert.is_true(events:DeactivatePlayerClassified(player))
                        end)
                    end)
                end)
            end)
        end)
    end)
end)
