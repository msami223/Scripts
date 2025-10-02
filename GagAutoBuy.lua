-- Roblox Services
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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

--[[
    Loads configuration settings from a JSON file.
    
    This function attempts to read and decode the settings file, populating the global
    config table with saved values. If loading fails or the file doesn't exist,
    default settings are applied instead.
    
    @return void - Updates the global config table directly
--]]
function SettingsManager.load()
    
    local success, fileContent = pcall(function()
        return readfile(SETTINGS_FILE)
    end)

    if success and fileContent then

        local decodeSuccess, decodedJson = pcall(function()
            return HttpService:JSONDecode(fileContent)
        end)

        if decodeSuccess and type(decodedJson) == "table" then

            -- Load general config settings
            for key, value in pairs(decodedJson) do

                if config[key] ~= nil and key ~= "selectedItems" then
                    config[key] = value
                end

            end

            -- Load selectedItems, ensuring all current fruits/vegetables are accounted for
            local loadedSelectedItems = decodedJson.selectedItems

            if type(loadedSelectedItems) == "table" then

                local newSelectedItems = {}

                for _, itemFullName in ipairs(ALL_FRUITS_AND_VEGETABLES) do

                    -- Prioritize loaded setting, otherwise default to true
                    newSelectedItems[itemFullName] = (loadedSelectedItems[itemFullName] ~= nil and loadedSelectedItems[itemFullName] == true) or (loadedSelectedItems[itemFullName] == nil and true)

                end

                config.selectedItems = newSelectedItems
            else

                -- If loadedSelectedItems is not a table, use the default (all true)
                for _, itemFullName in ipairs(ALL_FRUITS_AND_VEGETABLES) do
                    config.selectedItems[itemFullName] = true
                end

            end
            print("⚙️ Settings loaded from " .. SETTINGS_FILE)
        else
            print("❌ Error decoding settings JSON or not a table: " .. (decodeSuccess and "Invalid JSON format" or tostring(decodedJson)))
            print("⚠️ Using default settings for all.")
            SettingsManager.applyDefaults() -- Ensure defaults are set if loading fails partially
        end

    else
        print("⚠️ Could not read settings file: " .. SETTINGS_FILE .. ". Using default settings. Error: " .. tostring(fileContent))
        SettingsManager.applyDefaults()
    end

end

--[[
    Saves the current configuration settings to a JSON file.
    
    This function encodes the current config table to JSON and writes it to the
    settings file. It ensures selectedItems contains only valid fruit/vegetable
    entries before saving.
    
    @return void - Writes settings to file and prints status messages
--]]
function SettingsManager.save()

    -- Ensure selectedItems in config matches the current state of ALL_FRUITS_AND_VEGETABLES
    local currentConfigToSave = table.clone(config)

    local validSelectedItems = {}

    for _, item in ipairs(ALL_FRUITS_AND_VEGETABLES) do
        validSelectedItems[item] = config.selectedItems[item] or false -- Default to false if somehow missing
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

--[[
    Applies default configuration settings.
    
    This function resets all configuration values to their default state,
    including setting retry delay, disabling auto-purchasing, making GUI visible,
    and selecting all available fruits and vegetables.
    
    @return void - Updates the global config table directly
--]]
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
    GUI Management (New Modern UI)
-------------------------------------------------------------------------------]]

local GUIManager = {}

-- Theme Colors for the new UI
local Theme = {
    Background = Color3.fromHex("1B1B25"),
    Primary = Color3.fromHex("252535"),
    Secondary = Color3.fromHex("3F3F54"),
    Accent = Color3.fromHex("7F5AF0"),
    Text = Color3.fromHex("FFFFFF"),
    SubText = Color3.fromHex("94A1B2"),
    Success = Color3.fromHex("2CB67D"),
    Failure = Color3.fromHex("FF5353"),
    Stroke = Color3.fromHex("000000")
}


