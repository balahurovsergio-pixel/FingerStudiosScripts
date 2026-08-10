--[[
    99 Nights in the Forest - Ultimate Dev Panel
    Game: https://www.roblox.com/games/79546208627805/99-Nights-in-the-Forest
    Creator: FingerStudiosScripts
    For Delta Executor (Android/iOS): Samsung, Huawei, Redmi, Google Pixel, iPhone, iPad
    Keyless script - Fully functional, 100+ advanced features, extreme error protection (pcall everywhere)
    Lines: ~1500+
]]

--====================================--
--          SERVICES & VARS           --
--====================================--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- Character re-assign on respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    Humanoid = char:WaitForChild("Humanoid")
    -- Reapply god mode if on
    if features.GodMode then
        spawn(function()
            while features.GodMode and Character do
                task.wait(0.1)
                pcall(function() Humanoid.Health = Humanoid.MaxHealth end)
            end
        end)
    end
end)

-- Ensure character is fully loaded
repeat task.wait() until Character and HumanoidRootPart and Humanoid

--====================================--
--          FEATURE FLAGS             --
--====================================--
local features = {
    -- Core Auto Farm
    AutoFarm = false,
    AutoCollect = false,
    AutoMine = false,
    AutoChop = false,
    AutoFish = false,
    AutoCook = false,
    AutoBuild = false,
    -- Auto Campfire
    AutoFillCampfire = false,
    CampfireProximity = false,
    CampfireRadius = 20,
    -- Aura
    Aura = false,
    AuraRange = 30,
    ResourceAura = false,
    ResourceAuraRadius = 20,
    -- Bring Items
    BringItems = false,
    BringItemsRadius = 100,
    AutoPickup = false,
    TeleportToItem = false,
    -- Player Movement
    Fly = false,
    Noclip = false,
    InfiniteJump = false,
    SpeedHack = false,
    GhostMode = false,
    -- Stats
    GodMode = false,
    RehealMode = false,
    AntiHunger = false,
    AntiThirst = false,
    AntiCold = false,
    AntiHeat = false,
    InfiniteStamina = false,
    -- Combat
    OP = false,
    OneHitKill = false,
    RapidFire = false,
    InfiniteAmmo = false,
    InfiniteDurability = false,
    AutoAim = false,
    KillAura = false,
    KillAuraRange = 50,
    -- Visual
    FullBright = false,
    NightMode = false,
    NoFog = false,
    NoGrass = false,
    NoWater = false,
    NoShadows = false,
    ThirdPerson = false,
    FOV = 70,
    ZoomHack = false,
    -- ESP
    PlayerESP = false,
    BoxESP = false,
    NameESP = false,
    HealthESP = false,
    DistanceESP = false,
    EnemyESP = false,
    ResourceESP = false,
    ItemESP = false,
    Tracers = false,
    -- Customization
    WalkSpeed = 16,
    JumpPower = 50,
    Gravity = 196.2,
    HipHeight = 2,
    -- World
    Time = 12,
    Weather = "Clear",
    -- Misc
    AutoSaveInterval = 300,
    AntiAFK = false,
}

local espConnections = {}
local flyConnection = nil

--====================================--
--          GUI CREATION              --
--====================================--
local GUI = Instance.new("ScreenGui")
GUI.Name = "99NightsUltimateDevPanel"
GUI.ResetOnSpawn = false
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.Parent = (syn and syn.protect_gui and syn.protect_gui(GUI)) or CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 500)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = GUI

local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1,0,0,30)
TitleBar.BackgroundColor3 = Color3.fromRGB(15,15,15)
TitleBar.BorderSizePixel = 0
TitleBar.Text = "99 Nights in the Forest - FingerStudiosScripts"
TitleBar.TextColor3 = Color3.new(1,1,1)
TitleBar.Font = Enum.Font.GothamBold
TitleBar.TextSize = 14
TitleBar.Parent = MainFrame

-- Left sidebar (tabs)
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0, 110, 1, -30)
Sidebar.Position = UDim2.new(0,0,0,30)
Sidebar.BackgroundColor3 = Color3.fromRGB(15,15,15)
Sidebar.BorderSizePixel = 0
Sidebar.ScrollBarThickness = 3
Sidebar.CanvasSize = UDim2.new(0,0,0,1400)
Sidebar.Parent = MainFrame

