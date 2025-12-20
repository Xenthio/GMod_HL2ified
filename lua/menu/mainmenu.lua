-- Disable the GMod menu
if ( SERVER ) then return end

include( "vgui_scheme.lua" )
include( "skins/hl2.lua" )
include( "vgui_base.lua" )
include( "newgamedialog.lua" )

-- Global dialog handles
g_QuitDialog = nil

-- ModInfo
local ModInfo = { Title = "HALF-LIFE'", Title2 = "" }
local function LoadModInfo()
    local content = file.Read("gameinfo.txt", "GAME")
    if content then
        local data = util.KeyValuesToTable(content)
        if data and data.GameInfo then
            ModInfo.Title = data.GameInfo.title or ModInfo.Title
            ModInfo.Title2 = data.GameInfo.title2 or ModInfo.Title2
        end
    end
end
LoadModInfo()

-- Constants
local BACKGROUND_MAPS = {
    ["background01"] = true,
    ["background02"] = true,
    ["background03"] = true,
    ["background04"] = true,
    ["background05"] = true
}

local SAVE_COMPLETION_DELAY = 0.5 -- Time in seconds to wait for save to complete before quitting

-- Helper function to check if a map is a background map
local function IsBackgroundMap( mapName )
    return BACKGROUND_MAPS[mapName] == true
end

-- Helper function to check if currently in a real game (not background map)
local function IsInRealGame()
    local inGame = IsInGame()
    if ( inGame and game.GetMap ) then
        if ( IsBackgroundMap( game.GetMap() ) ) then
            inGame = false
        end
    end
    return inGame
end

-- Helper function to check if in a single player game
local function IsSinglePlayerGame()
    if ( !IsInRealGame() ) then return false end
    
    local maxPlayers = 1
    if ( game.MaxPlayers ) then
        maxPlayers = game.MaxPlayers()
    elseif ( GetMaxPlayers ) then
        maxPlayers = GetMaxPlayers()
    end
    
    return maxPlayers == 1
end

-- Helper for proportional scaling (Source engine standard is based on 480 height)
local function SchemeScale( val )
    return math.floor( val * ( ScrH() / 480 ) )
end

--------------------------------------------------------------------------------
-- CGameMenuItem
--------------------------------------------------------------------------------
local PANEL = {}

function PANEL:Init()
    self:SetText( "" )
    self:SetSize( 200, 20 )
    self.Label = ""
    self.Command = ""
    self.EngineCommand = ""
    self.UserData = {}
    
    self.Font = "MenuLarge"
    self.TextColor = Color( 255, 255, 255, 255 )
    self.ArmedColor = Color( 255, 255, 255, 255 )
    self.DepressedColor = Color( 255, 255, 255, 255 )
    self.Blink = false
end

function PANEL:SetMenuItemData( label, command, userData )
    self.Label = language.GetPhrase( label )
    self.Command = command
    self.UserData = userData
end

function PANEL:ApplySchemeSettings()
    -- Get colors from scheme
    self.TextColor = HL2Scheme.GetColor( "MainMenu.TextColor", Color( 200, 200, 200, 255 ), "SourceScheme" )
    self.ArmedColor = HL2Scheme.GetColor( "MainMenu.ArmedTextColor", Color( 255, 255, 255, 255 ), "SourceScheme" )
    self.DepressedColor = HL2Scheme.GetColor( "MainMenu.TextColor", Color( 100, 100, 100, 255 ), "SourceScheme" ) // Depressed unused in hl2
    
    -- Get font with fallback logic
    -- 1. Try MainMenuFont in ClientScheme
    local font = HL2Scheme.GetFont( "MainMenuFont", nil, "ClientScheme" )
    
    -- 2. Try MenuLarge in ClientScheme
    if ( !font ) then
        font = HL2Scheme.GetFont( "MenuLarge", nil, "ClientScheme" )
    end
    
    -- 3. Try MenuLarge in SourceScheme
    if ( !font ) then
        font = HL2Scheme.GetFont( "MenuLarge", nil, "SourceScheme" )
    end
    
    -- 4. Fallback to Default
    self.Font = font or "Default"
    
    -- Height
    local h = tonumber( HL2Scheme.GetResourceString( "MainMenu.MenuItemHeight", nil, "ClientScheme" ) )
    if ( h ) then
        self:SetTall( SchemeScale( h ) )
    else
        -- Fallback: Use font height
        surface.SetFont( self.Font )
        local _, th = surface.GetTextSize( "W" )
        if ( th ) then
            self:SetTall( th + SchemeScale( 4 ) ) -- Small padding
        else
            self:SetTall( SchemeScale( 32 ) )
        end
    end
