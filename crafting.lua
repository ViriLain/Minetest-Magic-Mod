-- Crafting recipes for magic mod items

----------------------------------------------------------------------
-- Mana Crystal: diamond + mese crystal
----------------------------------------------------------------------

minetest.register_craft({
	output = "magic:mana_crystal 2",
	recipe = {
		{"", "default:mese_crystal", ""},
		{"default:mese_crystal", "default:diamond", "default:mese_crystal"},
		{"", "default:mese_crystal", ""},
	},
})

----------------------------------------------------------------------
-- Wand recipes: stick core + mana crystals + element material
----------------------------------------------------------------------

-- Fire Wand: mana crystals + stick + coal (fuel/fire element)
minetest.register_craft({
	output = "magic:wand_fire",
	recipe = {
		{"", "default:coal_lump", "magic:mana_crystal"},
		{"", "default:stick", "default:coal_lump"},
		{"default:stick", "", ""},
	},
})

-- Ice Wand: mana crystals + stick + ice
minetest.register_craft({
	output = "magic:wand_ice",
	recipe = {
		{"", "default:ice", "magic:mana_crystal"},
		{"", "default:stick", "default:ice"},
		{"default:stick", "", ""},
	},
})

-- Lightning Wand: mana crystals + stick + gold (conductor)
minetest.register_craft({
	output = "magic:wand_lightning",
	recipe = {
		{"", "default:gold_ingot", "magic:mana_crystal"},
		{"", "default:stick", "default:gold_ingot"},
		{"default:stick", "", ""},
	},
})

-- Healing Wand: mana crystals + stick + apple (life element)
minetest.register_craft({
	output = "magic:wand_heal",
	recipe = {
		{"", "default:apple", "magic:mana_crystal"},
		{"", "default:stick", "default:apple"},
		{"default:stick", "", ""},
	},
})

----------------------------------------------------------------------
-- Enchanting Table: obsidian + mana crystals + diamond
----------------------------------------------------------------------

minetest.register_craft({
	output = "magic:enchanting_table",
	recipe = {
		{"", "magic:mana_crystal", ""},
		{"default:obsidian", "default:diamond", "default:obsidian"},
		{"default:obsidian", "default:obsidian", "default:obsidian"},
	},
})
