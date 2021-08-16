CREATE USER foxcaves;
CREATE DATABASE foxcaves;

GRANT ALL PRIVILEGES ON DATABASE foxcaves TO foxcaves;

\c foxcaves foxcaves;

CREATE TABLE users (
    id UUID PRIMARY KEY,
    username VARCHAR(255),
    email VARCHAR(255),
    password VARCHAR(255),
    active INT NOT NULL DEFAULT 0,
    bonusbytes BIGINT NOT NULL DEFAULT 0,
    loginkey VARCHAR(255),
    apikey VARCHAR(255),
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()),
    updated_at timestamp without time zone DEFAULT timezone('utc'::text, now())
);
CREATE UNIQUE INDEX ON users (lower(username));
CREATE UNIQUE INDEX ON users (lower(email));

CREATE TABLE files (
    id VARCHAR(32) PRIMARY KEY,
    "user" UUID REFERENCES users (id),
    name VARCHAR(255),
    extension VARCHAR(255),
    type INT,
    size BIGINT,
    thumbnail VARCHAR(255),
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()),
    updated_at timestamp without time zone DEFAULT timezone('utc'::text, now())
);
CREATE INDEX ON files ("user");

CREATE TABLE links (
    id VARCHAR(32) PRIMARY KEY,
    "user" UUID REFERENCES users (id),
    url VARCHAR(4096),
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()),
    updated_at timestamp without time zone DEFAULT timezone('utc'::text, now())
);
CREATE INDEX ON links ("user");