end

function PANEL:Paint( w, h )
    local col = self.TextColor
    
    if ( self:IsDown() ) then
        col = self.DepressedColor
    elseif ( self:IsHovered() ) then
        col = self.ArmedColor
    end
    
    if ( self.Blink ) then
        local flash = math.sin( CurTime() * 10 ) > 0
        if ( flash ) then col = self.ArmedColor end
    end

    surface.SetFont( self.Font )
    surface.SetTextColor( col )
    surface.SetTextPos( 0, 0 ) -- Align left
    surface.DrawText( self.Label )
end

function PANEL:OnCursorEntered()
    surface.PlaySound( "UI/buttonrollover.wav" )
end

function PANEL:DoClick()
    surface.PlaySound( "UI/buttonclickrelease.wav" )
    
    local cmd = self.Command
    if ( !cmd ) then return end

    if ( cmd == "OpenNewGameDialog" ) then
        OpenNewGameDialog()
    elseif ( cmd == "ResumeGame" ) then
        gui.HideGameUI()
    elseif ( cmd == "Quit" ) then
        OpenQuitConfirmationDialog()
    elseif ( cmd == "QuitNoConfirm" ) then
        RunConsoleCommand( "quit" )
    elseif ( cmd == "Disconnect" ) then
        RunConsoleCommand( "disconnect" )
    elseif ( string.StartWith( cmd, "engine " ) ) then
        RunConsoleCommand( string.sub( cmd, 8 ) )
    else
        RunConsoleCommand( "gamemenucommand", cmd )
    end
end

vgui.Register( "CGameMenuItem", PANEL, "DButton" )

--------------------------------------------------------------------------------
-- CQuitConfirmationDialog (Simple Yes/No for menu state)
--------------------------------------------------------------------------------
local QUIT_PANEL = {}

function QUIT_PANEL:Init()
    self.BaseClass.Init( self )
    self:SetSize( 416, 140 )
    self:Center()
    self:MakePopup()
    
    local titleText = language.GetPhrase( "#GameUI_QuitConfirmationTitle" )
    if titleText == "#GameUI_QuitConfirmationTitle" then
        titleText = "Quit"
    end
    self:SetTitleText( titleText )
    
    self:SetDeleteOnClose( true )
    self:SetMinimizeEnabled( false )
    self:SetMaximizeEnabled( false )
    
    -- Message Label
    self.lblMessage = vgui.Create( "DLabel", self )
    self.lblMessage:SetPos( 24, 48 )
    self.lblMessage:SetSize( 368, 40 )
    self.lblMessage:SetFont( HL2Scheme.GetFont( "Default", "Default", "SourceScheme" ) )
    
    local messageText = language.GetPhrase( "#GameUI_QuitConfirmationText" )
    if messageText == "#GameUI_QuitConfirmationText" then
        messageText = "Are you sure you want to quit?"
    end
    self.lblMessage:SetText( messageText )
    
    self.lblMessage:SetContentAlignment( 4 ) -- Left
    self.lblMessage:SetTextColor( HL2Scheme.GetColor( "NewGame.TextColor", Color( 255, 255, 255, 255 ), "SourceScheme" ) )
    self.lblMessage:SetWrap( true )
    
    -- Quit Button
    self.btnQuit = vgui.Create( "HL2Button", self )
    
    local quitText = language.GetPhrase( "#GameUI_Quit" )
    if quitText == "#GameUI_Quit" then
        quitText = "Quit"
    end
    self.btnQuit:SetText( quitText )
    
    self.btnQuit:SetPos( 231, 100 )
    self.btnQuit:SetSize( 80, 24 )
    self.btnQuit:SetContentAlignment( 4 )
    self.btnQuit.DoClick = function() 
        self:OnQuit()
    end
    
    -- Cancel Button
    self.btnCancel = vgui.Create( "HL2Button", self )
    
    local cancelText = language.GetPhrase( "#GameUI_Cancel" )
    if cancelText == "#GameUI_Cancel" then
        cancelText = "Cancel"
    end
    self.btnCancel:SetText( cancelText )
    
    self.btnCancel:SetPos( 320, 100 )
    self.btnCancel:SetSize( 72, 24 )
    self.btnCancel:SetContentAlignment( 4 )
    self.btnCancel.DoClick = function() 
        self:Close()
    end
