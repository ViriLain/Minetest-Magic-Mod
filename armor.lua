-- Mana armor
-- Armor pieces that boost max mana and mana regeneration
-- Uses Minetest's built-in armor inventory (3d_armor not required)
-- Worn in the craft grid as "equipped" via player metadata tracking

local mana = magic.mana

-- Armor definitions with mana bonuses
local armor_pieces = {
	{
		name = "magic:mana_helmet",
		description = "Mana Helmet",
		bonus_desc = "+20 max mana, +1 mana regen/sec",
		texture = "default_steel_ingot.png^[colorize:#0000AA:150",
		max_mana_bonus = 20,
		regen_bonus = 1,
	},
	{
		name = "magic:mana_chestplate",
		description = "Mana Chestplate",
		bonus_desc = "+40 max mana, +2 mana regen/sec",
		texture = "default_steel_ingot.png^[colorize:#0000DD:150",
		max_mana_bonus = 40,
		regen_bonus = 2,
	},
	{
		name = "magic:mana_leggings",
		description = "Mana Leggings",
		bonus_desc = "+25 max mana, +1 mana regen/sec",
		texture = "default_steel_ingot.png^[colorize:#0000BB:150",
		max_mana_bonus = 25,
		regen_bonus = 1,
	},
	{
		name = "magic:mana_boots",
		description = "Mana Boots",
		bonus_desc = "+15 max mana, +1 mana regen/sec",
		texture = "default_steel_ingot.png^[colorize:#000099:150",
		max_mana_bonus = 15,
		regen_bonus = 1,
	},
}

-- Register each armor piece as a craftitem that can be "equipped" on use
for _, piece in ipairs(armor_pieces) do
	minetest.register_tool(piece.name, {
		description = piece.description .. "\n" ..
			minetest.colorize("#8888FF", piece.bonus_desc),
		inventory_image = piece.texture,
		groups = {armor = 1},
		tool_capabilities = {
			full_punch_interval = 1.0,
			max_drop_level = 0,
			damage_groups = {},
		},
		-- Equip on use
		on_use = function(itemstack, user, pointed_thing)
			local name = user:get_player_name()
			local meta = user:get_meta()
			local slot = piece.name:gsub("magic:", "")

			-- Check if already wearing this type
			local current = meta:get_string("magic_armor_" .. slot)
			if current == "equipped" then
				-- Unequip
				meta:set_string("magic_armor_" .. slot, "")
				minetest.chat_send_player(name,
					"Unequipped " .. piece.description)
			else
				-- Equip
				meta:set_string("magic_armor_" .. slot, "equipped")
				minetest.chat_send_player(name,
					"Equipped " .. piece.description .. " (" .. piece.bonus_desc .. ")")
			end

			-- Recalculate bonuses
			magic.armor.recalculate(user)
			return itemstack
		end,
	})
end

-- Armor bonus tracking per player
local player_bonuses = {}

local armor = {}

-- Recalculate armor bonuses for a player based on what they have equipped
function armor.recalculate(player)
	local name = player:get_player_name()
	local meta = player:get_meta()
	local total_max = 0
	local total_regen = 0

	-- Check each armor slot
	for _, piece in ipairs(armor_pieces) do
		local slot = piece.name:gsub("magic:", "")
		if meta:get_string("magic_armor_" .. slot) == "equipped" then
			-- Verify the player actually has the item in inventory
			local inv = player:get_inventory()
			if inv:contains_item("main", piece.name) then
				total_max = total_max + piece.max_mana_bonus
				total_regen = total_regen + piece.regen_bonus
			else
				-- Item no longer in inventory, unequip it
				meta:set_string("magic_armor_" .. slot, "")
			end
		end
	end

	player_bonuses[name] = {
		max_mana = total_max,
		regen = total_regen,
	}
end

-- Get mana bonuses for a player
function armor.get_max_mana_bonus(player_name)
	local bonus = player_bonuses[player_name]
	if not bonus then
		return 0
	end
	return bonus.max_mana
end

function armor.get_regen_bonus(player_name)
	local bonus = player_bonuses[player_name]
	if not bonus then
		return 0
	end
	return bonus.regen
end

-- Recalculate on join
minetest.register_on_joinplayer(function(player)
	-- Slight delay to ensure inventory is loaded
	minetest.after(0.5, function()
		if player:get_pos() then
			armor.recalculate(player)
		end
	end)
end)

-- Clean up on leave
minetest.register_on_leaveplayer(function(player)
	player_bonuses[player:get_player_name()] = nil
end)

-- Periodically recheck armor (catches inventory changes)
local armor_timer = 0
minetest.register_globalstep(function(dtime)
	armor_timer = armor_timer + dtime
	if armor_timer < 2.0 then
		return
	end
	armor_timer = 0

	for _, player in ipairs(minetest.get_connected_players()) do
		armor.recalculate(player)
	end
end)

magic.armor = armor
