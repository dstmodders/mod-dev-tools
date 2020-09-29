----
-- Teleport submenu.
--
-- Extends `menu.Submenu`.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod submenus.TeleportSubmenu
-- @see menu.Submenu
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.6.0
----
require "class"

local Submenu = require "devtools/menu/submenu"

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam DevTools devtools
-- @tparam Widget root
-- @usage local teleportsubmenu = TeleportSubmenu(devtools, root)
local TeleportSubmenu = Class(Submenu, function(self, devtools, root)
    Submenu._ctor(
        self,
        devtools,
        root,
        "Teleport",
        "TeleportSubmenu",
        MOD_DEV_TOOLS.DATA_SIDEBAR.SELECTED
    )

    -- options
    if self.world and self.player and self.console and self.screen and self.player:IsAdmin() then
        self:AddSelectedPlayerLabelPrefix(devtools, self.player)
        self:AddOptions()
        self:AddToRoot()
    end
end)

--- General
-- @section general

--- Adds gather players option.
function TeleportSubmenu:AddGatherPlayersOption()
    self:AddActionOption({
        label = "Gather Players",
        on_accept_fn = function()
            self.console:GatherPlayers()
            self:UpdateScreen()
        end,
    })
end

--- Adds go next option.
-- @tparam table|string label
-- @tparam string prefab
function TeleportSubmenu:AddGoNextOption(label, prefab)
    self:AddActionOption({
        label = label,
        on_accept_fn = function()
            local gonext = prefab
            if type(prefab) == "table" then
                gonext = prefab[math.random(#prefab)]
            end
            self.console:GoNext(label, gonext)
            self:UpdateScreen()
        end,
    })
end

--- Adds teleport options.
function TeleportSubmenu:AddTeleportOptions()
    if not self.world:IsCave() then
        local livingtree = IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS)
            and "livingtree_halloween"
            or "livingtree"

        self:AddGoNextOption("Antlion Nest", "antlion_spawner")
        self:AddGoNextOption("Beefalo", "beefalo")
        self:AddGoNextOption("Catcoon", "catcoon")
        self:AddGoNextOption("Cave Entrance", "cave_entrance")
        self:AddGoNextOption("Deer", "deer")
        self:AddGoNextOption("Desert Oasis", "oasislake")
        self:AddGoNextOption("Eyebone (Chester)", "chester_eyebone")
        self:AddGoNextOption("Glommer Statue", "statueglommer")
        self:AddGoNextOption("Gravestone", "gravestone")
        self:AddGoNextOption("Leaky Shack", "mermhouse")
        self:AddGoNextOption("Mandrake", "mandrake_planted")
        self:AddGoNextOption("Moon Stone", "moonbase")
        self:AddGoNextOption("Pig Head", "pighead")
        self:AddGoNextOption("Pig House", "pighouse")
        self:AddGoNextOption("Pig King", "pigking")
        self:AddGoNextOption("Pond", "pond")
        self:AddGoNextOption("Spawn Portal", "multiplayer_portal")
        self:AddGoNextOption("Spider Den", "spiderden")
        self:AddGoNextOption("Stagehand", "stagehand")
        self:AddGoNextOption("Totally Normal Tree", livingtree)
        self:AddGoNextOption("Touch Stone", "resurrectionstone")
        self:AddGoNextOption("Walrus Camp", "walrus_camp")
        self:AddGoNextOption("Worm Hole", "wormhole")

        self:AddDividerOption()
        self:AddGoNextOption("Bearger", "bearger")
        self:AddGoNextOption("Deerclops", "deerclops")
        self:AddGoNextOption("Dragonfly", "dragonfly")
        self:AddGoNextOption("Gigantic Beehive", "beequeenhive")
        self:AddGoNextOption("Klaus Sack", "klaus_sack")
        self:AddGoNextOption("Malbatross", "malbatross")

        self:AddDividerOption()
        self:AddGoNextOption("Marble Sculpture (Bishop Body)", "sculpture_bishopbody")
        self:AddGoNextOption("Marble Sculpture (Knight Body)", "sculpture_knightbody")
        self:AddGoNextOption("Marble Sculpture (Rook Body)", "sculpture_rookbody")
        self:AddGoNextOption("Suspicious Marble (Bishop Head)", "sculpture_bishophead")
        self:AddGoNextOption("Suspicious Marble (Knight Head)", "sculpture_knighthead")
        self:AddGoNextOption("Suspicious Marble (Rook Nose)", "sculpture_rooknose")

        self:AddDividerOption()
        self:AddGoNextOption("Hot Spring", "hotspring")
        self:AddGoNextOption("Inviting Formation (Base)", "moon_altar_rock_glass")
        self:AddGoNextOption("Inviting Formation (Idol)", "moon_altar_rock_idol")
        self:AddGoNextOption("Inviting Formation (Orb)", "moon_altar_rock_seed")
        self:AddGoNextOption("Stone Fruit Bush", "rock_avocado_bush")
    else
        local statues = {
            "ruins_statue_mage",
            "ruins_statue_head",
        }

        self:AddGoNextOption("Ancient Pseudoscience Station (Broken)", "ancient_altar_broken")
        self:AddGoNextOption("Ancient Pseudoscience Station", "ancient_altar")
        self:AddGoNextOption("Ancient Statue", statues)
        self:AddGoNextOption("Bat Cave", "batcave")
        self:AddGoNextOption("Big Tentacle", "tentacle_pillar")
        self:AddGoNextOption("Broken Clockworks", "chessjunk_ruinsrespawner_inst")
        self:AddGoNextOption("Cave Exit", "cave_exit")
        self:AddGoNextOption("Cave Hole", "cave_hole")
        self:AddGoNextOption("Gravestone", "gravestone")
        self:AddGoNextOption("Light Flower", "flower_cave_triple")
        self:AddGoNextOption("Ornate Chest", "pandoraschest")
        self:AddGoNextOption("Pond (Cave)", "pond_cave")
        self:AddGoNextOption("Pond", "pond")
        self:AddGoNextOption("Rock Lobster", "rocky")
        self:AddGoNextOption("Slurper", "slurper")
        self:AddGoNextOption("Slurtle Mound", "slurtlehole")
        self:AddGoNextOption("Spider Den", "spiderden")
        self:AddGoNextOption("Splumonkey Pod", "monkeybarrel")
        self:AddGoNextOption("Star-sky (Hutch)", "hutch_fishbowl")
        self:AddGoNextOption("Touch Stone", "resurrectionstone")

        self:AddDividerOption()
        self:AddGoNextOption("Ancient Gateway", "atrium_gate")
        self:AddGoNextOption("Ancient Guardian", "minotaur")
        self:AddGoNextOption("Toadstool Cap", "toadstool_cap")
    end
end

--- Adds options.
function TeleportSubmenu:AddOptions()
    self:AddGatherPlayersOption()
    self:AddDividerOption()
    self:AddTeleportOptions()
end

return TeleportSubmenu
