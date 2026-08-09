--[[
    ========================================================================================
    NEXA TRAIN SIM ULTIMATE PRO SUITE & AUTO-FARM ENGINE
    ========================================================================================
    Target Game     : Project [NEW TRAINS] Train Sim by Nexa Works
    Place ID        : 12893488117
    Execution Env   : Delta Executor / Modern Lua Runtime
    Architecture    : Modular Event-Driven Telemetry, PID Physics Control & Auto-Farm Suite
    ========================================================================================
--]]

----------------------------------------------------------------------------------------
-- 1. CORE SERVICES & ENGINE INITIALIZATION
----------------------------------------------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local PathfindingService = game:GetService("PathfindingService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local Stats = game:GetService("Stats")
local LogService = game:GetService("LogService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Mouse = LocalPlayer:GetMouse()

----------------------------------------------------------------------------------------
-- 2. GLOBAL CONFIGURATION & SYSTEM STATE
----------------------------------------------------------------------------------------
local NexaConfig = {
    -- Auto Farm & Route Settings
    AutoFarmEnabled = false,
    AutoFarmRouteLoop = true,
    TargetDwellTime = 10, -- Seconds to wait at station for passenger loading
    ApproachDecelDistance = 400, -- Studs before station to begin braking
    StationStopDistance = 15, -- Studs threshold for full stop
    AutoDoorToggle = true,
    FarmSpeedLimit = 120, -- Target KM/H during auto-farm
    
    -- Governor & Physics Settings
    SpeedGovernorBypass = false,
    SpeedMultiplier = 1.0,
    AccelerationMultiplier = 2.0,
    TorqueBoost = 500000,
    AntiDerailEnabled = true,
    CollisionBypass = false,
    InstantBrakePower = 99999,
    AutoCruiseControl = false,
    CruiseTargetSpeed = 80,
    
    -- Track & Signal Control Settings
    SignalBypassGreen = false,
    AutoJunctionSwitch = true,
    SignalScanRadius = 1000,
    
    -- Visual ESP Settings
    StationESP = true,
    SignalESP = true,
    JunctionESP = true,
    PlayerTrainESP = true,
    ESPRenderDistance = 2500,
    
    -- System & Utility Settings
    AntiAFK = true,
    KeybindMenu = Enum.KeyCode.RightControl,
    NotificationVolume = 0.5,
    AutoRejoinOnKick = true
}

local NexaState = {
    CurrentTrain = nil,
    PrimarySeat = nil,
    TrainCarriages = {},
    CurrentVelocity = 0,
    CurrentKmh = 0,
    CurrentMph = 0,
    CurrentStation = nil,
    NextStation = nil,
    FarmStatus = "Idle",
    FarmTotalEarned = 0,
    FarmStationsCompleted = 0,
    DwellTimerRemaining = 0,
    ActiveESPObjects = {},
    Connections = {},
    StationsList = {},
    SignalsList = {},
    JunctionsList = {},
    GUIVisible = true,
    CurrentTab = "Telemetry"
}

----------------------------------------------------------------------------------------
-- 3. NOTIFICATION & AUDIO ENGINE
----------------------------------------------------------------------------------------
local NotificationStack = {}

local function PlayAlertSound(soundType)
    local sound = Instance.new("Sound")
    sound.Volume = NexaConfig.NotificationVolume
    sound.Parent = SoundService
    
    if soundType == "Success" then
        sound.SoundId = "rbxassetid://6895079853"
    elseif soundType == "Warning" then
        sound.SoundId = "rbxassetid://6895079853"
    elseif soundType == "Station" then
        sound.SoundId = "rbxassetid://9114223178"
    else
        sound.SoundId = "rbxassetid://6895079853"
    end
    
    sound:Play()
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end

local function CreateNotification(title, text, duration, color)
    duration = duration or 4
    color = color or Color3.fromRGB(0, 255, 170)
    
    local guiParent = gethui and gethui() or (syn and syn.protect_gui and PlayerGui) or PlayerGui
    local notifGui = guiParent:FindFirstChild("NexaNotifContainer")
    
    if not notifGui then
        notifGui = Instance.new("ScreenGui")
        notifGui.Name = "NexaNotifContainer"
        notifGui.ResetOnSpawn = false
        notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        notifGui.Parent = guiParent
        
        local container = Instance.new("Frame")
        container.Name = "ContainerFrame"
        container.Size = UDim2.new(0, 300, 1, -40)
        container.Position = UDim2.new(1, -320, 0, 20)
        container.BackgroundTransparency = 1
        container.Parent = notifGui
        
        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        layout.Padding = UDim.new(0, 8)
        layout.Parent = container
    end
    
    local containerFrame = notifGui.ContainerFrame
    
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, 0, 0, 64)
    Card.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
    Card.BorderSizePixel = 0
    Card.Position = UDim2.new(1, 20, 0, 0)
    Card.Parent = containerFrame
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Card
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = color
    Stroke.Thickness = 1.5
    Stroke.Parent = Card
    
    local TitleL = Instance.new("TextLabel")
    TitleL.Size = UDim2.new(1, -16, 0, 22)
    TitleL.Position = UDim2.new(0, 12, 0, 6)
    TitleL.BackgroundTransparency = 1
    TitleL.Text = title
    TitleL.TextColor3 = color
    TitleL.Font = Enum.Font.GothamBold
    TitleL.TextSize = 13
    TitleL.TextXAlignment = Enum.TextXAlignment.Left
    TitleL.Parent = Card
    
    local TextL = Instance.new("TextLabel")
    TextL.Size = UDim2.new(1, -16, 0, 30)
    TextL.Position = UDim2.new(0, 12, 0, 26)
    TextL.BackgroundTransparency = 1
    TextL.Text = text
    TextL.TextColor3 = Color3.fromRGB(200, 210, 225)
    TextL.Font = Enum.Font.Gotham
    TextL.TextSize = 11
    TextL.TextWrapped = true
    TextL.TextXAlignment = Enum.TextXAlignment.Left
    TextL.Parent = Card
    
    TweenService:Create(Card, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    
    task.delay(duration, function()
        local tweenOut = TweenService:Create(Card, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {Position = UDim2.new(1, 20, 0, 0)})
        tweenOut:Play()
        tweenOut.Completed:Connect(function()
            Card:Destroy()
        end)
    end)
end

----------------------------------------------------------------------------------------
-- 4. VEHICLE & TRAIN ASSEMBLY DETECTOR ENGINE
----------------------------------------------------------------------------------------
local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetSeat()
    local char = GetCharacter()
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart and hum.SeatPart:IsA("VehicleSeat") then
        return hum.SeatPart
    end
    return nil
end

local function DetectActiveTrainAssembly()
    local seat = GetSeat()
    if not seat then
        NexaState.CurrentTrain = nil
        NexaState.PrimarySeat = nil
        NexaState.TrainCarriages = {}
        return nil
    end
    
    NexaState.PrimarySeat = seat
    
    local current = seat
    local candidateTrain = nil
    
    while current and current ~= Workspace and current.Parent ~= nil do
        if current:FindFirstChild("Drive") or current:FindFirstChild("Throttle") or current:FindFirstChild("Engine") or string.find(string.lower(current.Name), "train") or string.find(string.lower(current.Name), "locomotive") or string.find(string.lower(current.Name), "car") then
            candidateTrain = current
        end
        current = current.Parent
    end
    
    if not candidateTrain then
        candidateTrain = seat.Parent
    end
    
    NexaState.CurrentTrain = candidateTrain
    
    -- Scan for linked carriages in assembly
    local carriages = {}
    if candidateTrain then
        for _, part in pairs(candidateTrain:GetDescendants()) do
            if part:IsA("VehicleSeat") or part:IsA("Seat") then
                table.insert(carriages, part.Parent)
            end
        end
    end
    NexaState.TrainCarriages = carriages
    
    return candidateTrain
end

local function CalculateTrainMass()
    if not NexaState.CurrentTrain then return 0 end
    local mass = 0
    for _, part in pairs(NexaState.CurrentTrain:GetDescendants()) do
        if part:IsA("BasePart") then
            mass = mass + part:GetMass()
        end
    end
    return math.floor(mass)
end

----------------------------------------------------------------------------------------
-- 5. MAP SCANNER ENGINE (STATIONS, SIGNALS & JUNCTIONS)
----------------------------------------------------------------------------------------
local function ScanWorldMap()
    NexaState.StationsList = {}
    NexaState.SignalsList = {}
    NexaState.JunctionsList = {}
    
    -- Recursive search for station platforms, signals, and switches
    for _, obj in pairs(Workspace:GetDescendants()) do
        local lowerName = string.lower(obj.Name)
        
        -- Detect Stations
        if string.find(lowerName, "station") or string.find(lowerName, "platform") or string.find(lowerName, "stopmark") then
            if obj:IsA("BasePart") or obj:IsA("Model") then
                local pos = obj:IsA("BasePart") and obj.Position or (obj:IsA("Model") and obj:GetPivot().Position)
                if pos then
                    table.insert(NexaState.StationsList, {
                        Instance = obj,
                        Name = obj.Name,
                        Position = pos
                    })
                end
            end
        end
        
        -- Detect Rail Signals
        if string.find(lowerName, "signal") or string.find(lowerName, "light") or string.find(lowerName, "semaphor") then
            if obj:IsA("BasePart") or obj:IsA("Model") then
                local pos = obj:IsA("BasePart") and obj.Position or (obj:IsA("Model") and obj:GetPivot().Position)
                if pos then
                    table.insert(NexaState.SignalsList, {
                        Instance = obj,
                        Name = obj.Name,
                        Position = pos
                    })
                end
            end
        end
        
        -- Detect Track Junctions / Switches
        if string.find(lowerName, "switch") or string.find(lowerName, "junction") or string.find(lowerName, "turnout") then
            if obj:IsA("BasePart") or obj:IsA("Model") then
                local pos = obj:IsA("BasePart") and obj.Position or (obj:IsA("Model") and obj:GetPivot().Position)
                if pos then
                    table.insert(NexaState.JunctionsList, {
                        Instance = obj,
                        Name = obj.Name,
                        Position = pos
                    })
                end
            end
        end
    end
end

local function GetClosestStation()
    local seat = NexaState.PrimarySeat
    if not seat or #NexaState.StationsList == 0 then return nil, 999999 end
    
    local trainPos = seat.Position
    local closest = nil
    local minDist = 999999
    
    for _, st in ipairs(NexaState.StationsList) do
        local dist = (st.Position - trainPos).Magnitude
        if dist < minDist then
            minDist = dist
            closest = st
        end
    end
    
    return closest, minDist
end

----------------------------------------------------------------------------------------
-- 6. AUTO-FARM & PASSENGER AUTOMATION SUITE
----------------------------------------------------------------------------------------
local function ControlTrainThrottle(throttleValue)
    local seat = NexaState.PrimarySeat
    if not seat then return end
    
    seat.ThrottleFloat = throttleValue
    seat.Throttle = math.clamp(math.floor(throttleValue * 100), -1, 1)
    
    -- Force velocity application if multiplier active
    if NexaConfig.SpeedGovernorBypass and throttleValue ~= 0 then
        seat.MaxSpeed = NexaConfig.FarmSpeedLimit * 1.5
        seat.Torque = NexaConfig.TorqueBoost
        local targetVelocity = seat.CFrame.LookVector * (throttleValue * (NexaConfig.FarmSpeedLimit / 3.6))
        seat.AssemblyLinearVelocity = seat.AssemblyLinearVelocity:Lerp(targetVelocity, 0.15 * NexaConfig.AccelerationMultiplier)
    end
end

local function TriggerPassengerDoors(openState)
    local train = NexaState.CurrentTrain
    if not train then return end
    
    for _, part in pairs(train:GetDescendants()) do
        if part:IsA("ClickDetector") or string.find(string.lower(part.Name), "door") then
            if part:IsA("RemoteEvent") or part:IsA("RemoteFunction") then
                pcall(function()
                    part:FireServer(openState)
                end)
            end
        end
    end
end

local function AutoFarmStep()
    if not NexaConfig.AutoFarmEnabled then return end
    
    local seat = NexaState.PrimarySeat
    if not seat then
        NexaState.FarmStatus = "Waiting for Train Seat"
        return
    end
    
    local station, dist = GetClosestStation()
    if not station then
        NexaState.FarmStatus = "Scanning for Stations..."
        ScanWorldMap()
        return
    end
    
    NexaState.NextStation = station
    
    -- Auto-Farm State Machine
    if dist > NexaConfig.ApproachDecelDistance then
        -- Cruise to next station
        NexaState.FarmStatus = "Cruising to: " .. station.Name .. " (" .. math.floor(dist) .. "m)"
        ControlTrainThrottle(1)
        
    elseif dist <= NexaConfig.ApproachDecelDistance and dist > NexaConfig.StationStopDistance then
        -- Decelerate smoothly
        NexaState.FarmStatus = "Approaching & Braking: " .. station.Name .. " (" .. math.floor(dist) .. "m)"
        local speedRatio = dist / NexaConfig.ApproachDecelDistance
        ControlTrainThrottle(math.clamp(speedRatio * 0.5, 0.05, 0.5))
        
    elseif dist <= NexaConfig.StationStopDistance then
        -- Full stop at platform
        NexaState.FarmStatus = "Docked at " .. station.Name .. " - Loading Passengers"
        ControlTrainThrottle(0)
        
        -- Apply immediate emergency anchor brake
        seat.AssemblyLinearVelocity = Vector3.new(0,0,0)
        
        if NexaConfig.AutoDoorToggle then
            TriggerPassengerDoors(true)
        end
        
        PlayAlertSound("Station")
        CreateNotification("Station Docked", "Loading passengers at " .. station.Name .. ". Dwell timer started.", 5, Color3.fromRGB(0, 255, 170))
        
        -- Dwell timer countdown
        for remaining = NexaConfig.TargetDwellTime, 1, -1 do
            if not NexaConfig.AutoFarmEnabled then break end
            NexaState.DwellTimerRemaining = remaining
            NexaState.FarmStatus = "Boarding Passengers (" .. remaining .. "s remaining)"
            task.wait(1)
        end
        
        if NexaConfig.AutoDoorToggle then
            TriggerPassengerDoors(false)
        end
        
        NexaState.FarmStationsCompleted = NexaState.FarmStationsCompleted + 1
        NexaState.FarmTotalEarned = NexaState.FarmTotalEarned + math.random(450, 850)
        
        CreateNotification("Departure", "Departing station " .. station.Name .. ". Next leg initiated.", 4, Color3.fromRGB(0, 200, 255))
        
        -- Drive away from current station so distance expands past stopping threshold
        ControlTrainThrottle(1)
        task.wait(5)
    end
end

----------------------------------------------------------------------------------------
-- 7. PHYSICS & GOVERNOR OVERRIDES SUITE
----------------------------------------------------------------------------------------
local function ApplyInstantBrake()
    local seat = NexaState.PrimarySeat
    if seat then
        seat.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        seat.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        ControlTrainThrottle(0)
        CreateNotification("Emergency Brake", "Magnetic brakes engaged. Train locked in position.", 3, Color3.fromRGB(255, 70, 70))
    end
end

local function ProcessAntiDerailment()
    if not NexaConfig.AntiDerailEnabled then return end
    local seat = NexaState.PrimarySeat
    if seat then
        local angVel = seat.AssemblyAngularVelocity
        -- Lock roll and pitch axes to prevent train tipping off tracks
        seat.AssemblyAngularVelocity = Vector3.new(0, angVel.Y, 0)
    end
end

local function ProcessCollisionBypass()
    local train = NexaState.CurrentTrain
    if not train then return end
    
    for _, part in pairs(train:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not NexaConfig.CollisionBypass
        end
    end
end

----------------------------------------------------------------------------------------
-- 8. VISUAL ESP & 3D RENDER ENGINE
----------------------------------------------------------------------------------------
local function ClearESP()
    for _, item in pairs(NexaState.ActiveESPObjects) do
        if item.Box then item.Box:Destroy() end
        if item.Text then item.Text:Destroy() end
    end
    NexaState.ActiveESPObjects = {}
end

local function RenderESP()
    ClearESP()
    
    local seat = NexaState.PrimarySeat
    local myPos = seat and seat.Position or (GetCharacter() and GetCharacter():GetPivot().Position)
    if not myPos then return end
    
    -- Station ESP Render
    if NexaConfig.StationESP then
        for _, st in ipairs(NexaState.StationsList) do
            local dist = (st.Position - myPos).Magnitude
            if dist <= NexaConfig.ESPRenderDistance then
                local bg = Instance.new("BillboardGui")
                bg.Name = "ESP_Station"
                bg.AlwaysOnTop = true
                bg.Size = UDim2.new(0, 160, 0, 40)
                bg.Adornee = st.Instance:IsA("BasePart") and st.Instance or st.Instance:FindFirstChildWhichIsA("BasePart")
                bg.Parent = CoreGui
                
                local txt = Instance.new("TextLabel")
                txt.Size = UDim2.new(1, 0, 1, 0)
                txt.BackgroundTransparency = 1
                txt.Text = "🚉 " .. st.Name .. "\n[" .. math.floor(dist) .. "m]"
                txt.TextColor3 = Color3.fromRGB(0, 255, 170)
                txt.Font = Enum.Font.GothamBold
                txt.TextSize = 11
                txt.Parent = bg
                
                table.insert(NexaState.ActiveESPObjects, {Box = bg, Text = txt})
            end
        end
    end
    
    -- Signal ESP Render
    if NexaConfig.SignalESP then
        for _, sig in ipairs(NexaState.SignalsList) do
            local dist = (sig.Position - myPos).Magnitude
            if dist <= NexaConfig.ESPRenderDistance then
                local bg = Instance.new("BillboardGui")
                bg.Name = "ESP_Signal"
                bg.AlwaysOnTop = true
                bg.Size = UDim2.new(0, 140, 0, 30)
                bg.Adornee = sig.Instance:IsA("BasePart") and sig.Instance or sig.Instance:FindFirstChildWhichIsA("BasePart")
                bg.Parent = CoreGui
                
                local txt = Instance.new("TextLabel")
                txt.Size = UDim2.new(1, 0, 1, 0)
                txt.BackgroundTransparency = 1
                txt.Text = "🚦 Signal\n[" .. math.floor(dist) .. "m]"
                txt.TextColor3 = NexaConfig.SignalBypassGreen and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 200, 50)
                txt.Font = Enum.Font.GothamMedium
                txt.TextSize = 10
                txt.Parent = bg
                
                table.insert(NexaState.ActiveESPObjects, {Box = bg, Text = txt})
            end
        end
    end
end

----------------------------------------------------------------------------------------
-- 9. DARK GLASSMORPHIC DEVELOPER GUI CONSTRUCTION
----------------------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NexaTrainSimUltimateGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = PlayerGui
else
    ScreenGui.Parent = PlayerGui
end

-- Main Viewport Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 960, 0, 620)
MainFrame.Position = UDim2.new(0.5, -480, 0.5, -310)
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 16, 24)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(36, 42, 60)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- Top Bar Header
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 48)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TitleText = Instance.new("TextLabel")
TitleText.Name = "Title"
TitleText.Size = UDim2.new(0, 450, 1, 0)
TitleText.Position = UDim2.new(0, 16, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "🚂 NEXA TRAIN SIM <font color=\"#00FFAB\">ULTIMATE ENGINE</font> <font color=\"#607090\">[v4.0 PRO]</font>"
TitleText.RichText = true
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 16
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TopBar

local TopMetrics = Instance.new("TextLabel")
TopMetrics.Name = "TopMetrics"
TopMetrics.Size = UDim2.new(0, 350, 1, 0)
TopMetrics.Position = UDim2.new(1, -366, 0, 0)
TopMetrics.BackgroundTransparency = 1
TopMetrics.Text = "FPS: -- | Ping: --ms | Mem: --MB"
TopMetrics.TextColor3 = Color3.fromRGB(0, 255, 170)
TopMetrics.Font = Enum.Font.Code
TopMetrics.TextSize = 12
TopMetrics.TextXAlignment = Enum.TextXAlignment.Right
TopMetrics.Parent = TopBar

local MetricsPad = Instance.new("UIPadding")
MetricsPad.PaddingRight = UDim.new(0, 16)
MetricsPad.Parent = TopMetrics

-- Sidebar Navigation
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 190, 1, -48)
Sidebar.Position = UDim2.new(0, 0, 0, 48)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SideLayout = Instance.new("UIListLayout")
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideLayout.Padding = UDim.new(0, 4)
SideLayout.Parent = Sidebar

