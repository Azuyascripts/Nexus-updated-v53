-- =================================================================
-- NEXUS ENGINE v5.3 | MMV SINGLE SHERIFF + STRICT ROLE FIX 🛸
-- =================================================================
if _G.NexusEngineRunning then _G.NexusEngineRunning = false task.wait(0.2) end
_G.NexusEngineRunning = true

local coreGui = pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui") or game.Players.LocalPlayer:WaitForChild("PlayerGui")
for _, ui in ipairs(coreGui:GetChildren()) do
    if ui.Name == "NEXUSFloatingUI" or ui.Name == "NEXUS_CosmicIntro" then ui:Destroy() end
end

-- =================================================================
-- SERVICES & GLOBALS
-- =================================================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local lp = Players.LocalPlayer

_G.LockAll = false
_G.ESPEnabled = false
_G.DesiredSpeed = 16
_G.DesiredJump = 50
_G.SafeAutoFarm = false
_G.TargetPart = "HumanoidRootPart"
_G.SelectedPlatform = "Unknown"

local lastShoot, lastThrow = 0, 0
local NexusGreen = Color3.fromRGB(0, 255, 65)

local gunWasOnGround = false
local currentRoundSheriff = nil

-- Reset round state on countdown
task.spawn(function()
    local lastTimerText = ""
    while _G.NexusEngineRunning do
        pcall(function()
            local t = workspace:FindFirstChild("RoundTimerPart", true)
            if t and t.SurfaceGui and t.SurfaceGui.Timer then
                local currentText = t.SurfaceGui.Timer.Text
                if currentText ~= lastTimerText then
                    if string.find(string.lower(currentText), "10") or string.find(string.lower(currentText), "map") or string.find(string.lower(currentText), "voting") then
                        gunWasOnGround = false
                        currentRoundSheriff = nil -- Reset Sheriff lock for new round
                    end
                    lastTimerText = currentText
                end
            end
        end)
        task.wait(1)
    end
end)

-- =================================================================
-- FULLSCREEN COSMIC SPACE INTRO & DEVICE SELECTOR
-- =================================================================
local IntroGui = Instance.new("ScreenGui", coreGui)
IntroGui.Name = "NEXUS_CosmicIntro"
IntroGui.ResetOnSpawn = false

local SpaceBg = Instance.new("Frame", IntroGui)
SpaceBg.Size = UDim2.new(1, 0, 1, 0)
SpaceBg.BackgroundColor3 = Color3.fromRGB(3, 5, 10)
SpaceBg.BackgroundTransparency = 0.15

for i = 1, 40 do
    local star = Instance.new("Frame", SpaceBg)
    local sz = math.random(1, 3)
    star.Size = UDim2.new(0, sz, 0, sz)
    star.Position = UDim2.new(math.random(), 0, math.random(), 0)
    star.BackgroundColor3 = Color3.fromRGB(220, 255, 230)
    star.BorderSizePixel = 0
    
    task.spawn(function()
        while IntroGui.Parent do
            TweenService:Create(star, TweenInfo.new(math.random(1, 3)), {BackgroundTransparency = math.random(0, 8)/10}):Play()
            task.wait(math.random(1, 3))
        end
    end)
end

local Sun = Instance.new("Frame", SpaceBg)
Sun.Size = UDim2.new(0, 90, 0, 90)
Sun.Position = UDim2.new(0.12, 0, 0.15, 0)
Sun.BackgroundColor3 = Color3.fromRGB(255, 210, 80)
Instance.new("UICorner", Sun).CornerRadius = UDim.new(1, 0)
local SunGlow = Instance.new("UIStroke", Sun)
SunGlow.Color = Color3.fromRGB(255, 170, 0)
SunGlow.Thickness = 4

