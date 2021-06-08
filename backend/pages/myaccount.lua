dofile(ngx.var.main_root .. "/scripts/global.lua")
if not ngx.ctx.user then return ngx.redirect("/login") end

local database = ngx.ctx.database

local args = ngx.req.get_uri_args()

if(args and args.setstyle) then
	local style = args.setstyle
	if(style == "purple_fox" or style == "red_fox" or style == "arctic_fox") then
		database:hset(database.KEYS.USERS .. ngx.ctx.user.id, "style", style)
		if(args.js) then
			ngx.print("success")
			return ngx.eof()
		end
	end
	return ngx.redirect("/myfiles")
end

local message = ""

local function deleteUser()
	local files = database:zrevrange(database.KEYS.USER_FILES .. ngx.ctx.user.id, 0, -1)
	dofile("scripts/fileapi.lua")
	for k, fileId in next, files do
		--file_delete(fileId, ngx.ctx.user.id)
	end
	error("fuck!")
	--database:hmdeleteset(database.KEYS.USERS .. ngx.ctx.user.id)--is this even correct?
end

ngx.req.read_body()
args = ngx.ctx.get_post_args()
if args and args.old_password then
	if args.delete_account then
		deleteUser()
	elseif args.kill_sessions then
		message = "<div class='alert alert-success'>All other sessions have been killed</div>"
		ngx.ctx.make_new_login_key()
	elseif ngx.hmac_sha1(ngx.ctx.user.username, args.old_password) ~= ngx.ctx.user.password then
		message = "<div class='alert alert-error'>Current password is wrong</div>"
	elseif args.change_password then
		if (not args.password) or args.password == "" then
			message = "<div class='alert alert-error'>New password may not be empty</div>"
		elseif args.password ~= args.password_confirm then
			message = "<div class='alert alert-error'>Password and confirmation do not match</div>"
		else
			local newpw = ngx.hmac_sha1(ngx.ctx.user.username, args.password)
			database:hset(database.KEYS.USERS .. ngx.ctx.user.id, "password", newpw)
			message = "<div class='alert alert-success'>Password changed</div>"
			ngx.ctx.user.password = newpw
			ngx.ctx.make_new_login_key()
		end
	elseif args.change_email then
		if args.email:lower() == ngx.ctx.user.email:lower() then
			message = "<div class='alert alert-error'>This is the same E-Mail we already have on record for you!</div>"
		else
			local emailcheck = ngx.ctx.check_email(args.email)
			if emailcheck == ngx.ctx.EMAIL_INVALID then
				message = "<div class='alert alert-error'>E-Mail invalid</div>"
			elseif emailcheck == ngx.ctx.EMAIL_TAKEN then
				message = "<div class='alert alert-error'>E-Mail already taken</div>"
			else
				database:sadd(database.KEYS.EMAILS, args.email:lower())
				database:srem(database.KEYS.EMAILS, ngx.ctx.user.email:lower())
				database:hset(database.KEYS.USERS .. ngx.ctx.user.id, "email", args.email)
				message = "<div class='alert alert-success'>E-Mail changed</div>"
				ngx.ctx.user.email = args.email
			end
		end
	end
end

printTemplateAndClose("myaccount", {MAINTITLE = "My account", MESSAGE = message})