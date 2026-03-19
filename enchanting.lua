-- Enchanting system
-- Provides an enchanting table node and weapon enchantments

local mana = magic.mana

-- Enchantment definitions
-- Each enchantment modifies weapon behavior
local enchantments = {
	fire = {
		name = "Fire Aspect",
		description = "Sets targets on fire for extra damage",
		mana_cost = 40,
		color = "#FF4400",
		extra_damage = 2,
		duration = 3,
	},
	ice = {
		name = "Frost",
		description = "Slows targets on hit",
		mana_cost = 35,
		color = "#88CCFF",
		extra_damage = 1,
		duration = 2,
	},
	lightning = {
		name = "Thunderstrike",
		description = "Chance to deal bonus lightning damage",
		mana_cost = 50,
		color = "#FFFF00",
		extra_damage = 4,
		duration = 0,
	},
	lifesteal = {
		name = "Lifesteal",
		description = "Heals attacker for a portion of damage dealt",
		mana_cost = 45,
		color = "#00FF88",
		extra_damage = 0,
		duration = 0,
	},
}

-- Tools that can be enchanted (base names from the default mod)
local enchantable_tools = {
	["default:sword_wood"] = true,
	["default:sword_stone"] = true,
	["default:sword_steel"] = true,
	["default:sword_bronze"] = true,
	["default:sword_mese"] = true,
	["default:sword_diamond"] = true,
	["default:axe_wood"] = true,
	["default:axe_stone"] = true,
	["default:axe_steel"] = true,
	["default:axe_bronze"] = true,
	["default:axe_mese"] = true,
	["default:axe_diamond"] = true,
}

-- Store enchantments in item metadata
local function get_enchantment(itemstack)
	local meta = itemstack:get_meta()
	return meta:get_string("magic_enchantment")
end

local function set_enchantment(itemstack, ench_type)
	local meta = itemstack:get_meta()
	local ench = enchantments[ench_type]
	if not ench then
		return itemstack
	end
	meta:set_string("magic_enchantment", ench_type)
	-- Update description to show enchantment
	local base_desc = minetest.registered_items[itemstack:get_name()]
	local desc = (base_desc and base_desc.description) or itemstack:get_name()
	meta:set_string("description",
		desc .. "\n" .. minetest.colorize(ench.color, ench.name))
	return itemstack
end

-- Apply enchantment effects when a player hits something
minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch,
		tool_capabilities, dir, damage)
	if not hitter or not hitter:is_player() then
		return
	end

	local wielded = hitter:get_wielded_item()
	local ench_type = get_enchantment(wielded)
	if ench_type == "" then
		return
	end

	local ench = enchantments[ench_type]
	if not ench then
		return
	end

	local target_pos = player:get_pos()

	if ench_type == "fire" then
		-- Fire damage over time
		if target_pos then
			minetest.add_particlespawner({
				amount = 15, time = 0.5,
				minpos = vector.subtract(target_pos, 0.3),
				maxpos = vector.add(target_pos, 0.3),
				minvel = {x = -0.5, y = 0.5, z = -0.5},
				maxvel = {x = 0.5, y = 1.5, z = 0.5},
				minexptime = 0.3, maxexptime = 0.8,
				minsize = 1, maxsize = 2,
				texture = "default_furnace_fire_fg.png",
			})
		end
		for i = 1, ench.duration do
			minetest.after(i, function()
				if player:get_pos() then
					player:punch(hitter, 1.0, {
						full_punch_interval = 1.0,
						damage_groups = {fleshy = ench.extra_damage},
					})
				end
			end)
		end

	elseif ench_type == "ice" then
		-- Slow the target
		if target_pos then
			minetest.add_particlespawner({
				amount = 15, time = 0.5,
				minpos = vector.subtract(target_pos, 0.3),
				maxpos = vector.add(target_pos, 0.3),
				minvel = {x = -0.5, y = 0, z = -0.5},
				maxvel = {x = 0.5, y = 1, z = 0.5},
				minexptime = 0.5, maxexptime = 1.0,
				minsize = 1, maxsize = 2,
				texture = "default_ice.png",
			})
		end
		local physics = player:get_physics_override()
		player:set_physics_override({speed = 0.4})
		minetest.after(ench.duration, function()
			if player:get_pos() then
				player:set_physics_override({speed = physics.speed or 1})
			end
		end)

	elseif ench_type == "lightning" then
		-- 40% chance for bonus lightning damage
		if math.random() < 0.4 then
			player:punch(hitter, 1.0, {
				full_punch_interval = 1.0,
				damage_groups = {fleshy = ench.extra_damage},
			})
			if target_pos then
				minetest.add_particlespawner({
					amount = 30, time = 0.2,
					minpos = target_pos,
					maxpos = {x = target_pos.x, y = target_pos.y + 10, z = target_pos.z},
					minvel = {x = -0.1, y = -1, z = -0.1},
					maxvel = {x = 0.1, y = 1, z = 0.1},
					minexptime = 0.2, maxexptime = 0.5,
					minsize = 2, maxsize = 4,
					texture = "default_gold_ingot.png^[colorize:#FFFFFF:200",
					glow = 14,
				})
				minetest.sound_play("default_break_glass", {
					pos = target_pos, max_hear_distance = 24,
				})
			end
		end

	elseif ench_type == "lifesteal" then
		-- Heal attacker for 30% of damage dealt
		local heal = math.ceil(damage * 0.3)
		if heal > 0 then
			local hp = hitter:get_hp()
			local max_hp = hitter:get_properties().hp_max or 20
			hitter:set_hp(math.min(hp + heal, max_hp))
			local hitter_pos = hitter:get_pos()
			if hitter_pos then
				minetest.add_particlespawner({
					amount = 8, time = 0.3,
					minpos = vector.subtract(hitter_pos, 0.2),
					maxpos = vector.add(hitter_pos, {x = 0.2, y = 1.5, z = 0.2}),
					minvel = {x = 0, y = 0.3, z = 0},
					maxvel = {x = 0, y = 0.8, z = 0},
					minexptime = 0.3, maxexptime = 0.6,
					minsize = 1, maxsize = 2,
					texture = "default_apple.png^[colorize:#FF0000:200",
					glow = 8,
				})
			end
		end
	end