local Earth = Instance.new("Frame", SpaceBg)
Earth.Size = UDim2.new(0, 65, 0, 65)
Earth.Position = UDim2.new(0.78, 0, 0.65, 0)
Earth.BackgroundColor3 = Color3.fromRGB(40, 120, 220)
Instance.new("UICorner", Earth).CornerRadius = UDim.new(1, 0)
local EarthGreen = Instance.new("Frame", Earth)
EarthGreen.Size = UDim2.new(0.4, 0, 0.5, 0)
EarthGreen.Position = UDim2.new(0.3, 0, 0.2, 0)
EarthGreen.BackgroundColor3 = Color3.fromRGB(50, 180, 90)
EarthGreen.BorderSizePixel = 0
Instance.new("UICorner", EarthGreen).CornerRadius = UDim.new(0.5, 0)

local Saturn = Instance.new("Frame", SpaceBg)
Saturn.Size = UDim2.new(0, 75, 0, 75)
Saturn.Position = UDim2.new(0.8, 0, 0.18, 0)
Saturn.BackgroundColor3 = Color3.fromRGB(210, 170, 110)
Instance.new("UICorner", Saturn).CornerRadius = UDim.new(1, 0)

local Ring = Instance.new("Frame", Saturn)
Ring.Size = UDim2.new(1.8, 0, 0.25, 0)
Ring.Position = UDim2.new(-0.4, 0, 0.38, 0)
Ring.BackgroundColor3 = Color3.fromRGB(180, 140, 90)
Ring.BackgroundTransparency = 0.3
Ring.Rotation = -20
Instance.new("UICorner", Ring).CornerRadius = UDim.new(1, 0)

local IntroFrame = Instance.new("Frame", SpaceBg)
IntroFrame.Size = UDim2.new(0, 360, 0, 140)
IntroFrame.Position = UDim2.new(0.5, -180, 0.5, -70)
IntroFrame.BackgroundColor3 = Color3.fromRGB(5, 15, 5)
IntroFrame.BackgroundTransparency = 0.2

local IntroStroke = Instance.new("UIStroke", IntroFrame)
IntroStroke.Thickness = 2
IntroStroke.Color = NexusGreen

local IntroText = Instance.new("TextLabel", IntroFrame)
IntroText.Size = UDim2.new(1, -20, 1, -20)
IntroText.Position = UDim2.new(0, 10, 0, 10)
IntroText.BackgroundTransparency = 1
IntroText.TextColor3 = NexusGreen
IntroText.Font = Enum.Font.Code
IntroText.TextSize = 13
IntroText.TextXAlignment = Enum.TextXAlignment.Left
IntroText.TextYAlignment = Enum.TextYAlignment.Top
IntroText.TextWrapped = true

local function finishIntro()
    task.spawn(function()
        for i = 0, 1, 0.08 do
            SpaceBg.BackgroundTransparency = 0.15 + (i * 0.85)
            IntroFrame.BackgroundTransparency = 0.2 + (i * 0.8)
            Sun.BackgroundTransparency = i
            Earth.BackgroundTransparency = i
            Saturn.BackgroundTransparency = i
            Ring.BackgroundTransparency = i
            task.wait(0.02)
        end
        IntroGui:Destroy()
    end)
end

task.spawn(function()
    local text = ">> COSMIC NEXUS ENGINE 5.3.\n>> MMV SINGLE SHERIFF ENGINE ONLINE...\n>> READY FOR PLATFORM SELECTION."
    for i = 1, #text do
        IntroText.Text = string.sub(text, 1, i) .. "_"
        task.wait(0.015)
    end
    task.wait(0.4)
    
    IntroText.Visible = false
    
    local SelectTitle = Instance.new("TextLabel", IntroFrame)
    SelectTitle.Size = UDim2.new(1, 0, 0, 30)
    SelectTitle.Position = UDim2.new(0, 0, 0, 15)
    SelectTitle.BackgroundTransparency = 1
    SelectTitle.TextColor3 = NexusGreen
    SelectTitle.Font = Enum.Font.Code
    SelectTitle.TextSize = 13
    SelectTitle.Text = "SELECT YOUR PLATFORM:"
    SelectTitle.TextXAlignment = Enum.TextXAlignment.Center

    local function makePlatformBtn(name, posY, callback)
        local b = Instance.new("TextButton", IntroFrame)
        b.Size = UDim2.new(0.8, 0, 0, 35)
        b.Position = UDim2.new(0.1, 0, 0, posY)
        b.BackgroundColor3 = Color3.fromRGB(10, 30, 10)
        b.TextColor3 = NexusGreen
        b.Font = Enum.Font.Code
        b.TextSize = 12
        b.Text = name
        Instance.new("UIStroke", b).Color = NexusGreen
        b.Activated:Connect(callback)
    end

    makePlatformBtn("💻 PC (KEYBOARD / MOUSE)", 55, function()
        _G.SelectedPlatform = "PC"
        finishIntro()
    end)

    makePlatformBtn("📱 MOBILE / TABLET (HUD)", 95, function()
        _G.SelectedPlatform = "Mobile"
        finishIntro()
    end)
end)

