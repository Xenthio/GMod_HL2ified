local surface = surface
local Color = Color

local SKIN = {}

SKIN.PrintName = "Half-Life 2"
SKIN.Author = "Copilot"
SKIN.DermaVersion = 1

-- Colors
SKIN.bg_color = Color( 60, 60, 60, 255 )
SKIN.bg_color_sleep = Color( 50, 50, 50, 255 )
SKIN.bg_color_dark = Color( 40, 40, 40, 255 )
SKIN.bg_color_bright = Color( 80, 80, 80, 255 )
SKIN.frame_border = Color( 100, 100, 100, 255 )

-- Fonts
if ( HL2Scheme ) then
    SKIN.fontFrame = HL2Scheme.GetFont( "UiBold", "DefaultBold", "SourceScheme" )
else
    SKIN.fontFrame = "DefaultBold"
end

SKIN.control_color = Color( 120, 120, 120, 255 )
SKIN.control_color_highlight = Color( 150, 150, 150, 255 )
SKIN.control_color_active = Color( 110, 150, 250, 255 )
SKIN.control_color_bright = Color( 255, 200, 100, 255 )
SKIN.control_color_dark = Color( 100, 100, 100, 255 )

SKIN.bg_alt1 = Color( 50, 50, 50, 255 )
SKIN.bg_alt2 = Color( 55, 55, 55, 255 )

SKIN.listview_hover = Color( 70, 70, 70, 255 )
SKIN.listview_selected = Color( 100, 170, 220, 255 )

SKIN.text_bright = Color( 255, 255, 255, 255 )
SKIN.text_normal = Color( 180, 180, 180, 255 )
SKIN.text_dark = Color( 20, 20, 20, 255 )
SKIN.text_highlight = Color( 255, 20, 20, 255 )

SKIN.texGradientUp = Material( "gui/gradient_up" )
SKIN.texGradientDown = Material( "gui/gradient_down" )

SKIN.combobox_selected = SKIN.listview_selected

SKIN.panel_transback = Color( 255, 255, 255, 50 )
SKIN.tooltip = Color( 255, 245, 175, 255 )

SKIN.colPropertySheet = Color( 170, 170, 170, 255 )
SKIN.colTab = SKIN.colPropertySheet
SKIN.colTabInactive = Color( 140, 140, 140, 255 )
SKIN.colTabShadow = Color( 0, 0, 0, 170 )
SKIN.colTabText = Color( 255, 255, 255, 255 )
SKIN.colTabTextInactive = Color( 0, 0, 0, 200 )
SKIN.fontTab = "DermaDefault"

SKIN.colCollapsibleCategory = Color( 255, 255, 255, 20 )

SKIN.colCategoryText = Color( 255, 255, 255, 255 )
SKIN.colCategoryTextInactive = Color( 200, 200, 200, 255 )
SKIN.fontCategoryHeader = "TabLarge"

SKIN.colNumberWangBG = Color( 255, 240, 150, 255 )
SKIN.colTextEntryBG = Color( 240, 240, 240, 255 )
SKIN.colTextEntryBorder = Color( 20, 20, 20, 255 )
SKIN.colTextEntryText = Color( 20, 20, 20, 255 )
SKIN.colTextEntryTextHighlight = Color( 20, 200, 250, 255 )
SKIN.colTextEntryTextCursor = Color( 0, 0, 100, 255 )
SKIN.colTextEntryTextPlaceholder = Color( 128, 128, 128, 255 )

SKIN.colNumSliderNotch = Color( 0, 0, 0, 100 )

SKIN.colMenuBG = Color( 255, 255, 255, 200 )
SKIN.colMenuBorder = Color( 0, 0, 0, 200 )

SKIN.colButtonText = Color( 255, 255, 255, 255 )
SKIN.colButtonTextDisabled = Color( 255, 255, 255, 55 )
SKIN.colButtonBorder = Color( 20, 20, 20, 255 )
SKIN.colButtonBorderHighlight = Color( 255, 255, 255, 50 )
SKIN.colButtonBorderShadow = Color( 0, 0, 0, 100 )

