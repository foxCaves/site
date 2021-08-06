register_route("/api/v1/files/{id}", "PATCH", make_route_opts(), function()
    local database = get_ctx_database()

    local file = file_get_public(ngx.ctx.route_vars.id, ngx.ctx.user.id)
    if not file then
        ngx.status = 404
        return
    end

    local newname = ngx.unescape_uri(ngx.var.arg_name)

    if newname:sub((newname:len() + 1) - file.extension:len()) ~= file.extension then
        api_error("Extension mismatch")
        return
    end

    file.name = newname

    database:query_safe('UPDATE files SET name = %s WHERE id = %s', newname, file.id)

    file_push_action('refresh', {
        id = file.id,
        name = newname,
    })

    ngx.print(cjson.encode(file))
end)
