function send_file(disposition_type)
	local fileid = ngx.var.fileid
	local file = file_get(fileid)
	
	if (not file) or file.extension:sub(2):lower() ~= ngx.var.extension:lower() then
		ngx.status = 404
		ngx.print("File not found")
		return ngx.eof()
	end
	
	ngx.header["Content-Dispotition"] = disposition_type .. "; filename=" .. file.name .. file.extension
	
	ngx.req.set_uri("/rawget/" .. fileid .. "/file" .. file.extension)
end