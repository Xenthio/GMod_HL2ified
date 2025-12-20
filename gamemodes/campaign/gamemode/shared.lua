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
	return string.match(map, "^background0[1-7]$") ~= nil
end