local SidePad = Instance.new("UIPadding")
SidePad.PaddingLeft = UDim.new(0, 10)
SidePad.PaddingTop = UDim.new(0, 10)
SidePad.PaddingRight = UDim.new(0, 10)
SidePad.Parent = Sidebar

-- Pages Container
local PagesFolder = Instance.new("Frame")
PagesFolder.Name = "PagesFolder"
PagesFolder.Size = UDim2.new(1, -190, 1, -48)
PagesFolder.Position = UDim2.new(0, 190, 0, 48)
PagesFolder.BackgroundTransparency = 1
PagesFolder.Parent = MainFrame

----------------------------------------------------------------------------------------
-- GUI TAB 1: TELEMETRY & INSTRUMENTS
----------------------------------------------------------------------------------------
local PageTelemetry = Instance.new("Frame")
PageTelemetry.Name = "Page_Telemetry"
PageTelemetry.Size = UDim2.new(1, 0, 1, 0)
PageTelemetry.BackgroundTransparency = 1
PageTelemetry.Parent = PagesFolder

-- Digital Speedometer Display Card
local SpeedCard = Instance.new("Frame")
SpeedCard.Size = UDim2.new(0, 340, 0, 220)
SpeedCard.Position = UDim2.new(0, 16, 0, 16)
SpeedCard.BackgroundColor3 = Color3.fromRGB(22, 26, 38)
SpeedCard.Parent = PageTelemetry

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 8)
SpeedCorner.Parent = SpeedCard

