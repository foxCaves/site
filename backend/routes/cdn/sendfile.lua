local utils = require("foxcaves.utils")
local file_model = require("foxcaves.models.file")
local main_url = require("foxcaves.config").urls.main
local ngx = ngx

R.register_route("/fcv-cdn/sendfile/f/{file}", "GET", R.make_route_opts_anon(), function(route_vars)
    local id = file_model.extract_name_and_extension(route_vars.file)

    local file = file_model.get_by_id(id)
    if not file then
        return utils.api_error("File not found", 404)
    end

    local disposition_type
    if ngx.var.arg_raw then
        disposition_type = "inline"
    elseif ngx.var.arg_dl then
        disposition_type = "attachment"
    end

    if not disposition_type then
        ngx.status = 302
        ngx.redirect(main_url .. "/view/" .. file.id)
        return
    end

    ngx.header["Content-Disposition"] = disposition_type .. "; filename=\"" .. file.name .. "\""
    ngx.header["Content-Type"] = file.mimetype
    ngx.req.set_uri("/fcv-rawget/" .. file.id .. "/file", true)
end)

R.register_route("/fcv-cdn/sendfile/t/{file}", "GET", R.make_route_opts_anon(), function(route_vars)
    local id = file_model.extract_name_and_extension(route_vars.file)

    local file = file_model.get_by_id(id)
    if not file then
        return utils.api_error("File not found", 404)
    end

    if (not file.thumbnail_mimetype) or file.thumbnail_mimetype == "" then
        return utils.api_error("Thumbnail for file not found", 404)
    end

    ngx.header["Content-Type"] = file.thumbnail_mimetype
    ngx.req.set_uri("/fcv-rawget/" .. file.id .. "/thumb", true)
end)
