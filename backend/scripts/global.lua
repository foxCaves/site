lfs.chdir(ngx.var.main_root)
dofile("/var/www/foxcaves/config/main.lua")

ngx.ctx.user = nil

local redis = require("resty.redis")

local database, err = redis:new()
if not database then
	ngx.print("Error initializing DB: ", err)
	return ngx.eof()
end
database:set_timeout(60000)

dofile("/var/www/foxcaves/config/database.lua")
local ok, err = database:connect(dbip, dbport)
if not ok then
	ngx.print("Error connecting to DB: ", err)
	return ngx.eof()
end

if database:get_reused_times() == 0 and dbpass then
	local ok, err = database:auth(dbpass)
	if not ok then
		ngx.print("Error connecting to DB: ", err)
		return ngx.eof()
	end
end

database.KEYS =  {
    USERS = "users:",
    USERNAME_TO_ID = "username_to_id:",
    USEDINVOICES = "used_invoices:",
    SESSIONS = "sessions:",
    NEXTUSERID = "next_user_id:",
    PUSH = "push:",

    FILES = "files:",
    USER_FILES = "user_files:",

    EMAILS = "emails:",
    EMAILKEYS = "email_keys:",

    LINKS = "links:",
    USER_LINKS = "user_links:",
}
dbip = nil
dbport = nil
dbpass = nil

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

ngx.ctx.database = database

ngx.ctx.EMAIL_INVALID = -1
ngx.ctx.EMAIL_TAKEN = -2
function ngx.ctx.check_email(email)
	if not ngx.re.match(email, "^[a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\\.[a-zA-Z]{2,4}$", "o") then
		return ngx.ctx.EMAIL_INVALID
	end

	local res = database:sismember(database.KEYS.EMAILS, email:lower())
	if res and res ~= 0 and res ~= ngx.null then
		return ngx.ctx.EMAIL_TAKEN
	end
	return nil
end

function ngx.ctx.check_username(username)
	if not ngx.re.match(username, "^[a-zA-Z0-9 .,;_-]+$", "o") then
		return ngx.ctx.EMAIL_INVALID
	end

	local res = database:exists(database.KEYS.USERS .. username:lower())
	if res and res ~= 0 and res ~= ngx.null then
		return ngx.ctx.EMAIL_TAKEN
	end
	return nil
end

local sizePostFixes = {" B", " kB", " MB", " GB", " TB", " PB", " EB", " ZB", " YB"}

function ngx.ctx.format_size(size)
	size = tonumber(size)
	local sinc = 1
	while size > 1024 do
		sinc = sinc + 1
		size = size / 1024
		if sinc == 9 then
			break
		end
	end
	return (math.ceil(size * 100) / 100) .. assert(sizePostFixes[sinc], "No suitable postfix for file size")
end

local repTbl = {
	["&"] = "&amp;",
	["<"] = "&lt;",
	[">"] = "&gt;",
}

function ngx.ctx.escape_html(str)
	if (not str) or type(str) ~= "string" then
		return str
	end
	str = str:gsub("[&<>]", repTbl)
	return str
end

function ngx.ctx.get_post_args(...)
	if not ngx.req.get_body_data() then return nil end
	return ngx.req.get_post_args(...)
end

function ngx.ctx.get_version()
	local fh = io.open(".revision", "r")
	if not fh then
		return "UNKNOWN"
	end
	local ret = fh:read("*all")
	fh:close()
	return ret:gsub("%s+", "")
end

function raw_push_action(action)
	action = action or '='
	database:publish(database.KEYS.PUSH .. ngx.ctx.user.id .. "_" .. ngx.ctx.user.pushchan, action .. "|")
end

function printTemplateAndClose(name, params)
	ngx.print(load_template(name, params))
	ngx.eof()
end
dofile("scripts/access.lua")

_G.ngx = ngx
_G.math = math
_G.tonumber = tonumber
_G.tostring = tostring
_G.os = os
_G.lfs = lfs
_G.cjson = cjson