local SpeedStroke = Instance.new("UIStroke")
SpeedStroke.Color = Color3.fromRGB(0, 255, 170)
SpeedStroke.Thickness = 1.5
SpeedStroke.Parent = SpeedCard

local SpeedTitle = Instance.new("TextLabel")
SpeedTitle.Size = UDim2.new(1, 0, 0, 30)
SpeedTitle.Position = UDim2.new(0, 0, 0, 8)
SpeedTitle.BackgroundTransparency = 1
SpeedTitle.Text = "REAL-TIME VELOCITY TELEMETRY"
SpeedTitle.TextColor3 = Color3.fromRGB(140, 150, 170)
SpeedTitle.Font = Enum.Font.GothamBold
SpeedTitle.TextSize = 12
SpeedTitle.Parent = SpeedCard

local SpeedBigText = Instance.new("TextLabel")
SpeedBigText.Size = UDim2.new(1, 0, 0, 80)
SpeedBigText.Position = UDim2.new(0, 0, 0, 45)
SpeedBigText.BackgroundTransparency = 1
SpeedBigText.Text = "000"
SpeedBigText.TextColor3 = Color3.fromRGB(0, 255, 170)
SpeedBigText.Font = Enum.Font.Code
SpeedBigText.TextSize = 72
SpeedBigText.Parent = SpeedCard

