local database = require("foxcaves.database")
local events = require("foxcaves.events")
local random = require("foxcaves.random")
local url_config = require("foxcaves.config").urls

local setmetatable = setmetatable
local next = next

local link_mt = {}
local link_model = {}

require("foxcaves.module_helper").setmodenv()

local function makelinkmt(link)
    link.not_in_db = nil
    setmetatable(link, link_mt)
    link:compute_virtuals()
    return link
end

local link_select = 'id, "user", url, ' .. database.TIME_COLUMNS

function link_model.get_by_user(user)
    if user.id then
        user = user.id
    end

    local links = database.get_shared():query('SELECT ' .. link_select .. ' FROM links WHERE "user" = %s', user)
    for k,v in next, links do
        links[k] = makelinkmt(v)
    end
    return links
end

function link_model.get_by_id(id)
	if not id then
		return nil
	end

	local link = database.get_shared():query_single('SELECT ' .. link_select .. ' FROM links WHERE id = %s', id)

	if not link then
		return nil
	end

	return makelinkmt(link)
end

function link_model.new()
    local link = {
        not_in_db = true,
        id = random.string(10),
    }
    setmetatable(link, link_mt)
    return link
end

function link_mt:compute_virtuals()
    self.short_url = url_config.short .. "/g" .. self.id
end

function link_mt:delete()
    database.get_shared():query('DELETE FROM links WHERE id = %s', self.id)

	events.push_raw({
        action = 'link:delete',
        link = self
    }, self.user)
end

function link_mt:set_owner(user)
    self.user = user.id or user
end

function link_mt:set_url(url)
    self.url = url
    self:compute_virtuals()
    return true
end

function link_mt:save()
    local res, primary_push_action
    if self.not_in_db then
        res = database.get_shared():query_single(
            'INSERT INTO links (id, "user", url) VALUES (%s, %s, %s) RETURNING ' .. database.TIME_COLUMNS,
            self.id, self.user, self.url
        )
        primary_push_action = 'create'
        self.not_in_db = nil
    else
        res = database.get_shared():query_single(
            'UPDATE links \
                SET "user" = %s, url = %s, \
                updated_at = (now() at time zone \'utc\') \
                WHERE id = %s \
                RETURNING ' .. database.TIME_COLUMNS,
            self.user, self.url, self.id
        )
        primary_push_action = 'refresh'
    end
    self.created_at = res.created_at
    self.updated_at = res.updated_at

	events.push_raw({
		action = "link:" .. primary_push_action,
		link = self,
	}, self.user)
end

link_mt.__index = link_mt

return link_model
