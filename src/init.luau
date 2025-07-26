--!strict

local ProxyTemplate = script:WaitForChild("ProxyTemplate") :: ModuleScript

type ProxyValue<T> = { value: T }

local function unknownRequire(instance: Instance)
	assert(instance:IsA("ModuleScript"), "The provided instance was not a ModuleScript.")
	return require(instance) :: any
end

local function createModuleProxy<T>(value: T)
	local proxyModule = ProxyTemplate:Clone()
	local proxy = unknownRequire(proxyModule:WaitForChild("_Proxy")) :: ProxyValue<T>
	proxy.value = value
	return proxyModule
end

local function addDescendantsProxies(parentModule, newParent)
	for _, child in parentModule:GetChildren() do
		if child:IsA("ModuleScript") then
			local value = unknownRequire(child)
			local proxyModule = createModuleProxy(value)
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
	-- stylua: ignore
	local TransparencyController = unknownRequire(CameraModule:WaitForChild("TransparencyController")) :: { new: (...any) -> ...any }
	local oldTransparencyControllerNew = TransparencyController.new

	local result = nil
	local thread = coroutine.running()

	TransparencyController.new = function(...)
		-- set this back its original value so it behaves as expected next time it's called
		TransparencyController.new = oldTransparencyControllerNew

		-- get the parent function and call it
		-- this is equivalent to calling `result = CameraModule.new()`
		local cameraModuleNew = debug.info(2, "f")
		result = cameraModuleNew()

		-- unblock our waiting thread
		if coroutine.status(thread) == "suspended" then
			task.spawn(thread)
		end

		-- local activeThread = coroutine.running()
		-- task.defer(task.cancel, activeThread)

		-- yield forever so we don't continue to leak memory
		coroutine.yield()
	end

	-- the patch has been setup, now we wait!
	task.spawn(unknownRequire, CameraModule)

	while not result do
		coroutine.yield()
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
