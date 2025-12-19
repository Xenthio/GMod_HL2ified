# HL2 Loading Screen

A standalone addon that replaces Garry's Mod loading screens with Half-Life 2 style loading screens during level transitions.

## Features

- Shows the last rendered game frame during level transitions
- HL2-style centered loading panel with rounded corners
- Skips HTML loading screen for faster transitions
- No HUD overlay on the captured frame (authentic HL2 style)

## Installation

1. Place the addon folder in your `garrysmod/addons/` directory
2. Copy the contents of `placemeinroot/` to your `garrysmod/` directory:
   - Copy `placemeinroot/lua/menu/loading.lua` to `garrysmod/lua/menu/loading.lua`

**Note:** The `placemeinroot` folder contains files that override base GMod files. These must be manually copied to the garrysmod root directory as addons cannot override menu state files.

## How It Works

1. **Client-side** (`lua/autorun/client/hl2_loading_capture.lua`): Updates the screen effect texture every frame using `render.UpdateScreenEffectTexture(0)`

2. **Menu-side** (`placemeinroot/lua/menu/loading.lua`): Reads the `_rt_fullframefb` render target and displays it with an HL2-style loading panel overlay

## Compatibility

Works with any gamemode. The loading screen will automatically show the last rendered frame when transitioning between levels.
