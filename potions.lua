-- Mana potions
-- Consumable items that restore or boost mana

local mana = magic.mana

----------------------------------------------------------------------
-- Mana Potion: instantly restores 50 mana
----------------------------------------------------------------------

minetest.register_craftitem("magic:mana_potion", {
	description = "Mana Potion\nRestores 50 mana instantly",
	inventory_image = "default_glass_bottle.png^[colorize:#0000FF:180",
	stack_max = 16,
	on_use = function(itemstack, user, pointed_thing)
		local name = user:get_player_name()
		local current = mana.get(name)
		local max = mana.get_max(name)

		if current >= max then
			minetest.chat_send_player(name, "Mana is already full!")
			return
		end

		mana.add(name, 50)
		minetest.chat_send_player(name,
			"Restored mana: " .. math.floor(mana.get(name)) .. "/" .. max)

		-- Particle effect
		local pos = user:get_pos()
		if pos then
			minetest.add_particlespawner({
				amount = 15,
				time = 0.5,
				minpos = vector.subtract(pos, 0.3),
				maxpos = vector.add(pos, {x = 0.3, y = 1.8, z = 0.3}),
				minvel = {x = -0.3, y = 0.3, z = -0.3},
				maxvel = {x = 0.3, y = 1.0, z = 0.3},
				minexptime = 0.3,
				maxexptime = 0.8,
				minsize = 1,
				maxsize = 2,
				texture = "default_diamond.png^[colorize:#0000FF:200",
				glow = 8,
			})
		end

		itemstack:take_item()
		return itemstack
	end,
})

----------------------------------------------------------------------
-- Greater Mana Potion: restores 100 mana (full refill)
----------------------------------------------------------------------

minetest.register_craftitem("magic:mana_potion_greater", {
	description = "Greater Mana Potion\nFully restores mana",
	inventory_image = "default_glass_bottle.png^[colorize:#4400FF:200",
	stack_max = 8,
	on_use = function(itemstack, user, pointed_thing)
		local name = user:get_player_name()
		local current = mana.get(name)
		local max = mana.get_max(name)

		if current >= max then
			minetest.chat_send_player(name, "Mana is already full!")
			return
		end

		mana.set(name, max)
		minetest.chat_send_player(name, "Mana fully restored!")

		local pos = user:get_pos()
		if pos then
			minetest.add_particlespawner({
				amount = 30,
				time = 0.8,
				minpos = vector.subtract(pos, 0.4),
				maxpos = vector.add(pos, {x = 0.4, y = 2.0, z = 0.4}),
				minvel = {x = -0.5, y = 0.5, z = -0.5},
				maxvel = {x = 0.5, y = 1.5, z = 0.5},
				minexptime = 0.5,
				maxexptime = 1.2,
				minsize = 1,
				maxsize = 3,
				texture = "default_diamond.png^[colorize:#4400FF:200",
				glow = 12,
			})
		end

		itemstack:take_item()
		return itemstack
	end,
})

----------------------------------------------------------------------
-- Mana Regen Potion: doubles mana regen for 30 seconds
----------------------------------------------------------------------

-- Track active regen buffs
local regen_buffs = {}

minetest.register_craftitem("magic:mana_potion_regen", {
	description = "Mana Regeneration Potion\nDoubles mana regen for 30 seconds",
	inventory_image = "default_glass_bottle.png^[colorize:#00AAFF:180",
	stack_max = 8,
	on_use = function(itemstack, user, pointed_thing)
		local name = user:get_player_name()

		if regen_buffs[name] then
			minetest.chat_send_player(name, "Regen buff is already active!")
			return
		end

		regen_buffs[name] = true
		minetest.chat_send_player(name, "Mana regeneration doubled for 30 seconds!")

		local pos = user:get_pos()
		if pos then
			minetest.add_particlespawner({
				amount = 20,
				time = 1.0,
				minpos = vector.subtract(pos, 0.3),
				maxpos = vector.add(pos, {x = 0.3, y = 1.8, z = 0.3}),
				minvel = {x = -0.2, y = 0.5, z = -0.2},
				maxvel = {x = 0.2, y = 1.2, z = 0.2},
				minexptime = 0.5,
				maxexptime = 1.0,
				minsize = 1,
				maxsize = 2,
				texture = "default_diamond.png^[colorize:#00AAFF:200",
				glow = 10,
			})
		end

		minetest.after(30, function()
			regen_buffs[name] = nil
			if minetest.get_player_by_name(name) then
				minetest.chat_send_player(name, "Mana regeneration buff has worn off.")
			end
		end)

		itemstack:take_item()
		return itemstack
	end,
})

-- Clean up on player leave
minetest.register_on_leaveplayer(function(player)
	regen_buffs[player:get_player_name()] = nil
end)

-- Expose regen buff check for the mana system
magic.potions = {
	has_regen_buff = function(player_name)
		return regen_buffs[player_name] == true
	end,
}