end

function QUIT_PANEL:OnQuit()
    RunConsoleCommand( "gamemenucommand", "QuitNoConfirm" )
    self:Close()
end

vgui.Register( "CQuitConfirmationDialog", QUIT_PANEL, "HL2Frame" )

--------------------------------------------------------------------------------
-- CSaveBeforeQuitDialog (Save & Quit, Quit, Cancel for in-game state)
--------------------------------------------------------------------------------
local SAVE_QUIT_PANEL = {}

function SAVE_QUIT_PANEL:Init()
    self.BaseClass.Init( self )
    self:SetSize( 416, 160 )
    self:Center()
    self:MakePopup()
    
    local titleText = language.GetPhrase( "#GameUI_QuitConfirmationTitle" )
    if titleText == "#GameUI_QuitConfirmationTitle" then
        titleText = "Quit"
    end
    self:SetTitleText( titleText )
    
    self:SetDeleteOnClose( true )
    self:SetMinimizeEnabled( false )
    self:SetMaximizeEnabled( false )
    
    -- Message Label
    self.lblMessage = vgui.Create( "DLabel", self )
    self.lblMessage:SetPos( 24, 48 )
    self.lblMessage:SetSize( 368, 40 )
    self.lblMessage:SetFont( HL2Scheme.GetFont( "Default", "Default", "SourceScheme" ) )
    
    local messageText = language.GetPhrase( "#GameUI_QuitWithoutSavingConfirmationText" )
    if messageText == "#GameUI_QuitWithoutSavingConfirmationText" then
        messageText = "Do you want to save your game before quitting?"
    end
    self.lblMessage:SetText( messageText )
    
    self.lblMessage:SetContentAlignment( 4 ) -- Left
    self.lblMessage:SetTextColor( HL2Scheme.GetColor( "NewGame.TextColor", Color( 255, 255, 255, 255 ), "SourceScheme" ) )
    self.lblMessage:SetWrap( true )
    
    -- Save and Quit Button
    self.btnSaveQuit = vgui.Create( "HL2Button", self )
    
    local saveQuitText = language.GetPhrase( "#GameUI_SaveAndQuit" )
    if saveQuitText == "#GameUI_SaveAndQuit" then
        saveQuitText = "Save and Quit"
    end
    self.btnSaveQuit:SetText( saveQuitText )
    
    self.btnSaveQuit:SetPos( 24, 110 )
    self.btnSaveQuit:SetSize( 120, 24 )
    self.btnSaveQuit:SetContentAlignment( 4 )
    self.btnSaveQuit.DoClick = function() 
        self:OnSaveAndQuit()
    end
    
    -- Quit Button (without saving)
    self.btnQuit = vgui.Create( "HL2Button", self )
    
    local quitText = language.GetPhrase( "#GameUI_Quit" )
    if quitText == "#GameUI_Quit" then
        quitText = "Quit"
    end
    self.btnQuit:SetText( quitText )
    
    self.btnQuit:SetPos( 231, 110 )
    self.btnQuit:SetSize( 80, 24 )
    self.btnQuit:SetContentAlignment( 4 )
    self.btnQuit.DoClick = function() 
        self:OnQuit()
    end
    
    -- Cancel Button
    self.btnCancel = vgui.Create( "HL2Button", self )
    
    local cancelText = language.GetPhrase( "#GameUI_Cancel" )
    if cancelText == "#GameUI_Cancel" then
        cancelText = "Cancel"
    end
    self.btnCancel:SetText( cancelText )
    
    self.btnCancel:SetPos( 320, 110 )
    self.btnCancel:SetSize( 72, 24 )
    self.btnCancel:SetContentAlignment( 4 )
    self.btnCancel.DoClick = function() 
        self:Close()
    end
