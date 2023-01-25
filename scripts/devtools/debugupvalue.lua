----
-- Upvalue debugging.
--
-- Includes features/functionality to access to some in-game local variables using `debug` module
-- and it has been inspired by `UpvalueHacker` from
-- [here](https://github.com/rezecib/Rezecib-s-Rebalance/blob/master/scripts/tools/upvaluehacker.lua)
-- created by Rafael Lizarralde ([@rezecib](https://github.com/rezecib)).
--
-- **NB!** Should be used with caution and only as a last resort.
--
-- **Source Code:** [https://github.com/dstmodders/mod-dev-tools](https://github.com/dstmodders/mod-dev-tools)
--
-- @module DebugUpvalue
--
-- @author Rafael Lizarralde ([@rezecib](https://github.com/rezecib))
-- @copyright 2020
-- @license MIT
-- @release 0.7.1
local DebugUpvalue = {}

local function GetUpvalue(fn, name)
    local i = 1
    while debug.getupvalue(fn, i) and debug.getupvalue(fn, i) ~= name do
        i = i + 1
    end
    local _, value = debug.getupvalue(fn, i)
    return value, i
end

--- Gets function upvalue.
-- @tparam function fn
-- @tparam string ... Strings
function DebugUpvalue.GetUpvalue(fn, ...)
    local previous, i
    for _, var in ipairs({ ... }) do
        previous = fn
        fn, i = GetUpvalue(fn, var)
    end
    return fn, i, previous
end

--- Sets function upvalue.
-- @tparam function start_fn
-- @tparam function new_fn
-- @tparam string ... Strings
function DebugUpvalue.SetUpvalue(start_fn, new_fn, ...)
    local _, fni, scope_fn = DebugUpvalue.GetUpvalue(start_fn, ...)
    debug.setupvalue(scope_fn, fni, new_fn)
end

return DebugUpvalue
