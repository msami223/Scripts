--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
-- Senpai Hub for Plants vs. Brainrot - ENHANCED EDITION
-- Game validation first
local PLANTS_VS_BRAINROT_ID = 127742093697776

if game.PlaceId ~= PLANTS_VS_BRAINROT_ID then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Wrong Game!";
        Text = "This script only works in Plants vs. Brainrot";
        Duration = 5;
    })
    return
end

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local NetworkClient = game:GetService("NetworkClient")

local localPlayer = Players.LocalPlayer

-- Configuration system - SEPARATE FOLDER: SenpaiHubPVB
local CONFIG_FILE = "SenpaiHubPVB/PlantsBrainrot_Config.json"
local SETTINGS_FILE = "SenpaiHubPVB/PlantsBrainrot_Settings.json"
local defaultConfig = {
    selectedSeeds = {},
    selectedGears = {},
    equipInterval = 20,
    theme = "Dark",
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

local currentConfig = {}
local currentSettings = {}

-- Variables
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
local Window = nil

-- UNIFIED TIMING SYSTEM
local ITEMS_PER_ROUND = 10
local PURCHASE_DELAY = 200
local CYCLE_INTERVAL = 3000
local currentItemIndex = 1
local purchaseCount = 0
local isAlternatingSeed = true

-- EXACT GAME REMOTES FROM SIGMA SPY
local BuyItemRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("BuyItem")
local BuyGearRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("BuyGear")
local OpenUIRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("OpenUI")
local EquipBestRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("EquipBest")
local ItemSellRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ItemSell")

-- UI References
local seedShopUI = localPlayer.PlayerGui.Main.Seeds
local gearShopUI = localPlayer.PlayerGui.Main.Gears

-- Available items lists
local availableSeeds = {
    "Cactus Seed", "Strawberry Seed", "Pumpkin Seed", "Sunflower Seed",
    "Dragon Fruit Seed", "Eggplant Seed", "Watermelon Seed", "Grape Seed",
    "Cocotank Seed", "Carnivorous Plant Seed", "Mr Carrot Seed", 
    "Tomatrio Seed", "Shroombino Seed", "Mango Seed"
}

local availableGears = {
    "Water Bucket", "Frost Grenade", "Banana Gun", "Frost Blower", "Carrot Launcher"
}

-- UI References for keybinds and dropdowns
local autoBuyToggleSeeds = nil
local autoBuyToggleGears = nil
local autoEquipToggle = nil
local autoBuyAllSeedsToggle = nil
local autoBuyAllGearsToggle = nil
local equipIntervalInput = nil
local seedDropdown = nil
local gearDropdown = nil
local themeDropdown = nil
local autoLoadDropdown = nil
local autoLoadToggle = nil
local ConfigNameInput = nil
local antiAFKToggle = nil
local autoReconnectToggle = nil

-- Control flags
local canChangeTheme = true
local canChangeDropdown = true

-- EXTENDED AUTO-RECONNECT SYSTEM (3 MINUTES DURATION)
local reconnectAttempts = 0
local MAX_RECONNECT_ATTEMPTS = 30
local RECONNECT_INTERVAL = 6
local lastDisconnectTime = 0
local lastPingTime = tick()
local consecutiveTimeouts = 0

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
                                
                                if string.find(text, "disconnect") or
                                   string.find(text, "connection") or
                                   string.find(text, "lost") or
                                   string.find(text, "error") or
                                   string.find(text, "kicked") or
                                   string.find(text, "unable") or
                                   string.find(text, "timeout") or
                                   string.find(text, "network") or
                                   string.find(text, "failed") or
                                   string.find(text, "id=17") then
                                    
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
                                            pcall(function()
                                                TeleportService:Teleport(game.PlaceId, localPlayer)
                                            end)
                                        end
                                    else
                                        print("❌ Max reconnect attempts reached (3 minutes elapsed)")
                                        WindUI:Notify({
                                            Title = "Auto-Reconnect Failed",
                                            Content = string.format("Could not reconnect after 3 minutes (%d attempts)", MAX_RECONNECT_ATTEMPTS),
                                            Duration = 5
                                        })
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
                        
                        pcall(function()
                            TeleportService:Teleport(game.PlaceId, localPlayer)
                        end)
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
                            
                            pcall(function()
                                TeleportService:Teleport(game.PlaceId, localPlayer)
                            end)
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
                    pcall(function()
                        TeleportService:Teleport(game.PlaceId, localPlayer)
                    end)
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
                        pcall(function()
                            TeleportService:Teleport(game.PlaceId, localPlayer)
                        end)
                    end
                end
            end
        end)
    end)
    
    -- Method 6: Heartbeat freeze detection (15 seconds threshold)
    local lastHeartbeat = tick()
    pcall(function()
        game:GetService("RunService").Heartbeat:Connect(function()
            if autoReconnectEnabled then
                local currentTime = tick()
                local timeSinceLastBeat = currentTime - lastHeartbeat
                
                if timeSinceLastBeat > 15 then
                    print("🔴 Connection frozen - no heartbeat for " .. math.floor(timeSinceLastBeat) .. " seconds")
                    reconnectAttempts = reconnectAttempts + 1
                    
                    if reconnectAttempts <= MAX_RECONNECT_ATTEMPTS then
                        task.wait(RECONNECT_INTERVAL)
                        pcall(function()
                            TeleportService:Teleport(game.PlaceId, localPlayer)
                        end)
                    end
                end
                
                lastHeartbeat = currentTime
            end
        end)
    end)
    
    print("✅ 3-minute auto-reconnect initialized (30 attempts × 6 seconds)")
