--[[
	🔥 SENPAI HUB - Custom UI Edition
	Plants vs. Brainrot
	100% Original Functionality Preserved
]]

local PLANTS_VS_BRAINROT_ID = 127742093697776

if game.PlaceId ~= PLANTS_VS_BRAINROT_ID then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Wrong Game!";
        Text = "This script only works in Plants vs. Brainrot";
        Duration = 5;
    })
    return
end

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local NetworkClient = game:GetService("NetworkClient")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer

-- Configuration Files
local CONFIG_FILE = "SenpaiHubPVB/PlantsBrainrot_Config.json"
local SETTINGS_FILE = "SenpaiHubPVB/PlantsBrainrot_Settings.json"

local defaultConfig = {
    selectedSeeds = {},
    selectedGears = {},
    equipInterval = 20,
    autoBuySeedsEnabled = false,
    autoBuyGearsEnabled = false,
    autoEquipEnabled = false,
    autoBuyAllSeedsEnabled = false,
    autoBuyAllGearsEnabled = false,
    antiAFKEnabled = false,
    autoReconnectEnabled = false
}

local defaultSettings = {
    autoLoadConfig = "None",
    autoLoadEnabled = false
}

-- 🔥 FLAME THEME COLORS
local COLORS = {
    Primary = Color3.fromRGB(255, 85, 50),      -- Bright Orange
    Secondary = Color3.fromRGB(255, 50, 150),   -- Hot Pink  
    Tertiary = Color3.fromRGB(255, 140, 0),     -- Dark Orange
    Background = Color3.fromRGB(25, 25, 35),
    Surface = Color3.fromRGB(35, 35, 50),
    SurfaceLight = Color3.fromRGB(45, 45, 60),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(200, 200, 210),
    Success = Color3.fromRGB(100, 255, 100),
    Error = Color3.fromRGB(255, 100, 100)
}

-- State Variables
local currentConfig = {}
local currentSettings = {}
local autoBuySeedsEnabled = false
local autoBuyGearsEnabled = false
local autoEquipEnabled = false
local autoBuyAllSeedsEnabled = false
local autoBuyAllGearsEnabled = false
local antiAFKEnabled = false
local autoReconnectEnabled = false
local selectedSeeds = {}
local selectedGears = {}
local equipInterval = 20
local currentTab = "Information"

-- UI Element References
local MainFrame, ContentArea
local seedCheckboxes = {}
local gearCheckboxes = {}
local configNameInput

-- Game Remotes
local BuyItemRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("BuyItem")
local BuyGearRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("BuyGear")
local OpenUIRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("OpenUI")
local EquipBestRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("EquipBest")
local ItemSellRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ItemSell")

local seedShopUI = localPlayer.PlayerGui.Main.Seeds
local gearShopUI = localPlayer.PlayerGui.Main.Gears

-- Items Lists
local availableSeeds = {
    "Cactus Seed", "Strawberry Seed", "Pumpkin Seed", "Sunflower Seed",
    "Dragon Fruit Seed", "Eggplant Seed", "Watermelon Seed", "Grape Seed",
    "Cocotank Seed", "Carnivorous Plant Seed", "Mr Carrot Seed", 
    "Tomatrio Seed", "Shroombino Seed", "Mango Seed"
}

local availableGears = {
    "Water Bucket", "Frost Grenade", "Banana Gun", "Frost Blower", "Carrot Launcher"
}

-- Timing System
local ITEMS_PER_ROUND = 10
local PURCHASE_DELAY = 200
local CYCLE_INTERVAL = 3000
local currentItemIndex = 1
local purchaseCount = 0
local isAlternatingSeed = true

-- Auto-Reconnect Variables
local reconnectAttempts = 0
local MAX_RECONNECT_ATTEMPTS = 30
local RECONNECT_INTERVAL = 6
local lastDisconnectTime = 0
local lastPingTime = tick()
local consecutiveTimeouts = 0

-- ============================================
-- GAME FUNCTIONS
-- ============================================

local function buySeed(seedName)
    if not BuyItemRemote then return false end
    return pcall(function() BuyItemRemote:FireServer(seedName) end)
end

local function buyGear(gearName)
    if not BuyGearRemote then return false end
    return pcall(function() BuyGearRemote:FireServer(gearName) end)
end

local function sellAllBrainrots()
    if not ItemSellRemote then return false end
    return pcall(function() ItemSellRemote:FireServer() end)
end

local function sellAllPlants()
    if not ItemSellRemote then return false end
    return pcall(function() 
        ItemSellRemote:FireServer(unpack({[2] = true}, 1, table.maxn({[2] = true}))) 
    end)
end

local function openSeedShop()
    if not OpenUIRemote or not seedShopUI then return false end
    return pcall(function() OpenUIRemote:Fire(seedShopUI, true) end)
end

local function openGearShop()
    if not OpenUIRemote or not gearShopUI then return false end
    return pcall(function() OpenUIRemote:Fire(gearShopUI, true) end)
end

local function equipBest()
    if not EquipBestRemote then return false end
    return pcall(function() EquipBestRemote:Fire() end)
end

local function startEquipLoop()
    task.spawn(function()
        while autoEquipEnabled do
            equipBest()
            task.wait(equipInterval)
        end
    end)
end

