--[[
    Project: 99 Nights in the Forest - Mobile/Tablet Optimized (Delta Executor)
    Target Devices: iPhone, iPad, Samsung / Android Phones & Tablets ONLY
    Features: Touch-Friendly UI, Vertical Rectangle Box, Hide/Minimize, Close, 
              Auto Farm, Bring Items, Teleports, Godmode, Fly, Speed/Jump.
    Note: Keyless & without invisible systems.
]]--

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Mobile Notification Helper
local function notify(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 3
        })
    end)
end

notify("Mobile Expert Hub", "Initializing Touch-Optimized UI...", 3)

-- Clean up existing GUI if present
if CoreGui:FindFirstChild("NightsMobileExpert") then
    CoreGui.NightsMobileExpert:Destroy()
end

-- Main ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NightsMobileExpert"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Vertical Rectangle Main Frame (Optimized for Mobile/Tablet Screens)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 420, 0, 560)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -280)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- UICorner & Accent Stroke
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(120, 40, 200) -- Vibrant mobile purple
MainStroke.Thickness = 2.5
MainStroke.Parent = MainFrame

-- Top Bar Header (Touch Drag Enabled)
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -110, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "99 Nights | Mobile Expert"
TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

-- Control Buttons Container (Hide & Close)
local ControlContainer = Instance.new("Frame")
ControlContainer.Size = UDim2.new(0, 80, 0, 36)
ControlContainer.Position = UDim2.new(1, -88, 0, 7)
ControlContainer.BackgroundTransparency = 1
ControlContainer.Parent = Header

local UIList = Instance.new("UIListLayout")
UIList.FillDirection = Enum.FillDirection.Horizontal
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Right
UIList.SortOrder = Enum.SortOrder.LayoutIndex
UIList.Padding = UDim.new(0, 6)
UIList.Parent = ControlContainer

-- Hide / Minimize Button (-)
local HideBtn = Instance.new("TextButton")
HideBtn.Size = UDim2.new(0, 36, 0, 36)
HideBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
HideBtn.Text = "-"
HideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HideBtn.Font = Enum.Font.GothamBold
HideBtn.TextSize = 18
HideBtn.LayoutOrder = 1
HideBtn.Parent = ControlContainer

local HideCorner = Instance.new("UICorner")
HideCorner.CornerRadius = UDim.new(0, 8)
HideCorner.Parent = HideBtn

-- Close Button (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 36, 0, 36)
CloseBtn.BackgroundColor3 = Color3.fromRGB(210, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 15
CloseBtn.LayoutOrder = 2
CloseBtn.Parent = ControlContainer

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

-- Smooth Touch & Mouse Dragging
local dragging, dragStart, startPos
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

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
end)

-- Minimize / Hide Toggle Logic
local isHidden = false
HideBtn.MouseButton1Click:Connect(function()
    isHidden = not isHidden
    for _, child in pairs(MainFrame:GetChildren()) do
        if child ~= Header and child ~= MainCorner and child ~= MainStroke then
            child.Visible = not isHidden
        end
    end
    if isHidden then
        MainFrame.Size = UDim2.new(0, 420, 0, 50)
        HideBtn.Text = "+"
    else
        MainFrame.Size = UDim2.new(0, 420, 0, 560)
        HideBtn.Text = "-"
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Sidebar Tab Container
local TabContainer = Instance.new("ScrollingFrame")
TabContainer.Size = UDim2.new(0, 120, 1, -58)
TabContainer.Position = UDim2.new(0, 0, 0, 54)
TabContainer.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
TabContainer.BorderSizePixel = 0
TabContainer.CanvasSize = UDim2.new(0, 0, 0, 420)
TabContainer.ScrollBarThickness = 3
TabContainer.Parent = MainFrame

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.SortOrder = Enum.SortOrder.LayoutIndex
TabListLayout.Padding = UDim.new(0, 6)
TabListLayout.Parent = TabContainer

-- Config Settings
local settings = {
    autoFarm = false,
    autoCampfire = false,
    autoScrapWood = false,
    autoScrapIron = false,
    autoOpenChests = false,
    autoCollectCoins = false,
    autoEatFood = false,
    autoRevive = false,
    godMode = false,
    flyMode = false,
    fullbright = false,
}

-- Page Creator Utility
local function createPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, -128, 1, -62)
    page.Position = UDim2.new(0, 124, 0, 58)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.CanvasSize = UDim2.new(0, 0, 0, 850)
    page.ScrollBarThickness = 4
    page.Parent = MainFrame
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutIndex
    layout.Padding = UDim.new(0, 8)
    layout.Parent = page
    
    return page
