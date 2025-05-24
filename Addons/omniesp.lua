return (function()
	local Players = game:GetService("Players")
	local Player = Players.LocalPlayer
	local Camera = workspace.CurrentCamera
	local RunService = game:GetService("RunService")


	local ESPBoxes = {}
	local ESPBoxOutlines = {}
	local ESPNames = {}
	local ESPTracers = {}


	local Config = {
		Enabled = false,
		Boxes = true,
		Names = true,
		Tracers = false,
		TeamColor = false,
		Color = Color3.new(1, 1, 1),
		BoxThickness = 1,
		ExtraBottomPadding = 10,
	}


	local function SetupPlayerESP(plr)
		if not ESPBoxes[plr] then
			local outline = Drawing.new("Square")
			outline.Color = Color3.new(0, 0, 0)
			outline.Thickness = Config.BoxThickness + 1
			outline.Filled = false
			outline.Visible = false
			ESPBoxOutlines[plr] = outline

			local box = Drawing.new("Square")
			box.Color = Config.Color
			box.Thickness = Config.BoxThickness
			box.Filled = false
			box.Visible = false
			ESPBoxes[plr] = box

			local name = Drawing.new("Text")
			name.Text = plr.Name
			name.Size = 16
			name.Color = Config.Color
			name.Center = true
			name.Outline = true
			name.Visible = false
			ESPNames[plr] = name

			local tracer = Drawing.new("Line")
			tracer.Color = Config.Color
			tracer.Thickness = 1
			tracer.Visible = false
			ESPTracers[plr] = tracer
		end
	end


	local function GetCharacterBoundingBox(plr)
		local char = plr.Character
		if not char then
			return
		end
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then
			return
		end

		local parts = {}
		for _, part in pairs(char:GetChildren()) do
			if part:IsA("BasePart") then
				table.insert(parts, part)
			end
		end

		local minX, minY = math.huge, math.huge
		local maxX, maxY = -math.huge, -math.huge

		for _, part in pairs(parts) do
			local corners = {
				part.CFrame * Vector3.new(-part.Size.X / 2, -part.Size.Y / 2, -part.Size.Z / 2),
				part.CFrame * Vector3.new(-part.Size.X / 2, -part.Size.Y / 2, part.Size.Z / 2),
				part.CFrame * Vector3.new(-part.Size.X / 2, part.Size.Y / 2, -part.Size.Z / 2),
				part.CFrame * Vector3.new(-part.Size.X / 2, part.Size.Y / 2, part.Size.Z / 2),
				part.CFrame * Vector3.new(part.Size.X / 2, -part.Size.Y / 2, -part.Size.Z / 2),
				part.CFrame * Vector3.new(part.Size.X / 2, -part.Size.Y / 2, part.Size.Z / 2),
				part.CFrame * Vector3.new(part.Size.X / 2, part.Size.Y / 2, -part.Size.Z / 2),
				part.CFrame * Vector3.new(part.Size.X / 2, part.Size.Y / 2, part.Size.Z / 2),
			}

			for _, corner in pairs(corners) do
				local screenPos, onScreen = Camera:WorldToViewportPoint(corner)
				if onScreen then
					minX = math.min(minX, screenPos.X)
					minY = math.min(minY, screenPos.Y)
					maxX = math.max(maxX, screenPos.X)
					maxY = math.max(maxY, screenPos.Y)
				end
			end
		end

		if minX == math.huge then
			return nil, nil 
		end

		return Vector2.new(minX, minY), Vector2.new(maxX, maxY)
	end


	RunService.RenderStepped:Connect(function()
		if not Config.Enabled then
			for plr, box in pairs(ESPBoxes) do
				box.Visible = false
			end
			for plr, outline in pairs(ESPBoxOutlines) do
				outline.Visible = false
			end
			for plr, name in pairs(ESPNames) do
				name.Visible = false
			end
			for plr, tracer in pairs(ESPTracers) do
				tracer.Visible = false
			end
			return
		end

		for _, plr in pairs(Players:GetPlayers()) do
			if
				plr ~= Player
				and plr.Character
				and plr.Character:FindFirstChild("HumanoidRootPart")
				and plr.Character:FindFirstChildOfClass("Humanoid")
				and plr.Character.Humanoid.Health > 0
			then
				SetupPlayerESP(plr)

				local rootPart = plr.Character.HumanoidRootPart
				local pos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
				if onScreen then
					local topLeft, bottomRight = GetCharacterBoundingBox(plr)
					if not topLeft or not bottomRight then
						ESPBoxes[plr].Visible = false
						ESPBoxOutlines[plr].Visible = false
						ESPNames[plr].Visible = false
						ESPTracers[plr].Visible = false
					else
						local boxSize = bottomRight - topLeft
						boxSize = Vector2.new(boxSize.X, boxSize.Y + Config.ExtraBottomPadding)

						if Config.Boxes then
							ESPBoxOutlines[plr].Visible = true
							ESPBoxOutlines[plr].Position = topLeft - Vector2.new(1, 1)
							ESPBoxOutlines[plr].Size = boxSize + Vector2.new(2, 2)
							ESPBoxOutlines[plr].Thickness = Config.BoxThickness + 2

							ESPBoxes[plr].Visible = true
							ESPBoxes[plr].Position = topLeft
							ESPBoxes[plr].Size = boxSize
							ESPBoxes[plr].Thickness = Config.BoxThickness

							local col = Config.TeamColor and plr.TeamColor.Color or Config.Color
							ESPBoxes[plr].Color = col
							ESPBoxOutlines[plr].Color = Color3.new(0, 0, 0)
						else
							ESPBoxes[plr].Visible = false
							ESPBoxOutlines[plr].Visible = false
						end

						if Config.Names then
							ESPNames[plr].Visible = true
							ESPNames[plr].Position = Vector2.new((topLeft.X + bottomRight.X) / 2, topLeft.Y - 20)
							ESPNames[plr].Text = plr.Name
							ESPNames[plr].Color = Config.TeamColor and plr.TeamColor.Color or Config.Color
						else
							ESPNames[plr].Visible = false
						end

						if Config.Tracers then
							ESPTracers[plr].Visible = true
							ESPTracers[plr].From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
							ESPTracers[plr].To = Vector2.new(pos.X, pos.Y)
							ESPTracers[plr].Color = Config.TeamColor and plr.TeamColor.Color or Config.Color
						else
							ESPTracers[plr].Visible = false
						end
					end
				else
					ESPBoxes[plr].Visible = false
					ESPBoxOutlines[plr].Visible = false
					ESPNames[plr].Visible = false
					ESPTracers[plr].Visible = false
				end
			else
				if ESPBoxes[plr] then
					ESPBoxes[plr].Visible = false
				end
				if ESPBoxOutlines[plr] then
					ESPBoxOutlines[plr].Visible = false
				end
				if ESPNames[plr] then
					ESPNames[plr].Visible = false
				end
				if ESPTracers[plr] then
					ESPTracers[plr].Visible = false
				end
			end
		end
	end)


	return {
		Config = Config,
	}
end)()
