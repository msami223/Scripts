-- Key System Script for Roblox with Distributor Support
-- This script uses your WordPress Key System plugin for key generation and verification.

-- =============================================================================
--                          !!! IMPORTANT !!!
--           REPLACE THE PLACEHOLDERS BELOW FOR EACH DISTRIBUTOR
-- =============================================================================

-- 1. REPLACE "YOUR_WEBSITE_URL_HERE" with the base URL of your WordPress site.
--    Example: "https://wordpress-1442530-5468918.cloudwaysapps.com"
local WEBSITE_BASE_URL = "https://wordpress-1442530-5469162.cloudwaysapps.com/" -- <-- REPLACE THIS

-- 2. REPLACE "YOUR_DISTRIBUTOR_ID_HERE" with the unique ID assigned to this distributor.
--    You can find this ID on your WordPress Key System -> Distributors page.
--    Example: "5E8E53"
local DISTRIBUTOR_ID = "5E8E53" -- <-- REPLACE THIS

-- 3. REPLACE "YOUR_MAIN_SCRIPT_URL_HERE" with the ACTUAL URL of your main script source.
--    This is the script that will be executed after successful key verification.
--    Example: "https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua"
local MAIN_SCRIPT_SOURCE_URL = "https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua" -- <-- REPLACE THIS

-- =============================================================================
--                          DO NOT EDIT BELOW THIS LINE
-- =============================================================================

-- Construct full URLs using the base URL
local verificationUrl = WEBSITE_BASE_URL .. "/?verify=1"
local getKeyUrl = WEBSITE_BASE_URL .. "/?dist_id=" .. DISTRIBUTOR_ID

-- Key Expiration displayed in UI (informative) - Defaults to 24 hours.
-- The actual expiration is determined by your WordPress settings.
local keyExpirationHours = 24 -- Can update manually to match WP settings if needed

-- Check if placeholders are still present before proceeding
local function checkPlaceholders()
    if WEBSITE_BASE_URL == "YOUR_WEBSITE_URL_HERE" or DISTRIBUTOR_ID == "YOUR_DISTRIBUTOR_ID_HERE" or MAIN_SCRIPT_SOURCE_URL == "YOUR_MAIN_SCRIPT_URL_HERE" then
        warn("Key System Error: Placeholders are not replaced in the script!")
        -- Create a minimal error UI
        local ErrorGui = Instance.new("ScreenGui")
        ErrorGui.Name = "KeySystemErrorUI"
        ErrorGui.Parent = game:GetService("CoreGui")
        local ErrorFrame = Instance.new("Frame")
        ErrorFrame.Size = UDim2.new(0, 300, 0, 100)
        ErrorFrame.Position = UDim2.new(0.5, -150, 0.5, -50)
        ErrorFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        ErrorFrame.BorderSizePixel = 1
        ErrorFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
        ErrorFrame.Parent = ErrorGui
        ErrorFrame.Draggable = true

        local ErrorTitle = Instance.new("TextLabel")
        ErrorTitle.Size = UDim2.new(1, 0, 0, 30)
        ErrorTitle.Position = UDim2.new(0, 0, 0, 0)
        ErrorTitle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        ErrorTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
        ErrorTitle.TextSize = 16
        ErrorTitle.Text = "Script Configuration Error"
        ErrorTitle.Font = Enum.Font.GothamSemibold
        ErrorTitle.TextXAlignment = Enum.TextXAlignment.Center
        ErrorTitle.Parent = ErrorFrame

        local ErrorMessage = Instance.new("TextLabel")
        ErrorMessage.Size = UDim2.new(1, -10, 0, 50)
        ErrorMessage.Position = UDim2.new(0, 5, 0, 30)
        ErrorMessage.BackgroundTransparency = 1
        ErrorMessage.TextColor3 = Color3.fromRGB(255, 50, 50) -- Red
        ErrorMessage.TextSize = 12
        ErrorMessage.Text = "Script is not configured.\nPlease replace placeholders at the top."
        ErrorMessage.Font = Enum.Font.Gotham
        ErrorMessage.TextXAlignment = Enum.TextXAlignment.Center
        ErrorMessage.TextYAlignment = Enum.TextYAlignment.Center
        ErrorMessage.TextWrapped = true
        ErrorMessage.Parent = ErrorFrame
        return false -- Indicate failure
    end
    return true -- Indicate success
end


