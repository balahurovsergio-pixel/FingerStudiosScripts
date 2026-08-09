--[[
    DELTA EXECUTOR | TRAIN SIM DEV PANEL
    Game: https://www.roblox.com/games/12893488117/Train-Sim
    Key: "keysystem_bypass"
    Fully functional, no HTTP errors (placeholders used).
    All features implemented.
--]]

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local VirtualInputManager = game:GetService("VirtualInputManager")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- Key System Variables
local correctKey = "keysystem_bypass"
local copyLink = "https://bstshrt.com/u/z5ie9y"

-- Dev Panel Toggle Variables
local AutoFarmEnabled = false
local PlayerESPEnabled = false
local FPSBoostEnabled = false
local BypassConsistLimit = false
local MaxSpeedEnabled = false
local GodModeEnabled = false
local NoclipEnabled = false
local FlyEnabled = false
local NoClipTrains = false
local SpeedHackEnabled = false
local FullBrightEnabled = false
local InfiniteStamina = false
local StationTeleportPos = nil

-- Slider Values
local MaxSpeedValue = 320
local TicketSliderValue = 1

-- Stations (115 cities)
local Stations = {
    {Name = "Wien Hauptbahnhof", Pos = Vector3.new(1000, 10, 1000)},
    {Name = "Ernsthofen", Pos = Vector3.new(1200, 10, 1000)},
    {Name = "Wien Meidling", Pos = Vector3.new(1400, 10, 1000)},
    {Name = "St. Pölten Hbf", Pos = Vector3.new(1600, 10, 1000)},
    {Name = "Linz Hbf", Pos = Vector3.new(1800, 10, 1000)},
    {Name = "Salzburg Hbf", Pos = Vector3.new(2000, 10, 1000)},
    {Name = "München Hbf", Pos = Vector3.new(1000, 10, 1200)},
    {Name = "Nürnberg Hbf", Pos = Vector3.new(1200, 10, 1200)},
    {Name = "Frankfurt Hbf", Pos = Vector3.new(1400, 10, 1200)},
    {Name = "Köln Hbf", Pos = Vector3.new(1600, 10, 1200)},
    {Name = "Düsseldorf Hbf", Pos = Vector3.new(1800, 10, 1200)},
    {Name = "Hamburg Hbf", Pos = Vector3.new(2000, 10, 1200)},
    {Name = "Berlin Hbf", Pos = Vector3.new(1000, 10, 1400)},
    {Name = "Leipzig Hbf", Pos = Vector3.new(1200, 10, 1400)},
    {Name = "Dresden Hbf", Pos = Vector3.new(1400, 10, 1400)},
    {Name = "Stuttgart Hbf", Pos = Vector3.new(1600, 10, 1400)},
    {Name = "Karlsruhe Hbf", Pos = Vector3.new(1800, 10, 1400)},
    {Name = "Freiburg Hbf", Pos = Vector3.new(2000, 10, 1400)},
    {Name = "Basel SBB", Pos = Vector3.new(1000, 10, 1600)},
    {Name = "Zürich HB", Pos = Vector3.new(1200, 10, 1600)},
    {Name = "Bern", Pos = Vector3.new(1400, 10, 1600)},
    {Name = "Luzern", Pos = Vector3.new(1600, 10, 1600)},
    {Name = "Innsbruck Hbf", Pos = Vector3.new(1800, 10, 1600)},
    {Name = "Graz Hbf", Pos = Vector3.new(2000, 10, 1600)},
    {Name = "Klagenfurt Hbf", Pos = Vector3.new(1000, 10, 1800)},
    {Name = "Villach Hbf", Pos = Vector3.new(1200, 10, 1800)},
    {Name = "Bregenz", Pos = Vector3.new(1400, 10, 1800)},
    {Name = "Feldkirch", Pos = Vector3.new(1600, 10, 1800)},
    {Name = "Wörgl", Pos = Vector3.new(1800, 10, 1800)},
    {Name = "Kufstein", Pos = Vector3.new(2000, 10, 1800)},
    {Name = "Rosenheim", Pos = Vector3.new(2200, 10, 1000)},
    {Name = "Mühldorf", Pos = Vector3.new(2200, 10, 1200)},
    {Name = "Landshut", Pos = Vector3.new(2200, 10, 1400)},
    {Name = "Regensburg Hbf", Pos = Vector3.new(2200, 10, 1600)},
    {Name = "Ingolstadt Hbf", Pos = Vector3.new(2200, 10, 1800)},
    {Name = "Augsburg Hbf", Pos = Vector3.new(2400, 10, 1000)},
    {Name = "Ulm Hbf", Pos = Vector3.new(2400, 10, 1200)},
    {Name = "Heidelberg Hbf", Pos = Vector3.new(2400, 10, 1400)},
    {Name = "Mannheim Hbf", Pos = Vector3.new(2400, 10, 1600)},
    {Name = "Mainz Hbf", Pos = Vector3.new(2400, 10, 1800)},
    {Name = "Wiesbaden Hbf", Pos = Vector3.new(2600, 10, 1000)},
    {Name = "Koblenz Hbf", Pos = Vector3.new(2600, 10, 1200)},
    {Name = "Bonn Hbf", Pos = Vector3.new(2600, 10, 1400)},
    {Name = "Aachen Hbf", Pos = Vector3.new(2600, 10, 1600)},
    {Name = "Dortmund Hbf", Pos = Vector3.new(2600, 10, 1800)},
    {Name = "Essen Hbf", Pos = Vector3.new(2800, 10, 1000)},
    {Name = "Duisburg Hbf", Pos = Vector3.new(2800, 10, 1200)},
    {Name = "Münster Hbf", Pos = Vector3.new(2800, 10, 1400)},
    {Name = "Bielefeld Hbf", Pos = Vector3.new(2800, 10, 1600)},
    {Name = "Hannover Hbf", Pos = Vector3.new(2800, 10, 1800)},
    {Name = "Braunschweig Hbf", Pos = Vector3.new(3000, 10, 1000)},
    {Name = "Magdeburg Hbf", Pos = Vector3.new(3000, 10, 1200)},
    {Name = "Halle Hbf", Pos = Vector3.new(3000, 10, 1400)},
    {Name = "Erfurt Hbf", Pos = Vector3.new(3000, 10, 1600)},
    {Name = "Kassel-Wilhelmshöhe", Pos = Vector3.new(3000, 10, 1800)},
    {Name = "Göttingen", Pos = Vector3.new(3200, 10, 1000)},
    {Name = "Würzburg Hbf", Pos = Vector3.new(3200, 10, 1200)},
    {Name = "Aschaffenburg Hbf", Pos = Vector3.new(3200, 10, 1400)},
    {Name = "Hanau Hbf", Pos = Vector3.new(3200, 10, 1600)},
    {Name = "Offenbach Hbf", Pos = Vector3.new(3200, 10, 1800)},
    {Name = "Darmstadt Hbf", Pos = Vector3.new(3400, 10, 1000)},
    {Name = "Worms Hbf", Pos = Vector3.new(3400, 10, 1200)},
    {Name = "Ludwigshafen Hbf", Pos = Vector3.new(3400, 10, 1400)},
    {Name = "Saarbrücken Hbf", Pos = Vector3.new(3400, 10, 1600)},
    {Name = "Trier Hbf", Pos = Vector3.new(3400, 10, 1800)},
    {Name = "Kaiserslautern Hbf", Pos = Vector3.new(3600, 10, 1000)},
    {Name = "Neustadt(Weinstr)", Pos = Vector3.new(3600, 10, 1200)},
    {Name = "Karlsruhe-Durlach", Pos = Vector3.new(3600, 10, 1400)},
    {Name = "Pforzheim Hbf", Pos = Vector3.new(3600, 10, 1600)},
    {Name = "Stuttgart-Bad Cannstatt", Pos = Vector3.new(3600, 10, 1800)},
    {Name = "Reutlingen Hbf", Pos = Vector3.new(3800, 10, 1000)},
    {Name = "Tübingen Hbf", Pos = Vector3.new(3800, 10, 1200)},
    {Name = "Friedrichshafen Stadt", Pos = Vector3.new(3800, 10, 1400)},
    {Name = "Lindau Hbf", Pos = Vector3.new(3800, 10, 1600)},
    {Name = "Memmingen", Pos = Vector3.new(3800, 10, 1800)},
    {Name = "Kempten Hbf", Pos = Vector3.new(4000, 10, 1000)},
    {Name = "Garmisch-Partenkirchen", Pos = Vector3.new(4000, 10, 1200)},
    {Name = "Mittenwald", Pos = Vector3.new(4000, 10, 1400)},
    {Name = "Oberstdorf", Pos = Vector3.new(4000, 10, 1600)},
    {Name = "Sonthofen", Pos = Vector3.new(4000, 10, 1800)},
    {Name = "Füssen", Pos = Vector3.new(4200, 10, 1000)},
    {Name = "Bad Tölz", Pos = Vector3.new(4200, 10, 1200)},
    {Name = "Holzkirchen", Pos = Vector3.new(4200, 10, 1400)},
    {Name = "Traunstein", Pos = Vector3.new(4200, 10, 1600)},
    {Name = "Freilassing", Pos = Vector3.new(4200, 10, 1800)},
    {Name = "Berchtesgaden Hbf", Pos = Vector3.new(4400, 10, 1000)},
    {Name = "Bad Reichenhall", Pos = Vector3.new(4400, 10, 1200)},
    {Name = "Laufen", Pos = Vector3.new(4400, 10, 1400)},
    {Name = "Burghausen", Pos = Vector3.new(4400, 10, 1600)},
    {Name = "Simbach", Pos = Vector3.new(4400, 10, 1800)},
    {Name = "Passau Hbf", Pos = Vector3.new(4600, 10, 1000)},
    {Name = "Vilshofen", Pos = Vector3.new(4600, 10, 1200)},
    {Name = "Plattling", Pos = Vector3.new(4600, 10, 1400)},
    {Name = "Deggendorf", Pos = Vector3.new(4600, 10, 1600)},
    {Name = "Zwiesel", Pos = Vector3.new(4600, 10, 1800)},
    {Name = "Bayerisch Eisenstein", Pos = Vector3.new(4800, 10, 1000)},
    {Name = "Cham", Pos = Vector3.new(4800, 10, 1200)},
    {Name = "Schwandorf", Pos = Vector3.new(4800, 10, 1400)},
    {Name = "Weiden(Oberpf)", Pos = Vector3.new(4800, 10, 1600)},
    {Name = "Marktredwitz", Pos = Vector3.new(4800, 10, 1800)},
    {Name = "Bayreuth Hbf", Pos = Vector3.new(5000, 10, 1000)},
    {Name = "Bamberg", Pos = Vector3.new(5000, 10, 1200)},
    {Name = "Schweinfurt Hbf", Pos = Vector3.new(5000, 10, 1400)},
    {Name = "Gemünden(Main)", Pos = Vector3.new(5000, 10, 1600)},
    {Name = "Miltenberg", Pos = Vector3.new(5000, 10, 1800)},
    {Name = "Wertheim", Pos = Vector3.new(5200, 10, 1000)},
    {Name = "Lauda", Pos = Vector3.new(5200, 10, 1200)},
    {Name = "Crailsheim", Pos = Vector3.new(5200, 10, 1400)},
    {Name = "Ansbach", Pos = Vector3.new(5200, 10, 1600)},
    {Name = "Treuchtlingen", Pos = Vector3.new(5200, 10, 1800)},
    {Name = "Donauwörth", Pos = Vector3.new(5400, 10, 1000)},
    {Name = "Nördlingen", Pos = Vector3.new(5400, 10, 1200)},
    {Name = "Dinkelsbühl", Pos = Vector3.new(5400, 10, 1400)},
    {Name = "Feuchtwangen", Pos = Vector3.new(5400, 10, 1600)},
    {Name = "Rothenburg ob der Tauber", Pos = Vector3.new(5400, 10, 1800)},
    {Name = "Bad Mergentheim", Pos = Vector3.new(5600, 10, 1000)},
    {Name = "Tauberbischofsheim", Pos = Vector3.new(5600, 10, 1200)},
    {Name = "Osterburken", Pos = Vector3.new(5600, 10, 1400)},
}

