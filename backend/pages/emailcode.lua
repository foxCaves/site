-- ROUTE:GET:/emailcode
dofile(ngx.var.main_root .. "/scripts/global.lua")
if ngx.ctx.user then return ngx.redirect("/myaccount") end
local database = ngx.ctx.database

local codeID = database.KEYS.EMAILKEYS .. ngx.unescape_uri(ngx.var.arg_code)
local res = database:hgetall(codeID)

dofile("scripts/userapi.lua")

local actiontitle, message
if res and res.user and res ~= ngx.null then
	local userID = database.KEYS.USERS .. res.user

	local userdata = database:hgetall(userID)

	if res.action == "activation" then
		actiontitle = "Activation"

		if userdata.active and userdata.active ~= "0" and userdata.active ~= 0 then
			message = "<div class='alert alert-success'>Your account was already active or is banned</div>"
		else
			message = "<div class='alert alert-success'>Your account has been activated. Please <a href='/login'>login</a> now.</div>"
			database:hset(userID, "active", 1)
		end
	elseif res.action == "forgotpwd" then
		actiontitle = "Forgot password"
		message = "<div class='alert alert-success'>A new password has been sent to you. Once you received it, please <a href='/login'>login</a>.</div>"

		local newPassword = randstr(16)
		local newSalt = randstr(32)
		database:hmset(userID, "salt", newSalt, "password", ngx.hmac_sha1(newSalt, newPassword))

		local email = "Hello, " .. userdata.username .. "!\n\nHere is your new password:\n" .. newPassword .. "\nPlease log in at " .. MAIN_URL .. "/login and change it as soon as possible.\n\nKind regards,\nfoxCaves Support"
		mail(userdata.email, "foxCaves - New password", email, "noreply@foxcav.es", "foxCaves")

		userdata.id = userID
		make_new_login_key(userdata)
	end

	database:del(codeID)
else
	actiontitle = "Invalid code"
	message = "<div class='alert alert-error'>Sorry, but your code is invalid or expired</div>"
end

printTemplateAndClose("message", {MAINTITLE = actiontitle, MESSAGE = message})
