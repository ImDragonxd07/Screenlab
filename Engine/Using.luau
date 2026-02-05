local m,l={},{}
local function loader(n:string)
	if m[n]then return m[n]end
	if l[n]then m[n]={}return m[n]end
	l[n]=1
	m[n]=require(script.Parent:FindFirstChild(n,1)or script.Parent.Parent:FindFirstChild(n,1)or error("Not found"))
	l[n]=nil
	return m[n]
end
return setmetatable({cache = m}, {
	__call = function(_, n)
		return loader(n)
	end
})