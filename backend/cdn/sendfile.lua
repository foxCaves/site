ctx_init()

local function send_file(disposition_type)
	local file = file_get_public(ngx.var.fileid)

	if (not file) or file.extension:sub(2):lower() ~= ngx.var.extension:lower() then
		ngx.status = 404
		ngx.print("File not found")
		return
	end

	ngx.header["Content-Dispotition"] = disposition_type .. "; filename=" .. file.name

	__on_shutdown()
	ngx.req.set_uri("/rawget/" .. file.id .. "/file" .. file.extension, true)
end

if ngx.var.action == "f" then
	send_file("inline")
else
	ngx.header["Content-Type"] = "application/octet-stream"
	send_file("attachment")
end
