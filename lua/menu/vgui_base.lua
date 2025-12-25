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
    
    -- Set text colors explicitly so they're visible
    self:SetTextColor( HL2Scheme.GetColor( "TextEntry.TextColor", Color( 221, 221, 221, 255 ), "SourceScheme" ) )
    self:SetCursorColor( HL2Scheme.GetColor( "TextEntry.CursorColor", Color( 221, 221, 221, 255 ), "SourceScheme" ) )
    self:SetHighlightColor( HL2Scheme.GetColor( "TextEntry.SelectedBgColor", Color( 255, 155, 0, 255 ), "SourceScheme" ) )
end

function TEXTENTRY:Paint( w, h )
    local skin = self:GetSkin()
    if ( skin and skin.PaintTextEntry ) then
        skin:PaintTextEntry( self, w, h )
    end

    -- Let base draw the text
    derma.SkinHook( "Paint", "TextEntry", self, w, h )
    return true -- Return true to let DTextEntry draw the text content
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

    -- Override the menu to use HL2 skin and set option colors
    local oldOpenMenu = self.OpenMenu
    self.OpenMenu = function( s, ... )
        local ret = oldOpenMenu( s, ... )
        if ( IsValid( s.Menu ) ) then
            s.Menu:SetSkin( "HL2" )
            -- Set font for menu options
            for _, child in ipairs( s.Menu:GetChildren() ) do
                if ( child.SetFont ) then
                    child:SetFont( HL2Scheme.GetFont( "Default", "Default", "SourceScheme" ) )
                end
            end
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

-- ---------------------------------------------------------
-- HL2Tab - Custom tab for HL2PropertySheet
-- Matches Source SDK tab behavior
-- ---------------------------------------------------------
local TAB = {}

AccessorFunc( TAB, "m_pPropertySheet", "PropertySheet" )
AccessorFunc( TAB, "m_pPanel", "Panel" )

function TAB:Init()
    self:SetMouseInputEnabled( true )
    self:SetContentAlignment( 7 )
    self:SetTextInset( 10, 4 )
    self:SetSkin( "HL2" )
end

function TAB:Paint(w, h)
    -- Use skin's PaintTab function
    derma.SkinHook( "Paint", "Tab", self, w, h )
    return false  -- Don't call base paint
end

function TAB:Setup( label, pPropertySheet, pPanel, strMaterial )
    self:SetText( label )
    self:SetPropertySheet( pPropertySheet )
    self:SetPanel( pPanel )

    if ( strMaterial ) then
        self.Image = vgui.Create( "DImage", self )
        self.Image:SetImage( strMaterial )
        self.Image:SizeToContents()
        self:InvalidateLayout()
    end
end

function TAB:IsActive()
    local sheet = self:GetPropertySheet()
    if not IsValid(sheet) then return false end
    return sheet:GetActiveTab() == self
end

function TAB:DoClick()
    local sheet = self:GetPropertySheet()
    if not IsValid(sheet) then return end
    sheet:SetActiveTab( self )
end

function TAB:PerformLayout()
    self:ApplySchemeSettings()

    if ( self.Image ) then
        self.Image:SetPos( 7, 3 )

        if ( !self:IsActive() ) then
            self.Image:SetImageColor( Color( 255, 255, 255, 155 ) )
        else
            self.Image:SetImageColor( color_white )
        end
    end
end

function TAB:GetTabHeight()
    -- Source SDK: active tab is taller
    -- Active: y=2, height=tabHeight (28)
    -- Inactive: y=4, height=tabHeight-2 (26)
    if ( self:IsActive() ) then
        return 28
    else
        return 26
    end
end

function TAB:ApplySchemeSettings()
    local ExtraInset = 10

    if ( self.Image ) then
        ExtraInset = ExtraInset + self.Image:GetWide()
    end

    self:SetTextInset( ExtraInset, 4 )
    local w, h = self:GetContentSize()
    h = self:GetTabHeight()

    self:SetSize( w + 10, h )
    
    -- Apply font from SourceScheme (Source SDK uses "Default" font for tabs)
    if HL2Scheme then
        local tabFont = HL2Scheme.GetFont("Default", "DermaDefault", "SourceScheme")
        if tabFont then
            self:SetFont(tabFont)
        end
    end
end

