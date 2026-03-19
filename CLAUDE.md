# CLAUDE.md — AI Assistant Guide for Minetest-Magic-Mod

## Project Overview

**Minetest-Magic-Mod** is a Minetest game mod that adds magic wands, a mana system, and weapon enchanting. Players can craft wands to cast elemental spells and enchant swords/axes at an enchanting table.

- **Mod name:** `magic`
- **Author:** Joe H. (ViriLain)
- **License:** MIT (2019)
- **Game Engine:** [Minetest](https://www.minetest.net/) (open-source voxel game engine)
- **Language:** Lua (Minetest modding API)
- **Dependencies:** `default` mod (Minetest Game)

## Repository Structure

```
Minetest-Magic-Mod/
├── init.lua          # Entry point — loads all modules, sets up global `magic` table
├── mana.lua          # Mana system: pool, regen, HUD bar, consume/add API
├── wands.lua         # Four magic wands: fire, ice, lightning, healing
├── enchanting.lua    # Enchanting table node, enchantment effects, mana crystal item
├── crafting.lua      # All crafting recipes
├── mod.conf          # Mod metadata (name, description, depends)
├── .gitignore        # Lua build artifacts
├── LICENSE           # MIT License
├── README.md         # Project overview and usage guide
└── CLAUDE.md         # This file
```

### Not Yet Added (Optional)

| File/Directory | Purpose |
|---|---|
| `textures/` | Custom PNG textures (currently uses recolored default textures) |
| `sounds/` | Custom OGG audio (currently uses default mod sounds) |
| `settingtypes.txt` | Configurable mod settings |
| `models/` | 3D mesh models |

## Module Overview

### `init.lua`
Entry point. Creates the global `magic` namespace table and loads all modules via `dofile()`.

### `mana.lua`
- Player mana pool (default 100, regenerates at 1/sec)
- HUD bar displayed below health/hunger
- API: `magic.mana.get()`, `.consume()`, `.add()`, `.set()`, `.get_max()`

### `wands.lua`
Four wands registered as tools with `on_use` callbacks:
- **Fire Wand** (`magic:wand_fire`) — 15 mana, 6 damage + 3s burn DOT
- **Ice Wand** (`magic:wand_ice`) — 12 mana, 4 damage + slow effect
- **Lightning Wand** (`magic:wand_lightning`) — 25 mana, 10 damage + visual bolt
- **Healing Wand** (`magic:wand_heal`) — 20 mana, heals 8 HP (self or pointed player)

All wands use raycast targeting and have durability (wear).

### `enchanting.lua`
- **Enchanting Table** (`magic:enchanting_table`) — formspec-based UI node
- Four enchantments stored in item metadata: Fire Aspect, Frost, Thunderstrike, Lifesteal
- Works on default swords and axes
- **Mana Crystal** (`magic:mana_crystal`) — crafting ingredient
- Effects applied via `register_on_punchplayer`

### `crafting.lua`
Recipes for mana crystals, all four wands, and the enchanting table. Uses materials from the `default` mod.

## Development Conventions

### Minetest Mod Standards

- **Namespace:** All items prefixed with `magic:` (e.g., `magic:wand_fire`, `magic:enchanting_table`)
- **Entry point:** `init.lua` loads modules with `dofile()`
- **API calls:** `minetest.register_node()`, `minetest.register_tool()`, `minetest.register_craftitem()`, etc.
- **Textures:** Currently uses `default` mod textures with `^[colorize` modifiers. Custom textures should be named `magic_itemname.png` in `textures/`

### Lua Style

- Use **snake_case** for variables and functions
- Use **local** scope by default; only `magic` table is global
- Indent with **tabs** (Minetest community convention)
- Keep helper functions `local` to their module

### Key Patterns Used

- **Raycast targeting:** Wands use `minetest.raycast()` from eye position
- **Item metadata:** Enchantments stored via `itemstack:get_meta()`
- **Timed effects:** `minetest.after()` for DOTs, slows, temporary fire
- **Particle effects:** `minetest.add_particlespawner()` for visual feedback
- **Physics override:** Ice effects use `player:set_physics_override({speed = ...})`

## Git Workflow

- **Default branch:** `master`
- **Remote:** `origin` pointing to ViriLain/Minetest-Magic-Mod
- **Commit style:** Clear, descriptive messages in imperative mood

## Build & Run

No build step required. Minetest loads Lua source directly:

1. Clone/symlink this repo into `~/.minetest/mods/` (or the game's `mods/` directory)
2. Enable the mod in Minetest's world configuration
3. Minetest loads `init.lua` on world start

### Testing

No test framework is currently configured. Testing options:

- **Manual testing:** Load the mod in a Minetest world and test in-game
- **Luacheck:** Static analysis for Lua (`luacheck .` with a `.luacheckrc` config)
- **Busted:** Lua unit test framework (requires mocking Minetest API)

## Key Notes for AI Assistants

1. **The `magic` global table** is the mod namespace. Access mana API via `magic.mana`.
2. **Minetest API:** Reference the [Minetest Lua API docs](https://minetest.gitlab.io/minetest/) for available functions.
3. **Only depends on `default` mod.** Do not add other dependencies without explicit request.
4. **Textures are recolored defaults.** Custom texture PNGs cannot be generated as code.
5. **Keep it simple.** Minetest mods should be lightweight. Avoid over-engineering.
6. **Respect the MIT license** in all generated code.
7. **Enchantments use item metadata** — check `get_enchantment()` / `set_enchantment()` in `enchanting.lua`.
