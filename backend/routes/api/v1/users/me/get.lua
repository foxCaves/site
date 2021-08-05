-- ROUTE:GET:/api/v1/users/self
dofile_global()
dofile("scripts/api_login.lua")
if not ngx.ctx.user then return end

local user = ngx.ctx.user
user.password = nil
user.loginkey = nil
user.sessionid = nil
user.salt = nil
ngx.print(cjson.encode(user))
