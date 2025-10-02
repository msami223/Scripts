-- Roblox Services
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Script Constants
local LOG_ENTRY_LIMIT = 700
local SETTINGS_FILE = "gag_autobuy_seeds_settings.json"
local ALL_FRUITS_AND_VEGETABLES = {
    "Daffodil", "Coconut", "Apple", "Pumpkin", "Pepper", "Cacao",
    "Orange Tulip", "Carrot", "Mango", "Tomato", "Blueberry", "Strawberry",
    "Beanstalk", "Mushroom", "Grape", "Dragon Fruit", "Cactus", "Bamboo",
    "Watermelon", "Corn"
}

-- Global Variables
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local DataStreamEvent = ReplicatedStorage.GameEvents.DataStream
local BuyRemote = ReplicatedStorage.GameEvents.BuySeedStock

-- default configs (you can change these w the GUI dw)
local config = {
    retryDelay = 0.2,
    isRunning = false,
    guiVisible = true,
    selectedItems = {}
}

local currentStocks = {}
local logEntries = {}
local guiElements = {} -- To store GUI object references

-- Initialize default selected items and current stocks
for _, item in ipairs(ALL_FRUITS_AND_VEGETABLES) do
    config.selectedItems[item] = true -- Default to all selected
    currentStocks[item] = { Stock = 0, MaxStock = 0 }
end

--[[-----------------------------------------------------------------------------
    Settings Management
-------------------------------------------------------------------------------]]

local SettingsManager = {}

function SettingsManager.load()
    
    local success, fileContent = pcall(function()
        return readfile(SETTINGS_FILE)
    end)

    if success and fileContent then

        local decodeSuccess, decodedJson = pcall(function()
            return HttpService:JSONDecode(fileContent)
        end)

        if decodeSuccess and type(decodedJson) == "table" then

            for key, value in pairs(decodedJson) do

                if config[key] ~= nil and key ~= "selectedItems" then
                    config[key] = value
                end

            end

            local loadedSelectedItems = decodedJson.selectedItems

            if type(loadedSelectedItems) == "table" then

                local newSelectedItems = {}

                for _, itemFullName in ipairs(ALL_FRUITS_AND_VEGETABLES) do
                    newSelectedItems[itemFullName] = (loadedSelectedItems[itemFullName] ~= nil and loadedSelectedItems[itemFullName] == true) or (loadedSelectedItems[itemFullName] == nil and true)
                end

                config.selectedItems = newSelectedItems
            else
                for _, itemFullName in ipairs(ALL_FRUITS_AND_VEGETABLES) do
                    config.selectedItems[itemFullName] = true
                end
            end
            print("⚙️ Settings loaded from " .. SETTINGS_FILE)
        else
            print("❌ Error decoding settings JSON or not a table: " .. (decodeSuccess and "Invalid JSON format" or tostring(decodedJson)))
            print("⚠️ Using default settings for all.")
            SettingsManager.applyDefaults()
        end

    else
        print("⚠️ Could not read settings file: " .. SETTINGS_FILE .. ". Using default settings. Error: " .. tostring(fileContent))
        SettingsManager.applyDefaults()
    end

end

function SettingsManager.save()

    local currentConfigToSave = table.clone(config)

    local validSelectedItems = {}

    for _, item in ipairs(ALL_FRUITS_AND_VEGETABLES) do
        validSelectedItems[item] = config.selectedItems[item] or false
    end

    currentConfigToSave.selectedItems = validSelectedItems

    local successEncode, jsonString = pcall(function()
        return HttpService:JSONEncode(currentConfigToSave)
    end)

    if not successEncode then
        print("❌ Error encoding settings to JSON: " .. tostring(jsonString))
        return
    end

    local successWrite, writeError = pcall(function()
        writefile(SETTINGS_FILE, jsonString)
    end)

    if successWrite then
        print("💾 Settings saved to " .. SETTINGS_FILE)
    else
        print("❌ Error saving settings: " .. tostring(writeError))
    end

end

function SettingsManager.applyDefaults()
    config.retryDelay = 0.2
    config.isRunning = false
    config.guiVisible = true
    config.selectedItems = {}
    for _, item in ipairs(ALL_FRUITS_AND_VEGETABLES) do
        config.selectedItems[item] = true
    end
    print("⚙️ Default settings applied.")
end


--[[-----------------------------------------------------------------------------
    GUI Management
-------------------------------------------------------------------------------]]

