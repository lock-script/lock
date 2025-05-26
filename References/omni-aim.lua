return (function()
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local UserInputService = game:GetService("UserInputService")
	local LocalPlayer = Players.LocalPlayer
	local Camera = workspace.CurrentCamera
	local WorldRoot = workspace

	local Config = {
		Enabled = true,
		Toggle = {
			ShowFOV = true,
		},
		FOV = {
			Radius = 50,
			Thickness = 0.8,
			Color = Color3.new(1, 1, 1),
			Transparency = 1,
			NumSides = 64,
		},
		Aim = {
			Smoothness = 0.4,
			TriggerKey = Enum.UserInputType.MouseButton2,
		},
		Team = {
			Check = false,
			UseTeamColor = false,
		},
		WallCheck = {
			Enabled = true,
			IgnoreList = { LocalPlayer.Character },
		},
	}

	local IsTriggerHeld = false

	local FOVOutline = Drawing.new("Circle")
	FOVOutline.Radius = Config.FOV.Radius
	FOVOutline.Thickness = Config.FOV.Thickness + 1.1
	FOVOutline.Color = Color3.new(0, 0, 0)
	FOVOutline.Transparency = Config.FOV.Transparency
	FOVOutline.NumSides = Config.FOV.NumSides
	FOVOutline.Filled = false
	FOVOutline.Visible = false

	local FOVCircle = Drawing.new("Circle")
	FOVCircle.Radius = Config.FOV.Radius
	FOVCircle.Thickness = Config.FOV.Thickness
	FOVCircle.Color = Config.FOV.Color
	FOVCircle.Transparency = Config.FOV.Transparency
	FOVCircle.NumSides = Config.FOV.NumSides
	FOVCircle.Filled = false
	FOVCircle.Visible = false

	local function UpdateFOVCircle()
		local pos = UserInputService:GetMouseLocation()

		FOVOutline.Position = pos
		FOVOutline.Radius = Config.FOV.Radius
		FOVOutline.Thickness = Config.FOV.Thickness + 2
		FOVOutline.Color = Color3.new(0, 0, 0)
		FOVOutline.Transparency = Config.FOV.Transparency
		FOVOutline.NumSides = Config.FOV.NumSides

		FOVCircle.Position = pos
		FOVCircle.Radius = Config.FOV.Radius
		FOVCircle.Thickness = Config.FOV.Thickness
		FOVCircle.Color = Config.FOV.Color
		FOVCircle.Transparency = Config.FOV.Transparency
		FOVCircle.NumSides = Config.FOV.NumSides
	end
	local function IsValidTarget(player)
		if not player.Character then
			return false
		end
		local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then
			return false
		end
		if Config.Team.Check and player.Team == LocalPlayer.Team then
			return false
		end
		return true
	end
	local function IsVisible(targetPart)
		if not Config.WallCheck.Enabled then
			return true
		end
		if not targetPart then
			return false
		end

		local origin = Camera.CFrame.Position
		local direction = (targetPart.Position - origin)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = Config.WallCheck.IgnoreList
		raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
		raycastParams.IgnoreWater = true

		local raycastResult = workspace:Raycast(origin, direction, raycastParams)
		if raycastResult then
			return raycastResult.Instance:IsDescendantOf(targetPart.Parent)
		else
			return true
		end
	end
	local function GetScreenPosAndDist(worldPos)
		local screenPos, onScreen = Camera:WorldToViewportPoint(worldPos)
		if not onScreen then
			return nil
		end

		local mousePos = UserInputService:GetMouseLocation()
		local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

		return Vector2.new(screenPos.X, screenPos.Y), dist
	end
	local function GetClosestTarget()
		local closestPlayer = nil
		local closestDist = Config.FOV.Radius

		for _, player in pairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and IsValidTarget(player) then
				local head = player.Character and player.Character:FindFirstChild("Head")
				if head and IsVisible(head) then
					local _, dist = GetScreenPosAndDist(head.Position)
					if dist and dist < closestDist then
						closestDist = dist
						closestPlayer = player
					end
				end
			end
		end

		return closestPlayer
	end
	local function AimAt(target)
		if not target or not target.Character then
			return
		end
		local head = target.Character:FindFirstChild("Head")
		if not head then
			return
		end

		local camPos = Camera.CFrame.Position
		local targetPos = head.Position
		local direction = (targetPos - camPos).Unit
		local targetCF = CFrame.new(camPos, camPos + direction)

		if Config.Aim.Smoothness <= 0 then
			Camera.CFrame = targetCF
		else
			Camera.CFrame = Camera.CFrame:Lerp(targetCF, Config.Aim.Smoothness)
		end
	end

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if (input.UserInputType == Config.Aim.TriggerKey) or (input.KeyCode == Config.Aim.TriggerKey) then
			IsTriggerHeld = true
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if (input.UserInputType == Config.Aim.TriggerKey) or (input.KeyCode == Config.Aim.TriggerKey) then
			IsTriggerHeld = false
		end
	end)

	RunService.RenderStepped:Connect(function()
		if not Config.Enabled then
			FOVCircle.Visible = false
			FOVOutline.Visible = false
			return
		end

		FOVCircle.Visible = Config.Toggle.ShowFOV
		FOVOutline.Visible = Config.Toggle.ShowFOV
		UpdateFOVCircle()

		if IsTriggerHeld then
			local target = GetClosestTarget()
			if target then
				AimAt(target)
			end
		end
	end)

	return {
		Config = Config,
	}
end)()
