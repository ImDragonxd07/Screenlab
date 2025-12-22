--https://www.redblobgames.com/articles/visibility/
local module = {}
local lights = {}

module.Settings = {
	IgnoreLayer = -1,
	RaycastStep = 2,
}


local ray  = require(script.Parent["Screenlab.Raycast"])

local engine = require(game.ReplicatedStorage.ScreenLAB.ScreenlabCore)
local Graphics = require(script.Parent.Drivers["Screenlab.Drivers.Graphics"])
local GlobalEvents = require(script.Parent["Screenlab.GlobalEvent"])
local Point    = Graphics.Delaunay.Point

local function rotateVector2(vector, angle)
	local cosAngle = math.cos(angle)
	local sinAngle = math.sin(angle)

	local x = vector.X * cosAngle - vector.Y * sinAngle
	local y = vector.X * sinAngle + vector.Y * cosAngle

	return Vector2.new(x, y)
end


local function cornerInShadow(corner, shadowCorners)
	for _, shadowCorner in ipairs(shadowCorners) do
		if corner == shadowCorner then
			return true
		end
	end
	return false
end


local function castRays360(lightPosition, lightobj,intensity)
	local hits = {}
	for angle = 0, 359, module.Settings.RaycastStep do
		local direction = rotateVector2(Vector2.new(1, 0), math.rad(angle))
		local rayHits = ray.Cast(lightobj.Position, direction, module.Settings.IgnoreLayer)

		if #rayHits > 0 then
			local hit = rayHits[1]
			local hitObject = hit
			local hitSize = hitObject.AbsoluteSize
			local hitCenter = hit.AbsolutePosition + hitSize / 2
			local lightCenter = lightPosition + lightobj.AbsoluteSize / 2
			local hitPosition = hit.AbsolutePosition
			local Distance = (hitCenter - lightCenter).Magnitude
			if(Distance > intensity) then
				return hits
			end
			local topLeft = hitPosition
			local topRight = hitPosition + Vector2.new(hitSize.X, 0)
			local bottomLeft = hitPosition + Vector2.new(0, hitSize.Y)
			local bottomRight = hitPosition + hitSize
			local cornersInShadow = {}
			local lightSize = lightobj.AbsoluteSize
			local lightTopLeft = lightPosition
			local lightBottomRight = lightPosition + lightSize
			local lightInsideObject = 
				(lightTopLeft.X > topLeft.X and lightBottomRight.X < bottomRight.X) and
				(lightTopLeft.Y > topLeft.Y and lightBottomRight.Y < bottomRight.Y)
			if direction.X <= 0 and direction.Y <= 0 then
				-- topleft
				cornersInShadow["topLeft"] = true
			elseif direction.X <= 0 and direction.Y >= 0 then
				-- bottomleft
				cornersInShadow["bottomLeft"] = true
			elseif direction.X >= 0 and direction.Y <= 0 then
				-- topright
				cornersInShadow["topRight"] = true
			elseif direction.X >= 0 and direction.Y >= 0 then
				-- bottom right
				cornersInShadow["botttomRight"] = true
			end
			table.insert(hits, { object = hitObject, corners = cornersInShadow, inside = lightInsideObject })
		end
	end

	return hits
end


local function drawHitCorners(RenderLayer, hits, lightobj)
	for _,hit in ipairs(hits) do
		local hitObject = hit.object
		local cornersInShadow = hit.corners
		local isinside = hit.inside
		local vp = workspace.CurrentCamera.ViewportSize
		local screenWidth, screenHeight = vp.X, vp.Y
		local points = {}
		if isinside then
			Graphics.RenderRect(RenderLayer,Vector2.new(0,0),Vector2.new(screenWidth,screenHeight),Color3.new(0, 0, 0))
		else
			local hitPosition = hitObject.AbsolutePosition
			local hitSize = hitObject.AbsoluteSize
			local ssize = 10000
			local objectCorners = {
				topLeft = hitPosition,
				topRight = hitPosition + Vector2.new(hitSize.X, 0),
				bottomLeft = hitPosition + Vector2.new(0, hitSize.Y),
				bottomRight = hitPosition + hitSize
			}
			for i, corner in pairs(objectCorners) do
				if not cornersInShadow[i] then
					table.insert(points, Point(corner.X, corner.Y))
					local direction = (corner - lightobj.AbsolutePosition).unit
					local shadowEndPosition = corner + direction * 10000
					table.insert(points, Point(shadowEndPosition.X,shadowEndPosition.Y))
				end
			end
			local triangles = Graphics.Delaunay.triangulate(unpack(points))
			for i, triangle in ipairs(triangles) do
				Graphics.RenderPoly(RenderLayer, Vector2.new(triangle.p1.x, triangle.p1.y), Vector2.new(triangle.p2.x, triangle.p2.y), Vector2.new(triangle.p3.x, triangle.p3.y), Color3.new(0, 0, 0))
			end
		end
	end

end

local ShadowObjects = {}
module.AddLight = function(obj, Ins) 
	table.insert(lights, Ins)
	local lightobj = Ins.Settings.Data.Object() 
	local RenderLayer = Graphics.NewRenderLayer() 
	local function Update()
		local lightPosition = lightobj.AbsolutePosition
		RenderLayer.NewFrame()
		local hits = castRays360(lightPosition, lightobj,Ins.Settings.Intensity) 
		for _, hit in ipairs(hits) do
			local obj = hit.object
			if not ShadowObjects [obj] then
				ShadowObjects [obj] = true
				obj:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
					Update()
				end)
				obj.Destroying:Connect(function()
					ShadowObjects [obj] = nil
				end)
			end
		end
		drawHitCorners (RenderLayer, hits, lightobj)
	end
	lightobj:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		Update()
	end)
	GlobalEvents.Events.NewObj:Connect(function()
		Update()
	end)
	Update()
end

module.RemoveLight = function(obj)
	for i,v in pairs(lights) do
		if(v.Settings.Data.Object == obj) then
			table.remove(lights, v)
		end
	end
end

return module