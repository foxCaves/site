local resty_redis = require("resty.redis")
local utils = require("foxcaves.utils")
local next = next
local error = error
local ngx = ngx

local config = CONFIG.redis

module("redis")

function make(close_on_shutdown)
	local database, err = resty_redis:new()
	if not database then
		error("Error initializing DB: " .. err)
	end
	database:set_timeout(60000)

	local ok, err = database:connect(config.host, config.port)
	if not ok then
		error("Error connecting to DB: " .. err)
	end

	if database:get_reused_times() == 0 and config.password then
		local ok, err = database:auth(config.password)
		if not ok then
			error("Error connecting to DB: " .. err)
		end
	end

	database.hgetall_real = database.hgetall
	function database:hgetall(key)
		local res = self:hgetall_real(key)
		if (not res) or (res == ngx.null) then
			return res
		end
		local ret = {}
		local k = nil
		for _,v in next, res do
			if not k then
				k = v
			else
				ret[k] = v
				k = nil
			end
		end
		return ret
	end

	database.hmget_real = database.hmget
	function database:hmget(key, ...)
		local res = self:hmget_real(key, ...)
		if (not res) or (res == ngx.null) then
			return res
		end
		local ret = {}
		local tbl = {...}
		for i,v in next, tbl do
			ret[v] = res[i]
		end
		return ret
	end

	if close_on_shutdown then
		utils.register_shutdown(function() database:close() end)
	else
		utils.register_shutdown(function() database:set_keepalive(config.keepalive_timeout or 10000, config.keepalive_count or 10) end)
	end

	return database
end

function get_shared()
	local redis = ngx.ctx.__redis
	if redis then
		return redis
	end
	redis = make()
	ngx.ctx.__redis = redis
	return redis
end