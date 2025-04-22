-- Key System Script for Roblox (Educational Purposes Only)
-- Redesigned UI and verification logic

-- Create the key verification UI with a modern design
local function createKeyUI()
    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local TopBar = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local CloseButton = Instance.new("TextButton")
    local KeyInput = Instance.new("TextBox")
    local SubmitButton = Instance.new("TextButton")
    local GetKeyButton = Instance.new("TextButton")
    local StatusLabel = Instance.new("TextLabel")
    local Shadow = Instance.new("ImageLabel")
    
    -- Configure ScreenGui
    ScreenGui.Name = "PremiumAccessUI"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Configure Shadow
    Shadow.Name = "Shadow"
    Shadow.Parent = ScreenGui
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.BackgroundTransparency = 1
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Shadow.Size = UDim2.new(0, 340, 0, 240)
    Shadow.Image = "rbxassetid://6014261993"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.5
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    
    -- Configure MainFrame
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
    MainFrame.Size = UDim2.new(0, 300, 0, 200)
    MainFrame.ClipsDescendants = true
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    
    -- Configure TopBar
    TopBar.Name = "TopBar"
    TopBar.Parent = MainFrame
    TopBar.BackgroundColor3 = Color3.fromRGB(45, 50, 80)
    TopBar.BorderSizePixel = 0
    TopBar.Size = UDim2.new(1, 0, 0, 35)
    
    -- Configure Title
    Title.Name = "Title"
    Title.Parent = TopBar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "Premium Access"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16.000
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Configure CloseButton
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = TopBar
    CloseButton.BackgroundTransparency = 1
    CloseButton.Position = UDim2.new(1, -35, 0, 0)
    CloseButton.Size = UDim2.new(0, 35, 1, 0)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 18.000
    
    -- Configure KeyInput
    KeyInput.Name = "KeyInput"
    KeyInput.Parent = MainFrame
    KeyInput.BackgroundColor3 = Color3.fromRGB(35, 40, 60)
    KeyInput.BorderSizePixel = 0
    KeyInput.Position = UDim2.new(0.5, -125, 0.35, 0)
    KeyInput.Size = UDim2.new(0, 250, 0, 35)
    KeyInput.Font = Enum.Font.Gotham
    KeyInput.PlaceholderText = "Enter your activation key..."
    KeyInput.Text = ""
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInput.TextSize = 14.000
    
    -- Round the input box corners
    local UICorner1 = Instance.new("UICorner")
    UICorner1.CornerRadius = UDim.new(0, 6)
    UICorner1.Parent = KeyInput
    
    -- Configure SubmitButton
    SubmitButton.Name = "SubmitButton"
    SubmitButton.Parent = MainFrame
    SubmitButton.BackgroundColor3 = Color3.fromRGB(70, 120, 220)
    SubmitButton.BorderSizePixel = 0
    SubmitButton.Position = UDim2.new(0.5, -125, 0.55, 0)
    SubmitButton.Size = UDim2.new(0, 120, 0, 35)
    SubmitButton.Font = Enum.Font.GothamSemibold
    SubmitButton.Text = "Activate"
    SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubmitButton.TextSize = 14.000
    
    -- Round the submit button corners
    local UICorner2 = Instance.new("UICorner")
    UICorner2.CornerRadius = UDim.new(0, 6)
    UICorner2.Parent = SubmitButton
    
    -- Configure GetKeyButton
    GetKeyButton.Name = "GetKeyButton"
    GetKeyButton.Parent = MainFrame
    GetKeyButton.BackgroundColor3 = Color3.fromRGB(45, 50, 70)
    GetKeyButton.BorderSizePixel = 0
    GetKeyButton.Position = UDim2.new(0.5, 5, 0.55, 0)
    GetKeyButton.Size = UDim2.new(0, 120, 0, 35)
    GetKeyButton.Font = Enum.Font.GothamSemibold
    GetKeyButton.Text = "Get Key"
    GetKeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    GetKeyButton.TextSize = 14.000
    
    -- Round the get key button corners
    local UICorner3 = Instance.new("UICorner")
    UICorner3.CornerRadius = UDim.new(0, 6)
    UICorner3.Parent = GetKeyButton
    
    -- Configure StatusLabel
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Parent = MainFrame
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0, 0, 0.8, 0)
    StatusLabel.Size = UDim2.new(1, 0, 0, 20)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Text = "Enter your key to access premium features"
    StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    StatusLabel.TextSize = 12.000
    
    -- Round the main frame corners
    local UICorner4 = Instance.new("UICorner")
    UICorner4.CornerRadius = UDim.new(0, 8)
    UICorner4.Parent = MainFrame
    
    -- Round the top bar corners
    local UICorner5 = Instance.new("UICorner")
    UICorner5.CornerRadius = UDim.new(0, 8)
    UICorner5.Parent = TopBar
    
    -- Make the top bar only round at the top
    local Frame = Instance.new("Frame")
    Frame.Parent = TopBar
    Frame.BackgroundColor3 = Color3.fromRGB(45, 50, 80)
    Frame.BorderSizePixel = 0
    Frame.Position = UDim2.new(0, 0, 1, -8)
    Frame.Size = UDim2.new(1, 0, 0, 8)
    
    return {
        ScreenGui = ScreenGui,
        KeyInput = KeyInput,
        SubmitButton = SubmitButton,
        GetKeyButton = GetKeyButton,
        StatusLabel = StatusLabel,
        CloseButton = CloseButton
    }
