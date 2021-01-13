----
-- Config.
--
-- Includes config functionality.
--
-- _Below is the list of some self-explanatory methods which have been added using SDK._
--
-- **Getters:**
--
--   - `GetDefaults`
--   - `GetValues`
--
-- **Setters:**
--
--   - `SetDefaults`
--   - `SetValues`
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @classmod Config
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.8.0-alpha
----
require "devtools/constants"

local SDK = require "devtools/sdk/sdk/sdk"

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam[opt] Data data
local Config = Class(function(self)
    SDK.Debug.AddMethods(self)
    SDK.PersistentData.Load().SetMode(SDK.PersistentData.DEFAULT).SetIsEncoded(false)
    SDK.Method
        .SetClass(self)
        .AddToString("Config")
        .AddGetters({
            defaults = "GetDefaults",
            values = "GetValues",
        })
        .AddSetters({
            defaults = "SetDefaults",
            values = "SetValues",
        })

    -- general
    self.defaults = {}
    self.values = {}

    -- other
    self:Load()
    self:DebugInit(tostring(self))
end)

--- General
-- @section general

--- Loads.
-- @treturn boolean
function Config:Load()
    SDK.PersistentData.Get("config", self, "values")
    if self.values == nil
        or (type(self.values) == "table" and SDK.Utils.Table.Count(self.values) == 0)
    then
        self.values = self.defaults
        return true
    end
    return false
end

--- Saves.
function Config:Save()
    SDK.PersistentData.Set("config", self.values).Save()
end

--- Defaults
-- @section defaults

--- Sets a default.
-- @tparam string name
-- @tparam any value
function Config:SetDefault(name, value)
    self.defaults[name] = value
end

--- Values
-- @section values

--- Gets a value.
-- @treturn table
function Config:GetValue(name)
    return self.values[name]
end

--- Resets a value.
-- @tparam string name
function Config:ResetValue(name)
    if self.values[name] ~= nil and self.defaults[name] ~= nil then
        self.values[name] = self.defaults[name]
    end
end

--- Sets a value.
-- @tparam string name
-- @tparam any value
function Config:SetValue(name, value)
    self.values[name] = value
end

return Config
