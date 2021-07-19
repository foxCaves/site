-- ROUTE:GET:/api/v1/files
dofile(ngx.var.main_root .. "/scripts/global.lua")
dofile("scripts/api_login.lua")
if not ngx.ctx.user then return end

local database = ngx.ctx.database
local files = database:zrevrange(database.KEYS.USER_FILES .. ngx.ctx.user.id, 0, -1)

ngx.header["Content-Type"] = "application/json"
dofile("scripts/fileapi.lua")
local results = {}
for _,fileid in next, files do
	table.insert(results, file_get(fileid))
end
ngx.print(cjson.encode(results))
ngx.eof()