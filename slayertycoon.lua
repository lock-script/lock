--|| REFERENCES ||--
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local HttpRequest = (syn and syn.request)
	or (http and http.request)
	or http_request
	or (fluxus and fluxus.request)
	or request
local Genv = getgenv()

local Player = Players.LocalPlayer

local LoadingTick = tick()

--|| LOAD LIBRARY ||--
local Library = loadstring(
	game:HttpGetAsync("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau", true)
)()
local Options = Library.Options

--|| CREATE WINDOW ||--

local GameTitle = "slayer tycoon"

local Window = Library:CreateWindow({
	Title = `<font size="13">omni.cc |</font> <font size ="12"><i>` .. GameTitle .. `</i></font>`,
	SubTitle = "",
	TabWidth = 140,
	Size = UDim2.fromOffset(900, 600),
	Resize = true,
	MinSize = Vector2.new(470, 380),
	Acrylic = true,
	Theme = "Darker",
	MinimizeKey = Enum.KeyCode.RightControl,
})

--|| TABS ||--
local Tabs = {
	Main = Window:CreateTab({
		Title = "Main",
		Icon = "phosphor-users-bold",
	}),

	Game = Window:CreateTab({
		Title = "Slayer Tycoon",
		Icon = "sword",
	}),

	Settings = Window:CreateTab({
		Title = "Settings",
		Icon = "settings",
	}),
}

--|| MAIN GLOBALS ||--
Genv.WalkSpeed = Genv.WalkSpeed or Player.Character.Humanoid.WalkSpeed

Genv.FlightSpeed = Genv.FlightSpeed or 100
Genv.Flight = Genv.Flight or false
Genv.FlightBind = Genv.FlightBind or "F"

--|| LIBRARY FUNCTIONS ||--

local function CreateSection(self, Args)
	local Title = Args.Title or "Paragraph"

	self:CreateParagraph("Paragraph", {
		Title = '<font size="14"><b>' .. Title .. "</b></font>",
		TitleAlignment = "Middle",
	})
end

local function CreateDivider(self)
	self:CreateParagraph("Divider", {
		Title = "Divider",
	})
end

local function CreateSpacer(self)
	self:CreateParagraph("Spacer", {
		Title = "Spacer",
	})
end

for _, Tab in pairs(Tabs) do
	Tab.CreateSection = CreateSection
	Tab.CreateDivider = CreateDivider
	Tab.CreateSpacer = CreateSpacer
end

--|| FUNCTIONS ||--

local function Fly(Enable)
	local Control = { f = 0, b = 0, l = 0, r = 0, u = 0, d = 0 }
	local Speed = Genv.FlightSpeed
	local Gyro, Velocity

	local KeyDownConnection, KeyUpConnection

	if Enable then
		Gyro = Instance.new("BodyGyro")
		Gyro.P = 9e4
		Gyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		Gyro.CFrame = Player.Character.HumanoidRootPart.CFrame
		Gyro.Parent = Player.Character.HumanoidRootPart

		Velocity = Instance.new("BodyVelocity")
		Velocity.MaxForce = Vector3.one * math.huge
		Velocity.Velocity = Vector3.zero
		Velocity.Parent = Player.Character.HumanoidRootPart

		Player.Character.Humanoid.PlatformStand = true
		Camera.CameraType = Enum.CameraType.Track

		local Mouse = Player:GetMouse()
		KeyDownConnection = Mouse.KeyDown:Connect(function(k)
			k = k:lower()
			if k == "w" then
				Control.f = -1
			elseif k == "s" then
				Control.b = 1
			elseif k == "a" then
				Control.l = -1
			elseif k == "d" then
				Control.r = 1
			elseif k == "e" then
				Control.u = -1
			elseif k == "q" then
				Control.d = 1
			end
		end)

		KeyUpConnection = Mouse.KeyUp:Connect(function(k)
			k = k:lower()
			if k == "w" then
				Control.f = 0
			elseif k == "s" then
				Control.b = 0
			elseif k == "a" then
				Control.l = 0
			elseif k == "d" then
				Control.r = 0
			elseif k == "e" then
				Control.u = 0
			elseif k == "q" then
				Control.d = 0
			end
		end)

		task.spawn(function()
			while Enable and Gyro and Velocity and Player.Character do
				task.wait()
				local Move = Vector3.new(Control.r + Control.l, Control.u + Control.d, Control.f + Control.b)
				if Move.Magnitude > 0 then
					Move = Camera.CFrame:VectorToWorldSpace(Move.Unit) * Speed
				else
					Move = Vector3.zero
				end
				Velocity.Velocity = Move
				Gyro.CFrame = Camera.CFrame
			end
		end)

		Genv._FlightKeyDown = KeyDownConnection
		Genv._FlightKeyUp = KeyUpConnection
	else
		for _, Inst in pairs(Player.Character.HumanoidRootPart:GetChildren()) do
			if Inst:IsA("BodyGyro") and Inst.Name == "Fly" or Inst:IsA("BodyVelocity") and Inst.Name == "Fly" then
				Inst:Destroy()
			end
		end

		if Genv._FlightKeyDown then
			Genv._FlightKeyDown:Disconnect()
			Genv._FlightKeyDown = nil
		end
		if Genv._FlightKeyUp then
			Genv._FlightKeyUp:Disconnect()
			Genv._FlightKeyUp = nil
		end

		Player.Character.Humanoid.PlatformStand = false
		Camera.CameraType = Enum.CameraType.Custom
	end