--[[
    Updates the activity log with a new message.
    
    This function adds a timestamped message to the log entries, manages log history
    to prevent memory overflow, recreates all log labels in the scroll frame, and
    automatically scrolls to the bottom to show the latest message.
    
    @param message (string) - The log message to display
    @return void - Updates the GUI log display directly
--]]
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

    local totalHeight = 5 -- Start with top padding

    for i, entry in ipairs(logEntries) do
        local logEntryLabel = Instance.new("TextLabel")
        logEntryLabel.Name = "LogEntry" .. i
        logEntryLabel.Parent = guiElements.logScrollFrame
        logEntryLabel.BackgroundTransparency = 1
        logEntryLabel.Size = UDim2.new(1, 0, 0, 16)
        logEntryLabel.Font = Enum.Font.Gotham
        logEntryLabel.Text = entry
        logEntryLabel.TextColor3 = Theme.SubText
        logEntryLabel.TextSize = 14
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


--[[
    Creates the complete GUI interface for the autobuy script.
    
    This function builds all GUI elements including the main frame, toggle button,
    plant selection checkboxes, settings frame, activity log, and all associated
    UI components. It sets up the visual hierarchy and styling but does not bind
    event handlers (that's done in bindEvents).
    
    @return void - Creates and stores GUI elements in the guiElements table
--]]
function GUIManager.create()

    -- Main ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GAGAutoBuySeedsGUI"
    screenGui.Parent = playerGui
    screenGui.ResetOnSpawn = false
    guiElements.screenGui = screenGui

    -- Floating Toggle Button
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "FloatingToggleButton"
    toggleButton.Parent = screenGui
    toggleButton.BackgroundColor3 = Theme.Accent
    toggleButton.BorderSizePixel = 0
    toggleButton.AnchorPoint = Vector2.new(1, 1)
    toggleButton.Position = UDim2.new(1, -15, 1, -15)
    toggleButton.Size = UDim2.new(0, 50, 0, 50)
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.Text = "🌱"
    toggleButton.TextColor3 = Theme.Text
    toggleButton.TextSize = 28
    toggleButton.ZIndex = 1000
    Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(1, 0)
    local toggleStroke = Instance.new("UIStroke", toggleButton)
    toggleStroke.Color = Color3.new(0,0,0)
    toggleStroke.Transparency = 0.5
    toggleStroke.Thickness = 1
    guiElements.toggleButton = toggleButton

    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = Theme.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.Position = UDim2.new(0.02, 0, 0.1, 0)
    mainFrame.Size = UDim2.new(0, 400, 0, 550)
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Visible = config.guiVisible
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)
    local mainStroke = Instance.new("UIStroke", mainFrame)
    mainStroke.Color = Theme.Stroke
    mainStroke.Transparency = 0.5
    mainStroke.Thickness = 2
    guiElements.mainFrame = mainFrame

    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Parent = mainFrame
    titleBar.BackgroundColor3 = Theme.Primary
    titleBar.BorderSizePixel = 0
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    local titleCorner = Instance.new("UICorner", titleBar)
    titleCorner.CornerRadius = UDim.new(0, 8)
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Parent = titleBar
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, -60, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = "SlowMo Hub | Auto Seed Buyer"
    titleLabel.TextColor3 = Theme.Text
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Parent = titleBar
    closeButton.BackgroundTransparency = 1
    closeButton.BorderSizePixel = 0
    closeButton.Position = UDim2.new(1, -35, 0.5, 0)
    closeButton.AnchorPoint = Vector2.new(0.5, 0.5)
    closeButton.Size = UDim2.new(0, 25, 0, 25)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "X"
    closeButton.TextColor3 = Theme.SubText
    closeButton.TextSize = 16
    guiElements.closeButton = closeButton

    -- Content Padding
    local contentPadding = Instance.new("UIPadding", mainFrame)
    contentPadding.PaddingTop = UDim.new(0, 45)
    contentPadding.PaddingLeft = UDim.new(0, 10)
    contentPadding.PaddingRight = UDim.new(0, 10)
    contentPadding.PaddingBottom = UDim.new(0, 10)

    -- Control Buttons Frame
    local controlFrame = Instance.new("Frame")
    controlFrame.Name = "ControlFrame"
    controlFrame.Parent = mainFrame
    controlFrame.BackgroundTransparency = 1
    controlFrame.Size = UDim2.new(1, 0, 0, 40)
    local controlLayout = Instance.new("UIListLayout", controlFrame)
    controlLayout.FillDirection = Enum.FillDirection.Horizontal
    controlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    controlLayout.SortOrder = Enum.SortOrder.LayoutOrder
    controlLayout.Padding = UDim.new(0, 10)
    
    -- Start/Stop Button
    local startStopButton = Instance.new("TextButton")
    startStopButton.Name = "StartStopButton"
    startStopButton.Parent = controlFrame
    startStopButton.BackgroundColor3 = Theme.Success
    startStopButton.Size = UDim2.new(0.5, -5, 1, 0)
    startStopButton.Font = Enum.Font.GothamBold
    startStopButton.Text = "▶ START"
    startStopButton.TextColor3 = Theme.Text
    startStopButton.TextSize = 16
    Instance.new("UICorner", startStopButton).CornerRadius = UDim.new(0, 6)
    guiElements.startStopButton = startStopButton

    -- Settings Button
    local settingsButton = Instance.new("TextButton")
    settingsButton.Name = "SettingsButton"
    settingsButton.Parent = controlFrame
    settingsButton.BackgroundColor3 = Theme.Secondary
    settingsButton.Size = UDim2.new(0.5, -5, 1, 0)
    settingsButton.Font = Enum.Font.GothamBold
    settingsButton.Text = "⚙️ SETTINGS"
    settingsButton.TextColor3 = Theme.Text
    settingsButton.TextSize = 16
    Instance.new("UICorner", settingsButton).CornerRadius = UDim.new(0, 6)
    guiElements.settingsButton = settingsButton

    -- Plant Selection Frame
    local plantFrame = Instance.new("Frame")
    plantFrame.Name = "PlantFrame"
    plantFrame.Parent = mainFrame
    plantFrame.BackgroundColor3 = Theme.Primary
    plantFrame.Position = UDim2.new(0, 0, 0, 50)
    plantFrame.Size = UDim2.new(1, 0, 0, 220)
    Instance.new("UICorner", plantFrame).CornerRadius = UDim.new(0, 6)
    
    local plantTitle = Instance.new("TextLabel")
    plantTitle.Name = "PlantTitle"
    plantTitle.Parent = plantFrame
    plantTitle.BackgroundTransparency = 1
    plantTitle.Position = UDim2.new(0, 10, 0, 10)
    plantTitle.Size = UDim2.new(1, -20, 0, 20)
    plantTitle.Font = Enum.Font.GothamBold
    plantTitle.Text = "Select Plants to Purchase"
    plantTitle.TextColor3 = Theme.Text
    plantTitle.TextSize = 16
    plantTitle.TextXAlignment = Enum.TextXAlignment.Left

    -- Scrolling Frame for Plants
    local plantScrollFrame = Instance.new("ScrollingFrame")
    plantScrollFrame.Name = "PlantScrollFrame"
    plantScrollFrame.Parent = plantFrame
    plantScrollFrame.BackgroundTransparency = 1
    plantScrollFrame.Position = UDim2.new(0, 0, 0, 35)
    plantScrollFrame.Size = UDim2.new(1, 0, 1, -40)
    plantScrollFrame.ScrollBarThickness = 8
    plantScrollFrame.ScrollBarImageColor3 = Theme.Accent
    guiElements.plantScrollFrame = plantScrollFrame

    local plantLayout = Instance.new("UIGridLayout", plantScrollFrame)
    plantLayout.CellPadding = UDim2.new(0, 5, 0, 5)
    plantLayout.CellSize = UDim2.new(0.5, -5, 0, 25)
    plantLayout.SortOrder = Enum.SortOrder.LayoutOrder
    plantLayout.StartCorner = Enum.StartCorner.TopLeft

    guiElements.plantCheckboxes = {}

    for i, plantName in ipairs(ALL_FRUITS_AND_VEGETABLES) do
        local checkFrame = Instance.new("Frame")
        checkFrame.Name = plantName .. "Frame"
        checkFrame.Parent = plantScrollFrame
        checkFrame.BackgroundTransparency = 1
        checkFrame.Size = UDim2.new(1, 0, 0, 25)
        checkFrame.LayoutOrder = i

        local checkbox = Instance.new("TextButton")
        checkbox.Name = plantName .. "Checkbox"
        checkbox.Parent = checkFrame
        checkbox.Size = UDim2.new(0, 20, 0, 20)
        checkbox.Position = UDim2.new(0, 5, 0.5, 0)
        checkbox.AnchorPoint = Vector2.new(0, 0.5)
        checkbox.Font = Enum.Font.GothamBold
        checkbox.TextColor3 = Theme.Text
        checkbox.TextSize = 18
        Instance.new("UICorner", checkbox).CornerRadius = UDim.new(0, 4)
        local checkStroke = Instance.new("UIStroke", checkbox)
        checkStroke.Color = Theme.Secondary
        checkStroke.Thickness = 2
        
        local plantLabel = Instance.new("TextLabel")
        plantLabel.Name = plantName .. "Label"
        plantLabel.Parent = checkFrame
        plantLabel.BackgroundTransparency = 1
        plantLabel.Position = UDim2.new(0, 35, 0, 0)
        plantLabel.Size = UDim2.new(1, -40, 1, 0)
        plantLabel.Font = Enum.Font.Gotham
        plantLabel.Text = plantName
        plantLabel.TextColor3 = Theme.SubText
        plantLabel.TextSize = 14
        plantLabel.TextXAlignment = Enum.TextXAlignment.Left

        guiElements.plantCheckboxes[plantName] = checkbox

        if config.selectedItems[plantName] then
            checkbox.BackgroundColor3 = Theme.Accent
            checkbox.Text = "✓"
            checkStroke.Enabled = false
        else
            checkbox.BackgroundColor3 = Theme.Primary
            checkbox.Text = ""
            checkStroke.Enabled = true
        end
    end

    -- Log Frame
    local logFrame = Instance.new("Frame")
    logFrame.Name = "LogFrame"
    logFrame.Parent = mainFrame
    logFrame.BackgroundColor3 = Theme.Primary
    logFrame.Position = UDim2.new(0, 0, 0, 280)
    logFrame.Size = UDim2.new(1, 0, 1, -285)
    Instance.new("UICorner", logFrame).CornerRadius = UDim.new(0, 6)

    local logTitle = Instance.new("TextLabel")
    logTitle.Name = "LogTitle"
    logTitle.Parent = logFrame
    logTitle.BackgroundTransparency = 1
    logTitle.Position = UDim2.new(0, 10, 0, 10)
    logTitle.Size = UDim2.new(1, -20, 0, 20)
    logTitle.Font = Enum.Font.GothamBold
    logTitle.Text = "Activity Log"
    logTitle.TextColor3 = Theme.Text
    logTitle.TextSize = 16
    logTitle.TextXAlignment = Enum.TextXAlignment.Left

    local logScrollFrame = Instance.new("ScrollingFrame")
    logScrollFrame.Name = "LogScrollFrame"
    logScrollFrame.Parent = logFrame
    logScrollFrame.BackgroundTransparency = 1
    logScrollFrame.Position = UDim2.new(0, 0, 0, 35)
    logScrollFrame.Size = UDim2.new(1, 0, 1, -40)
    logScrollFrame.ScrollBarThickness = 8
    logScrollFrame.ScrollBarImageColor3 = Theme.Accent
    logScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    guiElements.logScrollFrame = logScrollFrame

    local logLayout = Instance.new("UIListLayout", logScrollFrame)
    logLayout.Padding = UDim.new(0, 2)
    logLayout.SortOrder = Enum.SortOrder.LayoutOrder
    logLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    guiElements.logLayout = logLayout
    
    local logPadding = Instance.new("UIPadding", logScrollFrame)
    logPadding.PaddingLeft = UDim.new(0, 10)
    logPadding.PaddingRight = UDim.new(0, 10)


    -- Settings Frame (initially hidden)
    local settingsFrame = Instance.new("Frame")
    settingsFrame.Name = "SettingsFrame"
    settingsFrame.Parent = screenGui
    settingsFrame.BackgroundColor3 = Theme.Background
    settingsFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    settingsFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    settingsFrame.Size = UDim2.new(0, 350, 0, 220)
    settingsFrame.Visible = false
    settingsFrame.ZIndex = 1001
    Instance.new("UICorner", settingsFrame).CornerRadius = UDim.new(0, 8)
    local settingsStroke = Instance.new("UIStroke", settingsFrame)
    settingsStroke.Color = Theme.Stroke
    settingsStroke.Transparency = 0.5
    settingsStroke.Thickness = 2
    guiElements.settingsFrame = settingsFrame

    -- Settings Title Bar
    local settingsTitleBar = Instance.new("Frame")
    settingsTitleBar.Name = "SettingsTitleBar"
    settingsTitleBar.Parent = settingsFrame
    settingsTitleBar.BackgroundColor3 = Theme.Primary
    settingsTitleBar.Size = UDim2.new(1, 0, 0, 40)
    Instance.new("UICorner", settingsTitleBar).CornerRadius = UDim.new(0, 8)

    local settingsTitleLabel = Instance.new("TextLabel")
    settingsTitleLabel.Name = "SettingsTitleLabel"
    settingsTitleLabel.Parent = settingsTitleBar
    settingsTitleLabel.BackgroundTransparency = 1
    settingsTitleLabel.Position = UDim2.new(0, 15, 0.5, 0)
    settingsTitleLabel.AnchorPoint = Vector2.new(0, 0.5)
    settingsTitleLabel.Size = UDim2.new(1, -40, 1, 0)
    settingsTitleLabel.Font = Enum.Font.GothamBold
    settingsTitleLabel.Text = "⚙️ Settings"
    settingsTitleLabel.TextColor3 = Theme.Text
    settingsTitleLabel.TextSize = 18
    settingsTitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Settings Close Button
    local settingsCloseButton = Instance.new("TextButton")
    settingsCloseButton.Name = "SettingsCloseButton"
    settingsCloseButton.Parent = settingsTitleBar
    settingsCloseButton.BackgroundTransparency = 1
    settingsCloseButton.Position = UDim2.new(1, -25, 0.5, 0)
    settingsCloseButton.AnchorPoint = Vector2.new(0.5, 0.5)
    settingsCloseButton.Size = UDim2.new(0, 25, 0, 25)
    settingsCloseButton.Font = Enum.Font.GothamBold
    settingsCloseButton.Text = "X"
    settingsCloseButton.TextColor3 = Theme.SubText
    settingsCloseButton.TextSize = 16
    guiElements.settingsCloseButton = settingsCloseButton

    -- Settings Content Area
    local settingsContent = Instance.new("Frame")
    settingsContent.Name = "SettingsContent"
    settingsContent.Parent = settingsFrame
    settingsContent.BackgroundTransparency = 1
    settingsContent.Position = UDim2.new(0.05, 0, 0, 50)
    settingsContent.Size = UDim2.new(0.9, 0, 1, -100)

    -- Retry Delay
    local retryDelayLabel = Instance.new("TextLabel")
    retryDelayLabel.Name = "RetryDelayLabel"
    retryDelayLabel.Parent = settingsContent
    retryDelayLabel.BackgroundTransparency = 1
    retryDelayLabel.Size = UDim2.new(1, 0, 0, 20)
    retryDelayLabel.Font = Enum.Font.GothamBold
    retryDelayLabel.Text = "Buy Delay (seconds):"
    retryDelayLabel.TextColor3 = Theme.Text
    retryDelayLabel.TextSize = 16
    retryDelayLabel.TextXAlignment = Enum.TextXAlignment.Left

    local retryDelayBox = Instance.new("TextBox")
    retryDelayBox.Name = "RetryDelayBox"
    retryDelayBox.Parent = settingsContent
    retryDelayBox.BackgroundColor3 = Theme.Primary
    retryDelayBox.Position = UDim2.new(0, 0, 0, 30)
    retryDelayBox.Size = UDim2.new(1, 0, 0, 35)
    retryDelayBox.Font = Enum.Font.Gotham
    retryDelayBox.Text = tostring(config.retryDelay)
    retryDelayBox.TextColor3 = Theme.Text
    retryDelayBox.TextSize = 14
    retryDelayBox.PlaceholderText = "e.g. 0.2"
    retryDelayBox.PlaceholderColor3 = Theme.SubText
    retryDelayBox.ClearTextOnFocus = false
    Instance.new("UICorner", retryDelayBox).CornerRadius = UDim.new(0, 6)
    local retryStroke = Instance.new("UIStroke", retryDelayBox)
    retryStroke.Color = Theme.Secondary
    retryStroke.Thickness = 2
    guiElements.retryDelayBox = retryDelayBox

    -- Save Button
    local saveSettingsButton = Instance.new("TextButton")
    saveSettingsButton.Name = "SaveSettingsButton"
    saveSettingsButton.Parent = settingsFrame
    saveSettingsButton.BackgroundColor3 = Theme.Accent
    saveSettingsButton.AnchorPoint = Vector2.new(0.5, 1)
    saveSettingsButton.Position = UDim2.new(0.5, 0, 1, -15)
    saveSettingsButton.Size = UDim2.new(0.9, 0, 0, 40)
    saveSettingsButton.Font = Enum.Font.GothamBold
    saveSettingsButton.Text = "💾 SAVE & CLOSE"
    saveSettingsButton.TextColor3 = Theme.Text
    saveSettingsButton.TextSize = 16
    Instance.new("UICorner", saveSettingsButton).CornerRadius = UDim.new(0, 6)
    guiElements.saveButton = saveSettingsButton
