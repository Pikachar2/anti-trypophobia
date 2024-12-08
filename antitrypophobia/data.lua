--[[
base_dir = "__base__/graphics/entity/"
mod_dir = "__antitrypophobia__/"
objects = {"biter-spawner","spitter-spawner","biter-spawner-corpse","spitter-spawner-corpse"}

--settings.get_player_settings(player)["Anti_Trypophobia_Enabled"].value

--if settings.startup["Anti_Trypophobia_Enabled"].value or nil then
log ('BEFORE Trypo ------------------')
	for key, i in ipairs(objects) do
		if key == 1 or key == 2 then
			anim = data.raw["unit-spawner"][i].animations
		elseif key == 3 or key == 4 then
			anim = data.raw["corpse"][i].animation
		end
		
		for j=1,4 do
			for k = 1, #anim[j].layers do
				anim[j].layers[k].filename = anim[j].layers[k].filename:gsub(base_dir,mod_dir)
				anim[j].layers[k].hr_version.filename = anim[j].layers[k].hr_version.filename:gsub(base_dir,mod_dir)
			end
		end
	end
log ('AFTER Trypo ------------------')
--end
--]]