end

local function CheckRig(Character)
	local Character = Character or Players.LocalPlayer.Character
	local Humanoid = Character:WaitForChild("Humanoid")

	if Humanoid.RigType == Enum.HumanoidRigType.R6 then
		return "R6"
	else
		return "R15"
	end
end

local function SetClipboard(Text)
	local Clipboard = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set)
	Clipboard(tostring(Text))
end

local function GetPlayerList()
	local list = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= Player then
			if player.DisplayName ~= player.Name then
				table.insert(list, player.DisplayName .. " (@" .. player.Name .. ")")
			else
				table.insert(list, player.Name)
			end
		end
	end
	return list
end

local function TeleportTo(options: {
	Target: any,
	Tween: boolean?,
	TweenDur: number?,
})
	local targetCFrame

	local target = options.Target
	if typeof(target) == "CFrame" then
		targetCFrame = target
	elseif typeof(target) == "Vector3" then
		targetCFrame = CFrame.new(target)
	elseif typeof(target) == "Instance" and target:IsA("BasePart") then
		targetCFrame = target.CFrame
	else
		return
	end

	if not Player.Character:FindFirstChild("HumanoidRootPart") then
		return
	end

	if options.Tween then
		local tweenInfo = TweenInfo.new(options.TweenDur or 3, Enum.EasingStyle.Linear)
		local goal = { CFrame = targetCFrame }

		local tween = TweenService:Create(Player.Character:FindFirstChild("HumanoidRootPart"), tweenInfo, goal)
		tween:Play()
	else
		Player.Character:FindFirstChild("HumanoidRootPart").CFrame = targetCFrame
	end
end