-- Create the key verification UI
local function createKeyUI()
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
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Configure MainFrame
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
    MainFrame.Size = UDim2.new(0, 300, 0, 220) -- Adjusted size for new label

    -- Configure Title
    Title.Name = "Title"
    Title.Parent = MainFrame
    Title.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
    Title.BorderSizePixel = 0
    Title.Position = UDim2.new(0, 0, 0, 0) -- Position at top
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Font = Enum.Font.GothamSemibold
    Title.Text = "Script Key System"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16.000
    Title.TextWrapped = true
    Title.TextXAlignment = Enum.TextXAlignment.Center -- Center the title

    -- Configure Distributor Label (always create it, parent only if ID is set)
    DistributorLabel.Name = "DistributorLabel"
    DistributorLabel.BackgroundTransparency = 1
    DistributorLabel.Position = UDim2.new(0, 0, 0.15, 0) -- Position below title
    DistributorLabel.Size = UDim2.new(1, 0, 0, 20)
    DistributorLabel.Font = Enum.Font.Gotham
    DistributorLabel.Text = "Distributor: " .. DISTRIBUTOR_ID -- Display distributor ID
    DistributorLabel.TextColor3 = Color3.fromRGB(180, 180, 255)
    DistributorLabel.TextSize = 10.000
    DistributorLabel.TextXAlignment = Enum.TextXAlignment.Center -- Center the ID
     -- Parent only if DISTRIBUTOR_ID is actually set
    if DISTRIBUTOR_ID and DISTRIBUTOR_ID ~= "YOUR_DISTRIBUTOR_ID_HERE" then
         DistributorLabel.Parent = MainFrame
    end


    -- Configure KeyInput
    KeyInput.Name = "KeyInput"
    KeyInput.Parent = MainFrame
    KeyInput.BackgroundColor3 = Color3.fromRGB(51, 65, 85)
    KeyInput.BorderSizePixel = 0
    KeyInput.Position = UDim2.new(0.5, -125, 0.35, 0) -- Adjusted position
    KeyInput.Size = UDim2.new(0, 250, 0, 30)
    KeyInput.Font = Enum.Font.Gotham
    KeyInput.PlaceholderText = "Enter your key here..."
    KeyInput.Text = ""
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInput.TextSize = 14.000
    KeyInput.ClearTextOnFocus = false -- Keep text when focused
    KeyInput.TextXAlignment = Enum.TextXAlignment.Left -- Align text to the left
    KeyInput.TextYAlignment = Enum.TextYAlignment.Center -- Vertically center text
    KeyInput.Padding = UDim.new(0, 5) -- Add some padding


    -- Configure SubmitButton
    SubmitButton.Name = "SubmitButton"
    SubmitButton.Parent = MainFrame
    SubmitButton.BackgroundColor3 = Color3.fromRGB(34, 197, 94) -- Green
    SubmitButton.BorderSizePixel = 0
    SubmitButton.Position = UDim2.new(0.5, -60, 0.55, 0) -- Position below input
    SubmitButton.Size = UDim2.new(0, 120, 0, 30)
    SubmitButton.Font = Enum.Font.GothamSemibold
    SubmitButton.Text = "Submit Key"
    SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubmitButton.TextSize = 14.000
    SubmitButton.AutoButtonColor = true


    -- Configure GetKeyButton
    GetKeyButton.Name = "GetKeyButton"
    GetKeyButton.Parent = MainFrame
    GetKeyButton.BackgroundColor3 = Color3.fromRGB(51, 65, 85) -- Blueish gray
    GetKeyButton.BorderSizePixel = 0
    GetKeyButton.Position = UDim2.new(0.5, -60, 0.75, 0) -- Position below Submit
    GetKeyButton.Size = UDim2.new(0, 120, 0, 30)
    GetKeyButton.Font = Enum.Font.GothamSemibold
    GetKeyButton.Text = "Get Key"
    GetKeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    GetKeyButton.TextSize = 14.000
    GetKeyButton.AutoButtonColor = true


    -- Configure StatusLabel
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Parent = MainFrame
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0, 0, 0.9, 0) -- Position at bottom
    StatusLabel.Size = UDim2.new(1, 0, 0, 20)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Text = ""
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- Default white
    StatusLabel.TextSize = 12.000
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Center -- Center the status text
    StatusLabel.TextWrapped = true -- Wrap long status messages


    return {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame, -- Returning MainFrame for potential external control
        Title = Title,
        DistributorLabel = DistributorLabel,
        KeyInput = KeyInput,
        SubmitButton = SubmitButton,
        GetKeyButton = GetKeyButton,
        StatusLabel = StatusLabel
    }
end

-- Verify key with server
local function verifyKey(key, distId)
    -- Append key and distributorId to the verification URL
    local fullVerificationUrl = verificationUrl .. "&key=" .. key .. "&dist_id=" .. distId

    local success, response = pcall(function()
        -- Using game:HttpGet is common in exploit contexts
        -- Add a short timeout just in case
        return game:HttpGet(fullVerificationUrl, true, {
            ["User-Agent"] = "Roblox/1.0 (KeySystem; Distributor)" -- Optional: Add a User-Agent
        }, 10) -- 10 second timeout
    end)

    if success then
        -- Trim whitespace from response
        response = response:gsub("^%s+", ""):gsub("%s+$", "")

        if response == "valid" then
            return true, "valid"
        elseif response == "expired" then
            return false, "expired"
        elseif response == "invalid" then -- Server now returns 'invalid' if key/dist_id mismatch or key doesn't exist
            return false, "invalid"
        -- The server side is NOT currently checking or returning 'used' during verification
        -- If you add 'used' check back on server, uncomment this:
        -- elseif response == "used" then
        --     return false, "used"
        elseif response == "error" then -- Server might return 'error' for missing tables etc.
            return false, "server_error"
        else
             -- Handle unexpected response
            warn("Unexpected response from server:", response)
            return false, "unexpected_response"
        end
    else
        -- Handle HTTP request failure (pcall returned false)
        warn("HTTP GET failed:", response) -- response might contain error message here
        return false, "network_error" -- Indicate network problem
    end