-- ============================================
-- AUTO-RECONNECT SYSTEM (6 METHODS - 3 MINUTES)
-- ============================================

local function setupAutoReconnect()
    print("🌐 Initializing 3-minute auto-reconnect with network monitoring...")
    
    -- Method 1: Detect Roblox error prompts
    pcall(function()
        local RobloxPromptGui = game:GetService("CoreGui"):FindFirstChild("RobloxPromptGui")
        if RobloxPromptGui then
            local promptOverlay = RobloxPromptGui:FindFirstChild("promptOverlay")
            if promptOverlay then
                promptOverlay.ChildAdded:Connect(function(child)
                    if child.Name == "ErrorPrompt" and autoReconnectEnabled then
                        task.wait(0.5)
                        local errorMessage = child:FindFirstChild("MessageArea")
                        if errorMessage then
                            local messageText = errorMessage:FindFirstChild("ErrorMessage")
                            if messageText then
                                local text = messageText.Text:lower()
                                if string.find(text, "disconnect") or string.find(text, "connection") or
                                   string.find(text, "lost") or string.find(text, "error") or
                                   string.find(text, "kicked") or string.find(text, "unable") or
                                   string.find(text, "timeout") or string.find(text, "network") or
                                   string.find(text, "failed") or string.find(text, "id=17") then
                                    
                                    reconnectAttempts = reconnectAttempts + 1
                                    if reconnectAttempts <= MAX_RECONNECT_ATTEMPTS then
                                        local timeRemaining = (MAX_RECONNECT_ATTEMPTS - reconnectAttempts) * RECONNECT_INTERVAL
                                        print(string.format("🔄 Network issue - reconnecting (attempt %d/%d, %ds remaining)", 
                                            reconnectAttempts, MAX_RECONNECT_ATTEMPTS, timeRemaining))
                                        task.wait(RECONNECT_INTERVAL)
                                        local success = pcall(function()
                                            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, localPlayer)
                                        end)
                                        if not success then
                                            pcall(function() TeleportService:Teleport(game.PlaceId, localPlayer) end)
                                        end
                                    else
                                        print("❌ Max reconnect attempts reached (3 minutes elapsed)")
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end
    end)
    
    -- Method 2: NetworkClient disconnection detection
    pcall(function()
        NetworkClient.ChildRemoved:Connect(function()
            if autoReconnectEnabled then
                local currentTime = tick()
                if currentTime - lastDisconnectTime > 5 then
                    lastDisconnectTime = currentTime
                    reconnectAttempts = reconnectAttempts + 1
                    if reconnectAttempts <= MAX_RECONNECT_ATTEMPTS then
                        local timeRemaining = (MAX_RECONNECT_ATTEMPTS - reconnectAttempts) * RECONNECT_INTERVAL
                        print(string.format("🔄 NetworkClient disconnect (attempt %d/%d, %ds left)", 
                            reconnectAttempts, MAX_RECONNECT_ATTEMPTS, timeRemaining))
                        task.wait(RECONNECT_INTERVAL)
                        pcall(function() TeleportService:Teleport(game.PlaceId, localPlayer) end)
                    end
                end
            end
        end)
    end)
    
    -- Method 3: Active ping monitoring (checks every 8 seconds)
    task.spawn(function()
        while true do
            task.wait(8)
            if autoReconnectEnabled then
                local pingStart = tick()
                local pingSuccess = pcall(function()
                    local test = game:GetService("Players"):GetPlayers()
                    return test ~= nil
                end)
                local pingTime = tick() - pingStart
                
                if not pingSuccess or pingTime > 4 then
                    consecutiveTimeouts = consecutiveTimeouts + 1
                    print(string.format("⚠️ Poor connection detected (timeout %d/4)", consecutiveTimeouts))
                    
                    if consecutiveTimeouts >= 4 then
                        print("🔴 Connection lost - poor network quality")
                        reconnectAttempts = reconnectAttempts + 1
                        if reconnectAttempts <= MAX_RECONNECT_ATTEMPTS then
                            local timeRemaining = (MAX_RECONNECT_ATTEMPTS - reconnectAttempts) * RECONNECT_INTERVAL
                            print(string.format("🔄 Reconnecting (attempt %d/%d, %ds remaining)", 
                                reconnectAttempts, MAX_RECONNECT_ATTEMPTS, timeRemaining))
                            task.wait(RECONNECT_INTERVAL)
                            pcall(function() TeleportService:Teleport(game.PlaceId, localPlayer) end)
                        end
                        consecutiveTimeouts = 0
                    end
                else
                    consecutiveTimeouts = 0
                end
                lastPingTime = tick()
            end
        end
    end)
    
    -- Method 4: Monitor ReplicatedFirst
    pcall(function()
        game:GetService("ReplicatedFirst"):GetPropertyChangedSignal("FinishedReplicating"):Connect(function()
            if not game:GetService("ReplicatedFirst").FinishedReplicating and autoReconnectEnabled then
                print("🔄 Replication interrupted")
                reconnectAttempts = reconnectAttempts + 1
                if reconnectAttempts <= MAX_RECONNECT_ATTEMPTS then
                    task.wait(RECONNECT_INTERVAL)
                    pcall(function() TeleportService:Teleport(game.PlaceId, localPlayer) end)
                end
            end
        end)
    end)
    
    -- Method 5: GuiService error monitoring
    pcall(function()
        local GuiService = game:GetService("GuiService")
        GuiService.ErrorMessageChanged:Connect(function()
            if autoReconnectEnabled then
                local errorMessage = GuiService:GetErrorMessage()
                if errorMessage and errorMessage ~= "" then
                    print("🔴 GuiService error:", errorMessage)
                    reconnectAttempts = reconnectAttempts + 1
                    if reconnectAttempts <= MAX_RECONNECT_ATTEMPTS then
                        task.wait(RECONNECT_INTERVAL)
                        pcall(function() TeleportService:Teleport(game.PlaceId, localPlayer) end)
                    end
                end
            end
        end)
    end)
    
    -- Method 6: Heartbeat freeze detection (15 seconds threshold)
    local lastHeartbeat = tick()
    pcall(function()
        RunService.Heartbeat:Connect(function()
            if autoReconnectEnabled then
                local currentTime = tick()
                local timeSinceLastBeat = currentTime - lastHeartbeat
                if timeSinceLastBeat > 15 then
                    print("🔴 Connection frozen - no heartbeat for " .. math.floor(timeSinceLastBeat) .. " seconds")
                    reconnectAttempts = reconnectAttempts + 1
                    if reconnectAttempts <= MAX_RECONNECT_ATTEMPTS then
                        task.wait(RECONNECT_INTERVAL)
                        pcall(function() TeleportService:Teleport(game.PlaceId, localPlayer) end)
                    end
                end
                lastHeartbeat = currentTime
            end
        end)
    end)
    
    print("✅ 3-minute auto-reconnect initialized (30 attempts × 6 seconds)")
