--// ============================================================================
--// BRAINROT DEV PANEL v3.0 [MOBILE & TABLET EDITION]
--// Optimized for Delta Executor, Hydrogen, Fluxus Mobile, Codex, and Roblox Studio.
--// KEYLESS - NO KEY REQUIRED - FULL UNIVERSAL EXECUTOR SUPPORT
--// ============================================================================

--[========== DOUBLE LOAD GUARD ==========]
if getgenv().BrainrotLoaded then
	warn("[Brainrot Panel]: Script is already running!")
	return
end
getgenv().BrainrotLoaded = true

--[========== SERVICES CACHE ==========]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--[========== EXECUTOR COMPATIBILITY WRAPPERS ==========]
local request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local protect_gui = protectgui or (syn and syn.protect_gui) or function(gui) end
local identify_executor = identifyexecutor or function() return "Delta Executor / Universal Mobile" end

--[========== STATE MANAGEMENT ==========]
local State = {
	-- Movement
	Fly = false,
	FlySpeed = 32,
	FlyMode = "CFrame", -- "CFrame" or "Velocity"
	Noclip = false,
	InfJump = false,
	WalkSpeed = 16,
	JumpPower = 50,
	Gravity = 196.2,
	VerticalFly = 0,
	
	-- Visuals
	EspEnabled = false,
	EspBoxes = true,
	EspNames = true,
	EspTracers = false,
	FullBright = false,
	FpsBoost = false,
	FovValue = 70,
	
	-- Automation & Game Remotes
	AutoSell = false,
	AutoFarm = false,
	AutoRebirth = false,
	AutoAnnounce = false,
	AnnounceText = "Brainrot Dev Panel - Mobile Event Active!",
	AnnounceInterval = 10,
	
	-- Target Player
	SelectedTarget = nil,
	
	-- System
	AntiAFK = true
}

-- Lighting & Material Backup Storage
local SavedVisuals = {
	Lighting = {},
	Materials = {},
	Particles = {}
}

--[========== REMOTES BINDING ==========]
local panelFolder = ReplicatedStorage:FindFirstChild("BrainrotDevPanel")
local commandEvent = panelFolder and panelFolder:FindFirstChild("Command")
local stateEvent = panelFolder and panelFolder:FindFirstChild("State")

local function safeFireServer(cmd, data)
	data = data or {}
	data.cmd = cmd
	if commandEvent then
		pcall(function()
			commandEvent:FireServer(data)
		end)
	else
		-- Standalone Executor Fallback Log
		warn("[Brainrot Event]: DevPanel Remote missing in ReplicatedStorage. Command executed locally: " .. tostring(cmd))
	end
end

--[========== GUI ENGINE CREATION ==========]
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local GuiName = "BrainrotDevPanel_MobileUI"

-- Clean old instances
if PlayerGui:FindFirstChild(GuiName) then
	PlayerGui[GuiName]:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GuiName
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
protect_gui(ScreenGui)
ScreenGui.Parent = PlayerGui

--[========== NOTIFICATION SYSTEM (TOASTS) ==========]
local NotificationHolder = Instance.new("Frame")
NotificationHolder.Name = "NotificationHolder"
NotificationHolder.Size = UDim2.new(0, 260, 1, -20)
NotificationHolder.Position = UDim2.new(1, -270, 0, 10)
NotificationHolder.BackgroundTransparency = 1
NotificationHolder.Parent = ScreenGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.Padding = UDim.new(0, 8)
NotifLayout.Parent = NotificationHolder

