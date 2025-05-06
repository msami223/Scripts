--[[
    Roblox Key System Loader
    
    Instructions:
    1. Copy this script to your executor
    2. Click "Get Key" and follow instructions on the website
    3. Paste key into the textbox and click "Submit Key"
    4. The main script will automatically load if the key is valid
]]

-- Script Settings (CHANGE THESE)
local MAIN_SCRIPT_URL = "https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua"
local WEBSITE_BASE_URL = "https://wordpress-1442530-5481910.cloudwaysapps.com"
local VERIFICATION_URL = WEBSITE_BASE_URL .. "/?verify=1&key="
local GET_KEY_URL = WEBSITE_BASE_URL .. "/get-key/"
local DEBUG_MODE = true

-- For troubleshooting only - set to true if regular verification isn't working
local USE_DEBUG_ENDPOINT = false
local DEBUG_VERIFICATION_URL = WEBSITE_BASE_URL .. "/?debug_verify=1"

-- Debug print function
local function debugPrint(...)
    if DEBUG_MODE then
        print("[KeySystem Debug]", ...)
    end
end

-- Create UI
local KeySystemUI = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local Instructions = Instance.new("TextLabel")
local KeyInputBox = Instance.new("TextBox")
local GetKeyButton = Instance.new("TextButton")
local SubmitKeyButton = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")
local CloseButton = Instance.new("TextButton")

-- Set UI properties
KeySystemUI.Name = "KeySystemUI"
KeySystemUI.Parent = game:GetService("CoreGui")
KeySystemUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
KeySystemUI.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = KeySystemUI
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 400, 0, 250)
MainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MainFrame.BorderSizePixel = 0

Title.Name = "Title"
Title.Parent = MainFrame
Title.Position = UDim2.new(0, 0, 0, 10)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "Script Key Verification"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20

Instructions.Name = "Instructions"
Instructions.Parent = MainFrame
Instructions.Position = UDim2.new(0, 20, 0, 50)
Instructions.Size = UDim2.new(1, -40, 0, 40)
Instructions.BackgroundTransparency = 1
Instructions.Font = Enum.Font.Gotham
Instructions.Text = "Click 'Get Key', complete steps on website, paste key below."
Instructions.TextColor3 = Color3.fromRGB(200, 200, 200)
Instructions.TextSize = 14
Instructions.TextWrapped = true

KeyInputBox.Name = "KeyInputBox"
KeyInputBox.Parent = MainFrame
KeyInputBox.Position = UDim2.new(0.5, -150, 0, 100)
KeyInputBox.Size = UDim2.new(0, 300, 0, 40)
KeyInputBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
KeyInputBox.BorderSizePixel = 0
KeyInputBox.Font = Enum.Font.Gotham
KeyInputBox.PlaceholderText = "Paste key here..."
KeyInputBox.Text = ""
KeyInputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInputBox.TextSize = 14
KeyInputBox.ClearTextOnFocus = false

GetKeyButton.Name = "GetKeyButton"
GetKeyButton.Parent = MainFrame
GetKeyButton.Position = UDim2.new(0.25, -50, 0, 160)
GetKeyButton.Size = UDim2.new(0, 100, 0, 30)
GetKeyButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
GetKeyButton.BorderSizePixel = 0
GetKeyButton.Font = Enum.Font.GothamBold
GetKeyButton.Text = "Get Key"
GetKeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
GetKeyButton.TextSize = 14

SubmitKeyButton.Name = "SubmitKeyButton"
SubmitKeyButton.Parent = MainFrame
SubmitKeyButton.Position = UDim2.new(0.75, -50, 0, 160)
SubmitKeyButton.Size = UDim2.new(0, 100, 0, 30)
SubmitKeyButton.BackgroundColor3 = Color3.fromRGB(0, 180, 60)
SubmitKeyButton.BorderSizePixel = 0
SubmitKeyButton.Font = Enum.Font.GothamBold
SubmitKeyButton.Text = "Submit Key"
SubmitKeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitKeyButton.TextSize = 14

