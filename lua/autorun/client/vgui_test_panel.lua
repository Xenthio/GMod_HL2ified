-- VGUI Test Panel for HL2 Derma Skin
-- This panel demonstrates all the styled VGUI controls

if ( SERVER ) then return end

-- Load the necessary files
include( "menu/vgui_scheme.lua" )
include( "skins/hl2.lua" )
include( "menu/vgui_base.lua" )

-- ConVar to enable HL2 skin as default
CreateClientConVar( "hl2_derma_skin", "0", true, false, "Use HL2 VGUI skin as default for all derma controls (0 = off, 1 = on)" )

-- WARNING: This feature overrides vgui.Register globally, which could cause conflicts with other addons
-- that register VGUI panels after this file loads. The override is persistent until Lua is reloaded.
-- For maximum compatibility, avoid enabling this feature if you experience issues with other addons.

-- Store the original vgui.Register function
local originalVguiRegister = vgui.Register
local isHL2SkinApplied = false

-- Apply or remove HL2 skin as default based on ConVar
local function ApplyDefaultSkin()
    local shouldApply = GetConVar( "hl2_derma_skin" ):GetBool()
    
    if shouldApply and not isHL2SkinApplied then
        -- Override vgui.Register to apply HL2 skin to new panels
        vgui.Register = function( name, tbl, base )
            originalVguiRegister( name, tbl, base )

            -- Hook into panel creation to set HL2 skin
            if ( tbl and !tbl.HL2SkinApplied ) then
                local oldInit = tbl.Init
                tbl.Init = function( self )
                    if ( oldInit ) then oldInit( self ) end

                    -- Apply HL2 skin to standard derma controls
                    if ( self:GetSkin() and self:GetSkin().Name == "Default" ) then
                        self:SetSkin( "HL2" )
                    end
                end
                tbl.HL2SkinApplied = true
            end
        end
        
        isHL2SkinApplied = true
        print( "[HL2ified] HL2 Derma skin is now the default skin!" )
        
    elseif not shouldApply and isHL2SkinApplied then
        -- Restore original vgui.Register function
        vgui.Register = originalVguiRegister
        isHL2SkinApplied = false
        print( "[HL2ified] HL2 Derma skin disabled. Original vgui.Register restored." )
    end
end

-- Apply on load
ApplyDefaultSkin()

-- Monitor ConVar changes
cvars.AddChangeCallback( "hl2_derma_skin", function( convar, oldValue, newValue )
    ApplyDefaultSkin()
end, "HL2DermaSkinMonitor" )

-- Console command to toggle default skin
concommand.Add( "hl2_toggle_derma_skin", function()
    local cvar = GetConVar( "hl2_derma_skin" )
    local newValue = cvar:GetBool() and 0 or 1
    RunConsoleCommand( "hl2_derma_skin", tostring( newValue ) )

    if ( newValue == 1 ) then
        print( "[HL2ified] HL2 Derma skin enabled as default. Restart the game or reload Lua for full effect." )
    else
        print( "[HL2ified] HL2 Derma skin disabled. Using standard Derma skin. Restart the game or reload Lua for full effect." )
    end
end )

-- Global reference to the test panel
local g_VGUITestPanel = nil