local GUIManager = {}

function GUIManager.updateLog(message)

    if not guiElements.logScrollFrame then return end

    local timestamp = os.date("[%H:%M:%S] ")
    local fullMessage = timestamp .. message

    table.insert(logEntries, fullMessage)

    if #logEntries > LOG_ENTRY_LIMIT then
        table.remove(logEntries, 1)
    end

    for _, child in ipairs(guiElements.logScrollFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    local totalHeight = 0

    for i, entry in ipairs(logEntries) do

        local logEntryLabel = Instance.new("TextLabel")

        logEntryLabel.Name = "LogEntry" .. i
        logEntryLabel.Parent = guiElements.logScrollFrame
        logEntryLabel.BackgroundTransparency = 1
        logEntryLabel.Size = UDim2.new(1, -10, 0, 16) 
        logEntryLabel.Font = Enum.Font.GothamMedium
        logEntryLabel.Text = entry
        logEntryLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
        logEntryLabel.TextSize = 13
        logEntryLabel.TextXAlignment = Enum.TextXAlignment.Left
        logEntryLabel.TextYAlignment = Enum.TextYAlignment.Top
        logEntryLabel.TextWrapped = true
        logEntryLabel.LayoutOrder = i

        totalHeight = totalHeight + 18

    end

    guiElements.logScrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)

    task.wait()
    guiElements.logScrollFrame.CanvasPosition = Vector2.new(0, math.max(0, totalHeight - guiElements.logScrollFrame.AbsoluteSize.Y))

end

