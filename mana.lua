-- Mana system for the magic mod
-- Each player has a mana pool that regenerates over time

local mana = {}

-- Player mana storage: { player_name = { current = N, max = N } }
local player_mana = {}

local MANA_MAX_DEFAULT = 100
local MANA_REGEN_RATE = 1 -- mana per second
local MANA_HUD_UPDATE_INTERVAL = 0.5

-- HUD element IDs per player
local hud_ids = {}

function mana.get(player_name)
	local m = player_mana[player_name]
	if not m then
		return 0
	end
	return m.current
end

function mana.get_max(player_name)
	local m = player_mana[player_name]
	if not m then
		return MANA_MAX_DEFAULT
	end
	return m.max
end

function mana.set(player_name, value)
	local m = player_mana[player_name]
	if not m then
		return
	end
	m.current = math.max(0, math.min(value, m.max))
end

function mana.consume(player_name, amount)
	local m = player_mana[player_name]
	if not m then
		return false
	end
	if m.current < amount then
		return false
	end
	m.current = m.current - amount
	return true
end

function mana.add(player_name, amount)
	local m = player_mana[player_name]
	if not m then
		return
	end
	m.current = math.min(m.current + amount, m.max)
end

-- Initialize mana for a joining player
minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	player_mana[name] = {
		current = MANA_MAX_DEFAULT,
		max = MANA_MAX_DEFAULT,
	}

	-- Add mana HUD bar
	local bg_id = player:hud_add({
		hud_elem_type = "statbar",
		position = {x = 0.5, y = 1},
		text = "default_steel_ingot.png^[colorize:#00008B:255",
		number = 2 * MANA_MAX_DEFAULT,
		direction = 0,
		size = {x = 24, y = 24},
		offset = {x = 25, y = -(48 + 24 + 39)},
	})

	local bar_id = player:hud_add({
		hud_elem_type = "statbar",
		position = {x = 0.5, y = 1},
		text = "default_steel_ingot.png^[colorize:#0000FF:255",
		number = 2 * MANA_MAX_DEFAULT,
		direction = 0,
		size = {x = 24, y = 24},
		offset = {x = 25, y = -(48 + 24 + 39)},
	})

	local text_id = player:hud_add({
		hud_elem_type = "text",
		position = {x = 0.5, y = 1},
		text = "Mana: " .. MANA_MAX_DEFAULT .. "/" .. MANA_MAX_DEFAULT,
		number = 0x0000FF,
		direction = 0,
		offset = {x = 125, y = -(48 + 24 + 52)},
	})

	hud_ids[name] = {bg = bg_id, bar = bar_id, text = text_id}
end)

-- Clean up on leave
minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	player_mana[name] = nil
	hud_ids[name] = nil
end)

-- Regenerate mana and update HUD
local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer < MANA_HUD_UPDATE_INTERVAL then
		return
	end

	local elapsed = timer
	timer = 0

	for _, player in ipairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local m = player_mana[name]
		if m then
			-- Calculate effective max mana (base + armor bonus)
			local armor_bonus = 0
			if magic.armor then
				armor_bonus = magic.armor.get_max_mana_bonus(name)
			end
			m.max = MANA_MAX_DEFAULT + armor_bonus

			-- Calculate effective regen (base + armor + potion buff)
			local effective_regen = MANA_REGEN_RATE
			if magic.armor then
				effective_regen = effective_regen +
					magic.armor.get_regen_bonus(name)
			end
			if magic.potions and magic.potions.has_regen_buff(name) then
				effective_regen = effective_regen * 2
			end

			-- Regenerate
			if m.current < m.max then
				m.current = math.min(m.current + effective_regen * elapsed, m.max)
			end
			-- Clamp if max decreased (armor unequipped)
			if m.current > m.max then
				m.current = m.max
			end

			-- Update HUD bar
			local ids = hud_ids[name]
			if ids then
				player:hud_change(ids.bg, "number", math.floor(2 * m.max))
				player:hud_change(ids.bar, "number", math.floor(2 * m.current))
				player:hud_change(ids.text, "text",
					"Mana: " .. math.floor(m.current) .. "/" .. m.max)
			end
		end
	end
end)

return mana
