local function makeTableRecurse(var, done)
	local t = type(var)
	if(t == "table") then
		if(not done) then
			done = {}
		end
		if(not done[var]) then
			done[var] = true
			local ret = {"<table><thead><tr><th>Name</th><th>Type</th><th>Value</th></tr></thead><tbody>"}
			for k, v in next, var do
				table.insert(ret, "<tr><td>"..tostring(k).."</td><td>"..type(v).."</td><td>")
				table.insert(ret, makeTableRecurse(v, done))
				table.insert(ret, "</td></tr>")
			end
			table.insert(ret, "</tbody></table>")
			return table.concat(ret, "")
		end
		
		return "DONE"
	elseif(t == "function") then
		return escape_html(tostring(var))
	else
		return escape_html(tostring(var):sub(1, 1024))
	end
end

local function getFunctionCode(info)
	local curr = info.currentline
	local startline = info.linedefined--function start
	local endline = info.lastlinedefined--function end
	local minline = math.max(curr - 5, 1)--start of capture
	local maxline = curr + 5--end of capture

	if startline and minline < startline then
		minline = startline
	end
	if endline and maxline > endline then
		maxline = endline
	end
	
	if endline ~= -1 then
		local out = {"<h3><a href='#'>Code</a></h3><div><pre class='prettyprint lang-lua'><ol class='linenums'>"}
		local source = info.short_src
		if source:sub(1, 9) == '[string "' then
			source = source:sub(10, -3)
		end
		local fh = io.open(source, "r")
		if fh then
			local funcStart
			local iter = fh:lines()
			for i = 1, minline-1 do
				if(i == startline) then
					funcStart = iter()
				else
					iter()
				end
			end
			if(minline ~= startline) then
				table.insert(out, "<li class=\"L0\" value=\""..startline.."\">")
				table.insert(out, funcStart)
				table.insert(out, "<span class='nocode'>\n...</span></li>")
			end
			for i = minline, maxline do
				table.insert(out, "<li class=\"L0\" value=\""..i.."\">")
				if(curr == i) then
					table.insert(out, "<span class=\"errorline\">"..escape_html(iter()).."</span></li>")
				else
					table.insert(out, escape_html(iter()))
				end
				if i < maxline then
					table.insert(out, "</li>")
				end
			end
			if(maxline ~= endline) then
				local funcEnd
				for i = maxline + 1, endline do
					funcStart = iter()
					if funcStart then
						funcEnd = funcStart
					else
						break
					end
				end
				table.insert(out, "<span class='nocode'>\n...</span></li><li class=\"L0\" value=\""..endline.."\">"..funcEnd.."</li>")
			else
				table.insert(out, "</li>")
			end
			fh:close()
		else
			return "Failed to read source"
		end
		table.insert(out, "</ol></pre></div>")
		return table.concat(out, "")
	end
	return ""
end

local function getLocals(level)
	if(debug.getlocal(level+1, 1)) then
		local out = {"<h3><a href='#'>Locals</a></h3><div>"}
		local tbl = {}
		for i = 1, 100 do
			local k, v = debug.getlocal(level+1, i)
			if(not k) then
				break
			end
			tbl[k] = v
		end
		table.insert(out, makeTableRecurse(tbl))
		table.insert(out, "</div>")
		return table.concat(out, "")
	end
	return ""
end

local function getUpValues(func)
	if(func and debug.getupvalue(func, 1)) then
		local out = {"<h3><a href='#'>UpValues</a></h3><div>"}
		local tbl = {}
		for i = 1, 100 do
			local k, v = debug.getupvalue(func, i)
			if(not k) then
				break
			end
			tbl[k] = v
		end
		table.insert(out, makeTableRecurse(tbl))
		table.insert(out, "</div>")
		return table.concat(out, "")
	end
	return ""
end