--[[
  __  __          _____ _   _ 
 |  \/  |   /\   |_   _| \ | |
 | \  / |  /  \    | | |  \| |
 | |\/| | / /\ \   | | | . ` |
 | |  | |/ ____ \ _| |_| |\  |
 |_|  |_/_/    \_\_____|_| \_|

]]

--#region General features
Tabs.Main:CreateSection({
	Title = "General features",
})

local PlayerTeleportDropdown = Tabs.Main:CreateDropdown("PlayerTeleportDropdown", {
	Title = "Teleport to Player",
	Values = GetPlayerList(),
	Description = "Teleport to any player instantly",
	Multi = false,
	Default = " ",
	Callback = function(Value)
		if not Value or Value == "None" then
			return
		end
		local username = Value:match("@([%w_]+)")

		if not username then
			username = Value
		end

		local target = Players:FindFirstChild(username)

		if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
			Player.Character:PivotTo(target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0))
		else
			Library:Notify({
				Title = "Teleport to Player: Error",
				Content = "No player found",
				Duration = 2,
			})
		end
	end,
})

local WalkSpeedSlider = Tabs.Main:CreateSlider("WalkSpeedSlider", {
	Title = "Set Walk Speed",
	Description = "Change your walking speed",
	Default = Genv.WalkSpeed,
	Min = 0,
	Max = 1000,
	Rounding = 0,
	Callback = function(Value)
		Player.Character.Humanoid.WalkSpeed = Value
		Genv.WalkSpeed = Value
	end,
})

Tabs.Main:CreateSpacer()

local FlightToggle = Tabs.Main:CreateToggle("FlightToggle", {
	Title = "Toggle Flight",
	Description = "Enable or disable flight",
	Default = Genv.flight,
	Callback = function(value)
		Genv.Flight = value
		Fly(value)
	end,
})

local FlightBind = Tabs.Main:CreateKeybind("FlightBind", {
	Title = "Set Flight Bind",
	Description = "Customize the keybind used to toggle flight",
	Default = Genv.FlightBind,
	Mode = "Toggle",
	Callback = function()
		FlightToggle:SetValue(not Genv.Flight)
		Fly(Genv.Flight)
	end,
})

local FlightSlider = Tabs.Main:CreateSlider("FlightSlider", {
	Title = "Set Flight Speed",
	Description = "Adjust how fast you move while flying",
	Default = Genv.FlightSpeed,
	Min = 0,
	Max = 1000,
	Rounding = 0,
	Callback = function(value)
		Genv.FlightSpeed = value
	end,
})
--#endregion

--#region Miscellaneous features
Tabs.Main:CreateSection({
	Title = "Miscellaneous features",
})

local FullbrightToggle = Tabs.Main:AddToggle("FullbrightToggle", {
	Title = "Toggle Fullbright",
	Description = "Maximize brightness and remove shadows, suitable for dark games",
	Default = false,
	Callback = function(value)
		local lighting = game:GetService("Lighting")

		Genv.Fullbright = value

		if value then
			Genv.OriginalLighting = {
				Ambient = lighting.Ambient,
				OutdoorAmbient = lighting.OutdoorAmbient,
				Brightness = lighting.Brightness,
			}

			lighting.Ambient = Color3.fromRGB(255, 255, 255)
			lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
			lighting.Brightness = 2

			fullbrightLoop = game:GetService("RunService").Heartbeat:Connect(function()
				if Genv.Fullbright then
					lighting.Ambient = Color3.fromRGB(255, 255, 255)
					lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
					lighting.Brightness = 1.5
				else
					if Genv.OriginalLighting then
						lighting.Ambient = Genv.OriginalLighting.Ambient
						lighting.OutdoorAmbient = Genv.OriginalLighting.OutdoorAmbient
						lighting.Brightness = Genv.OriginalLighting.Brightness
					end
					if fullbrightLoop then
						fullbrightLoop:Disconnect()
					end
				end
			end)
		else
			if Genv.OriginalLighting then
				lighting.Ambient = Genv.OriginalLighting.Ambient
				lighting.OutdoorAmbient = Genv.OriginalLighting.OutdoorAmbient
				lighting.Brightness = Genv.OriginalLighting.Brightness
			end

			if fullbrightLoop then
				fullbrightLoop:Disconnect()
			end
		end
	end,
})

local InfiniteJumpToggle = Tabs.Main:AddToggle("InfiniteJumpToggle", {
	Title = "Toggle Infinite Jump",
	Description = "Jump repeatedly in the air without limits",
	Default = Genv.InfiniteJump,
	Callback = function(value)
		Genv.InfiniteJump = value

		if Genv.InfiniteJump then
			if infJump then
				infJump:Disconnect()
			end
			infJumpDebounce = false
			infJump = InputService.JumpRequest:Connect(function()
				if not infJumpDebounce then
					infJumpDebounce = true
					local humanoid = Player.Character:FindFirstChildWhichIsA("Humanoid")
					if humanoid then
						humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
					end
					task.wait(0.3)
					infJumpDebounce = false
				end
			end)
		else
			if infJump then
				infJump:Disconnect()
			end
		end
	end,
})

local NoclipToggle = Tabs.Main:AddToggle("NoclipToggle", {
	Title = "Toggle Noclip",
	Description = "Phase through walls and obstacles",
	Default = false,
	Callback = function(value)
		local character = Player.Character or Player.CharacterAdded:Wait()
		local RunService = game:GetService("RunService")

		if value then
			Genv.Noclip = RunService.Stepped:Connect(function()
				if character then
					for _, part in ipairs(character:GetDescendants()) do
						if
							part:IsA("BasePart")
							and (part.Name:lower():find("head") or part.Name:lower():find("torso"))
						then
							part.CanCollide = false
						end
					end
				end
			end)
		else
			if Genv.Noclip then
				Genv.Noclip:Disconnect()
				Genv.Noclip = nil
			end
			if character then
				for _, part in ipairs(character:GetDescendants()) do
					if part:IsA("BasePart") and (part.Name:lower():find("head") or part.Name:lower():find("torso")) then
						part.CanCollide = true
					end
				end
			end
		end
	end,
})

Tabs.Main:CreateSpacer()

local SpinToggle = Tabs.Main:AddToggle("SpinToggle", {
	Title = "Spin",
	Description = "Enable or disable spinning your character around",
	Default = false,
	Callback = function(value)
		local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
		if not root then
			return
		end

		if value == true then
			local spin = Instance.new("BodyAngularVelocity")
			spin.Name = "spinning"
			spin.Parent = root
			spin.MaxTorque = Vector3.new(0, math.huge, 0)
			task.spawn(function()
				while value == true do
					task.wait()
					spin.AngularVelocity = Vector3.new(0, Genv.SpinSpeed, 0)
				end
			end)
		else
			local existing = root:FindFirstChild("spinning")
			if existing then
				existing:Destroy()
			end
		end
	end,
})

local SpinSlider = Tabs.Main:AddSlider("SpinSlider", {
	Title = "Spin Speed",
	Description = "Customize the speed of your spinning",
	Default = Genv.SpinSpeed,
	Min = 1,
	Max = 1000,
	Rounding = 0,
	Callback = function(value)
		Genv.SpinSpeed = value
	end,
})

Tabs.Main:CreateSpacer()

local JerkToggle = Tabs.Main:AddToggle("JerkToggle", {
	Title = "Jerk Off",
	Description = "Toggle a jacking off animation",
	Default = false,
	Callback = function(value)
		Genv.Jerking = value

		local character = Player.Character or Player.CharacterAdded:Wait()
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid then
			return
		end

		if value == true then
			task.spawn(function()
				while Genv.Jerking do
					local animation = Instance.new("Animation")
					animation.AnimationId = (CheckRig() == "R6" and "rbxassetid://72042024" or "rbxassetid://698251653")
					animation.Name = "jerk"

					local track = humanoid:LoadAnimation(animation)
					track:Play()
					track.TimePosition = 0.6

					while Genv.Jerking and track and track.TimePosition < (CheckRig() == "R6" and 0.65 or 0.7) do
						task.wait(0.05)
					end

					if track then
						track:Stop()
						track:Destroy()
					end
				end
			end)
		else
			for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
				if track.Name == "jerk" then
					track:Stop()
					track:Destroy()
				end
			end
		end
	end,
})

local BangInput = Tabs.Main:AddInput("BangInput", {
	Title = "Bang Player",
	Description = "Rape any player, type 'stop' or '' to stop",
	Default = false,
	Finished = true,
	Placeholder = "Type Username",
	Callback = function(value)
		value = string.lower(value)

		if value == "" or value:lower() == "stop" then
			for _, track in ipairs(Player.Character.Humanoid:GetPlayingAnimationTracks()) do
				if track.Name == "bang" then
					track:Stop()
				end
			end
			if bangLoop then
				bangLoop:Disconnect()
				bangLoop = nil
			end
			return
		end

		local foundPlayer = false

		for _, plr in pairs(game.Players:GetPlayers()) do
			if plr ~= Player then
				local name = string.lower(plr.Name)
				local display = string.lower(plr.DisplayName)
				if string.find(name, value) or string.find(display, value) then
					local char = Player.Character or Player.CharacterAdded:Wait()
					local humanoid = char:FindFirstChildWhichIsA("Humanoid")
					if not humanoid then
						return
					end

					local anim = Instance.new("Animation")
					anim.AnimationId = (CheckRig() == "R6" and "rbxassetid://148840371" or "rbxassetid://5918726674")
					anim.Name = "bang"
					local track = humanoid:LoadAnimation(anim)
					track:Play()
					track:AdjustSpeed(3)

					bangLoop = game:GetService("RunService").Stepped:Connect(function()
						if
							not plr.Character
							or not plr.Character:FindFirstChild("HumanoidRootPart")
							or not char:FindFirstChild("HumanoidRootPart")
						then
							return
						end
						char.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1.1)
					end)

					humanoid.Died:Connect(function()
						bangLoop:Disconnect()
					end)

					foundPlayer = true
					break
				end
			end
		end

		if not foundPlayer then
			for _, track in ipairs(player.Character.Humanoid:GetPlayingAnimationTracks()) do
				if track.Name == "bang" then
					track:Stop()
				end
			end
			if bangLoop then
				bangLoop:Disconnect()
				bangLoop = nil
			end
		end
	end,
})
--#endregion

--[[
   _____          __  __ ______ 
  / ____|   /\   |  \/  |  ____|
 | |  __   /  \  | \  / | |__   
 | | |_ | / /\ \ | |\/| |  __|  
 | |__| |/ ____ \| |  | | |____ 
  \_____/_/    \_\_|  |_|______|
                                
                                
]]

--|| HELPER FUNCTIONS --||

local function GetTree()
	local dist, thing = math.huge
	for i, v in pairs(workspace.Map:GetChildren()) do
		if v:IsA("Model") and v:FindFirstChild("WoodHitPart") then
			if v.WoodHitPart.Transparency == 0 then
				local mag = (Player.Character.HumanoidRootPart.Position - v.WoodHitPart.Position).magnitude
				if mag < dist then
					dist = mag
					thing = v
				end
			end
		end
	end
	return thing
end

local function GetOre()
	local dist, thing = math.huge
	for i, v in pairs(workspace:GetChildren()) do
		if v.Name == "RockHitPart" then
			if v.Transparency == 0 then
				local mag = (Player.Character.HumanoidRootPart.Position - v.Position).magnitude
				if mag < dist then
					dist = mag
					thing = v
				end
			end
		end
	end
	return thing
end

local function DoHit()
	for i, v in pairs(Player.Character:GetChildren()) do
		if v:IsA("Tool") and v.Name == "Hatchet" or v.Name == "Pickaxe" then
			game:GetService("Players").LocalPlayer.Character[tostring(v.Name)].Attack:FireServer()
		end
	end
end

local function GetTycoon()
	for i, v in pairs(game:GetService("Workspace").TycoonSets.Tycoons:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChild("Owner") then
			if v.Owner.Value == game.Players.LocalPlayer then
				return v
			end
		end
	end
end

local function EquipTool(tool: string)
	if Player.Backpack:FindFirstChild(tool) then
		Player.Character.Humanoid:EquipTool(Player.Backpack:FindFirstChild(tool))
	end
end

local function GetKeys(t)
	local keys = {}
	for key, _ in pairs(t) do
		table.insert(keys, key)
	end
	return keys
end

local function CreateLoop(id, func)
	Genv.Loops = Genv.Loops or {}

	if Genv.Loops[id] then
		Genv.Loops[id].running = false
		Genv.Loops[id] = nil
	end

	local loop = { running = true }
	Genv.Loops[id] = loop

	task.spawn(function()
		while loop.running do
			task.wait()
			func()
		end
	end)
end

local function StopLoop(id)
	if Genv.Loops and Genv.Loops[id] then
		Genv.Loops[id].running = false
		Genv.Loops[id] = nil
	end
end

local TycoonTeleports = {
	["Mountains"] = Vector3.new(-41, 442, 316),
	["Grasslands"] = Vector3.new(-750, 399, 79),
	["Forest"] = Vector3.new(-727, 390, -291),
	["Rice Fields"] = Vector3.new(-108, 393, -299),
	["Winter Woods"] = Vector3.new(-263, 520, 523),
	["Wisteria Forest"] = Vector3.new(-860, 463, 394),
}

local NPCTeleports = {
	["Style Sensei"] = Vector3.new(-413, 388, 291),
	["Lumberjack"] = Vector3.new(-519, 387, -160),
	["Miner"] = Vector3.new(-89, 390, 50),
	["Muzan"] = Vector3.new(-1182, 357, 3766),
	["Biwa Lady"] = Vector3.new(-278, 391, -47),
}

--#region Teleport features

Tabs.Game:CreateSection({
	Title = "Teleport features",
})
local TycoonTeleportDropdown = Tabs.Game:CreateDropdown("TycoonTeleportDropdown", {
	Title = "Tycoon Teleports",
	Description = "Teleport to the tycoons",
	Default = " ",
	Values = GetKeys(TycoonTeleports),
	Callback = function(value)
		if TycoonTeleports[value] then
			Player.Character.HumanoidRootPart.CFrame = CFrame.new(TycoonTeleports[value])
		end
	end,
})

local NPCTeleportDropdown = Tabs.Game:CreateDropdown("NPCTeleportDropdown", {
	Title = "NPC Teleports",
	Description = "Teleport to the NPCs",
	Default = " ",
	Values = GetKeys(NPCTeleports),
	Callback = function(value)
		if NPCTeleports[value] then
			Player.Character.HumanoidRootPart.CFrame = CFrame.new(NPCTeleports[value])
		end
	end,
})

--#endregion

--#region Auto features

Tabs.Game:CreateSection({
	Title = "Auto features",
})

local AutoCollectToggle = Tabs.Game:CreateToggle("AutoCollectToggle", {
	Title = "Auto Collect",
	Description = "Automatically collect your tycoon's cash",
	Default = Genv.AutoCollect,
	Callback = function(value)
		Genv.AutoCollect = value
		if value then
			CreateLoop("AutoCollect", function()
				for _, Giver in pairs(game:GetService("Workspace").TycoonSets.Tycoons:GetDescendants()) do
					if Giver:IsA("TouchTransmitter") and Giver.Parent.Name == "Giver" then
						firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, Giver.Parent, 0)
						firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, Giver.Parent, 1)
					end
				end
			end)
		else
			StopLoop("AutoCollect")
		end
	end,
})

local AutoBuyToggle = Tabs.Game:CreateToggle("AutoBuyToggle", {
	Title = "Auto Buy",
	Description = "Automatically buy your tycoon parts",
	Default = Genv.AutoBuy,
	Callback = function(value)
		Genv.AutoBuy = value
		if value then
			CreateLoop("AutoBuy", function()
				local tycoon = GetTycoon()
				if not tycoon then
					return
				end
				for _, Part in pairs(tycoon.Buttons:GetDescendants()) do
					if Part:IsA("TouchTransmitter") then
						firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, Part.Parent, 0)
						firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, Part.Parent, 1)
					end
				end
			end)
		else
			StopLoop("AutoBuy")
		end
	end,
})

Tabs.Game:CreateSpacer()

local AutoTreeToggle = Tabs.Game:CreateToggle("AutoTreeToggle", {
	Title = "Auto Chop",
	Description = "Automatically chops trees around the map",
	Default = Genv.AutoTree,
	Callback = function(value)
		Genv.AutoTree = value
		if value then
			CreateLoop("AutoTree", function()
				local tree = GetTree()
				if not tree then
					return
				end
				EquipTool("Hatchet")
				Player.Character.HumanoidRootPart.CFrame = CFrame.new(tree.WoodHitPart.CFrame.Position)
					* CFrame.new(0, -3, 0)
				DoHit()
			end)
		else
			StopLoop("AutoTree")
		end
	end,
})

local AutoOreToggle = Tabs.Game:CreateToggle("AutoOreToggle", {
	Title = "Auto Mine",
	Description = "Automatically mines rocks around the map",
	Default = Genv.AutoMine,
	Callback = function(value)
		Genv.AutoMine = value
		if value then
			CreateLoop("AutoMine", function()
				local ore = GetOre()
				if not ore then
					return
				end
				EquipTool("Pickaxe")
				Player.Character.HumanoidRootPart.CFrame = CFrame.new(ore.Position) * CFrame.new(0, 0, 5)
				DoHit()
			end)
		else
			StopLoop("AutoMine")
		end
	end,
})

--#endregion

--#region Sell features

Tabs.Game:CreateSection({
	Title = "Sell features",
})

Tabs.Game:CreateButton({
	Title = "Sell Logs",
	Description = "Sell your wood to the Lumberjack",
	Callback = function()
		local OriginalCFrame = Player.Character.HumanoidRootPart.CFrame
		Player.Character.HumanoidRootPart.CFrame = workspace.Lumberjack.HumanoidRootPart.CFrame
		task.wait(0.3)
		fireproximityprompt(workspace.Lumberjack.ProxPrompt)
		task.wait(0.5)
		Player.Character.HumanoidRootPart.CFrame = OriginalCFrame
	end,
})

Tabs.Game:CreateButton({
	Title = "Sell Ores",
	Description = "Sell your ores to the Miner",
	Callback = function()
		local OriginalCFrame = Player.Character.HumanoidRootPart.CFrame
		Player.Character.HumanoidRootPart.CFrame = workspace.Miner.HumanoidRootPart.CFrame
		task.wait(0.3)
		fireproximityprompt(workspace.Miner.ProxPrompt)
		task.wait(0.5)
		Player.Character.HumanoidRootPart.CFrame = OriginalCFrame
	end,
})

--#endregion

--[[
   _____ ______ _______ _______ _____ _   _  _____  _____ 
  / ____|  ____|__   __|__   __|_   _| \ | |/ ____|/ ____|
 | (___ | |__     | |     | |    | | |  \| | |  __| (___  
  \___ \|  __|    | |     | |    | | | . ` | | |_ |\___ \ 
  ____) | |____   | |     | |   _| |_| |\  | |__| |____) |
 |_____/|______|  |_|     |_|  |_____|_| \_|\_____|_____/ 

]]

