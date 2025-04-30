-- Key System Script for Roblox with Distributor Support
-- Configure your Distributor ID here:
-- Use "" or "default" for keys generated without a specific distributor ID (main website page).
-- Use the specific Distributor ID (e.g., "cbbda565") for keys generated via a distributor link.
local DISTRIBUTOR_ID = "DISTRIBUTOR_ID_HERE" -- <-- YOU MUST REPLACE THIS!

-- Define the base URL for your key system website and verification endpoint
-- REMEMBER TO REPLACE THESE WITH YOUR ACTUAL WEBSITE URLs!
local KEY_WEBSITE_BASE_URL = "https://wordpress-1442530-5466128.cloudwaysapps.com/" -- Your website base URL (e.g., https://yourdomain.com/)
local VERIFICATION_BASE_URL = "https://wordpress-1442530-5466128.cloudwaysapps.com/?verify=1" -- Your verification endpoint (e.g., https://yourdomain.com/?verify=1)

-- Require necessary services
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players") -- Get Players service
local LocalPlayer = Players.LocalPlayer -- Get LocalPlayer from Players service
local UserInputService = game:GetService("UserInputService")

-- Create the key verification UI
local function createKeyUI()
    -- Clean up any existing UI just in case
    local existingUi = CoreGui:FindFirstChild("KeySystemUI")
    if existingUi then
        existingUi:Destroy()
    end

    -- Create basic UI elements
    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local KeyInput = Instance.new("TextBox")
    local SubmitButton = Instance.new("TextButton")
    local GetKeyButton = Instance.new("TextButton")
    local StatusLabel = Instance.new("TextLabel")
    local DistributorLabel = Instance.new("TextLabel")

    -- Configure ScreenGui
    ScreenGui.Name = "KeySystemUI"
    ScreenGui.Parent = CoreGui -- Parent to CoreGui so it's visible in any game/place
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 1000 -- Make sure it's on top of most other GUIs

    -- Configure MainFrame (the main window)
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 23, 42) -- Dark Blue/Gray
    MainFrame.BackgroundTransparency = 0.1 -- Slightly transparent
    MainFrame.BorderColor3 = Color3.fromRGB(40, 60, 90) -- Darker Border
    MainFrame.BorderSizePixel = 1
    -- Center the frame dynamically based on screen size
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = UDim2.new(0, 300, 0, 220) -- Size of the frame
    MainFrame.Draggable = true -- Make it draggable
    MainFrame.CornerRadius = UDim.new(0, 8) -- Rounded corners
    MainFrame.ClipsDescendants = true -- Prevents children from overflowing corners

    -- Add a UI Gradient for a subtle background look (Optional but nice)
    local FrameGradient = Instance.new("UIGradient")
    FrameGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 37, 56)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 23, 42))
    }
    FrameGradient.Parent = MainFrame

    -- Configure Title Label
    Title.Name = "Title"
    Title.Parent = MainFrame
    Title.BackgroundColor3 = Color3.fromRGB(30, 41, 59) -- Slightly Lighter Dark Blue/Gray
    Title.BackgroundTransparency = 0 -- Opaque background
    Title.BorderSizePixel = 0
    Title.Size = UDim2.new(1, 0, 0, 30) -- Full width of parent frame, 30px height
    Title.Position = UDim2.new(0,0,0,0) -- Position at the top
    Title.Font = Enum.Font.GothamSemibold
    Title.Text = "Script Key System"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text
    Title.TextSize = 16.000
    Title.TextWrapped = true
    Title.TextXAlignment = Enum.TextXAlignment.Center -- Center text horizontally
    Title.TextYAlignment = Enum.TextYAlignment.Center -- Center text vertically

    -- Add a UI Corner for the title background (applies to the bottom edge relative to Title position)
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = Title -- Applies corner to the bottom edge implicitly

    -- Configure Distributor Label
    local displayDistributorId = (DISTRIBUTOR_ID == "" or DISTRIBUTOR_ID == "DISTRIBUTOR_ID_HERE") and "default" or DISTRIBUTOR_ID
    DistributorLabel.Name = "DistributorLabel"
    DistributorLabel.Parent = MainFrame
    DistributorLabel.BackgroundTransparency = 1 -- Fully transparent background
    DistributorLabel.Position = UDim2.new(0.5, 0, 0, 35) -- Position 35px down from top (below Title), centered horizontally
    DistributorLabel.AnchorPoint = Vector2.new(0.5, 0) -- Anchor center-top
    DistributorLabel.Size = UDim2.new(1, -40, 0, 20) -- Full width minus padding, 20px height
    DistributorLabel.Font = Enum.Font.Gotham -- Consistent font
    DistributorLabel.Text = "Distributor: " .. displayDistributorId
    DistributorLabel.TextColor3 = Color3.fromRGB(180, 180, 255) -- Muted Purple/Blue text
    DistributorLabel.TextSize = 10.000
    DistributorLabel.TextXAlignment = Enum.TextXAlignment.Center
    DistributorLabel.TextYAlignment = Enum.TextYAlignment.Center

    -- Configure Key Input TextBox
    KeyInput.Name = "KeyInput"
    KeyInput.Parent = MainFrame
    KeyInput.BackgroundColor3 = Color3.fromRGB(51, 65, 85) -- Slightly Lighter Dark Blue/Gray
    KeyInput.BackgroundTransparency = 0.2 -- Semi-transparent
    KeyInput.BorderColor3 = Color3.fromRGB(60, 80, 110)
    KeyInput.BorderSizePixel = 1
    KeyInput.Position = UDim2.new(0.5, 0, 0, 65) -- Position below DistributorLabel, centered horizontally
    KeyInput.AnchorPoint = Vector2.new(0.5, 0) -- Anchor center-top
    KeyInput.Size = UDim2.new(0, 250, 0, 30) -- 250px width, 30px height
    KeyInput.Font = Enum.Font.SourceSans -- Clearer font for input
    KeyInput.PlaceholderText = "Enter your key here..."
    KeyInput.PlaceholderColor3 = Color3.fromRGB(150, 160, 170) -- Gray placeholder text
    KeyInput.Text = ""
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text
    KeyInput.TextSize = 14.000
    KeyInput.ClearTextOnFocus = false -- Don't clear text when focused
    KeyInput.CornerRadius = UDim.new(0, 6) -- Rounded corners for input
    KeyInput.TextXAlignment = Enum.TextXAlignment.Center -- Center input text
    KeyInput.TextYAlignment = Enum.TextYAlignment.Center

    -- Configure Submit Button
    SubmitButton.Name = "SubmitButton"
    SubmitButton.Parent = MainFrame
    SubmitButton.BackgroundColor3 = Color3.fromRGB(34, 197, 94) -- Green
    SubmitButton.BackgroundTransparency = 0 -- Opaque
    SubmitButton.BorderColor3 = Color3.fromRGB(25, 150, 70)
    SubmitButton.BorderSizePixel = 1
    SubmitButton.Position = UDim2.new(0.5, 0, 0, 110) -- Position below KeyInput, centered
    SubmitButton.AnchorPoint = Vector2.new(0.5, 0) -- Anchor center-top
    SubmitButton.Size = UDim2.new(0, 120, 0, 30) -- 120px width, 30px height
    SubmitButton.Font = Enum.Font.GothamSemibold
    SubmitButton.Text = "Submit Key"
    SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text
    SubmitButton.TextSize = 14.000
    SubmitButton.CornerRadius = UDim.new(0, 6) -- Rounded corners
    SubmitButton.TextXAlignment = Enum.TextXAlignment.Center
    SubmitButton.TextYAlignment = Enum.TextYAlignment.Center

    -- Configure Get Key Button
    GetKeyButton.Name = "GetKeyButton"
    GetKeyButton.Parent = MainFrame
    GetKeyButton.BackgroundColor3 = Color3.fromRGB(51, 65, 85) -- Dark Blue/Gray (matches input)
    GetKeyButton.BackgroundTransparency = 0 -- Opaque
    GetKeyButton.BorderColor3 = Color3.fromRGB(60, 80, 110)
    GetKeyButton.BorderSizePixel = 1
    GetKeyButton.Position = UDim2.new(0.5, 0, 0, 150) -- Position below SubmitButton, centered
    GetKeyButton.AnchorPoint = Vector2.new(0.5, 0) -- Anchor center-top
    GetKeyButton.Size = UDim2.new(0, 120, 0, 30) -- 120px width, 30px height
    GetKeyButton.Font = Enum.Font.GothamSemibold
    GetKeyButton.Text = "Get Key"
    GetKeyButton.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text
    GetKeyButton.TextSize = 14.000
    GetKeyButton.CornerRadius = UDim.new(0, 6) -- Rounded corners
    GetKeyButton.TextXAlignment = Enum.TextXAlignment.Center
    GetKeyButton.TextYAlignment = Enum.TextYAlignment.Center


    -- Configure Status Label
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Parent = MainFrame
    StatusLabel.BackgroundTransparency = 1 -- Fully transparent
    StatusLabel.Position = UDim2.new(0.5, 0, 0, 190) -- Position near bottom, centered
    StatusLabel.AnchorPoint = Vector2.new(0.5, 0) -- Anchor center-top
    StatusLabel.Size = UDim2.new(1, -40, 0, 20) -- Full width minus margins, 20px height
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Text = "" -- Starts empty
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text (will change based on status)
    StatusLabel.TextSize = 12.000
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
    StatusLabel.TextYAlignment = Enum.TextYAlignment.Center
    StatusLabel.TextWrapped = true -- Allows text to wrap if too long


    return {
        ScreenGui = ScreenGui,
        KeyInput = KeyInput,
        SubmitButton = SubmitButton,
        GetKeyButton = GetKeyButton,
        StatusLabel = StatusLabel,
        MainFrame = MainFrame -- Return the frame for dragging
    }
