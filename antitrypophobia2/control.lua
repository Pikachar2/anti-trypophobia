local CANDIDATE_ENTITIES = {
	["biter-spawner"] = { variations = 4, layer = "higher-object-above" },
	["spitter-spawner"] = { variations = 4, layer = "higher-object-above" },
	["biter-spawner-corpse"] = { variations = 4, layer = "corpse" },
	["spitter-spawner-corpse"] = { variations = 4, layer = "corpse" },
	["biolab"] = { variations = 1, layer = "higher-object-above" },
	["captive-biter-spawner"] = { variations = 1, layer = "higher-object-above" }
}

local TRACKED_ENTITIES = {}
local ENTITY_FILTER = {}
local ENTITY_NAMES = {}

local function initEntityLists()
	if #ENTITY_NAMES > 0 then return end
	for name, info in pairs(CANDIDATE_ENTITIES) do
		if prototypes.entity[name] then
			TRACKED_ENTITIES[name] = info
			table.insert(ENTITY_NAMES, name)
			table.insert(ENTITY_FILTER, { filter = "name", name = name })
		end
	end
end

-- Returns players who turned OFF anti-trypophobia visuals (and therefore want vanilla overlays)
local function getOptOutPlayers()
	local opt_out = {}
	for _, player in pairs(game.players) do
		if not settings.get_player_settings(player)["antitrypophobia-enabled"].value then
			table.insert(opt_out, player)
		end
	end
	return opt_out
end

local function attachVanillaOverlay(entity, opt_out_players)
	if not (entity and entity.valid) then return end
	local info = TRACKED_ENTITIES[entity.name]
	if not info then return end

	storage.overlays = storage.overlays or {}
	local reg_id = script.register_on_object_destroyed(entity)
	if storage.overlays[reg_id] then return end

	local variation = 1
	if info.variations > 1 then
		local hash = math.abs(math.floor(entity.position.x * 7 + entity.position.y * 13))
		variation = (hash % info.variations) + 1
	end

	local anim_name = "antitrypophobia-vanilla-" .. entity.name .. "-" .. variation
	local render_obj = rendering.draw_animation({
		animation = anim_name,
		target = entity,
		surface = entity.surface,
		render_layer = info.layer,
		players = opt_out_players,
		visible = (#opt_out_players > 0)
	})

	storage.overlays[reg_id] = render_obj
end

local function refreshAllPlayers()
	storage.overlays = storage.overlays or {}
	local opt_out_players = getOptOutPlayers()
	local any_opt_out = (#opt_out_players > 0)

	for reg_id, render_obj in pairs(storage.overlays) do
		if render_obj and render_obj.valid then
			render_obj.players = opt_out_players
			render_obj.visible = any_opt_out
		else
			storage.overlays[reg_id] = nil
		end
	end
end

local function scanSurface(surface)
	if not (surface and surface.valid) or #ENTITY_NAMES == 0 then return end
	local opt_out_players = getOptOutPlayers()
	local entities = surface.find_entities_filtered({ name = ENTITY_NAMES })
	for _, entity in ipairs(entities) do
		attachVanillaOverlay(entity, opt_out_players)
	end
end

local function fullRescan()
	initEntityLists()
	storage.overlays = {}
	rendering.clear("antitrypophobia2")
	for _, surface in pairs(game.surfaces) do
		scanSurface(surface)
	end
end

local function registerEvents()
	initEntityLists()

	script.on_event(defines.events.on_player_joined_game, refreshAllPlayers)
	script.on_event(defines.events.on_player_left_game, refreshAllPlayers)
	script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
		if event.setting == "antitrypophobia-enabled" then
			refreshAllPlayers()
		end
	end)

	script.on_event(defines.events.on_chunk_generated, function(event)
		if #ENTITY_NAMES == 0 then return end
		local opt_out_players = getOptOutPlayers()
		local entities = event.surface.find_entities_filtered({
			area = event.area,
			name = ENTITY_NAMES
		})
		for _, entity in ipairs(entities) do
			attachVanillaOverlay(entity, opt_out_players)
		end
	end)

	local function onEntityCreated(event)
		local entity = event.entity or event.created_entity or event.destination
		attachVanillaOverlay(entity, getOptOutPlayers())
	end

	script.on_event(defines.events.on_built_entity, onEntityCreated, ENTITY_FILTER)
	script.on_event(defines.events.on_robot_built_entity, onEntityCreated, ENTITY_FILTER)
	script.on_event(defines.events.on_biter_base_built, onEntityCreated)
	script.on_event(defines.events.script_raised_built, onEntityCreated, ENTITY_FILTER)
	script.on_event(defines.events.script_raised_revive, onEntityCreated, ENTITY_FILTER)
	script.on_event(defines.events.on_entity_cloned, onEntityCreated, ENTITY_FILTER)

	script.on_event(defines.events.on_entity_died, function(event)
		if event.entity and event.entity.valid then
			local corpse_names = {}
			if prototypes.entity["biter-spawner-corpse"] then table.insert(corpse_names, "biter-spawner-corpse") end
			if prototypes.entity["spitter-spawner-corpse"] then table.insert(corpse_names, "spitter-spawner-corpse") end
			if #corpse_names == 0 then return end

			local corpses = event.entity.surface.find_entities_filtered({
				position = event.entity.position,
				radius = 4,
				name = corpse_names
			})
			local opt_out_players = getOptOutPlayers()
			for _, corpse in ipairs(corpses) do
				attachVanillaOverlay(corpse, opt_out_players)
			end
		end
	end, ENTITY_FILTER)

	script.on_event(defines.events.on_object_destroyed, function(event)
		if not storage.overlays then return end
		local render_obj = storage.overlays[event.registration_number]
		if render_obj then
			if render_obj.valid then
				render_obj.destroy()
			end
			storage.overlays[event.registration_number] = nil
		end
	end)
end

-- Lifecycle Hooks
script.on_init(function()
	registerEvents()
	fullRescan()
end)

script.on_load(function()
	registerEvents()
end)

script.on_configuration_changed(function()
	registerEvents()
	fullRescan()
end)