local function Notify(titleText, descText, duration)
	duration = duration or 3
	
	local notifFrame = Instance.new("Frame")
	notifFrame.Size = UDim2.new(1, 0, 0, 60)
	notifFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
	notifFrame.BorderSizePixel = 0
	notifFrame.BackgroundTransparency = 1
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = notifFrame
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(0, 200, 255)
	stroke.Thickness = 1.5
	stroke.Transparency = 1
	stroke.Parent = notifFrame
	
	local tLabel = Instance.new("TextLabel")
	tLabel.Size = UDim2.new(1, -16, 0, 22)
	tLabel.Position = UDim2.new(0, 10, 0, 6)
	tLabel.BackgroundTransparency = 1
	tLabel.Text = titleText
	tLabel.TextColor3 = Color3.fromRGB(0, 220, 255)
	tLabel.TextXAlignment = Enum.TextXAlignment.Left
	tLabel.Font = Enum.Font.GothamBold
	tLabel.TextSize = 14
	tLabel.Parent = notifFrame
	
	local dLabel = Instance.new("TextLabel")
	dLabel.Size = UDim2.new(1, -16, 0, 26)
	dLabel.Position = UDim2.new(0, 10, 0, 28)
	dLabel.BackgroundTransparency = 1
	dLabel.Text = descText
	dLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
	dLabel.TextXAlignment = Enum.TextXAlignment.Left
	dLabel.TextWrapped = true
	dLabel.Font = Enum.Font.Gotham
	dLabel.TextSize = 11
	dLabel.Parent = notifFrame

	notifFrame.Parent = NotificationHolder
	
	-- Fade In Tween
	TweenService:Create(notifFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
	TweenService:Create(stroke, TweenInfo.new(0.3), {Transparency = 0}):Play()
	
	task.delay(duration, function()
		if notifFrame then
			local fadeOut = TweenService:Create(notifFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1})
			TweenService:Create(stroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
			fadeOut:Play()
			fadeOut.Completed:Connect(function()
				notifFrame:Destroy()
			end)
		end
	end)
end

Notify("Brainrot Dev Panel Loaded!", "Keyless Mobile Edition initialized successfully.", 4)

--[========== FLOATING TOGGLE BALL (MOBILE TOUCH ACCESSIBLE) ==========]
local FloatingButton = Instance.new("TextButton")
FloatingButton.Name = "FloatingToggle"
FloatingButton.Size = UDim2.fromOffset(54, 54)
FloatingButton.Position = UDim2.new(0, 15, 0.4, 0)
FloatingButton.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
FloatingButton.BorderSizePixel = 0
FloatingButton.Text = "⚡"
FloatingButton.TextSize = 26
FloatingButton.TextColor3 = Color3.fromRGB(0, 220, 255)
FloatingButton.Font = Enum.Font.GothamBold
FloatingButton.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0) -- Circle
FloatCorner.Parent = FloatingButton

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = Color3.fromRGB(0, 200, 255)
FloatStroke.Thickness = 2
FloatStroke.Parent = FloatingButton

-- Dragging floating button on touch
do
	local dragging = false
	local dragInput, dragStart, startPos

	FloatingButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = FloatingButton.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	FloatingButton.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			FloatingButton.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

--[========== MAIN WINDOW FRAME ==========]
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.fromOffset(450, 320)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(45, 45, 65)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- Floating Toggle click event
FloatingButton.Activated:Connect(function()
	MainFrame.Visible = not MainFrame.Visible
end)

-- Window Dragging (Header)
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 48)
Header.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 16)
HeaderCorner.Parent = Header

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -100, 1, 0)
TitleLabel.Position = UDim2.new(0, 16, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "BRAINROT PANEL <font color='#00E0FF'>v3.0</font>"
TitleLabel.RichText = true
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextSize = 16
TitleLabel.Parent = Header

local KeylessBadge = Instance.new("TextLabel")
KeylessBadge.Size = UDim2.new(0, 75, 0, 22)
KeylessBadge.Position = UDim2.new(1, -125, 0.5, -11)
KeylessBadge.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
KeylessBadge.Text = "KEYLESS"
KeylessBadge.TextColor3 = Color3.fromRGB(255, 255, 255)
KeylessBadge.Font = Enum.Font.GothamBold
KeylessBadge.TextSize = 10
KeylessBadge.Parent = Header

local BadgeCorner = Instance.new("UICorner")
BadgeCorner.CornerRadius = UDim.new(0, 6)
BadgeCorner.Parent = KeylessBadge

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -40, 0.5, -16)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 60)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.Activated:Connect(function()
	MainFrame.Visible = false
end)

