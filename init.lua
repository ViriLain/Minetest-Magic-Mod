-- Magic Mod for Minetest
-- Adds magic wands, enchanting, and a mana system
--
-- Author: Joe H. (ViriLain)
-- License: MIT

local modpath = minetest.get_modpath("magic")

-- Global mod namespace
magic = {}

-- Load modules
magic.mana = dofile(modpath .. "/mana.lua")
dofile(modpath .. "/armor.lua")
dofile(modpath .. "/potions.lua")
dofile(modpath .. "/wands.lua")
dofile(modpath .. "/enchanting.lua")
dofile(modpath .. "/crafting.lua")

minetest.log("action", "[magic] Magic mod loaded")
