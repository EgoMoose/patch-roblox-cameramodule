local FakeUserSettings = require(script:WaitForChild("FakeUserSettings"))

local PlayerModule = script.Parent.Parent:WaitForChild("PlayerModule")
local CameraModule = PlayerModule:WaitForChild("CameraModule")
local TransparencyController = require(CameraModule:WaitForChild("TransparencyController"))

local result = nil
local transparencyControllerEnable = TransparencyController.Enable

-- we can't get into the camera module directly because it returns an empty table if the `UserRemoveTheCameraApi` is enabled
-- however we can get into a number of the submodules that the camera module uses and is guaranteed to call early on
-- we can use these calls to get the environment of the camera module and replace the user settings with a fake thereby
-- disabling the flag

local injectionThread = coroutine.create(function()
	TransparencyController.Enable = function()
		local env = getfenv(3)
		env.UserSettings = FakeUserSettings
		local f = setfenv(3, env)
		
		TransparencyController.Enable = transparencyControllerEnable
		
		result = f()
		coroutine.yield()
	end

	require(CameraModule)
end)

coroutine.resume(injectionThread)
coroutine.close(injectionThread)

-- treat this module as a replacement for Camera module so that require(PlayerModule.CameraModule) 
-- behaves for other scripts such as the PlayerModule

for _, child in pairs(CameraModule:GetChildren()) do
	child.Parent = script
end

CameraModule.Name = "_CameraModule"
script.Name = "CameraModule"
script.Parent = PlayerModule

return result