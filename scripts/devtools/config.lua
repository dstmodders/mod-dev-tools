----
-- Config.
--
-- Includes config functionality.
--
-- **Source Code:** [https://github.com/dstmodders/mod-dev-tools](https://github.com/dstmodders/mod-dev-tools)
--
-- @classmod Config
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.7.1
----
require("class")
require("devtools/constants")

local Utils = require("devtools/utils")

--- Lifecycle
-- @section lifecycle

--- Constructor.
-- @function _ctor
-- @tparam[opt] Data data
local Config = Class(function(self, data)
    Utils.Debug.AddMethods(self)

    -- general
    self.data = data
    self.defaults = {}
    self.name = "Config"
    self.values = {}

    -- other
    self:Load()
    self:DebugInit(self.name)
end)

--- General
-- @section general

--- Loads.
-- @treturn boolean
function Config:Load()
    if self.data then
        self.data:GeneralGet("config", self, "values")
        if
            self.values == nil
            or (type(self.values) == "table" and Utils.Table.Count(self.values) == 0)
        then
            self.values = self.defaults
        end
        return true
    end
    return false
end

--- Saves.
-- @treturn boolean
function Config:Save()
    if self.data then
        self.data:GeneralSet("config", self.values)
        self.data:Save()
        return true
    end
    return false
end

--- Defaults
-- @section defaults

--- Gets defaults.
-- @treturn table
function Config:GetDefaults()
    return self.defaults
end

--- Sets defaults.
-- @tparam table defaults
function Config:SetDefaults(defaults)
    self.defaults = defaults
end

--- Gets default.
-- @treturn table
function Config:GetDefault(name)
    return self.defaults[name]
end

--- Sets default.
-- @tparam string name
-- @tparam any value
function Config:SetDefault(name, value)
    self.defaults[name] = value
end

--- Values
-- @section values

--- Gets values.
-- @treturn table
function Config:GetValues()
    return self.values
end

--- Sets values.
-- @tparam table values
function Config:SetValues(values)
    self.values = values
end

--- Gets value.
-- @treturn table
function Config:GetValue(name)
    return self.values[name]
end

--- Sets value.
-- @tparam string name
-- @tparam any value
function Config:SetValue(name, value)
    self.values[name] = value
    self:Save()
end

--- Resets value.
-- @tparam string name
function Config:ResetValue(name)
    if self.values[name] ~= nil and self.defaults[name] ~= nil then
        self.values[name] = self.defaults[name]
        self:Save()
    end
end

return Config