end

-- Verify key with server
local function verifyKey(key)
    -- Base verification URL with your actual domain
    local url = VERIFICATION_BASE_URL

    -- Add distributor parameter: Use "default" if DISTRIBUTOR_ID is empty or placeholder
    -- The server expects 'default' if no specific ID is used
    local actualDistributorId = (DISTRIBUTOR_ID == "" or DISTRIBUTOR_ID == "DISTRIBUTOR_ID_HERE") and "default" or DISTRIBUTOR_ID
    url = url .. "&distributor=" .. HttpService:UrlEncode(actualDistributorId) -- URL encode distributor ID

    -- Add key parameter
    url = url .. "&key=" .. HttpService:UrlEncode(key) -- URL encode the key

    -- Print the URL and raw response for debugging (remove or comment out in production)
    -- print("[DEBUG] Verification URL: " .. url)
    local success, response = pcall(function()
        -- Use HttpService to make requests
        return HttpService:GetAsync(url)
    end)

    if success then
        -- print("[DEBUG] Raw Response: '" .. tostring(response) .. "'")
    else
        warn("[DEBUG] HTTP Error: " .. tostring(response))
        return false, "http_error" -- Indicate a network/HTTP error
    end

    if success and type(response) == "string" then
        -- Trim whitespace from the response
        response = string.gsub(response, "^%s*(.-)%s*$", "%1")
        -- print("[DEBUG] Trimmed Response: '" .. response .. "'") -- Debug trimmed response

        if response == "valid" then
            return true, "valid"
        elseif response == "expired" then
            return false, "expired"
        elseif response == "used" then
            return false, "used"
        elseif response == "invalid" then
            return false, "invalid"
        else
             -- Handle unexpected responses
             warn("[DEBUG] Unexpected response from server: '" .. response .. "'")
             return false, "invalid_response" -- Or just 'invalid'? invalid_response is more specific.
        end
    else
         warn("[DEBUG] verifyKey failed or received non-string response.")
        return false, "error" -- General error
    end
