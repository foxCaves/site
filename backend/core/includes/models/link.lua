local LinkMT = {}
Link = {}

local function makelinkmt(link)
    link.not_in_db = nil
    setmetatable(link, LinkMT)
    link:ComputeVirtuals()
    return link
end

function Link.GetByUser(user)
    if user.id then
        user = user.id
    end

    local links = get_ctx_database():query_safe('SELECT * FROM links WHERE "user" = %s', user)
    for k,v in pairs(links) do
        links[k] = makelinkmt(v)
    end
    return links
end

function Link.GetByID(id)
	if not id then 
		return nil
	end

	local links = get_ctx_database():query_safe('SELECT * FROM links WHERE id = %s', id)
	links = links[1]

	if not links then
		return nil
	end

	return makelinkmt(links)
end

function Link.New()
    local link = {
        not_in_db = true,
        id = randstr(10),
        time = ngx.time(),
    }
    setmetatable(link, LinkMT)
    return link
end

function LinkMT:ComputeVirtuals()
    self.short_url = SHORT_URL .. "/g" .. self.id
end

function LinkMT:Delete()
    get_ctx_database():query_safe('DELETE FROM links WHERE id = %s', self.id)

	raw_push_action({
        action = 'link:delete',
        link = self
    }, self.user)
end

function LinkMT:SetOwner(user)
    self.user = user.id or user
end

function LinkMT:SetURL(url)
    self.url = url
    self:ComputeVirtuals()
    return true
end

function LinkMT:Save()
    local primary_push_action
    if self.not_in_db then
        get_ctx_database():query_safe('INSERT INTO links (id, "user", url, time) VALUES (%s, %s, %s, %s)', self.id, self.user, self.url, self.time)
        primary_push_action = 'create'
        self.not_in_db = nil
    else
        get_ctx_database():query_safe('UPDATE links SET "user" = %s, url = %s, time = %s WHERE id = %s', self.user, self.url, self.time, self.id)
        primary_push_action = 'refresh'
    end
	raw_push_action({
		action = "link:" .. primary_push_action,
		link = self,
	}, self.user)
end

LinkMT.__index = LinkMT
