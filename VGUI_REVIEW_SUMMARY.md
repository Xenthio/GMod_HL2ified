# VGUI Derma Skin - Comprehensive Source SDK Review Summary

## Overview
This document summarizes the comprehensive review pass of the HL2 VGUI derma skin implementation against the actual Source SDK C++ code and sourceschemebase.res.

## Paint Functions Implemented: 33

### Frame & Windows
1. **PaintFrame** - Rounded corners (FrameBorder backgroundtype 2), title bar with FrameTitleBar.BgColor
2. **PaintWindowCloseButton** - Marlett 'r' character
3. **PaintWindowMaximizeButton** - Marlett '1' character
4. **PaintWindowMinimizeButton** - Marlett '0' character

### Buttons
5. **PaintButton** - Left-aligned text (a_west), RaisedBorder/ButtonDepressedBorder
6. **PaintButtonUp** - Marlett 't' (up arrow) for scrollbars
7. **PaintButtonDown** - Marlett 'u' (down arrow) for scrollbars
8. **PaintButtonLeft** - Marlett '3' (left arrow) for scrollbars
9. **PaintButtonRight** - Marlett '4' (right arrow) for scrollbars

### Text Entry
10. **PaintTextEntry** - ButtonDepressedBorder style (inset borders)

### CheckBox
11. **PaintCheckBox** - Marlett 'g' (background), 'e'/'f' (border), 'b' (check)
    - Uses CheckButton.Border1 (Border.Dark) and Border2 (Border.Bright)

### ComboBox
12. **PaintComboBox** - DepressedBorder (ComboBoxBorder)
13. **PaintComboDownArrow** - Marlett 'u', positioned 3px from left (SetTextInset)

### Slider
14. **PaintSlider** - Track with DepressedBorder
15. **PaintSliderKnob** - Raised/depressed border on knob
16. **PaintNumSlider** - Container (minimal painting)

### ScrollBar
17. **PaintScrollBarGrip** - Uses ScrollBarSlider.FgColor for nob
18. **PaintVScrollBar** - Uses ScrollBarSlider.BgColor (255 255 255 64)
19. **PaintHScrollBar** - Uses ScrollBarSlider.BgColor (255 255 255 64)

### List
20. **PaintListView** - TransparentBlack background, DepressedBorder
21. **PaintListViewLine** - Orange selection (ListPanel.SelectedBgColor)

### Menu
22. **PaintMenuOption** - Orange armed background (Menu.ArmedBgColor)
23. **PaintMenu** - RaisedBorder (MenuBorder)
24. **PaintMenuRightArrow** - Marlett '4' for submenus
25. **PaintMenuSpacer** - Horizontal line separator

### Property Sheet
26. **PaintPropertySheet** - Generic background
27. **PaintTab** - Tab borders

### Generic
28. **PaintLabel** - OffWhite text color
29. **PaintPanel** - Blank/transparent (Panel.BgColor)
30. **PaintProgress** - White bar on TransparentBlack, DepressedBorder

### Utility
31. **PaintTooltip** - Orange background, dark border (ToolTipBorder)
32. **PaintNumberUp** - Marlett 't' for number widgets
33. **PaintNumberDown** - Marlett 'u' for number widgets

## Border Definitions (from sourceschemebase.res)

### RaisedBorder
- Top/Left: Border.Bright (200 200 200 196)
- Bottom/Right: Border.Dark (40 40 40 196)
- Used by: ButtonBorder, MenuBorder, PropertySheetBorder

### DepressedBorder
- Top/Left: Border.Dark (40 40 40 196)
- Bottom/Right: Border.Bright (200 200 200 196)
- Used by: BaseBorder, ComboBoxBorder, BrowserBorder, TextEntry

### ButtonDepressedBorder
- Inset: "2 1 1 1"
- Same colors as DepressedBorder

### ScrollBarButtonBorder
- Inset: "2 2 0 0"
- Same as RaisedBorder

### FrameBorder
- backgroundtype: "2" (rounded corners)

### ToolTipBorder
- All sides: Border.Dark

## Color Scheme Verification

All colors verified against sourceschemebase.res:

### Critical Color References
- **Border.Bright**: 200 200 200 196 (lit side of controls)
- **Border.Dark**: 40 40 40 196 (unlit side of controls)
- **Border.Selection**: 0 0 0 196 (default button border)
- **White**: 255 255 255 255
- **OffWhite**: 221 221 221 255
- **DullWhite**: 190 190 190 255
- **Orange**: 255 155 0 255 (selection color)
- **TransparentBlack**: 0 0 0 128
- **Black**: 0 0 0 255
- **Blank**: 0 0 0 0 (transparent)