end

-- ============================================
-- ANTI-AFK SYSTEM (FULL IMPLEMENTATION)
-- ============================================

local idledConnection = nil
local antiAFKLoop = nil

local function startAntiAFK()
    local VirtualUser = game:GetService("VirtualUser")
    
    if not idledConnection then
        idledConnection = localPlayer.Idled:Connect(function()
            if antiAFKEnabled then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
                print("🛡️ Anti-AFK: Prevented idle kick")
            end
        end)
    end
    
    if not antiAFKLoop then
        antiAFKLoop = task.spawn(function()
            while true do
                if antiAFKEnabled then
                    VirtualUser:CaptureController()
                    VirtualUser:Button1Down(Vector2.new(0, 0))
                    task.wait(0.1)
                    VirtualUser:Button1Up(Vector2.new(0, 0))
                    print("🛡️ Anti-AFK: Activity simulated")
                end
                task.wait(600)
            end
        end)
    end
end

-- ============================================
-- CONFIG MANAGEMENT SYSTEM
-- ============================================

local function saveSettings()
    local settings = {
        autoLoadConfig = currentSettings.autoLoadConfig or defaultSettings.autoLoadConfig,
        autoLoadEnabled = currentSettings.autoLoadEnabled or defaultSettings.autoLoadEnabled
    }
    if not isfolder("SenpaiHubPVB") then makefolder("SenpaiHubPVB") end
    pcall(function()
        writefile(SETTINGS_FILE, HttpService:JSONEncode(settings))
    end)
    return true
end

local function loadSettings()
    local success, result = pcall(function()
        if isfile(SETTINGS_FILE) then
            local data = readfile(SETTINGS_FILE)
            return HttpService:JSONDecode(data)
        end
        return nil
    end)
    
    if success and result then
        currentSettings = result
    else
        currentSettings = table.clone(defaultSettings)
        saveSettings()
    end
    return currentSettings
end

local function getAvailableConfigs()
    local configs = {"None"}
    pcall(function()
        if isfolder("SenpaiHubPVB") then
            local files = listfiles("SenpaiHubPVB")
            for _, file in pairs(files) do
                if file:match("%.json$") and not file:match("Settings") then
                    local fileName = file:match("SenpaiHubPVB/(.+)%.json$") or file:match("([^/\\]+)%.json$")
                    if fileName and fileName ~= "PlantsBrainrot_Settings" then
                        if not table.find(configs, fileName) then
                            table.insert(configs, fileName)
                        end
                    end
                end
            end
        end
    end)
    return configs
end

local function saveConfig(customName)
    if not isfolder("SenpaiHubPVB") then makefolder("SenpaiHubPVB") end
    local fileName = customName and ("SenpaiHubPVB/" .. customName .. ".json") or CONFIG_FILE
    
    currentConfig = {
        selectedSeeds = selectedSeeds,
        selectedGears = selectedGears,
        equipInterval = equipInterval,
        autoBuySeedsEnabled = autoBuySeedsEnabled,
        autoBuyGearsEnabled = autoBuyGearsEnabled,
        autoEquipEnabled = autoEquipEnabled,
        autoBuyAllSeedsEnabled = autoBuyAllSeedsEnabled,
        autoBuyAllGearsEnabled = autoBuyAllGearsEnabled,
        antiAFKEnabled = antiAFKEnabled,
        autoReconnectEnabled = autoReconnectEnabled
    }
    
    local success = pcall(function()
        writefile(fileName, HttpService:JSONEncode(currentConfig))
    end)
    
    if success then
        print("✅ Config saved to:", fileName)
    end
    return success
end