end

-- Run the script after key verification
local function runMainScript()
    -- The URL to the main script source is defined at the top of the file
    local scriptSourceUrl = MAIN_SCRIPT_SOURCE_URL

    -- Add a check to ensure the script source URL is valid and not the placeholder
    if not scriptSourceUrl or scriptSourceUrl == "YOUR_MAIN_SCRIPT_SOURCE_URL_HERE" or string.find(scriptSourceUrl, "YOUR_MAIN_SCRIPT_SOURCE_URL_HERE") then
         warn("Main script source URL is not set correctly!")
         -- Optionally display an error message in Roblox UI (requires creating UI after it's destroyed)
         return -- Don't attempt to execute
    end

    local success, err = pcall(function()
         -- Execute the main script code
         -- Note: Some script hubs return a table of game IDs and URLs.
         -- If your main script does this, you might need to adjust the loading logic here.
         -- The code below assumes the MAIN_SCRIPT_SOURCE_URL points directly to the Lua code to be executed.
        local mainScript = game:HttpGet(scriptSourceUrl)
        if mainScript and mainScript:len() > 0 then
            -- Attempt to load and execute the script
             local success_exec, err_exec = pcall(function()
                 loadstring(mainScript)()
             end)
             if not success_exec then
                 warn("Error executing main script:", err_exec)
                 -- Optionally display error in UI if needed (complex after UI destroyed)
             end
        else
            error("Failed to download main script or script is empty from " .. scriptSourceUrl)
        end
    end)

    if not success then
        warn("Error during main script loading/execution:", err)
        -- This pcall catches errors from game:HttpGet or the inner loadstring/execution
        -- Optionally display an error to the user
    end
end

-- Initialize key system and UI
local function initKeySystem()
    -- Check if mandatory placeholders are replaced first
    if not checkPlaceholders() then
        -- checkPlaceholders function already created the error UI
        return
    end

    local ui = createKeyUI()

    -- Handle Get Key button
    ui.GetKeyButton.MouseButton1Click:Connect(function()
        -- The getKeyUrl already includes the distributorId
        setclipboard(getKeyUrl)

        ui.StatusLabel.Text = "Key website URL copied! Paste in your browser."
        ui.StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0) -- Green
    end)

    -- Handle Submit button
    ui.SubmitButton.MouseButton1Click:Connect(function()
        local key = ui.KeyInput.Text:gsub("%s+", "") -- Trim whitespace from input

        if key == "" then
            ui.StatusLabel.Text = "Please enter a key!"
            ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0) -- Red
            ui.KeyInput:CaptureFocus() -- Keep focus on input
            return
        end

        ui.StatusLabel.Text = "Verifying key..."
        ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0) -- Yellow
        ui.KeyInput.Text = "" -- Clear input while verifying - Optional


        -- Add a small delay to show the verifying status
        task.delay(1.0, function() -- Reduced delay slightly
            local isValid, status = verifyKey(key, DISTRIBUTOR_ID) -- Pass distributorId to verification

            if isValid then
                ui.StatusLabel.Text = "Key verified successfully!"
                ui.StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0) -- Green

                -- Delay before closing UI and running script
                task.delay(1.0, function()
                    ui.ScreenGui:Destroy()
                    runMainScript() -- Run the main script logic
                end)
            else
                -- Update messages based on server response status
                if status == "expired" then
                    ui.StatusLabel.Text = "This key has expired! Keys expire after " .. keyExpirationHours .. " hours. Get a new key."
                    ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0) -- Red
                -- The server side is NOT currently checking or returning 'used' during verification
                -- If you add 'used' check back on server, uncomment this:
                -- elseif status == "used" then
                --     ui.StatusLabel.Text = "This key has already been used! Get a new key."
                --     ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0) -- Red
                elseif status == "network_error" then
                     ui.StatusLabel.Text = "Verification failed: Network error." -- Simplified message for user
                     ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 165, 0) -- Orange
                elseif status == "server_error" or status == "unexpected_response" then
                     ui.StatusLabel.Text = "Verification failed: Server error." -- Simplified message for user
                     ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 165, 0) -- Orange
                else -- This covers "invalid" and any other unknown status
                    ui.StatusLabel.Text = "Invalid key or Distributor ID mismatch! Get a new key."
                    ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0) -- Red
                end
                 ui.KeyInput:CaptureFocus() -- Keep focus on input field
            end
        end)
    end)

    return ui
end

-- Start the key system
initKeySystem()
