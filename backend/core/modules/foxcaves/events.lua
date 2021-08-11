local redis = require("foxcaves.redis")
local cjson = require("cjson")

module("events")

function push_raw(data, user)
	if user.id then
		user = user.id
	end
	redis.get_shared():publish("push:" .. user, cjson.encode(data))
end