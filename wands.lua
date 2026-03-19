-- Magic wands module
-- Registers wand tools with unique magical abilities

local mana = magic.mana

-- Helper: play sound + particles at a position
local function magic_effect(pos, particle_texture, sound_name, count)
	count = count or 20
	minetest.add_particlespawner({
		amount = count,
		time = 0.5,
		minpos = vector.subtract(pos, 0.5),
		maxpos = vector.add(pos, 0.5),
		minvel = {x = -1, y = 0, z = -1},
		maxvel = {x = 1, y = 2, z = 1},
		minacc = {x = 0, y = -1, z = 0},
		maxacc = {x = 0, y = 1, z = 0},
		minexptime = 0.5,
		maxexptime = 1.5,
		minsize = 1,
		maxsize = 3,
		texture = particle_texture,
	})
	if sound_name then
		minetest.sound_play(sound_name, {pos = pos, max_hear_distance = 16})
	end
end

-- Helper: raycast from player eye position in look direction
local function wand_raycast(player, range)
	range = range or 20
	local eye_pos = vector.add(player:get_pos(), {x = 0, y = 1.625, z = 0})
	local look_dir = player:get_look_dir()
	local end_pos = vector.add(eye_pos, vector.multiply(look_dir, range))
	return minetest.raycast(eye_pos, end_pos, true, false)
end

----------------------------------------------------------------------
-- Fire Wand
----------------------------------------------------------------------

minetest.register_tool("magic:wand_fire", {
	description = "Fire Wand\nShoots a fireball that ignites targets",
	inventory_image = "default_stick.png^[colorize:#FF4400:180",
	wield_image = "default_stick.png^[colorize:#FF4400:180",
	tool_capabilities = {
		full_punch_interval = 1.5,
		max_drop_level = 0,
		damage_groups = {fleshy = 2},
	},
	on_use = function(itemstack, user, pointed_thing)
		local name = user:get_player_name()
		if not mana.consume(name, 15) then
			minetest.chat_send_player(name, "Not enough mana! (need 15)")
			return
		end

		local ray = wand_raycast(user, 25)
		for hit in ray do
			if hit.type == "object" and hit.ref ~= user then
				local target = hit.ref
				target:punch(user, 1.0, {
					full_punch_interval = 1.0,
					damage_groups = {fleshy = 6},
				})
				-- Set target on fire (damage over time)
				local target_pos = target:get_pos()
				if target_pos then
					magic_effect(target_pos, "default_furnace_fire_fg.png", "default_cool_lava", 30)
					-- Fire damage over time: 2 damage every second for 3 seconds
					for i = 1, 3 do
						minetest.after(i, function()
							if target:get_pos() then
								target:punch(user, 1.0, {
									full_punch_interval = 1.0,
									damage_groups = {fleshy = 2},
								})
								magic_effect(target:get_pos(),
									"default_furnace_fire_fg.png", nil, 10)
							end
						end)
					end
				end
				break
			elseif hit.type == "node" then
				local above = hit.above
				local node = minetest.get_node(above)
				if node.name == "air" then
					minetest.set_node(above, {name = "fire:basic_flame"})
					minetest.after(4, function()
						if minetest.get_node(above).name == "fire:basic_flame" then
							minetest.remove_node(above)
						end
					end)
				end
				magic_effect(above, "default_furnace_fire_fg.png", "default_cool_lava", 20)
				break
			end
		end

		itemstack:add_wear(65535 / 150)
		return itemstack
	end,
})

----------------------------------------------------------------------
-- Ice Wand
----------------------------------------------------------------------

minetest.register_tool("magic:wand_ice", {
	description = "Ice Wand\nFreezes targets and creates ice",
	inventory_image = "default_stick.png^[colorize:#88CCFF:180",
	wield_image = "default_stick.png^[colorize:#88CCFF:180",
	tool_capabilities = {
		full_punch_interval = 1.5,
		max_drop_level = 0,
		damage_groups = {fleshy = 2},
	},
	on_use = function(itemstack, user, pointed_thing)
		local name = user:get_player_name()
		if not mana.consume(name, 12) then
			minetest.chat_send_player(name, "Not enough mana! (need 12)")
			return
		end

		local ray = wand_raycast(user, 25)
		for hit in ray do
			if hit.type == "object" and hit.ref ~= user then
				local target = hit.ref
				target:punch(user, 1.0, {
					full_punch_interval = 1.0,
					damage_groups = {fleshy = 4},
				})
				-- Slow the target by overriding physics
				local target_pos = target:get_pos()
				if target_pos then
					magic_effect(target_pos, "default_ice.png", "default_glass_footstep", 25)
					if target:is_player() then
						local physics = target:get_physics_override()
						target:set_physics_override({speed = 0.3})
						minetest.after(3, function()
							if target:get_pos() then
								target:set_physics_override({speed = physics.speed or 1})
							end
						end)
					end
				end
				break
			elseif hit.type == "node" then
				local node_pos = hit.under
				local node = minetest.get_node(node_pos)
				-- Turn water to ice
				if node.name == "default:water_source" then
					minetest.set_node(node_pos, {name = "default:ice"})
					minetest.after(8, function()
						if minetest.get_node(node_pos).name == "default:ice" then
							minetest.set_node(node_pos, {name = "default:water_source"})
						end
					end)
				end
				magic_effect(node_pos, "default_ice.png", "default_glass_footstep", 20)
				break
			end
		end

		itemstack:add_wear(65535 / 150)
		return itemstack
	end,
})

