local module = {}

local SimulatedObjects = {}
module.Gravity = 9.8
module.TerminalVelocity = 50
module.SimulationSteps = 2

local GlobalEvent = require(script.Parent["Screenlab.GlobalEvent"])
local insert = game:GetService("GuiService"):GetGuiInset()
local Camera = require(script.Parent["Screenlab.Camera"])


local PIXEL_TO_METER = 5
local referenceHeight = 830

local function CheckUICollision(pos1, size1, pos2, size2, offset)

	local left1, right1 = pos1.X, pos1.X + size1.X
	local top1, bottom1 = pos1.Y, pos1.Y + size1.Y
	local left2, right2 = pos2.X, pos2.X + size2.X
	local top2, bottom2 = pos2.Y, pos2.Y + size2.Y

	local xCollision = right1 > left2 and left1 < right2
	local yCollision = bottom1 > top2 and top1 < bottom2

	local xOverlap = 0
	local yOverlap = 0

	if xCollision then
		xOverlap = math.min(right1 - left2, right2 - left1)
	end

	if yCollision then
		yOverlap = math.min(bottom1 - top2, bottom2 - top1)
	end

	return xOverlap, yOverlap, xCollision, yCollision
end

module.RegisterSprite = function(ins)
	-- STATIC OBJECTS ARE RECOGNISED BY THE PHYSICS ENGINE BUT NOT EFFECTED BY FORCES, SIMULATED OBJECTS ARE EFFECTED BY FORCES. FOR AN OBJECT TO BE REGISTERED BUT NOT AFFECTED BY GRAVITY, SET SIMULATED AND STATIC TO TRUE
	local OFFSET = -1
	task.spawn(function()
		local Settings = ins.Settings
		local obj = Settings.Data.Object()
		local previoustouch = nil
		local tblnum = #SimulatedObjects + 1
		table.insert(SimulatedObjects, tblnum, Settings.Data)
		local falltime = 0
		local accel = 0
		local forces = ins.Forces
		local Nextpos = nil
		local velocity = Vector2.new()

		--module.OnPositionChangedRemote = function(val)
		--	if Settings.Simulate then
		--		Nextpos = val
		--		return false
		--	else
		--		return true
		--	end
		--end
		--Settings.Data.CreateFunctionHook("Position", script, "OnPositionChangedRemote")

		local refreshRate = 1 / 60
		local timeElapsed = 0
		forces.VelocityEvent:Connect(function(vel)
			velocity += vel 
		end)
		
		
		forces.PositionEvent:Connect(function(pos)
			Nextpos = pos
		end)
		
		GlobalEvent.Events.Update:Connect(function(dt)
			timeElapsed += dt
			if timeElapsed <= refreshRate - (5/1000) then return end
			timeElapsed = 0
			-- Unregister the object when done
			if not Settings.Register then
				if Settings.printdbg then
					print("Unregister physics " .. Settings.Data.Object().Name)
				end
				table.remove(SimulatedObjects, tblnum)
				return
			end
			
			if Settings.Register and Settings.Simulate then
				local AbsoluteOffset = -Camera.CurrentCamera.Position.vector2
				local PreCalculatedPos = obj.Position
				local grounded = false
				local touched = false
				local newvel = Vector2.new()
				local frozentable = table.clone(SimulatedObjects)
				local screenHeight = workspace.CurrentCamera.ViewportSize.Y
				local screenScale = screenHeight / referenceHeight
				for step = 1, module.SimulationSteps do
					local futurePos = obj.AbsolutePosition + AbsoluteOffset + (velocity * step / module.SimulationSteps)
					--local nf = Instance.new("Frame")
					--nf.Size = UDim2.fromOffset(10,10)
					--nf.Position = UDim2.fromOffset(futurePos.X,futurePos.Y)
					--nf.AnchorPoint = Vector2.new(0.5,0.5)
					--nf.Parent = game.Players.LocalPlayer.PlayerGui.ScreenLabUI
					for _, v in pairs(frozentable) do
						local vcollisiongroup = v.GetComponentsByType("Physics")[1].Settings.CollisionGroup
						if v.Object() ~= obj and vcollisiongroup == Settings.CollisionGroup then
							local vPos = v.Object().AbsolutePosition + AbsoluteOffset

							local xOverlap, yOverlap, xCollision, yCollision = CheckUICollision(futurePos, obj.AbsoluteSize, vPos, v.Object().AbsoluteSize)

							if xCollision and yCollision then
								touched = true
								falltime = 0
								accel = 0

								if yOverlap < xOverlap then
									-- Y Collision
									if futurePos.Y < vPos.Y then
										grounded = true
										PreCalculatedPos = UDim2.new(PreCalculatedPos.X.Scale, PreCalculatedPos.X.Offset, 0, (vPos.Y - obj.AbsoluteSize.Y - OFFSET))
									else
										PreCalculatedPos = UDim2.new(PreCalculatedPos.X.Scale, PreCalculatedPos.X.Offset, 0, (vPos.Y + v.Object().AbsoluteSize.Y + OFFSET + 2))
									end
									if math.abs(velocity.Y) > 1 then
										velocity = Vector2.new(velocity.X, -velocity.Y * forces.Bounciness)
									else
										velocity = Vector2.new(velocity.X, 0)
										falltime = 0
									end
								else
									-- X Collision
									if futurePos.X < vPos.X then
										PreCalculatedPos = UDim2.new(0, (vPos.X - obj.AbsoluteSize.X - OFFSET - 2), PreCalculatedPos.Y.Scale, PreCalculatedPos.Y.Offset)
									else
										PreCalculatedPos = UDim2.new(0, (vPos.X + v.Object().AbsoluteSize.X + OFFSET + 2), PreCalculatedPos.Y.Scale, PreCalculatedPos.Y.Offset)
									end
								end

								if v.Object() ~= previoustouch then
									previoustouch = v.Object()
									if Settings.printdbg  then
										print("TOUCHED " .. tostring(touched) .. " [" .. tostring(v.Object().Name) .. "]")
									end
									Settings.OnTouch:Fire(v.Object())
								end
								--break
							end
						end
					end
				end

				forces.Grounded = grounded

				if forces.Enable then
					local calcfric = 0
	
					if grounded then
						calcfric = 1 - forces.Friction

					else
						calcfric = 1 - forces.AirResistance
					end
					newvel += velocity
					newvel *= calcfric
					if Settings.printdbg then
						print("Friction: " .. calcfric)
					end
					if not grounded then
						falltime += refreshRate
						accel = (module.Gravity * falltime )* (PIXEL_TO_METER/ screenScale)
						
					end

					
					newvel = Vector2.new(
						math.clamp(newvel.X, -module.TerminalVelocity, module.TerminalVelocity),
						math.clamp(newvel.Y, -module.TerminalVelocity, module.TerminalVelocity)
					)


					if Settings.printdbg then
						print(Settings.Data.Object().Name)
						print("grounded? " .. tostring(grounded))
						print("xvelocity " .. velocity.X, "\n yvelocity " .. velocity.Y, "\n accel " .. accel, "\n falltime " .. falltime .. "\n gravityvalue " .. accel * falltime)
						print("Forces..")
						print("Gravity: " .. module.Gravity)
					end
					
	
					velocity = newvel
					forces.CurrentVelocity = velocity
					PreCalculatedPos += UDim2.new(0, velocity.X, 0, velocity.Y)

					if not grounded then
						PreCalculatedPos = PreCalculatedPos + UDim2.new(0, 0, 0, math.clamp(accel, -module.TerminalVelocity, module.TerminalVelocity))
					end
					if Nextpos then
						velocity = Vector2.new(0,0)
						obj.Position = Nextpos
						Nextpos = nil
					else
						obj.Position = PreCalculatedPos
					end
				end
			end
		end)


	end)
end

return module