end

-- Run the script after key verification
local function runMainScript()
    -- Hide the UI
    local uiGui = CoreGui:FindFirstChild("KeySystemUI")
    if uiGui then
        uiGui:Destroy()
    end
    print("Key verified. Running main script...")

    -- Your actual script URL here
    -- Using true as the second argument to game:HttpGet bypasses the cache, useful during development
    -- but might increase load times slightly in production. Consider removing true if script doesn't update often.
    local mainScriptUrl = "https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua" -- <-- REPLACE THIS

    local success, err = pcall(function()
        local scriptContent = game:HttpGet(mainScriptUrl, true) -- Fetch the script content
        if scriptContent and type(scriptContent) == "string" and string.len(scriptContent) > 100 then -- Basic check if content was retrieved (more than 100 chars)
            -- Load and execute the script content
            local loadedScript, loadError = loadstring(scriptContent)
            if loadedScript then
                loadedScript() -- Execute the loaded function
            else
                warn("Failed to load script string: " .. tostring(loadError))
                 error("Script execution failed: Cannot load string.") -- Throw a Lua error
            end
        else
            warn("Failed to download or empty script content from " .. mainScriptUrl .. ". Received: '" .. tostring(scriptContent) .. "'")
             error("Script download failed or content too short.") -- Throw a Lua error
        end
    end)

    if not success then
        warn("Error executing main script pcall: " .. tostring(err))
        local ui = createKeyUI() -- Re-show UI on script execution failure
        ui.StatusLabel.Text = "Error executing script: " .. tostring(err)
        ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        ui.SubmitButton.Active = true -- Make buttons visible again
        ui.GetKeyButton.Active = true
         -- Optional: Set KeyInput text back if needed
         -- ui.KeyInput.Text = ""
    end
