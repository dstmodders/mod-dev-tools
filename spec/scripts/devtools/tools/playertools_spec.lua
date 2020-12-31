require "busted.runner"()

describe("PlayerTools", function()
    -- setup
    local match

    -- before_each test data
    local inst
    local player_dead, player_hopping, player_over_water, player_running, player_sinking, players

    -- before_each initialization
    local devtools, world
    local PlayerTools, playertools

    local function EachPlayer(fn, except)
        except = except ~= nil and except or {}
        for _, player in pairs(players) do
            if not TableHasValue(except, player) then
                fn(player)
            end
        end
    end

    setup(function()
        -- match
        match = require "luassert.match"

        -- debug
        DebugSpyInit()

        -- globals
        _G.kleifileexists = ReturnValueFn(false)

        _G.EQUIPSLOTS = {
            BODY = "body",
            HEAD = "head",
        }

        _G.TUNING = {
            MINERHAT_LIGHTTIME = 468,
            TORCH_DAMAGE = 34 * .5,
        }
    end)

    teardown(function()
        -- debug
        DebugSpyTerm()

        -- globals
        _G.ConsoleCommandPlayer = nil
        _G.ConsoleRemote = nil
        _G.EQUIPSLOTS = nil
        _G.GROUND = nil
        _G.SetDebugEntity = nil
        _G.TheNet = nil
        _G.TheSim = nil
        _G.kleifileexists = nil
    end)

    before_each(function()
        -- test data
        inst = MockPlayerInst("PlayerInst", nil, { "godmode", "idle" }, { "wereness" })
        player_dead = MockPlayerInst("PlayerDead", "KU_one", { "dead", "idle" })
        player_hopping = MockPlayerInst("PlayerHopping", "KU_two", { "hopping" })
        player_running = MockPlayerInst("PlayerRunning", "KU_four", { "running" })
        player_sinking = MockPlayerInst("PlayerSinking", "KU_five", { "sinking" })
        player_over_water = MockPlayerInst("PlayerOverWater", "KU_three", nil, nil, { 100, 0, 100 })

        players = {
            inst,
            player_dead,
            player_hopping,
            player_over_water,
            player_running,
            player_sinking,
        }

        -- globals (TheNet)
        _G.TheNet = MockTheNet({
            {
                userid = inst.userid,
                admin = true
            },
            {
                userid = "KU_one",
                admin = false
            },
            {
                userid = "KU_two",
                admin = false
            },
            {
                userid = "KU_three",
                admin = false
            },
            {
                userid = "KU_four",
                admin = false
            },
            {
                userid = "KU_five",
                admin = false
            },
        })

        -- globals
        _G.ConsoleCommandPlayer = spy.new(ReturnValueFn(inst))
        _G.ConsoleRemote = spy.new(Empty)
        _G.GROUND = { INVALID = 255 }
        _G.SetDebugEntity = spy.new(Empty)
        _G.TheSim = MockTheSim()

        -- sdk
        _G.SDK.Player.IsAdmin = ReturnValueFn(true)

        -- initialization
        devtools = MockDevTools()
        world = MockWorldTools()

        PlayerTools = require "devtools/tools/playertools"
        playertools = PlayerTools(inst, world, devtools)

        DebugSpyClear()
    end)

    insulate("initialization", function()
        before_each(function()
            -- general
            devtools = MockDevTools()

            -- initialization
            PlayerTools = require "devtools/tools/playertools"
        end)

        local function AssertDefaults(self)
            assert.is_equal(devtools, self.devtools)
            assert.is_equal("PlayerTools", self.name)

            -- general
            assert.is_nil(self.controller)
            assert.is_equal(inst, self.inst)
            assert.is_false(self.is_move_button_down)
            assert.is_nil(self.speech)
            assert.is_nil(self.wereness_mode)
            assert.is_equal(world, self.world)

            -- god mode
            assert.is_equal(0, #self.god_mode_players)

            -- selection
            assert.is_equal(inst, self.selected_client)
            assert.is_nil(self.selected_server)

            -- submodules
            assert.is_not_nil(self.console)
            assert.is_not_nil(self.inventory)
            assert.is_not_nil(self.crafting)
            assert.is_not_nil(self.vision)
            assert.is_not_nil(self.map)

            -- other
            assert.is_equal(self, self.devtools.player)
        end

        describe("using the constructor", function()
            before_each(function()
                inst.HasTag:clear()
                inst.ListenForEvent:clear()

                playertools = PlayerTools(inst, world, devtools)
            end)

            it("should have the default fields", function()
                AssertDefaults(playertools)
            end)

            it("should call the instance HasTag()", function()
                assert.spy(inst.HasTag).was_called(1)
                assert.spy(inst.HasTag).was_called_with(match.is_ref(inst), "wereness")
            end)

            it("should call the instance ListenForEvent()", function()
                assert.spy(inst.ListenForEvent).was_called(1)
                assert.spy(inst.ListenForEvent).was_called_with(
                    match.is_ref(inst),
                    "weremodedirty",
                    match.is_function()
                )
            end)
        end)

        it("should add DevTools methods", function()
            local methods = {
                GetSelectedPlayer = "GetSelected",
                SelectPlayer = "Select",

                -- general
                "GetPlayer",
                "GetSpeech",
                "GetWerenessMode",
                "IsMoveButtonDown",
                --"SetIsMoveButtonDown",
                "IsPlatformJumping",

                -- god mode
                "GetGodModePlayers",
                "IsGodMode",
                "ToggleGodMode",

                -- lightwatcher
                "CanGrueAttack",

                -- player
                "GetWerenessPercent",

                -- selection
                "IsSelectedInSync",

                -- teleport
                "Teleport",
            }

            AssertAddedMethodsBefore(methods, devtools)
            playertools = PlayerTools(inst, world, devtools)
            AssertAddedMethodsAfter(methods, playertools, devtools)
        end)
    end)

    describe("general", function()
        describe("should have the", function()
            describe("getter", function()
                local getters = {
                    inst = "GetPlayer",
                    wereness_mode = "GetWerenessMode",
                    is_move_button_down = "IsMoveButtonDown",
                }

                for field, getter in pairs(getters) do
                    it(getter, function()
                        AssertClassGetter(playertools, field, getter)
                    end)
                end
            end)

            describe("setter", function()
                it("SetIsMoveButtonDown", function()
                    AssertClassSetter(playertools, "is_move_button_down", "SetIsMoveButtonDown")
                end)
            end)
        end)

        describe("IsPlatformJumping", function()
            describe("when the player is jumping", function()
                it("should return true", function()
                    assert.is_true(playertools:IsPlatformJumping(player_hopping))
                end)
            end)

            describe("when the player is not jumping", function()
                it("should return true", function()
                    EachPlayer(function(player)
                        assert.is_false(
                            playertools:IsPlatformJumping(player),
                            player:GetDisplayName()
                        )
                    end, { player_hopping })
                end)
            end)

            describe("when the player HasTag is missing", function()
                before_each(function()
                    EachPlayer(function(player)
                        player.HasTag = nil
                    end)
                end)

                it("should return nil", function()
                    EachPlayer(function(player)
                        assert.is_nil(
                            playertools:IsPlatformJumping(player),
                            player:GetDisplayName()
                        )
                    end)
                end)
            end)
        end)
    end)

    describe("lightwatcher", function()
        describe("CanGrueAttack", function()
            before_each(function()
                _G.SDK.Player.IsGhost = spy.new(ReturnValueFn(false))
                _G.SDK.Player.IsInLight = spy.new(ReturnValueFn(false))
                playertools.inventory.HasEquippedMoggles = spy.new(ReturnValueFn(false))
            end)

            describe("and has god mode", function()
                before_each(function()
                    playertools.god_mode_players = { inst }
                    playertools.IsGodMode = spy.new(ReturnValueFn(true))
                end)

                it("shouldn't call other functions", function()
                    assert.spy(_G.SDK.Player.IsInLight).was_not_called()
                    assert.spy(_G.SDK.Player.IsGhost).was_not_called()
                    assert.spy(playertools.inventory.HasEquippedMoggles).was_not_called()
                    playertools:CanGrueAttack()
                    assert.spy(_G.SDK.Player.IsInLight).was_not_called()
                    assert.spy(_G.SDK.Player.IsGhost).was_not_called()
                    assert.spy(playertools.inventory.HasEquippedMoggles).was_not_called()
                end)

                it("should return false", function()
                    assert.is_false(playertools:CanGrueAttack())
                end)
            end)

            describe("and doesn't have god mode", function()
                before_each(function()
                    playertools.god_mode_players = {}
                    playertools.IsGodMode = spy.new(ReturnValueFn(false))
                end)

                describe("and in light", function()
                    before_each(function()
                        _G.SDK.Player.IsInLight = spy.new(ReturnValueFn(true))
                    end)

                    it("should return false", function()
                        assert.is_false(playertools:CanGrueAttack())
                    end)
                end)

                describe("and in dark", function()
                    before_each(function()
                        _G.SDK.Player.IsInLight = spy.new(ReturnValueFn(false))
                    end)

                    describe("and a ghost", function()
                        before_each(function()
                            _G.SDK.Player.IsGhost = spy.new(ReturnValueFn(true))
                        end)

                        it("should return false", function()
                            assert.is_false(playertools:CanGrueAttack())
                        end)
                    end)

                    describe("but has Moggles equipped", function()
                        local _HasEquippedItemWithTag

                        before_each(function()
                            _HasEquippedItemWithTag = _G.SDK.Inventory.HasEquippedItemWithTag
                            _G.SDK.Inventory.HasEquippedItemWithTag = spy.new(ReturnValueFn(true))
                        end)

                        teardown(function()
                            _G.SDK.Inventory.HasEquippedItemWithTag = _HasEquippedItemWithTag
                        end)

                        it("should return false", function()
                            assert.is_false(playertools:CanGrueAttack())
                        end)
                    end)

                    it("should return true", function()
                        assert.is_true(playertools:CanGrueAttack())
                    end)
                end)
            end)
        end)
    end)

    describe("selection", function()
        describe("GetSelected", function()
            it("should call the ConsoleCommandPlayer", function()
                ConsoleCommandPlayer:clear()
                playertools:GetSelected()
                assert.spy(ConsoleCommandPlayer).was_called(1)
                assert.spy(ConsoleCommandPlayer).was_called_with()
            end)

            it("should return the ConsoleCommandPlayer", function()
                assert.is_equal(ConsoleCommandPlayer(), playertools:GetSelected())
            end)
        end)

        describe("Select", function()
            describe("in the local game", function()
                before_each(function()
                    _G.SDK.World.IsMasterSim = spy.new(ReturnValueFn(true))
                end)

                it("should set the selected_client field only", function()
                    EachPlayer(function(player)
                        playertools.selected_client = nil
                        playertools.selected_server = nil
                        playertools:Select(player)

                        assert.is_equal(
                            player,
                            playertools.selected_client,
                            player:GetDisplayName()
                        )

                        assert.is_nil(playertools.selected_server, player:GetDisplayName())
                    end)
                end)

                it("should debug string", function()
                    EachPlayer(function(player)
                        DebugSpyClear("DebugString")
                        playertools:Select(player)
                        AssertDebugSpyWasCalled("DebugString", 1, {
                            "Selected",
                            player:GetDisplayName()
                        })
                    end)
                end)

                it("should return true", function()
                    EachPlayer(function(player)
                        assert.is_true(playertools:Select(player), player:GetDisplayName())
                    end)
                end)
            end)

            describe("on dedicated server", function()
                before_each(function()
                    _G.SDK.World.IsMasterSim = spy.new(ReturnValueFn(false))
                end)

                it("should set the selected_client field only", function()
                    EachPlayer(function(player)
                        playertools.selected_client = nil
                        playertools.selected_server = nil
                        playertools:Select(player)

                        assert.is_equal(
                            player,
                            playertools.selected_client,
                            player:GetDisplayName()
                        )

                        assert.is_equal(
                            player,
                            playertools.selected_server,
                            player:GetDisplayName()
                        )
                    end)
                end)

                it("should debug 2 strings", function()
                    EachPlayer(function(player)
                        DebugSpyClear("DebugString")
                        playertools:Select(player)

                        local name = player:GetDisplayName()
                        AssertDebugSpyWasCalled("DebugString", 2, {
                            "[client]",
                            "Selected",
                            name
                        })

                        AssertDebugSpyWasCalled("DebugString", 2, {
                            "[server]",
                            "Selected",
                            name
                        })
                    end)
                end)

                it("should return true", function()
                    EachPlayer(function(player)
                        assert.is_true(playertools:Select(player), player:GetDisplayName())
                    end)
                end)
            end)
        end)

        describe("IsSelectedInSync", function()
            describe("in the local game", function()
                before_each(function()
                    _G.SDK.World.IsMasterSim = spy.new(ReturnValueFn(true))
                end)

                describe("when the player is selected on the client only", function()
                    before_each(function()
                        playertools.selected_client = inst
                        playertools.selected_server = nil
                    end)

                    it("should return true", function()
                        assert.is_true(playertools:IsSelectedInSync())
                    end)
                end)

                describe("when the player is selected on the server only", function()
                    before_each(function()
                        playertools.selected_client = nil
                        playertools.selected_server = inst
                    end)

                    it("should return false", function()
                        assert.is_false(playertools:IsSelectedInSync())
                    end)
                end)

                describe("when the player is selected on both client and server", function()
                    before_each(function()
                        playertools.selected_client = inst
                        playertools.selected_server = inst
                    end)

                    it("should return true", function()
                        assert.is_true(playertools:IsSelectedInSync())
                    end)
                end)
            end)

            describe("on dedicated server", function()
                before_each(function()
                    _G.SDK.World.IsMasterSim = spy.new(ReturnValueFn(false))
                end)

                describe("when the player is selected on the client only", function()
                    before_each(function()
                        playertools.selected_client = inst
                        playertools.selected_server = nil
                    end)

                    it("should return true", function()
                        assert.is_false(playertools:IsSelectedInSync())
                    end)
                end)

                describe("when the player is selected on the server only", function()
                    before_each(function()
                        playertools.selected_client = nil
                        playertools.selected_server = inst
                    end)

                    it("should return false", function()
                        assert.is_false(playertools:IsSelectedInSync())
                    end)
                end)

                describe("when the player is selected on both client and server", function()
                    before_each(function()
                        playertools.selected_client = inst
                        playertools.selected_server = inst
                    end)

                    it("should return false", function()
                        assert.is_true(playertools:IsSelectedInSync())
                    end)
                end)
            end)
        end)
    end)

    describe("god mode", function()
        describe("should have the getter", function()
            describe("getter", function()
                it("GetGodModePlayers", function()
                    AssertClassGetter(playertools, "god_mode_players", "GetGodModePlayers")
                end)
            end)
        end)

        describe("IsGodMode", function()
            describe("when the owner is not an admin", function()
                before_each(function()
                    _G.SDK.Player.IsAdmin = ReturnValueFn(false)
                    playertools.inst = player_dead
                end)

                it("should return nil", function()
                    EachPlayer(function(player)
                        assert.is_nil(playertools:IsGodMode(player), player:GetDisplayName())
                    end)
                end)
            end)

            describe("when the owner is an admin", function()
                before_each(function()
                    playertools.inst = inst
                end)

                describe("and the player is not in god_mode_players", function()
                    before_each(function()
                        playertools.god_mode_players = {}
                    end)

                    describe("but the health is invincible", function()
                        before_each(function()
                            EachPlayer(function(player)
                                player.components.health = {}
                                player.components.health.invincible = true
                            end)
                        end)

                        it("should return true", function()
                            EachPlayer(function(player)
                                assert.is_true(
                                    playertools:IsGodMode(player),
                                    player:GetDisplayName()
                                )
                            end)
                        end)
                    end)

                    describe("but the health is not invincible", function()
                        before_each(function()
                            EachPlayer(function(player)
                                player.components.health = {}
                                player.components.health.invincible = false
                            end)
                        end)

                        it("should return false", function()
                            EachPlayer(function(player)
                                assert.is_false(
                                    playertools:IsGodMode(player),
                                    player:GetDisplayName()
                                )
                            end)
                        end)
                    end)

                    describe("but the health components is missing", function()
                        it("should return false", function()
                            EachPlayer(function(player)
                                player.components.health.invincible = nil
                                assert.is_false(
                                    playertools:IsGodMode(player),
                                    player:GetDisplayName()
                                )

                                player.components.health = nil
                                assert.is_false(
                                    playertools:IsGodMode(player),
                                    player:GetDisplayName()
                                )

                                player.components = nil
                                assert.is_false(
                                    playertools:IsGodMode(player),
                                    player:GetDisplayName()
                                )
                            end)
                        end)
                    end)
                end)

                describe("and the player is in god_mode_players", function()
                    before_each(function()
                        playertools.god_mode_players = {}
                        EachPlayer(function(player)
                            table.insert(playertools.god_mode_players, player.userid)
                        end)
                    end)

                    describe("but the health is invincible", function()
                        before_each(function()
                            EachPlayer(function(player)
                                player.components.health = {}
                                player.components.health.invincible = true
                            end)
                        end)

                        it("should return true", function()
                            EachPlayer(function(player)
                                assert.is_true(
                                    playertools:IsGodMode(player),
                                    player:GetDisplayName()
                                )
                            end)
                        end)
                    end)

                    describe("but the health is not invincible", function()
                        before_each(function()
                            EachPlayer(function(player)
                                player.components.health = {}
                                player.components.health.invincible = false
                            end)
                        end)

                        it("should return false", function()
                            EachPlayer(function(player)
                                assert.is_false(
                                    playertools:IsGodMode(player),
                                    player:GetDisplayName()
                                )
                            end)
                        end)
                    end)

                    describe("but the health components is missing", function()
                        it("should return true", function()
                            EachPlayer(function(player)
                                player.components.health.invincible = nil
                                assert.is_true(
                                    playertools:IsGodMode(player),
                                    player:GetDisplayName()
                                )

                                player.components.health = nil
                                assert.is_true(
                                    playertools:IsGodMode(player),
                                    player:GetDisplayName()
                                )

                                player.components = nil
                                assert.is_true(
                                    playertools:IsGodMode(player),
                                    player:GetDisplayName()
                                )
                            end)
                        end)
                    end)
                end)
            end)
        end)

        describe("ToggleGodMode", function()
            describe("when the owner is not an admin", function()
                before_each(function()
                    _G.SDK.Player.IsAdmin = ReturnValueFn(false)
                    playertools.inst = player_dead
                end)

                it("should debug error", function()
                    EachPlayer(function(player)
                        DebugSpyClear("DebugError")
                        playertools:ToggleGodMode(player)
                        AssertDebugSpyWasCalled("DebugError", 1, {
                            "PlayerTools:ToggleGodMode():",
                            "not an admin"
                        })
                    end)
                end)

                it("should return nil", function()
                    EachPlayer(function(player)
                        assert.is_nil(playertools:ToggleGodMode(player), player:GetDisplayName())
                    end)
                end)
            end)

            describe("when the owner is an admin", function()
                before_each(function()
                    playertools.inst = inst
                end)

                describe("and the player is not in god mode", function()
                    before_each(function()
                        playertools.god_mode_players = {}
                        playertools.IsGodMode = ReturnValueFn(false)
                    end)

                    it("should add the player userid to the god_mode_players table", function()
                        EachPlayer(function(player)
                            assert.is_false(
                                TableHasValue(playertools.god_mode_players, player.userid),
                                player:GetDisplayName()
                            )

                            playertools:ToggleGodMode(player)

                            assert.is_true(
                                TableHasValue(playertools.god_mode_players, player.userid),
                                player:GetDisplayName()
                            )
                        end)
                    end)

                    it("should send the corresponding remote console command", function()
                        EachPlayer(function()
                            -- TODO: Add the missing PlayerTools:ToggleGodMode() test
                        end)
                    end)

                    it("should debug selected player string", function()
                        EachPlayer(function(player)
                            DebugSpyClear("DebugString")
                            playertools:ToggleGodMode(player)
                            AssertDebugSpyWasCalled("DebugString", 1, {
                                "(" .. player:GetDisplayName() .. ")",
                                "God Mode is enabled"
                            })
                        end)
                    end)

                    it("should return true", function()
                        EachPlayer(function(player)
                            assert.is_true(
                                playertools:ToggleGodMode(player),
                                player:GetDisplayName()
                            )
                        end)
                    end)
                end)

                describe("and the player is in god mode", function()
                    before_each(function()
                        playertools.god_mode_players = {}
                        playertools.IsGodMode = ReturnValueFn(true)

                        EachPlayer(function(player)
                            table.insert(playertools.god_mode_players, player.userid)
                        end)
                    end)

                    it("should remove the player from the god_mode_players table", function()
                        EachPlayer(function(player)
                            assert.is_true(
                                TableHasValue(playertools.god_mode_players, player.userid),
                                player:GetDisplayName()
                            )

                            playertools:ToggleGodMode(player)

                            assert.is_false(
                                TableHasValue(playertools.god_mode_players, player.userid),
                                player:GetDisplayName()
                            )
                        end)
                    end)

                    it("should send the corresponding remote console command", function()
                        EachPlayer(function()
                            -- TODO: Add the missing PlayerTools:ToggleGodMode() test
                        end)
                    end)

                    it("should debug selected player string", function()
                        EachPlayer(function(player)
                            DebugSpyClear("DebugString")
                            playertools:ToggleGodMode(player)
                            AssertDebugSpyWasCalled("DebugString", 1, {
                                "(" .. player:GetDisplayName() .. ")",
                                "God Mode is disabled"
                            })
                        end)
                    end)

                    it("should return false", function()
                        EachPlayer(function(player)
                            assert.is_false(
                                playertools:ToggleGodMode(player),
                                player:GetDisplayName()
                            )
                        end)
                    end)
                end)
            end)
        end)
    end)
end)