end

-- ANTI-AFK SYSTEM
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

-- KEYBIND SYSTEM
local function setupKeybinds()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        local isCtrlPressed = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
        
        if isCtrlPressed then
            if input.KeyCode == Enum.KeyCode.B then
                autoBuySeedsEnabled = not autoBuySeedsEnabled
                
                if autoBuyToggleSeeds then
                    pcall(function()
                        autoBuyToggleSeeds.Value = autoBuySeedsEnabled
                        if autoBuyToggleSeeds.Callback then
                            autoBuyToggleSeeds.Callback(autoBuySeedsEnabled)
                        end
                    end)
                end
                
                WindUI:Notify({
                    Title = "Auto Buy Seeds " .. (autoBuySeedsEnabled and "Started" or "Stopped") .. " [Ctrl+B]",
                    Content = autoBuySeedsEnabled and string.format("Now purchasing %d selected seeds automatically", #selectedSeeds) or "Seed purchasing stopped",
                    Duration = 3
                })
            
            elseif input.KeyCode == Enum.KeyCode.N then
                autoBuyGearsEnabled = not autoBuyGearsEnabled
                
                if autoBuyToggleGears then
                    pcall(function()
                        autoBuyToggleGears.Value = autoBuyGearsEnabled
                        if autoBuyToggleGears.Callback then
                            autoBuyToggleGears.Callback(autoBuyGearsEnabled)
                        end
                    end)
                end
                
                WindUI:Notify({
                    Title = "Auto Buy Gears " .. (autoBuyGearsEnabled and "Started" or "Stopped") .. " [Ctrl+N]",
                    Content = autoBuyGearsEnabled and string.format("Now purchasing %d selected gears automatically", #selectedGears) or "Gear purchasing stopped",
                    Duration = 3
                })
            
            elseif input.KeyCode == Enum.KeyCode.E then
                autoEquipEnabled = not autoEquipEnabled
                
                if autoEquipToggle then
                    pcall(function()
                        autoEquipToggle.Value = autoEquipEnabled
                        if autoEquipToggle.Callback then
                            autoEquipToggle.Callback(autoEquipEnabled)
                        end
                    end)
                end
                
                if autoEquipEnabled then
                    startEquipLoop()
                end
                
                WindUI:Notify({
                    Title = "Auto Equip " .. (autoEquipEnabled and "Started" or "Stopped") .. " [Ctrl+E]",
                    Content = autoEquipEnabled and string.format("Now auto-equipping best brainrot every %d seconds", equipInterval) or "Auto equip stopped",
                    Duration = 3
                })
            end
        end
    end)
end

-- BUYING FUNCTIONS
local function buySeed(seedName)
    if not BuyItemRemote then return false end
    return pcall(function() BuyItemRemote:FireServer(seedName) end)
end

local function buyGear(gearName)
    if not BuyGearRemote then return false end
    return pcall(function() BuyGearRemote:FireServer(gearName) end)
end

-- SELLING FUNCTIONS
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

-- SHOP OPENING FUNCTIONS
local function openSeedShop()
    if not OpenUIRemote or not seedShopUI then return false end
    return pcall(function() OpenUIRemote:Fire(seedShopUI, true) end)
end

local function openGearShop()
    if not OpenUIRemote or not gearShopUI then return false end
    return pcall(function() OpenUIRemote:Fire(gearShopUI, true) end)
end

-- EQUIP BEST FUNCTION
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

-- Apply equip interval function
local function applyEquipInterval()
    if equipIntervalInput then
        local value = ""
        if equipIntervalInput.Get then
            value = equipIntervalInput:Get()
        elseif equipIntervalInput.Value then
            value = equipIntervalInput.Value
        else
            value = "20"
        end
        
        local num = tonumber(value)
        if num and num > 0 then
            equipInterval = num
            WindUI:Notify({
                Title = "Equip Interval Updated",
                Content = "Auto-equip now runs every " .. num .. " seconds",
                Duration = 2
            })
            return true
        else
            WindUI:Notify({
                Title = "Invalid Number",
                Content = "Please enter a valid positive number for the interval",
                Duration = 3
            })
        end
    end
    return false
end

-- SETTINGS MANAGEMENT
local function saveSettings()
    local settings = {
        autoLoadConfig = currentSettings.autoLoadConfig or defaultSettings.autoLoadConfig,
        autoLoadEnabled = currentSettings.autoLoadEnabled or defaultSettings.autoLoadEnabled
    }
    
    if not isfolder("SenpaiHubPVB") then
        makefolder("SenpaiHubPVB")
    end
    
    local success = pcall(function()
        writefile(SETTINGS_FILE, game:GetService("HttpService"):JSONEncode(settings))
    end)
    
    return success
end

local function loadSettings()
    local success, result = pcall(function()
        if isfile(SETTINGS_FILE) then
            local data = readfile(SETTINGS_FILE)
            return game:GetService("HttpService"):JSONDecode(data)
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

-- Get available config files
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

-- Save config function (saves all toggles)
local function saveConfig(customName)
    if not isfolder("SenpaiHubPVB") then
        makefolder("SenpaiHubPVB")
    end
    
    local fileName = customName and ("SenpaiHubPVB/" .. customName .. ".json") or CONFIG_FILE
    
    local equipInt = equipInterval
    if equipIntervalInput then
        local equipValue = ""
        if equipIntervalInput.Get then
            equipValue = equipIntervalInput:Get()
        elseif equipIntervalInput.Value then
            equipValue = equipIntervalInput.Value
        end
        equipInt = tonumber(equipValue) or 20
    end
    
    currentConfig = {
        selectedSeeds = selectedSeeds,
        selectedGears = selectedGears,
        equipInterval = equipInt,
        theme = WindUI:GetCurrentTheme() or "Dark",
        autoBuySeedsEnabled = autoBuySeedsEnabled,
        autoBuyGearsEnabled = autoBuyGearsEnabled,
        autoEquipEnabled = autoEquipEnabled,
        autoBuyAllSeedsEnabled = autoBuyAllSeedsEnabled,
        autoBuyAllGearsEnabled = autoBuyAllGearsEnabled,
        antiAFKEnabled = antiAFKEnabled,
        autoReconnectEnabled = autoReconnectEnabled
    }
    
    local success = pcall(function()
        writefile(fileName, game:GetService("HttpService"):JSONEncode(currentConfig))
    end)
    
    if success then
        print("✅ Config saved to:", fileName)
        WindUI:Notify({
            Title = "Settings Saved",
            Content = "Your preferences have been saved as: " .. (customName or "PlantsBrainrot_Config"),
            Duration = 3
        })
    else
        WindUI:Notify({
            Title = "Save Failed",
            Content = "Could not save your settings. Please try again.",
            Duration = 3
        })
    end
    
    return success
end

-- Dropdown update functions
local function updateSeedDropdownProperly()
    if seedDropdown then
        task.spawn(function()
            task.wait(0.3)
            pcall(function()
                if seedDropdown.Set then
                    seedDropdown:Set(selectedSeeds)
                end
                if seedDropdown.Value ~= nil then
                    seedDropdown.Value = selectedSeeds
                end
                if Window and Window.Flags and Window.Flags.SeedSelection ~= nil then
                    Window.Flags.SeedSelection = selectedSeeds
                end
                task.wait(0.1)
                if seedDropdown.Refresh then
                    seedDropdown:Refresh(availableSeeds, selectedSeeds)
                end
            end)
        end)
    end
end

local function updateGearDropdownProperly()
    if gearDropdown then
        task.spawn(function()
            task.wait(0.3)
            pcall(function()
                if gearDropdown.Set then
                    gearDropdown:Set(selectedGears)
                end
                if gearDropdown.Value ~= nil then
                    gearDropdown.Value = selectedGears
                end
                if Window and Window.Flags and Window.Flags.GearSelection ~= nil then
                    Window.Flags.GearSelection = selectedGears
                end
                task.wait(0.1)
                if gearDropdown.Refresh then
                    gearDropdown:Refresh(availableGears, selectedGears)
                end
            end)
        end)
    end
end

local function updateAllUI()
    task.spawn(function()
        task.wait(0.3)
        
        updateSeedDropdownProperly()
        updateGearDropdownProperly()
        
        if equipIntervalInput and equipIntervalInput.Set then
            pcall(function()
                equipIntervalInput:Set(tostring(equipInterval))
            end)
        end
        
        if currentConfig.theme then
            pcall(function()
                WindUI:SetTheme(currentConfig.theme)
                if themeDropdown and themeDropdown.Set then
                    themeDropdown:Set(currentConfig.theme)
                end
            end)
        end
    end)
end

local function resetToDefault()
    selectedSeeds = {}
    selectedGears = {}
    equipInterval = defaultConfig.equipInterval
    
    task.spawn(function()
        task.wait(0.2)
        updateSeedDropdownProperly()
        updateGearDropdownProperly()
        updateAllUI()
    end)
    
    WindUI:Notify({
        Title = "Settings Reset",
        Content = "All preferences have been reset to their default values",
        Duration = 3
    })
end

-- Load settings AND config BEFORE creating UI
loadSettings()

-- If autoload is enabled, load the config NOW (before UI creation)
if currentSettings.autoLoadEnabled and currentSettings.autoLoadConfig ~= "None" then
    local configName = currentSettings.autoLoadConfig
    local filesToTry = {
        "SenpaiHubPVB/" .. configName .. ".json",
        configName .. ".json"
    }
    
    for _, file in pairs(filesToTry) do
        if file and isfile(file) then
            local success, result = pcall(function()
                local data = readfile(file)
                return game:GetService("HttpService"):JSONDecode(data)
            end)
            if success and result then
                currentConfig = result
                selectedSeeds = currentConfig.selectedSeeds or {}
                selectedGears = currentConfig.selectedGears or {}
                equipInterval = currentConfig.equipInterval or 20
                
                autoBuySeedsEnabled = currentConfig.autoBuySeedsEnabled or false
                autoBuyGearsEnabled = currentConfig.autoBuyGearsEnabled or false
                autoEquipEnabled = currentConfig.autoEquipEnabled or false
                autoBuyAllSeedsEnabled = currentConfig.autoBuyAllSeedsEnabled or false
                autoBuyAllGearsEnabled = currentConfig.autoBuyAllGearsEnabled or false
                antiAFKEnabled = currentConfig.antiAFKEnabled or false
                autoReconnectEnabled = currentConfig.autoReconnectEnabled or false
                
                -- Start systems immediately
                if antiAFKEnabled then startAntiAFK() end
                if autoReconnectEnabled then setupAutoReconnect() end
                if autoEquipEnabled then startEquipLoop() end
                
                print("✅ Pre-loaded config before UI:", configName)
                break
            end
        end
    end
end

-- Set theme to default
WindUI:SetTheme(currentConfig.theme or defaultConfig.theme)

Window = WindUI:CreateWindow({
    Title = "Senpai Hub",
    Icon = "flame",
    Author = "@senpai",
    Folder = "SenpaiHubPVB",
    Size = UDim2.fromOffset(580, 490),
    Theme = currentConfig.theme or defaultConfig.theme,
    SideBarWidth = 180,
})

Window:SetToggleKey(Enum.KeyCode.G)

Window:CreateTopbarButton("theme-switcher", "moon", function()
    local newTheme = WindUI:GetCurrentTheme() == "Dark" and "Light" or "Dark"
    WindUI:SetTheme(newTheme)
    if canChangeTheme and themeDropdown then
        themeDropdown:Set(newTheme)
    end
    WindUI:Notify({
        Title = "Theme Changed",
        Content = "Interface theme changed to: " .. newTheme,
        Duration = 2
    })
end, 990)

-- MODIFIED: Circular minimized button with gradient glow
Window:EditOpenButton({
    Title = "Senpai Hub",
    Icon = "flame",
    CornerRadius = UDim.new(1, 0),
    StrokeThickness = 3,
    Color = ColorSequence.new(
        Color3.fromRGB(255, 69, 0),
        Color3.fromRGB(255, 20, 147)
    ),
    OnlyMobile = true,
    Enabled = true,
    Draggable = true,
})

-- Create tabs
local InformationTab = Window:Tab({
    Title = "Information",
    Icon = "info",
    Locked = false
})

local AutoBuyTab = Window:Tab({
    Title = "Auto Buy",
    Icon = "shopping-cart",
    Locked = false
})

local SellTab = Window:Tab({
    Title = "Sell",
    Icon = "dollar-sign",
    Locked = false
})

local AutoEquipTab = Window:Tab({
    Title = "Auto Equip",
    Icon = "flame",
    Locked = false
})

local SettingsTab = Window:Tab({
    Title = "Settings",
    Icon = "settings",
    Locked = false
})

Window:SelectTab(1)

-- Information Tab
InformationTab:Paragraph({
    Title = "Senpai Hub for Plants vs. Brainrot",
    Desc = [[Key will auto load and work forever until I changed it so if it ask for key it means I changed it but you can get the key always.

FEATURES:

• Auto buy seeds
• Auto buy gears
• Sell all brainrot and Plants (Favorite not included)
• Auto equip your best brainrot and auto collects all money
• Anti-AFK protection
• Auto-reconnect on disconnect
• Save and load config
• Auto-load your preferred setup on startup
• Multiple theme options for personalization

CONTROLS:
• G = Show/Hide Interface
• Ctrl + B = Toggle Seed Auto-Buy
• Ctrl + N = Toggle Gear Auto-Buy  
• Ctrl + E = Toggle Auto Equipment + Auto Collect Money

Made for you with love <3]]
})

-- Auto Buy Tab
AutoBuyTab:Button({
    Title = "Open Seed Shop",
    Icon = "plant",
    Variant = "Primary",
    Callback = function()
        local success = openSeedShop()
        WindUI:Notify({
            Title = success and "Seed Shop Opened" or "Shop Access Failed",
            Content = success and "You can now browse and purchase seeds" or "Unable to access the seed shop",
            Duration = 3
        })
    end
})

AutoBuyTab:Button({
    Title = "Open Gear Shop",
    Icon = "wrench",
    Variant = "Secondary", 
    Callback = function()
        local success = openGearShop()
        WindUI:Notify({
            Title = success and "Gear Shop Opened" or "Shop Access Failed",
            Content = success and "You can now browse and purchase gears" or "Unable to access the gear shop",
            Duration = 3
        })
    end
})

AutoBuyTab:Divider()

seedDropdown = AutoBuyTab:Dropdown({
    Title = "Select Seeds",
    Values = availableSeeds,
    Value = selectedSeeds,
    SearchBarEnabled = true,
    MenuWidth = 400,
    Multi = true,
    Flag = "SeedSelection",
    Callback = function(value)
        selectedSeeds = value
    end
})

autoBuyToggleSeeds = AutoBuyTab:Toggle({
    Title = "Enable Auto Buy Seeds",
    Desc = "Automatically buy your selected seeds (Use Ctrl+B to toggle quickly)",
    Value = autoBuySeedsEnabled,
    Callback = function(enabled)
        autoBuySeedsEnabled = enabled
        if enabled then
            WindUI:Notify({
                Title = "Seed Auto Buy Started",
                Content = string.format("Now automatically purchasing %d seed types", #selectedSeeds),
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "Seed Auto Buy Stopped",
                Content = "Automatic seed purchasing has been disabled",
                Duration = 2
            })
        end
    end
})

autoBuyAllSeedsToggle = AutoBuyTab:Toggle({
    Title = "Auto Buy All Seeds",
    Desc = "Purchase all 14 available seed types automatically",
    Value = autoBuyAllSeedsEnabled,
    Callback = function(enabled)
        autoBuyAllSeedsEnabled = enabled
        if enabled then
            WindUI:Notify({
                Title = "Buying All Seeds",
                Content = string.format("Now purchasing all %d seed types automatically", #availableSeeds),
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "Stopped Buying All Seeds", 
                Content = "Switched back to your selected seeds only",
                Duration = 2
            })
        end
    end
})

AutoBuyTab:Divider()

gearDropdown = AutoBuyTab:Dropdown({
    Title = "Select Gears",
    Values = availableGears,
    Value = selectedGears,
    SearchBarEnabled = true,
    MenuWidth = 400,
    Multi = true,
    Flag = "GearSelection",
    Callback = function(value)
        selectedGears = value
    end
})

autoBuyToggleGears = AutoBuyTab:Toggle({
    Title = "Enable Auto Buy Gears",
    Desc = "Automatically buy your selected gears (Use Ctrl+N to toggle quickly)",
    Value = autoBuyGearsEnabled,
    Callback = function(enabled)
        autoBuyGearsEnabled = enabled
        if enabled then
            WindUI:Notify({
                Title = "Gear Auto Buy Started",
                Content = string.format("Now automatically purchasing %d gear types", #selectedGears),
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "Gear Auto Buy Stopped",
                Content = "Automatic gear purchasing has been disabled",
                Duration = 2
            })
        end
    end
})

autoBuyAllGearsToggle = AutoBuyTab:Toggle({
    Title = "Auto Buy All Gears",
    Desc = "Purchase all 5 available gear types automatically",
    Value = autoBuyAllGearsEnabled,
    Callback = function(enabled)
        autoBuyAllGearsEnabled = enabled
        if enabled then
            WindUI:Notify({
                Title = "Buying ALL Gears",
                Content = string.format("Now purchasing all %d gear types automatically", #availableGears),
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "Stopped Buying All Gears",
                Content = "Switched back to your selected gears only",
                Duration = 2
            })
        end
    end
})

-- Sell Tab
SellTab:Paragraph({
    Title = "Note:",
    Desc = "Your favorited brainrots are not included when you sell all.",
    Image = "dollar-sign",
    ImageSize = 20,
    Color = "White"
})

SellTab:Button({
    Title = "Sell All Brainrots",
    Icon = "brain-circuit",
    Variant = "Primary",
    Callback = function()
        local success = sellAllBrainrots()
        WindUI:Notify({
            Title = success and "Brainrots Sold" or "Sale Failed",
            Content = success and "All brainrots in your inventory have been sold" or "Unable to sell brainrots right now",
            Duration = 3
        })
    end
})

SellTab:Button({
    Title = "Sell All Plants",
    Icon = "leaf",
    Variant = "Secondary",
    Callback = function()
        local success = sellAllPlants()
        WindUI:Notify({
            Title = success and "Plants Sold" or "Sale Failed",
            Content = success and "All plants in your inventory have been sold" or "Unable to sell plants right now",
            Duration = 3
        })
    end
})

SellTab:Button({
    Title = "Sell Everything",
    Icon = "trash-2",
    Variant = "Destructive",
    Callback = function()
        local brainrotSuccess = sellAllBrainrots()
        task.wait(0.5)
        local plantSuccess = sellAllPlants()
        
        local bothSuccess = brainrotSuccess and plantSuccess
        WindUI:Notify({
            Title = bothSuccess and "Everything Sold" or "Partial Sale",
            Content = bothSuccess and "Your entire inventory has been cleared" or "Some items couldn't be sold",
            Duration = 3
        })
    end
})

-- Auto Equip Tab
AutoEquipTab:Paragraph({
    Title = "Auto Equip Brainrots + Collect All Money",
    Desc = "Useful when you need to collect all money from your brainrots",
    Image = "flame",
    ImageSize = 20,
    Color = "White"
})

equipIntervalInput = AutoEquipTab:Input({
    Title = "Auto Equip Interval (seconds)",
    Desc = "How often to automatically equip your best brainrots (default: 20 seconds)",
    Value = tostring(equipInterval)
})

AutoEquipTab:Button({
    Title = "Apply Interval",
    Icon = "clock",
    Variant = "Secondary",
    Callback = function()
        applyEquipInterval()
    end
})

autoEquipToggle = AutoEquipTab:Toggle({
    Title = "Enable Auto Equip + Collect All Money",
    Desc = "Automatically equip your best brainrot and collects all money from your brainrots (Use Ctrl+E to toggle quickly)",
    Value = autoEquipEnabled,
    Callback = function(enabled)
        autoEquipEnabled = enabled
        if enabled then
            startEquipLoop()
            WindUI:Notify({
                Title = "Auto Equipment Started",
                Content = string.format("Now auto-equipping best brainrot every %d seconds", equipInterval),
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "Auto Equipment Stopped",
                Content = "Automatic equipment has been disabled",
                Duration = 2
            })
        end
    end
})

AutoEquipTab:Button({
    Title = "Equip Best Brainrots",
    Icon = "flame",
    Variant = "Primary",
    Callback = function()
        local success = equipBest()
        WindUI:Notify({
            Title = success and "Equip Success" or "Equip Failed",
            Content = success and "Your best brainrots has been equipped" or "Unable to update equipment right now",
            Duration = 3
        })
    end
})

-- Settings Tab
SettingsTab:Paragraph({
    Title = "Personalization & Data Management",
    Desc = "Customize your interface and manage your saved configurations for quick setup across sessions.",
    Image = "palette",
    ImageSize = 20,
    Color = "White"
})

local themes = {}
for themeName, _ in pairs(WindUI:GetThemes()) do
    table.insert(themes, themeName)
end
table.sort(themes)

themeDropdown = SettingsTab:Dropdown({
    Title = "Interface Theme",
    Values = themes,
    SearchBarEnabled = true,
    MenuWidth = 280,
    Value = WindUI:GetCurrentTheme(),
    Callback = function(theme)
        canChangeDropdown = false
        WindUI:SetTheme(theme)
        WindUI:Notify({
            Title = "Theme Applied",
            Content = "Interface changed to " .. theme .. " theme",
            Icon = "palette",
            Duration = 2
        })
        canChangeDropdown = true
    end
})

SettingsTab:Divider()

SettingsTab:Paragraph({
    Title = "Connection & Activity",
    Desc = "Manage anti-AFK and auto-reconnect features for uninterrupted gameplay.",
    Image = "wifi",
    ImageSize = 20,
    Color = "White"
})

autoReconnectToggle = SettingsTab:Toggle({
    Title = "Enable Auto-Reconnect",
    Desc = "Automatically rejoin the game if disconnected due to network issues",
    Value = autoReconnectEnabled,
    Callback = function(enabled)
        autoReconnectEnabled = enabled
        reconnectAttempts = 0
        if enabled then
            setupAutoReconnect()
            WindUI:Notify({
                Title = "Auto-Reconnect Enabled",
                Content = string.format("Will attempt to reconnect up to %d times if disconnected", MAX_RECONNECT_ATTEMPTS),
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "Auto-Reconnect Disabled",
                Content = "Manual reconnection required if disconnected",
                Duration = 2
            })
        end
    end
})

antiAFKToggle = SettingsTab:Toggle({
    Title = "Enable Anti-AFK Protection",
    Desc = "Prevents Roblox from kicking you for inactivity",
    Value = antiAFKEnabled,
    Callback = function(enabled)
        antiAFKEnabled = enabled
        if enabled then
            startAntiAFK()
            WindUI:Notify({
                Title = "Anti-AFK Enabled",
                Content = "You will no longer be kicked for inactivity",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "Anti-AFK Disabled",
                Content = "Inactivity kick protection has been turned off",
                Duration = 2
            })
        end
    end
})

SettingsTab:Divider()

SettingsTab:Paragraph({
    Title = "Startup Configuration",
    Desc = "Choose a saved configuration to automatically load when you start the script.",
    Image = "settings-2",
    ImageSize = 20,
    Color = "White"
})

autoLoadToggle = SettingsTab:Toggle({
    Title = "Enable Auto-Load",
    Desc = "Automatically load your chosen configuration when the script starts",
    Value = currentSettings.autoLoadEnabled or false,
    Callback = function(state)
        currentSettings.autoLoadEnabled = state
        saveSettings()
        WindUI:Notify({
            Title = "Auto-Load " .. (state and "Enabled" or "Disabled"),
            Content = "Startup configuration " .. (state and "will now load automatically" or "disabled"),
            Duration = 2
        })
    end
})

local availableConfigs = getAvailableConfigs()
autoLoadDropdown = SettingsTab:Dropdown({
    Title = "Startup Configuration",
    Values = availableConfigs,
    Value = currentSettings.autoLoadConfig or "None",
    SearchBarEnabled = true,
    MenuWidth = 280,
    Callback = function(config)
        currentSettings.autoLoadConfig = config
        saveSettings()
        WindUI:Notify({
            Title = "Startup Config Set",
            Content = "Will auto-load: " .. config,
            Duration = 2
        })
    end
})

SettingsTab:Button({
    Title = "Refresh Configuration List",
    Icon = "refresh-cw",
    Callback = function()
        local newConfigs = getAvailableConfigs()
        if autoLoadDropdown and autoLoadDropdown.Refresh then
            autoLoadDropdown:Refresh(newConfigs)
        end
        WindUI:Notify({
            Title = "List Updated",
            Content = "Found " .. math.max(0, #newConfigs - 1) .. " saved configurations",
            Duration = 2
        })
    end
})

SettingsTab:Divider()

SettingsTab:Paragraph({
    Title = "Save & Load Configurations",
    Desc = "Save your current preferences or load previously saved configurations for quick setup.",
    Image = "save",
    ImageSize = 20,
    Color = "White"
})

local configName = "senpai-hub-pvb"

ConfigNameInput = SettingsTab:Input({
    Title = "Configuration Name",
    Value = configName,
    Callback = function(value)
        configName = value or "senpai-hub-pvb"
    end
})

SettingsTab:Button({
    Title = "Save Current Settings",
    Icon = "save",
    Variant = "Primary",
    Callback = function()
        local name = configName
        if ConfigNameInput and ConfigNameInput.Get then
            name = ConfigNameInput:Get() or configName
        end
        saveConfig(name)
    end
})

SettingsTab:Button({
    Title = "Load Saved Settings",
    Icon = "folder-open",
    Variant = "Secondary",
    Callback = function()
        local name = configName
        if ConfigNameInput and ConfigNameInput.Get then
            name = ConfigNameInput:Get() or configName
        end
        
        local filesToTry = {"SenpaiHubPVB/" .. name .. ".json", name .. ".json"}
        local loaded = false
        for _, file in pairs(filesToTry) do
            if file and isfile(file) then
                local success, result = pcall(function()
                    return game:GetService("HttpService"):JSONDecode(readfile(file))
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
                    
                    -- Start systems
                    if antiAFKEnabled then startAntiAFK() end
                    if autoReconnectEnabled then setupAutoReconnect() end
                    if autoEquipEnabled then startEquipLoop() end
                    
                    -- Update toggles
                    if autoBuyToggleSeeds then autoBuyToggleSeeds.Value = autoBuySeedsEnabled end
                    if autoBuyToggleGears then autoBuyToggleGears.Value = autoBuyGearsEnabled end
                    if autoEquipToggle then autoEquipToggle.Value = autoEquipEnabled end
                    if autoBuyAllSeedsToggle then autoBuyAllSeedsToggle.Value = autoBuyAllSeedsEnabled end
                    if autoBuyAllGearsToggle then autoBuyAllGearsToggle.Value = autoBuyAllGearsEnabled end
                    if antiAFKToggle then antiAFKToggle.Value = antiAFKEnabled end
                    if autoReconnectToggle then autoReconnectToggle.Value = autoReconnectEnabled end
                    
                    updateAllUI()
                    loaded = true
                    WindUI:Notify({
                        Title = "Settings Loaded",
                        Content = name .. " loaded - Seeds: " .. #selectedSeeds .. ", Gears: " .. #selectedGears,
                        Duration = 3
                    })
                    break
                end
            end
        end
        
        if not loaded then
            WindUI:Notify({
                Title = "Load Failed", 
                Content = "Could not find: " .. name,
                Duration = 3
            })
        end
    end
})

SettingsTab:Button({
    Title = "Reset All Settings",
    Icon = "rotate-ccw",
    Variant = "Destructive",
    Callback = function()
        resetToDefault()
    end
})

-- Initialize keybinds
setupKeybinds()

-- UNIFIED AUTO-BUY LOOP
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

-- Startup notification
task.spawn(function()
    task.wait(1)
    WindUI:Notify({
        Title = "Senpai Hub Ready",
        Content = string.format("Welcome! %s\nSeeds: %d | Gears: %d | Interval: %ds\n\nPress G to toggle interface", 
            currentSettings.autoLoadEnabled and currentSettings.autoLoadConfig ~= "None" and ("Auto-loaded: " .. currentSettings.autoLoadConfig) or "Enjoy using my scripts!",
            #selectedSeeds,
            #selectedGears,
            equipInterval),
        Duration = 8
    })
end)

task.spawn(function()
    while task.wait(0.1) do
    end
end)
