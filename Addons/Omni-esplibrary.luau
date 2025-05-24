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

		Toggle = {
			Boxes = true,
			Names = true,
			Tracers = false,
		},

		Team = {
			Check = false, -- Skip rendering if player is on the same team
			UseTeamColor = false, -- Use team color instead of default color
		},

		Visual = {
			Color = Color3.new(1, 1, 1),
			BoxThickness = 1,
			ExtraBoxHeight = 10,
		},
	}

	local function SetupPlayerESP(plr)
		if not ESPBoxes[plr] then
			local outline = Drawing.new("Square")
			outline.Color = Color3.new(0, 0, 0)
			outline.Thickness = Config.Visual.BoxThickness
			outline.Filled = false
			outline.Visible = false
			ESPBoxOutlines[plr] = outline

			local box = Drawing.new("Square")
			box.Color = Config.Visual.Color
			box.Thickness = Config.Visual.BoxThickness
			box.Filled = false
			box.Visible = false
			ESPBoxes[plr] = box

			local name = Drawing.new("Text")
			name.Text = plr.Name
			name.Size = 16
			name.Color = Config.Visual.Color
			name.Center = true
			name.Outline = true
			name.Visible = false
			ESPNames[plr] = name

			local tracer = Drawing.new("Line")
			tracer.Color = Config.Visual.Color
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
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
				table.insert(parts, part)
			end
		end

		local minX, minY = math.huge, math.huge
		local maxX, maxY = -math.huge, -math.huge

		for _, part in pairs(parts) do
			local size = part.Size / 2
			local corners = {
				part.CFrame * Vector3.new(-size.X, -size.Y, -size.Z),
				part.CFrame * Vector3.new(-size.X, -size.Y, size.Z),
				part.CFrame * Vector3.new(-size.X, size.Y, -size.Z),
				part.CFrame * Vector3.new(-size.X, size.Y, size.Z),
				part.CFrame * Vector3.new(size.X, -size.Y, -size.Z),
				part.CFrame * Vector3.new(size.X, -size.Y, size.Z),
				part.CFrame * Vector3.new(size.X, size.Y, -size.Z),
				part.CFrame * Vector3.new(size.X, size.Y, size.Z),
			}
			for _, corner in ipairs(corners) do
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
			return
		end
		return Vector2.new(minX, minY), Vector2.new(maxX, maxY)
	end

	RunService.RenderStepped:Connect(function()
		if not Config.Enabled then
			for _, box in pairs(ESPBoxes) do
				box.Visible = false
			end
			for _, outline in pairs(ESPBoxOutlines) do
				outline.Visible = false
			end
			for _, name in pairs(ESPNames) do
				name.Visible = false
			end
			for _, tracer in pairs(ESPTracers) do
				tracer.Visible = false
			end
			return
		end

		for _, plr in pairs(Players:GetPlayers()) do
			if plr == Player then
				continue
			end
			if Config.Team.Check and plr.Team == Player.Team then
				continue
			end
			if not (plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")) then
				continue
			end

			local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
			if humanoid humanoid.Health < 1 then
				ESPBoxes[plr].Visible = false
				ESPBoxOutlines[plr].Visible = false
				ESPNames[plr].Visible = false
				ESPTracers[plr].Visible = false
				continue
			end

			SetupPlayerESP(plr)

			local rootPart = plr.Character.HumanoidRootPart
			local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
			if not onScreen then
				ESPBoxes[plr].Visible = false
				ESPBoxOutlines[plr].Visible = false
				ESPNames[plr].Visible = false
				ESPTracers[plr].Visible = false
				continue
			end

			local topLeft, bottomRight = GetCharacterBoundingBox(plr)
			if not topLeft or not bottomRight then
				ESPBoxes[plr].Visible = false
				ESPBoxOutlines[plr].Visible = false
				ESPNames[plr].Visible = false
				ESPTracers[plr].Visible = false
				continue
			end

			local boxSize = bottomRight - topLeft
			boxSize = Vector2.new(boxSize.X, boxSize.Y + Config.Visual.ExtraBoxHeight)
			local color = Config.Team.UseTeamColor and plr.TeamColor.Color or Config.Visual.Color

			-- Boxes
			if Config.Toggle.Boxes then
				ESPBoxOutlines[plr].Visible = true
				ESPBoxOutlines[plr].Position = topLeft - Vector2.new(1, 1)
				ESPBoxOutlines[plr].Size = boxSize + Vector2.new(2, 2)
				ESPBoxOutlines[plr].Color = Color3.new(0, 0, 0)
				ESPBoxOutlines[plr].Thickness = Config.Visual.BoxThickness

				ESPBoxes[plr].Visible = true
				ESPBoxes[plr].Position = topLeft
				ESPBoxes[plr].Size = boxSize
				ESPBoxes[plr].Color = color
				ESPBoxes[plr].Thickness = Config.Visual.BoxThickness
			else
				ESPBoxes[plr].Visible = false
				ESPBoxOutlines[plr].Visible = false
			end

			-- Names
			if Config.Toggle.Names then
				ESPNames[plr].Visible = true
				ESPNames[plr].Position = Vector2.new((topLeft.X + bottomRight.X) / 2, topLeft.Y - 20)
				ESPNames[plr].Text = plr.Name
				ESPNames[plr].Color = color
			else
				ESPNames[plr].Visible = false
			end

			-- Tracers
			if Config.Toggle.Tracers then
				ESPTracers[plr].Visible = true
				ESPTracers[plr].From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
				ESPTracers[plr].To = Vector2.new(screenPos.X, screenPos.Y)
				ESPTracers[plr].Color = color
			else
				ESPTracers[plr].Visible = false
			end
		end
	end)

	Players.PlayerRemoving:Connect(function(plr)
		if ESPBoxes[plr] then
			ESPBoxes[plr]:Remove()
			ESPBoxes[plr] = nil
		end
		if ESPBoxOutlines[plr] then
			ESPBoxOutlines[plr]:Remove()
			ESPBoxOutlines[plr] = nil
		end
		if ESPNames[plr] then
			ESPNames[plr]:Remove()
			ESPNames[plr] = nil
		end
		if ESPTracers[plr] then
			ESPTracers[plr]:Remove()
			ESPTracers[plr] = nil
		end
	end)

	return {
		Config = Config,
	}
end)()