-- Dragging implementation for Header
do
	local dragging = false
	local dragInput, dragStart, startPos

	Header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = MainFrame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	Header.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			MainFrame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

--[========== NAVIGATION TABS SYSTEM ==========]
local TabBar = Instance.new("ScrollingFrame")
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(1, -24, 0, 36)
TabBar.Position = UDim2.new(0, 12, 0, 54)
TabBar.BackgroundTransparency = 1
TabBar.ScrollBarThickness = 0
TabBar.CanvasSize = UDim2.fromOffset(0, 0)
TabBar.Parent = MainFrame

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 8)
TabListLayout.Parent = TabBar

TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	TabBar.CanvasSize = UDim2.fromOffset(TabListLayout.AbsoluteContentSize.X + 10, 0)
end)

local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -24, 1, -100)
ContentContainer.Position = UDim2.new(0, 12, 0, 94)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local Tabs = {}
local activeTabButton = nil

local function CreateTab(name, icon)
	local tabBtn = Instance.new("TextButton")
	tabBtn.Size = UDim2.new(0, 100, 1, 0)
	tabBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
	tabBtn.Text = icon .. " " .. name
	tabBtn.TextColor3 = Color3.fromRGB(160, 160, 180)
	tabBtn.Font = Enum.Font.GothamBold
	tabBtn.TextSize = 12
	tabBtn.Parent = TabBar
	
	local tabCorner = Instance.new("UICorner")
	tabCorner.CornerRadius = UDim.new(0, 8)
	tabCorner.Parent = tabBtn

	local tabScroll = Instance.new("ScrollingFrame")
	tabScroll.Name = name .. "Tab"
	tabScroll.Size = UDim2.new(1, 0, 1, 0)
	tabScroll.BackgroundTransparency = 1
	tabScroll.BorderSizePixel = 0
	tabScroll.ScrollBarThickness = 4
	tabScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 255)
	tabScroll.Visible = false
	tabScroll.Parent = ContentContainer

	local contentLayout = Instance.new("UIListLayout")
	contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
	contentLayout.Padding = UDim.new(0, 8)
	contentLayout.Parent = tabScroll

	contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		tabScroll.CanvasSize = UDim2.fromOffset(0, contentLayout.AbsoluteContentSize.Y + 15)
	end)

	tabBtn.Activated:Connect(function()
		for _, t in pairs(Tabs) do
			t.Scroll.Visible = false
			t.Button.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
			t.Button.TextColor3 = Color3.fromRGB(160, 160, 180)
		end
		tabScroll.Visible = true
		tabBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 230)
		tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	end)

	Tabs[name] = { Button = tabBtn, Scroll = tabScroll }
	return tabScroll
end

-- Generate Tabs
local TabLocal = CreateTab("Local", "🚀")
local TabVisuals = CreateTab("Visuals", "👁️")
local TabAuto = CreateTab("Brainrot", "🧠")
local TabTarget = CreateTab("Players", "🎯")
local TabServer = CreateTab("Server", "🌐")

-- Set Default Active Tab
Tabs["Local"].Scroll.Visible = true
Tabs["Local"].Button.BackgroundColor3 = Color3.fromRGB(0, 180, 230)
Tabs["Local"].Button.TextColor3 = Color3.fromRGB(255, 255, 255)

--[========== UI COMPONENT BUILDERS ==========]
local function AddSection(parent, titleText)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 24)
	label.BackgroundTransparency = 1
	label.Text = "— " .. string.upper(titleText) .. " —"
	label.TextColor3 = Color3.fromRGB(0, 200, 255)
	label.Font = Enum.Font.GothamBlack
	label.TextSize = 11
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
end

local function AddButton(parent, text, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -6, 0, 38)
	btn.BackgroundColor3 = Color3.fromRGB(32, 34, 46)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(240, 240, 250)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 12
	btn.AutoButtonColor = true
	btn.Parent = parent

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = btn

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(50, 52, 68)
	stroke.Thickness = 1
	stroke.Parent = btn

	btn.Activated:Connect(function()
		pcall(callback)
	end)

	return btn
