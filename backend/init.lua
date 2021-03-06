-- Protect global table
setmetatable(_G, {
    __index = function(_, k)
        error("Attempt to read unknown from _G: " .. k)
    end,
    __newindex = function(_, k)
        if k == "lfs" or k == "path" or k == "socket" then
            return
        end
        error("Attempt to write to _G: " .. k)
    end,
})

-- Load module path
local path = require("path")
local root = path.abs(debug.getinfo(1, "S").source:sub(2):match("(.*/)"))
package.path = package.path .. ";" .. path.abs(root .. "/modules"):gsub("//+", "/") .. "/?.lua"

-- Secure cjson
local cjson = require("cjson")
cjson.decode_max_depth(10)
cjson.decode_invalid_numbers(false)

-- Load environment vars
rawset(_G, 'OSENV', {
    ENVIRONMENT = true
})
for k, _ in pairs(OSENV) do
    rawset(OSENV, k, os.getenv(k))
end

dofile(root .. "/migrator.lua")
