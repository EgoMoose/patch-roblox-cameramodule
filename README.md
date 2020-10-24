# CameraModule-API-Public-Override
Module that overrides the FFlagUserRemoveTheCameraApi

## How to use
Simply put this module underneath the `PlayerScriptsLoader` and require it before the `PlayerModule` is required.

Something like this:

```Lua
-- PlayerScriptsLoader
local PlayerModule = script.Parent:WaitForChild("PlayerModule")
local CameraInjector = script:WaitForChild("CameraInjector")

require(CameraInjector)
require(PlayerModule)
```

Now you can access the camera API like normal before the `UserRemoveTheCameraApi` FFlag existed.