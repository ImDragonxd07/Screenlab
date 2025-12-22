local module = {}
local engine = require(game.ReplicatedStorage.ScreenLAB.ScreenlabCore)

local function newvec(x, y)
	return {x = x, y = y}
end

local function subtractvect(v1, v2)
	return newvec(v1.x - v2.x, v1.y - v2.y)
end

local function calc(v1, v2)
	return v1.x * v2.y - v1.y * v2.x
end

local function lineIntersection(p1, p2, q1, q2)
	local epsilon = 1e-9
	local r = subtractvect(p2, p1)
	local s = subtractvect(q2, q1)
	local rxs = calc(r, s)
	local qpxr = calc(subtractvect(q1, p1), r)

	if math.abs(rxs) < epsilon and math.abs(qpxr) < epsilon then
		return false, nil 
	elseif math.abs(rxs) < epsilon then
		return false, nil 
	end

	local t = calc(subtractvect(q1, p1), s) / rxs
	local u = calc(subtractvect(q1, p1), r) / rxs

	if rxs ~= 0 and t >= 0 and t <= 1 and u >= 0 and u <= 1 then
		local intersection = newvec(p1.x + t * r.x, p1.y + t * r.y)
		return true, intersection  -- Intersection found
	else
		return false, nil  -- No intersection
	end
end

local function distance(v1, v2)
	return math.sqrt((v1.x - v2.x) ^ 2 + (v1.y - v2.y) ^ 2)
end

local function getOffset(pos, ref)
	local OffsetXPos = pos.X.Scale * ref.AbsoluteSize.X + pos.X.Offset
	local OffsetYPos = pos.Y.Scale * ref.AbsoluteSize.Y + pos.Y.Offset
	return newvec(OffsetXPos, OffsetYPos)
end

module.Cast = function(vectorOrigin, vectorDirection, ignorelayer, raylength)
	raylength = raylength or 10000
	local guiElements = engine.playerData.ScreenLabWindow.Sprites:GetChildren()
	local parentSize = engine.playerData.ScreenLabWindow.AbsoluteSize
	local rayOrigin = getOffset(vectorOrigin, engine.playerData.ScreenLabWindow)
	local rayDirection = newvec(vectorDirection.X, vectorDirection.Y)
	local hits = {}
	for _, guiElement in pairs(guiElements) do
		if guiElement.ZIndex ~= ignorelayer then
			local position = guiElement.AbsolutePosition
			local size = guiElement.AbsoluteSize
			local topLeft = position
			local topRight = newvec(position.x + size.x, position.y)
			local bottomLeft = newvec(position.x, position.y + size.y)
			local bottomRight = newvec(position.x + size.x, position.y + size.y)

			local edges = {
				{topLeft, topRight},
				{topRight, bottomRight},
				{bottomRight, bottomLeft},
				{bottomLeft, topLeft}
			}

			for _, edge in ipairs(edges) do
				local rayEnd = newvec(rayOrigin.x + rayDirection.x * raylength, rayOrigin.y + rayDirection.y * raylength)  -- Extend the ray far enough
				local hit, intersection = lineIntersection(rayOrigin, rayEnd, edge[1], edge[2])
				if hit then
					if intersection ~= rayOrigin then
						table.insert(hits, {element = guiElement, distance = distance(rayOrigin, intersection)})
						break
					end
				end
			end
		end
	end
	table.sort(hits, function(a, b)
		return a.distance < b.distance
	end)
	local sorted = {}
	for i, hit in ipairs(hits) do
		sorted[i] = hit.element
	end
	return sorted
end

return module
