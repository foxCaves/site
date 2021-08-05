-- ROUTE:GET:/api/v1/files/{id}
dofile_global()
dofile("scripts/api_login.lua")
if not ngx.ctx.user then return end

dofile("scripts/fileapi.lua")
local file = file_get(ngx.ctx.route_vars.id)
if not file then
    ngx.status = 404
    return
end

ngx.print(cjson.encode(file))
