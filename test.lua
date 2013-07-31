
minetest = { }
function minetest.get_modpath() return "." end

dofile("init.lua")

local function test_loader()

	local function error(e)
		print(e)
		os.exit(1)
	end

	local t, e = imageloader.type("test.bmp")
	print("Type: "..(t or "error: "..e))

	local bmp, e = imageloader.load("test.bmp")
	if not bmp then error(e) end

	print(("Size: %dx%d"):format(bmp.w, bmp.h))

	local pos = { x=160, y=120 }
	local c = bmp.pixels[pos.y][pos.x]

	print(("Pixel at (%d,%d): [R=%d,G=%d,B=%d,A=%d]"):format(pos.x, pos.y, c.r, c.g, c.b, c.a))

end

local function test_palette()

	local i = palette.bestfit_color(pal, {r=0,g=0,b=0})
	print("Best Fit: "..pal[i].node)

end

test_palette()
