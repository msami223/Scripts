-- ==============================================================================
-- STEAL AN EGG - CLIENT DEVELOPER & AUTOMATION HUB
-- Self-contained GUI with Auto-Steal, Speed Bypass, Teleports, & ESP
-- ==============================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Determine GUI parent (CoreGui if permitted, otherwise PlayerGui)
local TargetGuiParent = (pcall(function() return CoreGui.Name end) and CoreGui) or PlayerGui

-- Clean up any existing instance of this hub
if TargetGuiParent:FindFirstChild("StealEggHub") then
    TargetGuiParent.StealEggHub:Destroy()
end

-- ==============================================================================
-- STATE & SETTINGS
-- ==============================================================================
local State = {
    AutoSteal = false,
    AutoDeliver = false,
    SpeedBypass = false,
    SpeedValue = 32,
    InfiniteJump = false,
    NoClip = false,
    EggESP = false,
    AutoTrain = false,
    BaseCFrame = nil,
    NestCFrame = nil,
}

-- Attempt to auto-locate Base or Nest if tagged/named in Workspace
task.spawn(function()
    task.wait(1)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        State.BaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
    end
end)

-- ==============================================================================
-- CREATE MODERN UI
-- ==============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StealEggHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = TargetGuiParent

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 480, 0, 360)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(45, 50, 65)
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

-- Top Bar (Draggable)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(28, 32, 42)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 12)
TopBarCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "STEAL AN EGG // DEV HUB"
Title.TextColor3 = Color3.fromRGB(255, 200, 50)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 44, 55)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseBtn.TextSize = 14
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Make GUI Draggable
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

-- Sidebar Tabs & Content Container
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -20, 1, -55)
ContentFrame.Position = UDim2.new(0, 10, 0, 48)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 4
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 65, 80)
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 480)
ContentFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = ContentFrame

-- Helper Function to Create Toggle Buttons
local function CreateToggle(text, order, defaultState, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 40)
    Frame.BackgroundColor3 = Color3.fromRGB(28, 32, 42)
    Frame.LayoutOrder = order
    Frame.Parent = ContentFrame
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Frame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -80, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamMedium
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 60, 0, 26)
    ToggleBtn.Position = UDim2.new(1, -68, 0.5, -13)
    ToggleBtn.BackgroundColor3 = defaultState and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(60, 65, 80)
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.Text = defaultState and "ON" or "OFF"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.TextSize = 12
    ToggleBtn.Parent = Frame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = ToggleBtn
    
    local currentState = defaultState
    ToggleBtn.MouseButton1Click:Connect(function()
        currentState = not currentState
        ToggleBtn.BackgroundColor3 = currentState and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(60, 65, 80)
        ToggleBtn.Text = currentState and "ON" or "OFF"
        callback(currentState)
    end)
    return Frame
end

-- Helper Function to Create Action Buttons
local function CreateButton(text, order, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 36)
    Button.BackgroundColor3 = Color3.fromRGB(38, 44, 58)
    Button.LayoutOrder = order
    Button.Font = Enum.Font.GothamBold
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 200, 50)
    Button.TextSize = 13
    Button.Parent = ContentFrame
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Button
    
    Button.MouseButton1Click:Connect(callback)
    return Button
end

-- Helper Function to Create Section Headers
local function CreateSection(title, order)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 24)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamBold
    Label.Text = string.upper(title)
    Label.TextColor3 = Color3.fromRGB(130, 140, 160)
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.LayoutOrder = order
    Label.Parent = ContentFrame
end

-- ==============================================================================
-- ADD UI CONTROLS & FEATURES
-- ==============================================================================

CreateSection("🥚 Egg Stealing & Delivery", 1)

CreateToggle("Auto-Steal Nearest Egg", 2, State.AutoSteal, function(val)
    State.AutoSteal = val
end)

CreateToggle("Auto-Deliver to Base", 3, State.AutoDeliver, function(val)
    State.AutoDeliver = val
end)

CreateToggle("Highlight All Eggs (ESP)", 4, State.EggESP, function(val)
    State.EggESP = val
end)

CreateSection("⚡ Movement & Speed Modifiers", 5)