StatusLabel.Name = "StatusLabel"
StatusLabel.Parent = MainFrame
StatusLabel.Position = UDim2.new(0, 20, 0, 210)
StatusLabel.Size = UDim2.new(1, -40, 0, 20)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextSize = 14

-- Add Close Button
CloseButton.Name = "CloseButton"
CloseButton.Parent = MainFrame
CloseButton.Position = UDim2.new(1, -30, 0, 10)
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
CloseButton.BorderSizePixel = 0
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14

-- Add corner radius to UI elements
function AddCorner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = instance
end

AddCorner(MainFrame, 10)
AddCorner(KeyInputBox, 5)
AddCorner(GetKeyButton, 5)
AddCorner(SubmitKeyButton, 5)
AddCorner(CloseButton, 10)

-- Close Button Logic
CloseButton.MouseButton1Click:Connect(function()
    KeySystemUI:Destroy()
end)

-- Get Key Button Logic
GetKeyButton.MouseButton1Click:Connect(function()
    setclipboard(GET_KEY_URL)
    StatusLabel.Text = "Status: Key page URL copied! Paste in browser."
    StatusLabel.TextColor3 = Color3.fromRGB(60, 180, 255)
    
    -- Reset status after 3 seconds
    task.spawn(function()
        task.wait(3)
        StatusLabel.Text = "Status: Idle"
        StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    end)
end)

-- Test if HTTP Requests are enabled
local function testHttpEnabled()
    local HttpService = game:GetService("HttpService")
    local success = pcall(function()
        HttpService:JSONEncode({test = true})
    end)
    return success
end

