return (function()
	local Players = game:GetService("Players")
	local LocalPlayer = Players.LocalPlayer
	local Mouse = LocalPlayer:GetMouse()
	local Camera = workspace.CurrentCamera

	local Config = {
		Visible = true,
		Radius = 50,
		Thickness = 0.8,
		Color = Color3.new(1, 1, 1),
		Transparency = 1,
		NumSides = 64,
	}

	local FOVOutline = Drawing.new("Circle")
	FOVOutline.Radius = Config.Radius
	FOVOutline.Thickness = Config.Thickness + 1.1
	FOVOutline.Color = Color3.new(0, 0, 0)
	FOVOutline.Transparency = Config.Transparency
	FOVOutline.NumSides = Config.NumSides
	FOVOutline.Filled = false
	FOVOutline.Visible = Config.Visible

	local FOVCircle = Drawing.new("Circle")
	FOVCircle.Radius = Config.Radius
	FOVCircle.Thickness = Config.Thickness
	FOVCircle.Color = Config.Color
	FOVCircle.Transparency = Config.Transparency
	FOVCircle.NumSides = Config.NumSides
	FOVCircle.Filled = false
	FOVCircle.Visible = Config.Visible

	task.spawn(function()
		while task.wait() do
			local Pos = game.UserInputService:GetMouseLocation()

			FOVOutline.Position = Pos
			FOVOutline.Radius = Config.Radius
			FOVOutline.Thickness = Config.Thickness + 2
			FOVOutline.Color = Color3.new(0, 0, 0)
			FOVOutline.Transparency = Config.Transparency
			FOVOutline.NumSides = Config.NumSides
			FOVOutline.Visible = Config.Visible

			FOVCircle.Position = Pos
			FOVCircle.Radius = Config.Radius
			FOVCircle.Thickness = Config.Thickness
			FOVCircle.Color = Config.Color
			FOVCircle.Transparency = Config.Transparency
			FOVCircle.NumSides = Config.NumSides
			FOVCircle.Visible = Config.Visible
		end
	end)

	local Module = {}

	function Module.IsInFOV(Position)
		local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(Position)
		if not OnScreen then
			return false
		end
		local Distance = (Vector2.new(Mouse.X, Mouse.Y + 36) - Vector2.new(ScreenPosition.X, ScreenPosition.Y)).Magnitude
		return Distance <= Config.Radius
	end

	function Module.GetClosestToCursor(Targets)
		local Closest = nil
		local ClosestDistance = math.huge
		for _, Target in ipairs(Targets) do
			local Head = Target.Character and Target.Character:FindFirstChild("Head")
			if Head then
				local Pos, OnScreen = Camera:WorldToViewportPoint(Head.Position)
				if OnScreen then
					local Dist = (Vector2.new(Mouse.X, Mouse.Y + 36) - Vector2.new(Pos.X, Pos.Y)).Magnitude
					if Dist <= Config.Radius and Dist < ClosestDistance then
						Closest = Target
						ClosestDistance = Dist
					end
				end
			end
		end
		return Closest
	end

	Module.Config = Config

	return Module
end)()