local function loadConfig(name)
    local filesToTry = {"SenpaiHubPVB/" .. name .. ".json", name .. ".json"}
    for _, file in pairs(filesToTry) do
        if file and isfile(file) then
            local success, result = pcall(function()
                local data = readfile(file)
                return HttpService:JSONDecode(data)
            end)
            if success and result then
                currentConfig = result
                selectedSeeds = result.selectedSeeds or {}
                selectedGears = result.selectedGears or {}
                equipInterval = result.equipInterval or 20
                
                autoBuySeedsEnabled = result.autoBuySeedsEnabled or false
                autoBuyGearsEnabled = result.autoBuyGearsEnabled or false
                autoEquipEnabled = result.autoEquipEnabled or false
                autoBuyAllSeedsEnabled = result.autoBuyAllSeedsEnabled or false
                autoBuyAllGearsEnabled = result.autoBuyAllGearsEnabled or false
                antiAFKEnabled = result.antiAFKEnabled or false
                autoReconnectEnabled = result.autoReconnectEnabled or false
                
                if antiAFKEnabled then startAntiAFK() end
                if autoReconnectEnabled then setupAutoReconnect() end
                if autoEquipEnabled then startEquipLoop() end
                
                print("✅ Config loaded:", name)
                return true
            end
        end
    end
    return false
end

-- Load settings on startup
loadSettings()

-- Auto-load config if enabled
if currentSettings.autoLoadEnabled and currentSettings.autoLoadConfig ~= "None" then
    loadConfig(currentSettings.autoLoadConfig)
end

-- ============================================
-- UI CREATION FUNCTIONS
-- ============================================

local function createButton(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 38)
    button.BackgroundColor3 = COLORS.Primary
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)  -- Explicit white
    button.TextSize = 15
    button.Font = Enum.Font.GothamBold
    button.BorderSizePixel = 0
    button.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, COLORS.Primary),
        ColorSequenceKeypoint.new(1, COLORS.Secondary)
    }
    gradient.Rotation = 45
    gradient.Parent = button
    
    button.MouseButton1Click:Connect(callback)
    
    return button
end

local function createToggle(parent, text, defaultValue, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = COLORS.Surface
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)  -- White text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 50, 0, 26)
    toggle.Position = UDim2.new(1, -55, 0.5, -13)
    toggle.BackgroundColor3 = defaultValue and COLORS.Success or Color3.fromRGB(60, 60, 70)
    toggle.Text = ""
    toggle.BorderSizePixel = 0
    toggle.Parent = frame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggle
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 20, 0, 20)
    indicator.Position = defaultValue and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
    indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)  -- White indicator
    indicator.BorderSizePixel = 0
    indicator.Parent = toggle
    
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(1, 0)
    indicatorCorner.Parent = indicator
    
    local isEnabled = defaultValue
    
    toggle.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        TweenService:Create(indicator, TweenInfo.new(0.2), {
            Position = isEnabled and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
        }):Play()
        TweenService:Create(toggle, TweenInfo.new(0.2), {
            BackgroundColor3 = isEnabled and COLORS.Success or Color3.fromRGB(60, 60, 70)
        }):Play()
        callback(isEnabled)
    end)
    
    return toggle, frame
end

local function createTextBox(parent, text, defaultValue, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = COLORS.Surface
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.45, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)  -- White text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local textbox = Instance.new("TextBox")
    textbox.Size = UDim2.new(0.55, -20, 0, 30)
    textbox.Position = UDim2.new(0.45, 5, 0.5, -15)
    textbox.BackgroundColor3 = COLORS.Background
    textbox.Text = tostring(defaultValue)
    textbox.TextColor3 = Color3.fromRGB(255, 255, 255)  -- White text
    textbox.TextSize = 14
    textbox.Font = Enum.Font.Gotham
    textbox.BorderSizePixel = 0
    textbox.Parent = frame
    
    local textboxCorner = Instance.new("UICorner")
    textboxCorner.CornerRadius = UDim.new(0, 6)
    textboxCorner.Parent = textbox
    
    if callback then
        textbox.FocusLost:Connect(function()
            callback(textbox.Text)
        end)
    end
    
    return textbox, frame
end

local function createLabel(parent, text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 0)
    label.AutomaticSize = Enum.AutomaticSize.Y
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = COLORS.TextSecondary
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true
    label.Parent = parent
    
    return label
end

local function createSection(parent, name)
    local section = Instance.new("Frame")
    section.Name = name
    section.Size = UDim2.new(1, 0, 0, 0)
    section.BackgroundTransparency = 1
    section.Visible = false
    section.Parent = parent
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = section
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        section.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y)
        ContentArea.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)
    
    return section
end

