# CLAUDE.md — AI Assistant Guide for Minetest-Magic-Mod

## Project Overview

**Minetest-Magic-Mod** (also referred to as "Minetest-Wand-Mods") is a Minetest game mod project focused on magic and wand mechanics. The project is in a **pre-development / skeleton state** — no mod code has been implemented yet.

- **Author:** Joe H. (ViriLain)
- **License:** MIT (2019)
- **Game Engine:** [Minetest](https://www.minetest.net/) (open-source voxel game engine)
- **Language:** Lua (Minetest modding API)

## Repository Structure

```
Minetest-Magic-Mod/
├── .gitignore        # Lua build artifacts, compiled objects, shared libraries
├── LICENSE           # MIT License
├── README.md         # Project title only ("Minetest-Wand-Mods")
└── CLAUDE.md         # This file
```

### Missing (Needed for a Functional Mod)

A complete Minetest mod requires at minimum:

| File/Directory | Purpose |
|---|---|
| `mod.conf` | Mod metadata: name, description, dependencies, author |
| `init.lua` | Main entry point — loaded by Minetest engine |
| `textures/` | PNG texture files for items, nodes, entities |
| `sounds/` | OGG audio files (optional) |
| `models/` | 3D mesh models (optional) |
| `settingtypes.txt` | Configurable mod settings (optional) |

## Development Conventions

### Minetest Mod Standards

When implementing this mod, follow these conventions:

- **Mod naming:** Use a short, lowercase mod name (e.g., `magic`) as the namespace prefix for all registered items, nodes, and entities: `magic:wand_fire`, `magic:spell_heal`
- **Entry point:** All mod code starts in `init.lua`, which can `dofile()` additional modules
- **API calls:** Use `minetest.register_node()`, `minetest.register_tool()`, `minetest.register_craftitem()`, `minetest.register_entity()`, etc.
- **Textures:** Named as `modname_itemname.png` (e.g., `magic_wand_fire.png`), placed in `textures/`

### Lua Style

- Use **snake_case** for variables and functions
- Use **local** scope by default; avoid globals except the mod namespace table
- Indent with **tabs** (Minetest community convention)
- Prefix private/internal functions with `_` or keep them `local`

### mod.conf Format

```
name = magic
description = Magic wands and spells for Minetest
depends = default
optional_depends =
author = Joe H.
```

## Git Workflow

- **Default branch:** `master`
- **Remote:** `origin` pointing to ViriLain/Minetest-Magic-Mod
- **Commit style:** Use clear, descriptive commit messages in imperative mood

## Build & Run

No build step is required. Minetest mods are loaded directly from Lua source:

1. Clone/symlink this repo into `~/.minetest/mods/` (or the game's `mods/` directory)
2. Enable the mod in Minetest's world configuration
3. Minetest loads `init.lua` on world start

### Testing

No test framework is currently configured. For Minetest mods, testing options include:

- **Manual testing:** Load the mod in a Minetest world and test in-game
- **Luacheck:** Static analysis for Lua (`luacheck .` with a `.luacheckrc` config)
- **Busted:** Lua unit test framework (requires mocking Minetest API)

## Key Notes for AI Assistants

1. **This project has no code yet.** Any implementation work starts from scratch.
2. **Minetest API:** Reference the [Minetest Lua API docs](https://minetest.gitlab.io/minetest/) for available functions and callbacks.
3. **Do not assume dependencies** beyond the `default` mod unless explicitly requested.
4. **Texture files** must be provided or generated separately — they cannot be created as code.
5. **Keep it simple.** Minetest mods should be lightweight and focused. Avoid over-engineering.
6. **Respect the MIT license** in all generated code.
