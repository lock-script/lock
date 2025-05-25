return (function()
	local Players = game:GetService("Players")
	local Player = Players.LocalPlayer
	local Camera = workspace.CurrentCamera
	local RunService = game:GetService("RunService")

	local ESPBoxes = {}
	local ESPBoxOutlines = {}
	local ESPNames = {}
	local ESPDistances = {}
	local ESPTracers = {}
	local ESPHealthBars = {}
	local ESPHealthBarOutlines = {}

	local Config = {
		Enabled = false,

		Toggle = {
			Boxes = true,
			Names = true,
			Tracers = false,
			Distance = true,
			HealthBar = true,
		},

		Team = {
			Check = false,
			UseTeamColor = false,
		},

		Visual = {
			Color = Color3.new(1, 1, 1),
			Outlines = true,
			Font = 2,
			FontSize = 10,
		},
	}

	local function SetupPlayerESP(plr)
		if not ESPBoxes[plr] then
			local outline = Drawing.new("Square")
			outline.Color = Color3.new(0, 0, 0)
			outline.Thickness = 1.5
			outline.Filled = false
			outline.Visible = false
			ESPBoxOutlines[plr] = outline

			local box = Drawing.new("Square")
			box.Color = Config.Visual.Color
			box.Thickness = 1
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

			local dist = Drawing.new("Text")
			dist.Size = 14
			dist.Color = Config.Visual.Color
			dist.Center = true
			dist.Outline = true
			dist.Visible = false
			ESPDistances[plr] = dist

			local tracer = Drawing.new("Line")
			tracer.Color = Config.Visual.Color
			tracer.Thickness = 1
			tracer.Visible = false
			ESPTracers[plr] = tracer

			local healthBarOutline = Drawing.new("Square")
			healthBarOutline.Thickness = 3
			healthBarOutline.Color = Color3.new(0, 0, 0)
			healthBarOutline.Filled = false
			healthBarOutline.Visible = false
			ESPHealthBarOutlines[plr] = healthBarOutline

			local healthBar = Drawing.new("Square")
			healthBar.Thickness = 1
			healthBar.Filled = true
			healthBar.Visible = false
			ESPHealthBars[plr] = healthBar
		end
	end

	local function GetCharacterBoundingBox(plr)
		local char = plr.Character
		if not char then return end

		local humanoid = char:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then return end

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

		if minX == math.huge then return end
		return Vector2.new(minX, minY), Vector2.new(maxX, maxY)
	end

	RunService.RenderStepped:Connect(function()
		if not Config.Enabled then
			for _, map in pairs({ESPBoxes, ESPBoxOutlines, ESPNames, ESPDistances, ESPTracers, ESPHealthBars, ESPHealthBarOutlines}) do
				for _, obj in pairs(map) do
					obj.Visible = false
				end
			end
			return
		end

		for _, plr in pairs(Players:GetPlayers()) do
			if plr == Player then continue end
			if Config.Team.Check and plr.Team == Player.Team then continue end
			if not (plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")) then continue end

			local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
			if not humanoid or humanoid.Health < 1 then continue end

			SetupPlayerESP(plr)

			local rootPart = plr.Character.HumanoidRootPart
			local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
			if not onScreen then continue end

			local topLeft, bottomRight = GetCharacterBoundingBox(plr)
			if not topLeft or not bottomRight then continue end

			local boxSize = bottomRight - topLeft
			boxSize = Vector2.new(boxSize.X, boxSize.Y + 8)
			local color = Config.Team.UseTeamColor and plr.TeamColor.Color or Config.Visual.Color

			-- Boxes
			if Config.Toggle.Boxes then
				local outline = ESPBoxOutlines[plr]
				outline.Visible = Config.Visual.Outlines
				outline.Position = topLeft - Vector2.new(1, 1)
				outline.Size = boxSize + Vector2.new(2, 2)
				outline.Color = Color3.new(0, 0, 0)

				local box = ESPBoxes[plr]
				box.Visible = true
				box.Position = topLeft
				box.Size = boxSize
				box.Color = color
			else
				ESPBoxes[plr].Visible = false
				ESPBoxOutlines[plr].Visible = false
			end

			-- Name
			if Config.Toggle.Names then
				local name = ESPNames[plr]
				name.Visible = true
				name.Position = Vector2.new((topLeft.X + bottomRight.X) / 2, topLeft.Y - 20)
				name.Text = plr.Name
				name.Color = color
				name.Outline = Config.Visual.Outlines
				name.Font = Config.Visual.Font
				name.Size = Config.Visual.FontSize
			else
				ESPNames[plr].Visible = false
			end

			-- Distance
			if Config.Toggle.Distance then
				local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
				local dist = ESPDistances[plr]
				dist.Visible = true
				dist.Position = Vector2.new((topLeft.X + bottomRight.X) / 2, bottomRight.Y + 10)
				dist.Text = string.format("%d studs", distance)
				dist.Color = color
				dist.Outline = Config.Visual.Outlines
				dist.Font = Config.Visual.Font
				dist.Size = Config.Visual.FontSize
			else
				ESPDistances[plr].Visible = false
			end

			-- Tracer
			if Config.Toggle.Tracers then
				local tracer = ESPTracers[plr]
				tracer.Visible = true
				tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
				tracer.To = Vector2.new(screenPos.X, screenPos.Y)
				tracer.Color = color
			else
				ESPTracers[plr].Visible = false
			end

			-- Healthbar
			if Config.Toggle.HealthBar then
				local healthPercent = humanoid.Health / humanoid.MaxHealth
				local barHeight = boxSize.Y * healthPercent
				local barPosition = Vector2.new(bottomRight.X + 5, topLeft.Y + (boxSize.Y - barHeight))

				local outline = ESPHealthBarOutlines[plr]
				outline.Size = Vector2.new(2, boxSize.Y)
				outline.Position = Vector2.new(bottomRight.X + 5, topLeft.Y)
				outline.Visible = Config.Visual.Outlines

				local bar = ESPHealthBars[plr]
				bar.Size = Vector2.new(2, barHeight)
				bar.Position = barPosition
				bar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
				bar.Visible = true
			else
				ESPHealthBars[plr].Visible = false
				ESPHealthBarOutlines[plr].Visible = false
			end
		end
	end)

	Players.PlayerRemoving:Connect(function(plr)
		for _, map in pairs({
			ESPBoxes,
			ESPBoxOutlines,
			ESPNames,
			ESPTracers,
			ESPDistances,
			ESPHealthBars,
			ESPHealthBarOutlines,
		}) do
			if map[plr] then
				map[plr]:Remove()
				map[plr] = nil
			end
		end
	end)

	Config.Enabled = true

	return {
		Config = Config,
	}
end)()