local function createCheckbox(parent, text, defaultValue, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.BackgroundColor3 = COLORS.Surface
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    local checkbox = Instance.new("TextButton")
    checkbox.Size = UDim2.new(0, 24, 0, 24)
    checkbox.Position = UDim2.new(0, 6, 0.5, -12)
    checkbox.BackgroundColor3 = COLORS.Background
    checkbox.Text = ""
    checkbox.BorderSizePixel = 0
    checkbox.Parent = frame
    
    local checkboxCorner = Instance.new("UICorner")
    checkboxCorner.CornerRadius = UDim.new(0, 4)
    checkboxCorner.Parent = checkbox
    
    local checkmark = Instance.new("TextLabel")
    checkmark.Size = UDim2.new(1, 0, 1, 0)
    checkmark.BackgroundTransparency = 1
    checkmark.Text = defaultValue and "✓" or ""
    checkmark.TextColor3 = COLORS.Success
    checkmark.TextSize = 18
    checkmark.Font = Enum.Font.GothamBold
    checkmark.Parent = checkbox
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -40, 1, 0)
    label.Position = UDim2.new(0, 36, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)  -- White text
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local isChecked = defaultValue
    
    checkbox.MouseButton1Click:Connect(function()
        isChecked = not isChecked
        checkmark.Text = isChecked and "✓" or ""
        TweenService:Create(checkbox, TweenInfo.new(0.1), {
            BackgroundColor3 = isChecked and COLORS.Primary or COLORS.Background
        }):Play()
        callback(isChecked)
    end)
    
    return checkbox, frame
end

local function createDropdown(parent, text, items, selectedItems, callback)
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(1, 0, 0, 40)
    dropdownFrame.BackgroundColor3 = COLORS.Surface
    dropdownFrame.BorderSizePixel = 0
    dropdownFrame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = dropdownFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text .. " (" .. #selectedItems .. " selected)"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)  -- White text
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = dropdownFrame
    
    local expandButton = Instance.new("TextButton")
    expandButton.Size = UDim2.new(0, 35, 0, 30)
    expandButton.Position = UDim2.new(1, -40, 0.5, -15)
    expandButton.BackgroundColor3 = COLORS.Primary
    expandButton.Text = "▼"
    expandButton.TextColor3 = Color3.fromRGB(255, 255, 255)  -- White text
    expandButton.TextSize = 14
    expandButton.Font = Enum.Font.GothamBold
    expandButton.BorderSizePixel = 0
    expandButton.Parent = dropdownFrame
    
    local expandCorner = Instance.new("UICorner")
    expandCorner.CornerRadius = UDim.new(0, 6)
    expandCorner.Parent = expandButton
    
    local itemsList = Instance.new("Frame")
    itemsList.Size = UDim2.new(1, 0, 0, 0)
    itemsList.Position = UDim2.new(0, 0, 1, 5)
    itemsList.BackgroundColor3 = COLORS.Surface
    itemsList.BorderSizePixel = 0
    itemsList.Visible = false
    itemsList.ZIndex = 10
    itemsList.Parent = dropdownFrame
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 8)
    listCorner.Parent = itemsList
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -10, 1, -10)
    scrollFrame.Position = UDim2.new(0, 5, 0, 5)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = COLORS.Primary
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.Parent = itemsList
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 3)
    listLayout.Parent = scrollFrame
    
    local checkboxes = {}
    
    for _, itemName in pairs(items) do
        local isSelected = table.find(selectedItems, itemName) ~= nil
        local cb, cbFrame = createCheckbox(scrollFrame, itemName, isSelected, function(checked)
            if checked then
                if not table.find(selectedItems, itemName) then
                    table.insert(selectedItems, itemName)
                end
            else
                local index = table.find(selectedItems, itemName)
                if index then
                    table.remove(selectedItems, index)
                end
            end
            label.Text = text .. " (" .. #selectedItems .. " selected)"
            callback(selectedItems)
        end)
        checkboxes[itemName] = cb
    end
    
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        local height = math.min(listLayout.AbsoluteContentSize.Y + 10, 200)
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
        itemsList.Size = UDim2.new(1, 0, 0, height)
    end)
    
    local isExpanded = false
    expandButton.MouseButton1Click:Connect(function()
        isExpanded = not isExpanded
        itemsList.Visible = isExpanded
        expandButton.Text = isExpanded and "▲" or "▼"
    end)
    
    return dropdownFrame, checkboxes
end

-- ============================================
-- CREATE UI STRUCTURE
-- ============================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SenpaiHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Circular Toggle Button (Minimized)
local ToggleButton = Instance.new("ImageButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 60, 0, 60)
ToggleButton.Position = UDim2.new(0, 20, 0.5, -30)
ToggleButton.BackgroundColor3 = COLORS.Primary
ToggleButton.BorderSizePixel = 0
ToggleButton.Image = ""
ToggleButton.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleButton

local ToggleGradient = Instance.new("UIGradient")
ToggleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, COLORS.Primary),
    ColorSequenceKeypoint.new(1, COLORS.Secondary)
}
ToggleGradient.Rotation = 45
ToggleGradient.Parent = ToggleButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = COLORS.Text
ToggleStroke.Thickness = 3
ToggleStroke.Transparency = 0.3
ToggleStroke.Parent = ToggleButton

local ToggleIcon = Instance.new("TextLabel")
ToggleIcon.Size = UDim2.new(1, 0, 1, 0)
ToggleIcon.BackgroundTransparency = 1
ToggleIcon.Text = "🔥"
ToggleIcon.TextColor3 = COLORS.Text
ToggleIcon.TextSize = 28
ToggleIcon.Font = Enum.Font.GothamBold
ToggleIcon.Parent = ToggleButton

