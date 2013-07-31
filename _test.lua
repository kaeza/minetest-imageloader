
local function write_bytes(f, n, c, d)

	local s = (d < 0) and c or 1
	local e = (d < 0) and 1 or c

	local buf = ""

	for x = s, e, d do
		local ch = (n % 256)
		buf = buf..string.char(ch)
		n = (n - ch) / 256
	end

	print(buf)

end

s = (65 * 256) + 66
write_bytes(nil, s, 2, -1)