function GUIManager.create()

    -- Main ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GAGAutoBuySeedsGUI"
    screenGui.Parent = playerGui
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    guiElements.screenGui = screenGui

    -- Floating Toggle Button (Modernized)
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "FloatingToggleButton"
    toggleButton.Parent = screenGui
    toggleButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    toggleButton.BorderSizePixel = 0
    toggleButton.AnchorPoint = Vector2.new(1, 1)
    toggleButton.Position = UDim2.new(1, -20, 1, -20)
    toggleButton.Size = UDim2.new(0, 60, 0, 60)
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.Text = "🌱"
    toggleButton.TextColor3 = Color3.new(1, 1, 1)
    toggleButton.TextSize = 28
    toggleButton.ZIndex = 1000
    
    local toggleCorner = Instance.new("UICorner", toggleButton)
    toggleCorner.CornerRadius = UDim.new(0.5, 0)
    
    local toggleShadow = Instance.new("ImageLabel", toggleButton)
    toggleShadow.Name = "Shadow"
    toggleShadow.BackgroundTransparency = 1
    toggleShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    toggleShadow.Size = UDim2.new(1, 20, 1, 20)
    toggleShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    toggleShadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    toggleShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    toggleShadow.ImageTransparency = 0.7
    toggleShadow.ZIndex = 999
    
    guiElements.toggleButton = toggleButton

    -- Main Frame (Glassmorphic Design)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -280)
    mainFrame.Size = UDim2.new(0, 400, 0, 560)
    mainFrame.Active = true
    mainFrame.Visible = config.guiVisible
    mainFrame.ClipsDescendants = false
    
    local mainCorner = Instance.new("UICorner", mainFrame)
    mainCorner.CornerRadius = UDim.new(0, 16)
    
    local mainStroke = Instance.new("UIStroke", mainFrame)
    mainStroke.Color = Color3.fromRGB(60, 60, 80)
    mainStroke.Thickness = 1
    mainStroke.Transparency = 0.5
    
    guiElements.mainFrame = mainFrame
    
    -- Make frame draggable
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    local function updateDrag(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                updateDrag(input)
            end
        end
    end)
    
    -- Resize Handle (Bottom-Right Corner)
    local resizeHandle = Instance.new("Frame")
    resizeHandle.Name = "ResizeHandle"
    resizeHandle.Parent = mainFrame
    resizeHandle.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    resizeHandle.BorderSizePixel = 0
    resizeHandle.AnchorPoint = Vector2.new(1, 1)
    resizeHandle.Position = UDim2.new(1, 0, 1, 0)
    resizeHandle.Size = UDim2.new(0, 20, 0, 20)
    resizeHandle.ZIndex = 100
    
    local resizeCorner = Instance.new("UICorner", resizeHandle)
    resizeCorner.CornerRadius = UDim.new(0, 0)
    
    -- Resize icon (3 diagonal lines)
    local resizeIcon = Instance.new("TextLabel")
    resizeIcon.Parent = resizeHandle
    resizeIcon.BackgroundTransparency = 1
    resizeIcon.Size = UDim2.new(1, 0, 1, 0)
    resizeIcon.Font = Enum.Font.GothamBold
    resizeIcon.Text = "⋰"
    resizeIcon.TextColor3 = Color3.fromRGB(150, 150, 170)
    resizeIcon.TextSize = 16
    resizeIcon.Rotation = 90
    resizeIcon.ZIndex = 101
    
    -- Make frame resizable
    local resizing = false
    local resizeStart = nil
    local startSize = nil
    local minSize = Vector2.new(350, 450)
    local maxSize = Vector2.new(800, 900)
    
    local function updateResize(input)
        local delta = input.Position - resizeStart
        local newWidth = math.clamp(startSize.X + delta.X, minSize.X, maxSize.X)
        local newHeight = math.clamp(startSize.Y + delta.Y, minSize.Y, maxSize.Y)
        mainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
    end
    
    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            resizeStart = input.Position
            startSize = mainFrame.AbsoluteSize
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resizing = false
                end
            end)
        end
    end)
    
    resizeHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if resizing then
                updateResize(input)
            end
        end
    end)

    -- Header Section
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Parent = mainFrame
    header.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    header.BorderSizePixel = 0
    header.Size = UDim2.new(1, 0, 0, 65)
    
    local headerCorner = Instance.new("UICorner", header)
    headerCorner.CornerRadius = UDim.new(0, 16)
    
    local headerBottom = Instance.new("Frame", header)
    headerBottom.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    headerBottom.BorderSizePixel = 0
    headerBottom.Position = UDim2.new(0, 0, 1, -16)
    headerBottom.Size = UDim2.new(1, 0, 0, 16)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Parent = header
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 20, 0, 10)
    titleLabel.Size = UDim2.new(1, -100, 0, 24)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = "SlowMo Hub"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 20
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Name = "SubtitleLabel"
    subtitleLabel.Parent = header
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Position = UDim2.new(0, 20, 0, 35)
    subtitleLabel.Size = UDim2.new(1, -100, 0, 20)
    subtitleLabel.Font = Enum.Font.Gotham
    subtitleLabel.Text = "Garden Auto Buy Seeds"
    subtitleLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
    subtitleLabel.TextSize = 14
    subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Close Button (Modern X)
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Parent = header
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 59, 48)
    closeButton.BorderSizePixel = 0
    closeButton.Position = UDim2.new(1, -45, 0, 20)
    closeButton.Size = UDim2.new(0, 28, 0, 28)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.TextSize = 20
    
    local closeCorner = Instance.new("UICorner", closeButton)
    closeCorner.CornerRadius = UDim.new(0.5, 0)
    
    guiElements.closeButton = closeButton

    -- Content Container
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Parent = mainFrame
    contentFrame.BackgroundTransparency = 1
    contentFrame.Position = UDim2.new(0, 15, 0, 75)
    contentFrame.Size = UDim2.new(1, -30, 1, -85)

    -- Control Buttons (Modern Cards)
    local controlFrame = Instance.new("Frame")
    controlFrame.Name = "ControlFrame"
    controlFrame.Parent = contentFrame
    controlFrame.BackgroundTransparency = 1
    controlFrame.Size = UDim2.new(1, 0, 0, 55)
    
    local controlLayout = Instance.new("UIListLayout", controlFrame)
    controlLayout.FillDirection = Enum.FillDirection.Horizontal
    controlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    controlLayout.SortOrder = Enum.SortOrder.LayoutOrder
    controlLayout.Padding = UDim.new(0, 12)

    -- Start/Stop Button
    local startStopButton = Instance.new("TextButton")
    startStopButton.Name = "StartStopButton"
    startStopButton.Parent = controlFrame
    startStopButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    startStopButton.BorderSizePixel = 0
    startStopButton.Size = UDim2.new(0.48, 0, 1, 0)
    startStopButton.Font = Enum.Font.GothamBold
    startStopButton.Text = "▶ START"
    startStopButton.TextColor3 = Color3.new(1, 1, 1)
    startStopButton.TextSize = 15
    
    local startCorner = Instance.new("UICorner", startStopButton)
    startCorner.CornerRadius = UDim.new(0, 10)
    
    guiElements.startStopButton = startStopButton

    -- Settings Button
    local settingsButton = Instance.new("TextButton")
    settingsButton.Name = "SettingsButton"
    settingsButton.Parent = controlFrame
    settingsButton.BackgroundColor3 = Color3.fromRGB(90, 90, 120)
    settingsButton.BorderSizePixel = 0
    settingsButton.Size = UDim2.new(0.48, 0, 1, 0)
    settingsButton.Font = Enum.Font.GothamBold
    settingsButton.Text = "⚙ SETTINGS"
    settingsButton.TextColor3 = Color3.new(1, 1, 1)
    settingsButton.TextSize = 15
    
    local settingsCorner = Instance.new("UICorner", settingsButton)
    settingsCorner.CornerRadius = UDim.new(0, 10)
    
    guiElements.settingsButton = settingsButton

    -- Plant Selection Card
    local plantFrame = Instance.new("Frame")
    plantFrame.Name = "PlantFrame"
    plantFrame.Parent = contentFrame
    plantFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    plantFrame.BorderSizePixel = 0
    plantFrame.Position = UDim2.new(0, 0, 0, 65)
    plantFrame.Size = UDim2.new(1, 0, 0, 200)
    
    local plantCorner = Instance.new("UICorner", plantFrame)
    plantCorner.CornerRadius = UDim.new(0, 12)

    local plantTitle = Instance.new("TextLabel")
    plantTitle.Name = "PlantTitle"
    plantTitle.Parent = plantFrame
    plantTitle.BackgroundTransparency = 1
    plantTitle.Position = UDim2.new(0, 15, 0, 10)
    plantTitle.Size = UDim2.new(1, -30, 0, 25)
    plantTitle.Font = Enum.Font.GothamBold
    plantTitle.Text = "Select Plants to Buy"
    plantTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    plantTitle.TextSize = 15
    plantTitle.TextXAlignment = Enum.TextXAlignment.Left

    -- Plant Scroll
    local plantScrollFrame = Instance.new("ScrollingFrame")
    plantScrollFrame.Name = "PlantScrollFrame"
    plantScrollFrame.Parent = plantFrame
    plantScrollFrame.BackgroundTransparency = 1
    plantScrollFrame.Position = UDim2.new(0, 10, 0, 40)
    plantScrollFrame.Size = UDim2.new(1, -20, 1, -50)
    plantScrollFrame.ScrollBarThickness = 4
    plantScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 130)
    plantScrollFrame.BorderSizePixel = 0
    
    guiElements.plantScrollFrame = plantScrollFrame

    local plantLayout = Instance.new("UIListLayout", plantScrollFrame)
    plantLayout.Padding = UDim.new(0, 6)
    plantLayout.SortOrder = Enum.SortOrder.Name

    guiElements.plantCheckboxes = {}

    for _, plantName in ipairs(ALL_FRUITS_AND_VEGETABLES) do

        local checkFrame = Instance.new("Frame")
        checkFrame.Name = plantName .. "Frame"
        checkFrame.Parent = plantScrollFrame
        checkFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        checkFrame.BorderSizePixel = 0
        checkFrame.Size = UDim2.new(1, 0, 0, 32)
        
        local checkCorner = Instance.new("UICorner", checkFrame)
        checkCorner.CornerRadius = UDim.new(0, 8)

        local checkbox = Instance.new("TextButton")
        checkbox.Name = plantName .. "Checkbox"
        checkbox.Parent = checkFrame
        checkbox.BorderSizePixel = 0
        checkbox.Position = UDim2.new(0, 8, 0.5, -12)
        checkbox.Size = UDim2.new(0, 24, 0, 24)
        checkbox.Font = Enum.Font.GothamBold
        checkbox.TextColor3 = Color3.new(1, 1, 1)
        checkbox.TextSize = 16
        
        local checkboxCorner = Instance.new("UICorner", checkbox)
        checkboxCorner.CornerRadius = UDim.new(0, 6)

        local plantLabel = Instance.new("TextLabel")
        plantLabel.Name = plantName .. "Label"
        plantLabel.Parent = checkFrame
        plantLabel.BackgroundTransparency = 1
        plantLabel.Position = UDim2.new(0, 40, 0, 0)
        plantLabel.Size = UDim2.new(1, -45, 1, 0)
        plantLabel.Font = Enum.Font.Gotham
        plantLabel.Text = plantName
        plantLabel.TextColor3 = Color3.fromRGB(220, 220, 235)
        plantLabel.TextSize = 14
        plantLabel.TextXAlignment = Enum.TextXAlignment.Left

        guiElements.plantCheckboxes[plantName] = checkbox

        if config.selectedItems[plantName] then
            checkbox.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
            checkbox.Text = "✓"
        else
            checkbox.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            checkbox.Text = ""
        end

    end

    plantScrollFrame.CanvasSize = UDim2.new(0, 0, 0, #ALL_FRUITS_AND_VEGETABLES * 38)

    -- Log Card
    local logFrame = Instance.new("Frame")
    logFrame.Name = "LogFrame"
    logFrame.Parent = contentFrame
    logFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    logFrame.BorderSizePixel = 0
    logFrame.Position = UDim2.new(0, 0, 0, 275)
    logFrame.Size = UDim2.new(1, 0, 1, -275)
    
    local logCorner = Instance.new("UICorner", logFrame)
    logCorner.CornerRadius = UDim.new(0, 12)

    local logTitle = Instance.new("TextLabel")
    logTitle.Name = "LogTitle"
    logTitle.Parent = logFrame
    logTitle.BackgroundTransparency = 1
    logTitle.Position = UDim2.new(0, 15, 0, 10)
    logTitle.Size = UDim2.new(1, -30, 0, 25)
    logTitle.Font = Enum.Font.GothamBold
    logTitle.Text = "Activity Log"
    logTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    logTitle.TextSize = 15
    logTitle.TextXAlignment = Enum.TextXAlignment.Left

    local logScrollFrame = Instance.new("ScrollingFrame")
    logScrollFrame.Name = "LogScrollFrame"
    logScrollFrame.Parent = logFrame
    logScrollFrame.BackgroundTransparency = 1
    logScrollFrame.Position = UDim2.new(0, 10, 0, 40)
    logScrollFrame.Size = UDim2.new(1, -20, 1, -50)
    logScrollFrame.ScrollBarThickness = 4
    logScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 130)
    logScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    logScrollFrame.BorderSizePixel = 0
    
    guiElements.logScrollFrame = logScrollFrame

    local logLayout = Instance.new("UIListLayout", logScrollFrame)
    logLayout.Padding = UDim.new(0, 3)
    logLayout.SortOrder = Enum.SortOrder.LayoutOrder
    guiElements.logLayout = logLayout

    -- Settings Frame (Modern Modal)
    local settingsFrame = Instance.new("Frame")
    settingsFrame.Name = "SettingsFrame"
    settingsFrame.Parent = screenGui
    settingsFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
    settingsFrame.BorderSizePixel = 0
    settingsFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    settingsFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    settingsFrame.Size = UDim2.new(0, 380, 0, 240)
    settingsFrame.Visible = false
    settingsFrame.Active = true
    settingsFrame.ZIndex = 1001
    
    local settingsCorner = Instance.new("UICorner", settingsFrame)
    settingsCorner.CornerRadius = UDim.new(0, 16)
    
    local settingsStroke = Instance.new("UIStroke", settingsFrame)
    settingsStroke.Color = Color3.fromRGB(60, 60, 80)
    settingsStroke.Thickness = 1
    
    guiElements.settingsFrame = settingsFrame

    local settingsTitleBar = Instance.new("Frame")
    settingsTitleBar.Name = "SettingsTitleBar"
    settingsTitleBar.Parent = settingsFrame
    settingsTitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 52)
    settingsTitleBar.BorderSizePixel = 0
    settingsTitleBar.Size = UDim2.new(1, 0, 0, 55)
    settingsTitleBar.ZIndex = 1002
    
    local settingsTitleCorner = Instance.new("UICorner", settingsTitleBar)
    settingsTitleCorner.CornerRadius = UDim.new(0, 16)
    
    local settingsTitleBottom = Instance.new("Frame", settingsTitleBar)
    settingsTitleBottom.BackgroundColor3 = Color3.fromRGB(35, 35, 52)
    settingsTitleBottom.BorderSizePixel = 0
    settingsTitleBottom.Position = UDim2.new(0, 0, 1, -16)
    settingsTitleBottom.Size = UDim2.new(1, 0, 0, 16)
    settingsTitleBottom.ZIndex = 1002

    local settingsTitleLabel = Instance.new("TextLabel")
    settingsTitleLabel.Parent = settingsTitleBar
    settingsTitleLabel.BackgroundTransparency = 1
    settingsTitleLabel.Position = UDim2.new(0, 20, 0, 0)
    settingsTitleLabel.Size = UDim2.new(1, -60, 1, 0)
    settingsTitleLabel.Font = Enum.Font.GothamBold
    settingsTitleLabel.Text = "⚙ Settings"
    settingsTitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    settingsTitleLabel.TextSize = 18
    settingsTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    settingsTitleLabel.ZIndex = 1003

    local settingsCloseButton = Instance.new("TextButton")
    settingsCloseButton.Parent = settingsTitleBar
    settingsCloseButton.BackgroundColor3 = Color3.fromRGB(255, 59, 48)
    settingsCloseButton.BorderSizePixel = 0
    settingsCloseButton.Position = UDim2.new(1, -40, 0.5, -14)
    settingsCloseButton.Size = UDim2.new(0, 28, 0, 28)
    settingsCloseButton.Font = Enum.Font.GothamBold
    settingsCloseButton.Text = "×"
    settingsCloseButton.TextColor3 = Color3.new(1, 1, 1)
    settingsCloseButton.TextSize = 20
    settingsCloseButton.ZIndex = 1003
    
    local settingsCloseCorner = Instance.new("UICorner", settingsCloseButton)
    settingsCloseCorner.CornerRadius = UDim.new(0.5, 0)
    
    guiElements.settingsCloseButton = settingsCloseButton

    local settingsContent = Instance.new("Frame")
    settingsContent.Parent = settingsFrame
    settingsContent.BackgroundTransparency = 1
    settingsContent.Position = UDim2.new(0, 20, 0, 70)
    settingsContent.Size = UDim2.new(1, -40, 1, -130)
    settingsContent.ZIndex = 1002

    local retryDelayLabel = Instance.new("TextLabel")
    retryDelayLabel.Parent = settingsContent
    retryDelayLabel.BackgroundTransparency = 1
    retryDelayLabel.Size = UDim2.new(1, 0, 0, 22)
    retryDelayLabel.Font = Enum.Font.GothamBold
    retryDelayLabel.Text = "Buy Delay (seconds)"
    retryDelayLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    retryDelayLabel.TextSize = 15
    retryDelayLabel.TextXAlignment = Enum.TextXAlignment.Left
    retryDelayLabel.ZIndex = 1003

    local retryDelayBox = Instance.new("TextBox")
    retryDelayBox.Parent = settingsContent
    retryDelayBox.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    retryDelayBox.BorderSizePixel = 0
    retryDelayBox.Position = UDim2.new(0, 0, 0, 30)
    retryDelayBox.Size = UDim2.new(1, 0, 0, 40)
    retryDelayBox.Font = Enum.Font.Gotham
    retryDelayBox.Text = tostring(config.retryDelay)
    retryDelayBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    retryDelayBox.TextSize = 15
    retryDelayBox.PlaceholderText = "e.g. 0.2"
    retryDelayBox.ZIndex = 1003
    
    local delayBoxCorner = Instance.new("UICorner", retryDelayBox)
    delayBoxCorner.CornerRadius = UDim.new(0, 10)
    
    guiElements.retryDelayBox = retryDelayBox

    local saveSettingsButton = Instance.new("TextButton")
    saveSettingsButton.Parent = settingsFrame
    saveSettingsButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    saveSettingsButton.BorderSizePixel = 0
    saveSettingsButton.AnchorPoint = Vector2.new(0.5, 1)
    saveSettingsButton.Position = UDim2.new(0.5, 0, 1, -15)
    saveSettingsButton.Size = UDim2.new(0, 340, 0, 45)
    saveSettingsButton.Font = Enum.Font.GothamBold
    saveSettingsButton.Text = "💾 Save Settings"
    saveSettingsButton.TextColor3 = Color3.new(1, 1, 1)
    saveSettingsButton.TextSize = 16
    saveSettingsButton.ZIndex = 1002
    
    local saveCorner = Instance.new("UICorner", saveSettingsButton)
    saveCorner.CornerRadius = UDim.new(0, 10)
    
    guiElements.saveButton = saveSettingsButton

