local env = require("foxcaves.env")
local revision = require("foxcaves.revision")
local sentry_enabled = not not require("foxcaves.config").sentry.dsn

register_route("/api/v1/system/info", "GET", make_route_opts_anon(), function()
    return {
        environment = env,
        release = revision.hash,
        sentry = sentry_enabled,
    }
end)
