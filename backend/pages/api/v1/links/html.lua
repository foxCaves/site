-- ROUTE:GET:/api/v1/links/{id}/html
dofile(ngx.var.main_root .. "/scripts/global.lua")
dofile("scripts/api_login.lua")
if not ngx.ctx.user then return end

dofile("scripts/linkapi.lua")

local linkid = ngx.ctx.route_vars.id
local link = link_get(linkid)

if not link then
	ngx.status = 404
	ngx.print("Link not found")
	return ngx.eof()
end

printTemplateAndClose("linkhtml", {link = link})