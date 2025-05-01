--[[
    Multi-Distributor Key System for Roblox Scripts
    
    Configuration:
    - WEBSITE_URL: Your WordPress website URL
    - SCRIPT_ID: Your script identifier (used for tracking)
    - DISTRIBUTOR_ID: Specific distributor ID (alphanumeric code) or leave empty for random distributor
    - SCRIPT_URL: The URL of the script to execute after key verification
]]

-- Configuration (Edit these values)
local WEBSITE_URL = "https://wordpress-1442530-5470290.cloudwaysapps.com"
local SCRIPT_ID = "blox-fruits" -- Change this to your script identifier
local DISTRIBUTOR_ID = "BCrKgLfr" -- Set to specific distributor ID or leave empty for random distributor
local SCRIPT_URL = "https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua" -- URL of your script to execute

-- Create the key verification UI
local function createKeyUI()
    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local CloseButton = Instance.new("TextButton")
    local KeyInput = Instance.new("TextBox")
    local SubmitButton = Instance.new("TextButton")
    local GetKeyButton = Instance.new("TextButton")
    local StatusLabel = Instance.new("TextLabel")
    local DistributorLabel = Instance.new("TextLabel")
    
    -- Configure ScreenGui
    ScreenGui.Name = "KeySystemUI"
    
    -- Use the correct parent based on environment
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = game:GetService("CoreGui")
    elseif gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = game:GetService("CoreGui")
    end
    
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Configure MainFrame
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -175, 0.5, -125)
    MainFrame.Size = UDim2.new(0, 350, 0, 250)
    MainFrame.ClipsDescendants = true
    
    -- Add corner radius to MainFrame
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame
    
    -- Configure Title
    Title.Name = "Title"
    Title.Parent = MainFrame
    Title.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
    Title.BorderSizePixel = 0
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Font = Enum.Font.GothamSemibold
    Title.Text = "Script Key System"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18.000
    
    -- Add corner radius to Title
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = Title
    
    -- Configure Close Button
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = Title
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    CloseButton.Position = UDim2.new(1, -35, 0.5, -12)
    CloseButton.Size = UDim2.new(0, 24, 0, 24)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 14.000
    CloseButton.AutoButtonColor = true
    
    -- Add corner radius to Close Button
    local CloseButtonCorner = Instance.new("UICorner")
    CloseButtonCorner.CornerRadius = UDim.new(1, 0)  -- Make it circular
    CloseButtonCorner.Parent = CloseButton
    
    -- Configure KeyInput
    KeyInput.Name = "KeyInput"
    KeyInput.Parent = MainFrame
    KeyInput.BackgroundColor3 = Color3.fromRGB(51, 65, 85)
    KeyInput.BorderSizePixel = 0
    KeyInput.Position = UDim2.new(0.5, -150, 0.35, 0)
    KeyInput.Size = UDim2.new(0, 300, 0, 40)
    KeyInput.Font = Enum.Font.Gotham
    KeyInput.PlaceholderText = "Enter your key here..."
    KeyInput.Text = ""
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInput.TextSize = 14.000
    
    -- Add corner radius to KeyInput
    local KeyInputCorner = Instance.new("UICorner")
    KeyInputCorner.CornerRadius = UDim.new(0, 6)
    KeyInputCorner.Parent = KeyInput
    
    -- Configure SubmitButton
    SubmitButton.Name = "SubmitButton"
    SubmitButton.Parent = MainFrame
    SubmitButton.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
    SubmitButton.BorderSizePixel = 0
    SubmitButton.Position = UDim2.new(0.5, -140, 0.55, 0)
    SubmitButton.Size = UDim2.new(0, 130, 0, 40)
    SubmitButton.Font = Enum.Font.GothamSemibold
    SubmitButton.Text = "Submit Key"
    SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubmitButton.TextSize = 14.000
    SubmitButton.AutoButtonColor = true
    
    -- Add corner radius to SubmitButton
    local SubmitCorner = Instance.new("UICorner")
    SubmitCorner.CornerRadius = UDim.new(0, 6)
    SubmitCorner.Parent = SubmitButton
    
    -- Configure GetKeyButton
    GetKeyButton.Name = "GetKeyButton"
    GetKeyButton.Parent = MainFrame
    GetKeyButton.BackgroundColor3 = Color3.fromRGB(51, 65, 85)
    GetKeyButton.BorderSizePixel = 0
    GetKeyButton.Position = UDim2.new(0.5, 10, 0.55, 0)
    GetKeyButton.Size = UDim2.new(0, 130, 0, 40)
    GetKeyButton.Font = Enum.Font.GothamSemibold
    GetKeyButton.Text = "Get Key"
    GetKeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    GetKeyButton.TextSize = 14.000
    GetKeyButton.AutoButtonColor = true
    
    -- Add corner radius to GetKeyButton
    local GetKeyCorner = Instance.new("UICorner")
    GetKeyCorner.CornerRadius = UDim.new(0, 6)
    GetKeyCorner.Parent = GetKeyButton
    
    -- Configure StatusLabel
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Parent = MainFrame
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0, 0, 0.75, 0)
    StatusLabel.Size = UDim2.new(1, 0, 0, 20)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Text = "Enter key or click Get Key"
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    StatusLabel.TextSize = 14.000
    
    -- Configure DistributorLabel
    DistributorLabel.Name = "DistributorLabel"
    DistributorLabel.Parent = MainFrame
    DistributorLabel.BackgroundTransparency = 1
    DistributorLabel.Position = UDim2.new(0, 0, 0.85, 0)
    DistributorLabel.Size = UDim2.new(1, 0, 0, 20)
    DistributorLabel.Font = Enum.Font.Gotham
    DistributorLabel.Text = ""
    DistributorLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    DistributorLabel.TextSize = 12.000
    
    -- Add visual effects
    local function createGlow()
        local Glow = Instance.new("ImageLabel")
        Glow.Name = "Glow"
        Glow.Parent = MainFrame
        Glow.BackgroundTransparency = 1
        Glow.Position = UDim2.new(0.5, -200, 0.5, -200)
        Glow.Size = UDim2.new(0, 400, 0, 400)
        Glow.Image = "rbxassetid://5028857084"
        Glow.ImageTransparency = 0.8
        Glow.ZIndex = 0
    end
    
    createGlow()
    
    return {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        KeyInput = KeyInput,
        SubmitButton = SubmitButton,
        GetKeyButton = GetKeyButton,
        CloseButton = CloseButton,
        StatusLabel = StatusLabel,
        DistributorLabel = DistributorLabel
    }
