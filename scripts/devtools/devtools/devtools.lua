----
-- Base dev tools.
--
-- Includes base dev tools functionality and must be extended by other related classes. Shouldn't
-- be used on its own.
--
-- @classmod devtools.DevTools
-- @see DevTools
-- @see devtools.player.ConsoleDevTools
-- @see devtools.player.CraftingDevTools
-- @see devtools.player.InventoryDevTools
-- @see devtools.player.MapDevTools
-- @see devtools.player.VisionDevTools
-- @see devtools.PlayerDevTools
-- @see devtools.world.SaveDataDevTools
-- @see devtools.WorldDevTools
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.1.0-alpha
----
require "class"

local Utils = require "devtools/utils"

--- Constructor.
-- @function _ctor
-- @tparam[opt] string name
-- @tparam[opt] DevTools devtools
-- @usage local devtools = DevTools()
local DevTools = Class(function(self, name, devtools)
    Utils.AddDebugMethods(self)

    -- initialization
    self._init = {
        dest = nil,
        field = nil,
        methods = {},
    }

    -- general
    self.devtools = devtools
    self.name = name ~= nil and name or "DevTools"
    self.owner = devtools.inst
    self.worlddevtools = devtools.world
end)

--- General
-- @section general

--- Gets name.
-- @treturn string
function DevTools:GetName()
    return self.name
end

--- Gets full function name.
--
-- Just prepends the name to the provided function name.
--
-- @tparam function fn_name Function name
-- @treturn string
-- @usage local devtools = DevTools("YourDevTools")
-- print(devtools:GetFnFullName("GetName")) -- prints: YourDevTools:GetName()
--
function DevTools:GetFnFullName(fn_name)
    return string.format("%s:%s()", self.name, fn_name)
end

function DevTools:AddGlobalDevToolsMethods(methods)
    Utils.Methods.AddToAnotherClass(self, self.devtools, methods)
end

function DevTools:RemoveGlobalDevToolsMethods(methods)
    Utils.Methods.RemoveFromAnotherClass(self.devtools, methods)
end

--- Other
-- @section other

--- __tostring
-- @treturn string
function DevTools:__tostring()
    return self.name
end

--- Lifecycle
-- @section lifecycle

--- Initializes.
--
-- Adds provided methods and a field in the destination class.
--
-- @tparam table dest Destination class
-- @tparam string field Destination class field
-- @tparam table methods Methods to add
function DevTools:DoInit(dest, field, methods)
    methods = methods ~= nil and methods or {}

    Utils.AssertRequiredField(self.name .. ".devtools", self.devtools)

    local init = self._init

    if dest then
        init.dest = dest
        init.field = field
        dest[field] = self
    end

    self:AddGlobalDevToolsMethods(methods)

    init.methods = methods

    self:DebugInit(self.name)
end

--- Terminates.
--
-- Removes added methods and a field added earlier by `DoInit`.
function DevTools:DoTerm()
    Utils.AssertRequiredField(self.name .. ".devtools", self.devtools)

    local init = self._init

    if init and init.dest and init.field then
        init.dest[init.field] = nil
    end

    if init and init.methods then
        self:RemoveGlobalDevToolsMethods(init.methods)
    end

    self._init = {
        dest = nil,
        field = nil,
        methods = {},
    }

    self:DebugTerm(self.name)
end

return DevTools