end

local function AddToggle(parent, text, defaultState, callback)
	local state = defaultState or false

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -6, 0, 38)
	btn.BackgroundColor3 = state and Color3.fromRGB(20, 110, 70) or Color3.fromRGB(32, 34, 46)
	btn.Text = (state and "[ON] " or "[OFF] ") .. text
	btn.TextColor3 = state and Color3.fromRGB(150, 255, 180) or Color3.fromRGB(200, 200, 210)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 12
	btn.Parent = parent

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = btn

	btn.Activated:Connect(function()
		state = not state
		btn.Text = (state and "[ON] " or "[OFF] ") .. text
		btn.BackgroundColor3 = state and Color3.fromRGB(20, 110, 70) or Color3.fromRGB(32, 34, 46)
		btn.TextColor3 = state and Color3.fromRGB(150, 255, 180) or Color3.fromRGB(200, 200, 210)
		pcall(callback, state)
	end)

	return btn
end

local function AddSlider(parent, text, min, max, default, callback)
	local value = default

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -6, 0, 48)
	frame.BackgroundColor3 = Color3.fromRGB(28, 30, 40)
	frame.Parent = parent

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = frame

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -12, 0, 20)
	title.Position = UDim2.new(0, 8, 0, 4)
	title.BackgroundTransparency = 1
	title.Text = text .. ": " .. tostring(value)
	title.TextColor3 = Color3.fromRGB(220, 220, 230)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 11
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = frame

	local sliderBar = Instance.new("Frame")
	sliderBar.Size = UDim2.new(1, -16, 0, 10)
	sliderBar.Position = UDim2.new(0, 8, 0, 28)
	sliderBar.BackgroundColor3 = Color3.fromRGB(45, 48, 62)
	sliderBar.Parent = frame

	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(1, 0)
	barCorner.Parent = sliderBar

	local fillBar = Instance.new("Frame")
	fillBar.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	fillBar.BackgroundColor3 = Color3.fromRGB(0, 180, 240)
	fillBar.Parent = sliderBar

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = fillBar

	local function update(input)
		local pos = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
		value = math.floor(min + (max - min) * pos)
		fillBar.Size = UDim2.new(pos, 0, 1, 0)
		title.Text = text .. ": " .. tostring(value)
		pcall(callback, value)
	end

	local dragging = false
	sliderBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			update(input)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			update(input)
		end
	end)
end

--[========== MOBILE FLY TOUCH CONTROLLER OVERLAY ==========]
local FlyOverlay = Instance.new("Frame")
FlyOverlay.Name = "FlyControlsOverlay"
FlyOverlay.Size = UDim2.fromOffset(130, 130)
FlyOverlay.Position = UDim2.new(1, -145, 1, -155)
FlyOverlay.BackgroundTransparency = 1
FlyOverlay.Visible = false
FlyOverlay.Parent = ScreenGui

local function CreateFlyTouchBtn(text, pos, dirValue)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.fromOffset(110, 48)
	btn.Position = pos
	btn.BackgroundColor3 = Color3.fromRGB(24, 26, 36)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(0, 220, 255)
	btn.Font = Enum.Font.GothamBlack
	btn.TextSize = 13
	btn.Parent = FlyOverlay

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 10)
	c.Parent = btn

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(0, 200, 255)
	stroke.Thickness = 1.5
	stroke.Parent = btn

	btn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			State.VerticalFly = dirValue
		end
	end)

	btn.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			State.VerticalFly = 0
		end
	end)
end

CreateFlyTouchBtn("▲ FLY UP", UDim2.fromOffset(10, 0), 1)
CreateFlyTouchBtn("▼ FLY DOWN", UDim2.fromOffset(10, 60), -1)

--[========== FLY ENGINE v3 ==========]
local flyConnection, flyBodyVel, flyBodyGyro

