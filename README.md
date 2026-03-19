# Minetest Magic Mod

A magic mod for [Minetest](https://www.minetest.net/) that adds magic wands, weapon enchanting, and a mana system.

## Features

### Mana System
- Every player has a mana pool (100 max) that regenerates over time
- Mana is consumed when casting spells or enchanting weapons
- Blue HUD bar shows current mana

### Magic Wands
Craft and wield elemental wands to cast spells:

| Wand | Mana Cost | Effect |
|---|---|---|
| Fire Wand | 15 | Fireball that ignites targets (6 damage + 3s burn) |
| Ice Wand | 12 | Freezes targets (4 damage + slow) |
| Lightning Wand | 25 | Lightning bolt (10 damage + visual effect) |
| Healing Wand | 20 | Heals yourself or a pointed player (8 HP) |

### Enchanting
- Craft an **Enchanting Table** to enchant swords and axes
- Four enchantments available:
  - **Fire Aspect** — burn damage over time
  - **Frost** — slows targets on hit
  - **Thunderstrike** — 40% chance for bonus lightning damage
  - **Lifesteal** — heals you for 30% of damage dealt

### Mana Potions
Brew potions to manage your mana in battle:

| Potion | Effect |
|---|---|
| Mana Potion | Restores 50 mana instantly |
| Greater Mana Potion | Fully restores mana |
| Mana Regen Potion | Doubles mana regen for 30 seconds |

### Mana Armor
Craft a set of mana-infused armor to boost your magical power:

| Piece | Max Mana Bonus | Regen Bonus |
|---|---|---|
| Mana Helmet | +20 | +1/sec |
| Mana Chestplate | +40 | +2/sec |
| Mana Leggings | +25 | +1/sec |
| Mana Boots | +15 | +1/sec |
| **Full Set** | **+100** | **+5/sec** |

Use (right-click) an armor piece while it's in your inventory to equip/unequip it.

### Crafting
All items are craftable using materials from the default Minetest Game:
- **Mana Crystals** — diamond + mese crystals
- **Wands** — sticks + mana crystal + element-specific materials
- **Enchanting Table** — obsidian + diamond + mana crystals
- **Potions** — glass + mana crystals + various catalysts
- **Armor** — steel ingots + mana crystals

## Installation

1. Clone or download this repository
2. Place it in your Minetest mods directory (`~/.minetest/mods/`)
3. Enable "magic" in your world's mod configuration

## Dependencies

- `default` (included in Minetest Game)

## License

MIT License — see [LICENSE](LICENSE) for details.
