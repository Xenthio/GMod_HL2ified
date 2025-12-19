-- Disable the GMod menu
if ( SERVER ) then return end

include( "vgui_scheme.lua" )
include( "vgui_base.lua" )
include( "newgamedialog.lua" )

surface.CreateFont( "HL2MenuFont", {
	font = "Trebuchet MS",
	size = 32,
	weight = 900,
	antialias = true,
    additive = false,
} )

-- Create the background panel
local function CreateMainMenu()

	-- Remove old menu if it exists
	if ( IsValid( pnlMainMenu ) ) then
		pnlMainMenu:Remove()
	end

	-- Create the main panel
	pnlMainMenu = vgui.Create( "DPanel" )
	pnlMainMenu:SetSize( ScrW(), ScrH() )
	-- pnlMainMenu:MakePopup() -- Removed to prevent focus stealing/z-order issues
    pnlMainMenu:SetMouseInputEnabled( true )
	pnlMainMenu:SetKeyboardInputEnabled( false )
    pnlMainMenu:SetPaintBackground( false )
    
    -- Stub for problems.lua
    function pnlMainMenu:SetProblemCount( count )
        -- Do nothing
    end
    
    -- Stub for getmaps.lua
    function pnlMainMenu:Call( name, args )
        -- Do nothing
    end
	
	-- Draw background
	pnlMainMenu.Paint = function( self, w, h )
		-- If we are not in a game (void), draw a solid background
        if ( !IsInGame() ) then
            surface.SetDrawColor( 0, 0, 0, 255 )
            surface.DrawRect( 0, 0, w, h )
            return
        end
        
        -- If we are in a game, check if it's a background map
        -- Heuristic: HUD is usually disabled in background maps
        local isBackground = GetConVar("cl_drawhud"):GetInt() == 0
        
        -- Fallback: Check map name
        if ( !isBackground ) then
             local map = game.GetMap()
             if ( map and (string.find(map, "^background") or map == "test_hardware") ) then
                 isBackground = true
             end
        end
        
        if ( !isBackground ) then
            -- In a real game (Pause menu), draw blur
            Derma_DrawBackgroundBlur( self, 0 )
        end
	end

	-- Load GameMenu.res
	local gameMenu = util.KeyValuesToTable( file.Read( "resource/GameMenu.res", "GAME" ) or "" )
	
	if ( !gameMenu ) then
		print( "Error: Could not load resource/GameMenu.res" )
		return
	end

	-- Container for buttons
	local buttonList = vgui.Create( "DListLayout", pnlMainMenu )
	buttonList:SetSize( 300, ScrH() - 100 )
	buttonList:SetPos( 100, 400 ) -- Middle left alignment

	-- Sort the menu items by "InGameOrder" or just index if numeric
	local sortedItems = {}
	for k, v in pairs( gameMenu ) do
		if ( tonumber( k ) ) then
			table.insert( sortedItems, { key = tonumber(k), data = v } )
		end
	end
	
	table.SortByMember( sortedItems, "key", true )

	for _, item in ipairs( sortedItems ) do
		local data = item.data
		
		-- Check visibility conditions
		local inGame = IsInGame()
		if ( data.OnlyInGame and !inGame ) then continue end
		if ( data.notmulti and inGame ) then continue end -- Simplified logic
        if ( data.ConsoleOnly ) then continue end

		local btn = buttonList:Add( "DButton" )
		btn:SetText( language.GetPhrase( data.label ) )
		btn:SetTall( 40 )
		btn:SetFont( "HL2MenuFont" )
		btn:SetContentAlignment( 4 ) -- Left align text
		btn:SetTextInset( 20, 0 )
        btn:SetPaintBackground( false )
        btn:SetColor( Color( 255, 255, 255 ) )

        btn.Paint = function( self, w, h )
            if ( self:IsHovered() ) then
                -- draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255, 20 ) )
                self:SetColor( Color( 255, 200, 0 ) )
            else
                self:SetColor( Color( 255, 255, 255 ) )
            end
        end

		btn.DoClick = function()
			local cmd = data.command
			if ( !cmd ) then return end

			if ( cmd == "OpenNewGameDialog" ) then
				OpenNewGameDialog()
			elseif ( cmd == "ResumeGame" ) then
				gui.HideGameUI()
			elseif ( string.StartWith( cmd, "engine " ) ) then
				RunConsoleCommand( string.sub( cmd, 8 ) )
			else
				-- Use gamemenucommand to let the engine handle standard dialogs
				-- This works for OpenNewGameDialog, OpenOptionsDialog, Quit, etc.
				RunConsoleCommand( "gamemenucommand", cmd )
			end
		end
	end

end

hook.Add( "MenuStart", "CreateCustomMenu", CreateMainMenu )
hook.Add( "GameContentChanged", "RefreshCustomMenu", CreateMainMenu )

-- Also run it now if we are reloading lua
CreateMainMenu()
