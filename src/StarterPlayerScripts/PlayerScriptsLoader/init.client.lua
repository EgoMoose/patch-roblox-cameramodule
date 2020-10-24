local PlayerModule = script.Parent:WaitForChild("PlayerModule")
local CameraInjector = script:WaitForChild("CameraInjector")

require(CameraInjector)
require(PlayerModule)

-- beyond this point is test code!

local CameraModule = require(PlayerModule.CameraModule)
local Update = CameraModule.Update

function CameraModule:Update(dt)
	Update(self, dt)
	print("Hooked to frame update!")
end