local function StopFlyEngine()
	State.Fly = false
	FlyOverlay.Visible = false

	if flyConnection then flyConnection:Disconnect() flyConnection = nil end
	if flyBodyVel then flyBodyVel:Destroy() flyBodyVel = nil end
	if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end

	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then hum.PlatformStand = false end
end

local function StartFlyEngine()
	StopFlyEngine()
	State.Fly = true
	FlyOverlay.Visible = true

	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local root = char:WaitForChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")

	if State.FlyMode == "Velocity" then
		flyBodyVel = Instance.new("BodyVelocity")
		flyBodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		flyBodyVel.Velocity = Vector3.zero
		flyBodyVel.Parent = root

		flyBodyGyro = Instance.new("BodyGyro")
		flyBodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
		flyBodyGyro.CFrame = root.CFrame
		flyBodyGyro.Parent = root
	end

	flyConnection = RunService.RenderStepped:Connect(function()
		if not State.Fly or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			StopFlyEngine()
			return
		end

		local c = LocalPlayer.Character
		local r = c.HumanoidRootPart
		local h = c:FindFirstChildOfClass("Humanoid")
		local cam = workspace.CurrentCamera

		if h then h.PlatformStand = true end

		local moveDir = h and h.MoveDirection or Vector3.zero
		local speed = State.FlySpeed

		if State.FlyMode == "Velocity" and flyBodyVel and flyBodyGyro then
			local vel = (moveDir * speed) + Vector3.new(0, State.VerticalFly * speed, 0)
			flyBodyVel.Velocity = vel
			flyBodyGyro.CFrame = cam.CFrame
		else
			-- CFrame Smooth Fly
			local camCF = cam.CFrame
			local newPos = r.CFrame.Position + (camCF.LookVector * (moveDir.Z * -speed * 0.02)) + (camCF.RightVector * (moveDir.X * speed * 0.02)) + Vector3.new(0, State.VerticalFly * speed * 0.02, 0)
			r.CFrame = CFrame.new(newPos, newPos + camCF.LookVector)
		end
	end)
end

--[========== STEALTH NOCLIP ENGINE ==========]
RunService.Stepped:Connect(function()
	if State.Noclip and LocalPlayer.Character then
		for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
			if part:IsA("BasePart") and part.CanCollide then
				part.CanCollide = false
			end
		end
	end
end)

