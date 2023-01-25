----
-- Different methods mod utilities.
--
-- **Source Code:** [https://github.com/dstmodders/mod-dev-tools](https://github.com/dstmodders/mod-dev-tools)
--
-- @module Utils.Methods
-- @see Utils
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.7.1
----
local Methods = {}

--- Adds methods from one class to another.
-- @tparam table src Source class to get methods from
-- @tparam table dest Destination class to add methods to
-- @tparam table methods Methods to add
function Methods.AddToAnotherClass(src, dest, methods)
    for k, v in pairs(methods) do
        -- we also add tables as they can behave as functions in some cases
        if type(src[v]) == "function" or type(src[v]) == "table" then
            k = type(k) == "number" and v or k
            rawset(dest, k, function(_, ...)
                return src[v](src, ...)
            end)
        end
    end
end

--- Adds methods from one class to another.
-- @tparam table src Source class from where we remove methods
-- @tparam table methods Methods to remove
function Methods.RemoveFromAnotherClass(src, methods)
    for _, v in pairs(methods) do
        -- we also add tables as they can behave as functions in some cases
        if type(src[v]) == "function" or type(src[v]) == "table" then
            src[v] = nil
        end
    end
end

return Methods