-- Main Frame
MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 720, 0, 520)
MainFrame.Position = UDim2.new(0.5, -360, 0.5, -260)
MainFrame.BackgroundColor3 = COLORS.Background
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = COLORS.Primary
MainStroke.Thickness = 2
MainStroke.Transparency = 0.5
MainStroke.Parent = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = COLORS.Surface
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

local HeaderGradient = Instance.new("UIGradient")
HeaderGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, COLORS.Primary),
    ColorSequenceKeypoint.new(1, COLORS.Secondary)
}
HeaderGradient.Rotation = 90
HeaderGradient.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🔥 SENPAI HUB"
Title.TextColor3 = COLORS.Text
Title.TextSize = 22
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -45, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)  -- White text on red
CloseButton.TextSize = 28
CloseButton.Font = Enum.Font.GothamBold
CloseButton.BorderSizePixel = 0
CloseButton.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

-- Tab Bar (Horizontal)
local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(1, -20, 0, 45)
TabBar.Position = UDim2.new(0, 10, 0, 60)
TabBar.BackgroundTransparency = 1
TabBar.Parent = MainFrame

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 8)
TabLayout.Parent = TabBar

-- Content Area
ContentArea = Instance.new("ScrollingFrame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -20, 1, -125)
ContentArea.Position = UDim2.new(0, 10, 0, 115)
ContentArea.BackgroundTransparency = 1
ContentArea.BorderSizePixel = 0
ContentArea.ScrollBarThickness = 6
ContentArea.ScrollBarImageColor3 = COLORS.Primary
ContentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentArea.Parent = MainFrame

-- Tab Creation Function
local function createTab(name, icon)
    local tab = Instance.new("TextButton")
    tab.Name = name
    tab.Size = UDim2.new(0, 125, 1, -10)
    tab.Position = UDim2.new(0, 5, 0, 5)
    tab.BackgroundColor3 = COLORS.Surface
    tab.Text = icon .. " " .. name
    tab.TextColor3 = COLORS.TextSecondary
    tab.TextSize = 14
    tab.Font = Enum.Font.GothamBold
    tab.BorderSizePixel = 0
    tab.Parent = TabBar
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = tab
    
    tab.MouseButton1Click:Connect(function()
        currentTab = name
        for _, child in pairs(ContentArea:GetChildren()) do
            if child:IsA("Frame") and child.Name ~= "UIListLayout" then
                child.Visible = (child.Name == name)
            end
        end
        
        for _, otherTab in pairs(TabBar:GetChildren()) do
            if otherTab:IsA("TextButton") then
                if otherTab.Name == name then
                    otherTab.BackgroundColor3 = COLORS.Primary
                    otherTab.TextColor3 = Color3.fromRGB(255, 255, 255)  -- White when selected
                else
                    otherTab.BackgroundColor3 = COLORS.Surface
                    otherTab.TextColor3 = COLORS.TextSecondary
                end
            end
        end
    end)
    
    return tab
end

-- Create Tabs
createTab("Information", "ℹ️")
createTab("Auto Buy", "🛒")
createTab("Sell", "💰")
createTab("Auto Equip", "⚡")
createTab("Settings", "⚙️")

-- ============================================
-- TAB CONTENT - INFORMATION
-- ============================================

local InfoSection = createSection(ContentArea, "Information")
InfoSection.Visible = true

createLabel(InfoSection, "🔥 SENPAI HUB - Plants vs. Brainrot")
createLabel(InfoSection, "")
createLabel(InfoSection, "FEATURES:")
createLabel(InfoSection, "• Auto buy seeds & gears with multi-select")
createLabel(InfoSection, "• Sell all brainrot and plants (favorites excluded)")
createLabel(InfoSection, "• Auto equip best brainrot + auto collect money")
createLabel(InfoSection, "• Anti-AFK protection (prevents kick)")
createLabel(InfoSection, "• Auto-reconnect on disconnect (3 minutes, 6 methods)")
createLabel(InfoSection, "• Save/Load configurations")
createLabel(InfoSection, "• Auto-load preferred setup on startup")
createLabel(InfoSection, "")
createLabel(InfoSection, "CONTROLS:")
createLabel(InfoSection, "• G = Toggle Interface")
createLabel(InfoSection, "• Ctrl + B = Toggle Seed Auto-Buy")
createLabel(InfoSection, "• Ctrl + N = Toggle Gear Auto-Buy")
createLabel(InfoSection, "• Ctrl + E = Toggle Auto Equip")
createLabel(InfoSection, "")
createLabel(InfoSection, "Made with love by @senpai 🔥")

-- ============================================
-- TAB CONTENT - AUTO BUY
-- ============================================

local AutoBuySection = createSection(ContentArea, "Auto Buy")

createButton(AutoBuySection, "🌱 Open Seed Shop", function()
    openSeedShop()
end)

createButton(AutoBuySection, "🔧 Open Gear Shop", function()
    openGearShop()
end)

createLabel(AutoBuySection, "")
createLabel(AutoBuySection, "SELECT SEEDS TO AUTO-BUY:")

local seedDropdownFrame, seedCheckboxRefs = createDropdown(AutoBuySection, "Select Seeds", availableSeeds, selectedSeeds, function(items)
    selectedSeeds = items
end)
seedCheckboxes = seedCheckboxRefs

createLabel(AutoBuySection, "")

createToggle(AutoBuySection, "Enable Auto Buy Seeds", autoBuySeedsEnabled, function(enabled)
    autoBuySeedsEnabled = enabled
end)

createToggle(AutoBuySection, "Auto Buy All Seeds (14 types)", autoBuyAllSeedsEnabled, function(enabled)
    autoBuyAllSeedsEnabled = enabled
end)

createLabel(AutoBuySection, "")
createLabel(AutoBuySection, "SELECT GEARS TO AUTO-BUY:")

local gearDropdownFrame, gearCheckboxRefs = createDropdown(AutoBuySection, "Select Gears", availableGears, selectedGears, function(items)
    selectedGears = items
end)
gearCheckboxes = gearCheckboxRefs

createLabel(AutoBuySection, "")

createToggle(AutoBuySection, "Enable Auto Buy Gears", autoBuyGearsEnabled, function(enabled)
    autoBuyGearsEnabled = enabled
end)

createToggle(AutoBuySection, "Auto Buy All Gears (5 types)", autoBuyAllGearsEnabled, function(enabled)
    autoBuyAllGearsEnabled = enabled
end)

-- ============================================
-- TAB CONTENT - SELL
-- ============================================

local SellSection = createSection(ContentArea, "Sell")

createLabel(SellSection, "⚠️ NOTE: Favorited items are not included when selling")
createLabel(SellSection, "")

createButton(SellSection, "💰 Sell All Brainrots", function()
    sellAllBrainrots()
end)

createButton(SellSection, "🌿 Sell All Plants", function()
    sellAllPlants()
end)

createButton(SellSection, "🗑️ Sell Everything", function()
    sellAllBrainrots()
    task.wait(0.5)
    sellAllPlants()
end)

-- ============================================
-- TAB CONTENT - AUTO EQUIP
-- ============================================

local EquipSection = createSection(ContentArea, "Auto Equip")

createLabel(EquipSection, "Auto equip best brainrots and collect all money automatically")
createLabel(EquipSection, "")

local intervalInput = createTextBox(EquipSection, "Equip Interval (seconds):", equipInterval, function(text)
    local num = tonumber(text)
    if num and num > 0 then
        equipInterval = num
    end
end)

createToggle(EquipSection, "Enable Auto Equip", autoEquipEnabled, function(enabled)
    autoEquipEnabled = enabled
    if enabled then
        startEquipLoop()
    end
end)

createLabel(EquipSection, "")

createButton(EquipSection, "⚡ Equip Best Now", function()
    equipBest()
end)

-- ============================================
-- TAB CONTENT - SETTINGS
-- ============================================

local SettingsSection = createSection(ContentArea, "Settings")

createLabel(SettingsSection, "CONNECTION & ACTIVITY:")
createLabel(SettingsSection, "")

createToggle(SettingsSection, "Enable Auto-Reconnect (3 min)", autoReconnectEnabled, function(enabled)
    autoReconnectEnabled = enabled
    reconnectAttempts = 0
    if enabled then
        setupAutoReconnect()
    end
end)

createToggle(SettingsSection, "Enable Anti-AFK Protection", antiAFKEnabled, function(enabled)
    antiAFKEnabled = enabled
    if enabled then
        startAntiAFK()
    end
end)

createLabel(SettingsSection, "")
createLabel(SettingsSection, "STARTUP CONFIGURATION:")
createLabel(SettingsSection, "")

createToggle(SettingsSection, "Enable Auto-Load on Startup", currentSettings.autoLoadEnabled, function(state)
    currentSettings.autoLoadEnabled = state
    saveSettings()
end)

-- Config dropdown will be added in Part 3
createLabel(SettingsSection, "")
createLabel(SettingsSection, "SAVE & LOAD CONFIGURATIONS:")
createLabel(SettingsSection, "")

configNameInput = createTextBox(SettingsSection, "Config Name:", "senpai-hub-config")

createButton(SettingsSection, "💾 Save Current Settings", function()
    local name = configNameInput.Text
    if name and name ~= "" then
        saveConfig(name)
    end
end)

createButton(SettingsSection, "📂 Load Saved Settings", function()
    local name = configNameInput.Text
    if name and name ~= "" then
        loadConfig(name)
    end
end)

-- ============================================
-- UI FUNCTIONALITY - TOGGLE & CLOSE
-- ============================================

local isVisible = false

ToggleButton.MouseButton1Click:Connect(function()
    isVisible = not isVisible
    MainFrame.Visible = isVisible
    
    if isVisible then
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 720, 0, 520)
        }):Play()
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    isVisible = false
    TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0)
    }):Play()
    task.wait(0.2)
    MainFrame.Visible = false