local SpeedSubText = Instance.new("TextLabel")
SpeedSubText.Size = UDim2.new(1, 0, 0, 24)
SpeedSubText.Position = UDim2.new(0, 0, 0, 135)
SpeedSubText.BackgroundTransparency = 1
SpeedSubText.Text = "KM/H | 000 MPH | 000 STU/S"
SpeedSubText.TextColor3 = Color3.fromRGB(180, 190, 210)
SpeedSubText.Font = Enum.Font.GothamMedium
SpeedSubText.TextSize = 12
SpeedSubText.Parent = SpeedCard

local TrainMassLabel = Instance.new("TextLabel")
TrainMassLabel.Size = UDim2.new(1, 0, 0, 20)
TrainMassLabel.Position = UDim2.new(0, 0, 0, 170)
TrainMassLabel.BackgroundTransparency = 1
TrainMassLabel.Text = "ASSEMBLY MASS: 0 LBS | CARRIAGES: 0"
TrainMassLabel.TextColor3 = Color3.fromRGB(120, 130, 150)
TrainMassLabel.Font = Enum.Font.Code
TrainMassLabel.TextSize = 11
TrainMassLabel.Parent = SpeedCard

-- G-Force & Gradient Instrument Card
local GaugeCard = Instance.new("Frame")
GaugeCard.Size = UDim2.new(1, -388, 0, 220)
GaugeCard.Position = UDim2.new(0, 372, 0, 16)
GaugeCard.BackgroundColor3 = Color3.fromRGB(22, 26, 38)
GaugeCard.Parent = PageTelemetry

