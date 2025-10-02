-- Roblox Services
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

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

local config = {
    retryDelay = 0.2,
    isRunning = false,
    guiVisible = true,
    selectedItems = {}
}

local currentStocks = {}
local logEntries = {}
local guiElements = {}

for _, item in ipairs(ALL_FRUITS_AND_VEGETABLES) do
    config.selectedItems[item] = true
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
            print("Settings loaded from " .. SETTINGS_FILE)
        else
            print("Error decoding settings JSON")
            SettingsManager.applyDefaults()
        end
    else
        print("Could not read settings file, using defaults")
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
        print("Error encoding settings to JSON: " .. tostring(jsonString))
        return
    end

    local successWrite, writeError = pcall(function()
        writefile(SETTINGS_FILE, jsonString)
    end)

    if successWrite then
        print("Settings saved to " .. SETTINGS_FILE)
    else
        print("Error saving settings: " .. tostring(writeError))
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
    print("Default settings applied.")
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
        logEntryLabel.Font = Enum.Font.Code
        logEntryLabel.Text = entry
        logEntryLabel.TextColor3 = Color3.fromRGB(180, 255, 200)
        logEntryLabel.TextSize = 12
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

    -- Floating Toggle Button
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "FloatingToggleButton"
    toggleButton.Parent = screenGui
    toggleButton.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
    toggleButton.BorderSizePixel = 0
    toggleButton.AnchorPoint = Vector2.new(1, 1)
    toggleButton.Position = UDim2.new(1, -20, 1, -20)
    toggleButton.Size = UDim2.new(0, 56, 0, 56)
    toggleButton.Font = Enum.Font.FredokaOne
    toggleButton.Text = "🌿"
    toggleButton.TextColor3 = Color3.new(1, 1, 1)
    toggleButton.TextSize = 26
    toggleButton.ZIndex = 1000
    
    Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(1, 0)
    
    local toggleStroke = Instance.new("UIStroke", toggleButton)
    toggleStroke.Color = Color3.fromRGB(22, 163, 74)
    toggleStroke.Thickness = 2
    
    guiElements.toggleButton = toggleButton

    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = Color3.fromRGB(17, 24, 39)
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0.5, -225, 0.5, -300)
    mainFrame.Size = UDim2.new(0, 450, 0, 600)
    mainFrame.Visible = config.guiVisible
    mainFrame.ClipsDescendants = false
    
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 20)
    
    local mainStroke = Instance.new("UIStroke", mainFrame)
    mainStroke.Color = Color3.fromRGB(75, 85, 99)
    mainStroke.Thickness = 2
    
    guiElements.mainFrame = mainFrame

    -- Draggable Header
    local dragBar = Instance.new("Frame")
    dragBar.Name = "DragBar"
    dragBar.Parent = mainFrame
    dragBar.BackgroundColor3 = Color3.fromRGB(31, 41, 55)
    dragBar.BorderSizePixel = 0
    dragBar.Size = UDim2.new(1, 0, 0, 60)
    dragBar.Active = true
    
    local dragCorner = Instance.new("UICorner", dragBar)
    dragCorner.CornerRadius = UDim.new(0, 20)
    
    local dragBottom = Instance.new("Frame", dragBar)
    dragBottom.BackgroundColor3 = Color3.fromRGB(31, 41, 55)
    dragBottom.BorderSizePixel = 0
    dragBottom.Position = UDim2.new(0, 0, 1, -20)
    dragBottom.Size = UDim2.new(1, 0, 0, 20)

    -- Drag functionality
    local dragging = false
    local dragInput, dragStart, startPos

    dragBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
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

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = dragBar
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 20, 0, 8)
    titleLabel.Size = UDim2.new(1, -100, 0, 22)
    titleLabel.Font = Enum.Font.FredokaOne
    titleLabel.Text = "Auto Seed Buyer"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 20
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Parent = dragBar
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Position = UDim2.new(0, 20, 0, 32)
    subtitleLabel.Size = UDim2.new(1, -100, 0, 18)
    subtitleLabel.Font = Enum.Font.GothamMedium
    subtitleLabel.Text = "Grow A Garden"
    titleLabel.TextColor3 = Color3.fromRGB(156, 163, 175)
    subtitleLabel.TextSize = 13
    subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Parent = dragBar
    closeButton.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
    closeButton.BorderSizePixel = 0
    closeButton.Position = UDim2.new(1, -45, 0, 15)
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.TextSize = 16
    
    Instance.new("UICorner", closeButton).CornerRadius = UDim.new(1, 0)
    
    guiElements.closeButton = closeButton

    -- Content Area
    local contentFrame = Instance.new("Frame")
    contentFrame.Parent = mainFrame
    contentFrame.BackgroundTransparency = 1
    contentFrame.Position = UDim2.new(0, 20, 0, 70)
    contentFrame.Size = UDim2.new(1, -40, 1, -80)

    -- Control Buttons
    local startButton = Instance.new("TextButton")
    startButton.Parent = contentFrame
    startButton.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
    startButton.BorderSizePixel = 0
    startButton.Size = UDim2.new(0.48, 0, 0, 45)
    startButton.Font = Enum.Font.GothamBold
    startButton.Text = "START"
    startButton.TextColor3 = Color3.new(1, 1, 1)
    startButton.TextSize = 15
    
    Instance.new("UICorner", startButton).CornerRadius = UDim.new(0, 12)
    
    guiElements.startStopButton = startButton

    local settingsButton = Instance.new("TextButton")
    settingsButton.Parent = contentFrame
    settingsButton.BackgroundColor3 = Color3.fromRGB(99, 102, 241)
    settingsButton.BorderSizePixel = 0
    settingsButton.Position = UDim2.new(0.52, 0, 0, 0)
    settingsButton.Size = UDim2.new(0.48, 0, 0, 45)
    settingsButton.Font = Enum.Font.GothamBold
    settingsButton.Text = "SETTINGS"
    settingsButton.TextColor3 = Color3.new(1, 1, 1)
    settingsButton.TextSize = 15
    
    Instance.new("UICorner", settingsButton).CornerRadius = UDim.new(0, 12)
    
    guiElements.settingsButton = settingsButton

    -- Plant Selection Section
    local plantSection = Instance.new("Frame")
    plantSection.Parent = contentFrame
    plantSection.BackgroundColor3 = Color3.fromRGB(31, 41, 55)
    plantSection.BorderSizePixel = 0
    plantSection.Position = UDim2.new(0, 0, 0, 60)
    plantSection.Size = UDim2.new(1, 0, 0, 220)
    
    Instance.new("UICorner", plantSection).CornerRadius = UDim.new(0, 12)

    local plantHeader = Instance.new("TextLabel")
    plantHeader.Parent = plantSection
    plantHeader.BackgroundTransparency = 1
    plantHeader.Position = UDim2.new(0, 15, 0, 12)
    plantHeader.Size = UDim2.new(1, -30, 0, 22)
    plantHeader.Font = Enum.Font.GothamBold
    plantHeader.Text = "Select Plants"
    plantHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
    plantHeader.TextSize = 16
    plantHeader.TextXAlignment = Enum.TextXAlignment.Left

    local plantScrollFrame = Instance.new("ScrollingFrame")
    plantScrollFrame.Parent = plantSection
    plantScrollFrame.BackgroundTransparency = 1
    plantScrollFrame.Position = UDim2.new(0, 10, 0, 40)
    plantScrollFrame.Size = UDim2.new(1, -20, 1, -50)
    plantScrollFrame.ScrollBarThickness = 5
    plantScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(75, 85, 99)
    plantScrollFrame.BorderSizePixel = 0
    
    guiElements.plantScrollFrame = plantScrollFrame

    local plantLayout = Instance.new("UIListLayout", plantScrollFrame)
    plantLayout.Padding = UDim.new(0, 5)
    plantLayout.SortOrder = Enum.SortOrder.Name

    guiElements.plantCheckboxes = {}

    for _, plantName in ipairs(ALL_FRUITS_AND_VEGETABLES) do
        local itemFrame = Instance.new("Frame")
        itemFrame.Name = plantName .. "Frame"
        itemFrame.Parent = plantScrollFrame
        itemFrame.BackgroundColor3 = Color3.fromRGB(55, 65, 81)
        itemFrame.BorderSizePixel = 0
        itemFrame.Size = UDim2.new(1, 0, 0, 35)
        
        Instance.new("UICorner", itemFrame).CornerRadius = UDim.new(0, 8)

        local checkbox = Instance.new("TextButton")
        checkbox.Name = plantName .. "Checkbox"
        checkbox.Parent = itemFrame
        checkbox.BorderSizePixel = 0
        checkbox.Position = UDim2.new(0, 8, 0.5, -12)
        checkbox.Size = UDim2.new(0, 24, 0, 24)
        checkbox.Font = Enum.Font.GothamBold
        checkbox.TextColor3 = Color3.new(1, 1, 1)
        checkbox.TextSize = 14
        
        Instance.new("UICorner", checkbox).CornerRadius = UDim.new(0, 6)

        local plantLabel = Instance.new("TextLabel")
        plantLabel.Parent = itemFrame
        plantLabel.BackgroundTransparency = 1
        plantLabel.Position = UDim2.new(0, 40, 0, 0)
        plantLabel.Size = UDim2.new(1, -45, 1, 0)
        plantLabel.Font = Enum.Font.Gotham
        plantLabel.Text = plantName
        plantLabel.TextColor3 = Color3.fromRGB(229, 231, 235)
        plantLabel.TextSize = 13
        plantLabel.TextXAlignment = Enum.TextXAlignment.Left

        guiElements.plantCheckboxes[plantName] = checkbox

        if config.selectedItems[plantName] then
            checkbox.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
            checkbox.Text = "✓"
        else
            checkbox.BackgroundColor3 = Color3.fromRGB(75, 85, 99)
            checkbox.Text = ""
        end
    end

    plantScrollFrame.CanvasSize = UDim2.new(0, 0, 0, #ALL_FRUITS_AND_VEGETABLES * 40)

    -- Log Section
    local logSection = Instance.new("Frame")
    logSection.Parent = contentFrame
    logSection.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    logSection.BackgroundTransparency = 0.6
    logSection.BorderSizePixel = 0
    logSection.Position = UDim2.new(0, 0, 0, 290)
    logSection.Size = UDim2.new(1, 0, 1, -290)
    
    Instance.new("UICorner", logSection).CornerRadius = UDim.new(0, 12)

    local logHeader = Instance.new("TextLabel")
    logHeader.Parent = logSection
    logHeader.BackgroundTransparency = 1
    logHeader.Position = UDim2.new(0, 15, 0, 10)
    logHeader.Size = UDim2.new(1, -30, 0, 20)
    logHeader.Font = Enum.Font.GothamBold
    logHeader.Text = "Activity Log"
    logHeader.TextColor3 = Color3.fromRGB(34, 197, 94)
    logHeader.TextSize = 14
    logHeader.TextXAlignment = Enum.TextXAlignment.Left

    local logScrollFrame = Instance.new("ScrollingFrame")
    logScrollFrame.Parent = logSection
    logScrollFrame.BackgroundTransparency = 1
    logScrollFrame.Position = UDim2.new(0, 10, 0, 35)
    logScrollFrame.Size = UDim2.new(1, -20, 1, -45)
    logScrollFrame.ScrollBarThickness = 4
    logScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(75, 85, 99)
    logScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    logScrollFrame.BorderSizePixel = 0
    
    guiElements.logScrollFrame = logScrollFrame

    Instance.new("UIListLayout", logScrollFrame).Padding = UDim.new(0, 2)

    -- Settings Frame
    local settingsFrame = Instance.new("Frame")
    settingsFrame.Name = "SettingsFrame"
    settingsFrame.Parent = screenGui
    settingsFrame.BackgroundColor3 = Color3.fromRGB(17, 24, 39)
    settingsFrame.BorderSizePixel = 0
    settingsFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    settingsFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    settingsFrame.Size = UDim2.new(0, 380, 0, 220)
    settingsFrame.Visible = false
    settingsFrame.ZIndex = 1001
    
    Instance.new("UICorner", settingsFrame).CornerRadius = UDim.new(0, 20)
    
    local settingsStroke = Instance.new("UIStroke", settingsFrame)
    settingsStroke.Color = Color3.fromRGB(75, 85, 99)
    settingsStroke.Thickness = 2
    
    guiElements.settingsFrame = settingsFrame

    local settingsHeader = Instance.new("Frame")
    settingsHeader.Parent = settingsFrame
    settingsHeader.BackgroundColor3 = Color3.fromRGB(31, 41, 55)
    settingsHeader.BorderSizePixel = 0
    settingsHeader.Size = UDim2.new(1, 0, 0, 50)
    settingsHeader.ZIndex = 1002
    
    local settingsHeaderCorner = Instance.new("UICorner", settingsHeader)
    settingsHeaderCorner.CornerRadius = UDim.new(0, 20)
    
    local settingsHeaderBottom = Instance.new("Frame", settingsHeader)
    settingsHeaderBottom.BackgroundColor3 = Color3.fromRGB(31, 41, 55)
    settingsHeaderBottom.BorderSizePixel = 0
    settingsHeaderBottom.Position = UDim2.new(0, 0, 1, -20)
    settingsHeaderBottom.Size = UDim2.new(1, 0, 0, 20)
    settingsHeaderBottom.ZIndex = 1002

    local settingsTitle = Instance.new("TextLabel")
    settingsTitle.Parent = settingsHeader
    settingsTitle.BackgroundTransparency = 1
    settingsTitle.Position = UDim2.new(0, 20, 0, 0)
    settingsTitle.Size = UDim2.new(1, -60, 1, 0)
    settingsTitle.Font = Enum.Font.GothamBold
    settingsTitle.Text = "Settings"
    settingsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    settingsTitle.TextSize = 18
    settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
    settingsTitle.ZIndex = 1003

    local settingsCloseButton = Instance.new("TextButton")
    settingsCloseButton.Parent = settingsHeader
    settingsCloseButton.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
    settingsCloseButton.BorderSizePixel = 0
    settingsCloseButton.Position = UDim2.new(1, -38, 0.5, -15)
    settingsCloseButton.Size = UDim2.new(0, 30, 0, 30)
    settingsCloseButton.Font = Enum.Font.GothamBold
    settingsCloseButton.Text = "X"
    settingsCloseButton.TextColor3 = Color3.new(1, 1, 1)
    settingsCloseButton.TextSize = 14
    settingsCloseButton.ZIndex = 1003
    
    Instance.new("UICorner", settingsCloseButton).CornerRadius = UDim.new(1, 0)
    
    guiElements.settingsCloseButton = settingsCloseButton

    local settingsContent = Instance.new("Frame")
    settingsContent.Parent = settingsFrame
    settingsContent.BackgroundTransparency = 1
    settingsContent.Position = UDim2.new(0, 20, 0, 65)
    settingsContent.Size = UDim2.new(1, -40, 1, -120)
    settingsContent.ZIndex = 1002

    local delayLabel = Instance.new("TextLabel")
    delayLabel.Parent = settingsContent
    delayLabel.BackgroundTransparency = 1
    delayLabel.Size = UDim2.new(1, 0, 0, 20)
    delayLabel.Font = Enum.Font.GothamBold
    delayLabel.Text = "Buy Delay (seconds)"
    delayLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    delayLabel.TextSize = 14
    delayLabel.TextXAlignment = Enum.TextXAlignment.Left
    delayLabel.ZIndex = 1003

    local delayBox = Instance.new("TextBox")
    delayBox.Parent = settingsContent
    delayBox.BackgroundColor3 = Color3.fromRGB(55, 65, 81)
    delayBox.BorderSizePixel = 0
    delayBox.Position = UDim2.new(0, 0, 0, 28)
    delayBox.Size = UDim2.new(1, 0, 0, 38)
    delayBox.Font = Enum.Font.Gotham
    delayBox.Text = tostring(config.retryDelay)
    delayBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    delayBox.TextSize = 14
    delayBox.PlaceholderText = "0.2"
    delayBox.ZIndex = 1003
    
    Instance.new("UICorner", delayBox).CornerRadius = UDim.new(0, 10)
    
    guiElements.retryDelayBox = delayBox

    local saveButton = Instance.new("TextButton")
    saveButton.Parent = settingsFrame
    saveButton.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
    saveButton.BorderSizePixel = 0
    saveButton.Position = UDim2.new(0.5, -150, 1, -50)
    saveButton.Size = UDim2.new(0, 300, 0, 40)
    saveButton.Font = Enum.Font.GothamBold
    saveButton.Text = "Save"
    saveButton.TextColor3 = Color3.new(1, 1, 1)
    saveButton.TextSize = 15
    saveButton.ZIndex = 1002
    
    Instance.new("UICorner", saveButton).CornerRadius = UDim.new(0, 10)
    
    guiElements.saveButton = saveButton

    -- Resize Handle
    local resizeHandle = Instance.new("Frame")
    resizeHandle.Name = "ResizeHandle"
    resizeHandle.Parent = mainFrame
    resizeHandle.BackgroundColor3 = Color3.fromRGB(75, 85, 99)
    resizeHandle.BorderSizePixel = 0
    resizeHandle.AnchorPoint = Vector2.new(1, 1)
    resizeHandle.Position = UDim2.new(1, 0, 1, 0)
    resizeHandle.Size = UDim2.new(0, 25, 0, 25)
    resizeHandle.ZIndex = 1000
    resizeHandle.Active = true
    
    Instance.new("UICorner", resizeHandle).CornerRadius = UDim.new(0, 0)
    
    local resizeIcon = Instance.new("TextLabel")
    resizeIcon.Parent = resizeHandle
    resizeIcon.BackgroundTransparency = 1
    resizeIcon.Size = UDim2.new(1, 0, 1, 0)
    resizeIcon.Font = Enum.Font.GothamBold
    resizeIcon.Text = "⋰"
    resizeIcon.TextColor3 = Color3.fromRGB(156, 163, 175)
    resizeIcon.TextSize = 16
    resizeIcon.Rotation = 90
    resizeIcon.ZIndex = 1001

    -- Resize functionality
    local resizing = false
    local resizeStart, startSize
    local minSize = Vector2.new(400, 500)
    local maxSize = Vector2.new(800, 900)

    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
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

    UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - resizeStart
            local newWidth = math.clamp(startSize.X + delta.X, minSize.X, maxSize.X)
            local newHeight = math.clamp(startSize.Y + delta.Y, minSize.Y, maxSize.Y)
            mainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
        end
    end)