end

-- Add draggable functionality to the frame
local function makeDraggable(frame)
    local dragging = false
    local dragStartPosition
    local startPosition

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStartPosition = input.Position
            startPosition = frame.Position
             -- Consume input changes while dragging to prevent camera movement etc.
             -- Note: this might consume other inputs too depending on context
             input.Changed:Connect(function()
                 if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                 end
             end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            local delta = input.Position - dragStartPosition
            -- Update position relative to the initial startPosition
            frame.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
        end
    end)

    frame.InputEnded:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            dragging = false
        end
    end)
end


-- Initialize key system and UI
local function initKeySystem()
    local ui = createKeyUI()
    makeDraggable(ui.MainFrame) -- Make the main frame draggable

    -- Handle Get Key button
    ui.GetKeyButton.MouseButton1Click:Connect(function()
        -- Website URL to get key
        local keyWebsite = KEY_WEBSITE_BASE_URL

        -- Add distributor parameter only if DISTRIBUTOR_ID is set and not empty/placeholder
        local actualDistributorId = (DISTRIBUTOR_ID == "" or DISTRIBUTOR_ID == "DISTRIBUTOR_ID_HERE") and "default" or DISTRIBUTOR_ID

        -- Append distributor parameter to the URL
        -- Ensure it's URL encoded
        keyWebsite = keyWebsite .. "?distributor=" .. HttpService:UrlEncode(actualDistributorId)


        -- Copy URL to clipboard - Requires exploit context/functionality
        if setclipboard then
            pcall(function() -- Use pcall as setclipboard might error in some contexts
                setclipboard(keyWebsite)
                ui.StatusLabel.Text = "Key website URL copied to clipboard! Paste in your browser."
                ui.StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0) -- Green
            end)
        else
             ui.StatusLabel.Text = "Copying not supported. Go to this URL manually: " .. keyWebsite
             ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0) -- Yellow
        end
    end)

    -- Handle Submit button
    ui.SubmitButton.MouseButton1Click:Connect(function()
        local key = ui.KeyInput.Text

        if key == "" then
            ui.StatusLabel.Text = "Please enter a key!"
            ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0) -- Red
            return
        end

        -- Disable buttons while verifying
        ui.SubmitButton.Active = false
        ui.GetKeyButton.Active = false
        ui.StatusLabel.Text = "Verifying key..."
        ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0) -- Yellow

        -- Use task.spawn for non-blocking verification
        task.spawn(function()
            local isValid, status = verifyKey(key)

            -- Re-enable buttons after verification attempt
             ui.SubmitButton.Active = true
             ui.GetKeyButton.Active = true

            if isValid then
                ui.StatusLabel.Text = "Key verified successfully!"
                ui.StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0) -- Green

                task.delay(1, function() -- Small delay before hiding UI and running script
                    runMainScript()
                end)
            else
                -- Display specific error messages based on status
                local expirationText = "<?php echo intval($expiration_hours); ?> hours."
                if status == "expired" then
                    ui.StatusLabel.Text = "This key has expired! Keys expire after " .. expirationText
                    ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                elseif status == "used" then
                    ui.StatusLabel.Text = "This key has already been used!"
                    ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                elseif status == "invalid" then
                    ui.StatusLabel.Text = "Invalid key! Please try again."
                    ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                elseif status == "http_error" then
                     ui.StatusLabel.Text = "Network error during verification. Try again."
                     ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                elseif status == "invalid_response" then
                      ui.StatusLabel.Text = "Server returned an unexpected response."
                      ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                else -- Catch any other status or generic error
                     ui.StatusLabel.Text = "Verification failed! Check key and try again."
                     ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                end
                 -- Clear the input field on verification failure
                 ui.KeyInput.Text = ""
            end
        end) -- End task.spawn
    end)

    return ui
end

-- Start the key system when the script runs
initKeySystem()