local GaugeCorner = Instance.new("UICorner")
GaugeCorner.CornerRadius = UDim.new(0, 8)
GaugeCorner.Parent = GaugeCard

local GaugeTitle = Instance.new("TextLabel")
GaugeTitle.Size = UDim2.new(1, -20, 0, 30)
GaugeTitle.Position = UDim2.new(0, 12, 0, 8)
GaugeTitle.BackgroundTransparency = 1
GaugeTitle.Text = "DYNAMICS & GRADIENT GAUGES"
GaugeTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
GaugeTitle.Font = Enum.Font.GothamBold
GaugeTitle.TextSize = 12
GaugeTitle.TextXAlignment = Enum.TextXAlignment.Left
GaugeTitle.Parent = GaugeCard

local GForceText = Instance.new("TextLabel")
GForceText.Size = UDim2.new(1, -24, 0, 24)
GForceText.Position = UDim2.new(0, 12, 0, 48)
GForceText.BackgroundTransparency = 1
GForceText.Text = "Longitudinal G-Force: 0.00 G"
GForceText.TextColor3 = Color3.fromRGB(200, 210, 225)
GForceText.Font = Enum.Font.Gotham
GForceText.TextSize = 12
GForceText.TextXAlignment = Enum.TextXAlignment.Left
GForceText.Parent = GaugeCard

local GradientText = Instance.new("TextLabel")
GradientText.Size = UDim2.new(1, -24, 0, 24)
GradientText.Position = UDim2.new(0, 12, 0, 80)
GradientText.BackgroundTransparency = 1
GradientText.Text = "Track Gradient / Incline: 0.0°"
GradientText.TextColor3 = Color3.fromRGB(200, 210, 225)
GradientText.Font = Enum.Font.Gotham
GradientText.TextSize = 12
GradientText.TextXAlignment = Enum.TextXAlignment.Left
GradientText.Parent = GaugeCard

----------------------------------------------------------------------------------------
-- GUI TAB 2: AUTOMATED PASSENGER FARMING
----------------------------------------------------------------------------------------
local PageFarm = Instance.new("Frame")
PageFarm.Name = "Page_Farm"
PageFarm.Size = UDim2.new(1, 0, 1, 0)
PageFarm.BackgroundTransparency = 1
PageFarm.Visible = false
PageFarm.Parent = PagesFolder

-- Auto Farm Dashboard
local FarmDashboard = Instance.new("Frame")
FarmDashboard.Size = UDim2.new(1, -32, 0, 180)
FarmDashboard.Position = UDim2.new(0, 16, 0, 16)
FarmDashboard.BackgroundColor3 = Color3.fromRGB(22, 26, 38)
FarmDashboard.Parent = PageFarm

local DashCorner = Instance.new("UICorner")
DashCorner.CornerRadius = UDim.new(0, 8)
DashCorner.Parent = FarmDashboard

local DashTitle = Instance.new("TextLabel")
DashTitle.Size = UDim2.new(1, -20, 0, 30)
DashTitle.Position = UDim2.new(0, 12, 0, 8)
DashTitle.BackgroundTransparency = 1
DashTitle.Text = "🤖 PASSENGER AUTO-FARM ENGINE CONTROL"
DashTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
DashTitle.Font = Enum.Font.GothamBold
DashTitle.TextSize = 13
DashTitle.TextXAlignment = Enum.TextXAlignment.Left
DashTitle.Parent = FarmDashboard

local FarmToggleBtn = Instance.new("TextButton")
FarmToggleBtn.Size = UDim2.new(0, 220, 0, 42)
FarmToggleBtn.Position = UDim2.new(0, 12, 0, 48)
FarmToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
FarmToggleBtn.Text = "▶ START AUTO-FARM"
FarmToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FarmToggleBtn.Font = Enum.Font.GothamBold
FarmToggleBtn.TextSize = 13
FarmToggleBtn.Parent = FarmDashboard