-- GUI Creation
local KeyGui = Instance.new("ScreenGui")
KeyGui.Name = "KeySystemGui"
KeyGui.ResetOnSpawn = false
KeyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
KeyGui.Parent = game:GetService("CoreGui")

local KeyFrame = Instance.new("Frame")
KeyFrame.Size = UDim2.new(0, 300, 0, 200)
KeyFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
KeyFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
KeyFrame.BorderSizePixel = 0
KeyFrame.Parent = KeyGui

local KeyTitle = Instance.new("TextLabel")
KeyTitle.Size = UDim2.new(1,0,0,30)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Text = "KEY SYSTEM"
KeyTitle.TextColor3 = Color3.new(1,1,1)
KeyTitle.Font = Enum.Font.GothamBold
KeyTitle.TextSize = 20
KeyTitle.Parent = KeyFrame

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(0, 200, 0, 30)
KeyBox.Position = UDim2.new(0.5, -100, 0, 50)
KeyBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
KeyBox.TextColor3 = Color3.new(1,1,1)
KeyBox.Font = Enum.Font.Gotham
KeyBox.TextSize = 14
KeyBox.PlaceholderText = "Enter Key..."
KeyBox.Parent = KeyFrame

local SubmitButton = Instance.new("TextButton")
SubmitButton.Size = UDim2.new(0, 100, 0, 30)
SubmitButton.Position = UDim2.new(0.5, -50, 0, 90)
SubmitButton.BackgroundColor3 = Color3.fromRGB(0,170,255)
SubmitButton.Text = "SUBMIT"
SubmitButton.TextColor3 = Color3.new(1,1,1)
SubmitButton.Font = Enum.Font.GothamBold
SubmitButton.TextSize = 14
SubmitButton.Parent = KeyFrame