end)

----------------------------------------------------------------------
-- Enchanting Table node
----------------------------------------------------------------------

-- Formspec for the enchanting table
local function get_enchanting_formspec(player_name)
	local current_mana = math.floor(mana.get(player_name))
	return "size[8,7.5]" ..
		"label[0,0;Enchanting Table]" ..
		"label[0,0.5;Place a weapon in the slot, then choose an enchantment]" ..
		"label[0,1;Mana: " .. current_mana .. "]" ..
		"list[context;weapon;3.5,1;1,1;]" ..
		"button[0.5,2.5;3,1;enchant_fire;Fire Aspect (40 mana)]" ..
		"button[4.5,2.5;3,1;enchant_ice;Frost (35 mana)]" ..
		"button[0.5,3.5;3,1;enchant_lightning;Thunderstrike (50 mana)]" ..
		"button[4.5,3.5;3,1;enchant_lifesteal;Lifesteal (45 mana)]" ..
		"list[current_player;main;0,4.5;8,3;]" ..
		"listring[context;weapon]" ..
		"listring[current_player;main]"
end

minetest.register_node("magic:enchanting_table", {
	description = "Enchanting Table\nEnchant weapons with magical properties",
	tiles = {
		"default_obsidian.png^[colorize:#440088:100", -- top
		"default_obsidian.png",                        -- bottom
		"default_obsidian.png^[colorize:#220044:80",   -- sides
	},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.0, 0.5}, -- base
			{-0.375, 0.0, -0.375, 0.375, 0.125, 0.375}, -- top
		},
	},
	paramtype = "light",
	light_source = 5,
	groups = {cracky = 2},
	sounds = default.node_sound_stone_defaults(),

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("weapon", 1)
		meta:set_string("formspec", get_enchanting_formspec(""))
	end,

	on_rightclick = function(pos, node, clicker)
		local meta = minetest.get_meta(pos)
		local name = clicker:get_player_name()
		meta:set_string("formspec", get_enchanting_formspec(name))
	end,

	on_receive_fields = function(pos, formname, fields, sender)
		local name = sender:get_player_name()
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local weapon_stack = inv:get_stack("weapon", 1)

		-- Determine which enchantment was selected
		local ench_type = nil
		if fields.enchant_fire then ench_type = "fire"
		elseif fields.enchant_ice then ench_type = "ice"
		elseif fields.enchant_lightning then ench_type = "lightning"
		elseif fields.enchant_lifesteal then ench_type = "lifesteal"
		end

		if not ench_type then
			return
		end

		-- Validate weapon
		if weapon_stack:is_empty() then
			minetest.chat_send_player(name, "Place a weapon in the slot first!")
			return
		end

		if not enchantable_tools[weapon_stack:get_name()] then
			minetest.chat_send_player(name, "This item cannot be enchanted!")
			return
		end

		if get_enchantment(weapon_stack) ~= "" then
			minetest.chat_send_player(name, "This weapon is already enchanted!")
			return
		end

		-- Check and consume mana
		local ench = enchantments[ench_type]
		if not mana.consume(name, ench.mana_cost) then
			minetest.chat_send_player(name,
				"Not enough mana! (need " .. ench.mana_cost .. ")")
			return
		end

		-- Apply enchantment
		weapon_stack = set_enchantment(weapon_stack, ench_type)
		inv:set_stack("weapon", 1, weapon_stack)

		-- Effects
		minetest.sound_play("default_place_node_metal", {
			pos = pos, max_hear_distance = 16,
		})
		minetest.add_particlespawner({
			amount = 30,
			time = 1,
			minpos = vector.subtract(pos, 0.5),
			maxpos = vector.add(pos, {x = 0.5, y = 1.5, z = 0.5}),
			minvel = {x = -0.5, y = 0.5, z = -0.5},
			maxvel = {x = 0.5, y = 2, z = 0.5},
			minexptime = 0.5,
			maxexptime = 1.5,
			minsize = 1,
			maxsize = 3,
			texture = "default_obsidian_shard.png^[colorize:" .. ench.color .. ":200",
			glow = 10,
		})

		minetest.chat_send_player(name,
			"Enchanted weapon with " .. ench.name .. "!")

		-- Refresh formspec
		meta:set_string("formspec", get_enchanting_formspec(name))
	end,

	-- Drop contents when broken
	on_dig = function(pos, node, digger)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local weapon = inv:get_stack("weapon", 1)
		if not weapon:is_empty() then
			local above = {x = pos.x, y = pos.y + 1, z = pos.z}
			minetest.item_drop(weapon, digger, above)
		end
		minetest.node_dig(pos, node, digger)
	end,

	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if listname == "weapon" and enchantable_tools[stack:get_name()] then
			return stack:get_count()
		end
		return 0
	end,
})

----------------------------------------------------------------------
-- Mana Crystal item (used in crafting)
----------------------------------------------------------------------

minetest.register_craftitem("magic:mana_crystal", {
	description = "Mana Crystal\nUsed for crafting magical items",
	inventory_image = "default_diamond.png^[colorize:#0000FF:150",
})
