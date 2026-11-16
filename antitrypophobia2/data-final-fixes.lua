local base_dir = "__base__/graphics/entity/"
local space_dir = "__space%-age__/graphics/entity/"
local mod_dir = "__antitrypophobia2__/"

local function replacePathsInLayers(anim, from_dir)
	if not anim or not anim.layers then return end
	for k = 1, #anim.layers do
		if anim.layers[k].filename then
			anim.layers[k].filename = anim.layers[k].filename:gsub(from_dir, mod_dir)
		end
	end
end

local spawner_objects = {
	{ name = "biter-spawner", type = "unit-spawner" },
	{ name = "spitter-spawner", type = "unit-spawner" },
	{ name = "biter-spawner-corpse", type = "corpse" },
	{ name = "spitter-spawner-corpse", type = "corpse" }
}

for _, obj in ipairs(spawner_objects) do
	local proto = data.raw[obj.type][obj.name]
	if proto then
		local anim_list = (obj.type == "unit-spawner") and proto.graphics_set.animations or proto.animation
		for v = 1, #anim_list do
			-- 1. Save a copy of the original vanilla animation for players who opt out
			local vanilla_copy = table.deepcopy(anim_list[v])
			vanilla_copy.type = "animation"
			vanilla_copy.name = "antitrypophobia-vanilla-" .. obj.name .. "-" .. v
			data:extend({ vanilla_copy })

			-- 2. Replace the prototype's animation with the mod's safe sprites by default
			replacePathsInLayers(anim_list[v], base_dir)
		end
	end
end

if mods["space-age"] then
	local biolab = data.raw["lab"]["biolab"]
	if biolab then
		if biolab.on_animation then
			local vanilla_copy = table.deepcopy(biolab.on_animation)
			vanilla_copy.type = "animation"
			vanilla_copy.name = "antitrypophobia-vanilla-biolab-1"
			data:extend({ vanilla_copy })

			replacePathsInLayers(biolab.on_animation, space_dir)
		end
		if biolab.off_animation then
			replacePathsInLayers(biolab.off_animation, space_dir)
		end
	end

	local captive = data.raw["assembling-machine"]["captive-biter-spawner"]
	if captive and captive.graphics_set and captive.graphics_set.animation then
		local vanilla_copy = table.deepcopy(captive.graphics_set.animation)
		vanilla_copy.type = "animation"
		vanilla_copy.name = "antitrypophobia-vanilla-captive-biter-spawner-1"
		data:extend({ vanilla_copy })

		replacePathsInLayers(captive.graphics_set.animation, space_dir)
	end
end

-- Comment out when done
-- TEMPORARY FOR TESTING: Keep only menu simulations that mention biter/spitter/spawner/biolab
local sims = data.raw["utility-constants"]["default"].main_menu_simulations
if sims then
	local kept = 0
	for name, sim in pairs(sims) do
		local haystack = string.lower(name .. " " .. (sim.init or ""))
		local has_nest = string.find(haystack, "biter", 1, true)
			or string.find(haystack, "spitter", 1, true)
			or string.find(haystack, "spawner", 1, true)
			or string.find(haystack, "biolab", 1, true)

		if has_nest then
			kept = kept + 1
			log("antitrypophobia2 keeping menu sim: " .. name)
		else
			sims[name] = nil
		end
	end
	log("antitrypophobia2 total menu sims kept: " .. kept)
end