end

function GUIManager.updateToggleButtonState()
    if config.isRunning then
        guiElements.startStopButton.Text = "STOP"
        guiElements.startStopButton.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
        guiElements.toggleButton.BackgroundColor3 = Color3.fromRGB(251, 146, 60)
    else
        guiElements.startStopButton.Text = "START"
        guiElements.startStopButton.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
        guiElements.toggleButton.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
    end
end

function GUIManager.bindEvents()
    -- Plant Checkbox Events
    for plantName, checkbox in pairs(guiElements.plantCheckboxes) do
        checkbox.MouseButton1Click:Connect(function()
            config.selectedItems[plantName] = not config.selectedItems[plantName]

            if config.selectedItems[plantName] then
                checkbox.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
                checkbox.Text = "✓"
            else
                checkbox.BackgroundColor3 = Color3.fromRGB(75, 85, 99)
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
        GUIManager.updateLog(config.guiVisible and "GUI opened" or "GUI minimized")
    end)

    -- Start/Stop Button Event
    guiElements.startStopButton.MouseButton1Click:Connect(function()
        config.isRunning = not config.isRunning
        SettingsManager.save()

        GUIManager.updateToggleButtonState()
        GUIManager.updateLog(config.isRunning and "Auto-purchasing enabled" or "Auto-purchasing disabled")
    end)

    -- Settings Button Event
    guiElements.settingsButton.MouseButton1Click:Connect(function()
        guiElements.settingsFrame.Visible = not guiElements.settingsFrame.Visible
    end)

    -- Settings Close Button Event
    guiElements.settingsCloseButton.MouseButton1Click:Connect(function()
        guiElements.settingsFrame.Visible = false
    end)

    -- Save Settings Button Event
    guiElements.saveButton.MouseButton1Click:Connect(function()
        local retryDelayValue = tonumber(guiElements.retryDelayBox.Text)

        if retryDelayValue and retryDelayValue >= 0 then
            config.retryDelay = retryDelayValue
            GUIManager.updateLog("Buy delay updated to " .. string.format("%.2f", retryDelayValue) .. " seconds")
        else
            guiElements.retryDelayBox.Text = tostring(config.retryDelay)
            GUIManager.updateLog("Invalid buy delay value. Reverted to " .. string.format("%.2f", config.retryDelay))
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
        GUIManager.updateLog("GUI closed. Script remains active, use floating button to reopen.")
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
            GUIManager.updateLog("Received stock for unknown item: " .. foodName)
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
        GUIManager.updateLog("Stock refreshed, but autobuy is disabled. Skipping purchase cycle.")
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
        GUIManager.updateLog("No selected items currently in stock or all desired items are unselected.")
        return
    end

    local numItemTypes = 0
    for _ in pairs(itemsToBuy) do numItemTypes = numItemTypes + 1 end

    GUIManager.updateLog("Stock update! " .. numItemTypes .. " selected item types available, " .. totalItemsAvailable .. " total units.")

    for itemName, stockQuantity in pairs(itemsToBuy) do
        if not config.isRunning then
            GUIManager.updateLog("Purchase cycle stopped by user.")
            break
        end

        if not config.selectedItems[itemName] then
            GUIManager.updateLog(itemName .. " was deselected during purchase cycle. Skipping.")
            continue
        end

        GUIManager.updateLog("Processing " .. itemName .. " (" .. stockQuantity .. " available)")

        local successfulPurchases = 0

        for i = 1, stockQuantity do
            if not config.isRunning then
                GUIManager.updateLog("Purchase interrupted for " .. itemName .. " at " .. i .. "/" .. stockQuantity)
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
                        GUIManager.updateLog(itemName .. " purchased on attempt " .. attempt .. " (" .. successfulPurchases .. "/" .. stockQuantity .. ")")
                    end

                    break
                else
                    lastError = err

                    if attempt < 3 then
                        GUIManager.updateLog("Retry " .. attempt .. "/3 for " .. itemName .. " failed: " .. tostring(err))
                    end
                end
            end

            if not purchasedThisUnit then
                GUIManager.updateLog("Failed to buy 1 unit of " .. itemName .. " after 3 attempts. Error: " .. tostring(lastError))
            end
        end

        if successfulPurchases > 0 then
            local efficiency = math.floor((successfulPurchases / stockQuantity) * 100)
            GUIManager.updateLog(itemName .. " processing complete: " .. successfulPurchases .. "/" .. stockQuantity .. " purchased (" .. efficiency .. "% success for this batch).")
        else
            GUIManager.updateLog(itemName .. " processing failed: 0/" .. stockQuantity .. " purchased for this batch.")
        end

        if next(itemsToBuy, itemName) ~= nil and config.isRunning then
            task.wait(config.retryDelay * 2)
        end
    end

    GUIManager.updateLog("Stock purchase session completed.")
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

    GUIManager.updateLog("GAG Autobuy Seeds initialized (v2.0 Revamped)")

    if config.isRunning then
        GUIManager.updateLog("Auto-purchasing is currently ENABLED (from saved settings).")
    else
        GUIManager.updateLog("Click START to enable auto-purchasing.")
    end

    GUIManager.updateLog("Listening for seed stock updates...")

    print("GAG Autobuy Seeds (v2.0 Revamped) loaded successfully!")
end

--[[-----------------------------------------------------------------------------
    Script Entry Point
-------------------------------------------------------------------------------]]

local success, err = pcall(initialize)

if not success then
    print("CRITICAL ERROR during GAG Autobuy Seeds initialization: " .. tostring(err))
    warn(debug.traceback())
end