-- =================================================================
-- MAIN NATIVE MATRIX GUI
-- =================================================================
local ScreenGui = Instance.new("ScreenGui", coreGui)
ScreenGui.Name = "NEXUSFloatingUI"
ScreenGui.ResetOnSpawn = false

-- Timer HUD
local TimerBox = Instance.new("Frame", ScreenGui)
TimerBox.Size = UDim2.new(0, 120, 0, 30)
TimerBox.Position = UDim2.new(0.5, -60, 0, 10)
TimerBox.BackgroundColor3 = Color3.fromRGB(5, 15, 5)
Instance.new("UIStroke", TimerBox).Color = NexusGreen

local TimerText = Instance.new("TextLabel", TimerBox)
TimerText.Size = UDim2.new(1, 0, 1, 0)
TimerText.BackgroundTransparency = 1
TimerText.TextColor3 = NexusGreen
TimerText.Font = Enum.Font.Code
TimerText.TextSize = 12
TimerText.Text = "TIME: --:--"

-- Main Native Matrix Menu Frame
local MainMenu = Instance.new("Frame", ScreenGui)
MainMenu.Size = UDim2.new(0, 240, 0, 265)
MainMenu.Position = UDim2.new(0, 20, 0.3, 0)
MainMenu.BackgroundColor3 = Color3.fromRGB(5, 15, 5)
MainMenu.BackgroundTransparency = 0.2
Instance.new("UIStroke", MainMenu).Color = NexusGreen

local MenuTitle = Instance.new("TextLabel", MainMenu)
MenuTitle.Size = UDim2.new(1, -70, 0, 25)
MenuTitle.BackgroundColor3 = Color3.fromRGB(10, 30, 10)
MenuTitle.Text = "  NEXUS MATRIX v5.3"
MenuTitle.TextColor3 = NexusGreen
MenuTitle.Font = Enum.Font.Code
MenuTitle.TextSize = 11
MenuTitle.TextXAlignment = Enum.TextXAlignment.Left

local ContentContainer = Instance.new("Frame", MainMenu)
ContentContainer.Size = UDim2.new(1, 0, 1, -25)
ContentContainer.Position = UDim2.new(0, 0, 0, 25)
ContentContainer.BackgroundTransparency = 1

local MinBtn = Instance.new("TextButton", MainMenu)
MinBtn.Size = UDim2.new(0, 25, 0, 25)
MinBtn.Position = UDim2.new(1, -50, 0, 0)
MinBtn.BackgroundColor3 = Color3.fromRGB(20, 50, 20)
MinBtn.Text = "-"
MinBtn.TextColor3 = NexusGreen
MinBtn.Font = Enum.Font.Code
MinBtn.TextSize = 14

local CloseBtn = Instance.new("TextButton", MainMenu)
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -25, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(60, 15, 15)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.Font = Enum.Font.Code
CloseBtn.TextSize = 11

CloseBtn.Activated:Connect(function()
    _G.NexusEngineRunning = false
    ScreenGui:Destroy()
end)

