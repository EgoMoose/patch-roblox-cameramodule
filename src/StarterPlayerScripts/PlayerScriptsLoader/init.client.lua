--[[
	PlayerScriptsLoader - This script requires and instantiates the PlayerModule singleton

	2018 PlayerScripts Update - AllYourBlox
	2020 CameraModule Public Access Override - EgoMoose
--]]

local PlayerModule = script.Parent:WaitForChild("PlayerModule")
local CameraInjector = script:WaitForChild("CameraInjector")

require(CameraInjector)
require(PlayerModule)