end

function GUIManager.updateToggleButtonState()

    if config.isRunning then
        guiElements.startStopButton.Text = "⏸ STOP"
        guiElements.startStopButton.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
        guiElements.toggleButton.BackgroundColor3 = Color3.fromRGB(255, 152, 0)
    else
        guiElements.startStopButton.Text = "▶ START"
        guiElements.startStopButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
        guiElements.toggleButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    end

end

function GUIManager.bindEvents()

    -- Plant Checkbox Events
    for plantName, checkbox in pairs(guiElements.plantCheckboxes) do

        checkbox.MouseButton1Click:Connect(function()

            config.selectedItems[plantName] = not config.selectedItems[plantName]

            if config.selectedItems[plantName] then
                checkbox.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
                checkbox.Text = "✓"
            else
                checkbox.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
                checkbox.Text = ""
            end

            SettingsManager.save()

        end)

    end

    -- Floating Toggle Button Event
    guiElements.toggleButton.MouseButton1Click:Connect(function()

        config.guiVisible = not config.guiVisible
        guiElements.mainFrame.Visible = config.guiVisible

        if not config.guiVisible then
            guiElements.settingsFrame.Visible = false
        end

        SettingsManager.save()
        GUIManager.updateLog(config.guiVisible and "👁️ GUI opened" or "👁️ GUI minimized")

    end)

    -- Start/Stop Button Event
    guiElements.startStopButton.MouseButton1Click:Connect(function()

        config.isRunning = not config.isRunning
        SettingsManager.save()

        GUIManager.updateToggleButtonState()
        GUIManager.updateLog(config.isRunning and "🚀 Auto-purchasing enabled" or "🛑 Auto-purchasing disabled")

    end)

    -- Main Settings Button Event
    guiElements.settingsButton.MouseButton1Click:Connect(function()
        guiElements.settingsFrame.Visible = not guiElements.settingsFrame.Visible
    end)

    -- Settings Frame Close Button Event
    guiElements.settingsCloseButton.MouseButton1Click:Connect(function()
        guiElements.settingsFrame.Visible = false
    end)

    -- Save Settings Button Event (in Settings Frame)
    guiElements.saveButton.MouseButton1Click:Connect(function()

        local retryDelayValue = tonumber(guiElements.retryDelayBox.Text)

        if retryDelayValue and retryDelayValue >= 0 then
            config.retryDelay = retryDelayValue
            GUIManager.updateLog("⚙️ Buy delay updated to " .. string.format("%.2f", retryDelayValue) .. " seconds")
        else
            guiElements.retryDelayBox.Text = tostring(config.retryDelay)
            GUIManager.updateLog("❌ Invalid buy delay value. Reverted to " .. string.format("%.2f", config.retryDelay))
        end

        guiElements.settingsFrame.Visible = false
        SettingsManager.save()

    end)

    -- Main Frame Close Button Event
    guiElements.closeButton.MouseButton1Click:Connect(function()

        config.isRunning = false
        config.guiVisible = false
        guiElements.mainFrame.Visible = false
        guiElements.settingsFrame.Visible = false

        SettingsManager.save()
        GUIManager.updateToggleButtonState()
        GUIManager.updateLog("❌ GUI closed. Script remains active, use floating 🌱 button to reopen.")

    end)