end

function SAVE_QUIT_PANEL:OnSaveAndQuit()
    -- Auto-save using the same logic as Source engine
    local saveName = "autosave_quit"
    RunConsoleCommand( "save", saveName )
    
    -- Store reference for timer validation
    local dialogRef = self
    
    -- Small delay to allow save to complete before quitting
    -- Note: GMod's save command is fire-and-forget, so we can't check for success
    -- The delay gives the save operation time to complete in most cases
    timer.Simple( SAVE_COMPLETION_DELAY, function()
        -- Only quit if the dialog is still valid (wasn't closed/removed)
        if ( IsValid( dialogRef ) ) then
            RunConsoleCommand( "gamemenucommand", "QuitNoConfirm" )
        end
    end )
    
    self:Close()
end

function SAVE_QUIT_PANEL:OnQuit()
    RunConsoleCommand( "gamemenucommand", "QuitNoConfirm" )
    self:Close()
end

vgui.Register( "CSaveBeforeQuitDialog", SAVE_QUIT_PANEL, "HL2Frame" )

--------------------------------------------------------------------------------
-- CGameMenu
--------------------------------------------------------------------------------
PANEL = {}

function PANEL:Init()
    self.Items = {}
    self:SetPaintBackground( false )
end

function PANEL:LoadGameMenu()
    self:Clear()
    self.Items = {}
    
    local gameMenu = util.KeyValuesToTable( file.Read( "resource/GameMenu.res", "GAME" ) or "" )
    if ( !gameMenu ) then return end
    
    -- Sort
    local sortedItems = {}
    for k, v in pairs( gameMenu ) do
        if ( tonumber( k ) ) then
            table.insert( sortedItems, { key = tonumber(k), data = v } )
        end
    end
    table.SortByMember( sortedItems, "key", true )
    
    for _, item in ipairs( sortedItems ) do
        local data = item.data
        local btn = vgui.Create( "CGameMenuItem", self )
        btn:SetMenuItemData( data.label, data.command, data )
        table.insert( self.Items, btn )
    end
    
    self:InvalidateLayout()
end

function PANEL:ApplySchemeSettings()
    for _, btn in ipairs( self.Items ) do
        btn:ApplySchemeSettings()
    end
end

function PANEL:UpdateMenuItemState()
    local inGame = IsInRealGame()

    local maxPlayers = 1
    if ( game.MaxPlayers ) then
        maxPlayers = game.MaxPlayers()
    elseif ( GetMaxPlayers ) then
        maxPlayers = GetMaxPlayers()
    end
    
    local isMulti = inGame and ( maxPlayers > 1 )
    
    local y = 0
    local visibleCount = 0
    
    for _, btn in ipairs( self.Items ) do
        local data = btn.UserData
        local visible = true
        
        -- Check flags (case-insensitive fallback)
        local onlyInGame = data.OnlyInGame or data.onlyingame
        local notMulti = data.notmulti or data.NotMulti
        local notSingle = data.notsingle or data.NotSingle
        local consoleOnly = data.ConsoleOnly or data.consoleonly
        
        if ( onlyInGame and !inGame ) then visible = false end
        if ( notMulti and isMulti ) then visible = false end
        if ( notSingle and inGame and !isMulti ) then visible = false end
        if ( consoleOnly ) then visible = false end
        
        btn:SetVisible( visible )
        
        if ( visible ) then
            btn:SetPos( 0, y )
            y = y + btn:GetTall()
            visibleCount = visibleCount + 1
        end
    end
    
    self:SetTall( y )
end

function PANEL:PerformLayout()
    self:UpdateMenuItemState()
end

vgui.Register( "CGameMenu", PANEL, "DPanel" )

--------------------------------------------------------------------------------
-- CBasePanel
--------------------------------------------------------------------------------
PANEL = {}

function PANEL:Init()
    self:SetSize( ScrW(), ScrH() )
    self:SetMouseInputEnabled( true )
    self:SetKeyboardInputEnabled( false )
    self:SetPaintBackground( false )
    
    self.GameMenu = vgui.Create( "CGameMenu", self )
    self.GameMenu:LoadGameMenu()
    
    self.TitleLabels = {}
    self.TitlePos = {}
    
    -- Create Title Labels
    local titles = { ModInfo.Title, ModInfo.Title2 }
    for i, title in ipairs( titles ) do
        if ( title and title != "" ) then
            local lbl = vgui.Create( "DLabel", self )
            lbl:SetText( title )
            lbl:SetContentAlignment( 4 ) -- Left
            table.insert( self.TitleLabels, lbl )
        end
    end
    
    self.MenuInset = 32
    self.MenuX = 32
    self.MenuY = 248
    self.BottomBorder = 32
    
    self:ApplySchemeSettings()
end

function PANEL:ApplySchemeSettings()
    -- Read from ClientScheme
    self.MenuInset = tonumber( HL2Scheme.GetResourceString( "MainMenu.Inset", nil, "ClientScheme" ) ) or 32
    self.MenuX = tonumber( HL2Scheme.GetResourceString( "Main.Menu.X", nil, "ClientScheme" ) ) or 32
    self.MenuY = tonumber( HL2Scheme.GetResourceString( "Main.Menu.Y", nil, "ClientScheme" ) ) or 248
    self.BottomBorder = tonumber( HL2Scheme.GetResourceString( "Main.BottomBorder", nil, "ClientScheme" ) ) or 32
    
    -- Scale
    self.MenuInset = SchemeScale( self.MenuInset )
    self.MenuX = SchemeScale( self.MenuX )
    self.MenuY = SchemeScale( self.MenuY )
    self.BottomBorder = SchemeScale( self.BottomBorder )
    
    self.GameMenu:ApplySchemeSettings()
    
    -- Apply settings to Title Labels
    self.TitlePos = {}
    for i, lbl in ipairs( self.TitleLabels ) do
        local x = tonumber( HL2Scheme.GetResourceString( "Main.Title" .. i .. ".X", nil, "ClientScheme" ) ) or 32
        local y = tonumber( HL2Scheme.GetResourceString( "Main.Title" .. i .. ".Y", nil, "ClientScheme" ) ) or (100 + i * 50)
        local col = HL2Scheme.GetColor( "Main.Title" .. i .. ".Color", Color( 255, 255, 255, 255 ), "ClientScheme" )
        -- local font = HL2Scheme.GetFont( "ClientTitleFont", "DermaLarge", "ClientScheme", "ClientScheme" )
        
        -- Create a scaled font for the title
        local fontName = "ClientTitleFont_Scaled"
        local baseSize = 32 -- Base size for 480p
        
        surface.CreateFont( fontName, {
            font = "HALFLIFE2",
            size = SchemeScale( baseSize ),
            weight = 0,
            antialias = true,
            additive = false
        } )
        
        x = SchemeScale( x )
        y = SchemeScale( y )
        
        lbl:SetFont( fontName )
        lbl:SetTextColor( col )
        lbl:SizeToContents()
        lbl:SetSize( lbl:GetWide() + 10, lbl:GetTall() ) -- Padding
        
        table.insert( self.TitlePos, { x = x, y = y } )
    end
    
    self:InvalidateLayout()
end

function PANEL:PerformLayout()
    local w, h = ScrW(), ScrH()
    self:SetSize( w, h )
    
    -- Position Menu
    local menuW = 300 -- Approximate
    local menuH = self.GameMenu:GetTall()
    
    local idealY = self.MenuY
    
    -- Ensure it doesn't go off screen
    if ( idealY + menuH + self.BottomBorder > h ) then
        idealY = h - menuH - self.BottomBorder
    end
    
    local yDiff = idealY - self.MenuY
    
    self.GameMenu:SetPos( self.MenuX, idealY )
    self.GameMenu:SetSize( menuW, menuH )
    
    -- Position Titles
    for i, lbl in ipairs( self.TitleLabels ) do
        local pos = self.TitlePos[i]
        if ( pos ) then
            lbl:SetPos( pos.x, pos.y + yDiff )
        end
    end
end

function PANEL:Paint( w, h )
    -- Check for game state change to update menu items
    local inGame = IsInGame()
    if ( self.LastInGame != inGame ) then
        self.LastInGame = inGame
        if ( IsValid( self.GameMenu ) ) then
            self.GameMenu:InvalidateLayout()
        end
    end

    if ( !inGame ) then
        -- Draw Background Image
        -- TODO: Load console/background01
        -- surface.SetDrawColor( 0, 0, 0, 255 )
        -- surface.DrawRect( 0, 0, w, h )
        
        -- Try to draw background image if available
        -- local bg = Material("console/background01")
        -- surface.SetMaterial(bg)
        -- surface.DrawTexturedRect(0, 0, w, h)
    else
        -- Check if we are on a background map
        local isBackground = false
        if ( game.GetMap ) then
            isBackground = IsBackgroundMap( game.GetMap() )
        end

        if ( !isBackground ) then
            -- Draw Blur
            -- Derma_DrawBackgroundBlur( self, 0 )
            
            -- Draw darkened background if needed (e.g. pause menu)
            surface.SetDrawColor( 0, 0, 0, 120 )
            surface.DrawRect( 0, 0, w, h )
        end
    end
end

-- Stub for problems.lua
function PANEL:SetProblemCount( count ) end
-- Stub for getmaps.lua
function PANEL:Call( name, args ) end

vgui.Register( "CBasePanel", PANEL, "DPanel" )

--------------------------------------------------------------------------------
-- Main Entry Point
--------------------------------------------------------------------------------

local function CreateMainMenu()
    if ( IsValid( pnlMainMenu ) ) then
        pnlMainMenu:Remove()
    end
    
    pnlMainMenu = vgui.Create( "CBasePanel" )
end

function OpenQuitConfirmationDialog()
    if ( IsValid( g_QuitDialog ) ) then 
        g_QuitDialog:Remove() 
    end
    
    if ( IsSinglePlayerGame() ) then
        -- Show save & quit dialog for single player games
        g_QuitDialog = vgui.Create( "CSaveBeforeQuitDialog" )
    else
        -- Show simple confirmation for menu or multiplayer
        g_QuitDialog = vgui.Create( "CQuitConfirmationDialog" )
    end
end

hook.Add( "MenuStart", "CreateCustomMenu", CreateMainMenu )
hook.Add( "GameContentChanged", "RefreshCustomMenu", CreateMainMenu )

-- Also run it now if we are reloading lua
CreateMainMenu()