local SpaceshipBtn = Instance.new("TextButton", ScreenGui)
SpaceshipBtn.Size = UDim2.new(0, 45, 0, 45)
SpaceshipBtn.Position = UDim2.new(0, 20, 0.3, 0)
SpaceshipBtn.BackgroundColor3 = Color3.fromRGB(5, 15, 5)
SpaceshipBtn.Text = "🛸"
SpaceshipBtn.TextSize = 22
SpaceshipBtn.Visible = false
Instance.new("UICorner", SpaceshipBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", SpaceshipBtn).Color = NexusGreen

local isMinimized = false
MinBtn.Activated:Connect(function()
    isMinimized = not isMinimized
    ContentContainer.Visible = not isMinimized
    if isMinimized then
        MainMenu.Size = UDim2.new(0, 240, 0, 25)
        SpaceshipBtn.Position = MainMenu.Position
        SpaceshipBtn.Visible = true
        MainMenu.Visible = false
    end
end)

SpaceshipBtn.Activated:Connect(function()
    isMinimized = false
    MainMenu.Size = UDim2.new(0, 240, 0, 265)
    MainMenu.Visible = true
    ContentContainer.Visible = true
    SpaceshipBtn.Visible = false
end)

local function createToggleBtn(parent, text, pos, defaultState, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.9, 0, 0, 28)
    btn.Position = pos
    btn.BackgroundColor3 = defaultState and Color3.fromRGB(15, 60, 15) or Color3.fromRGB(10, 20, 10)
    btn.Text = text .. ": " .. (defaultState and "ON" or "OFF")
    btn.TextColor3 = NexusGreen
    btn.Font = Enum.Font.Code
    btn.TextSize = 11
    Instance.new("UIStroke", btn).Color = NexusGreen
    
    local state = defaultState
    btn.Activated:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(15, 60, 15) or Color3.fromRGB(10, 20, 10)
        btn.Text = text .. ": " .. (state and "ON" or "OFF")
        callback(state)
    end)
    return btn
end

local function createBtn(name, text, pos, size)
    local btn = Instance.new("TextButton", ScreenGui)
    btn.Name = name
    btn.Visible = true
    btn.Size = size
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(5, 15, 5)
    btn.Text = text
    btn.TextColor3 = NexusGreen
    btn.Font = Enum.Font.Code
    btn.TextSize = 11
    Instance.new("UIStroke", btn).Color = NexusGreen
    return btn
end

local ShootBtn = createBtn("ShootBtn", "SHOOT FLICK", UDim2.new(1, -190, 1, -180), UDim2.new(0, 130, 0, 40))
local ThrowBtn = createBtn("ThrowBtn", "THROW FLICK", UDim2.new(1, -195, 1, -100), UDim2.new(0, 60, 0, 60))

createToggleBtn(ContentContainer, "ESP & ROLES", UDim2.new(0.05, 0, 0.05, 0), false, function(v) _G.ESPEnabled = v end)
createToggleBtn(ContentContainer, "SAFE COIN FARM", UDim2.new(0.05, 0, 0.20, 0), false, function(v) _G.SafeAutoFarm = v end)
createToggleBtn(ContentContainer, "LOCK BUTTONS", UDim2.new(0.05, 0, 0.35, 0), false, function(v) _G.LockAll = v end)

local TargetBtn = Instance.new("TextButton", ContentContainer)
TargetBtn.Size = UDim2.new(0.9, 0, 0, 28)
TargetBtn.Position = UDim2.new(0.05, 0, 0.50, 0)
TargetBtn.BackgroundColor3 = Color3.fromRGB(10, 20, 10)
TargetBtn.Text = "TARGET: RootPart"
TargetBtn.TextColor3 = NexusGreen
TargetBtn.Font = Enum.Font.Code
TargetBtn.TextSize = 11
Instance.new("UIStroke", TargetBtn).Color = NexusGreen