### Button Colors
- TextColor: White
- BgColor: Blank
- ArmedTextColor: White
- ArmedBgColor: Blank
- DepressedTextColor: White
- DepressedBgColor: Blank

### CheckButton Colors
- TextColor: White
- BgColor: TransparentBlack
- Border1: Border.Dark
- Border2: Border.Bright
- Check: White
- DisabledBgColor: TransparentBlack

### ComboBox Colors
- ArrowColor: DullWhite
- ArmedArrowColor: White
- BgColor: Blank

### Frame Colors
- BgColor: 160 160 160 128
- OutOfFocusBgColor: 160 160 160 32
- TitleTextInsetX: 16

### FrameTitleBar Colors
- TextColor: White
- BgColor: Blank
- DisabledTextColor: 255 255 255 192
- DisabledBgColor: Blank

### ListPanel Colors
- TextColor: OffWhite
- BgColor: TransparentBlack
- SelectedTextColor: Black
- SelectedBgColor: Orange

### Menu Colors
- TextColor: White
- BgColor: 160 160 160 64
- ArmedTextColor: Black
- ArmedBgColor: Orange

### ProgressBar Colors
- FgColor: White
- BgColor: TransparentBlack

### ScrollBar Colors
- ScrollBarButton.FgColor: White
- ScrollBarButton.BgColor: Blank
- ScrollBarSlider.FgColor: Blank (nob color)
- ScrollBarSlider.BgColor: 255 255 255 64 (track background)

### Slider Colors
- NobColor: 108 108 108 255
- TextColor: 180 180 180 255
- TrackColor: 31 31 31 255

### TextEntry Colors
- TextColor: OffWhite
- BgColor: TransparentBlack
- CursorColor: OffWhite
- DisabledTextColor: DullWhite
- DisabledBgColor: Blank
- SelectedTextColor: Black
- SelectedBgColor: Orange

### Tooltip Colors
- TextColor: 0 0 0 196 (dark text)
- BgColor: Orange

## Marlett Font Character Reference

The Marlett font is used extensively for icons and symbols:

- **'r'** - Close/X button
- **'1'** - Maximize button
- **'0'** - Minimize button (underscore)
- **'t'** - Up arrow
- **'u'** - Down arrow
- **'3'** - Left arrow
- **'4'** - Right arrow
- **'g'** - Checkbox background box
- **'e'** - Checkbox border (part 1)
- **'f'** - Checkbox border (part 2)
- **'b'** - Checkmark

## Source SDK File References

Implementation verified against:
- `vgui2/vgui_controls/button.cpp`
- `vgui2/vgui_controls/checkbutton.cpp`
- `vgui2/vgui_controls/combobox.cpp`
- `vgui2/vgui_controls/frame.cpp`
- `vgui2/vgui_controls/menu.cpp`
- `vgui2/vgui_controls/scrollbar.cpp`
- `vgui2/vgui_controls/slider.cpp`
- `vgui2/vgui_controls/textentry.cpp`
- `vgui2/vgui_controls/listpanel.cpp`
- `resource/sourceschemebase.res`

## Implementation Notes

### Button Alignment
Buttons are left-aligned by default (a_west) as per Source SDK, matching `SetContentAlignment(Label::a_west)`.

### CheckBox Rendering
Uses Marlett font exactly as Source SDK CheckImage class:
- Position (0, 1) for background and borders
- Position (0, 2) for checkmark
- Border uses two colors (Border1 and Border2) for two-tone effect

### ComboBox Button
Arrow positioned 3 pixels from left edge per `SetTextInset(3, 0)` in Source SDK.

### Frame Title Bar
- Default inset: 5 pixels
- Caption height: 28 pixels (14 for small caption)
- Title text X inset: 16 pixels (from Frame.TitleTextInsetX)
- Title text Y inset: 9 pixels (2 for small caption)

### Scroll Bar Buttons
All use Marlett font with appropriate arrow characters, matching Source SDK ScrollBarButton class.

## GLuaFixer Compliance
All code passes GLuaFixer 1.29.0 with zero warnings or errors.

## Test Coverage
Test panel created at `lua/autorun/client/vgui_test_panel.lua` with command `vgui_test` to demonstrate all styled controls.

## Default Skin Option
ConVar `hl2_derma_skin` (0/1) allows setting HL2 as the default skin for all Derma controls.
Command `hl2_toggle_derma_skin` toggles the setting.