----------------------------------------------------------------------
-- Lightning Wand
----------------------------------------------------------------------

minetest.register_tool("magic:wand_lightning", {
	description = "Lightning Wand\nStrikes targets with lightning",
	inventory_image = "default_stick.png^[colorize:#FFFF00:180",
	wield_image = "default_stick.png^[colorize:#FFFF00:180",
	tool_capabilities = {
		full_punch_interval = 2.0,
		max_drop_level = 0,
		damage_groups = {fleshy = 2},
	},
	on_use = function(itemstack, user, pointed_thing)
		local name = user:get_player_name()
		if not mana.consume(name, 25) then
			minetest.chat_send_player(name, "Not enough mana! (need 25)")
			return
		end

		local ray = wand_raycast(user, 30)
		for hit in ray do
			if hit.type == "object" and hit.ref ~= user then
				local target = hit.ref
				target:punch(user, 1.0, {
					full_punch_interval = 1.0,
					damage_groups = {fleshy = 10},
				})
				local target_pos = target:get_pos()
				if target_pos then
					-- Lightning bolt visual: tall particle column
					minetest.add_particlespawner({
						amount = 50,
						time = 0.2,
						minpos = {x = target_pos.x, y = target_pos.y, z = target_pos.z},
						maxpos = {x = target_pos.x, y = target_pos.y + 20, z = target_pos.z},
						minvel = {x = -0.2, y = -2, z = -0.2},
						maxvel = {x = 0.2, y = 2, z = 0.2},
						minacc = {x = 0, y = 0, z = 0},
						maxacc = {x = 0, y = 0, z = 0},
						minexptime = 0.3,
						maxexptime = 0.8,
						minsize = 2,
						maxsize = 5,
						texture = "default_gold_ingot.png^[colorize:#FFFFFF:200",
						glow = 14,
					})
					minetest.sound_play("default_break_glass", {
						pos = target_pos, max_hear_distance = 32,
					})
				end
				break
			elseif hit.type == "node" then
				local pos = hit.above
				minetest.add_particlespawner({
					amount = 40,
					time = 0.2,
					minpos = {x = pos.x, y = pos.y, z = pos.z},
					maxpos = {x = pos.x, y = pos.y + 15, z = pos.z},
					minvel = {x = -0.2, y = -2, z = -0.2},
					maxvel = {x = 0.2, y = 2, z = 0.2},
					minacc = {x = 0, y = 0, z = 0},
					maxacc = {x = 0, y = 0, z = 0},
					minexptime = 0.3,
					maxexptime = 0.8,
					minsize = 2,
					maxsize = 5,
					texture = "default_gold_ingot.png^[colorize:#FFFFFF:200",
					glow = 14,
				})
				minetest.sound_play("default_break_glass", {
					pos = pos, max_hear_distance = 32,
				})
				break
			end
		end

		itemstack:add_wear(65535 / 100)
		return itemstack
	end,
})

----------------------------------------------------------------------
-- Healing Wand
----------------------------------------------------------------------

minetest.register_tool("magic:wand_heal", {
	description = "Healing Wand\nRestores health to yourself or others",
	inventory_image = "default_stick.png^[colorize:#00FF88:180",
	wield_image = "default_stick.png^[colorize:#00FF88:180",
	tool_capabilities = {
		full_punch_interval = 2.0,
		max_drop_level = 0,
		damage_groups = {},
	},
	on_use = function(itemstack, user, pointed_thing)
		local name = user:get_player_name()
		if not mana.consume(name, 20) then
			minetest.chat_send_player(name, "Not enough mana! (need 20)")
			return
		end

		local target = user -- default: heal self

		-- If pointing at another player, heal them instead
		if pointed_thing.type == "object" then
			local obj = pointed_thing.ref
			if obj and obj:is_player() then
				target = obj
			end
		end

		local hp = target:get_hp()
		local max_hp = target:get_properties().hp_max or 20
		local heal_amount = 8

		target:set_hp(math.min(hp + heal_amount, max_hp))

		local pos = target:get_pos()
		if pos then
			magic_effect(pos, "default_apple.png^[colorize:#00FF88:200", nil, 25)
			minetest.add_particlespawner({
				amount = 15,
				time = 1,
				minpos = vector.subtract(pos, 0.3),
				maxpos = vector.add(pos, {x = 0.3, y = 1.8, z = 0.3}),
				minvel = {x = -0.2, y = 0.5, z = -0.2},
				maxvel = {x = 0.2, y = 1.5, z = 0.2},
				minexptime = 0.5,
				maxexptime = 1.0,
				minsize = 1,
				maxsize = 2,
				texture = "default_apple.png^[colorize:#00FF88:200",
				glow = 10,
			})
		end

		local target_name = target:get_player_name()
		if target_name == name then
			minetest.chat_send_player(name, "Healed yourself for " .. heal_amount .. " HP")
		else
			minetest.chat_send_player(name, "Healed " .. target_name .. " for " .. heal_amount .. " HP")
			minetest.chat_send_player(target_name, name .. " healed you for " .. heal_amount .. " HP")
		end

		itemstack:add_wear(65535 / 200)
		return itemstack
	end,
})