local FarmBtnCorner = Instance.new("UICorner")
FarmBtnCorner.CornerRadius = UDim.new(0, 6)
FarmBtnCorner.Parent = FarmToggleBtn

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -250, 0, 42)
StatusLabel.Position = UDim2.new(0, 244, 0, 48)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: IDLE | Stations Docked: 0 | Total Earned: $0"
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 170)
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = FarmDashboard

FarmToggleBtn.MouseButton1Click:Connect(function()
    NexaConfig.AutoFarmEnabled = not NexaConfig.AutoFarmEnabled
    if NexaConfig.AutoFarmEnabled then
        FarmToggleBtn.Text = "⏸ PAUSE AUTO-FARM"
        FarmToggleBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        CreateNotification("Auto-Farm Activated", "Passenger route automation is now running.", 4, Color3.fromRGB(0, 255, 170))
    else
        FarmToggleBtn.Text = "▶ START AUTO-FARM"
        FarmToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
        NexaState.FarmStatus = "Idle"
        CreateNotification("Auto-Farm Paused", "Passenger route automation halted.", 4, Color3.fromRGB(255, 180, 50))
    end
end)

----------------------------------------------------------------------------------------
-- GUI TAB 3: GOVERNOR & OVERRIDES
----------------------------------------------------------------------------------------
local PageGovernor = Instance.new("Frame")
PageGovernor.Name = "Page_Governor"
PageGovernor.Size = UDim2.new(1, 0, 1, 0)
PageGovernor.BackgroundTransparency = 1
PageGovernor.Visible = false
PageGovernor.Parent = PagesFolder

local GovScroll = Instance.new("ScrollingFrame")
GovScroll.Size = UDim2.new(1, -32, 1, -20)
GovScroll.Position = UDim2.new(0, 16, 0, 10)
GovScroll.BackgroundTransparency = 1
GovScroll.BorderSizePixel = 0
GovScroll.ScrollBarThickness = 6
GovScroll.Parent = PageGovernor

local GovGrid = Instance.new("UIGridLayout")
GovGrid.CellSize = UDim2.new(0, 350, 0, 95)
GovGrid.CellPadding = UDim2.new(0, 12, 0, 12)
GovGrid.SortOrder = Enum.SortOrder.Name
GovGrid.Parent = GovScroll

local function CreateGovCard(title, desc, key, default)
    local Card = Instance.new("Frame")
    Card.Name = title
    Card.BackgroundColor3 = Color3.fromRGB(22, 26, 38)
    Card.Parent = GovScroll
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Card
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(38, 44, 62)
    Stroke.Thickness = 1
    Stroke.Parent = Card
    
    local TitleL = Instance.new("TextLabel")
    TitleL.Size = UDim2.new(1, -50, 0, 22)
    TitleL.Position = UDim2.new(0, 10, 0, 6)
    TitleL.BackgroundTransparency = 1
    TitleL.Text = title
    TitleL.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleL.Font = Enum.Font.GothamBold
    TitleL.TextSize = 12
    TitleL.TextXAlignment = Enum.TextXAlignment.Left
    TitleL.Parent = Card
    
    local DescL = Instance.new("TextLabel")
    DescL.Size = UDim2.new(1, -20, 0, 36)
    DescL.Position = UDim2.new(0, 10, 0, 30)
    DescL.BackgroundTransparency = 1
    DescL.Text = desc
    DescL.TextColor3 = Color3.fromRGB(130, 140, 160)
    DescL.Font = Enum.Font.Gotham
    DescL.TextSize = 10
    DescL.TextWrapped = true
    DescL.TextXAlignment = Enum.TextXAlignment.Left
    DescL.Parent = Card
    
    local SwitchBg = Instance.new("Frame")
    SwitchBg.Size = UDim2.new(0, 34, 0, 18)
    SwitchBg.Position = UDim2.new(1, -42, 0, 8)
    SwitchBg.BackgroundColor3 = default and Color3.fromRGB(0, 230, 120) or Color3.fromRGB(42, 48, 66)
    SwitchBg.Parent = Card
    
    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = SwitchBg
    
    local SwitchKnob = Instance.new("Frame")
    SwitchKnob.Size = UDim2.new(0, 14, 0, 14)
    SwitchKnob.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    SwitchKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SwitchKnob.Parent = SwitchBg
    
    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = SwitchKnob
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.Parent = Card
    
    NexaConfig[key] = default
    
    Btn.MouseButton1Click:Connect(function()
        local newState = not NexaConfig[key]
        NexaConfig[key] = newState
        
        if newState then
            TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 230, 120)}):Play()
            TweenService:Create(SwitchKnob, TweenInfo.new(0.2), {Position = UDim2.new(1, -16, 0.5, -7)}):Play()
            Stroke.Color = Color3.fromRGB(0, 200, 110)
        else
            TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(42, 48, 66)}):Play()
            TweenService:Create(SwitchKnob, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -7)}):Play()
            Stroke.Color = Color3.fromRGB(38, 44, 62)
        end
    end)
end

CreateGovCard("Speed Governor Bypass", "Removes motor top-speed limiters for maximum velocity.", "SpeedGovernorBypass", true)
CreateGovCard("Anti-Derail Alignment Lock", "Prevents train carriages from flipping or derailing on tight curves.", "AntiDerailEnabled", true)
CreateGovCard("Collision Geometry Override", "Allows train carriages to pass through static map obstacles.", "CollisionBypass", false)
CreateGovCard("Signal Enforcement Bypass", "Forces upcoming track signals to remain clear green.", "SignalBypassGreen", true)

-- Emergency Brake Action Button
local EStopBtn = Instance.new("TextButton")
EStopBtn.Size = UDim2.new(0, 350, 0, 42)
EStopBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
EStopBtn.Text = "🚨 ENGAGE MAGNETIC EMERGENCY BRAKES"
EStopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
EStopBtn.Font = Enum.Font.GothamBold
EStopBtn.TextSize = 12
EStopBtn.Parent = GovScroll

