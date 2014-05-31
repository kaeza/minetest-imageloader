
imageloader = { }

local types = { }

local bmp_meta = {
	__index = bmp_methods,
}

--[[
typedef = {
	description = "FOO File",
	check = func(file), --> bool
	load = func(file), --> table or (nil, errormsg)
}
]]

function imageloader.register_type(def)

	types[#types + 1] = def

end

local function find_loader(file)

	for _,def in ipairs(types) do

		file:seek("set", 0)
		local r = def.check(file)
		file:seek("set", 0)

		if r then
			return def
		end

	end

	return nil, "imageloader: unknown file type"

end

function imageloader.load(filename)

	local f, e = io.open(filename)
	if not f then return nil, "imageloader: "..e end

	local def, e = find_loader(f)
	if not def then return nil, e end

	local r, e = def.load(f)

	f:close()

	if r then
		r = setmetatable(r, bmp_meta)
	end

	return r, e

end

function imageloader.type(filename)

	local f, e = io.open(filename)
	if not f then return nil, "imageloader: "..e end

	local def, e = find_loader(f)
	if not def then return nil, e end

	return def.description

end

function imageloader.to_schematic(bmp, pal)
	local data = { }
	local datai = 1
	for z = 1, bmp.h do
		for x = 1, bmp.w do
			local c = bmp.pixels[z][bmp.w + 1 - x]
			local i = palette.bestfit_color(pal, c)
			if (i == 1) and ((c.r ~= 255) or (c.g ~= 0) or (c.r ~= 255)) then
				print("WARNING: wrong color taken as transparency:"
					..(("at (%d,%d): [R=%d,G=%d,B=%d]"):format(x, z, c.r, c.g, c.b))
				)
			end
			local node = pal[i].node
			data[datai] = { name=node }
			datai = datai + 1
		end
	end
	return {
		size = { x=bmp.w, y=1, z=bmp.h },
		data = data,
	}
end

minetest.register_chatcommand("loadimage", {
	description = "Load an image file into the world at current position",
	params = "<filename>",
	func = function(name, param)
		param = param:trim()
		if param == "" then
			minetest.chat_send_player(name, "[imageloader] Usage: /loadimage <filename>")
			return
		end
		minetest.chat_send_player(name, "[imageloader] Loading image...")
		local bmp, e = imageloader.load(minetest.get_modpath("imageloader").."/images/"..param)
		if not bmp then
			minetest.chat_send_player(name, "[imageloader] Failed to load image: "..(e or "unknown error"))
			return
		end
		print(("Image loaded: size: %dx%d"):format(bmp.w, bmp.h))
		minetest.chat_send_player(name, "[imageloader] Creating schematic...")
		local schem = imageloader.to_schematic(bmp, palette.wool_palette)
		print(("Schematic created: size: %dx%dx%d"):format(schem.size.x, schem.size.y, schem.size.z))
		minetest.chat_send_player(name, "[imageloader] Placing schematic...")
		local pos = minetest.get_player_by_name(name):getpos()
		minetest.place_schematic(pos, schem, 0)
		minetest.chat_send_player(name, "[imageloader] DONE!")
	end,
})
