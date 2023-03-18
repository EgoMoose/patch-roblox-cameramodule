--!nonstrict

local ProxyTemplate = script:WaitForChild("ProxyTemplate")

local function createModuleProxy(value)
	local proxyModule = ProxyTemplate:Clone()
	require(proxyModule:WaitForChild("_Proxy")).Value = value
	return proxyModule
end

local function addDescendantsProxies(parentModule, newParent)
	for _, child in parentModule:GetChildren() do
		if child:IsA("ModuleScript") then
			local proxyModule = createModuleProxy(require(child))
			proxyModule.Name = child.Name
			proxyModule.Parent = newParent

			addDescendantsProxies(child, proxyModule)
		elseif child:IsA("ValueBase") then
			local copyValue = child:Clone()
			copyValue.Parent = newParent

			copyValue.Changed:Connect(function(value)
				if child.Value ~= value then
					child.Value = value
				end
			end)

			child.Changed:Connect(function(value)
				copyValue.Value = value
			end)

			addDescendantsProxies(child, copyValue)
		end
	end
end

local function patch(CameraModule: ModuleScript)
	local TransparencyController = require(CameraModule:WaitForChild("TransparencyController"))
	local oldTransparencyControllerNew = TransparencyController.new

	local result = nil
	local bind = Instance.new("BindableEvent")

	TransparencyController.new = function(...)
		-- set this back its original value so it behaves as expected next time it's called
		TransparencyController.new = oldTransparencyControllerNew

		-- get the parent function and call it
		-- this is equivalent to calling `result = CameraModule.new()`
		local cameraModuleNew = debug.info(2, "f")
		result = cameraModuleNew()

		-- yield forever so we don't continue to leak memory
		bind:Fire()
		bind.Event:Wait()
	end

	-- the patch has been setup, now we wait!
	task.spawn(function()
		require(CameraModule)
	end)

	while not result do
		bind.Event:Wait()
	end

	-- create a bunch of proxies so we don't actually have to move anything
	-- this ensures we don't breaks anything reliant on the original parent child relationship
	local newCameraModule = createModuleProxy(result)
	newCameraModule.Name = CameraModule.Name
	newCameraModule.Parent = CameraModule.Parent

	addDescendantsProxies(CameraModule, newCameraModule)

	CameraModule.Name = "_" .. CameraModule.Name
end

return patch