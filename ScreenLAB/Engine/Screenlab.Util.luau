local module = {}
module.ptr = function (value)
	local _pointer
	if value then
		_pointer= value
	else
		return _pointer
	end
end


module.StringToAssetId = function(str)
	local final = str
	if not string.find(final, "rbxassetid://") then
		final = "rbxassetid://" .. final
	end
	return final
end

return module
