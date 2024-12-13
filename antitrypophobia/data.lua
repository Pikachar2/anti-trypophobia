use_phobia_mode = true
--local is_space-age_enabled = script.active_mods["space%-age"] 
local is_space_age_enabled = mods["space-age"]

if use_phobia_mode then
	base_dir = "__base__/graphics/entity/"
	mod_dir = "__antitrypophobia__/"
	objects = {"biter-spawner","spitter-spawner","biter-spawner-corpse","spitter-spawner-corpse"}

--	log ('antitrypophobia --- data.raw.corpse: ' .. serpent.block(data.raw["corpse"]["biter-spawner-corpse"]))
	for key, i in ipairs(objects) do
		if key == 1 or key == 2 then
			anim = data.raw["unit-spawner"][i].graphics_set.animations
		elseif key == 3 or key == 4 then
			anim = data.raw["corpse"][i].animation
		end
--	log ('antitrypophobia --- anim: ' .. serpent.block(anim))
--	log ('antitrypophobia --- i: ' .. serpent.block(i))
	--log ('antitrypophobia --- key: ' .. serpent.block(key))
	--log ('antitrypophobia --- data.raw.unit-spawner[biter-spawner]: ' .. serpent.block(data.raw["unit-spawner"][i]))
--	log ('antitrypophobia --- data.raw.corpse: ' .. serpent.block(data.raw["corpse"]))
		
		for j=1,4 do
			for k = 1, #anim[j].layers do
				anim[j].layers[k].filename = anim[j].layers[k].filename:gsub(base_dir,mod_dir)
			end
		end
	end

	if is_space_age_enabled then
--		log ('antitrypophobia --- Space Age is enabled!!!!!')
	-- Space Age replacements
		space_dir = "__space%-age__/graphics/entity/"
		objects = {"biolab","captive-spawner"}
	--log ('antitrypophobia --- data.raw.lab: ' .. serpent.block(data.raw["lab"]))

		on_anim = data.raw["lab"]["biolab"].on_animation
		off_anim = data.raw["lab"]["biolab"].off_animation

		for k = 1, #on_anim.layers do
			on_anim.layers[k].filename = on_anim.layers[k].filename:gsub(space_dir,mod_dir)
		end
		for k = 1, #off_anim.layers do
			off_anim.layers[k].filename = off_anim.layers[k].filename:gsub(space_dir,mod_dir)
		end

		captive_anim = data.raw["assembling-machine"]["captive-biter-spawner"].graphics_set.animation
	--log ('antitrypophobia --- data.raw.captive-biter-spawner: ' .. serpent.block(captive_anim))

		for k = 1, #captive_anim.layers do
			captive_anim.layers[k].filename = captive_anim.layers[k].filename:gsub(space_dir,mod_dir)
		end
	end

end