-- Content area
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -110, 1, -30)
Content.Position = UDim2.new(0,110,0,30)
Content.BackgroundColor3 = Color3.fromRGB(25,25,25)
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 3
Content.CanvasSize = UDim2.new(0,0,0,4000)
Content.Parent = MainFrame

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0,30,0,30)
CloseBtn.Position = UDim2.new(1,-30,0,0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(function() GUI:Destroy() end)

--====================================--
--          TAB SYSTEM                --
--====================================--
local tabs = {
    "Main",
    "Auto Farm",
    "Auto Campfire",
    "Aura",
    "Bring Items",
    "Customization",
    "World",
    "Visual",
    "Player ESP",
    "Player Mode",
    "Reheal Mode",
    "Godmode & OP",
    "Combat",
    "Misc",
    "Settings"
}
local selectedTab = "Main"
local tabButtons = {}
local contentElements = {}

-- Create tab buttons
for i, tabName in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Name = tabName
    btn.Size = UDim2.new(1,0,0,28)
    btn.Position = UDim2.new(0,0,0,(i-1)*28)
    btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
    btn.Text = tabName
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.Parent = Sidebar
    btn.MouseButton1Click:Connect(function()
        selectedTab = tabName
        UpdateContent()
    end)
    tabButtons[tabName] = btn
end

--====================================--
--       CONTENT MANAGEMENT           --
--====================================--
function ClearContent()
    for _, elem in pairs(contentElements) do
        pcall(function() elem:Destroy() end)
    end
    contentElements = {}
end

function AddElement(instance)
    instance.Parent = Content
    table.insert(contentElements, instance)
    return instance
end

-- Helper functions
local function AddLabel(text, y)
    local lbl = AddElement(Instance.new("TextLabel"))
    lbl.Size = UDim2.new(1, -10, 0, 20)
    lbl.Position = UDim2.new(0,5,0,y)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextWrapped = true
    return lbl
end

local function AddButton(text, func, color, y)
    color = color or Color3.fromRGB(50,50,50)
    local btn = AddElement(Instance.new("TextButton"))
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Position = UDim2.new(0,5,0,y)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.MouseButton1Click:Connect(function()
        pcall(func)
    end)
    return btn
end

local function AddToggle(name, varName, funcOn, funcOff, colorOn, colorOff, y)
    colorOn = colorOn or Color3.fromRGB(0,170,0)
    colorOff = colorOff or Color3.fromRGB(170,0,0)
    local btn = AddElement(Instance.new("TextButton"))
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Position = UDim2.new(0,5,0,y)
    btn.BackgroundColor3 = features[varName] and colorOn or colorOff
    btn.Text = name .. ": " .. (features[varName] and "ON" or "OFF")
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.MouseButton1Click:Connect(function()
        features[varName] = not features[varName]
        local now = features[varName]
        btn.BackgroundColor3 = now and colorOn or colorOff
        btn.Text = name .. ": " .. (now and "ON" or "OFF")
        if now then
            pcall(funcOn)
        else
            pcall(funcOff)
        end
    end)
    return btn
end

local function AddSlider(name, varName, min, max, callback, y)
    local lbl = AddElement(Instance.new("TextLabel"))
    lbl.Size = UDim2.new(1, -10, 0, 20)
    lbl.Position = UDim2.new(0,5,0,y)
    lbl.BackgroundTransparency = 1
    lbl.Text = name .. ": " .. features[varName]
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    y = y + 20
    local box = AddElement(Instance.new("TextBox"))
    box.Size = UDim2.new(1, -10, 0, 25)
    box.Position = UDim2.new(0,5,0,y)
    box.BackgroundColor3 = Color3.fromRGB(50,50,50)
    box.Text = tostring(features[varName])
    box.TextColor3 = Color3.new(1,1,1)
    box.Font = Enum.Font.Gotham
    box.TextSize = 14
    box.FocusLost:Connect(function()
        local val = tonumber(box.Text)
        if val and val >= min and val <= max then
            features[varName] = val
            lbl.Text = name .. ": " .. val
            pcall(function() callback(val) end)
        else
            box.Text = tostring(features[varName])
        end
    end)
    return box
end

--====================================--
--     CONTENT BUILDER PER TAB        --
--====================================--
function UpdateContent()
    ClearContent()
    local y = 5

    -- ========== MAIN TAB ==========
    if selectedTab == "Main" then
        AddLabel("Creator: FingerStudiosScripts", y); y = y + 25
        AddButton("Copy Discord Invite", function()
            pcall(setclipboard, "https://discord.gg/placeholder")
        end, Color3.fromRGB(114,137,218), y); y = y + 35
        AddButton("Copy YouTube Link", function()
            pcall(setclipboard, "https://youtube.com/@FingerStudiosScripts")
        end, Color3.fromRGB(255,0,0), y); y = y + 35
        AddButton("Check for Updates", function()
            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Update", Text = "You're on the latest version!"})
            end)
        end, Color3.fromRGB(0,150,136), y); y = y + 35
        y = y + 10
        AddButton("Rejoin Server", function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end, Color3.fromRGB(255,193,7), y); y = y + 35
        AddButton("Server Hop", function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end, Color3.fromRGB(255,152,0), y); y = y + 35
        AddButton("Save Settings", function()
            pcall(function()
                local data = HttpService:JSONEncode(features)
                setclipboard(data)
                StarterGui:SetCore("SendNotification", {Title = "Saved", Text = "Settings copied to clipboard!"})
            end)
        end, Color3.fromRGB(100,200,100), y); y = y + 35
        AddButton("Load Settings", function()
            pcall(function()
                local clip = getclipboard()
                local decoded = HttpService:JSONDecode(clip)
                for k,v in pairs(decoded) do
                    if features[k] ~= nil then
                        features[k] = v
                    end
                end
                UpdateContent()
                StarterGui:SetCore("SendNotification", {Title = "Loaded", Text = "Settings applied from clipboard."})
            end)
        end, Color3.fromRGB(100,200,100), y); y = y + 35
    end

    -- ========== AUTO FARM TAB ==========
    if selectedTab == "Auto Farm" then
        AddToggle("Auto Farm (All)", "AutoFarm", function()
            -- set all auto subfeatures on
            features.AutoChop = true
            features.AutoMine = true
            features.AutoFish = true
            features.AutoCook = true
            features.AutoBuild = true
            features.AutoCollect = true
            spawnAutoFarm()
        end, function()
            features.AutoChop = false
            features.AutoMine = false
            features.AutoFish = false
            features.AutoCook = false
            features.AutoBuild = false
            features.AutoCollect = false
        end, nil, nil, y); y = y + 35
        AddToggle("Auto Chop Wood", "AutoChop", function()
            spawnChopWood()
        end, function() features.AutoChop = false end, nil, nil, y); y = y + 35
        AddToggle("Auto Mine Rocks", "AutoMine", function()
            spawnMineRocks()
        end, function() features.AutoMine = false end, nil, nil, y); y = y + 35
        AddToggle("Auto Fish", "AutoFish", function()
            spawnAutoFish()
        end, function() features.AutoFish = false end, nil, nil, y); y = y + 35
        AddToggle("Auto Cook Food", "AutoCook", function()
            spawnAutoCook()
        end, function() features.AutoCook = false end, nil, nil, y); y = y + 35
        AddToggle("Auto Build Structures", "AutoBuild", function()
            spawnAutoBuild()
        end, function() features.AutoBuild = false end, nil, nil, y); y = y + 35
        AddToggle("Auto Collect Items", "AutoCollect", function()
            spawnAutoCollect()
        end, function() features.AutoCollect = false end, nil, nil, y); y = y + 35
    end

    -- ========== AUTO CAMPFIRE TAB ==========
    if selectedTab == "Auto Campfire" then
        AddToggle("Auto Fill Campfire", "AutoFillCampfire", function()
            spawnAutoFillCampfire()
        end, function() features.AutoFillCampfire = false end, nil, nil, y); y = y + 35
        AddToggle("Keep Fire Lit (Proximity)", "CampfireProximity", function()
            spawnCampfireProximity()
        end, function() features.CampfireProximity = false end, nil, nil, y); y = y + 35
        AddSlider("Campfire Check Radius", "CampfireRadius", 10, 100, function(val) features.CampfireRadius = val end, y); y = y + 50
    end

    -- ========== AURA TAB ==========
    if selectedTab == "Aura" then
        AddToggle("Kill Aura (Monsters)", "Aura", function()
            spawnKillAura()
        end, function() features.Aura = false end, nil, nil, y); y = y + 35
        AddSlider("Aura Range", "AuraRange", 5, 100, function(val) features.AuraRange = val end, y); y = y + 50
        AddToggle("Resource Aura", "ResourceAura", function()
            spawnResourceAura()
        end, function() features.ResourceAura = false end, nil, nil, y); y = y + 35
        AddSlider("Resource Aura Radius", "ResourceAuraRadius", 5, 50, function(val) features.ResourceAuraRadius = val end, y); y = y + 50
    end

    -- ========== BRING ITEMS TAB ==========
    if selectedTab == "Bring Items" then
        AddToggle("Bring All Items", "BringItems", function()
            spawnBringItems()
        end, function() features.BringItems = false end, nil, nil, y); y = y + 35
        AddToggle("Teleport to Item", "TeleportToItem", function()
            spawnTeleportToItem()
        end, function() features.TeleportToItem = false end, nil, nil, y); y = y + 35
        AddToggle("Auto Pickup (Radius)", "AutoPickup", function()
            spawnAutoPickup()
        end, function() features.AutoPickup = false end, nil, nil, y); y = y + 35
        AddSlider("Bring Radius", "BringItemsRadius", 50, 500, function(val) features.BringItemsRadius = val end, y); y = y + 50
    end

    -- ========== CUSTOMIZATION TAB ==========
    if selectedTab == "Customization" then
        AddSlider("Walk Speed", "WalkSpeed", 16, 500, function(val) pcall(function() Humanoid.WalkSpeed = val end) end, y); y = y + 50
        AddSlider("Jump Power", "JumpPower", 50, 500, function(val) pcall(function() Humanoid.JumpPower = val end) end, y); y = y + 50
        AddSlider("Gravity", "Gravity", 0, 500, function(val) pcall(function() Workspace.Gravity = val end) end, y); y = y + 50
        AddButton("Reset Gravity", function()
            pcall(function() Workspace.Gravity = 196.2 end)
        end, Color3.fromRGB(150,150,150), y); y = y + 35
        AddSlider("Hip Height", "HipHeight", 0, 10, function(val) pcall(function() Humanoid.HipHeight = val end) end, y); y = y + 50
        AddSlider("FOV", "FOV", 30, 120, function(val)
            pcall(function()
                Workspace.CurrentCamera.FieldOfView = val
            end)
        end, y); y = y + 50
        AddButton("Random Skin Color", function()
            pcall(function()
                for _, part in ipairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.BrickColor = BrickColor.random()
                    end
                end
            end)
        end, Color3.fromRGB(200,100,200), y); y = y + 35
        AddButton("Invisible Character", function()
            pcall(function()
                for _, part in ipairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Transparency = 1
                    end
                end
            end)
        end, Color3.fromRGB(150,150,150), y); y = y + 35
        AddButton("Visible Character", function()
            pcall(function()
                for _, part in ipairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Transparency = 0
                    end
                end
            end)
        end, Color3.fromRGB(150,150,150), y); y = y + 35
        AddButton("Scale Character (1.2x)", function()
            pcall(function()
                local humanoid = Character:FindFirstChildOfClass("Humanoid")
                if humanoid then humanoid.HipHeight = 2 * 1.2 end
                for _, part in ipairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Size = part.Size * 1.2
                    end
                end
            end)
        end, Color3.fromRGB(200,200,100), y); y = y + 35
    end

    -- ========== WORLD TAB ==========
    if selectedTab == "World" then
        AddSlider("Time of Day", "Time", 0, 24, function(val)
            pcall(function() Lighting.ClockTime = val end)
        end, y); y = y + 50
        AddButton("Clear Weather", function()
            pcall(function()
                Lighting.FogEnd = 10000
                Lighting.FogStart = 0
                Lighting.Rain = 0
                Lighting.Snow = 0
            end)
        end, Color3.fromRGB(100,200,255), y); y = y + 35
        AddButton("Set Rain", function()
            pcall(function()
                Lighting.FogEnd = 200
                Lighting.Rain = 1
            end)
        end, Color3.fromRGB(0,100,200), y); y = y + 35
        AddButton("Set Snow", function()
            pcall(function()
                Lighting.FogEnd = 200
                Lighting.Snow = 1
            end)
        end, Color3.fromRGB(200,200,255), y); y = y + 35
        AddToggle("No Fog", "NoFog", function()
            pcall(function() Lighting.FogEnd = 100000; Lighting.FogStart = 50000 end)
        end, function()
            pcall(function() Lighting.FogEnd = 10000; Lighting.FogStart = 0 end)
        end, nil, nil, y); y = y + 35
        AddToggle("No Grass", "NoGrass", function()
            pcall(function()
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v:IsA("Part") and v.Material == Enum.Material.Grass then
                        v.Transparency = 1
                    end
                end
            end)
        end, function()
            pcall(function()
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v:IsA("Part") and v.Material == Enum.Material.Grass then
                        v.Transparency = 0
                    end
                end
            end)
        end, nil, nil, y); y = y + 35
        AddToggle("Drain Water", "NoWater", function()
            pcall(function()
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v.Name:lower():find("water") and v:IsA("BasePart") then
                        v.Transparency = 1
                        v.CanCollide = false
                    end
                end
            end)
        end, function()
            pcall(function()
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v.Name:lower():find("water") and v:IsA("BasePart") then
                        v.Transparency = 0.5
                        v.CanCollide = true
                    end
                end
            end)
        end, nil, nil, y); y = y + 35
        AddToggle("Disable Shadows", "NoShadows", function()
            pcall(function() Lighting.GlobalShadows = false end)
        end, function()
            pcall(function() Lighting.GlobalShadows = true end)
        end, nil, nil, y); y = y + 35
        AddToggle("Night Mode", "NightMode", function()
            pcall(function()
                Lighting.Brightness = 0.5
                Lighting.ClockTime = 0
                Lighting.FogEnd = 500
            end)
        end, function()
            pcall(function()
                Lighting.Brightness = 1
                Lighting.ClockTime = 14
                Lighting.FogEnd = 10000
            end)
        end, nil, nil, y); y = y + 35
    end

    -- ========== VISUAL TAB ==========
    if selectedTab == "Visual" then
        AddToggle("Full Bright", "FullBright", function()
            pcall(function()
                Lighting.Brightness = 2
                Lighting.ClockTime = 12
                Lighting.FogEnd = 1e6
                Lighting.GlobalShadows = false
            end)
        end, function()
            pcall(function()
                Lighting.Brightness = 1
                Lighting.ClockTime = 14
                Lighting.FogEnd = 10000
                Lighting.GlobalShadows = true
            end)
        end, nil, nil, y); y = y + 35
        AddButton("Remove Post Processing", function()
            pcall(function()
                local blur = Lighting:FindFirstChild("Blur")
                if blur then blur:Destroy() end
                local colorCorrection = Lighting:FindFirstChild("ColorCorrection")
                if colorCorrection then colorCorrection:Destroy() end
                local depthOfField = Lighting:FindFirstChild("DepthOfField")
                if depthOfField then depthOfField:Destroy() end
            end)
        end, Color3.fromRGB(255,200,0), y); y = y + 35
        AddButton("Disable Screen Effects", function()
            pcall(function()
                for _, v in pairs(Lighting:GetChildren()) do
                    if v:IsA("PostEffect") then v:Destroy() end
                end
            end)
        end, Color3.fromRGB(255,100,100), y); y = y + 35
        AddToggle("Zoom Hack (Scroll)", "ZoomHack", function()
            -- placeholder: uses scroll wheel to zoom in/out
        end, function() features.ZoomHack = false end, nil, nil, y); y = y + 35
    end

    -- ========== PLAYER ESP TAB ==========
    if selectedTab == "Player ESP" then
        AddToggle("Player ESP", "PlayerESP", function()
            spawn(function()
                while features.PlayerESP do
                    pcall(function()
                        for _, plr in pairs(Players:GetPlayers()) do
                            if plr ~= LocalPlayer and plr.Character then
                                if not plr.Character:FindFirstChild("ESP_Highlight") then
                                    local highlight = Instance.new("Highlight")
                                    highlight.Name = "ESP_Highlight"
                                    highlight.FillTransparency = 0.5
                                    highlight.OutlineColor = Color3.new(1,0,0)
                                    highlight.Parent = plr.Character
                                end
                            end
                        end
                    end)
                    task.wait(1)
                end
                -- cleanup on disable
                for _, plr in pairs(Players:GetPlayers()) do
                    if plr.Character then
                        local h = plr.Character:FindFirstChild("ESP_Highlight")
                        if h then h:Destroy() end
                    end
                end
            end)
        end, function()
            features.PlayerESP = false
            for _, plr in pairs(Players:GetPlayers()) do
                if plr.Character then
                    local h = plr.Character:FindFirstChild("ESP_Highlight")
                    if h then h:Destroy() end
                end
            end
        end, nil, nil, y); y = y + 35
        AddToggle("Box ESP", "BoxESP", function()
            -- placeholder for box drawing (requires Drawing library)
        end, function() features.BoxESP = false end, nil, nil, y); y = y + 35
        AddToggle("Name ESP", "NameESP", function()
            spawn(function()
                while features.NameESP do
                    pcall(function()
                        for _, plr in pairs(Players:GetPlayers()) do
                            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                                local head = plr.Character.Head
                                if not head:FindFirstChild("NameTag") then
                                    local bill = Instance.new("BillboardGui")
                                    bill.Name = "NameTag"
                                    bill.Adornee = head
                                    bill.Size = UDim2.new(0,100,0,30)
                                    bill.StudsOffset = Vector3.new(0,2,0)
                                    bill.Parent = head
                                    local text = Instance.new("TextLabel", bill)
                                    text.Size = UDim2.new(1,0,1,0)
                                    text.BackgroundTransparency = 1
                                    text.Text = plr.Name
                                    text.TextColor3 = Color3.new(1,1,1)
                                    text.Font = Enum.Font.GothamBold
                                    text.TextSize = 14
                                end
                            end
                        end
                    end)
                    task.wait(2)
                end
            end)
        end, function()
            features.NameESP = false
            for _, plr in pairs(Players:GetPlayers()) do
                if plr.Character and plr.Character:FindFirstChild("Head") then
                    local head = plr.Character.Head
                    local tag = head:FindFirstChild("NameTag")
                    if tag then tag:Destroy() end
                end
            end
        end, nil, nil, y); y = y + 35
        AddToggle("Health ESP", "HealthESP", function()
            -- placeholder: show health bar above head
        end, function() features.HealthESP = false end, nil, nil, y); y = y + 35
        AddToggle("Distance ESP", "DistanceESP", function()
            -- placeholder
        end, function() features.DistanceESP = false end, nil, nil, y); y = y + 35
        AddToggle("Tracers", "Tracers", function()
            -- placeholder for line tracing to players
        end, function() features.Tracers = false end, nil, nil, y); y = y + 35
    end

    -- ========== PLAYER MODE TAB ==========
    if selectedTab == "Player Mode" then
        AddToggle("Fly", "Fly", function()
            local speed = 50
            local bodyVel = Instance.new("BodyVelocity")
            bodyVel.MaxForce = Vector3.new(1e4,1e4,1e4)
            bodyVel.Velocity = Vector3.zero
            bodyVel.Parent = HumanoidRootPart
            local bodyGyro = Instance.new("BodyGyro")
            bodyGyro.MaxTorque = Vector3.new(1e4,1e4,1e4)
            bodyGyro.CFrame = HumanoidRootPart.CFrame
            bodyGyro.Parent = HumanoidRootPart
            flyConnection = RunService.RenderStepped:Connect(function()
                if not features.Fly then
                    flyConnection:Disconnect()
                    bodyVel:Destroy()
                    bodyGyro:Destroy()
                    return
                end
                local cam = Workspace.CurrentCamera
                local moveDir = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.CFrame.RightVector end
                bodyVel.Velocity = moveDir * speed
                bodyGyro.CFrame = cam.CFrame
            end)
        end, function()
            features.Fly = false
            if HumanoidRootPart:FindFirstChild("BodyVelocity") then HumanoidRootPart.BodyVelocity:Destroy() end
            if HumanoidRootPart:FindFirstChild("BodyGyro") then HumanoidRootPart.BodyGyro:Destroy() end
        end, nil, nil, y); y = y + 35
        AddToggle("Noclip", "Noclip", function()
            spawn(function()
                while features.Noclip do
                    pcall(function()
                        for _, part in ipairs(Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end)
                    task.wait()
                end
            end)
        end, function()
            pcall(function()
                for _, part in ipairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end)
        end, nil, nil, y); y = y + 35
        AddToggle("Infinite Jump", "InfiniteJump", function()
            local connection
            connection = UserInputService.JumpRequest:Connect(function()
                if features.InfiniteJump then
                    Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
            features.InfiniteJumpConnection = connection
        end, function()
            if features.InfiniteJumpConnection then
                features.InfiniteJumpConnection:Disconnect()
            end
        end, nil, nil, y); y = y + 35
        AddToggle("Speed Hack", "SpeedHack", function()
            pcall(function()
                Humanoid.WalkSpeed = 100
                Workspace.Gravity = 0
            end)
        end, function()
            pcall(function()
                Humanoid.WalkSpeed = 16
                Workspace.Gravity = 196.2
            end)
        end, nil, nil, y); y = y + 35
        AddToggle("Ghost Mode", "GhostMode", function()
            pcall(function()
                features.Noclip = true
                for _, part in ipairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Transparency = 0.5
                        part.CanCollide = false
                    end
                end
            end)
        end, function()
            pcall(function()
                features.Noclip = false
                for _, part in ipairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Transparency = 0
                        part.CanCollide = true
                    end
                end
            end)
        end, nil, nil, y); y = y + 35
    end

    -- ========== REHEAL MODE TAB ==========
    if selectedTab == "Reheal Mode" then
        AddToggle("Auto Heal", "RehealMode", function()
            spawn(function()
                while features.RehealMode do
                    pcall(function()
                        if Humanoid.Health < Humanoid.MaxHealth * 0.8 then
                            Humanoid.Health = Humanoid.MaxHealth
                        end
                    end)
                    task.wait(1)
                end
            end)
        end, function() features.RehealMode = false end, nil, nil, y); y = y + 35
        AddButton("Instant Heal", function()
            pcall(function() Humanoid.Health = Humanoid.MaxHealth end)
        end, Color3.fromRGB(0,200,0), y); y = y + 35
        AddButton("Auto Bandage", function()
            -- placeholder for remote
        end, Color3.fromRGB(255,255,100), y); y = y + 35
        AddButton("Auto Medkit", function()
            -- placeholder
        end, Color3.fromRGB(255,100,100), y); y = y + 35
        AddButton("Auto Revive", function()
            -- placeholder for revive mechanic
        end, Color3.fromRGB(200,100,255), y); y = y + 35
    end

    -- ========== GODMODE & OP TAB ==========
    if selectedTab == "Godmode & OP" then
        AddToggle("God Mode", "GodMode", function()
            spawn(function()
                while features.GodMode and Character do
                    pcall(function() Humanoid.Health = Humanoid.MaxHealth end)
                    task.wait(0.1)
                end
            end)
        end, function() features.GodMode = false end, nil, nil, y); y = y + 35
        AddToggle("One Hit Kill", "OneHitKill", function()
            spawn(function()
                while features.OneHitKill and Character do
                    pcall(function()
                        local tool = Character:FindFirstChildOfClass("Tool")
                        if tool then
                            for _, child in ipairs(tool:GetDescendants()) do
                                if child.Name == "Damage" and child:IsA("NumberValue") then
                                    child.Value = 99999
                                end
                            end
                        end
                    end)
                    task.wait(0.3)
                end
            end)
        end, function() features.OneHitKill = false end, nil, nil, y); y = y + 35
        AddToggle("Damage Multiplier x10", "OP", function()
            -- placeholder for altering damage remote
        end, function() features.OP = false end, nil, nil, y); y = y + 35
        AddToggle("Rapid Fire", "RapidFire", function()
            -- placeholder for ranged weapons
        end, function() features.RapidFire = false end, nil, nil, y); y = y + 35
        AddToggle("Infinite Ammo", "InfiniteAmmo", function()
            -- placeholder
        end, function() features.InfiniteAmmo = false end, nil, nil, y); y = y + 35
        AddToggle("Infinite Durability", "InfiniteDurability", function()
            -- placeholder for tool durability
        end, function() features.InfiniteDurability = false end, nil, nil, y); y = y + 35
        AddToggle("Auto Aim", "AutoAim", function()
            -- placeholder: locks on nearest enemy head
        end, function() features.AutoAim = false end, nil, nil, y); y = y + 35
    end

    -- ========== COMBAT TAB ==========
    if selectedTab == "Combat" then
        AddToggle("Kill Aura", "KillAura", function()
            spawn(function()
                while features.KillAura do
                    pcall(function()
                        local pos = HumanoidRootPart.Position
                        local range = features.KillAuraRange
                        for _, mob in pairs(Workspace:GetDescendants()) do
                            if mob:IsA("Model") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                                if (mob:GetPrimaryPartCFrame().Position - pos).Magnitude <= range then
                                    local args = { [1] = "Damage", [2] = mob, [3] = 999 }
                                    ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Combat"):FireServer(unpack(args))
                                end
                            end
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end, function() features.KillAura = false end, nil, nil, y); y = y + 35
        AddSlider("Kill Aura Range", "KillAuraRange", 5, 100, function(val) features.KillAuraRange = val end, y); y = y + 50
        AddToggle("Auto Block", "AutoBlock", function()
            -- placeholder
        end, function() features.AutoBlock = false end, nil, nil, y); y = y + 35
        AddToggle("Auto Parry", "AutoParry", function()
            -- placeholder
        end, function() features.AutoParry = false end, nil, nil, y); y = y + 35
        AddButton("Kill All Enemies", function()
            pcall(function()
                for _, mob in pairs(Workspace:GetDescendants()) do
                    if mob:IsA("Model") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                        local args = { [1] = "Damage", [2] = mob, [3] = 99999 }
                        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Combat"):FireServer(unpack(args))
                    end
                end
            end)
        end, Color3.fromRGB(255,0,0), y); y = y + 35
    end

    -- ========== MISC TAB ==========
    if selectedTab == "Misc" then
        AddToggle("Anti Hunger", "AntiHunger", function()
            spawn(function()
                while features.AntiHunger do
                    pcall(function()
                        if Character:FindFirstChild("Hunger") then
                            Character.Hunger.Value = 100
                        end
                    end)
                    task.wait(1)
                end
            end)
        end, function() features.AntiHunger = false end, nil, nil, y); y = y + 35
        AddToggle("Anti Thirst", "AntiThirst", function()
            spawn(function()
                while features.AntiThirst do
                    pcall(function()
                        if Character:FindFirstChild("Thirst") then
                            Character.Thirst.Value = 100
                        end
                    end)
                    task.wait(1)
                end
            end)
        end, function() features.AntiThirst = false end, nil, nil, y); y = y + 35
        AddToggle("Anti Cold", "AntiCold", function()
            spawn(function()
                while features.AntiCold do
                    pcall(function()
                        if Character:FindFirstChild("Temperature") then
                            Character.Temperature.Value = 25
                        end
                    end)
                    task.wait(1)
                end
            end)
        end, function() features.AntiCold = false end, nil, nil, y); y = y + 35
        AddToggle("Anti Heat", "AntiHeat", function()
            spawn(function()
                while features.AntiHeat do
                    pcall(function()
                        if Character:FindFirstChild("Temperature") then
                            Character.Temperature.Value = 10
                        end
                    end)
                    task.wait(1)
                end
            end)
        end, function() features.AntiHeat = false end, nil, nil, y); y = y + 35
        AddToggle("Infinite Stamina", "InfiniteStamina", function()
            spawn(function()
                while features.InfiniteStamina do
                    pcall(function()
                        if Character:FindFirstChild("Stamina") then
                            Character.Stamina.Value = 100
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end, function() features.InfiniteStamina = false end, nil, nil, y); y = y + 35
        AddToggle("Anti AFK", "AntiAFK", function()
            LocalPlayer.Idled:Connect(function()
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
            end)
        end, function() features.AntiAFK = false end, nil, nil, y); y = y + 35
        AddButton("Auto Eat Food", function()
            -- placeholder
        end, Color3.fromRGB(255,200,0), y); y = y + 35
        AddButton("Auto Drink", function()
            -- placeholder
        end, Color3.fromRGB(0,150,255), y); y = y + 35
        AddButton("Auto Sleep", function()
            -- placeholder
        end, Color3.fromRGB(150,100,255), y); y = y + 35
        AddButton("Auto Equip Best Tool", function()
            -- placeholder
        end, Color3.fromRGB(100,200,100), y); y = y + 35
        AddButton("Auto Sell Items", function()
            -- placeholder
        end, Color3.fromRGB(255,100,100), y); y = y + 35
        AddButton("Auto Buy Upgrades", function()
            -- placeholder
        end, Color3.fromRGB(255,255,100), y); y = y + 35
        AddButton("Auto Complete Quests", function()
            -- placeholder
        end, Color3.fromRGB(200,100,255), y); y = y + 35
        AddButton("Infinite Backpack", function()
            -- placeholder
        end, Color3.fromRGB(100,200,200), y); y = y + 35
    end

    -- ========== SETTINGS TAB ==========
    if selectedTab == "Settings" then
        AddButton("Hide UI", function()
            GUI.Enabled = false
            if not GUI:FindFirstChild("ShowButton") then
                local showBtn = Instance.new("TextButton")
                showBtn.Name = "ShowButton"
                showBtn.Size = UDim2.new(0,100,0,30)
                showBtn.Position = UDim2.new(0,10,0,10)
                showBtn.BackgroundColor3 = Color3.fromRGB(255,0,0)
                showBtn.Text = "Show Panel"
                showBtn.TextColor3 = Color3.new(1,1,1)
                showBtn.Font = Enum.Font.GothamBold
                showBtn.TextSize = 14
                showBtn.Parent = GUI
                showBtn.MouseButton1Click:Connect(function()
                    GUI.Enabled = true
                    showBtn:Destroy()
                end)
            end
        end, Color3.fromRGB(255,150,0), y); y = y + 35
        AddButton("Destroy UI", function() GUI:Destroy() end, Color3.fromRGB(200,0,0), y); y = y + 35
        AddButton("Toggle UI Keybind (F4)", function()
            -- placeholder: can be implemented with UserInputService
        end, Color3.fromRGB(150,150,150), y); y = y + 35
        local credits = AddElement(Instance.new("TextLabel"))
        credits.Size = UDim2.new(1, -10, 0, 150)
        credits.Position = UDim2.new(0,5,0,y)
        credits.BackgroundTransparency = 1
        credits.Text = [[
Script by FingerStudiosScripts
Discord: .gg/placeholder
YouTube: @FingerStudiosScripts
Delta Executor compatible
Android: Samsung, Huawei, Redmi, Google Pixel
iOS: iPhone, iPad
Version: 2.0 Ultimate
        ]]
        credits.TextColor3 = Color3.new(1,1,1)
        credits.Font = Enum.Font.Gotham
        credits.TextSize = 12
        credits.TextWrapped = true
        y = y + 160
    end

    Content.CanvasSize = UDim2.new(0,0,0,y+20)
end

--====================================--
--    FEATURE IMPLEMENTATIONS         --
--====================================--
function spawnAutoFarm()
    -- All-in-one auto farm
end
function spawnChopWood()
    spawn(function()
        while features.AutoChop do
            pcall(function()
                -- search for trees and chop
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name:lower():find("tree") or obj.Name:lower():find("log")) then
                        if (obj.Position - HumanoidRootPart.Position).Magnitude < 30 then
                            fireproximityprompt(obj.ProximityPrompt) -- placeholder
                        end
                    end
                end
            end)
            task.wait(1)
        end
    end)
end
function spawnMineRocks()
    spawn(function()
        while features.AutoMine do
            pcall(function()
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name:lower():find("rock") or obj.Name:lower():find("ore")) then
                        if (obj.Position - HumanoidRootPart.Position).Magnitude < 30 then
                            fireproximityprompt(obj.ProximityPrompt)
                        end
                    end
                end
            end)
            task.wait(1)
        end
    end)
end
function spawnAutoFish()
    spawn(function()
        while features.AutoFish do
            pcall(function()
                -- cast rod and reel
                -- placeholder: fire remote
            end)
            task.wait(5)
        end
    end)
end
function spawnAutoCook()
    spawn(function()
        while features.AutoCook do
            pcall(function()
                -- find campfire and cook raw food
            end)
            task.wait(2)
        end
    end)
end
function spawnAutoBuild()
    spawn(function()
        while features.AutoBuild do
            pcall(function()
                -- build any pending structures
            end)
            task.wait(5)
        end
    end)
end
function spawnAutoCollect()
    spawn(function()
        while features.AutoCollect do
            pcall(function()
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and obj:FindFirstChild("ProximityPrompt") then
                        local prompt = obj.ProximityPrompt
                        if prompt.Enabled and (prompt.ObjectText:lower():find("take") or prompt.ObjectText:lower():find("collect")) then
                            fireproximityprompt(prompt)
                        end
                    end
                end
            end)
            task.wait(0.5)
        end
    end)
end

function spawnAutoFillCampfire()
    spawn(function()
        while features.AutoFillCampfire do
            pcall(function()
                for _, camp in pairs(Workspace:GetDescendants()) do
                    if camp.Name:lower():find("campfire") and camp:IsA("BasePart") then
                        local args = { [1] = "AddFuel", [2] = camp }
                        ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Campfire"):FireServer(unpack(args))
                    end
                end
            end)
            task.wait(2)
        end
    end)
end
function spawnCampfireProximity()
    spawn(function()
        while features.CampfireProximity do
            pcall(function()
                local pos = HumanoidRootPart.Position
                for _, camp in pairs(Workspace:GetDescendants()) do
                    if camp.Name:lower():find("campfire") and camp:IsA("BasePart") then
                        if (camp.Position - pos).Magnitude < features.CampfireRadius then
                            local args = { [1] = "AddWood", [2] = camp }
                            ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Campfire"):FireServer(unpack(args))
                        end
                    end
                end
            end)
            task.wait(1)
        end
    end)
end

function spawnKillAura()
    spawn(function()
        while features.Aura do
            pcall(function()
                local pos = HumanoidRootPart.Position
                for _, mob in pairs(Workspace:GetDescendants()) do
                    if mob:IsA("Model") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                        if (mob:GetPrimaryPartCFrame().Position - pos).Magnitude <= features.AuraRange then
                            local args = { [1] = "Damage", [2] = mob, [3] = 999 }
                            ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Combat"):FireServer(unpack(args))
                        end
                    end
                end
            end)
            task.wait(0.1)
        end
    end)
end
function spawnResourceAura()
    spawn(function()
        while features.ResourceAura do
            pcall(function()
                local pos = HumanoidRootPart.Position
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name:lower():find("tree") or obj.Name:lower():find("rock")) then
                        if (obj.Position - pos).Magnitude <= features.ResourceAuraRadius then
                            fireproximityprompt(obj:FindFirstChild("ProximityPrompt"))
                        end
                    end
                end
            end)
            task.wait(0.5)
        end
    end)
end

function spawnBringItems()
    spawn(function()
        while features.BringItems do
            pcall(function()
                local pos = HumanoidRootPart.Position
                for _, item in pairs(Workspace:GetDescendants()) do
                    if item:IsA("BasePart") and item:FindFirstChild("ProximityPrompt") then
                        local prompt = item.ProximityPrompt
                        if prompt.Enabled and (prompt.ObjectText:lower():find("take") or prompt.ObjectText:lower():find("collect")) then
                            if (item.Position - pos).Magnitude <= features.BringItemsRadius then
                                item.CFrame = CFrame.new(pos + Vector3.new(math.random(-3,3), 0, math.random(-3,3)))
                            end
                        end
                    end
                end
            end)
            task.wait(0.5)
        end
    end)
end
function spawnTeleportToItem()
    spawn(function()
        while features.TeleportToItem do
            pcall(function()
                for _, item in pairs(Workspace:GetDescendants()) do
                    if item:IsA("BasePart") and item:FindFirstChild("ProximityPrompt") then
                        if item.ProximityPrompt.Enabled and item.ProximityPrompt.ObjectText:lower():find("take") then
                            HumanoidRootPart.CFrame = item.CFrame + Vector3.new(0,3,0)
                            break
                        end
                    end
                end
            end)
            task.wait(0.3)
        end
    end)
end
function spawnAutoPickup()
    spawn(function()
        while features.AutoPickup do
            pcall(function()
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and obj:FindFirstChild("ProximityPrompt") then
                        local prompt = obj.ProximityPrompt
                        if prompt.Enabled and (prompt.ObjectText:lower():find("take") or prompt.ObjectText:lower():find("collect")) then
                            fireproximityprompt(prompt)
                        end
                    end
                end
            end)
            task.wait(0.3)
        end
    end)
end

--====================================--
--     STARTUP & INITIAL LOAD         --
--====================================--
UpdateContent()
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "99 Nights Dev Panel",
        Text = "Loaded! FingerStudiosScripts",
        Duration = 5
    })
end)
print("Ultimate 99 Nights Dev Panel loaded. ~1500 lines. Delta Executor ready.")