--#region Server related settings
Tabs.Settings:CreateSection({
	Title = "Server related settings",
})

Tabs.Settings:CreateButton({
	Title = "PlaceId: <i>" .. tostring(game.PlaceId) .. "</i>",
	Description = "Copy the PlaceId above to your clipboard",
	Callback = function()
		SetClipboard(tostring(game.PlaceId))
	end,
})

Tabs.Settings:CreateButton({
	Title = "GameId: <i>" .. tostring(game.GameId) .. "</i>",
	Description = "Copy the GameId above to your clipboard",
	Callback = function()
		SetClipboard(tostring(game.GameId))
	end,
})

Tabs.Settings:CreateSpacer()

Tabs.Settings:CreateButton({
	Title = "Rejoin Server",
	Description = "Rejoin the server you're in",
	Callback = function()
		if #Players:GetPlayers() <= 1 then
			Player:Kick("\nRejoining...")
			TeleportService:Teleport(game.PlaceId, Player)
		else
			TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player)
		end
	end,
})

Tabs.Settings:CreateButton({
	Title = "Hop Servers",
	Description = "Join a different server",
	Callback = function()
		if HttpRequest then
			local servers = {}
			local req = HttpRequest({
				Url = string.format(
					"https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true",
					game.PlaceId
				),
			})
			local body = HttpService:JSONDecode(req.Body)

			if body and body.data then
				for _, v in next, body.data do
					if
						type(v) == "table"
						and tonumber(v.playing)
						and tonumber(v.maxPlayers)
						and v.playing < v.maxPlayers
						and v.id ~= game.JobId
					then
						table.insert(servers, 1, v.id)
					end
				end
			end

			if #servers > 0 then
				TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], Player)
			else
			end
		else
		end
	end,
})
--#endregion

