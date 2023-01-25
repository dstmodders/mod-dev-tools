require("busted.runner")()
require("class")
require("devtools/utils")

describe("Utils", function()
    -- setup
    local match

    -- before_each initialization
    local Utils

    setup(function()
        -- match
        match = require("luassert.match")

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
        Utils = require("devtools/utils")

        -- debug
        DebugSpyClear()

        -- globals
        _G.TheNet = MockTheNet()
        _G.TheSim = MockTheSim()
    end)

    describe("general", function()
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
                assert
                    .spy(SendRemoteExecute)
                    .was_called_with(match.is_ref(TheNet), 'TheWorld:PushEvent("ms_setseason", "autumn")', 1, 3)
            end)

            it("should add data correctly", function()
                Utils.ConsoleRemote('%d, %0.2f, "%s"', { 1, 0.12345, "test" })
                assert
                    .spy(SendRemoteExecute)
                    .was_called_with(match.is_ref(TheNet), '1, 0.12, "test"', 1, 3)
            end)
        end)
    end)
end)