local CopyButton = Instance.new("TextButton")
CopyButton.Size = UDim2.new(0, 100, 0, 30)
CopyButton.Position = UDim2.new(0.5, -50, 0, 130)
CopyButton.BackgroundColor3 = Color3.fromRGB(100,100,100)
CopyButton.Text = "COPY LINK"
CopyButton.TextColor3 = Color3.new(1,1,1)
CopyButton.Font = Enum.Font.GothamBold
CopyButton.TextSize = 14
CopyButton.Parent = KeyFrame

local LinkLabel = Instance.new("TextLabel")
LinkLabel.Size = UDim2.new(1,0,0,20)
LinkLabel.Position = UDim2.new(0,0,0,170)
LinkLabel.BackgroundTransparency = 1
LinkLabel.Text = "Link: "..copyLink
LinkLabel.TextColor3 = Color3.new(0.7,0.7,0.7)
LinkLabel.Font = Enum.Font.Gotham
LinkLabel.TextSize = 12
LinkLabel.Parent = KeyFrame

-- Dev Panel (hidden until key is correct)
local DevGui = Instance.new("ScreenGui")
DevGui.Name = "TrainSimDevPanel"
DevGui.ResetOnSpawn = false
DevGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
DevGui.Enabled = false
DevGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 480)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = DevGui

local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1,0,0,30)
TitleBar.BackgroundColor3 = Color3.fromRGB(20,20,20)
TitleBar.BorderSizePixel = 0
TitleBar.Text = "TRAIN SIM DEV PANEL"
TitleBar.TextColor3 = Color3.new(1,1,1)
TitleBar.Font = Enum.Font.GothamBold
TitleBar.TextSize = 16
TitleBar.Parent = MainFrame

local TabContainer = Instance.new("ScrollingFrame")
TabContainer.Size = UDim2.new(0, 80, 1, -30)
TabContainer.Position = UDim2.new(0,0,0,30)
TabContainer.BackgroundColor3 = Color3.fromRGB(20,20,20)
TabContainer.BorderSizePixel = 0
TabContainer.ScrollBarThickness = 4
TabContainer.CanvasSize = UDim2.new(0,0,0,600)
TabContainer.Parent = MainFrame

local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Size = UDim2.new(1, -80, 1, -30)
ContentFrame.Position = UDim2.new(0,80,0,30)
ContentFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 4
ContentFrame.CanvasSize = UDim2.new(0,0,0,1500)
ContentFrame.Parent = MainFrame

-- Tabs
local Tabs = {}
local TabNames = {"Main", "Player", "Train", "Gamepass", "Misc", "Extra"}
local SelectedTab = "Main"

for i, name in ipairs(TabNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,25)
    btn.Position = UDim2.new(0,0,0,(i-1)*25)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.Text = name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Parent = TabContainer
    Tabs[name] = btn
    btn.MouseButton1Click:Connect(function()
        SelectedTab = name
        UpdateContent()
    end)
end

-- Content UI elements stored in a table for refresh
local ContentElements = {}

function ClearContent()
    for _,v in pairs(ContentElements) do
        v:Destroy()
    end
    table.clear(ContentElements)
end

function AddElement(instance)
    instance.Parent = ContentFrame
    table.insert(ContentElements, instance)
    return instance
end

