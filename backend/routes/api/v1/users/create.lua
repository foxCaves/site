register_route("/api/v1/users", "POST", make_route_opts_anon(), function()
    local database = get_ctx_database()
    local args = get_post_args()

    local username = args.username or ""
    local email = args.email or ""
    local password = args.password or ""

    if args.agreetos ~= "yes" then
        return api_error("agreetos required")
    end
    if username == "" then
        return api_error("username required")
    end
    if email == "" then
        return api_error("email required")
    end
    if password == "" then
        return api_error("password required")
    end

    local usernamecheck = check_username(args.username)
    if usernamecheck == VALIDATION_STATE_INVALID then
        return api_error("username invalid")
    elseif usernamecheck == VALIDATION_STATE_TAKEN then
        return api_error("username taken")
    end

    local emailcheck = check_email(email)
    if emailcheck == VALIDATION_STATE_INVALID then
        return api_error("email invalid")
    elseif emailcheck == VALIDATION_STATE_TAKEN then
        return api_error("email taken")
    end

    local id = uuid.generate_random()

    local res = database:query_safe('INSERT INTO users (id, username, email, password) VALUES (%s, %s, %s, %s) RETURNING id, username, email', id, username, email, hash_password(password))
    local user = res[1]

    make_new_login_key(user)
    make_new_api_key(user)

    user_require_email_confirmation(user)
end)
