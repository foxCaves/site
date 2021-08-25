return {
    redis = {
        host = "127.0.0.1",
        port = 6379,
    },
    postgres = {
        -- pgmoon options
    },
    email = {
        host = "localhost",
        port = 25,
        -- user = "user",
        -- password = "pass",
        -- ssl = true,
    },
    urls = {
        short = "http://short.foxcaves",
        main = "http://main.foxcaves",
    },
    sentry = {
        dsn = nil,
        dsn_frontend = nil,
    },
}