end

-- Function to safely copy text to clipboard
local function safeSetClipboard(text)
    local success, result = pcall(function()
        setclipboard(text)
        return true
    end)
    
    if not success then
        -- Try alternative clipboard functions
        if writeclipboard then
            pcall(function() writeclipboard(text) end)
            return true
        elseif Clipboard and Clipboard.set then
            pcall(function() Clipboard.set(text) end)
            return true
        else
            return false
        end
    end
    
    return result
end

-- Verify key with server
local function verifyKey(key)
    -- Build the verification URL with distributor ID
    local url = WEBSITE_URL .. "/?verify=1&key=" .. key
    if DISTRIBUTOR_ID and DISTRIBUTOR_ID ~= "" then
        url = url .. "&d=" .. DISTRIBUTOR_ID
    end
    
    print("Sending verification request to: " .. url) -- Debug: Print the full URL
    
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    
    print("Raw response: '" .. tostring(response) .. "'") -- Debug: Print raw response
    
    if success then
        -- Trim any whitespace from the response
        response = response:gsub("^%s*(.-)%s*$", "%1")
        
        print("Verification response: " .. response) -- Debug output
        
        if response == "valid" then
            return true, "valid"
        elseif response == "expired" then
            return false, "expired"
        elseif response == "invalid_distributor" then
            return false, "invalid_distributor"
        else
            return false, "invalid"
        end
    else
        warn("Verification error: " .. tostring(response)) -- Debug output
        return false, "error"
    end
end