--#region Interface related settings
Tabs.Settings:CreateSection({
	Title = "Interface related settings",
})

local ThemeDropdown = Tabs.Settings:CreateDropdown("ThemeDropdown", {
	Title = "Set Theme",
	Description = "Change the look of the interface",
	Values = {
		"Abyss",
		"Adapta Nokto",
		"Ambiance",
		"Amethyst Dark",
		"Amethyst",
		"Aqua",
		"Arc Dark",
		"Dark Typewriter",
		"Dark",
		"Darker",
		"DuoTone Dark Earth",
		"DuoTone Dark Forest",
		"DuoTone Dark Sea",
		"DuoTone Dark Sky",
		"DuoTone Dark Space",
		"Elementary",
		"GitHub Dark Colorblind",
		"GitHub Dark Default",
		"GitHub Dark Dimmed",
		"GitHub Dark High Contrast",
		"GitHub Dark",
		"GitHub Light Colorblind",
		"GitHub Light Default",
		"GitHub Light High Contrast",
		"GitHub Light",
		"Kimbie Dark",
		"Light",
		"Monokai Classic",
		"Monokai Dimmed",
		"Monokai Vibrant",
		"Monokai",
		"Quiet Light",
		"Rose",
		"Solarized Dark",
		"Solarized Light",
		"Tomorrow Night Blue",
		"Typewriter",
		"United GNOME",
		"United Ubuntu",
		"VS Dark",
		"VS Light",
		"VSC Dark High Contrast",
		"VSC Dark Modern",
		"VSC Dark+",
		"VSC Light High Contrast",
		"VSC Light Modern",
		"VSC Light+",
		"VSC Red",
		"Viow Arabian Mix",
		"Viow Arabian",
		"Viow Darker",
		"Viow Flat",
		"Viow Light",
		"Viow Mars",
		"Viow Neon",
		"Vynixu",
		"Yaru Dark",
		"Yaru",
	},
	Default = "Darker",
	Callback = function(value)
		Library:SetTheme(value)
	end,
})