local function debug_trace(err)
	local out = {
		"<html><head>\
		<script type=\"text/javascript\" src=\"http://cdnjs.cloudflare.com/ajax/libs/jquery/1.8.3/jquery.min.js\"></script>\
		<script type=\"text/javascript\" src=\"http://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.9.1/jquery-ui.min.js\"></script>\
		<script src=\"http://cdnjs.cloudflare.com/ajax/libs/prettify/188.0.0/prettify.js\" type=\"text/javascript\"></script>\
		<script src=\"http://cdnjs.cloudflare.com/ajax/libs/prettify/188.0.0/lang-lua.js\" type=\"text/javascript\"></script>\
		<script type=\"text/javascript\" src=\"http://_static.staging.foxcav.es/errorpage/error.js\"></script>\
		<link rel=\"stylesheet\" type=\"text/css\" href=\"http://ajax.googleapis.com/ajax/libs/jqueryui/1.9.1/themes/base/jquery-ui.css\" />\
		<link rel=\"stylesheet\" type=\"text/css\" href=\"http://_static.staging.foxcav.es/errorpage/error.css\" />\
		<link rel=\"stylesheet\" type=\"text/css\" href=\"http://_static.staging.foxcav.es/css/prettify.css\" />\
		</head><body><h1 class=\"ui-widget\">Original Error:",
		err,
		"</h1><div class='accordion'><h3 class='autoclick'><a href='#'>UserInfo</a></h3><div>",
		string.format(
			"<table><tr><th>UserID</th><td>%s</td></tr><tr><th>IP</th><td>%s</td></tr><tr><th>URL</th><td>%s</td></tr><tbody>",
			ngx.ctx.user and ngx.ctx.user.id or "N/A",
			ngx.var.remote_addr,
			ngx.var.request_uri
		),
		"</tbody></table></div>"
	}
	local cur = nil
	for level = 2, 100 do
		cur = debug.getinfo(level)
		
		if not cur then break end
		
		local src_file = cur.short_src
		if src_file:sub(1, 9) == '[string "' then
			src_file = src_file:sub(10, -3)
		end
		
		if level <= 2 then
			table.insert(out, "<h3 class='autoclick'><a href='#'>Level "..tostring(level).."</a></h3><div><div class='accordion'>")
		else
			table.insert(out, "<h3><a href='#'>Level "..tostring(level).."</a></h3><div><div class='accordion'>")
		end
		table.insert(out, "<h3 class='autoclick'><a href='#'>Base</a></h3><div><ul><li>Where: "..src_file.."</li>")
		if(cur.currentline ~= -1) then
			table.insert(out, "<li>Line: "..cur.currentline.."</li>")
		end
		table.insert(out, "<li>What: "..(cur.name and "In function '"..cur.name.."'" or "In main chunk").."</li></ul></div>")

		table.insert(out, getLocals(level))
		table.insert(out, getUpValues(cur.func))
		table.insert(out, getFunctionCode(cur))
		
		table.insert(out, "</div></div>")
	end
	
	table.insert(out, "</body></html>")
	return table.concat(out, "")
end

local isok, err = xpcall(dofile, debug_trace, ngx.var.run_lua_file)

local function buildMultipart(name, content, boundry)
	local str
	if(name) then
		str = "Content-Type: application/octet-stream; name=\""..name.."\"\r\nContent-Transfer-Encoding: base64\r\n\r\n"..ngx.encode_base64(content)
	else
		str = "Content-Type: text/html\r\nContent-Transfer-Encoding: base64\r\n\r\n"..ngx.encode_base64(content)
	end
	return str.."\r\n--"..boundry.."\r\n"; 
end

local function sendAttachmentMail(attachment)
	local boundry = "b"..randstr(16)

	local mp = buildMultipart(nil, "See attachment", boundry)
	mp = mp .. buildMultipart("error.html", attachment, boundry)
	
	mail(
		"development@foxcav.es",
		"[foxCaves] Error report",
		"",
		"noreply@foxcav.es",
		"foxCaves",
		"MIME-Version: 1.0\r\nContent-Type: multipart/mixed; boundary = "..boundry.."\r\n\r\nThis is a MIME encoded message.\r\n\r\n--"..boundry.."\r\n"..mp
	)
end

if not isok then
	if IS_DEVELOPMENT then
		ngx.print(err)
		return ngx.eof()
	else
		sendAttachmentMail(err)
		return ngx.exec("/error/500")
	end
end