end

-- Verify key with server
local function verifyKey(key)
    -- Alternative verification URL
    local url = "https://keyauth.vercel.app/api/verify?key=" .. key
    
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    
    if success then
        if string.find(response, "valid") then
            return true, "valid"
        elseif string.find(response, "expired") then
            return false, "expired"
        elseif string.find(response, "used") then
            return false, "used"
        else
            return false, "invalid"
        end
    else
        return false, "error"
    end
end

-- Run the script after key verification
local function runMainScript()
    -- Main script logic
    local Games = loadstring(game:HttpGet("https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua", true))()

    for PlaceID, Execute in pairs(Games) do
        if PlaceID == game.PlaceId then
            loadstring(game:HttpGet(Execute))()
        end
    end
end

-- Initialize key system and UI
local function initKeySystem()
    local ui = createKeyUI()
    
    -- Handle Close button
    ui.CloseButton.MouseButton1Click:Connect(function()
        ui.ScreenGui:Destroy()
    end)
    
    -- Handle Get Key button
    ui.GetKeyButton.MouseButton1Click:Connect(function()
        -- Alternative key website
        local keyWebsite = "https://keyauth.vercel.app/getkey"
        
        -- Copy URL to clipboard
        setclipboard(keyWebsite)
        
        ui.StatusLabel.Text = "Key website copied to clipboard!"
        ui.StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    end)
    
    -- Handle Submit button
    ui.SubmitButton.MouseButton1Click:Connect(function()
        local key = ui.KeyInput.Text
        
        if key == "" then
            ui.StatusLabel.Text = "Please enter a valid key"
            ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            return
        end
        
        ui.StatusLabel.Text = "Authenticating..."
        ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
        
        -- Visual feedback on button
        local originalColor = ui.SubmitButton.BackgroundColor3
        ui.SubmitButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        ui.SubmitButton.Text = "Checking..."
        
        task.delay(1.5, function()
            local isValid, status = verifyKey(key)
            
            if isValid then
                ui.StatusLabel.Text = "Authentication successful!"
                ui.StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                ui.SubmitButton.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
                ui.SubmitButton.Text = "Success!"
                
                task.delay(1, function()
                    ui.ScreenGui:Destroy()
                    runMainScript()
                end)
            else
                ui.SubmitButton.BackgroundColor3 = originalColor
                ui.SubmitButton.Text = "Activate"
                
                if status == "expired" then
                    ui.StatusLabel.Text = "Key expired - please get a new one"
                    ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                elseif status == "used" then
                    ui.StatusLabel.Text = "Key already in use on another device"
                    ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                else
                    ui.StatusLabel.Text = "Invalid key - please check and try again"
                    ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                end
            end
        end)
    end)
    
    -- Add hover effects
    local function addButtonEffect(button)
        local originalColor = button.BackgroundColor3
        local hoverColor = Color3.new(
            math.min(originalColor.R * 1.1, 1),
            math.min(originalColor.G * 1.1, 1),
            math.min(originalColor.B * 1.1, 1)
        )
        
        button.MouseEnter:Connect(function()
            button.BackgroundColor3 = hoverColor
        end)
        
        button.MouseLeave:Connect(function()
            button.BackgroundColor3 = originalColor
        end)
    end
    
    addButtonEffect(ui.SubmitButton)
    addButtonEffect(ui.GetKeyButton)
    
    return ui
end

-- Start the key system
initKeySystem()