CreateToggle("Speed Carry Bypass (Force Fast Speed)", 6, State.SpeedBypass, function(val)
    State.SpeedBypass = val
end)

CreateToggle("Infinite Jump", 7, State.InfiniteJump, function(val)
    State.InfiniteJump = val
end)

CreateToggle("NoClip (Walk Through Obstacles)", 8, State.NoClip, function(val)
    State.NoClip = val
end)

CreateSection("📍 Teleports & Locations", 9)

CreateButton("📌 Set Current Position as Base Plot", 10, function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        State.BaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
    end
end)

CreateButton("🐔 Set Current Position as Hen Nest", 11, function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        State.NestCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
    end
end)

CreateButton("🚀 Teleport to Nest", 12, function()
    if State.NestCFrame and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = State.NestCFrame + Vector3.new(0, 3, 0)
    end
end)

CreateButton("🏠 Teleport to Base", 13, function()
    if State.BaseCFrame and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = State.BaseCFrame + Vector3.new(0, 3, 0)
    end
end)

-- ==============================================================================
-- FEATURE IMPLEMENTATIONS & LOOPS
-- ==============================================================================

-- 1. SPEED & CARRY WEIGHT BYPASS LOOP
RunService.Stepped:Connect(function()
    if State.SpeedBypass and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = State.SpeedValue
        end
    end
    
    -- NoClip handling
    if State.NoClip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- 2. INFINITE JUMP
UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- 3. AUTO-STEAL & AUTO-DELIVER LOOP
task.spawn(function()
    while true do
        task.wait(0.3)
        pcall(function()
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            local root = char.HumanoidRootPart
            
            -- Check if already carrying an egg (looks for an attached/welded Egg model or Tool)
            local isCarryingEgg = char:FindFirstChild("CarriedEgg") or char:FindFirstChildWhichIsA("Tool")
            
            -- Auto-Deliver
            if State.AutoDeliver and isCarryingEgg and State.BaseCFrame then
                root.CFrame = State.BaseCFrame + Vector3.new(0, 3, 0)
                task.wait(0.5)
            end
            
            -- Auto-Steal: Find nearest ProximityPrompt or Egg in Workspace
            if State.AutoSteal and not isCarryingEgg then
                local nearestPrompt = nil
                local nearestDist = 300
                
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") and (string.find(string.lower(obj.Parent.Name), "egg") or string.find(string.lower(obj.ActionText), "steal") or string.find(string.lower(obj.ActionText), "take")) then
                        local part = obj.Parent:IsA("BasePart") and obj.Parent or obj.Parent:FindFirstChildWhichIsA("BasePart")
                        if part then
                            local dist = (root.Position - part.Position).Magnitude
                            if dist < nearestDist then
                                nearestDist = dist
                                nearestPrompt = obj
                            end
                        end
                    end
                end
                
                if nearestPrompt then
                    local targetPart = nearestPrompt.Parent:IsA("BasePart") and nearestPrompt.Parent or nearestPrompt.Parent:FindFirstChildWhichIsA("BasePart")
                    if targetPart then
                        root.CFrame = targetPart.CFrame + Vector3.new(0, 2, 0)
                        task.wait(0.1)
                        fireproximityprompt(nearestPrompt)
                    end
                end
            end
        end)
    end
end)

-- 4. EGG ESP / HIGHLIGHTER
local activeHighlights = {}
task.spawn(function()
    while true do
        task.wait(1.5)
        if State.EggESP then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") or obj:IsA("BasePart") then
                    if string.find(string.lower(obj.Name), "egg") and not obj:IsDescendantOf(LocalPlayer.Character) then
                        if not activeHighlights[obj] then
                            local highlight = Instance.new("Highlight")
                            highlight.FillColor = Color3.fromRGB(255, 215, 0)
                            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                            highlight.FillTransparency = 0.4
                            highlight.OutlineTransparency = 0
                            highlight.Adornee = obj
                            highlight.Parent = ScreenGui
                            activeHighlights[obj] = highlight
                        end
                    end
                end
            end
        else
            for obj, highlight in pairs(activeHighlights) do
                if highlight then highlight:Destroy() end
            end
            table.clear(activeHighlights)
        end
    end
end)

print("[StealEggHub] Loaded successfully!")
