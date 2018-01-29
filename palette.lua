
palette = { }

local PAL_SIZE = 256

local floor = math.floor

local col_diff

--[[ bestfit_init:
  |  Color matching is done with weighted squares, which are much faster
  |  if we pregenerate a little lookup table...
  ]]
local function bestfit_init()

	col_diff = { }

	for i = 0, 63 do
		local k = i * i;
		local t

		t = k * (59 * 59)
		col_diff[0  +i] = t
		col_diff[0  +128-i] = t

		t = k * (30 * 30)
		col_diff[128+i] = t
		col_diff[128+128-i] = t

		t = k * (11 * 11)
		col_diff[256+i] = t
		col_diff[256+128-i] = t
	end

end

--[[ bestfit_color:
  |  Searches a palette for the color closest to the requested R, G, B value.
  ]]
function palette.bestfit_color(pal, c)

	local r, g, b = floor(c.r / 4), floor(c.g / 4), floor(c.b / 4)

	local i, coldiff, lowest, bestfit

	assert((r >= 0) and (r <= 63))
	assert((g >= 0) and (g <= 63))
	assert((b >= 0) and (b <= 63))

	bestfit = 1
	lowest = math.huge

	-- only the transparent (pink) color can be mapped to index 0
	if (r == 63) and (g == 0) and (b == 63) then
		i = 1
	else
		i = 2
	end

	while i < PAL_SIZE do
		local cc = pal[i]
		if not cc then break end
		local rgb = { r=floor(cc.r / 4), g = floor(cc.g / 4), b = floor(cc.b / 4) }
		coldiff = col_diff[0 + ((rgb.g - g) % 0x80)]
		if coldiff < lowest then
			coldiff = coldiff + col_diff[128 + ((rgb.r - r) % 0x80)]
			if coldiff < lowest then
				coldiff = coldiff + col_diff[256 + ((rgb.b - b) % 0x80)]
				if coldiff < lowest then
					bestfit = i
					if coldiff == 0 then return bestfit end
					lowest = coldiff
				end
			end
		end
		i = i + 1
	end

	return bestfit

end

palette.wool_palette = {
	{ node="ignore", r=255, g=0, b=255 },
	{ node="wool:white", r=221, g=221, b=221},
	{ node="wool:grey", r=134, g=134, b=134},
	{ node="wool:dark_grey", r=61, g=61, b=61},
	{ node="wool:black", r=31, g=31, b=31},
	{ node="wool:red", r=171, g=18, b=18},
	{ node="wool:green", r=94, g=218, b=28},
	{ node="wool:dark_green", r=34, g=104, b=0},
	{ node="wool:blue", r=0, g=74, b=146},
	{ node="wool:violet", r=93, g=6, b=170},
	{ node="wool:magenta", r=202, g=3, b=113},
	{ node="wool:orange", r=214, g=84, b=22},
	{ node="wool:yellow", r=254, g=227, b=16},
	{ node="wool:pink", r=255, g=134, b=134},
	{ node="wool:brown", r=89, g=45, b=0},
	{ node="wool:cyan", r=0, g=133, b=141},
}

bestfit_init()
