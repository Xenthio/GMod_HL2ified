# HL2 VGUI Derma Skin

This is a custom Derma skin for Garry's Mod that replicates the look and feel of Half-Life 2's VGUI interface.

## Features

- **Complete VGUI Control Styling**: All major Derma controls have been styled to match Source Engine VGUI
  - Frames and Windows
  - Buttons
  - Text Entry fields
  - CheckBoxes
  - ComboBoxes
  - Sliders
  - Labels
  - Panels
  - ListViews
  - Progress Bars
  - ScrollBars
  - Menus

- **Test Panel**: A comprehensive test panel showcasing all styled controls
- **Optional Default Skin**: Can be enabled to replace the default Derma skin

## Usage

### Testing the Controls

Open the test panel using the console command:
```
vgui_test
```

This will open a window displaying all available VGUI controls styled with the HL2 skin.

### Using HL2 Controls in Your Code

Instead of using standard Derma controls, use the HL2-prefixed versions:

```lua
-- Standard Derma controls
local frame = vgui.Create( "DFrame" )
local button = vgui.Create( "DButton" )
local textEntry = vgui.Create( "DTextEntry" )

-- HL2-styled controls
local frame = vgui.Create( "HL2Frame" )
local button = vgui.Create( "HL2Button" )
local textEntry = vgui.Create( "HL2TextEntry" )
```

Available HL2 controls:
- `HL2Frame` - Window frame
- `HL2Button` - Push button
- `HL2TextEntry` - Text input field
- `HL2CheckBox` - Checkbox
- `HL2ComboBox` - Dropdown menu
- `HL2Slider` - Slider control
- `HL2Label` - Text label
- `HL2Panel` - Generic panel
- `HL2ListView` - List view

### Setting HL2 as Default Skin

To use the HL2 skin as the default for all Derma controls:

1. Enable via console:
   ```
   hl2_derma_skin 1
   ```

2. Or toggle using:
   ```
   hl2_toggle_derma_skin
   ```

3. Restart the game or reload Lua for full effect:
   ```
   lua_refresh_file "*"
   ```

To disable:
```
hl2_derma_skin 0
```

### Manually Applying the Skin

You can also manually apply the HL2 skin to any Derma control:

```lua
local button = vgui.Create( "DButton" )
button:SetSkin( "HL2" )
```

## Technical Details

### File Structure

- `lua/skins/hl2.lua` - Main skin definition with all painting functions
- `lua/menu/vgui_base.lua` - Custom VGUI control wrappers (HL2Frame, HL2Button, etc.)
- `lua/menu/vgui_scheme.lua` - Scheme file parser and color/font management
- `lua/autorun/client/vgui_test_panel.lua` - Test panel and default skin option
- `resource/SourceScheme.res` - Source Engine color scheme
- `resource/ClientScheme.res` - Client-specific color overrides

### Color Scheme

The skin uses colors defined in `SourceScheme.res` and `ClientScheme.res` files, which are parsed by the `HL2Scheme` system. This ensures accurate replication of the Source Engine VGUI look.

### Customization

To customize colors, edit the resource scheme files or override them in your gamemode:

```lua
-- Override a color
HL2Scheme.Schemes["SourceScheme"].Colors["Button.TextColor"] = Color( 255, 0, 0, 255 )
```

## Source SDK Reference

This implementation is based on the Source SDK VGUI controls available at:
https://github.com/Source-SDK-Archives/source-sdk-orangebox/tree/master/vgui2/vgui_controls

## License

Part of the GMod_HL2ified project.