local TransparencyToggle = Tabs.Settings:CreateToggle("TransparencyToggle", {
	Title = "Toggle Transparency",
	Description = "Toggle the transparent look of the interface",
	Default = false,
	Callback = function(value)
		Library:ToggleTransparency(value)
	end,
})

local AcrylicToggle = Tabs.Settings:CreateToggle("AcrylicToggle", {
	Title = "Toggle Acrylic",
	Description = "Toggle the acrylic mode of the interface \n• Needs graphics level 8 and above",
	Default = Window.Acrylic,
	Callback = function(value)
		Library:ToggleAcrylic(value)
		if value == true then
			TransparencyToggle:SetValue(true)
		end
	end,
})

--#endregion

Players.PlayerAdded:Connect(function()
	Options.PlayerTeleportDropdown.Values = {}
	task.wait()
	Options.PlayerTeleportDropdown.Values = GetPlayerList()
end)
Players.PlayerRemoving:Connect(function()
	Options.PlayerTeleportDropdown.Values = {}
	task.wait()
	Options.PlayerTeleportDropdown.Values = GetPlayerList()
end)
Library:Notify({
	Title = "omni.cc",
	Content = string.format("Loaded in <i><b>%.2f</b></i> second(s)", math.floor((tick() - LoadingTick) * 100) / 100),
	Duration = 3,
})