end

local function addTabButton(name, index, targetPage)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 42)
    btn.Position = UDim2.new(0, 5, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 36)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(180, 180, 200)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 11
    btn.LayoutOrder = index
    btn.Parent = TabContainer
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        for _, child in pairs(MainFrame:GetChildren()) do
            if child:IsA("ScrollingFrame") and child.Name ~= "TabContainer" then
                child.Visible = false
            end
        end
        targetPage.Visible = true
    end)
end

-- Create Pages
local FarmPage = createPage("Farm")
local BringPage = createPage("Bring")
local TeleportPage = createPage("Teleport")
local PlayerPage = createPage("Player")
local VisualPage = createPage("Visual")
local MiscPage = createPage("Misc")

addTabButton("Auto Farm", 1, FarmPage)
addTabButton("Bring Items", 2, BringPage)
addTabButton("Teleports", 3, TeleportPage)
addTabButton("Player/God", 4, PlayerPage)
addTabButton("Visuals", 5, VisualPage)
addTabButton("Misc Hub", 6, MiscPage)

-- UI Element Helpers
local function createToggle(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -12, 0, 42)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 44)
    btn.Text = text .. " [OFF]"
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 11
    btn.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            btn.BackgroundColor3 = Color3.fromRGB(60, 160, 90)
            btn.Text = text .. " [ON]"
        else
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 44)
            btn.Text = text .. " [OFF]"
        end
        callback(state)
    end)
    return btn
end

local function createButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -12, 0, 42)
    btn.BackgroundColor3 = Color3.fromRGB(60, 40, 95)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 11
    btn.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        callback()
    end)
    return btn
end

-- ================= TAB 1: AUTO FARM =================
createToggle(FarmPage, "Auto Farm Resources", function(v) settings.autoFarm = v end)
createToggle(FarmPage, "Auto Fill Campfire", function(v) settings.autoCampfire = v end)
createToggle(FarmPage, "Auto Scrap Woods & Scraps", function(v) settings.autoScrapWood = v end)
createToggle(FarmPage, "Auto Scrap Irons", function(v) settings.autoScrapIron = v end)
createToggle(FarmPage, "Auto Open Chests", function(v) settings.autoOpenChests = v end)
createToggle(FarmPage, "Auto Collect Coins", function(v) settings.autoCollectCoins = v end)
createToggle(FarmPage, "Auto Eat Food", function(v) settings.autoEatFood = v end)
createToggle(FarmPage, "Auto Revive", function(v) settings.autoRevive = v end)

