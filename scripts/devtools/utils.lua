----
-- Different mod utilities.
--
-- Includes different utilities used throughout the whole mod.
--
-- In order to become an utility the solution should either:
--
-- 1. Be a non-mod specific and isolated which can be reused in my other mods.
-- 2. Be a mod specific and isolated which can be used between classes/modules.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @module Utils
-- @see Utils.Chain
-- @see Utils.Constant
-- @see Utils.Debug
-- @see Utils.Dump
-- @see Utils.Entity
-- @see Utils.Methods
-- @see Utils.Modmain
-- @see Utils.RPC
-- @see Utils.String
-- @see Utils.Table
-- @see Utils.Thread
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.2.0-alpha
----
local Utils = {}

Utils.Chain = require "devtools/utils/chain"
Utils.Constant = require "devtools/utils/constant"
Utils.Debug = require "devtools/utils/debug"
Utils.Dump = require "devtools/utils/dump"
Utils.Entity = require "devtools/utils/entity"
Utils.Methods = require "devtools/utils/methods"
Utils.Modmain = require "devtools/utils/modmain"
Utils.RPC = require "devtools/utils/rpc"
Utils.String = require "devtools/utils/string"
Utils.Table = require "devtools/utils/table"
Utils.Thread = require "devtools/utils/thread"

--- Assets if the required field is not missing.
-- @tparam string name
-- @tparam any field
function Utils.AssertRequiredField(name, field)
    assert(field ~= nil, string.format("Required %s is missing", name))
end

--- Executes the console command remotely.
-- @tparam string cmd Command to execute
-- @tparam[opt] table data Data that will be unpacked and used alongside with string
-- @treturn table
function Utils.ConsoleRemote(cmd, data)
    local fn_str = string.format(cmd, unpack(data or {}))
    local x, _, z = TheSim:ProjectScreenPos(TheSim:GetPosition())
    TheNet:SendRemoteExecute(fn_str, x, z)
end

return Utils
