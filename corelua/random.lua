local randomstream = io.open("/dev/urandom", "r")
function random(min, max)
	local a,b,c,d = randomstream:read(4):byte(1,4)
	a = bit.lshift(a, 24) + bit.lshift(b, 16) + bit.lshift(c, 8) + d
	if not max and not min then
		return (a / 4294967296.0) + 0.5
	else
		a = a + 2147483648
		if not max then --Means min is actually max
			return a % (min + 1)
		else
			return (a % ((max - min) + 1)) + min
		end
	end
end

local chars = {
	"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
	"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
	"0","1","2","3","4","5","6","7","8","9"
}
local charcount = #chars
function randstr(len)
	local ret = {}
	for i=1,len do
		table.insert(ret, chars[random(charcount)])
	end
	return table.concat(ret)
end
