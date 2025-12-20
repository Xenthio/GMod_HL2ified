-- Campaign Gamemode - Client Init
include("shared.lua")

function GM:Initialize()
	print("[Campaign] Client Initialized")
end

-- Helper function to check if we're on a background map
local function IsBackgroundMap()
	local map = game.GetMap()
	return map == "background01" or map == "background02" or map == "background03" or 
	       map == "background04" or map == "background05" or map == "background06" or 
	       map == "background07"
end

--
-- Load save hint (GMod blocks 'load' command from Lua, so we show a hint)
--
local LoadSaveHint = nil
local LoadSaveTime = 0

net.Receive( "CampaignLoadSaveHint", function()
	local saveName = net.ReadString()
	LoadSaveHint = saveName
	LoadSaveTime = CurTime()
end )

hook.Add( "HUDPaint", "CampaignLoadSaveHint", function()
	if not LoadSaveHint then return end
	
	local ply = LocalPlayer()
	if IsValid( ply ) and ply:Health() > 0 then
		LoadSaveHint = nil -- Player respawned somehow, clear hint
		return
	end
	
	-- Draw hint text
	local text1 = "PRESS F9 TO QUICKLOAD"
	local text2 = "or load save: " .. LoadSaveHint
	
	surface.SetFont( "DermaLarge" )
	local w1, h1 = surface.GetTextSize( text1 )
	local w2, h2 = surface.GetTextSize( text2 )
	
	local x = ScrW() / 2
	local y = ScrH() * 0.7
	
	-- Pulsing alpha for visibility
	local pulse = math.abs( math.sin( CurTime() * 2 ) )
	local alpha = 150 + pulse * 105
	
	-- Draw shadow
	surface.SetTextColor( 0, 0, 0, alpha )
	surface.SetTextPos( x - w1/2 + 2, y + 2 )
	surface.DrawText( text1 )
	surface.SetTextPos( x - w2/2 + 2, y + h1 + 10 + 2 )
	surface.DrawText( text2 )
	
	-- Draw text
	surface.SetTextColor( 255, 200, 80, alpha )
	surface.SetTextPos( x - w1/2, y )
	surface.DrawText( text1 )
	surface.SetTextColor( 200, 200, 200, alpha * 0.8 )
	surface.SetTextPos( x - w2/2, y + h1 + 10 )
	surface.DrawText( text2 )
end )

--
-- First-person death view (HL2 SP style)
--

-- Track death state locally to avoid network delay
local IsDead = false
local LastHealth = 100
local LastVelocityZ = 0
local DiedFromFall = false
local FallDeathTime = 0

hook.Add( "Think", "CampaignDeathCheck", function()
	local ply = LocalPlayer()
	if not IsValid( ply ) then return end
	
	local health = ply:Health()
	local velZ = ply:GetVelocity().z
	
	-- Detect death: health dropped to 0 or below
	if health <= 0 and LastHealth > 0 then
		IsDead = true
		
		-- Check if we died from fall damage (were falling fast before death)
		if LastVelocityZ < -600 then
			DiedFromFall = true
			FallDeathTime = CurTime()
		end
	end
	
	-- Detect respawn: health went from 0 to positive
	if health > 0 and IsDead then
		IsDead = false
		DiedFromFall = false
	end
	
	LastHealth = health
	LastVelocityZ = velZ
end )

-- Override CalcView to prevent the death chase cam
function GM:CalcView( ply, origin, angles, fov )
	local view = {}
	view.origin = origin
	view.angles = angles
	view.fov = fov
	view.drawviewer = false
	
	-- On background maps, ensure camera is at proper position
	if IsBackgroundMap() then
		-- For background maps, the camera should be at the info_player_start position
		-- or a fixed position. The game will handle this, so we don't override.
		-- However, we make sure not to offset the camera.
		return view
	end
	
	-- If dead, keep first person at player position, allow looking around
	if IsDead or ply:Health() <= 0 then
		view.origin = ply:GetPos() + Vector( 0, 0, 64 )
	end
	if not ply:Alive()  then
		view.origin = ply:GetPos() + Vector( 0, 0, 16 )
	end
	
	return view
end

-- Never draw local player in third person (prevents death cam showing player model)
-- Also hide on background maps
function GM:ShouldDrawLocalPlayer( ply )
	-- Always hide player model on background maps
	if IsBackgroundMap() then
		return false
	end
	return false
end

-- Hide viewmodel on death
function GM:PreDrawViewModel( vm, ply, weapon )
	if IsDead or not ply:Alive() or ply:Health() <= 0 then
		return true -- Don't draw
	end
	
	-- Hide viewmodel on background maps
	if IsBackgroundMap() then
		return true -- Don't draw
	end
end

-- Hide player model completely on background maps
hook.Add( "PrePlayerDraw", "HidePlayerOnBackgroundMaps", function( ply )
	if ply == LocalPlayer() and IsBackgroundMap() then
		return true -- Don't draw
	end
end )

-- Also ensure player effects are hidden on background maps
hook.Add( "PostPlayerDraw", "HidePlayerEffectsOnBackgroundMaps", function( ply )
	if ply == LocalPlayer() and IsBackgroundMap() then
		-- This shouldn't be called if PrePlayerDraw returns true, but just in case
	end
end )

-- Black screen on fall death
function GM:RenderScreenspaceEffects()
	if DiedFromFall then
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.DrawRect( -10, -10, ScrW() + 20, ScrH() + 20 )
	end
end