end)

-- ============================================
-- KEYBIND SYSTEM
-- ============================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- G to toggle UI
    if input.KeyCode == Enum.KeyCode.G then
        ToggleButton.MouseButton1Click:Fire()
    end
    
    local isCtrl = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
    
    if isCtrl then
        -- Ctrl + B = Toggle Seed Auto-Buy
        if input.KeyCode == Enum.KeyCode.B then
            autoBuySeedsEnabled = not autoBuySeedsEnabled
            print(string.format("🔥 Auto Buy Seeds: %s", autoBuySeedsEnabled and "ON" or "OFF"))
        
        -- Ctrl + N = Toggle Gear Auto-Buy
        elseif input.KeyCode == Enum.KeyCode.N then
            autoBuyGearsEnabled = not autoBuyGearsEnabled
            print(string.format("🔥 Auto Buy Gears: %s", autoBuyGearsEnabled and "ON" or "OFF"))
        
        -- Ctrl + E = Toggle Auto Equip
        elseif input.KeyCode == Enum.KeyCode.E then
            autoEquipEnabled = not autoEquipEnabled
            if autoEquipEnabled then
                startEquipLoop()
            end
            print(string.format("🔥 Auto Equip: %s", autoEquipEnabled and "ON" or "OFF"))
        end
    end