end

--[[
    Updates the visual state of buttons based on the current running status.
    
    This function changes the appearance and text of the start/stop button and
    floating toggle button to reflect whether auto-purchasing is currently
    active or inactive. Colors and button text are updated accordingly.
    
    @return void - Updates button appearance directly
--]]
function GUIManager.updateToggleButtonState()
    if config.isRunning then
        guiElements.startStopButton.Text = "⏸ STOP"
        guiElements.startStopButton.BackgroundColor3 = Theme.Failure
        guiElements.toggleButton.BackgroundColor3 = Theme.Success
    else
        guiElements.startStopButton.Text = "▶ START"
        guiElements.startStopButton.BackgroundColor3 = Theme.Success
        guiElements.toggleButton.BackgroundColor3 = Theme.Accent
    end
end

--[[
    Binds event handlers to all interactive GUI elements.
    
    This function connects mouse click events and other interactions to their
    respective callback functions. It handles plant checkbox toggles, button clicks,
    settings changes, and GUI visibility controls. Must be called after create().
    
    @return void - Connects event handlers to GUI elements
--]]
function GUIManager.bindEvents()
    -- Plant Checkbox Events
    for plantName, checkbox in pairs(guiElements.plantCheckboxes) do
        checkbox.MouseButton1Click:Connect(function()
            config.selectedItems[plantName] = not config.selectedItems[plantName]
            local stroke = checkbox:FindFirstChildOfClass("UIStroke")

            if config.selectedItems[plantName] then
                checkbox.BackgroundColor3 = Theme.Accent
                checkbox.Text = "✓"
                if stroke then stroke.Enabled = false end
            else
                checkbox.BackgroundColor3 = Theme.Primary
                checkbox.Text = ""
                if stroke then stroke.Enabled = true end
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

    -- Save Settings Button Event
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
        GUIManager.updateLog("❌ GUI closed. Script active, use 🌱 to reopen.")
    end)
