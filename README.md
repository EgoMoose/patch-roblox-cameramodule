# patch-roblox-cameramodule
Module that provides access to the CameraModule API in the Roblox PlayerModule

## How to use
* [Wally](https://wally.run/package/egomoose/patch-cameramodule)
* [Releases](https://github.com/EgoMoose/patch-roblox-cameramodule/releases)

This module returns a function that should be called on the CameraModule before PlayerModule has had a chance to run. The easiest place to do this is in the `PlayerScriptsLoader`, but this may or may not be the right place depending on the rest of your project.

For example:

```Lua
-- PlayerScriptsLoader
local PlayerModule = script.Parent:WaitForChild("PlayerModule")
local CameraModule = PlayerModule:WaitForChild("CameraModule")
local PatchCameraModule = script.Parent:WaitForChild("PatchCameraModule")

require(PatchCameraModule)(CameraModule)

local playerModuleObject = require(PlayerModule)
local cameraModuleObject = playerModuleObject:GetCameras()

-- the api is public!
print(cameraModuleObject)

-- can overwrite the functions
local prevUpdateFunc = cameraModuleObject.Update
function cameraModuleObject.Update(self, ...)
	print(...)
	prevUpdateFunc(self, ...)
end
```

## A note on CameraModule descendants
When this patch runs it renames the `CameraModule` to `_CameraModule` and creates a redirection module named `CameraModule` that points to the new patched value. This is done b/c as a result of the patch trying to require `_CameraModule` will cause a infinite yield.

```Lua
local CameraModule = require(game.Players.LocalPlayer.PlayerModule.CameraModule)
print(CameraModule) -- this works!

local CameraModule = require(game.Players.LocalPlayer.PlayerModule._CameraModule)
print(CameraModule) -- this will never print b/c the above line yields forever!
```

As a result of this an important decision needed to be made on the development end of this patch. The module named `CameraModule` returns the patched value, but it doesn't have any of the descendants that `_CameraModule` does. This is problematic if the user of this patch is trying to access any of those descendants by standard naming conventions.

```Lua
-- This doesn't exist!
local TransparencyController = require(game.Players.LocalPlayer.PlayerModule.CameraModule.TransparencyController)
-- It's here instead!
local TransparencyController = require(game.Players.LocalPlayer.PlayerModule._CameraModule.TransparencyController)
```

You might just suggest to move all the descendants of `_CameraModule` to the new `CameraModule` and at the time of writing this that would work, but it could easily break in the future if any of the camera code becomes dependant on the expected parent-child relationship.

The solution I decided to use instead is to continue to use redirection modules and proxy values. Instead of moving the descendants out from `_CameraModule` I instead create a duplicate hierarchy under `CameraModule` with module scrips and values that redirect to the values under `_CameraModule`.

This is the best way to get behavior parity with the default CameraModule that I can think of at the moment. If you want to be extra safe you can always reference the path via `_CameraModule` to avoid worrying about the redirection modules and proxies.