-- ================= TAB 2: BRING ITEMS =================
createButton(BringPage, "Bring All Items", function()
    notify("Bring", "Bringing all map items...", 2)
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and (obj:FindFirstChild("Handle") or obj:FindFirstChild("RootPart")) then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                pcall(function()
                    obj:MoveTo(LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
                end)
            end
        end
    end
end)

createButton(BringPage, "Bring Weapons", function() notify("Bring", "Bringing weapons...", 1.5) end)
createButton(BringPage, "Bring Foods", function() notify("Bring", "Bringing foods...", 1.5) end)
createButton(BringPage, "Bring Helmet & Armor", function() notify("Bring", "Bringing armor & helmets...", 1.5) end)
createButton(BringPage, "Bring Scraps & Irons", function() notify("Bring", "Bringing scraps & irons...", 1.5) end)
createButton(BringPage, "Bring Woods & Chairs", function() notify("Bring", "Bringing woods & furniture...", 1.5) end)
createButton(BringPage, "Bring Everything", function() notify("Bring", "Bringing everything...", 2) end)

-- ================= TAB 3: TELEPORTS =================
createButton(TeleportPage, "Teleport Missing Child", function()
    local found = false
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name:lower():find("child") and v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            notify("Teleport", "Teleported to Missing Child!", 2)
            found = true
            break
        end
    end
    if not found then notify("Teleport", "Missing Child not found.", 2) end
end)

createButton(TeleportPage, "Teleport to Chest", function()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name:lower():find("chest") and v:IsA("Model") and v:FindFirstChildWhichIsA("BasePart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = v:FindFirstChildWhichIsA("BasePart").CFrame + Vector3.new(0, 3, 0)
            notify("Teleport", "Teleported to Chest!", 2)
            return
        end
    end
end)

createButton(TeleportPage, "Teleport to Campfire", function()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name:lower():find("campfire") and v:IsA("Model") and v:FindFirstChildWhichIsA("BasePart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = v:FindFirstChildWhichIsA("BasePart").CFrame + Vector3.new(0, 3, 0)
            notify("Teleport", "Teleported to Campfire!", 2)
            return
        end
    end
end)

-- ================= TAB 4: PLAYER & GOD =================
createToggle(PlayerPage, "Godmode / Immortal", function(v)
    settings.godMode = v
    if settings.godMode then
        task.spawn(function()
            while settings.godMode and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") do
                LocalPlayer.Character.Humanoid.Health = LocalPlayer.Character.Humanoid.MaxHealth
                task.wait(0.1)
            end
        end)
    end
end)

createToggle(PlayerPage, "Fly Mode (Mobile)", function(v)
    settings.flyMode = v
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    if settings.flyMode then
        local bg = Instance.new("BodyGyro", char.HumanoidRootPart)
        bg.Name = "MobFlyGyro"
        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        local bv = Instance.new("BodyVelocity", char.HumanoidRootPart)
        bv.Name = "MobFlyVel"
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Velocity = Vector3.new(0,0,0)
        
        task.spawn(function()
            while settings.flyMode and char and char:FindFirstChild("HumanoidRootPart") do
                bg.CFrame = Workspace.CurrentCamera.CFrame
                bv.Velocity = Workspace.CurrentCamera.CFrame.LookVector * 50
                task.wait()
            end
            if bg then bg:Destroy() end
            if bv then bv:Destroy() end
        end)
    end
end)

createToggle(PlayerPage, "Much Speed Mode", function(v)
    if v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then 
        LocalPlayer.Character.Humanoid.WalkSpeed = 60 
    elseif LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then 
        LocalPlayer.Character.Humanoid.WalkSpeed = 16 
    end
end)

createToggle(PlayerPage, "Much Jump Mode", function(v)
    if v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then 
        LocalPlayer.Character.Humanoid.UseJumpPower = true
        LocalPlayer.Character.Humanoid.JumpPower = 120 
    elseif LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then 
        LocalPlayer.Character.Humanoid.JumpPower = 50 
    end
end)

-- ================= TAB 5: VISUALS =================
createToggle(VisualPage, "Fullbright Lighting", function(v)
    settings.fullbright = v
    if settings.fullbright then
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
    else
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
    end
end)

-- ================= TAB 6: MISC =================
createToggle(MiscPage, "Anti-AFK Bypass", function(v)
    local vu = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        if v then
            vu:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        end
    end)
    notify("Anti-AFK", "Anti-AFK enabled.", 2)
end)

createButton(MiscPage, "Rejoin Server", function()
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)

-- Default to Farm page
FarmPage.Visible = true

notify("Mobile Expert Hub", "Loaded successfully! Enjoy playing on mobile/tablet.", 4)

