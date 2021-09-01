local config = require("foxcaves.config").postgres
local consts = require("foxcaves.consts")
local pgmoon = require("pgmoon")
local lfs = require("lfs")

local function setup_super()
    local super_config = {
        user = "postgres",
        database = "postgres",
        host = config.host,
        port = config.port,
    }
    local db = pgmoon.new(super_config)
    local _, err = db:connect()
    if err then
        error(err)
    end

    local user_name = db:escape_identifier(config.user)
    local database_name = db:escape_identifier(config.database)

    db:query("CREATE USER " .. user_name .. ";")
    db:query("CREATE DATABASE " .. database_name .. ";")
    db:query("GRANT ALL PRIVILEGES ON DATABASE " .. database_name .. " TO " ..  user_name .. ";")

    db:disconnect()
end

local function process_migration_dir(db, ran_migrations, dir)
    for file in lfs.dir(dir) do
        if file:sub(1, 1) ~= "." then
            local absfile = dir .. "/" .. file
            local attributes = lfs.attributes(absfile)
            if attributes.mode == "file" then
                if not ran_migrations[file] then
                    print("Running: " .. file)
                    local fh = io.open(absfile, "r")
                    local data = fh:read("*a")
                    fh:close()
                    db:query_err(data)
                    ran_migrations[file] = true
                    db:query_err("INSERT INTO migrations (name) VALUES (" .. db:escape_literal(file) .. ");")
                end
            end
        end
    end
end
local function setup_db()
    local db = pgmoon.new(config)
    local _, err = db:connect()
    if err then
        error(err)
    end

    function db:query_err(query)
        local res, qerr = self:query(query)
        if not res then
            error(qerr)
        end
        return res
    end

    db:query_err("CREATE TABLE IF NOT EXISTS migrations (name VARCHAR(255) PRIMARY KEY);")

    local ran_migrations_arr = db:query_err("SELECT name FROM migrations;")
    local ran_migrations = {}
    for _, row in ipairs(ran_migrations_arr) do
        ran_migrations[row.name] = true
    end

    process_migration_dir(db, ran_migrations, consts.LUA_ROOT .. "/migrations")

    db:disconnect()
end


if config.use_super then
    print("Running super migrator...")
    setup_super()
    print("Super migrator done!")
end

print("Running migrator...")
setup_db()
print("Migrator done!")