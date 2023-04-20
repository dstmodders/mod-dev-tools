----
-- API.
--
-- Includes API functionality.
--
-- **Source Code:** [https://github.com/dstmodders/mod-dev-tools](https://github.com/dstmodders/mod-dev-tools)
--
-- @classmod API
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.8.0
----
require("class")
require("devtools/constants")

local Utils = require("devtools/utils")

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam DevTools devtools
local API = Class(function(self, devtools)
    Utils.Debug.AddMethods(self)

    -- general
    self.devtools = devtools
    self.name = "API"

    -- other
    self:DebugInit(self.name)
end)

--- General
-- @section general

--- Adds submenu.
-- @tparam string|table submenu Require string or data table
function API:AddSubmenu(submenu)
    if type(submenu) == "string" then
        self.devtools:AddSubmenusData(require(submenu))
    elseif type(submenu) == "table" then
        self.devtools:AddSubmenusData(submenu)
    end
end

--- Gets API version.
-- @treturn string
function API:GetAPIVersion() -- luacheck: only
    return MOD_DEV_TOOLS.API.VERSION
end

return API