-- Run the script after key verification
local function runMainScript()
    -- Execute the script from the URL specified at the top
    local success, result = pcall(function()
        if SCRIPT_URL and SCRIPT_URL ~= "" then
            -- Load and execute the script
            print("Loading script from: " .. SCRIPT_URL) -- Debug output
            return loadstring(game:HttpGet(SCRIPT_URL))()
        else
            -- Fallback to default behavior if no script URL is provided
            print("No script URL provided, using fallback") -- Debug output
            local Games = loadstring(game:HttpGet("https://raw.githubusercontent.com/newredz/BloxFruits/refs/heads/main/Source.luau"))
            
            for PlaceID, Execute in pairs(Games) do
                if PlaceID == game.PlaceId then
                    loadstring(game:HttpGet(Execute))()
                    return true
                end
            end
            return false
        end
    end)
    
    if not success then
        -- If script loading failed, show an error message
        warn("Script execution error: " .. tostring(result)) -- Debug output
        
        local ScreenGui = Instance.new("ScreenGui")
        local MessageFrame = Instance.new("Frame")
        local MessageLabel = Instance.new("TextLabel")
        local ErrorDetails = Instance.new("TextLabel")
        local CloseButton = Instance.new("TextButton")
        
        -- Use the correct parent based on environment
        if syn and syn.protect_gui then
            syn.protect_gui(ScreenGui)
            ScreenGui.Parent = game:GetService("CoreGui")
        elseif gethui then
            ScreenGui.Parent = gethui()
        else
            ScreenGui.Parent = game:GetService("CoreGui")
        end
        
        MessageFrame.Size = UDim2.new(0, 350, 0, 150)
        MessageFrame.Position = UDim2.new(0.5, -175, 0.5, -75)
        MessageFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        MessageFrame.BorderSizePixel = 0
        MessageFrame.Parent = ScreenGui
        
        -- Add corner radius
        local FrameCorner = Instance.new("UICorner")
        FrameCorner.CornerRadius = UDim.new(0, 6)
        FrameCorner.Parent = MessageFrame
        
        MessageLabel.Size = UDim2.new(1, 0, 0, 30)
        MessageLabel.Position = UDim2.new(0, 0, 0, 10)
        MessageLabel.BackgroundTransparency = 1
        MessageLabel.Font = Enum.Font.GothamBold
        MessageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        MessageLabel.TextSize = 16
        MessageLabel.Text = "Error Loading Script"
        MessageLabel.Parent = MessageFrame
        
        ErrorDetails.Size = UDim2.new(1, -20, 0, 60)
        ErrorDetails.Position = UDim2.new(0, 10, 0, 40)
        ErrorDetails.BackgroundTransparency = 1
        ErrorDetails.Font = Enum.Font.Gotham
        ErrorDetails.TextColor3 = Color3.fromRGB(255, 100, 100)
        ErrorDetails.TextSize = 14
        ErrorDetails.Text = "The script could not be loaded. Please try again later or contact the script owner.\n\nError: " .. tostring(result):sub(1, 100)
        ErrorDetails.TextWrapped = true
        ErrorDetails.Parent = MessageFrame
        
        CloseButton.Size = UDim2.new(0, 100, 0, 30)
        CloseButton.Position = UDim2.new(0.5, -50, 1, -40)
        CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        CloseButton.BorderSizePixel = 0
        CloseButton.Font = Enum.Font.GothamBold
        CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        CloseButton.TextSize = 14
        CloseButton.Text = "Close"
        CloseButton.Parent = MessageFrame
        CloseButton.AutoButtonColor = true
        
        -- Add corner radius to button
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 4)
        ButtonCorner.Parent = CloseButton
        
        CloseButton.MouseButton1Click:Connect(function()
            ScreenGui:Destroy()
        end)
    end
end

