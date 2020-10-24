local FFLAG_OVERRIDES = {
	["UserRemoveTheCameraApi"] = false
}

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

return function()
	return FakeUserSettings
end