--[========== INFINITE JUMP ENGINE ==========]
UserInputService.JumpRequest:Connect(function()
	if State.InfJump and LocalPlayer.Character then
		local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

--[========== TAP TELEPORT TOOL BUILDER ==========]
local function GiveTapTpTool()
	local tool = Instance.new("Tool")
	tool.Name = "Tap Teleport [Mobile]"
	tool.RequiresHandle = false
	tool.Parent = LocalPlayer.Backpack

	tool.Activated:Connect(function()
		local pos = Mouse.Hit.Position
		if pos and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
			Notify("Teleported!", "Moved to selected tap position.")
		end
	end)
end

--[========== TAB 1: LOCAL PLAYER & MOVEMENT ==========]
AddSection(TabLocal, "Movement Physics")

AddSlider(TabLocal, "WalkSpeed", 16, 250, 16, function(v)
	State.WalkSpeed = v
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
		LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = v
	end
end)

AddSlider(TabLocal, "JumpPower", 50, 350, 50, function(v)
	State.JumpPower = v
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
		LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = v
	end
end)

AddSlider(TabLocal, "Fly Speed", 16, 200, 32, function(v)
	State.FlySpeed = v
end)

AddToggle(TabLocal, "Toggle Flight Engine", false, function(active)
	if active then StartFlyEngine() else StopFlyEngine() end
	safeFireServer("ToggleFly", { enabled = active })
end)

AddToggle(TabLocal, "Stealth Noclip", false, function(active)
	State.Noclip = active
	Notify("Noclip Mode", active and "Enabled collision pass" or "Disabled noclip")
end)

AddToggle(TabLocal, "Infinite Air Jump", false, function(active)
	State.InfJump = active
end)

AddButton(TabLocal, "Give Tap-Teleport Mobile Tool", function()
	GiveTapTpTool()
	Notify("Tool Added", "Equip 'Tap Teleport' tool and tap anywhere!")
end)

AddButton(TabLocal, "Reset Character", function()
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
		LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Health = 0
	end
end)

--[========== UNIVERSAL ESP ENGINE ==========]
local EspFolder = Instance.new("Folder")
EspFolder.Name = "Brainrot_ESP"
EspFolder.Parent = ScreenGui

local function ClearEsp()
	EspFolder:ClearAllChildren()
end

local function RenderEsp()
	ClearEsp()
	if not State.EspEnabled then return end

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local char = p.Character
			local root = char.HumanoidRootPart

			-- Highlight Box
			if State.EspBoxes then
				local hl = Instance.new("Highlight")
				hl.Adornee = char
				hl.FillColor = Color3.fromRGB(0, 200, 255)
				hl.FillTransparency = 0.6
				hl.OutlineColor = Color3.fromRGB(255, 255, 255)
				hl.OutlineTransparency = 0
				hl.Parent = EspFolder
			end

			-- Billboard GUI
			if State.EspNames then
				local bb = Instance.new("BillboardGui")
				bb.Adornee = root
				bb.Size = UDim2.fromOffset(150, 30)
				bb.StudsOffset = Vector3.new(0, 3.5, 0)
				bb.AlwaysOnTop = true
				bb.Parent = EspFolder

				local txt = Instance.new("TextLabel")
				txt.Size = UDim2.new(1, 0, 1, 0)
				txt.BackgroundTransparency = 1
				txt.Text = p.DisplayName .. " (@" .. p.Name .. ")"
				txt.TextColor3 = Color3.fromRGB(255, 255, 255)
				txt.Font = Enum.Font.GothamBold
				txt.TextSize = 11
				txt.Parent = bb
			end
		end
	end
end

task.spawn(function()
	while task.wait(2) do
		if State.EspEnabled then pcall(RenderEsp) end
	end
end)

--[========== DEEP FPS BOOSTER ENGINE ==========]
local function SetFpsBoost(enabled)
	State.FpsBoost = enabled

	if enabled then
		SavedVisuals.Lighting.GlobalShadows = Lighting.GlobalShadows
		SavedVisuals.Lighting.FogEnd = Lighting.FogEnd
		Lighting.GlobalShadows = false
		Lighting.FogEnd = 9e9

		for _, v in ipairs(workspace:GetDescendants()) do
			if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Fire") or v:IsA("Smoke") then
				SavedVisuals.Particles[v] = v.Enabled
				v.Enabled = false
			elseif v:IsA("BasePart") and not v:IsDescendantOf(LocalPlayer.Character) then
				SavedVisuals.Materials[v] = { Material = v.Material, Reflectance = v.Reflectance }
				v.Material = Enum.Material.SmoothPlastic
				v.Reflectance = 0
			end
		end
		Notify("FPS Boost Active", "Stripped heavy textures and visual effects.")
	else
		Lighting.GlobalShadows = SavedVisuals.Lighting.GlobalShadows or true
		Lighting.FogEnd = SavedVisuals.Lighting.FogEnd or 100000

		for obj, state in pairs(SavedVisuals.Particles) do
			if obj and obj.Parent then obj.Enabled = state end
		end
		for obj, props in pairs(SavedVisuals.Materials) do
			if obj and obj.Parent then
				obj.Material = props.Material
				obj.Reflectance = props.Reflectance
			end
		end
		Notify("FPS Boost Disabled", "Restored graphics quality.")
	end
end

--[========== TAB 2: VISUALS & RENDER ==========]
AddSection(TabVisuals, "ESP Suite")

AddToggle(TabVisuals, "Enable Player ESP", false, function(active)
	State.EspEnabled = active
	if active then RenderEsp() else ClearEsp() end
end)

AddToggle(TabVisuals, "ESP Boxes", true, function(active)
	State.EspBoxes = active
	if State.EspEnabled then RenderEsp() end
end)

AddToggle(TabVisuals, "ESP Name Tags", true, function(active)
	State.EspNames = active
	if State.EspEnabled then RenderEsp() end
end)

AddSection(TabVisuals, "Lighting & Camera")

AddToggle(TabVisuals, "Full Bright / Night Vision", false, function(active)
	State.FullBright = active
	Lighting.Ambient = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(128, 128, 128)
	Lighting.Brightness = active and 3 or 1
end)

AddSlider(TabVisuals, "Field of View (FOV)", 60, 120, 70, function(v)
	workspace.CurrentCamera.FieldOfView = v
end)

AddToggle(TabVisuals, "Ultra FPS Booster", false, function(active)
	SetFpsBoost(active)
end)

--[========== TAB 3: BRAINROT AUTOMATION ==========]
AddSection(TabAuto, "Automation Loops")

AddToggle(TabAuto, "Auto Sell Owned Brainrots", false, function(active)
	State.AutoSell = active
	if active then
		task.spawn(function()
			while State.AutoSell do
				safeFireServer("SellOwned")
				task.wait(2)
			end
		end)
	end
end)

AddToggle(TabAuto, "Auto Farm Step", false, function(active)
	State.AutoFarm = active
	if active then
		task.spawn(function()
			while State.AutoFarm do
				safeFireServer("AutoFarmStep")
				task.wait(1.2)
			end
		end)
	end
end)

AddToggle(TabAuto, "Auto Rebirth Loop", false, function(active)
	State.AutoRebirth = active
	if active then
		task.spawn(function()
			while State.AutoRebirth do
				safeFireServer("FastRebirth")
				task.wait(5)
			end
		end)
	end
end)

AddSection(TabAuto, "Brainrot Spawner Remotes")
local rarities = { "Common", "Rare", "Epic", "Legendary", "Mythic", "Brainrot God", "Secret" }
for _, r in ipairs(rarities) do
	AddButton(TabAuto, "Spawn " .. r .. " Brainrot", function()
		safeFireServer("SpawnBrainrot", { rarity = r })
		Notify("Remote Fired", "Spawn request sent for: " .. r)
	end)
end

AddSection(TabAuto, "Broadcasting")
AddToggle(TabAuto, "Auto Announcement Spammer", false, function(active)
	State.AutoAnnounce = active
	if active then
		task.spawn(function()
			while State.AutoAnnounce do
				safeFireServer("Announce", { text = State.AnnounceText })
				task.wait(State.AnnounceInterval)
			end
		end)
	end
end)

--[========== TAB 4: TARGET PLAYER SELECTION ==========]
AddSection(TabTarget, "Target Selector")

local PlayerDropdownFrame = Instance.new("Frame")
PlayerDropdownFrame.Size = UDim2.new(1, -6, 0, 36)
PlayerDropdownFrame.BackgroundColor3 = Color3.fromRGB(30, 32, 44)
PlayerDropdownFrame.Parent = TabTarget

local DropdownCorner = Instance.new("UICorner")
DropdownCorner.CornerRadius = UDim.new(0, 8)
DropdownCorner.Parent = PlayerDropdownFrame

local TargetNameLabel = Instance.new("TextLabel")
TargetNameLabel.Size = UDim2.new(1, -10, 1, 0)
TargetNameLabel.Position = UDim2.new(0, 10, 0, 0)
TargetNameLabel.BackgroundTransparency = 1
TargetNameLabel.Text = "Selected Target: None"
TargetNameLabel.TextColor3 = Color3.fromRGB(0, 220, 255)
TargetNameLabel.Font = Enum.Font.GothamBold
TargetNameLabel.TextSize = 11
TargetNameLabel.TextXAlignment = Enum.TextXAlignment.Left
TargetNameLabel.Parent = PlayerDropdownFrame

AddButton(TabTarget, "Cycle Next Player Target", function()
	local plrs = Players:GetPlayers()
	if #plrs <= 1 then
		Notify("Target System", "No other players in server!")
		return
	end
	
	local currentIndex = 1
	for i, p in ipairs(plrs) do
		if p == State.SelectedTarget then currentIndex = i break end
	end
	
	local nextIndex = (currentIndex % #plrs) + 1
	if plrs[nextIndex] == LocalPlayer then nextIndex = (nextIndex % #plrs) + 1 end
	
	State.SelectedTarget = plrs[nextIndex]
	TargetNameLabel.Text = "Selected Target: " .. State.SelectedTarget.DisplayName .. " (@" .. State.SelectedTarget.Name .. ")"
	Notify("Target Selected", State.SelectedTarget.Name)
end)

AddButton(TabTarget, "Teleport to Selected Player", function()
	if State.SelectedTarget and State.SelectedTarget.Character and State.SelectedTarget.Character:FindFirstChild("HumanoidRootPart") then
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			LocalPlayer.Character.HumanoidRootPart.CFrame = State.SelectedTarget.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
			Notify("Teleported", "Moved to " .. State.SelectedTarget.Name)
		end
	else
		Notify("Error", "Target player character missing!")
	end
end)

AddButton(TabTarget, "Spectate Target Player", function()
	if State.SelectedTarget and State.SelectedTarget.Character and State.SelectedTarget.Character:FindFirstChildOfClass("Humanoid") then
		workspace.CurrentCamera.CameraSubject = State.SelectedTarget.Character:FindFirstChildOfClass("Humanoid")
		Notify("Spectating", State.SelectedTarget.Name)
	end
end)

AddButton(TabTarget, "Stop Spectating (Reset Cam)", function()
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
		workspace.CurrentCamera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	end
end)

--[========== TAB 5: SERVER & EXTERNAL UTILITIES ==========]
AddSection(TabServer, "Server Utilities")

AddButton(TabServer, "Rejoin Current Server", function()
	TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

AddButton(TabServer, "Server Hop (Low Player Server)", function()
	Notify("Server Hop", "Searching for available servers...")
	pcall(function()
		local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
		for _, s in ipairs(servers) do
			if s.playing < s.maxPlayers and s.id ~= game.JobId then
				TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
				break
			end
		end
	end)
end)

AddButton(TabServer, "Copy Game Job ID", function()
	if setclipboard then
		setclipboard(tostring(game.JobId))
		Notify("Clipboard", "Job ID copied to clipboard!")
	end
end)

AddSection(TabServer, "External Mobile Script Hubs")

AddButton(TabServer, "Load Infinite Yield Mobile", function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
	Notify("Script Hub", "Loaded Infinite Yield!")
end)

AddButton(TabServer, "Load Mobile Dex Explorer", function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
	Notify("Script Hub", "Loaded Mobile Dex Explorer!")
end)

--[========== ANTI-AFK CONNECTION ==========]
LocalPlayer.Idled:Connect(function()
	if State.AntiAFK then
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new())
		Notify("Anti-AFK", "Prevented 20-minute idle kick.")
	end
end)

--[========== INCOMING REMOTE LISTENERS ==========]
if stateEvent then
	stateEvent.OnClientEvent:Connect(function(payload)
		if typeof(payload) ~= "table" then return end
		
		if payload.kind == "Notice" then
			Notify("Server Notice", payload.text or "Notification received.")
		elseif payload.kind == "FlyState" then
			if payload.enabled then StartFlyEngine() else StopFlyEngine() end
		elseif payload.kind == "Announcement" then
			Notify("ANNOUNCEMENT", tostring(payload.text or ""), 6)
		end
	end)
end

-- Re-apply state on respawn
LocalPlayer.CharacterAdded:Connect(function(char)
	task.wait(1)
	local hum = char:WaitForChild("Humanoid", 3)
	if hum then
		hum.WalkSpeed = State.WalkSpeed
		hum.JumpPower = State.JumpPower
	end
	if State.Fly then StartFlyEngine() end
end)

print("[Brainrot Dev Panel v3.0]: Keyless Mobile script initialization complete.")