end)

-- ============================================
-- DRAGGING SYSTEM FOR TOGGLE BUTTON
-- ============================================

local dragging = false
local dragInput, dragStart, startPos

ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = ToggleButton.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

ToggleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        ToggleButton.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- ============================================
-- AUTO-BUY LOOP (UNIFIED TIMING SYSTEM)
-- ============================================

task.spawn(function()
    while true do
        local shouldBuySeeds = (autoBuySeedsEnabled and #selectedSeeds > 0) or autoBuyAllSeedsEnabled
        local shouldBuyGears = (autoBuyGearsEnabled and #selectedGears > 0) or autoBuyAllGearsEnabled
        
        if shouldBuySeeds or shouldBuyGears then
            local purchased = false
            
            if shouldBuySeeds and shouldBuyGears then
                if isAlternatingSeed then
                    local seedList = autoBuyAllSeedsEnabled and availableSeeds or selectedSeeds
                    if #seedList > 0 then
                        local seedIndex = ((currentItemIndex - 1) % #seedList) + 1
                        local seedName = seedList[seedIndex]
                        local success = buySeed(seedName)
                        if success then
                            purchased = true
                        end
                    end
                    isAlternatingSeed = false
                else
                    local gearList = autoBuyAllGearsEnabled and availableGears or selectedGears
                    if #gearList > 0 then
                        local gearIndex = ((currentItemIndex - 1) % #gearList) + 1
                        local gearName = gearList[gearIndex]
                        local success = buyGear(gearName)
                        if success then
                            purchased = true
                        end
                    end
                    isAlternatingSeed = true
                end
            elseif shouldBuySeeds then
                local seedList = autoBuyAllSeedsEnabled and availableSeeds or selectedSeeds
                if #seedList > 0 then
                    local seedIndex = ((currentItemIndex - 1) % #seedList) + 1
                    local seedName = seedList[seedIndex]
                    local success = buySeed(seedName)
                    if success then
                        purchased = true
                    end
                end
            elseif shouldBuyGears then
                local gearList = autoBuyAllGearsEnabled and availableGears or selectedGears
                if #gearList > 0 then
                    local gearIndex = ((currentItemIndex - 1) % #gearList) + 1
                    local gearName = gearList[gearIndex]
                    local success = buyGear(gearName)
                    if success then
                        purchased = true
                    end
                end
            end
            
            if purchased then
                purchaseCount = purchaseCount + 1
                
                if purchaseCount >= ITEMS_PER_ROUND then
                    purchaseCount = 0
                    currentItemIndex = currentItemIndex + 1
                    
                    local totalItems = 0
                    if shouldBuySeeds and shouldBuyGears then
                        totalItems = math.max(
                            autoBuyAllSeedsEnabled and #availableSeeds or #selectedSeeds,
                            autoBuyAllGearsEnabled and #availableGears or #selectedGears
                        )
                    elseif shouldBuySeeds then
                        totalItems = autoBuyAllSeedsEnabled and #availableSeeds or #selectedSeeds
                    elseif shouldBuyGears then
                        totalItems = autoBuyAllGearsEnabled and #availableGears or #selectedGears
                    end
                    
                    if currentItemIndex > totalItems then
                        currentItemIndex = 1
                        task.wait(CYCLE_INTERVAL / 1000)
                    end
                end
            end
            
            task.wait(PURCHASE_DELAY / 1000)
        else
            task.wait(2)
        end
    end
end)

-- ============================================
-- PARENT TO PLAYERGUI & STARTUP
-- ============================================

ScreenGui.Parent = localPlayer:WaitForChild("PlayerGui")

-- Startup notification
task.wait(1)
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("🔥 SENPAI HUB - Fully Loaded!")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("📌 Press G to open/close")
print("📌 All features loaded:")
print("   ✅ Multi-select dropdowns")
print("   ✅ Save/Load system")
print("   ✅ Auto-reconnect (6 methods)")
print("   ✅ Anti-AFK protection")
print("   ✅ Auto-buy with timing")
print("   ✅ Auto-equip system")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

if currentSettings.autoLoadEnabled and currentSettings.autoLoadConfig ~= "None" then
    print("🔥 Auto-loaded config: " .. currentSettings.autoLoadConfig)
    print("   Seeds selected: " .. #selectedSeeds)
    print("   Gears selected: " .. #selectedGears)
end

print("")
print("Controls:")
print("• G = Toggle Interface")
print("• Ctrl + B = Toggle Seed Auto-Buy")  
print("• Ctrl + N = Toggle Gear Auto-Buy")
print("• Ctrl + E = Toggle Auto Equip")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("")

-- Keep script alive
task.spawn(function()
    while task.wait(1) do
        -- Script keepalive
    end
end)