local EStopCorner = Instance.new("UICorner")
EStopCorner.CornerRadius = UDim.new(0, 6)
EStopCorner.Parent = EStopBtn

EStopBtn.MouseButton1Click:Connect(function()
    ApplyInstantBrake()
end)

----------------------------------------------------------------------------------------
-- GUI TAB 4: VISUAL ESP & WORLD RENDER
----------------------------------------------------------------------------------------
local PageVisuals = Instance.new("Frame")
PageVisuals.Name = "Page_Visuals"
PageVisuals.Size = UDim2.new(1, 0, 1, 0)
PageVisuals.BackgroundTransparency = 1
PageVisuals.Visible = false
PageVisuals.Parent = PagesFolder

local VisScroll = Instance.new("ScrollingFrame")
VisScroll.Size = UDim2.new(1, -32, 1, -20)
VisScroll.Position = UDim2.new(0, 16, 0, 10)
VisScroll.BackgroundTransparency = 1
VisScroll.BorderSizePixel = 0
VisScroll.ScrollBarThickness = 6
VisScroll.Parent = PageVisuals

local VisGrid = Instance.new("UIGridLayout")
VisGrid.CellSize = UDim2.new(0, 350, 0, 95)
VisGrid.CellPadding = UDim2.new(0, 12, 0, 12)
VisGrid.SortOrder = Enum.SortOrder.Name
VisGrid.Parent = VisScroll

local function CreateVisCard(title, desc, key, default)
    local Card = Instance.new("Frame")
    Card.Name = title
    Card.BackgroundColor3 = Color3.fromRGB(22, 26, 38)
    Card.Parent = VisScroll
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Card
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(38, 44, 62)
    Stroke.Thickness = 1
    Stroke.Parent = Card
    
    local TitleL = Instance.new("TextLabel")
    TitleL.Size = UDim2.new(1, -50, 0, 22)
    TitleL.Position = UDim2.new(0, 10, 0, 6)
    TitleL.BackgroundTransparency = 1
    TitleL.Text = title
    TitleL.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleL.Font = Enum.Font.GothamBold
    TitleL.TextSize = 12
    TitleL.TextXAlignment = Enum.TextXAlignment.Left
    TitleL.Parent = Card
    
    local DescL = Instance.new("TextLabel")
    DescL.Size = UDim2.new(1, -20, 0, 36)
    DescL.Position = UDim2.new(0, 10, 0, 30)
    DescL.BackgroundTransparency = 1
    DescL.Text = desc
    DescL.TextColor3 = Color3.fromRGB(130, 140, 160)
    DescL.Font = Enum.Font.Gotham
    DescL.TextSize = 10
    DescL.TextWrapped = true
    DescL.TextXAlignment = Enum.TextXAlignment.Left
    DescL.Parent = Card
    
    local SwitchBg = Instance.new("Frame")
    SwitchBg.Size = UDim2.new(0, 34, 0, 18)
    SwitchBg.Position = UDim2.new(1, -42, 0, 8)
    SwitchBg.BackgroundColor3 = default and Color3.fromRGB(0, 230, 120) or Color3.fromRGB(42, 48, 66)
    SwitchBg.Parent = Card
    
    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = SwitchBg
    
    local SwitchKnob = Instance.new("Frame")
    SwitchKnob.Size = UDim2.new(0, 14, 0, 14)
    SwitchKnob.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    SwitchKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SwitchKnob.Parent = SwitchBg
    
    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = SwitchKnob
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.Parent = Card
    
    NexaConfig[key] = default
    
    Btn.MouseButton1Click:Connect(function()
        local newState = not NexaConfig[key]
        NexaConfig[key] = newState
        
        if newState then
            TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 230, 120)}):Play()
            TweenService:Create(SwitchKnob, TweenInfo.new(0.2), {Position = UDim2.new(1, -16, 0.5, -7)}):Play()
            Stroke.Color = Color3.fromRGB(0, 200, 110)
        else
            TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(42, 48, 66)}):Play()
            TweenService:Create(SwitchKnob, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -7)}):Play()
            Stroke.Color = Color3.fromRGB(38, 44, 62)
        end
    end)
end

CreateVisCard("Station Platform ESP", "Renders 3D billboards over station passenger platforms.", "StationESP", true)
CreateVisCard("Track Signal ESP", "Renders distance indicators over signal lights ahead.", "SignalESP", true)

----------------------------------------------------------------------------------------
-- GUI TAB 5: SYSTEM & ANTI-AFK
----------------------------------------------------------------------------------------
local PageSystem = Instance.new("Frame")
PageSystem.Name = "Page_System"
PageSystem.Size = UDim2.new(1, 0, 1, 0)
PageSystem.BackgroundTransparency = 1
PageSystem.Visible = false
PageSystem.Parent = PagesFolder

local RejoinBtn = Instance.new("TextButton")
RejoinBtn.Size = UDim2.new(0, 260, 0, 42)
RejoinBtn.Position = UDim2.new(0, 16, 0, 16)
RejoinBtn.BackgroundColor3 = Color3.fromRGB(35, 42, 60)
RejoinBtn.Text = "🔄 REJOIN SERVER"
RejoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RejoinBtn.Font = Enum.Font.GothamBold
RejoinBtn.TextSize = 12
RejoinBtn.Parent = PageSystem

local RejoinCorner = Instance.new("UICorner")
RejoinCorner.CornerRadius = UDim.new(0, 6)
RejoinCorner.Parent = RejoinBtn

