----
-- Teleport submenu.
--
-- Extends `menu.submenu.Submenu`.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod menu.submenu.TeleportSubmenu
-- @see menu.submenu.Submenu
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
require "class"

local Submenu = require "devtools/menu/submenu/submenu"

local TeleportSubmenu = Class(Submenu, function(self, devtools, root)
    Submenu._ctor(self, devtools, root, "Teleport", "TeleportSubmenu", #root + 1)

    -- general
    self.console = devtools.player and devtools.player.console
    self.devtools = devtools
    self.player = devtools.player
    self.world = devtools.world

    -- options
    if self.world and self.player and self.console and self.screen and self.player:IsAdmin() then
        self:AddSelectedPlayerLabelPrefix(devtools, self.player)
        self:AddOptions()
        self:AddToRoot()
    end
end)

--- Helpers
-- @section helpers

local function AddGatherPlayersOption(self)
    self:AddDoActionOption({
        label = "Gather Players",
        on_accept_fn = function()
            self.console:GatherPlayers()
            self:UpdateScreen("selected")
        end,
    })
end

local function AddGoNextOption(self, label, prefab)
    self:AddDoActionOption({
        label = label,
        on_accept_fn = function()
            local gonext = prefab
            if type(prefab) == "table" then
                gonext = prefab[math.random(#prefab)]
            end
            self.console:GoNext(label, gonext)
            self:UpdateScreen("selected")
        end,
    })
end

--- General
-- @section general

--- Adds options.
function TeleportSubmenu:AddOptions()
    AddGatherPlayersOption(self)

    self:AddDividerOption()
    if not self.world:IsCave() then
        local livingtree = IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS)
            and "livingtree_halloween"
            or "livingtree"

        AddGoNextOption(self, "Antlion Nest", "antlion_spawner")
        AddGoNextOption(self, "Beefalo", "beefalo")
        AddGoNextOption(self, "Catcoon", "catcoon")
        AddGoNextOption(self, "Cave Entrance", "cave_entrance")
        AddGoNextOption(self, "Deer", "deer")
        AddGoNextOption(self, "Desert Oasis", "oasislake")
        AddGoNextOption(self, "Eyebone (Chester)", "chester_eyebone")
        AddGoNextOption(self, "Glommer Statue", "statueglommer")
        AddGoNextOption(self, "Gravestone", "gravestone")
        AddGoNextOption(self, "Leaky Shack", "mermhouse")
        AddGoNextOption(self, "Mandrake", "mandrake_planted")
        AddGoNextOption(self, "Moon Stone", "moonbase")
        AddGoNextOption(self, "Pig Head", "pighead")
        AddGoNextOption(self, "Pig House", "pighouse")
        AddGoNextOption(self, "Pig King", "pigking")
        AddGoNextOption(self, "Pond", "pond")
        AddGoNextOption(self, "Spawn Portal", "multiplayer_portal")
        AddGoNextOption(self, "Spider Den", "spiderden")
        AddGoNextOption(self, "Stagehand", "stagehand")
        AddGoNextOption(self, "Totally Normal Tree", livingtree)
        AddGoNextOption(self, "Touch Stone", "resurrectionstone")
        AddGoNextOption(self, "Walrus Camp", "walrus_camp")
        AddGoNextOption(self, "Worm Hole", "wormhole")

        self:AddDividerOption()
        AddGoNextOption(self, "Bearger", "bearger")
        AddGoNextOption(self, "Deerclops", "deerclops")
        AddGoNextOption(self, "Dragonfly", "dragonfly")
        AddGoNextOption(self, "Gigantic Beehive", "beequeenhive")
        AddGoNextOption(self, "Klaus Sack", "klaus_sack")
        AddGoNextOption(self, "Malbatross", "malbatross")

        self:AddDividerOption()
        AddGoNextOption(self, "Marble Sculpture (Bishop Body)", "sculpture_bishopbody")
        AddGoNextOption(self, "Marble Sculpture (Knight Body)", "sculpture_knightbody")
        AddGoNextOption(self, "Marble Sculpture (Rook Body)", "sculpture_rookbody")
        AddGoNextOption(self, "Suspicious Marble (Bishop Head)", "sculpture_bishophead")
        AddGoNextOption(self, "Suspicious Marble (Knight Head)", "sculpture_knighthead")
        AddGoNextOption(self, "Suspicious Marble (Rook Nose)", "sculpture_rooknose")

        self:AddDividerOption()
        AddGoNextOption(self, "Hot Spring", "hotspring")
        AddGoNextOption(self, "Inviting Formation (Base)", "moon_altar_rock_glass")
        AddGoNextOption(self, "Inviting Formation (Idol)", "moon_altar_rock_idol")
        AddGoNextOption(self, "Inviting Formation (Orb)", "moon_altar_rock_seed")
        AddGoNextOption(self, "Stone Fruit Bush", "rock_avocado_bush")
    else
        local statues = {
            "ruins_statue_mage",
            "ruins_statue_head",
        }

        AddGoNextOption(self, "Ancient Pseudoscience Station (Broken)", "ancient_altar_broken")
        AddGoNextOption(self, "Ancient Pseudoscience Station", "ancient_altar")
        AddGoNextOption(self, "Ancient Statue", statues)
        AddGoNextOption(self, "Bat Cave", "batcave")
        AddGoNextOption(self, "Big Tentacle", "tentacle_pillar")
        AddGoNextOption(self, "Broken Clockworks", "chessjunk_ruinsrespawner_inst")
        AddGoNextOption(self, "Cave Exit", "cave_exit")
        AddGoNextOption(self, "Cave Hole", "cave_hole")
        AddGoNextOption(self, "Gravestone", "gravestone")
        AddGoNextOption(self, "Light Flower", "flower_cave_triple")
        AddGoNextOption(self, "Ornate Chest", "pandoraschest")
        AddGoNextOption(self, "Pond (Cave)", "pond_cave")
        AddGoNextOption(self, "Pond", "pond")
        AddGoNextOption(self, "Rock Lobster", "rocky")
        AddGoNextOption(self, "Slurper", "slurper")
        AddGoNextOption(self, "Slurtle Mound", "slurtlehole")
        AddGoNextOption(self, "Spider Den", "spiderden")
        AddGoNextOption(self, "Splumonkey Pod", "monkeybarrel")
        AddGoNextOption(self, "Star-sky (Hutch)", "hutch_fishbowl")
        AddGoNextOption(self, "Touch Stone", "resurrectionstone")

        self:AddDividerOption()
        AddGoNextOption(self, "Ancient Gateway", "atrium_gate")
        AddGoNextOption(self, "Ancient Guardian", "minotaur")
        AddGoNextOption(self, "Toadstool Cap", "toadstool_cap")
    end
end

return TeleportSubmenu
