local M = {}
setfenv(1, M)

M.VALIDATION_STATE_OK = 0
M.VALIDATION_STATE_INVALID = -1
M.VALIDATION_STATE_TAKEN = -2

M.LOGIN_SUCCESS = 1
M.LOGIN_USER_BANNED = -1
M.LOGIN_BAD_CREDENTIALS = -10

M.ENV_PRODUCTION = 1
M.ENV_DEVELOPMENT = 2
M.ENV_TESTING = 3
M.ENV_STAGING = 4
M.ENV_INVALID = -1

-- Load paths
local path = require("path")
local CORE_ROOT = path.abs(debug.getinfo(1, "S").source:sub(2):match("(.*/)") .. "/../../")
M.LUA_ROOT = path.abs(CORE_ROOT .. "/../")
M.ROOT = path.abs(M.LUA_ROOT .. "/../")

return M
