local lfs = require("lfs")
local utils = require("foxcaves.utils")
local expiry_utils = require("foxcaves.expiry_utils")
local file_model = require("foxcaves.models.file")
local ngx = ngx
local io = io

R.register_route("/api/v1/files", "POST", R.make_route_opts(), function()
    if not ngx.ctx.user:can_perform_write() then
        return utils.api_error("You cannot create files", 403)
    end

    local name = ngx.var.arg_name

    if not name then
        return utils.api_error("No name")
    end

    local user = ngx.ctx.user

    name = ngx.unescape_uri(name)

    local file = file_model.new()
    file:set_owner(user)
    if not file:set_name(name) or not file:compute_mimetype() then
        return utils.api_error("Invalid name")
    end

    expiry_utils.parse_expiry(ngx.var, file, "arg_")

    ngx.req.read_body()
    local filetmp = ngx.req.get_body_file()
    local filedata = ngx.req.get_body_data()
    if (not filetmp) and (not filedata) then
        return utils.api_error("No body")
    end

    local filesize = filetmp and lfs.attributes(filetmp, "size") or filedata:len()
    if (not filesize) or filesize <= 0 then
        return utils.api_error("Empty body")
    end

    if not user:has_free_storage_for(filesize) then
        return utils.api_error("Over quota", 402)
    end

    if not filetmp then
        filetmp =  file_model.paths.temp .. "file_" .. file.id .. ".tmp"
        local f = io.open(filetmp, "wb")
        f:write(filedata)
        f:close()
    end
    file:move_upload_data(filetmp)

    file:save()

    return file:get_private()
end, {
    description = "Uploads a file",
    authorization = {"active"},
    request = {
        query = {
            name = {
                description = "The name of the file",
                type = "string",
                required = true,
            },
            expires_at = {
                type = "string",
                description = "The expiry of the file",
                required = false,
            },
            expires_in = {
                type = "integer",
                description = "The expiry of the file in seconds from now",
                required = false,
            },
        },
        body = {
            type = "raw",
            description = "The file data",
            required = true,
        },
    },
    response = {
        body = {
            type = "file.private",
        },
    },
})