local function CreateVGUITestPanel()
    -- Close existing panel if open
    if ( IsValid( g_VGUITestPanel ) ) then
        g_VGUITestPanel:Remove()
    end

    -- Create the main frame
    local frame = vgui.Create( "HL2Frame" )
    frame:SetTitle( "VGUI Control Test Panel" )
    frame:SetSize( 700, 600 )
    frame:Center()
    frame:MakePopup()
    frame:SetDeleteOnClose( true )

    g_VGUITestPanel = frame

    -- Create a scroll panel for all controls
    local scroll = vgui.Create( "DScrollPanel", frame )
    scroll:Dock( FILL )
    scroll:DockMargin( 10, 35, 10, 10 )

    -- Helper function to create labeled controls
    local function AddControl( parent, label, control, controlHeight )
        local container = vgui.Create( "HL2Panel", parent )
        container:Dock( TOP )
        container:DockMargin( 5, 5, 5, 5 )
        container:SetTall( controlHeight or 30 )

        local lbl = vgui.Create( "HL2Label", container )
        lbl:SetText( label )
        lbl:SetPos( 5, 5 )
        lbl:SetSize( 150, 20 )

        control:SetParent( container )
        control:SetPos( 160, 2 )

        return container
    end

    -- Title
    local titleLabel = vgui.Create( "HL2Label", scroll )
    titleLabel:SetText( "HL2 VGUI Controls Test" )
    titleLabel:SetFont( HL2Scheme.GetFont( "UiBold", "DermaLarge", "SourceScheme" ) )
    titleLabel:SizeToContents()
    titleLabel:Dock( TOP )
    titleLabel:DockMargin( 5, 5, 5, 10 )

    -- Description
    local descLabel = vgui.Create( "HL2Label", scroll )
    descLabel:SetText( "This panel demonstrates all the custom HL2-styled VGUI controls." )
    descLabel:SetWrap( true )
    descLabel:SetAutoStretchVertical( true )
    descLabel:Dock( TOP )
    descLabel:DockMargin( 5, 0, 5, 15 )

    -- Section: Buttons
    local sectionLabel1 = vgui.Create( "HL2Label", scroll )
    sectionLabel1:SetText( "BUTTONS" )
    sectionLabel1:SetFont( HL2Scheme.GetFont( "UiBold", "DermaDefaultBold", "SourceScheme" ) )
    sectionLabel1:Dock( TOP )
    sectionLabel1:DockMargin( 5, 0, 5, 5 )

    -- Standard Button
    local btn1 = vgui.Create( "HL2Button" )
    btn1:SetText( "Standard Button" )
    btn1:SetSize( 150, 24 )
    btn1.DoClick = function() print( "Button clicked!" ) end
    AddControl( scroll, "Standard Button:", btn1, 30 )

    -- Disabled Button
    local btn2 = vgui.Create( "HL2Button" )
    btn2:SetText( "Disabled Button" )
    btn2:SetSize( 150, 24 )
    btn2:SetEnabled( false )
    AddControl( scroll, "Disabled Button:", btn2, 30 )

    -- Section: Text Entry
    local sectionLabel2 = vgui.Create( "HL2Label", scroll )
    sectionLabel2:SetText( "TEXT ENTRY" )
    sectionLabel2:SetFont( HL2Scheme.GetFont( "UiBold", "DermaDefaultBold", "SourceScheme" ) )
    sectionLabel2:Dock( TOP )
    sectionLabel2:DockMargin( 5, 15, 5, 5 )

    -- Text Entry
    local textEntry = vgui.Create( "HL2TextEntry" )
    textEntry:SetSize( 200, 24 )
    textEntry:SetPlaceholderText( "Enter text here..." )
    AddControl( scroll, "Text Entry:", textEntry, 30 )

    -- Disabled Text Entry
    local textEntry2 = vgui.Create( "HL2TextEntry" )
    textEntry2:SetSize( 200, 24 )
    textEntry2:SetText( "Disabled text" )
    textEntry2:SetEnabled( false )
    AddControl( scroll, "Disabled:", textEntry2, 30 )

    -- Section: CheckBox
    local sectionLabel3 = vgui.Create( "HL2Label", scroll )
    sectionLabel3:SetText( "CHECKBOXES" )
    sectionLabel3:SetFont( HL2Scheme.GetFont( "UiBold", "DermaDefaultBold", "SourceScheme" ) )
    sectionLabel3:Dock( TOP )
    sectionLabel3:DockMargin( 5, 15, 5, 5 )

    -- CheckBox
    local checkbox1 = vgui.Create( "HL2CheckBox" )
    checkbox1:SetValue( false )
    AddControl( scroll, "CheckBox (Unchecked):", checkbox1, 25 )

    local checkbox2 = vgui.Create( "HL2CheckBox" )
    checkbox2:SetValue( true )
    AddControl( scroll, "CheckBox (Checked):", checkbox2, 25 )

    -- Section: ComboBox
    local sectionLabel4 = vgui.Create( "HL2Label", scroll )
    sectionLabel4:SetText( "COMBOBOX" )
    sectionLabel4:SetFont( HL2Scheme.GetFont( "UiBold", "DermaDefaultBold", "SourceScheme" ) )
    sectionLabel4:Dock( TOP )
    sectionLabel4:DockMargin( 5, 15, 5, 5 )

    -- ComboBox
    local comboBox = vgui.Create( "HL2ComboBox" )
    comboBox:SetSize( 200, 24 )
    comboBox:AddChoice( "Option 1" )
    comboBox:AddChoice( "Option 2" )
    comboBox:AddChoice( "Option 3" )
    comboBox:AddChoice( "Option 4" )
    comboBox:ChooseOptionID( 1 )
    AddControl( scroll, "ComboBox:", comboBox, 30 )

    -- Section: Sliders
    local sectionLabel5 = vgui.Create( "HL2Label", scroll )
    sectionLabel5:SetText( "SLIDERS" )
    sectionLabel5:SetFont( HL2Scheme.GetFont( "UiBold", "DermaDefaultBold", "SourceScheme" ) )
    sectionLabel5:Dock( TOP )
    sectionLabel5:DockMargin( 5, 15, 5, 5 )

    -- Slider
    local slider = vgui.Create( "HL2NumSlider", scroll )
    slider:SetText( "Volume" )
    slider:SetMin( 0 )
    slider:SetMax( 100 )
    slider:SetValue( 50 )
    slider:SetDecimals( 0 )
    slider:Dock( TOP )
    slider:DockMargin( 5, 5, 5, 5 )
    slider:SetTall( 30 )
    slider:SetSkin( "HL2" )

    -- Section: Labels
    local sectionLabel6 = vgui.Create( "HL2Label", scroll )
    sectionLabel6:SetText( "LABELS" )
    sectionLabel6:SetFont( HL2Scheme.GetFont( "UiBold", "DermaDefaultBold", "SourceScheme" ) )
    sectionLabel6:Dock( TOP )
    sectionLabel6:DockMargin( 5, 15, 5, 5 )

    local label1 = vgui.Create( "HL2Label", scroll )
    label1:SetText( "Standard Label - Lorem ipsum dolor sit amet, consectetur adipiscing elit." )
    label1:SetWrap( true )
    label1:SetAutoStretchVertical( true )
    label1:Dock( TOP )
    label1:DockMargin( 160, 5, 5, 5 )

    -- Section: ListView
    local sectionLabel7 = vgui.Create( "HL2Label", scroll )
    sectionLabel7:SetText( "LISTVIEW" )
    sectionLabel7:SetFont( HL2Scheme.GetFont( "UiBold", "DermaDefaultBold", "SourceScheme" ) )
    sectionLabel7:Dock( TOP )
    sectionLabel7:DockMargin( 5, 15, 5, 5 )

    local listView = vgui.Create( "HL2ListView", scroll )
    listView:Dock( TOP )
    listView:DockMargin( 5, 5, 5, 5 )
    listView:SetTall( 150 )
    listView:SetMultiSelect( false )
    listView:AddColumn( "Name" )
    listView:AddColumn( "Value" )

    for i = 1, 10 do
        listView:AddLine( "Item " .. i, "Value " .. i )
    end

    -- Section: Progress Bar
    local sectionLabel8 = vgui.Create( "HL2Label", scroll )
    sectionLabel8:SetText( "PROGRESS BAR" )
    sectionLabel8:SetFont( HL2Scheme.GetFont( "UiBold", "DermaDefaultBold", "SourceScheme" ) )
    sectionLabel8:Dock( TOP )
    sectionLabel8:DockMargin( 5, 15, 5, 5 )

    local progress = vgui.Create( "DProgress", scroll )
    progress:Dock( TOP )
    progress:DockMargin( 5, 5, 5, 5 )
    progress:SetTall( 24 )
    progress:SetFraction( 0.6 )
    progress:SetSkin( "HL2" )

    -- Section: Panels
    local sectionLabel9 = vgui.Create( "HL2Label", scroll )
    sectionLabel9:SetText( "PANELS" )
    sectionLabel9:SetFont( HL2Scheme.GetFont( "UiBold", "DermaDefaultBold", "SourceScheme" ) )
    sectionLabel9:Dock( TOP )
    sectionLabel9:DockMargin( 5, 15, 5, 5 )

    local panel1 = vgui.Create( "HL2Panel", scroll )
    panel1:Dock( TOP )
    panel1:DockMargin( 5, 5, 5, 5 )
    panel1:SetTall( 60 )
    panel1.m_bPaintBackground = true

    local panelLabel = vgui.Create( "HL2Label", panel1 )
    panelLabel:SetText( "This is a panel with background" )
    panelLabel:SetPos( 10, 20 )
    panelLabel:SizeToContents()

    -- Section: PropertySheet (Tabs)
    local sectionLabel10 = vgui.Create( "HL2Label", scroll )
    sectionLabel10:SetText( "PROPERTYSHEET (TABS)" )
    sectionLabel10:SetFont( HL2Scheme.GetFont( "UiBold", "DermaDefaultBold", "SourceScheme" ) )
    sectionLabel10:Dock( TOP )
    sectionLabel10:DockMargin( 5, 15, 5, 5 )

    local propertySheet = vgui.Create( "DPropertySheet", scroll )
    propertySheet:Dock( TOP )
    propertySheet:DockMargin( 5, 5, 5, 5 )
    propertySheet:SetTall( 150 )
    propertySheet:SetSkin( "HL2" )

    -- Tab 1
    local panel2 = vgui.Create( "DPanel", propertySheet )
    panel2:Dock( FILL )
    local tab1Label = vgui.Create( "HL2Label", panel2 )
    tab1Label:SetText( "Content for Tab 1" )
    tab1Label:SetPos( 10, 10 )
    tab1Label:SizeToContents()
    propertySheet:AddSheet( "Tab 1", panel2, "icon16/page.png" )

    -- Tab 2
    local panel3 = vgui.Create( "DPanel", propertySheet )
    panel3:Dock( FILL )
    local tab2Label = vgui.Create( "HL2Label", panel3 )
    tab2Label:SetText( "Content for Tab 2" )
    tab2Label:SetPos( 10, 10 )
    tab2Label:SizeToContents()
    propertySheet:AddSheet( "Tab 2", panel3, "icon16/page.png" )

    -- Tab 3
    local panel4 = vgui.Create( "DPanel", propertySheet )
    panel4:Dock( FILL )
    local tab3Label = vgui.Create( "HL2Label", panel4 )
    tab3Label:SetText( "Content for Tab 3" )
    tab3Label:SetPos( 10, 10 )
    tab3Label:SizeToContents()
    propertySheet:AddSheet( "Tab 3", panel4, "icon16/page.png" )

    -- Bottom spacing
    local spacer = vgui.Create( "DPanel", scroll )
    spacer:Dock( TOP )
    spacer:SetTall( 20 )
    spacer:SetPaintBackground( false )
end

-- Console command to open the test panel
concommand.Add( "vgui_test", function()
    CreateVGUITestPanel()
end )

-- Also create on first load for testing
-- Uncomment the next line to have the panel auto-open when the game loads
-- timer.Simple( 1, CreateVGUITestPanel )

print( "[HL2ified] VGUI Test Panel loaded. Use 'vgui_test' command to open." )
