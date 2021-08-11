ENV_PRODUCTION = 1
ENV_DEVELOPMENT = 2
ENV_TESTING = 3
ENV_STAGING = 4
ENV_INVALID = -1

REVISION = "unknown"
ENVIRONMENT_STRING = "invalid"
ENVIRONMENT = ENV_INVALID

CONFIG = {}

setmetatable(_G, {
	__index = function(t, k)
		error("Attempt to read unknown from _G: " .. k)
	end,
	__newindex = function(t, k, v)
		error("Attempt to write to _G: " .. k)
	end,
})

local lfs = require("lfs")

local function load_revision()
	local fh = io.open("/var/www/foxcaves/.revision", "r")
	if not fh then
		return
	end
	REVISION = fh:read("*all"):gsub("%s+", "")
	fh:close()
end
load_revision()

local function init_environment()
	local envtbl = {
		production = ENV_PRODUCTION,
		development = ENV_DEVELOPMENT,
		testing = ENV_TESTING,
		staging = ENV_STAGING,
	}
	local str = os.getenv("ENVIRONMENT"):lower()
	ENVIRONMENT = envtbl[str]
	if not ENVIRONMENT then
		error("Invalid environment")
	end
	ENVIRONMENT_STRING = str
end
init_environment()

dofile("/var/www/foxcaves/config/" .. ENVIRONMENT_STRING .. ".lua")

require("foxcaves.router").load()