end


--[[-----------------------------------------------------------------------------
    Core Autobuy Logic
-------------------------------------------------------------------------------]]

local AutoBuyer = {}

function AutoBuyer.processSeedStockUpdate(stockTable)

    for foodName, info in pairs(stockTable) do

        if currentStocks[foodName] then
            currentStocks[foodName].Stock = info.Stock
            currentStocks[foodName].MaxStock = info.MaxStock
        else
            GUIManager.updateLog("⚠️ Received stock for unknown item: " .. foodName)
        end

    end

end

function AutoBuyer.tryBuySeed(itemName)

    if not currentStocks[itemName] or currentStocks[itemName].Stock <= 0 then
        return false, "No stock available for " .. itemName
    end

    local success, err = pcall(function()
        BuyRemote:FireServer(itemName)
    end)

    task.wait(config.retryDelay)
    return success, err

end

function AutoBuyer.handleStockRefresh()

    if not config.isRunning then
        GUIManager.updateLog("⏱ Stock refreshed, but autobuy is disabled. Skipping purchase cycle.")
        return
    end

    local itemsToBuy = {}
    local totalItemsAvailable = 0

    for item, stockInfo in pairs(currentStocks) do

        if config.selectedItems[item] and stockInfo.Stock > 0 then
            itemsToBuy[item] = stockInfo.Stock
            totalItemsAvailable = totalItemsAvailable + stockInfo.Stock
        end

    end

    if not next(itemsToBuy) then
        GUIManager.updateLog("📦 No selected items currently in stock or all desired items are unselected.")
        return
    end

    local numItemTypes = 0
    for _ in pairs(itemsToBuy) do numItemTypes = numItemTypes + 1 end

    GUIManager.updateLog("📦 Stock update! " .. numItemTypes .. " selected item types available, " .. totalItemsAvailable .. " total units.")

    for itemName, stockQuantity in pairs(itemsToBuy) do

        if not config.isRunning then
            GUIManager.updateLog("⏹️ Purchase cycle stopped by user.")
            break
        end

        if not config.selectedItems[itemName] then
            GUIManager.updateLog("⚠️ ".. itemName .. " was deselected during purchase cycle. Skipping.")
            continue
        end


        GUIManager.updateLog("🛒 Processing " .. itemName .. " (" .. stockQuantity .. " available)")

        local successfulPurchases = 0

        for i = 1, stockQuantity do

            if not config.isRunning then
                GUIManager.updateLog("⏹️ Purchase interrupted for " .. itemName .. " at " .. i .. "/" .. stockQuantity)
                break
            end

            local purchasedThisUnit = false
            local lastError

            for attempt = 1, 3 do

                local success, err = AutoBuyer.tryBuySeed(itemName)

                if success then

                    purchasedThisUnit = true
                    successfulPurchases = successfulPurchases + 1

                    if attempt > 1 then
                        GUIManager.updateLog("✅ " .. itemName .. " purchased on attempt " .. attempt .. " (" .. successfulPurchases .. "/" .. stockQuantity .. ")")
                    end

                    break

                else

                    lastError = err

                    if attempt < 3 then
                        GUIManager.updateLog("🔄 Retry " .. attempt .. "/3 for " .. itemName .. " failed: " .. tostring(err))
                    end

                end
            end

            if not purchasedThisUnit then

                GUIManager.updateLog("❌ Failed to buy 1 unit of " .. itemName .. " after 3 attempts. Error: " .. tostring(lastError))

            end

        end

        if successfulPurchases > 0 then

            local efficiency = math.floor((successfulPurchases / stockQuantity) * 100)
            GUIManager.updateLog("☑️ " .. itemName .. " processing complete: " .. successfulPurchases .. "/" .. stockQuantity .. " purchased (" .. efficiency .. "% success for this batch).")

        else
            GUIManager.updateLog("❌ " .. itemName .. " processing failed: 0/" .. stockQuantity .. " purchased for this batch.")

        end

        if next(itemsToBuy, itemName) ~= nil and config.isRunning then
            task.wait(config.retryDelay * 2)
        end

    end

    GUIManager.updateLog("🏁 Stock purchase session completed.")

