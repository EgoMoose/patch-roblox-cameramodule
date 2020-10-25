-- Injects into the CameraModule to override for public API access
-- EgoMoose

local FFLAG_OVERRIDES = {
	["UserRemoveTheCameraApi"] = false
}

-- Fake User Settings

local FakeUserSettings = {}

function FakeUserSettings:IsUserFeatureEnabled(name)
	if FFLAG_OVERRIDES[name] ~= nil then
		return FFLAG_OVERRIDES[name]
	end
	return UserSettings():IsUserFeatureEnabled(name)
end

function FakeUserSettings:GetService(name)
	return UserSettings():GetService(name)
end

local function FakeUserSettingsFunc()
	return FakeUserSettings
end

-- Camera Injection

local PlayerModule = script.Parent.Parent:WaitForChild("PlayerModule")
local CameraModule = PlayerModule:WaitForChild("CameraModule")
local TransparencyController = require(CameraModule:WaitForChild("TransparencyController"))

local result = nil
local copy = TransparencyController.Enable
local bind = Instance.new("BindableEvent")

TransparencyController.Enable = function(self, ...)
	copy(self, ...)
	
	local env = getfenv(3)
	env.UserSettings = FakeUserSettingsFunc
	local f = setfenv(3, env)
	
	TransparencyController.Enable = copy
	
	result = f()
	bind.Event:Wait() -- infinite wait so no more connections can be made
end

coroutine.wrap(function()
	require(CameraModule)
end)()

-- Place children under injection

for _, child in pairs(CameraModule:GetChildren()) do
	child.Parent = script
end

CameraModule.Name = "_CameraModule"
script.Name = "CameraModule"
script.Parent = PlayerModule

--

return result