-- Initialize key system and UI
local function initKeySystem()
    local ui = createKeyUI()
    
    -- If distributor ID is specified, show it in the UI
    if DISTRIBUTOR_ID and DISTRIBUTOR_ID ~= "" then
        ui.DistributorLabel.Text = "Distributor: " .. DISTRIBUTOR_ID
    end
    
    -- Debug output to check if UI is created
    print("Key System UI created")
    
    -- Handle Close button
    ui.CloseButton.MouseButton1Click:Connect(function()
        print("Close button clicked") -- Debug output
        ui.ScreenGui:Destroy()
    end)
    
    -- Add hover effect for close button
    ui.CloseButton.MouseEnter:Connect(function()
        game:GetService("TweenService"):Create(ui.CloseButton, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(255, 100, 100)}):Play()
    end)
    
    ui.CloseButton.MouseLeave:Connect(function()
        game:GetService("TweenService"):Create(ui.CloseButton, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(255, 70, 70)}):Play()
    end)
    
    -- Handle Get Key button
    ui.GetKeyButton.MouseButton1Click:Connect(function()
        print("Get Key button clicked") -- Debug output
        
        -- Generate the key website URL with distributor ID if specified
        local keyWebsite = WEBSITE_URL
        if DISTRIBUTOR_ID and DISTRIBUTOR_ID ~= "" then
            keyWebsite = keyWebsite .. "/?d=" .. DISTRIBUTOR_ID
        }
        
        -- Copy URL to clipboard
        local clipboardSuccess = safeSetClipboard(keyWebsite)
        
        if clipboardSuccess then
            ui.StatusLabel.Text = "Key website URL copied to clipboard! Paste in your browser."
            ui.StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            ui.StatusLabel.Text = "Could not copy URL. Visit: " .. keyWebsite
            ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        end
    end)
    
    -- Handle Submit button
    ui.SubmitButton.MouseButton1Click:Connect(function()
        print("Submit button clicked") -- Debug output
        
        local key = ui.KeyInput.Text
        
        if key == "" then
            ui.StatusLabel.Text = "Please enter a key!"
            ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            return
        end
        
        ui.StatusLabel.Text = "Verifying key..."
        ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        
        -- Add loading animation
        local loadingDots = 0
        local loadingConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if loadingDots < 3 then
                loadingDots = loadingDots + 1
            else
                loadingDots = 0
            end
            ui.StatusLabel.Text = "Verifying key" .. string.rep(".", loadingDots)
        end)
        
        task.delay(1.5, function()
            loadingConnection:Disconnect()
            
            local isValid, status = verifyKey(key)
            
            if isValid then
                ui.StatusLabel.Text = "Key verified successfully!"
                ui.StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                
                -- Add success animation
                for i = 1, 5 do
                    ui.SubmitButton.BackgroundColor3 = Color3.fromRGB(34, 197, 94):Lerp(Color3.fromRGB(0, 255, 0), i/5)
                    task.wait(0.05)
                end
                
                task.delay(1, function()
                    ui.ScreenGui:Destroy()
                    runMainScript()
                end)
            else
                if status == "expired" then
                    ui.StatusLabel.Text = "This key has expired! Keys expire after 24 hours."
                    ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                elseif status == "invalid_distributor" then
                    ui.StatusLabel.Text = "This key is not valid for this distributor."
                    ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                else
                    ui.StatusLabel.Text = "Invalid key! Please try again."
                    ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                end
                
                -- Add error animation
                for i = 1, 3 do
                    ui.KeyInput.BorderColor3 = Color3.fromRGB(255, 0, 0)
                    ui.KeyInput.BorderSizePixel = 2
                    task.wait(0.1)
                    ui.KeyInput.BorderSizePixel = 0
                    task.wait(0.1)
                end
            end
        end)
    end)
    
    -- Make the UI draggable
    local UserInputService = game:GetService("UserInputService")
    local dragToggle = nil
    local dragStart = nil
    local startPos = nil
    
    local function updateInput(input)
        local delta = input.Position - dragStart
        local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        game:GetService("TweenService"):Create(ui.MainFrame, TweenInfo.new(0.1), {Position = position}):Play()
    end
    
    ui.MainFrame.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragToggle = true
            dragStart = input.Position
            startPos = ui.MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragToggle then
                updateInput(input)
            end
        end
    end)
    
    -- Add manual button event triggers for compatibility with different exploits
    ui.SubmitButton.Activated:Connect(function()
        print("Submit button activated via Activated event") -- Debug output
        ui.SubmitButton.MouseButton1Click:Fire()
    end)
    
    ui.GetKeyButton.Activated:Connect(function()
        print("Get Key button activated via Activated event") -- Debug output
        ui.GetKeyButton.MouseButton1Click:Fire()
    end)
    
    ui.CloseButton.Activated:Connect(function()
        print("Close button activated via Activated event") -- Debug output
        ui.CloseButton.MouseButton1Click:Fire()
    end)
    
    -- Add button hover effects
    local function addButtonHoverEffect(button, defaultColor, hoverColor)
        button.MouseEnter:Connect(function()
            game:GetService("TweenService"):Create(button, TweenInfo.new(0.3), {BackgroundColor3 = hoverColor}):Play()
        end)
        
        button.MouseLeave:Connect(function()
            game:GetService("TweenService"):Create(button, TweenInfo.new(0.3), {BackgroundColor3 = defaultColor}):Play()
        end)
    end
    
    addButtonHoverEffect(ui.SubmitButton, Color3.fromRGB(34, 197, 94), Color3.fromRGB(40, 220, 100))
    addButtonHoverEffect(ui.GetKeyButton, Color3.fromRGB(51, 65, 85), Color3.fromRGB(61, 75, 95))
    
    return ui
end

-- Start the key system
print("Starting key system") -- Debug output
initKeySystem()
print("Key system initialized") -- Debug output