end


--[[-----------------------------------------------------------------------------
    Core Autobuy Logic
-------------------------------------------------------------------------------]]

local AutoBuyer = {}

--[[
    Processes and updates seed stock data from the game server.
    
    This function receives a table containing stock information for various seeds
    and updates the local currentStocks table accordingly. It logs warnings for
    any unknown items received from the server.
    
    @param stockTable (table) - Table containing stock data with format:
                               {ItemName = {Stock = number, MaxStock = number}, ...}
    @return void - Updates the global currentStocks table directly
--]]
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

--[[
    Attempts to purchase a single seed of the specified item.
    
    This function checks if the item is in stock, fires the buy remote event,
    and waits for the configured retry delay. It uses pcall for safe execution
    and returns success status along with any error information.
    
    @param itemName (string) - The name of the seed/item to purchase
    @return success (boolean), error (string|nil) - Purchase result and error info
--]]
function AutoBuyer.tryBuySeed(itemName)

    if not currentStocks[itemName] or currentStocks[itemName].Stock <= 0 then
        return false, "No stock available for " .. itemName
    end

    local success, err = pcall(function()
        BuyRemote:FireServer(itemName)
    end)

    task.wait(config.retryDelay) -- Use task.wait for better yielding    
    return success, err

end

--[[
    Handles the main purchasing logic when stock is refreshed.
    
    This function is triggered when new stock data arrives from the server.
    It identifies selected items that are in stock, attempts to purchase them
    with retry logic, logs purchase progress, and manages the overall buying
    session. Respects user settings for delays and selected items.
    
    @return void - Performs purchases and logs activity
--]]
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

        if not config.selectedItems[itemName] then -- Double check if it was deselected during a long buy cycle
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
                    else
                         -- We don't need to log the first attempt 🤷‍♀️
                         -- GUIManager.updateLog("✅ " .. itemName .. " purchased (" .. successfulPurchases .. "/" .. stockQuantity .. ")")
                    end

                    break -- Break from retry loop for this unit

                else

                    lastError = err

                    if attempt < 3 then
                        GUIManager.updateLog("🔄 Retry " .. attempt .. "/3 for " .. itemName .. " failed: " .. tostring(err))
                        -- retryDelay is already in tryBuySeed, no need for extra wait here unless specifically desired between retries of the SAME unit.
                    end

                end
            end

            if not purchasedThisUnit then

                GUIManager.updateLog("❌ Failed to buy 1 unit of " .. itemName .. " after 3 attempts. Error: " .. tostring(lastError))
                -- continues trying to buy remaining stockQuantity

            end

        end

        if successfulPurchases > 0 then

            local efficiency = math.floor((successfulPurchases / stockQuantity) * 100)
            GUIManager.updateLog("☑️ " .. itemName .. " processing complete: " .. successfulPurchases .. "/" .. stockQuantity .. " purchased (" .. efficiency .. "% success for this batch).")

        else
            GUIManager.updateLog("❌ " .. itemName .. " processing failed: 0/" .. stockQuantity .. " purchased for this batch.")

        end

        if next(itemsToBuy, itemName) ~= nil and config.isRunning then -- If not the last item and still running
            task.wait(config.retryDelay * 2) -- Small additional delay between different item types for safety/observation
        end

    end

    GUIManager.updateLog("🏁 Stock purchase session completed.")

end


--[[-----------------------------------------------------------------------------    
    Event Listeners and Initialization
-------------------------------------------------------------------------------]]

--[[
    Handles incoming data stream events from the game server.
    
    This function processes DataStreamEvent messages, specifically looking for
    seed stock updates. When stock data is found in the event payload, it
    triggers the stock processing and purchasing logic.
    
    @param eventType (string) - The type of event received (e.g., "UpdateData")
    @param object (string) - The object associated with the event? idk but not important
    @param tbl (table) - Table containing the event data and information
    @return void - Processes events and triggers appropriate handlers
--]]
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

--[[
    Initializes the autobuy script and sets up all components.
    
    This function orchestrates the startup sequence by loading saved settings,
    creating the GUI interface, setting up event bindings, connecting to game
    events, and displaying initial status messages. It serves as the main
    entry point for script initialization.
    
    @return void - Initializes all script components and starts the system
--]]
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
