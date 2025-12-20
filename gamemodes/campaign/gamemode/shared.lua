-- Campaign Gamemode
-- Shared configuration file

GM.Name = "Campaign"
GM.Author = "AIChaos"
GM.Email = ""
GM.Website = ""

-- Include player class
include("player_class.lua")

-- Helper function to check if we're on a background map
function IsBackgroundMap()
	local map = game.GetMap()
	return map == "background01" or map == "background02" or map == "background03" or 
	       map == "background04" or map == "background05" or map == "background06" or 
	       map == "background07"
end