-- Submit Key Button Logic
SubmitKeyButton.MouseButton1Click:Connect(function()
    local HttpService = game:GetService("HttpService")
    
    -- Test if HTTP Requests are enabled
    if not testHttpEnabled() then
        StatusLabel.Text = "Error: HTTP Requests not enabled!"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end
    
    -- Get the entered key
    local enteredKey = KeyInputBox.Text
    
    -- Basic validation
    if string.gsub(enteredKey, "%s", "") == "" then
        StatusLabel.Text = "Status: Please enter a key."
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end
    
    -- Update status
    StatusLabel.Text = "Status: Verifying key..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
    
    -- Disable the Submit button temporarily
    SubmitKeyButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    SubmitKeyButton.Active = false
    
    -- Determine which verification URL to use
    local fullUrl
    if USE_DEBUG_ENDPOINT then
        fullUrl = DEBUG_VERIFICATION_URL
        debugPrint("Using debug endpoint")
    else
        -- URL-encode the key
        local encodedKey = HttpService:UrlEncode(enteredKey)
        fullUrl = VERIFICATION_URL .. encodedKey
    end
    
    -- Debug output
    debugPrint("Attempting to connect to: " .. fullUrl)
    
    -- First test the test endpoint
    local testUrl = WEBSITE_BASE_URL .. "/?test=1"
    debugPrint("Testing connection with: " .. testUrl)
    
    local testSuccess, testResult = pcall(function()
        return HttpService:GetAsync(testUrl, false, {
            ["User-Agent"] = "Mozilla/5.0",
            ["Cache-Control"] = "no-cache"
        })
    end)
    
    if not testSuccess then
        debugPrint("Test connection failed:", testResult)
        
        -- Try one more time with different headers
        local secondAttemptSuccess, secondAttemptResult = pcall(function()
            return HttpService:GetAsync(testUrl, false, {
                ["User-Agent"] = "Roblox/1.0"
            })
        end)
        
        if not secondAttemptSuccess then
            StatusLabel.Text = "Error: Cannot connect to server. Make sure HTTP Requests are enabled!"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            SubmitKeyButton.BackgroundColor3 = Color3.fromRGB(0, 180, 60)
            SubmitKeyButton.Active = true
            return
        else
            debugPrint("Second test attempt succeeded:", secondAttemptResult)
        end
    else
        debugPrint("Test connection successful:", testResult)
    end
    
    -- Set headers - try with a standard browser user-agent
    local headers = {
        ["User-Agent"] = "Mozilla/5.0",
        ["Cache-Control"] = "no-cache"
    }
    
    -- Make the HTTP Request with error handling
    local success, result = pcall(function()
        return HttpService:GetAsync(fullUrl, false, headers)
    end)
    
    -- Handle the pcall result
    if not success then
        debugPrint("HTTP Request Failed:", result)
        
        -- Try again with a different User-Agent
        local secondSuccess, secondResult = pcall(function()
            return HttpService:GetAsync(fullUrl, false, {
                ["User-Agent"] = "Roblox/1.0"
            })
        end)
        
        if not secondSuccess then
            StatusLabel.Text = "Error: Cannot connect to verification server."
            StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            SubmitKeyButton.BackgroundColor3 = Color3.fromRGB(0, 180, 60)
            SubmitKeyButton.Active = true
            warn("Key verification HTTP request failed:", result)
            return
        else
            result = secondResult
            debugPrint("Second attempt succeeded with different headers")
        end
    end
    
    -- Debug output
    debugPrint("Server response:", result)
    
    -- Process the result string
    if result == "valid" then
        StatusLabel.Text = "Status: Valid Key! Loading script..."
        StatusLabel.TextColor3 = Color3.fromRGB(60, 255, 60)
        
        -- Fetch the main script
        local fetchSuccess, scriptCodeOrError = pcall(function()
            return HttpService:GetAsync(MAIN_SCRIPT_URL, false, headers)
        end)
        
        if not fetchSuccess then
            debugPrint("Script Fetch Failed:", scriptCodeOrError)
            StatusLabel.Text = "Error: Failed to download main script."
            StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            SubmitKeyButton.BackgroundColor3 = Color3.fromRGB(0, 180, 60)
            SubmitKeyButton.Active = true
            warn("Failed to fetch main script:", scriptCodeOrError)
            return
        end
        
        -- Execute the main script
        StatusLabel.Text = "Status: Executing main script..."
        task.wait(0.5)
        
        local runSuccess, runError = pcall(loadstring(scriptCodeOrError))
        
        if not runSuccess then
            debugPrint("Script Execution Failed:", runError)
            warn("!!! ERROR EXECUTING MAIN SCRIPT:", runError)
            StatusLabel.Text = "Error: Failed to execute main script."
            StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            SubmitKeyButton.BackgroundColor3 = Color3.fromRGB(0, 180, 60)
            SubmitKeyButton.Active = true
            return
        end
        
        -- Script executed successfully, remove the UI
        task.wait(1)
        KeySystemUI:Destroy()
    
    elseif result == "expired" then
        StatusLabel.Text = "Error: Key has expired. Please get a new one."
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        SubmitKeyButton.BackgroundColor3 = Color3.fromRGB(0, 180, 60)
        SubmitKeyButton.Active = true
    
    elseif result == "invalid" then
        StatusLabel.Text = "Error: Invalid key entered."
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        SubmitKeyButton.BackgroundColor3 = Color3.fromRGB(0, 180, 60)
        SubmitKeyButton.Active = true
    
    elseif result == "error" then
        StatusLabel.Text = "Error: Server encountered an issue during verification."
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        SubmitKeyButton.BackgroundColor3 = Color3.fromRGB(0, 180, 60)
        SubmitKeyButton.Active = true
    
    else
        StatusLabel.Text = "Error: Unexpected server response."
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        SubmitKeyButton.BackgroundColor3 = Color3.fromRGB(0, 180, 60)
        SubmitKeyButton.Active = true
        warn("Unexpected verification response:", result)
    end
end)

-- Run a quick test to see if HTTP Requests are enabled
if not testHttpEnabled() then
    StatusLabel.Text = "Warning: HTTP Requests not enabled in this game!"
    StatusLabel.TextColor3 = Color3.fromRGB(255, 180, 0)
end

-- Print initialization message
print("Key System Loader initialized!")
print("Click 'Get Key' to open the key generation page.")