function TAB:DoRightClick()
    if ( !IsValid( self:GetPropertySheet() ) ) then return end

    local tabs = DermaMenu()
    for k, v in pairs( self:GetPropertySheet().Items ) do
        if ( !v || !IsValid( v.Tab ) || !v.Tab:IsVisible() ) then continue end
        local option = tabs:AddOption( v.Tab:GetText(), function()
            if ( !v || !IsValid( v.Tab ) || !IsValid( self:GetPropertySheet() ) ) then return end
            v.Tab:DoClick()
        end )
        if ( IsValid( v.Tab.Image ) ) then option:SetIcon( v.Tab.Image:GetImage() ) end
    end
    tabs:Open()
end

vgui.Register( "HL2Tab", TAB, "DButton" )

-- ---------------------------------------------------------
-- HL2PropertySheet - Custom PropertySheet for HL2 skin
-- Matches Source SDK PropertySheet layout
-- ---------------------------------------------------------
local PROPSHEET = {}

AccessorFunc( PROPSHEET, "m_pActiveTab", "ActiveTab" )
AccessorFunc( PROPSHEET, "m_iPadding", "Padding" )
AccessorFunc( PROPSHEET, "m_fFadeTime", "FadeTime" )
AccessorFunc( PROPSHEET, "m_bShowIcons", "ShowIcons" )

function PROPSHEET:Init()
    self:SetSkin( "HL2" )
    self:SetShowIcons( true )

    -- Create a container for tabs instead of DHorizontalScroller
    self.tabContainer = vgui.Create( "DPanel", self )
    self.tabContainer:SetPaintBackground( false )
    self.tabContainer:Dock( TOP )
    self.tabContainer:SetTall( 30 )  -- Increased to accommodate inactive tabs at y=4 with height 26
    -- Source SDK uses m_iTabXIndent for left indent (default 0 or small value)
    -- No margin - tabs should be flush with left edge
    self.tabContainer:DockMargin( 0, 0, 0, 0 )

    self:SetFadeTime( 0.1 )
    self:SetPadding( 8 )

    self.animFade = Derma_Anim( "Fade", self, self.CrossFade )

    self.Items = {}
end

function PROPSHEET:Paint(w, h)
    -- Use skin's PaintPropertySheet function to draw borders
    derma.SkinHook( "Paint", "PropertySheet", self, w, h )
    return true  -- Allow base painting if needed
end

function PROPSHEET:AddSheet( label, panel, material, NoStretchX, NoStretchY, Tooltip )
    if ( !IsValid( panel ) ) then
        ErrorNoHalt( "HL2PropertySheet:AddSheet tried to add invalid panel!" )
        debug.Trace()
        return
    end

    local Sheet = {}
    Sheet.Name = label

    Sheet.Tab = vgui.Create( "HL2Tab", self.tabContainer )
    Sheet.Tab:SetTooltip( Tooltip )
    Sheet.Tab:Setup( label, self, panel, material )

    Sheet.Panel = panel
    Sheet.Panel.NoStretchX = NoStretchX
    Sheet.Panel.NoStretchY = NoStretchY
    Sheet.Panel:SetPos( self:GetPadding(), 30 + self:GetPadding() )
    Sheet.Panel:SetVisible( false )

    panel:SetParent( self )

    table.insert( self.Items, Sheet )

    -- Layout tabs manually to match Source SDK
    self:LayoutTabs()

    if ( !self:GetActiveTab() ) then
        self:SetActiveTab( Sheet.Tab )
        Sheet.Panel:SetVisible( true )
    end

    return Sheet
end

function PROPSHEET:LayoutTabs()
    -- Source SDK: xtab starts at m_iTabXIndent, then xtab += (width + 1)
    local xtab = 0  -- Start at left edge like Source SDK (m_iTabXIndent typically 0)
    
    for k, v in pairs( self.Items ) do
        if ( !IsValid( v.Tab ) ) then continue end
        
        local w, h = v.Tab:GetSize()
        local isActive = v.Tab:IsActive()
        
        -- Source SDK positioning:
        -- Active tab: SetBounds(xtab, 2, width, tabHeight)
        -- Inactive tab: SetBounds(xtab, 4, width, tabHeight - 2)
        if isActive then
            v.Tab:SetPos( xtab, 2 )
            v.Tab:SetTall( 28 )
        else
            v.Tab:SetPos( xtab, 4 )
            v.Tab:SetTall( 26 )
        end
        
        -- Source SDK: xtab += (width + 1) - 1px gap between tabs
        xtab = xtab + w + 1
    end
end