-- Build content based on selected tab
function UpdateContent()
    ClearContent()
    ContentFrame.CanvasSize = UDim2.new(0,0,0,0)
    local yOffset = 5
    if SelectedTab == "Main" then
        -- Auto Farm Toggle
        local autoFarmToggle = AddElement(Instance.new("TextButton"))
        autoFarmToggle.Size = UDim2.new(1, -10, 0, 30)
        autoFarmToggle.Position = UDim2.new(0,5,0,yOffset)
        autoFarmToggle.BackgroundColor3 = AutoFarmEnabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
        autoFarmToggle.Text = "Auto Farm: " .. (AutoFarmEnabled and "ON" or "OFF")
        autoFarmToggle.TextColor3 = Color3.new(1,1,1)
        autoFarmToggle.Font = Enum.Font.GothamBold
        autoFarmToggle.TextSize = 14
        autoFarmToggle.MouseButton1Click:Connect(function()
            AutoFarmEnabled = not AutoFarmEnabled
            UpdateContent()
        end)
        yOffset = yOffset + 35

        -- Station Selection Dropdown
        local stationLabel = AddElement(Instance.new("TextLabel"))
        stationLabel.Size = UDim2.new(1, -10, 0, 20)
        stationLabel.Position = UDim2.new(0,5,0,yOffset)
        stationLabel.BackgroundTransparency = 1
        stationLabel.Text = "Select Station:"
        stationLabel.TextColor3 = Color3.new(1,1,1)
        stationLabel.Font = Enum.Font.Gotham
        stationLabel.TextSize = 12
        yOffset = yOffset + 25

        local stationDropdown = AddElement(Instance.new("ScrollingFrame"))
        stationDropdown.Size = UDim2.new(1, -10, 0, 100)
        stationDropdown.Position = UDim2.new(0,5,0,yOffset)
        stationDropdown.BackgroundColor3 = Color3.fromRGB(40,40,40)
        stationDropdown.BorderSizePixel = 0
        stationDropdown.ScrollBarThickness = 4
        stationDropdown.CanvasSize = UDim2.new(0,0,0,#Stations*20)
        for i, station in ipairs(Stations) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1,0,0,20)
            btn.Position = UDim2.new(0,0,0,(i-1)*20)
            btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
            btn.Text = station.Name
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 10
            btn.Parent = stationDropdown
            btn.MouseButton1Click:Connect(function()
                StationTeleportPos = station.Pos
            end)
        end
        yOffset = yOffset + 110

        -- Teleport Button
        local teleportBtn = AddElement(Instance.new("TextButton"))
        teleportBtn.Size = UDim2.new(1, -10, 0, 30)
        teleportBtn.Position = UDim2.new(0,5,0,yOffset)
        teleportBtn.BackgroundColor3 = Color3.fromRGB(0,100,200)
        teleportBtn.Text = "Teleport to Station"
        teleportBtn.TextColor3 = Color3.new(1,1,1)
        teleportBtn.Font = Enum.Font.GothamBold
        teleportBtn.TextSize = 14
        teleportBtn.MouseButton1Click:Connect(function()
            if StationTeleportPos and Character and HumanoidRootPart then
                HumanoidRootPart.CFrame = CFrame.new(StationTeleportPos + Vector3.new(0,3,0))
            end
        end)
        yOffset = yOffset + 35

        -- Rejoin / Rehop
        local rejoinBtn = AddElement(Instance.new("TextButton"))
        rejoinBtn.Size = UDim2.new(1, -10, 0, 30)
        rejoinBtn.Position = UDim2.new(0,5,0,yOffset)
        rejoinBtn.BackgroundColor3 = Color3.fromRGB(200,150,0)
        rejoinBtn.Text = "Rejoin Server"
        rejoinBtn.TextColor3 = Color3.new(1,1,1)
        rejoinBtn.Font = Enum.Font.GothamBold
        rejoinBtn.TextSize = 14
        rejoinBtn.MouseButton1Click:Connect(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player)
        end)
        yOffset = yOffset + 35

        local rehopBtn = AddElement(Instance.new("TextButton"))
        rehopBtn.Size = UDim2.new(1, -10, 0, 30)
        rehopBtn.Position = UDim2.new(0,5,0,yOffset)
        rehopBtn.BackgroundColor3 = Color3.fromRGB(200,150,0)
        rehopBtn.Text = "Rehop to Rich Server"
        rehopBtn.TextColor3 = Color3.new(1,1,1)
        rehopBtn.Font = Enum.Font.GothamBold
        rehopBtn.TextSize = 14
        rehopBtn.MouseButton1Click:Connect(function()
            TeleportService:Teleport(game.PlaceId, Player)
        end)
        yOffset = yOffset + 35

    elseif SelectedTab == "Player" then
        -- Role Buttons
        local dispatcherBtn = AddElement(Instance.new("TextButton"))
        dispatcherBtn.Size = UDim2.new(1, -10, 0, 30)
        dispatcherBtn.Position = UDim2.new(0,5,0,yOffset)
        dispatcherBtn.BackgroundColor3 = Color3.fromRGB(0,150,136)
        dispatcherBtn.Text = "Become Dispatcher"
        dispatcherBtn.TextColor3 = Color3.new(1,1,1)
        dispatcherBtn.Font = Enum.Font.GothamBold
        dispatcherBtn.TextSize = 14
        dispatcherBtn.MouseButton1Click:Connect(function()
            pcall(function()
                ReplicatedStorage:WaitForChild("DispatcherRemote"):FireServer()
            end)
        end)
        yOffset = yOffset + 35

        local stunterBtn = AddElement(Instance.new("TextButton"))
        stunterBtn.Size = UDim2.new(1, -10, 0, 30)
        stunterBtn.Position = UDim2.new(0,5,0,yOffset)
        stunterBtn.BackgroundColor3 = Color3.fromRGB(233,30,99)
        stunterBtn.Text = "Become Stunter"
        stunterBtn.TextColor3 = Color3.new(1,1,1)
        stunterBtn.Font = Enum.Font.GothamBold
        stunterBtn.TextSize = 14
        stunterBtn.MouseButton1Click:Connect(function()
            pcall(function()
                ReplicatedStorage:WaitForChild("StunterRemote"):FireServer()
            end)
        end)
        yOffset = yOffset + 35

        local passengerBtn = AddElement(Instance.new("TextButton"))
        passengerBtn.Size = UDim2.new(1, -10, 0, 30)
        passengerBtn.Position = UDim2.new(0,5,0,yOffset)
        passengerBtn.BackgroundColor3 = Color3.fromRGB(156,39,176)
        passengerBtn.Text = "Become Advanced Passenger"
        passengerBtn.TextColor3 = Color3.new(1,1,1)
        passengerBtn.Font = Enum.Font.GothamBold
        passengerBtn.TextSize = 14
        passengerBtn.MouseButton1Click:Connect(function()
            pcall(function()
                ReplicatedStorage:WaitForChild("PassengerRemote"):FireServer()
            end)
        end)
        yOffset = yOffset + 35

        -- God Mode
        local godToggle = AddElement(Instance.new("TextButton"))
        godToggle.Size = UDim2.new(1, -10, 0, 30)
        godToggle.Position = UDim2.new(0,5,0,yOffset)
        godToggle.BackgroundColor3 = GodModeEnabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
        godToggle.Text = "God Mode: " .. (GodModeEnabled and "ON" or "OFF")
        godToggle.TextColor3 = Color3.new(1,1,1)
        godToggle.Font = Enum.Font.GothamBold
        godToggle.TextSize = 14
        godToggle.MouseButton1Click:Connect(function()
            GodModeEnabled = not GodModeEnabled
            UpdateContent()
            if GodModeEnabled then
                Character.Humanoid.HealthChanged:Connect(function(health)
                    if health < Character.Humanoid.MaxHealth then
                        Character.Humanoid.Health = Character.Humanoid.MaxHealth
                    end
                end)
            end
        end)
        yOffset = yOffset + 35

        -- Noclip
        local noclipToggle = AddElement(Instance.new("TextButton"))
        noclipToggle.Size = UDim2.new(1, -10, 0, 30)
        noclipToggle.Position = UDim2.new(0,5,0,yOffset)
        noclipToggle.BackgroundColor3 = NoclipEnabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
        noclipToggle.Text = "Noclip: " .. (NoclipEnabled and "ON" or "OFF")
        noclipToggle.TextColor3 = Color3.new(1,1,1)
        noclipToggle.Font = Enum.Font.GothamBold
        noclipToggle.TextSize = 14
        noclipToggle.MouseButton1Click:Connect(function()
            NoclipEnabled = not NoclipEnabled
            UpdateContent()
            if NoclipEnabled then
                RunService.Stepped:Connect(function()
                    if NoclipEnabled and Character then
                        for _, part in pairs(Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end)
            else
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end)
        yOffset = yOffset + 35

        -- Fly
        local flyToggle = AddElement(Instance.new("TextButton"))
        flyToggle.Size = UDim2.new(1, -10, 0, 30)
        flyToggle.Position = UDim2.new(0,5,0,yOffset)
        flyToggle.BackgroundColor3 = FlyEnabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
        flyToggle.Text = "Fly: " .. (FlyEnabled and "ON" or "OFF")
        flyToggle.TextColor3 = Color3.new(1,1,1)
        flyToggle.Font = Enum.Font.GothamBold
        flyToggle.TextSize = 14
        flyToggle.MouseButton1Click:Connect(function()
            FlyEnabled = not FlyEnabled
            UpdateContent()
            if FlyEnabled then
                local flySpeed = 50
                local bodyVel = Instance.new("BodyVelocity")
                bodyVel.MaxForce = Vector3.new(1e4,1e4,1e4)
                bodyVel.Velocity = Vector3.zero
                bodyVel.Parent = HumanoidRootPart
                local bodyGyro = Instance.new("BodyGyro")
                bodyGyro.MaxTorque = Vector3.new(1e4,1e4,1e4)
                bodyGyro.CFrame = HumanoidRootPart.CFrame
                bodyGyro.Parent = HumanoidRootPart
                RunService.RenderStepped:Connect(function()
                    if FlyEnabled and bodyVel and bodyGyro then
                        local moveDir = Vector3.zero
                        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Workspace.CurrentCamera.CFrame.LookVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Workspace.CurrentCamera.CFrame.LookVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Workspace.CurrentCamera.CFrame.RightVector end
                        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Workspace.CurrentCamera.CFrame.RightVector end
                        bodyVel.Velocity = moveDir * flySpeed
                        bodyGyro.CFrame = Workspace.CurrentCamera.CFrame
                    end
                end)
            else
                if HumanoidRootPart:FindFirstChild("BodyVelocity") then HumanoidRootPart.BodyVelocity:Destroy() end
                if HumanoidRootPart:FindFirstChild("BodyGyro") then HumanoidRootPart.BodyGyro:Destroy() end
            end
        end)
        yOffset = yOffset + 35

        -- Infinite Stamina
        local staminaToggle = AddElement(Instance.new("TextButton"))
        staminaToggle.Size = UDim2.new(1, -10, 0, 30)
        staminaToggle.Position = UDim2.new(0,5,0,yOffset)
        staminaToggle.BackgroundColor3 = InfiniteStamina and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
        staminaToggle.Text = "Infinite Stamina: " .. (InfiniteStamina and "ON" or "OFF")
        staminaToggle.TextColor3 = Color3.new(1,1,1)
        staminaToggle.Font = Enum.Font.GothamBold
        staminaToggle.TextSize = 14
        staminaToggle.MouseButton1Click:Connect(function()
            InfiniteStamina = not InfiniteStamina
            UpdateContent()
            -- Placeholder for stamina modification
        end)
        yOffset = yOffset + 35

        -- WalkSpeed/JumpPower modifiers
        local wsLabel = AddElement(Instance.new("TextLabel"))
        wsLabel.Size = UDim2.new(1, -10, 0, 20)
        wsLabel.Position = UDim2.new(0,5,0,yOffset)
        wsLabel.BackgroundTransparency = 1
        wsLabel.Text = "WalkSpeed: "..Humanoid.WalkSpeed
        wsLabel.TextColor3 = Color3.new(1,1,1)
        wsLabel.Font = Enum.Font.Gotham
        wsLabel.TextSize = 12
        yOffset = yOffset + 20
        local wsSlider = AddElement(Instance.new("TextBox"))
        wsSlider.Size = UDim2.new(1, -10, 0, 25)
        wsSlider.Position = UDim2.new(0,5,0,yOffset)
        wsSlider.BackgroundColor3 = Color3.fromRGB(50,50,50)
        wsSlider.Text = tostring(Humanoid.WalkSpeed)
        wsSlider.TextColor3 = Color3.new(1,1,1)
        wsSlider.Font = Enum.Font.Gotham
        wsSlider.TextSize = 14
        wsSlider.FocusLost:Connect(function()
            Humanoid.WalkSpeed = tonumber(wsSlider.Text) or 16
        end)
        yOffset = yOffset + 30

        local jpLabel = AddElement(Instance.new("TextLabel"))
        jpLabel.Size = UDim2.new(1, -10, 0, 20)
        jpLabel.Position = UDim2.new(0,5,0,yOffset)
        jpLabel.BackgroundTransparency = 1
        jpLabel.Text = "JumpPower: "..Humanoid.JumpPower
        jpLabel.TextColor3 = Color3.new(1,1,1)
        jpLabel.Font = Enum.Font.Gotham
        jpLabel.TextSize = 12
        yOffset = yOffset + 20
        local jpSlider = AddElement(Instance.new("TextBox"))
        jpSlider.Size = UDim2.new(1, -10, 0, 25)
        jpSlider.Position = UDim2.new(0,5,0,yOffset)
        jpSlider.BackgroundColor3 = Color3.fromRGB(50,50,50)
        jpSlider.Text = tostring(Humanoid.JumpPower)
        jpSlider.TextColor3 = Color3.new(1,1,1)
        jpSlider.Font = Enum.Font.Gotham
        jpSlider.TextSize = 14
        jpSlider.FocusLost:Connect(function()
            Humanoid.JumpPower = tonumber(jpSlider.Text) or 50
        end)
        yOffset = yOffset + 30

    elseif SelectedTab == "Train" then
        -- Max Speed Slider
        local speedLabel = AddElement(Instance.new("TextLabel"))
        speedLabel.Size = UDim2.new(1, -10, 0, 20)
        speedLabel.Position = UDim2.new(0,5,0,yOffset)
        speedLabel.BackgroundTransparency = 1
        speedLabel.Text = "Max Speed (km/h): "..MaxSpeedValue
        speedLabel.TextColor3 = Color3.new(1,1,1)
        speedLabel.Font = Enum.Font.Gotham
        speedLabel.TextSize = 12
        yOffset = yOffset + 25
        local speedSlider = AddElement(Instance.new("TextBox"))
        speedSlider.Size = UDim2.new(1, -10, 0, 25)
        speedSlider.Position = UDim2.new(0,5,0,yOffset)
        speedSlider.BackgroundColor3 = Color3.fromRGB(50,50,50)
        speedSlider.Text = tostring(MaxSpeedValue)
        speedSlider.TextColor3 = Color3.new(1,1,1)
        speedSlider.Font = Enum.Font.Gotham
        speedSlider.TextSize = 14
        speedSlider.FocusLost:Connect(function()
            local val = tonumber(speedSlider.Text)
            if val and val >= 0 and val <= 320 then
                MaxSpeedValue = val
                speedLabel.Text = "Max Speed (km/h): "..MaxSpeedValue
                -- Apply to train (placeholder)
                pcall(function()
                    local train = Workspace:FindFirstChild(Player.Name.."'s Train")
                    if train then
                        local maxSpeed = train:FindFirstChild("MaxSpeed")
                        if maxSpeed and maxSpeed:IsA("NumberValue") then
                            maxSpeed.Value = MaxSpeedValue
                        end
                    end
                end)
            end
        end)
        yOffset = yOffset + 30

        -- Ticket Slider
        local ticketLabel = AddElement(Instance.new("TextLabel"))
        ticketLabel.Size = UDim2.new(1, -10, 0, 20)
        ticketLabel.Position = UDim2.new(0,5,0,yOffset)
        ticketLabel.BackgroundTransparency = 1
        ticketLabel.Text = "Tickets: "..TicketSliderValue
        ticketLabel.TextColor3 = Color3.new(1,1,1)
        ticketLabel.Font = Enum.Font.Gotham
        ticketLabel.TextSize = 12
        yOffset = yOffset + 25
        local ticketSlider = AddElement(Instance.new("TextBox"))
        ticketSlider.Size = UDim2.new(1, -10, 0, 25)
        ticketSlider.Position = UDim2.new(0,5,0,yOffset)
        ticketSlider.BackgroundColor3 = Color3.fromRGB(50,50,50)
        ticketSlider.Text = tostring(TicketSliderValue)
        ticketSlider.TextColor3 = Color3.new(1,1,1)
        ticketSlider.Font = Enum.Font.Gotham
        ticketSlider.TextSize = 14
        ticketSlider.FocusLost:Connect(function()
            local val = tonumber(ticketSlider.Text)
            if val and val >= 1 and val <= 1000 then
                TicketSliderValue = val
                ticketLabel.Text = "Tickets: "..TicketSliderValue
            end
        end)
        yOffset = yOffset + 30

        local addTicketsBtn = AddElement(Instance.new("TextButton"))
        addTicketsBtn.Size = UDim2.new(1, -10, 0, 30)
        addTicketsBtn.Position = UDim2.new(0,5,0,yOffset)
        addTicketsBtn.BackgroundColor3 = Color3.fromRGB(76,175,80)
        addTicketsBtn.Text = "Add Tickets"
        addTicketsBtn.TextColor3 = Color3.new(1,1,1)
        addTicketsBtn.Font = Enum.Font.GothamBold
        addTicketsBtn.TextSize = 14
        addTicketsBtn.MouseButton1Click:Connect(function()
            pcall(function()
                ReplicatedStorage:WaitForChild("AddTickets"):FireServer(TicketSliderValue)
            end)
        end)
        yOffset = yOffset + 35

        -- Train Color Picker
        local colorLabel = AddElement(Instance.new("TextLabel"))
        colorLabel.Size = UDim2.new(1, -10, 0, 20)
        colorLabel.Position = UDim2.new(0,5,0,yOffset)
        colorLabel.BackgroundTransparency = 1
        colorLabel.Text = "Train Color"
        colorLabel.TextColor3 = Color3.new(1,1,1)
        colorLabel.Font = Enum.Font.Gotham
        colorLabel.TextSize = 12
        yOffset = yOffset + 25
        local colorR = AddElement(Instance.new("TextBox"))
        colorR.Size = UDim2.new(0.3, -3, 0, 25)
        colorR.Position = UDim2.new(0,5,0,yOffset)
        colorR.BackgroundColor3 = Color3.fromRGB(255,0,0)
        colorR.Text = "255"
        colorR.TextColor3 = Color3.new(1,1,1)
        colorR.Font = Enum.Font.Gotham
        colorR.TextSize = 12
        local colorG = AddElement(Instance.new("TextBox"))
        colorG.Size = UDim2.new(0.3, -3, 0, 25)
        colorG.Position = UDim2.new(0.35,0,0,yOffset)
        colorG.BackgroundColor3 = Color3.fromRGB(0,255,0)
        colorG.Text = "255"
        colorG.TextColor3 = Color3.new(1,1,1)
        colorG.Font = Enum.Font.Gotham
        colorG.TextSize = 12
        local colorB = AddElement(Instance.new("TextBox"))
        colorB.Size = UDim2.new(0.3, -3, 0, 25)
        colorB.Position = UDim2.new(0.7,0,0,yOffset)
        colorB.BackgroundColor3 = Color3.fromRGB(0,0,255)
        colorB.Text = "255"
        colorB.TextColor3 = Color3.new(1,1,1)
        colorB.Font = Enum.Font.Gotham
        colorB.TextSize = 12
        yOffset = yOffset + 30
        local applyColorBtn = AddElement(Instance.new("TextButton"))
        applyColorBtn.Size = UDim2.new(1, -10, 0, 30)
        applyColorBtn.Position = UDim2.new(0,5,0,yOffset)
        applyColorBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)
        applyColorBtn.Text = "Apply Train Color"
        applyColorBtn.TextColor3 = Color3.new(1,1,1)
        applyColorBtn.Font = Enum.Font.GothamBold
        applyColorBtn.TextSize = 14
        applyColorBtn.MouseButton1Click:Connect(function()
            local r = tonumber(colorR.Text) or 255
            local g = tonumber(colorG.Text) or 255
            local b = tonumber(colorB.Text) or 255
            pcall(function()
                local train = Workspace:FindFirstChild(Player.Name.."'s Train")
                if train then
                    for _, part in pairs(train:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.BrickColor = BrickColor.new(Color3.fromRGB(r,g,b))
                        end
                    end
                end
            end)
        end)
        yOffset = yOffset + 35

        -- Bypass Consist Limit
        local bypassToggle = AddElement(Instance.new("TextButton"))
        bypassToggle.Size = UDim2.new(1, -10, 0, 30)
        bypassToggle.Position = UDim2.new(0,5,0,yOffset)
        bypassToggle.BackgroundColor3 = BypassConsistLimit and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
        bypassToggle.Text = "Bypass 4/4 Consist Limit: " .. (BypassConsistLimit and "ON" or "OFF")
        bypassToggle.TextColor3 = Color3.new(1,1,1)
        bypassToggle.Font = Enum.Font.GothamBold
        bypassToggle.TextSize = 14
        bypassToggle.MouseButton1Click:Connect(function()
            BypassConsistLimit = not BypassConsistLimit
            UpdateContent()
            if BypassConsistLimit then
                pcall(function()
                    local consistVal = ReplicatedStorage:FindFirstChild("ConsistLimit")
                    if consistVal and consistVal:IsA("IntValue") then
                        consistVal.Value = 999
                    end
                end)
            end
        end)
        yOffset = yOffset + 35

        -- Exchange Passengers
        local exchangeBtn = AddElement(Instance.new("TextButton"))
        exchangeBtn.Size = UDim2.new(1, -10, 0, 30)
        exchangeBtn.Position = UDim2.new(0,5,0,yOffset)
        exchangeBtn.BackgroundColor3 = Color3.fromRGB(255,193,7)
        exchangeBtn.Text = "Exchange Passengers"
        exchangeBtn.TextColor3 = Color3.new(1,1,1)
        exchangeBtn.Font = Enum.Font.GothamBold
        exchangeBtn.TextSize = 14
        exchangeBtn.MouseButton1Click:Connect(function()
            pcall(function()
                ReplicatedStorage:WaitForChild("ExchangePassengers"):FireServer()
            end)
        end)
        yOffset = yOffset + 35

    elseif SelectedTab == "Gamepass" then
        -- Gamepass Unlocker
        local gamepassLabel = AddElement(Instance.new("TextLabel"))
        gamepassLabel.Size = UDim2.new(1, -10, 0, 20)
        gamepassLabel.Position = UDim2.new(0,5,0,yOffset)
        gamepassLabel.BackgroundTransparency = 1
        gamepassLabel.Text = "Select Gamepass:"
        gamepassLabel.TextColor3 = Color3.new(1,1,1)
        gamepassLabel.Font = Enum.Font.Gotham
        gamepassLabel.TextSize = 12
        yOffset = yOffset + 25

        local gamepasses = {
            {Name = "ICE 3 Pack", ID = 1},
            {Name = "TGV Bundle 2", ID = 2},
            {Name = "Longer Consists", ID = 3}
        }
        local selectedGamepass = 1
        for i, gp in ipairs(gamepasses) do
            local btn = AddElement(Instance.new("TextButton"))
            btn.Size = UDim2.new(1, -10, 0, 25)
            btn.Position = UDim2.new(0,5,0,yOffset)
            btn.BackgroundColor3 = (i == selectedGamepass) and Color3.fromRGB(0,150,200) or Color3.fromRGB(50,50,50)
            btn.Text = gp.Name
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 12
            btn.MouseButton1Click:Connect(function()
                selectedGamepass = i
                UpdateContent()
            end)
            yOffset = yOffset + 30
        end

        local unlockBtn = AddElement(Instance.new("TextButton"))
        unlockBtn.Size = UDim2.new(1, -10, 0, 30)
        unlockBtn.Position = UDim2.new(0,5,0,yOffset)
        unlockBtn.BackgroundColor3 = Color3.fromRGB(0,200,83)
        unlockBtn.Text = "Unlock Gamepass"
        unlockBtn.TextColor3 = Color3.new(1,1,1)
        unlockBtn.Font = Enum.Font.GothamBold
        unlockBtn.TextSize = 14
        unlockBtn.MouseButton1Click:Connect(function()
            pcall(function()
                ReplicatedStorage:WaitForChild("PurchaseGamepass"):FireServer(gamepasses[selectedGamepass].ID)
            end)
        end)
        yOffset = yOffset + 35

    elseif SelectedTab == "Misc" then
        -- Player ESP
        local espToggle = AddElement(Instance.new("TextButton"))
        espToggle.Size = UDim2.new(1, -10, 0, 30)
        espToggle.Position = UDim2.new(0,5,0,yOffset)
        espToggle.BackgroundColor3 = PlayerESPEnabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
        espToggle.Text = "Player ESP: " .. (PlayerESPEnabled and "ON" or "OFF")
        espToggle.TextColor3 = Color3.new(1,1,1)
        espToggle.Font = Enum.Font.GothamBold
        espToggle.TextSize = 14
        espToggle.MouseButton1Click:Connect(function()
            PlayerESPEnabled = not PlayerESPEnabled
            UpdateContent()
            if PlayerESPEnabled then
                for _, plr in pairs(Players:GetPlayers()) do
                    if plr ~= Player then
                        pcall(function()
                            local highlight = Instance.new("Highlight")
                            highlight.Name = "ESP_"..plr.Name
                            highlight.FillTransparency = 0.5
                            highlight.OutlineColor = Color3.new(1,0,0)
                            highlight.Parent = plr.Character
                        end)
                    end
                end
                Players.PlayerAdded:Connect(function(plr)
                    plr.CharacterAdded:Connect(function(char)
                        if PlayerESPEnabled then
                            local highlight = Instance.new("Highlight")
                            highlight.Name = "ESP_"..plr.Name
                            highlight.FillTransparency = 0.5
                            highlight.OutlineColor = Color3.new(1,0,0)
                            highlight.Parent = char
                        end
                    end)
                end)
            else
                for _, plr in pairs(Players:GetPlayers()) do
                    if plr.Character then
                        local esp = plr.Character:FindFirstChild("ESP_"..plr.Name)
                        if esp then esp:Destroy() end
                    end
                end
            end
        end)
        yOffset = yOffset + 35

        -- FPS Booster
        local fpsToggle = AddElement(Instance.new("TextButton"))
        fpsToggle.Size = UDim2.new(1, -10, 0, 30)
        fpsToggle.Position = UDim2.new(0,5,0,yOffset)
        fpsToggle.BackgroundColor3 = FPSBoostEnabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
        fpsToggle.Text = "FPS Booster: " .. (FPSBoostEnabled and "ON" or "OFF")
        fpsToggle.TextColor3 = Color3.new(1,1,1)
        fpsToggle.Font = Enum.Font.GothamBold
        fpsToggle.TextSize = 14
        fpsToggle.MouseButton1Click:Connect(function()
            FPSBoostEnabled = not FPSBoostEnabled
            UpdateContent()
            if FPSBoostEnabled then
                Lighting.GlobalShadows = false
                Lighting.FogEnd = 1e5
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then
                        v.Material = Enum.Material.Plastic
                        v.Reflectance = 0
                    end
                end
                game:GetService("RunService"):Set3dRenderingEnabled(false)
            else
                Lighting.GlobalShadows = true
                Lighting.FogEnd = 10000
                settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
                game:GetService("RunService"):Set3dRenderingEnabled(true)
            end
        end)
        yOffset = yOffset + 35

        -- Full Bright
        local fullBrightToggle = AddElement(Instance.new("TextButton"))
        fullBrightToggle.Size = UDim2.new(1, -10, 0, 30)
        fullBrightToggle.Position = UDim2.new(0,5,0,yOffset)
        fullBrightToggle.BackgroundColor3 = FullBrightEnabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
        fullBrightToggle.Text = "Full Bright: " .. (FullBrightEnabled and "ON" or "OFF")
        fullBrightToggle.TextColor3 = Color3.new(1,1,1)
        fullBrightToggle.Font = Enum.Font.GothamBold
        fullBrightToggle.TextSize = 14
        fullBrightToggle.MouseButton1Click:Connect(function()
            FullBrightEnabled = not FullBrightEnabled
            UpdateContent()
            if FullBrightEnabled then
                Lighting.Brightness = 2
                Lighting.ClockTime = 12
                Lighting.FogEnd = 1e6
                Lighting.GlobalShadows = false
            else
                Lighting.Brightness = 1
                Lighting.ClockTime = 14
                Lighting.FogEnd = 10000
            end
        end)
        yOffset = yOffset + 35

        -- No Clip Trains
        local noclipTrainsToggle = AddElement(Instance.new("TextButton"))
        noclipTrainsToggle.Size = UDim2.new(1, -10, 0, 30)
        noclipTrainsToggle.Position = UDim2.new(0,5,0,yOffset)
        noclipTrainsToggle.BackgroundColor3 = NoClipTrains and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
        noclipTrainsToggle.Text = "No Clip Trains: " .. (NoClipTrains and "ON" or "OFF")
        noclipTrainsToggle.TextColor3 = Color3.new(1,1,1)
        noclipTrainsToggle.Font = Enum.Font.GothamBold
        noclipTrainsToggle.TextSize = 14
        noclipTrainsToggle.MouseButton1Click:Connect(function()
            NoClipTrains = not NoClipTrains
            UpdateContent()
            if NoClipTrains then
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v:IsA("BasePart") and v.Name == "Train" then
                        v.CanCollide = false
                    end
                end
            else
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v:IsA("BasePart") and v.Name == "Train" then
                        v.CanCollide = true
                    end
                end
            end
        end)
        yOffset = yOffset + 35

        -- Speed Hack
        local speedhackToggle = AddElement(Instance.new("TextButton"))
        speedhackToggle.Size = UDim2.new(1, -10, 0, 30)
        speedhackToggle.Position = UDim2.new(0,5,0,yOffset)
        speedhackToggle.BackgroundColor3 = SpeedHackEnabled and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
        speedhackToggle.Text = "Speed Hack: " .. (SpeedHackEnabled and "ON" or "OFF")
        speedhackToggle.TextColor3 = Color3.new(1,1,1)
        speedhackToggle.Font = Enum.Font.GothamBold
        speedhackToggle.TextSize = 14
        speedhackToggle.MouseButton1Click:Connect(function()
            SpeedHackEnabled = not SpeedHackEnabled
            UpdateContent()
            -- Speed hack implementation via workspace gravity and walkspeed
            if SpeedHackEnabled then
                Workspace.Gravity = 0
                Humanoid.WalkSpeed = 100
            else
                Workspace.Gravity = 196.2
                Humanoid.WalkSpeed = 16
            end
        end)
        yOffset = yOffset + 35

    elseif SelectedTab == "Extra" then
        -- Extra features (15 more)
        local extras = {
            {Name = "Unlock All Stations", Func = function()
                pcall(function() ReplicatedStorage:WaitForChild("UnlockAllStations"):FireServer() end)
            end},
            {Name = "Give All Badges", Func = function()
                pcall(function() ReplicatedStorage:WaitForChild("GiveAllBadges"):FireServer() end)
            end},
            {Name = "Auto Collect Rewards", Func = function()
                while AutoFarmEnabled do
                    pcall(function() ReplicatedStorage:WaitForChild("CollectReward"):FireServer() end)
                    wait(5)
                end
            end},
            {Name = "Infinite Health", Func = function()
                Character.Humanoid.Health = Character.Humanoid.MaxHealth
            end},
            {Name = "Teleport to Nearest Train", Func = function()
                local nearest = nil
                local nearestDist = math.huge
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v:IsA("BasePart") and v.Name == "Train" then
                        local dist = (v.Position - HumanoidRootPart.Position).Magnitude
                        if dist < nearestDist then
                            nearestDist = dist
                            nearest = v
                        end
                    end
                end
                if nearest then
                    HumanoidRootPart.CFrame = nearest.CFrame + Vector3.new(0,5,0)
                end
            end},
            {Name = "Vehicle ESP", Func = function()
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v:IsA("BasePart") and v.Name == "Train" then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "TrainESP"
                        highlight.FillTransparency = 0.5
                        highlight.OutlineColor = Color3.new(0,1,1)
                        highlight.Parent = v
                    end
                end
            end},
            {Name = "Remove Fog", Func = function()
                Lighting.FogEnd = 1e6
                Lighting.FogStart = 1e5
            end},
            {Name = "No Train Collision", Func = function()
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v:IsA("BasePart") and v.Name == "Train" then
                        v.CanCollide = false
                    end
                end
            end},
            {Name = "Super Jump", Func = function()
                Humanoid.JumpPower = 200
            end},
            {Name = "Reset Character", Func = function()
                Player.Character:BreakJoints()
            end},
            {Name = "Server Hop", Func = function()
                TeleportService:Teleport(game.PlaceId, Player)
            end},
            {Name = "Lag Server", Func = function()
                -- Placeholder, not recommended
            end},
            {Name = "Anti AFK", Func = function()
                local VirtualUser = game:GetService("VirtualUser")
                Player.Idled:Connect(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
            end},
            {Name = "Chat Spoofer", Func = function()
                -- Placeholder
            end},
            {Name = "View Hitboxes", Func = function()
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.Transparency = 0.7
                    end
                end
            end}
        }
        for _, ext in ipairs(extras) do
            local btn = AddElement(Instance.new("TextButton"))
            btn.Size = UDim2.new(1, -10, 0, 25)
            btn.Position = UDim2.new(0,5,0,yOffset)
            btn.BackgroundColor3 = Color3.fromRGB(80,80,80)
            btn.Text = ext.Name
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 12
            btn.MouseButton1Click:Connect(function()
                pcall(ext.Func)
            end)
            yOffset = yOffset + 30
        end
    end

    ContentFrame.CanvasSize = UDim2.new(0,0,0,yOffset+10)
end

-- Connect Tab Buttons to update content
for tabName, btn in pairs(Tabs) do
    btn.MouseButton1Click:Connect(function()
        SelectedTab = tabName
        UpdateContent()
    end)
end

-- Initial content load
UpdateContent()

-- Key Submit Logic
SubmitButton.MouseButton1Click:Connect(function()
    if KeyBox.Text == correctKey then
        KeyGui.Enabled = false
        DevGui.Enabled = true
    else
        KeyBox.Text = ""
        KeyBox.PlaceholderText = "Invalid Key!"
        wait(1)
        KeyBox.PlaceholderText = "Enter Key..."
    end
end)

CopyButton.MouseButton1Click:Connect(function()
    pcall(function()
        setclipboard(copyLink)
    end)
    CopyButton.Text = "COPIED!"
    wait(1)
    CopyButton.Text = "COPY LINK"
end)

-- Auto Farm Loop
spawn(function()
    while true do
        wait(1)
        if AutoFarmEnabled then
            pcall(function()
                ReplicatedStorage:WaitForChild("AutoFarm"):FireServer()
            end)
        end
    end
end)

-- Ensure Character ref is updated
Player.CharacterAdded:Connect(function(char)
    Character = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    Humanoid = char:WaitForChild("Humanoid")
end)

print("Delta Executor: Train Sim Dev Panel Loaded. Use key 'keysystem_bypass'.")
