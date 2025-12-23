if ( SERVER ) then return end

-- ---------------------------------------------------------
-- HL2Frame
-- ---------------------------------------------------------
local PANEL = {}

function PANEL:Init()
    -- Call DFrame's Init directly to avoid recursion when subclassed
    -- Only call if not already initialized (prevents duplicate controls)
    if ( !self.btnClose ) then
        local base = vgui.GetControlTable( "DFrame" )
        if ( base and base.Init ) then base.Init( self ) end
    end

    self:SetSkin( "HL2" )
    self:SetTitle( "" )
    self:ShowCloseButton( true )
    self:SetDraggable( true )

    -- Hide DFrame's default title label (we draw it manually in the skin)
    if ( self.lblTitle ) then
        self.lblTitle:SetVisible( false )
    end

    -- Setup Close Button (DFrame creates it)
    if ( self.btnClose ) then
        self.btnClose:SetText( "" )
        self.btnClose:SetSkin( "HL2" )
        self.btnClose:SetSize( 18, 18 )
        self.btnClose.Paint = function( s, w, h )
            local skin = s:GetSkin()
            if ( skin and skin.PaintWindowCloseButton ) then
                skin:PaintWindowCloseButton( s, w, h )
            end
        end
    end

    -- Ensure Min/Max exist
    if ( !self.btnMinim ) then self.btnMinim = vgui.Create( "DButton", self ) end
    if ( !self.btnMaxim ) then self.btnMaxim = vgui.Create( "DButton", self ) end

    -- Setup Minimize Button
    self.btnMinim:SetText( "" )
    self.btnMinim:SetSkin( "HL2" )
    self.btnMinim:SetSize( 18, 18 )
    self.btnMinim.Paint = function( s, w, h )
        local skin = s:GetSkin()
        if ( skin and skin.PaintWindowMinimizeButton ) then
            skin:PaintWindowMinimizeButton( s, w, h )
        end
    end

    -- Setup Maximize Button
    self.btnMaxim:SetText( "" )
    self.btnMaxim:SetSkin( "HL2" )
    self.btnMaxim:SetSize( 18, 18 )
    self.btnMaxim.Paint = function( s, w, h )
        local skin = s:GetSkin()
        if ( skin and skin.PaintWindowMaximizeButton ) then
            skin:PaintWindowMaximizeButton( s, w, h )
        end
    end

    -- Default visibility (HL2 usually doesn't show them, but we port them)
    self.btnMinim:SetVisible( true )
    self.btnMaxim:SetVisible( true )

    self.FocusWeight = 1
    self.Closing = false
    self.LastVisible = false
    self:SetAlpha( 0 )

    self:InvalidateLayout( true )
end

function PANEL:PerformLayout()
    local w = self:GetWide()
    local x = w - 25 -- Start position for Close button
    local y = 8

    if ( self.btnClose and self.btnClose:IsVisible() ) then
        self.btnClose:SetPos( x, y )
        self.btnClose:SetSize( 18, 18 )
        x = x - 18 - 2
    end

    if ( self.btnMaxim and self.btnMaxim:IsVisible() ) then
        self.btnMaxim:SetPos( x, y )
        self.btnMaxim:SetSize( 18, 18 )
        x = x - 18 - 2
    end

    if ( self.btnMinim and self.btnMinim:IsVisible() ) then
        self.btnMinim:SetPos( x, y )
        self.btnMinim:SetSize( 18, 18 )
    end
end

function PANEL:SetMinimizeEnabled( b )
    if ( self.btnMinim ) then self.btnMinim:SetVisible( b ) end
end

function PANEL:SetMaximizeEnabled( b )
    if ( self.btnMaxim ) then self.btnMaxim:SetVisible( b ) end
end

function PANEL:Think()
    local dframe = vgui.GetControlTable( "DFrame" )
    if ( dframe and dframe.Think ) then
        dframe.Think( self )
    end

    -- HL2 doesn't use the sizeall cursor for moving windows
    -- Override cursor after parent Think runs
    if ( !self.Sizing and !self.Dragging ) then
        self:SetCursor( "arrow" )
    end

    -- Force layout if not done (fix for buttons at 0,0)
    if ( !self.LayoutDone ) then
        self:PerformLayout()
        self.LayoutDone = true
    end

    -- Detect visibility change (Open)
    if ( self:IsVisible() != self.LastVisible ) then
        if ( self:IsVisible() ) then
            self:SetAlpha( 0 )
            self.Closing = false
        end
        self.LastVisible = self:IsVisible()
    end

    -- Handle Focus Transition
    local focusTime = tonumber( HL2Scheme.GetResourceString( "Frame.FocusTransitionEffectTime", nil, "SourceScheme" ) ) or 0.3
    local targetWeight = self:IsActive() and 1 or 0

    if ( self.FocusWeight != targetWeight ) then
        self.FocusWeight = math.Approach( self.FocusWeight, targetWeight, (1 / focusTime) * FrameTime() )
    end

    -- Handle Visibility Fade
    local transitionTime = tonumber( HL2Scheme.GetResourceString( "Frame.TransitionEffectTime", nil, "SourceScheme" ) ) or 0.3

    if ( self.Closing ) then
        local alpha = self:GetAlpha()
        alpha = math.Approach( alpha, 0, (255 / transitionTime) * FrameTime() )
        self:SetAlpha( alpha )

        if ( alpha == 0 ) then
            self.Closing = false
            self:SetVisible( false )
            if ( self:GetDeleteOnClose() ) then self:Remove() end
        end
    elseif ( self:IsVisible() and self:GetAlpha() < 255 ) then
        local alpha = self:GetAlpha()
        alpha = math.Approach( alpha, 255, (255 / transitionTime) * FrameTime() )
        self:SetAlpha( alpha )
    end
end

function PANEL:Close()
    self.Closing = true
end

function PANEL:SetTitleText( str )
    self:SetTitle( str )
end

vgui.Register( "HL2Frame", PANEL, "DFrame" )

-- ---------------------------------------------------------
-- HL2Button
-- ---------------------------------------------------------
local BUTTON = {}

function BUTTON:Init()
    self:SetSkin( "HL2" )
    self:SetFont( HL2Scheme.GetFont( "Default", "Default", "SourceScheme" ) ) -- Default font from scheme
    self:SetText( "" )
    self:SetCursor( "arrow" ) -- Don't change cursor to hand
    self:SetTextInset( 6, 0 ) -- Match Source Button.cpp
end

vgui.Register( "HL2Button", BUTTON, "DButton" )

-- ---------------------------------------------------------
-- HL2TextEntry
-- ---------------------------------------------------------
local TEXTENTRY = {}

function TEXTENTRY:Init()
    self:SetSkin( "HL2" )
    self:SetFont( HL2Scheme.GetFont( "Default", "Default", "SourceScheme" ) )
    self:SetCursor( "beam" )
    self:SetTextInset( 4, 0 )
end

function TEXTENTRY:Paint( w, h )
    local skin = self:GetSkin()
    if ( skin and skin.PaintTextEntry ) then
        skin:PaintTextEntry( self, w, h )
    end

    -- Let base draw the text
    derma.SkinHook( "Paint", "TextEntry", self, w, h )
    return false
end

vgui.Register( "HL2TextEntry", TEXTENTRY, "DTextEntry" )

-- ---------------------------------------------------------
-- HL2CheckBox
-- ---------------------------------------------------------
local CHECKBOX = {}

function CHECKBOX:Init()
    self:SetSkin( "HL2" )
    self:SetSize( 16, 16 )
end

function CHECKBOX:Paint( w, h )
    local skin = self:GetSkin()
    if ( skin and skin.PaintCheckBox ) then
        skin:PaintCheckBox( self, w, h )
    end
    return true
end

vgui.Register( "HL2CheckBox", CHECKBOX, "DCheckBox" )

-- ---------------------------------------------------------
-- HL2ComboBox
-- ---------------------------------------------------------
local COMBOBOX = {}

function COMBOBOX:Init()
    self:SetSkin( "HL2" )
    self:SetFont( HL2Scheme.GetFont( "Default", "Default", "SourceScheme" ) )
    self:SetTextColor( HL2Scheme.GetColor( "TextEntry.TextColor", Color( 221, 221, 221, 255 ), "SourceScheme" ) )
    self:SetFGColor( HL2Scheme.GetColor( "TextEntry.TextColor", Color( 221, 221, 221, 255 ), "SourceScheme" ) )

    -- Override the menu to use HL2 skin
    local oldOpenMenu = self.OpenMenu
    self.OpenMenu = function( s, ... )
        local ret = oldOpenMenu( s, ... )
        if ( IsValid( s.Menu ) ) then
            s.Menu:SetSkin( "HL2" )
        end
        return ret
    end
end

function COMBOBOX:Paint( w, h )
    local skin = self:GetSkin()
    if ( skin and skin.PaintComboBox ) then
        skin:PaintComboBox( self, w, h )
    end
    return true
end

vgui.Register( "HL2ComboBox", COMBOBOX, "DComboBox" )

-- ---------------------------------------------------------
-- HL2Slider
-- ---------------------------------------------------------
local SLIDER = {}

function SLIDER:Init()
    self:SetSkin( "HL2" )
end

function SLIDER:Paint( w, h )
    local skin = self:GetSkin()
    if ( skin and skin.PaintSlider ) then
        skin:PaintSlider( self, w, h )
    end
    return false
end

vgui.Register( "HL2Slider", SLIDER, "DSlider" )

-- ---------------------------------------------------------
-- HL2Label
-- ---------------------------------------------------------
local LABEL = {}

function LABEL:Init()
    self:SetSkin( "HL2" )
    self:SetFont( HL2Scheme.GetFont( "Default", "Default", "SourceScheme" ) )
    self:SetTextColor( HL2Scheme.GetColor( "Label.TextColor", Color( 200, 200, 200, 255 ), "SourceScheme" ) )
end

vgui.Register( "HL2Label", LABEL, "DLabel" )

-- ---------------------------------------------------------
-- HL2Panel
-- ---------------------------------------------------------
local PANELBASE = {}

function PANELBASE:Init()
    self:SetSkin( "HL2" )
end

function PANELBASE:Paint( w, h )
    if ( self.m_bPaintBackground ) then
        local skin = self:GetSkin()
        if ( skin and skin.PaintPanel ) then
            skin:PaintPanel( self, w, h )
        end
    end
end

vgui.Register( "HL2Panel", PANELBASE, "DPanel" )

-- ---------------------------------------------------------
-- HL2ListView
-- ---------------------------------------------------------
local LISTVIEW = {}

function LISTVIEW:Init()
    self:SetSkin( "HL2" )
end

function LISTVIEW:Paint( w, h )
    local skin = self:GetSkin()
    if ( skin and skin.PaintListView ) then
        skin:PaintListView( self, w, h )
    end
    return false
end

vgui.Register( "HL2ListView", LISTVIEW, "DListView" )

-- ---------------------------------------------------------
-- HL2NumSlider
-- ---------------------------------------------------------
local NUMSLIDER = {}

function NUMSLIDER:Init()
    self:SetSkin( "HL2" )
end

function NUMSLIDER:PerformLayout()
    -- Make sure the internal slider uses HL2 skin and paints the track
    if self.Slider and self.Slider:IsValid() then
        self.Slider:SetSkin( "HL2" )
        self.Slider.Paint = function(pnl, w, h)
            local skin = pnl:GetSkin()
            if skin and skin.PaintSlider then
                skin:PaintSlider(pnl, w, h)
            end
            return false
        end
    end
end

vgui.Register( "HL2NumSlider", NUMSLIDER, "DNumSlider" )