function PROPSHEET:SetActiveTab( active )
    if ( self.m_pActiveTab == active ) then return end

    -- Find the old sheet
    local oldSheet = nil
    if ( self.m_pActiveTab ) then
        for k, v in pairs( self.Items ) do
            if ( v.Tab == self.m_pActiveTab ) then
                oldSheet = v
                break
            end
        end
    end

    -- Hide old panel
    if ( oldSheet and IsValid( oldSheet.Panel ) ) then
        oldSheet.Panel:SetVisible( false )
    end

    self.m_pActiveTab = active

    -- Find the new sheet
    local newSheet = nil
    for k, v in pairs( self.Items ) do
        if ( v.Tab == active ) then
            newSheet = v
            break
        end
    end

    -- Show new panel
    if ( newSheet and IsValid( newSheet.Panel ) ) then
        newSheet.Panel:SetVisible( true )
        newSheet.Panel:SetPos( self:GetPadding(), 30 + self:GetPadding() )
        newSheet.Panel:InvalidateLayout( true )
    end

    -- Re-layout tabs when active tab changes
    self:LayoutTabs()
    self:InvalidateLayout()

    self.animFade:Start( self:GetFadeTime(), { OldTab = oldSheet, NewTab = newSheet } )
end

function PROPSHEET:PerformLayout()
    local ActiveTab = self:GetActiveTab()
    if ( !ActiveTab ) then return end
    
    -- Find the sheet for the active tab
    local ActiveSheet = nil
    for k, v in pairs( self.Items ) do
        if ( v.Tab == ActiveTab ) then
            ActiveSheet = v
            break
        end
    end
    
    if ( !ActiveSheet || !IsValid( ActiveSheet.Panel ) ) then return end

    -- Re-layout tabs to ensure positioning is correct
    self:LayoutTabs()

    local ActivePanel = ActiveSheet.Panel
    ActivePanel:SetPos( self:GetPadding(), 30 + self:GetPadding() )

    if ( ActivePanel.NoStretchX ) then
        ActivePanel:SetWide( ActivePanel:GetWide() )
    else
        ActivePanel:SetWide( self:GetWide() - self:GetPadding() * 2 )
    end

    if ( ActivePanel.NoStretchY ) then
        ActivePanel:SetTall( ActivePanel:GetTall() )
    else
        ActivePanel:SetTall( self:GetTall() - 30 - self:GetPadding() * 2 )
    end

    ActivePanel:InvalidateLayout()
end

function PROPSHEET:CrossFade( anim, delta, data )
    local oldSheet = data.OldTab
    local newSheet = data.NewTab

    if ( !oldSheet || !IsValid( oldSheet.Panel ) ) then return end
    if ( !newSheet || !IsValid( newSheet.Panel ) ) then return end

    oldSheet.Panel:SetAlpha( 255 - (255 * delta) )
    newSheet.Panel:SetAlpha( 255 * delta )
end

function PROPSHEET:SizeToContents()
    local wide, tall = self:GetSize()
    local y = 30 + self:GetPadding()

    for k, v in pairs( self.Items ) do
        if ( IsValid( v.Panel ) ) then
            v.Panel:InvalidateLayout( true )
            tall = math.max( tall, y + v.Panel:GetTall() + self:GetPadding() )
        end
    end

    self:SetSize( wide, tall )
end

vgui.Register( "HL2PropertySheet", PROPSHEET, "DPanel" )

-- ---------------------------------------------------------
-- Panel Replacement System
-- Replaces default VGUI panels with HL2 versions when enabled
-- ---------------------------------------------------------

-- Table mapping default panels to their HL2 equivalents
local panelReplacements = {
    ["DPropertySheet"] = "HL2PropertySheet",
    ["DTab"] = "HL2Tab",
}

-- Store original vgui.Create
local originalVguiCreate = vgui.Create

-- Global flag to track if replacements are active
_HL2_PANEL_REPLACEMENTS_ACTIVE = false

-- Function to enable panel replacements
function HL2_EnablePanelReplacements()
    if _HL2_PANEL_REPLACEMENTS_ACTIVE then return end
    
    vgui.Create = function(className, parent, name)
        -- Check if we have a replacement for this panel
        local replacement = panelReplacements[className]
        if replacement then
            -- Create the HL2 version instead
            return originalVguiCreate(replacement, parent, name)
        end
        
        -- No replacement, use original
        return originalVguiCreate(className, parent, name)
    end
    
    _HL2_PANEL_REPLACEMENTS_ACTIVE = true
    print("[HL2ified] Panel replacements enabled (DPropertySheet -> HL2PropertySheet, etc.)")
end

-- Function to disable panel replacements
function HL2_DisablePanelReplacements()
    if not _HL2_PANEL_REPLACEMENTS_ACTIVE then return end
    
    vgui.Create = originalVguiCreate
    _HL2_PANEL_REPLACEMENTS_ACTIVE = false
    print("[HL2ified] Panel replacements disabled")
end
