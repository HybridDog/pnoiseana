local np = {
	offset = 0,
	scale = 1,
	spread = {x=25, y=25, z=25},
	seed = 9130,
	octaves = 3,
	persist = 0.5
}

minetest.register_on_generated(function(minp, maxp)
	local results = {}
	local s = 500
	for i = 0,s do
		results[i] = 0
	end

	local buf
	local sidelen = 80
	local perlin = minetest.get_perlin_map(np, {x=sidelen, y=sidelen})
	local mapsize = sidelen * sidelen
	local n = 30
	for x = -n,n do
		local map = perlin:get2dMap_flat({x = x * 80, y = minp.z}, buf)
		for i = 1,mapsize do
			local v = math.min(math.floor(math.abs(map[i])*s), s)
			results[v] = results[v] + 1
		end
	end

	-- ignore values > 1
	results[s] = 0

	local mv = 0
	for i = 0,s do
		results[i] = results[i] / (mapsize * 2 * n + 1)
		mv = math.max(mv, results[i])
	end
	for i = 0,s do
		results[i] = results[i] / mv
	end

	local file = io.open(minetest.get_modpath"pnoiseana".."/tmp.ppm", "w")
	assert(file, "not file")

	local ys = 300

	file:write("P3 " .. s+1 .." ".. ys .." 1 \n")

	for y = 1,ys do
		local yv = 1 - (y-1)/(ys-1)
		for x = 0,s do
			if yv < results[x] then
				file:write"0 0 0 "
			else
				file:write"1 1 1 "
			end
		end
		file:write"\n"
	end

	error()
end)
