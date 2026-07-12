local module = {}
module.__index = module 

function module:New()
	return setmetatable({callbacks = {}}, module)
end

function module:Connect(func)
	table.insert(self.callbacks, func)
end

function module:Fire(...)
	for _, v in ipairs(self.callbacks) do
		coroutine.resume(coroutine.create(v), ...)
	end
end

function module:Destroy()
	self.callbacks = nil
	setmetatable(self, nil)
	table.clear(self)
	table.freeze(self)
end


return module