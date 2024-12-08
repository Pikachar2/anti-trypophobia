base_dir = "__base__/graphics/entity/"
mod_dir = "__antitrypophobia__/"
objects = {"biter-spawner","spitter-spawner","biter-spawner-corpse","spitter-spawner-corpse"}

log ('antitrypophobia --- data.raw.corpse: ' .. serpent.block(data.raw["corpse"]["biter-spawner-corpse"]))
for key, i in ipairs(objects) do
	if key == 1 or key == 2 then
		anim = data.raw["unit-spawner"][i].graphics_set.animations
	elseif key == 3 or key == 4 then
		anim = data.raw["corpse"][i].animation
	end
log ('antitrypophobia --- anim: ' .. serpent.block(anim))
log ('antitrypophobia --- i: ' .. serpent.block(i))
--log ('antitrypophobia --- key: ' .. serpent.block(key))
--log ('antitrypophobia --- data.raw.unit-spawner[biter-spawner]: ' .. serpent.block(data.raw["unit-spawner"][i]))
log ('antitrypophobia --- data.raw.corpse: ' .. serpent.block(data.raw["corpse"]))
	
	for j=1,4 do
		for k = 1, #anim[j].layers do
			anim[j].layers[k].filename = anim[j].layers[k].filename:gsub(base_dir,mod_dir)
		end
	end
end