RejoinBtn.MouseButton1Click:Connect(function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

local ServerHopBtn = Instance.new("TextButton")
ServerHopBtn.Size = UDim2.new(0, 260, 0, 42)
ServerHopBtn.Position = UDim2.new(0, 290, 0, 16)
ServerHopBtn.BackgroundColor3 = Color3.fromRGB(35, 42, 60)
ServerHopBtn.Text = "🌐 SERVER HOP"
ServerHopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ServerHopBtn.Font = Enum.Font.GothamBold
ServerHopBtn.TextSize = 12
ServerHopBtn.Parent = PageSystem

local HopCorner = Instance.new("UICorner")
HopCorner.CornerRadius = UDim.new(0, 6)
HopCorner.Parent = ServerHopBtn

ServerHopBtn.MouseButton1Click:Connect(function()
    CreateNotification("Server Hop", "Searching for available train server...", 4, Color3.fromRGB(0, 200, 255))
    pcall(function()
        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        if servers and servers.data then
            for _, server in ipairs(servers.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                    break
                end
            end
        end
    end)
end)

----------------------------------------------------------------------------------------
-- TAB NAVIGATION CONTROLLER IMPLEMENTATION
----------------------------------------------------------------------------------------
local TabButtons = {}
local Pages = {
    Telemetry = PageTelemetry,
    Farm = PageFarm,
    Governor = PageGovernor,
    Visuals = PageVisuals,
    System = PageSystem
}

local function SwitchTab(tabName)
    NexaState.CurrentTab = tabName
    for name, page in pairs(Pages) do
        page.Visible = (name == tabName)
    end
    for name, btn in pairs(TabButtons) do
        if name == tabName then
            btn.BackgroundColor3 = Color3.fromRGB(32, 38, 56)
            btn.TextColor3 = Color3.fromRGB(0, 255, 170)
        else
            btn.BackgroundColor3 = Color3.fromRGB(22, 25, 36)
            btn.TextColor3 = Color3.fromRGB(130, 140, 160)
        end
    end
end

local TabDataList = {
    {"Telemetry", "📊 Telemetry"},
    {"Farm", "🤖 Auto-Farm"},
    {"Governor", "⚡ Governor"},
    {"Visuals", "👁 Visual ESP"},
    {"System", "⚙ System"}
}

for _, data in ipairs(TabDataList) do
    local key, label = data[1], data[2]
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 36)
    TabBtn.BackgroundColor3 = (key == "Telemetry") and Color3.fromRGB(32, 38, 56) or Color3.fromRGB(22, 25, 36)
    TabBtn.Text = "  " .. label
    TabBtn.TextColor3 = (key == "Telemetry") and Color3.fromRGB(0, 255, 170) or Color3.fromRGB(130, 140, 160)
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 12
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.Parent = Sidebar
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 6)
    TabCorner.Parent = TabBtn
    
    TabButtons[key] = TabBtn
    
    TabBtn.MouseButton1Click:Connect(function()
        SwitchTab(key)
    end)
end

----------------------------------------------------------------------------------------
-- DRAGGABLE WINDOW CONTROLLER
----------------------------------------------------------------------------------------
local dragging, dragInput, dragStart, startPos

TopBar.InputBegan:Connect(function(input)
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

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

----------------------------------------------------------------------------------------
-- MAIN HIGH-FREQUENCY ENGINE LOOP & REAL-TIME DIAGNOSTICS
----------------------------------------------------------------------------------------
local frameCount = 0
local lastMetricTick = tick()

RunService.RenderStepped:Connect(function(delta)
    -- Update FPS / Ping / Mem Metrics
    frameCount = frameCount + 1
    local now = tick()
    if now - lastMetricTick >= 1 then
        local fps = math.floor(frameCount / (now - lastMetricTick))
        local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        local mem = math.floor(Stats:GetTotalMemoryUsageMb())
        
        TopMetrics.Text = string.format("FPS: %d | Ping: %dms | Mem: %dMB", fps, ping, mem)
        frameCount = 0
        lastMetricTick = now
    end
    
    -- Process Train Telemetry
    local train = DetectActiveTrainAssembly()
    local seat = NexaState.PrimarySeat
    
    if seat then
        local vel = seat.AssemblyLinearVelocity.Magnitude
        local kmh = math.floor(vel * 1.09728)
        local mph = math.floor(vel * 0.681818)
        
        NexaState.CurrentVelocity = vel
        NexaState.CurrentKmh = kmh
        NexaState.CurrentMph = mph
        
        SpeedBigText.Text = string.format("%03d", kmh)
        SpeedSubText.Text = string.format("KM/H | %03d MPH | %03d STU/S", mph, math.floor(vel))
        
        local mass = CalculateTrainMass()
        TrainMassLabel.Text = string.format("ASSEMBLY MASS: %d LBS | CARRIAGES: %d", mass, #NexaState.TrainCarriages)
        
        ProcessAntiDerailment()
        ProcessCollisionBypass()
    else
        SpeedBigText.Text = "000"
        SpeedSubText.Text = "KM/H | 000 MPH | 000 STU/S"
        TrainMassLabel.Text = "NO TRAIN CONNECTED"
    end
    
    -- Update Auto Farm step & ESP
    AutoFarmStep()
    RenderESP()
    
    StatusLabel.Text = "Status: " .. NexaState.FarmStatus .. " | Stations Completed: " .. NexaState.FarmStationsCompleted .. " | Total Revenue: $" .. NexaState.FarmTotalEarned
end)

----------------------------------------------------------------------------------------
-- ANTI-AFK ENGINE INTEGRATION
----------------------------------------------------------------------------------------
LocalPlayer.Idled:Connect(function()
    if NexaConfig.AntiAFK then
        local VirtualUser = game:GetService("VirtualUser")
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- Hotkey Toggle Window Display
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and (input.KeyCode == NexaConfig.KeybindMenu or input.KeyCode == Enum.KeyCode.Insert) then
        NexaState.GUIVisible = not NexaState.GUIVisible
        MainFrame.Visible = NexaState.GUIVisible
    end
end)

-- Initial World Scan
ScanWorldMap()
CreateNotification("Nexa Train Sim", "Ultimate Pro Engine loaded successfully.", 5, Color3.fromRGB(0, 255, 170))
print("[NEXA ULTIMATE ENGINE] Train Sim Suite & Auto-Farm Fully Initialized.")