end


--[[-----------------------------------------------------------------------------    
    Event Listeners and Initialization
-------------------------------------------------------------------------------]]

local function onDataStreamEvent(eventType, object, tbl)

    if eventType == "UpdateData" and type(tbl) == "table" then

        for _, pair in ipairs(tbl) do

            if type(pair) == "table" and #pair >= 2 then

                local path = pair[1]
                local data = pair[2]

                if path == "ROOT/SeedStock/Stocks" and type(data) == "table" then
                    AutoBuyer.processSeedStockUpdate(data)
                    AutoBuyer.handleStockRefresh()
                    break
                end

            end

        end

    end

end

local function initialize()

    SettingsManager.load()
    GUIManager.create()
    GUIManager.updateToggleButtonState()
    GUIManager.bindEvents()

    DataStreamEvent.OnClientEvent:Connect(onDataStreamEvent)

    GUIManager.updateLog("🌱 GAG Autobuy Seeds initialized (v2.0 Modern UI)")

    if config.isRunning then
        GUIManager.updateLog("🚀 Auto-purchasing is currently ENABLED (from saved settings).")
    else
        GUIManager.updateLog("▶️ Click START to enable auto-purchasing.")
    end

    GUIManager.updateLog("👂 Listening for seed stock updates...")

    print("🌱 GAG Autobuy Seeds (v2.0 Modern UI) loaded successfully!")

end

--[[-----------------------------------------------------------------------------
    Script Entry Point
-------------------------------------------------------------------------------]]

local success, err = pcall(initialize)

if not success then

    print("❌ CRITICAL ERROR during GAG Autobuy Seeds initialization: " .. tostring(err))
    warn(debug.traceback())

end
