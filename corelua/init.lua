lfs = require("lfs")
socket = require("socket")

function escape_html(str)
	if (not str) or type(str) ~= "string" then
		return str
	end
	str = str:gsub("[&<>]", {
		["&"] = "&amp;",
		["<"] = "&lt;",
		[">"] = "&gt;",
	})
	return str
end

local setfenv = setfenv
local getfenv = getfenv
local filecache = {}
function dofile(file)
	local cache_key
	if file:sub(1) == "/" then
		cache_key = file
	else
		cache_key = lfs.currentdir().."/"..file
	end
	local code = filecache[cache_key]
	if not code then
		local fh = io.open(file, "r")
		code = fh:read("*all")
		fh:close()
		local err
		code, err = load("return function() "..code.."\nend", file)
		if err then error(err) end
		filecache[cache_key] = code
	end
	return setfenv(code(), getfenv())()
end

loadfile("/var/www/foxcaves/corelua/mail.lua")()
loadfile("/var/www/foxcaves/corelua/random.lua")()
loadfile("/var/www/foxcaves/corelua/template.lua")()