function SKIN:PaintFrame( panel, w, h )
    if ( !HL2Scheme ) then return end

    -- Background
    local activeCol = HL2Scheme.GetColor( "Frame.BgColor", Color( 0, 0, 0, 196 ), "SourceScheme" )
    local inactiveCol = HL2Scheme.GetColor( "Frame.OutOfFocusBgColor", Color( 160, 160, 160, 32 ), "SourceScheme" )
    
    local focusWeight = panel.FocusWeight or (panel:IsActive() and 1 or 0)
    
    -- Interpolate based on FocusWeight
    local r = Lerp( focusWeight, inactiveCol.r, activeCol.r )
    local g = Lerp( focusWeight, inactiveCol.g, activeCol.g )
    local b = Lerp( focusWeight, inactiveCol.b, activeCol.b )
    local a = Lerp( focusWeight, inactiveCol.a, activeCol.a )
    
    local bgColor = Color( r, g, b, a )

    draw.RoundedBox( 8, 0, 0, w, h, bgColor )
    
    -- Border
    local borderColor = HL2Scheme.GetColor( "Frame.AutoSelectionBoxColor", Color( 255, 255, 255, 20 ), "SourceScheme" )
    local bright = HL2Scheme.GetColor( "Border.Bright", nil, "SourceScheme" )
    if ( bright ) then borderColor = bright end
    
    -- Title
    if ( panel.GetTitle ) then
        local title = panel:GetTitle()
        if ( title and title != "" ) then
            local font = HL2Scheme.GetFont( "UiBold", "DefaultBold", "SourceScheme" )
            surface.SetFont( font )
            surface.SetTextColor( HL2Scheme.GetColor( "FrameTitleBar.TextColor", Color( 255, 255, 255 ), "SourceScheme" ) )
            
            -- Source uses 28, 9 for title inset
            -- User requested it to be less far right
            surface.SetTextPos( 15, 9 ) 
            surface.DrawText( title )
        end
    end
end

function SKIN:PaintButton( panel, w, h )
    if ( !HL2Scheme ) then return end

    local isDown = panel:IsDown()
    local isHovered = panel:IsHovered()
    local isDisabled = !panel:IsEnabled()
    
    -- Colors
    local textColor = HL2Scheme.GetColor( "Button.TextColor", Color( 255, 255, 255 ), "SourceScheme" )
    local bgColor = HL2Scheme.GetColor( "Button.BgColor", Color( 0, 0, 0, 0 ), "SourceScheme" )
    
    -- Borders
    local colLight = HL2Scheme.GetColor( "Border.Bright", Color( 255, 255, 255, 100 ), "SourceScheme" )
    local colDark = HL2Scheme.GetColor( "Border.Dark", Color( 0, 0, 0, 100 ), "SourceScheme" )
    
    if ( isDisabled ) then
        textColor = HL2Scheme.GetColor( "Button.DisabledTextColor", Color( 100, 100, 100 ), "SourceScheme" )
    elseif ( isDown ) then
        textColor = HL2Scheme.GetColor( "Button.DepressedTextColor", textColor, "SourceScheme" )
        bgColor = HL2Scheme.GetColor( "Button.DepressedBgColor", Color( 0, 0, 0, 200 ), "SourceScheme" )
        
        surface.SetDrawColor( bgColor )
        surface.DrawRect( 0, 0, w, h )
        
        surface.SetDrawColor( colDark )
        surface.DrawLine( 0, 0, w-1, 0 ) -- Top
        surface.DrawLine( 0, 0, 0, h-1 ) -- Left
        
        surface.SetDrawColor( colLight )
        surface.DrawLine( w-1, 0, w-1, h-1 ) -- Right
        surface.DrawLine( 0, h-1, w-1, h-1 ) -- Bottom
        
    elseif ( isHovered and false ) then -- Hover disabled in HL2Button
        -- ...
    else
        surface.SetDrawColor( bgColor )
        surface.DrawRect( 0, 0, w, h )
        
        surface.SetDrawColor( colLight )
        surface.DrawLine( 0, 0, w-1, 0 )
        surface.DrawLine( 0, 0, 0, h-1 )
        
        surface.SetDrawColor( colDark )
        surface.DrawLine( w-1, 0, w-1, h-1 )
        surface.DrawLine( 0, h-1, w-1, h-1 )
    end
    
    panel:SetTextColor( textColor )
end

derma.DefineSkin( "HL2", "Half-Life 2 VGUI Skin", SKIN )
