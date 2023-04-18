----
-- API.
--
-- Includes API functionality.
--
-- **Source Code:** [https://github.com/dstmodders/mod-dev-tools](https://github.com/dstmodders/mod-dev-tools)
--
-- @classmod API
--
-- @author [Depressed DST Modders](https://github.com/dstmodders)
-- @copyright 2020
-- @license MIT
-- @release 0.8.0-alpha
----
require("devtools/constants")

local SDK = require("devtools/sdk/sdk/sdk")

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam DevTools devtools
local API = Class(function(self, devtools)
    SDK.Debug.AddMethods(self)
    SDK.Method.SetClass(self).AddToString("API")

    -- general
    self.devtools = devtools

    -- other
    self:DebugInit(tostring(self))
end)

--- General
-- @section general

--- Adds a submenu.
-- @tparam string|table submenu Require string or data table
function API:AddSubmenu(submenu)
    if type(submenu) == "string" then
        self.devtools:AddSubmenusData(require(submenu))
    elseif type(submenu) == "table" then
        self.devtools:AddSubmenusData(submenu)
    end
end

--- Gets an API version.
-- @treturn string
function API:GetAPIVersion() -- luacheck: only
    return MOD_DEV_TOOLS.API.VERSION
end

return API