Window:SelectTab(1)
Library:ToggleTransparency(false)
Library:ToggleAcrylic(false)
for _, screengui in ipairs(game.CoreGui:GetDescendants()) do
	if screengui.Name:match("FluentRenewed") then
		for _, descendant in ipairs(screengui:GetDescendants()) do
			if descendant:IsA("TextLabel") then
				local text = descendant.Text

				-- SECTION HEADERS
				if text:match('<font size="14">') and text:match("<b>") then
					descendant.TextXAlignment = Enum.TextXAlignment.Left
					descendant.TextYAlignment = Enum.TextYAlignment.Bottom
					descendant.Size = UDim2.new(1, 0, 0, 30)
					descendant.Position = UDim2.new(0, 5, 0, 0)

					local parent = descendant.Parent
					if parent then
						parent.Size = UDim2.new(1, 0, 1.2, 0)
						parent.Position = UDim2.new(0, 0, 0, 0)

						local padding = parent:FindFirstChild("UIPadding")
						if padding then
							padding:Destroy()
						end

						local grandparent = parent.Parent
						if grandparent then
							grandparent.BackgroundTransparency = 1

							local stroke = grandparent:FindFirstChild("UIStroke")
								or Instance.new("UIStroke", grandparent)
							stroke.Transparency = 1

							grandparent:GetPropertyChangedSignal("BackgroundTransparency"):Connect(function()
								grandparent.BackgroundTransparency = 1
							end)

							grandparent:GetPropertyChangedSignal("Transparency"):Connect(function()
								stroke.Transparency = 1
							end)
						end
					end
				end

				if text:lower():match("divider") then
					local parent = descendant.Parent
					local grandparent = parent and parent.Parent
					if parent and grandparent then
						for _, v in ipairs(parent:GetChildren()) do
							v:Destroy()
						end
						local stroke = grandparent:FindFirstChild("UIStroke") or Instance.new("UIStroke", grandparent)
						local function style_line()
							stroke.Transparency = 1
							parent.BackgroundColor3 = Color3.new(1, 1, 1)
							parent.Size = UDim2.new(1, 0, 0.1, 0)
							parent.BackgroundTransparency = 0.95
							parent.Position = UDim2.new(0, 0, 0.5, 0)
							grandparent.BackgroundTransparency = 1
						end

						style_line()

						parent:GetPropertyChangedSignal("BackgroundTransparency"):Connect(style_line)
						grandparent:GetPropertyChangedSignal("BackgroundTransparency"):Connect(style_line)
					end
				end

				if text:lower():match("spacer") then
					local parent = descendant.Parent
					local grandparent = parent and parent.Parent
					if parent and grandparent then
						for _, v in ipairs(parent:GetChildren()) do
							v:Destroy()
						end
						local stroke = grandparent:FindFirstChild("UIStroke") or Instance.new("UIStroke", grandparent)
						local function style_line()
							stroke.Transparency = 1
							parent.BackgroundColor3 = Color3.new(1, 1, 1)
							parent.Size = UDim2.new(1, 0, 0.03, 0)
							parent.BackgroundTransparency = 1
							parent.Position = UDim2.new(0, 0, 0.5, 0)
							grandparent.BackgroundTransparency = 1
						end

						style_line()

						parent:GetPropertyChangedSignal("BackgroundTransparency"):Connect(style_line)
						grandparent:GetPropertyChangedSignal("BackgroundTransparency"):Connect(style_line)
					end
				end

				descendant.Font = "Roboto"
			end

			if descendant:IsA("TextBox") and descendant.Parent:IsA("Frame") then
				descendant.TextSize = 12
			end
		end
	end
end