local parts = {"HumanoidRootPart", "Head", "LeftUpperArm", "RightUpperArm"}
local partIdx = 1
TargetBtn.Activated:Connect(function()
    partIdx = (partIdx % #parts) + 1
    _G.TargetPart = parts[partIdx]
    TargetBtn.Text = "TARGET: " .. (parts[partIdx] == "HumanoidRootPart" and "RootPart" or parts[partIdx])
end)

local RoadmapBtn = Instance.new("TextButton", ContentContainer)
RoadmapBtn.Size = UDim2.new(0.9, 0, 0, 28)
RoadmapBtn.Position = UDim2.new(0.05, 0, 0.65, 0)
RoadmapBtn.BackgroundColor3 = Color3.fromRGB(15, 30, 45)
RoadmapBtn.Text = "⚡ DELAYED ROADMAP"
RoadmapBtn.TextColor3 = Color3.fromRGB(100, 200, 255)
RoadmapBtn.Font = Enum.Font.Code
RoadmapBtn.TextSize = 11
Instance.new("UIStroke", RoadmapBtn).Color = Color3.fromRGB(100, 200, 255)

RoadmapBtn.Activated:Connect(function()
    if ScreenGui:FindFirstChild("RoadmapPopup") then return end
    local popup = Instance.new("Frame", ScreenGui)
    popup.Name = "RoadmapPopup"
    popup.Size = UDim2.new(0, 230, 0, 135)
    popup.Position = UDim2.new(0.5, -115, 0.35, 0)
    popup.BackgroundColor3 = Color3.fromRGB(5, 15, 5)
    Instance.new("UIStroke", popup).Color = NexusGreen
    
    local title = Instance.new("TextLabel", popup)
    title.Size = UDim2.new(1, -25, 0, 25)
    title.BackgroundColor3 = Color3.fromRGB(10, 30, 10)
    title.Text = "  PLANNED DELAYED FEATURES"
    title.TextColor3 = NexusGreen
    title.Font = Enum.Font.Code
    title.TextSize = 10
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local pClose = Instance.new("TextButton", popup)
    pClose.Size = UDim2.new(0, 25, 0, 25)
    pClose.Position = UDim2.new(1, -25, 0, 0)
    pClose.BackgroundColor3 = Color3.fromRGB(60, 15, 15)
    pClose.Text = "X"
    pClose.TextColor3 = Color3.fromRGB(255, 100, 100)
    pClose.Font = Enum.Font.Code
    pClose.TextSize = 11
    pClose.Activated:Connect(function() popup:Destroy() end)
    
    local body = Instance.new("TextLabel", popup)
    body.Size = UDim2.new(1, -10, 1, -30)
    body.Position = UDim2.new(0, 5, 0, 28)
    body.BackgroundTransparency = 1
    body.Text = "• Silent Aim Wall Check [WIP]\n• Auto Gun Pick Up [Retired]\n• Auto Deflect Logic [In Test]\n• Target ESP Prediction [V5]"
    body.TextColor3 = NexusGreen
    body.Font = Enum.Font.Code
    body.TextSize = 10
    body.TextXAlignment = Enum.TextXAlignment.Left
    body.TextYAlignment = Enum.TextYAlignment.Top
    
    task.delay(5, function() if popup.Parent then popup:Destroy() end end)
end)

local function makeDraggable(btn, lockCheck)
    local dragging, dragStart, startPos = false, nil, nil
    btn.InputBegan:Connect(function(input)
        if lockCheck and _G.LockAll then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, input.Position, btn.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if lockCheck and _G.LockAll then dragging = false return end
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

makeDraggable(MainMenu, false)
makeDraggable(SpaceshipBtn, false)
makeDraggable(ShootBtn, true)
makeDraggable(ThrowBtn, true)

-- =================================================================
-- UNIVERSAL MMV TOOL FINDER
-- =================================================================
local function getToolFromPlayer(player, toolType)
    if not player or not player.Character then return nil end
    local char = player.Character
    local backpack = player:FindFirstChild("Backpack")
    
    local function matchTool(container)
        if not container then return nil end
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") then
                local n = string.lower(item.Name)
                if toolType == "Gun" and (string.find(n, "gun") or string.find(n, "revolver") or string.find(n, "pistol")) then
                    return item
                elseif toolType == "Knife" and (string.find(n, "knife") or string.find(n, "blade") or string.find(n, "dagger") or string.find(n, "scythe") or string.find(n, "sword")) then
                    return item
                end
            end
        end
        return nil
    end

    return matchTool(char) or matchTool(backpack) or (toolType == "Gun" and (char:FindFirstChild("Gun") or (backpack and backpack:FindFirstChild("Gun")))) or (toolType == "Knife" and (char:FindFirstChild("Knife") or (backpack and backpack:FindFirstChild("Knife"))))
end

local function getMurderer()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if getToolFromPlayer(p, "Knife") then return p end
        end
    end
    return nil
end

local function instantLightningFlick(targetPos, actionCallback)
    Camera.CameraType = Enum.CameraType.Scriptable
    local originalCFrame = Camera.CFrame
    
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
    RunService.RenderStepped:Wait()
    
    if actionCallback then actionCallback() end
    RunService.RenderStepped:Wait()
    
    Camera.CameraType = Enum.CameraType.Custom
end

ShootBtn.Activated:Connect(function()
    if _G.LockAll then return end
    if tick() - lastShoot < 0.8 then return end
    lastShoot = tick()
    
    local char = lp.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    local gun = getToolFromPlayer(lp, "Gun")
    local murd = getMurderer()
    
    if gun and murd and murd.Character then
        local targetPart = murd.Character:FindFirstChild(_G.TargetPart) or murd.Character:FindFirstChild("HumanoidRootPart")
        if targetPart then
            if gun.Parent ~= char then
                humanoid:EquipTool(gun)
                task.wait(0.05)
            end
            
            local targetPos = targetPart.Position + (targetPart.AssemblyLinearVelocity * 0.125)
            
            instantLightningFlick(targetPos, function()
                gun:Activate()
                local remote = gun:FindFirstChild("Shoot") or gun:FindFirstChild("ShootGun") or ReplicatedStorage:FindFirstChild("ShootGun", true)
                if remote then
                    remote:FireServer(CFrame.lookAt(char.HumanoidRootPart.Position, targetPos), CFrame.new(targetPos))
                end
            end)
            
            task.delay(0.2, function()
                if gun and gun.Parent == char and lp:FindFirstChild("Backpack") then
                    gun.Parent = lp.Backpack
                end
            end)
        end
    end
end)

ThrowBtn.Activated:Connect(function()
    if _G.LockAll then return end
    if tick() - lastThrow < 0.8 then return end
    lastThrow = tick()
    
    local char = lp.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    local knife = getToolFromPlayer(lp, "Knife")
    if not knife then return end
    
    local near, dist = nil, math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local d = (char.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then dist = d near = v end
        end
    end
    
    if near and near.Character and near.Character:FindFirstChild("HumanoidRootPart") then
        local targetPart = near.Character:FindFirstChild(_G.TargetPart) or near.Character:FindFirstChild("HumanoidRootPart")
        if targetPart then
            if knife.Parent ~= char literary then
                humanoid:EquipTool(knife)
                task.wait(0.05)
            end
            
            local targetPos = targetPart.Position
            instantLightningFlick(targetPos, function()
                knife:Activate()
                local remote = (knife:FindFirstChild("Events") and knife.Events:FindFirstChild("KnifeThrown")) or knife:FindFirstChild("KnifeThrown") or ReplicatedStorage:FindFirstChild("KnifeThrown", true)
                if remote then
                    remote:FireServer({CFrame.new(char.HumanoidRootPart.Position, targetPos) * CFrame.Angles(1.453, 0.044, 1.65), CFrame.new(targetPos)})
                end
            end)
            
            task.delay(0.2, function()
                if knife and knife.Parent == char and lp:FindFirstChild("Backpack") then
                    knife.Parent = lp.Backpack
                end
            end)
        end
    end
end)

-- =================================================================
-- STRICT SINGLE SHERIFF & ACCURATE HERO ROLE ENGINE
-- =================================================================
local function getRoleFromWorkspaceOrReplicated(p)
    local detectedRole = nil
    pcall(function()
        local rolesFolder = workspace:FindFirstChild("Roles", true) 
            or ReplicatedStorage:FindFirstChild("Roles", true)
            or workspace:FindFirstChild("Role", true)
            or ReplicatedStorage:FindFirstChild("Role", true)
            or workspace:FindFirstChild("PlayerData", true)
        
        if rolesFolder then
            local pRoleObj = rolesFolder:FindFirstChild(p.Name) or rolesFolder:FindFirstChild(tostring(p.UserId))
            if pRoleObj then
                if pRoleObj:IsA("StringValue") then
                    detectedRole = pRoleObj.Value
                elseif pRoleObj:FindFirstChild("Role") then
                    detectedRole = pRoleObj.Role.Value
                end
            end
        end
        if not detectedRole then
            detectedRole = p:GetAttribute("Role") or p:GetAttribute("role")
        end
    end)
    return detectedRole
end

local function findDroppedGunInWorkspace()
    for _, child in ipairs(workspace:GetChildren()) do
        local nameLower = string.lower(child.Name)
        if nameLower == "defaultgun" or nameLower == "gundrop" or nameLower == "droppedgun" then
            return child
        end
    end
    return workspace:FindFirstChild("DefaultGun", true) or workspace:FindFirstChild("GunDrop", true) or workspace:FindFirstChild("DroppedGun", true)
end

task.spawn(function()
    while _G.NexusEngineRunning do
        if _G.ESPEnabled then
            -- 1. SEARCH FOR DROPPED GUN
            local droppedGunObj = findDroppedGunInWorkspace()

            if droppedGunObj then
                gunWasOnGround = true
                local adorneePart = droppedGunObj:IsA("Model") and (droppedGunObj.PrimaryPart or droppedGunObj:FindFirstChildOfClass("BasePart")) or droppedGunObj
                if adorneePart and adorneePart:IsA("BasePart") then
                    local gunHl = droppedGunObj:FindFirstChild("NEXUSGunESP") or Instance.new("Highlight")
                    gunHl.Name = "NEXUSGunESP"
                    gunHl.Adornee = droppedGunObj
                    gunHl.Parent = droppedGunObj
                    gunHl.FillColor = Color3.fromRGB(0, 255, 65)
                    gunHl.FillTransparency = 0.4
                    gunHl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    gunHl.OutlineTransparency = 0
                    gunHl.Enabled = true

                    local bill = adorneePart:FindFirstChild("NEXUSGunBill") or Instance.new("BillboardGui", adorneePart)
                    bill.Name = "NEXUSGunBill"
                    bill.Adornee = adorneePart
                    bill.Size = UDim2.new(0, 150, 0, 50)
                    bill.AlwaysOnTop = true
                    bill.ExtentsOffset = Vector3.new(0, 1.8, 0)

                    local lbl = bill:FindFirstChild("TextLabel") or Instance.new("TextLabel", bill)
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.Font = Enum.Font.Code
                    lbl.TextSize = 12
                    lbl.Text = "DROPPED GUN\n▼"
                    lbl.TextColor3 = Color3.fromRGB(0, 255, 65)
                    lbl.TextStrokeTransparency = 0
                    lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    bill.Enabled = true
                end
            end

            -- 2. LOCK SINGLE SHERIFF AT ROUND START
            if not currentRoundSheriff then
                for _, p in ipairs(Players:GetPlayers()) do
                    local sRole = getRoleFromWorkspaceOrReplicated(p)
                    local charTool = p.Character and (p.Character:FindFirstChild("Gun") or p.Character:FindFirstChild("DefaultGun"))
                    if sRole == "Sheriff" or charTool then
                        currentRoundSheriff = p
                        break
                    end
                end
            end

            -- 3. PLAYER ROLE ESP
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= lp and p.Character and p.Character:FindFirstChild("Head") then
                    local char = p.Character
                    local head = char.Head
                    
                    local hl = char:FindFirstChild("NEXUSESP") or Instance.new("Highlight")
                    hl.Name = "NEXUSESP"
                    hl.Adornee = char
                    hl.Parent = char
                    
                    local serverRole = getRoleFromWorkspaceOrReplicated(p)
                    local hasKnife = getToolFromPlayer(p, "Knife") ~= nil
                    local hasEquippedGun = (p.Character and (p.Character:FindFirstChild("Gun") or p.Character:FindFirstChild("DefaultGun"))) ~= nil
                    
                    local isHero = hasEquippedGun and gunWasOnGround and not droppedGunObj and (p ~= currentRoundSheriff)
                    
                    local roleName, roleColor = "INNOCENT", NexusGreen
                    
                    if serverRole == "Murderer" or serverRole == "Murder" or hasKnife then
                        roleName, roleColor = "MURDERER", Color3.fromRGB(255, 0, 0)
                    elseif isHero or serverRole == "Hero" then
                        roleName, roleColor = "HERO", Color3.fromRGB(255, 255, 0)
                    elseif p == currentRoundSheriff or serverRole == "Sheriff" then
                        roleName, roleColor = "SHERIFF", Color3.fromRGB(0, 100, 255)
                    end
                    
                    hl.FillColor = roleColor
                    hl.FillTransparency = 0.4
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.OutlineTransparency = 0
                    hl.Enabled = true

                    local bill = head:FindFirstChild("NEXUSBill") or Instance.new("BillboardGui", head)
                    bill.Name = "NEXUSBill"
                    bill.Adornee = head
                    bill.Size = UDim2.new(0, 150, 0, 50)
                    bill.AlwaysOnTop = true
                    bill.ExtentsOffset = Vector3.new(0, 2.5, 0)

                    local lbl = bill:FindFirstChild("TextLabel") or Instance.new("TextLabel", bill)
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.Font = Enum.Font.Code
                    lbl.TextSize = 12
                    lbl.Text = roleName .. "\n▼"
                    lbl.TextColor3 = roleColor
                    lbl.TextStrokeTransparency = 0
                    lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    bill.Enabled = true
                end
            end
        else
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character then
                    if p.Character:FindFirstChild("NEXUSESP") then p.Character.NEXUSESP.Enabled = false end
                    if p.Character:FindFirstChild("Head") and p.Character.Head:FindFirstChild("NEXUSBill") then
                        p.Character.Head.NEXUSBill.Enabled = false
                    end
                end
            end
        end
        task.wait(0.3)
    end
end)

task.spawn(function()
    while _G.NexusEngineRunning do
        pcall(function()
            local t = workspace:FindFirstChild("RoundTimerPart", true)
            TimerText.Text = "TIME: " .. (t and t.SurfaceGui.Timer.Text or "LOBBY")
        end)
        task.wait(0.5)
    end
end)

task.spawn(function()
    while _G.NexusEngineRunning do
        if _G.SafeAutoFarm then
            local char = lp.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local container = workspace:FindFirstChild("Normal", true) or workspace:FindFirstChild("CoinContainer", true)
                if container then
                    for _, coin in ipairs(container:GetChildren()) do
                        if not _G.SafeAutoFarm or not _G.NexusEngineRunning then break end
                        if coin:IsA("BasePart") and coin.Name == "Coin" then
                            hrp.CFrame = coin.CFrame
                            task.wait(0.35)
                        end
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

RunService.RenderStepped:Connect(function()
    if _G.NexusEngineRunning and lp.Character and lp.Character:FindFirstChild("Humanoid") then
        if _G.DesiredSpeed ~= 16 then lp.Character.Humanoid.WalkSpeed = _G.DesiredSpeed end
        if _G.DesiredJump ~= 50 then lp.Character.Humanoid.JumpPower = _G.DesiredJump end
    end
end)
