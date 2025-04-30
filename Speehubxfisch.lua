-- Key System Script for Roblox (Distributor Version)
-- Developed for https://wordpress-1442530-5468918.cloudwaysapps.com/


-- !!! IMPORTANT !!!
-- REPLACE 'YOUR_DISTRIBUTOR_ID' with the unique ID assigned to this distributor
-- You can find this ID on your WordPress Key System -> Distributors page.
local distributorId = '5E8E53' -- <-- REPLACE THIS

-- REPLACE the URL in scriptSourceUrl with the ACTUAL URL of your script source.
-- Example: local scriptSourceUrl = "https://pastebin.com/raw/abcdefgh"
local scriptSourceUrl = "https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua" -- <-- REPLACE THIS

-- !!! IMPORTANT !!!


-- Base URL for your key system website
local websiteUrl = "https://wordpress-1442530-5469162.cloudwaysapps.com/"

-- Verification Endpoint URL
local verificationUrl = websiteUrl .. "/?verify=1"

-- Get Key Button URL (appends distributorId automatically)
local getKeyUrl = websiteUrl .. "/?dist_id=" .. distributorId

-- Key Expiration displayed in UI (informative) - This is fetched from your WP settings
local keyExpirationHours = 24 -- Default, replace with the actual value from your WP settings or fetch dynamically if preferred


-- Create the key verification UI
local function createKeyUI()
    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local DistributorLabel = Instance.new("TextLabel") -- Added label for distributor ID
    local KeyInput = Instance.new("TextBox")
    local SubmitButton = Instance.new("TextButton")
    local GetKeyButton = Instance.new("TextButton")
    local StatusLabel = Instance.new("TextLabel")

    -- Basic UI Setup (You can enhance this)
    ScreenGui.Name = "DistributorKeySystemUI"
    ScreenGui.Parent = game:GetService("CoreGui") -- Use CoreGui to appear above other UI
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    MainFrame.BorderSizePixel = 1
    MainFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -115)
    MainFrame.Size = UDim2.new(0, 300, 0, 230)
    MainFrame.Draggable = true -- Make it draggable

    Title.Name = "Title"
    Title.Parent = MainFrame
    Title.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Title.BorderSizePixel = 0
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Font = Enum.Font.GothamSemibold
    Title.Text = "Script Key System"
    Title.TextColor3 = Color3.fromRGB(200, 200, 200)
    Title.TextSize = 16.000
    Title.TextWrapped = true
    Title.TextXAlignment = Enum.TextXAlignment.Center

    DistributorLabel.Name = "DistributorLabel"
    DistributorLabel.Parent = MainFrame
    DistributorLabel.BackgroundTransparency = 1
    DistributorLabel.Position = UDim2.new(0, 0, 0.15, 0)
    DistributorLabel.Size = UDim2.new(1, 0, 0, 20)
    DistributorLabel.Font = Enum.Font.Gotham
    DistributorLabel.Text = "Dist ID: " .. distributorId
    DistributorLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
    DistributorLabel.TextSize = 10.000 -- Slightly smaller
    DistributorLabel.TextXAlignment = Enum.TextXAlignment.Center
    DistributorLabel.TextWrapped = true


    KeyInput.Name = "KeyInput"
    KeyInput.Parent = MainFrame
    KeyInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    KeyInput.BorderSizePixel = 1
    KeyInput.BorderColor3 = Color3.fromRGB(80, 80, 80)
    KeyInput.Position = UDim2.new(0.5, -125, 0.3, 15)
    KeyInput.Size = UDim2.new(0, 250, 0, 30)
    KeyInput.Font = Enum.Font.SourceSans
    KeyInput.PlaceholderText = "Enter your key here..."
    KeyInput.Text = ""
    KeyInput.TextColor3 = Color3.fromRGB(240, 240, 240)
    KeyInput.TextSize = 14.000
    KeyInput.ClearTextOnFocus = false
    KeyInput.TextXAlignment = Enum.TextXAlignment.Left
    KeyInput.TextYAlignment = Enum.TextYAlignment.Center
    KeyInput.Padding = UDim.new(0, 5) -- Add some padding


    SubmitButton.Name = "SubmitButton"
    SubmitButton.Parent = MainFrame
    SubmitButton.BackgroundColor3 = Color3.fromRGB(34, 197, 94) -- Green
    SubmitButton.BorderSizePixel = 0
    SubmitButton.Position = UDim2.new(0.5, -60, 0.55, 15)
    SubmitButton.Size = UDim2.new(0, 120, 0, 30)
    SubmitButton.Font = Enum.Font.GothamSemibold
    SubmitButton.Text = "Submit Key"
    SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubmitButton.TextSize = 14.000
    SubmitButton.AutoButtonColor = true


    GetKeyButton.Name = "GetKeyButton"
    GetKeyButton.Parent = MainFrame
    GetKeyButton.BackgroundColor3 = Color3.fromRGB(51, 65, 85) -- Blueish gray
    GetKeyButton.BorderSizePixel = 0
    GetKeyButton.Position = UDim2.new(0.5, -60, 0.75, 15)
    GetKeyButton.Size = UDim2.new(0, 120, 0, 30)
    GetKeyButton.Font = Enum.Font.GothamSemibold
    GetKeyButton.Text = "Get Key"
    GetKeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    GetKeyButton.TextSize = 14.000
    GetKeyButton.AutoButtonColor = true


    StatusLabel.Name = "StatusLabel"
    StatusLabel.Parent = MainFrame
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0, 0, 0.9, 15)
    StatusLabel.Size = UDim2.new(1, 0, 0, 20)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Text = ""
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- Default white
    StatusLabel.TextSize = 12.000
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
    StatusLabel.TextWrapped = true


    return {
        ScreenGui = ScreenGui,
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
    -- !!! IMPORTANT !!!
    -- REPLACE this URL with the ACTUAL URL of your script source for THIS distributor
    -- Example: local scriptSourceUrl = "https://pastebin.com/raw/abcdefgh"
    local scriptSourceUrl = "https://raw.githubusercontent.com/AhmadV99/Speed-Hub-X/main/Speed%20Hub%20X.lua" -- <-- REPLACE THIS

    -- Add a check to ensure the script source URL is valid and not the placeholder
    if not scriptSourceUrl or scriptSourceUrl == "YOUR_SCRIPT_SOURCE_URL" or string.find(scriptSourceUrl, "YOUR_SCRIPT_SOURCE_URL") then
         warn("Main script source URL is not set correctly!")
         -- Optionally display an error message in Roblox UI (requires modifying UI after it's destroyed)
         return -- Don't attempt to execute
    end


    local success, err = pcall(function()
         -- Execute the main script code
        local mainScript = game:HttpGet(scriptSourceUrl) -- No timeout here, relying on game engine defaults
        if mainScript and mainScript:len() > 0 then
            -- Attempt to load and execute the script
             local success_exec, err_exec = pcall(function()
                 loadstring(mainScript)()
             end)
             if not success_exec then
                 warn("Error executing main script:", err_exec)
                 -- Optionally display error in UI if needed
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
    -- Check if distributorId is set before creating UI
    local trimmedDistributorId = distributorId:gsub("%s+", "")
    if not trimmedDistributorId or trimmedDistributorId == 'YOUR_DISTRIBUTOR_ID' then
        warn("Distributor ID is not set or is placeholder in the script!")
        -- Create a minimal UI just to show an error message
        local ErrorGui = Instance.new("ScreenGui")
        ErrorGui.Name = "KeySystemErrorUI"
        ErrorGui.Parent = game:GetService("CoreGui")
        local ErrorFrame = Instance.new("Frame") -- Use a frame for better centering/styling
        ErrorFrame.Size = UDim2.new(0, 300, 0, 80)
        ErrorFrame.Position = UDim2.new(0.5, -150, 0.5, -40)
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
        ErrorTitle.Text = "Key System Error"
        ErrorTitle.Font = Enum.Font.GothamSemibold
        ErrorTitle.TextXAlignment = Enum.TextXAlignment.Center
        ErrorTitle.Parent = ErrorFrame

        local ErrorMessage = Instance.new("TextLabel")
        ErrorMessage.Size = UDim2.new(1, -10, 0, 40) -- Smaller height, subtract padding
        ErrorMessage.Position = UDim2.new(0, 5, 0, 30) -- Position below title, add padding
        ErrorMessage.BackgroundTransparency = 1
        ErrorMessage.TextColor3 = Color3.fromRGB(255, 50, 50) -- Red
        ErrorMessage.TextSize = 12
        ErrorMessage.Text = "Distributor ID not set in script.\nPlease contact script provider."
        ErrorMessage.Font = Enum.Font.Gotham
        ErrorMessage.TextXAlignment = Enum.TextXAlignment.Center
        ErrorMessage.TextYAlignment = Enum.TextYAlignment.Center
        ErrorMessage.TextWrapped = true
        ErrorMessage.Parent = ErrorFrame
        return -- Stop initialization
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
         ui.KeyInput.Text = "" -- Clear input while verifying


        -- Add a small delay to show the verifying status
        task.delay(1.0, function() -- Reduced delay slightly
            local isValid, status = verifyKey(key, distributorId) -- Pass distributorId to verification

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
                 -- Make sure input is selectable again after failed attempt, restore key if needed? Or just clear.
                 -- ui.KeyInput.Text = key -- Option to restore key
                 ui.KeyInput:CaptureFocus() -- Keep focus on input field
            end
        end)
    end)

    return ui
end

-- Start the key system UI only if distributorId is properly set in the script
-- Moved the check outside initKeySystem to prevent creating UI if ID is not set
-- Added a check for empty string after trimming whitespace
local trimmedDistributorId = distributorId:gsub("%s+", "")
if trimmedDistributorId and trimmedDistributorId ~= 'YOUR_DISTRIBUTOR_ID' then
     initKeySystem()
else
     warn("Distributor ID is not set or is placeholder in the script!")
     -- Create a minimal UI just to show an error message
     local ErrorGui = Instance.new("ScreenGui")
     ErrorGui.Name = "KeySystemErrorUI"
     ErrorGui.Parent = game:GetService("CoreGui")
     local ErrorFrame = Instance.new("Frame") -- Use a frame for better centering/styling
     ErrorFrame.Size = UDim2.new(0, 300, 0, 80)
     ErrorFrame.Position = UDim2.new(0.5, -150, 0.5, -40)
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
     ErrorTitle.Text = "Key System Error"
     ErrorTitle.Font = Enum.Font.GothamSemibold
     ErrorTitle.TextXAlignment = Enum.TextXAlignment.Center
     ErrorTitle.Parent = ErrorFrame

     local ErrorMessage = Instance.new("TextLabel")
     ErrorMessage.Size = UDim2.new(1, -10, 0, 40) -- Smaller height, subtract padding
     ErrorMessage.Position = UDim2.new(0, 5, 0, 30) -- Position below title, add padding
     ErrorMessage.BackgroundTransparency = 1
     ErrorMessage.TextColor3 = Color3.fromRGB(255, 50, 50) -- Red
     ErrorMessage.TextSize = 12
     ErrorMessage.Text = "Distributor ID not set in script.\nPlease contact script provider."
     ErrorMessage.Font = Enum.Font.Gotham
     ErrorMessage.TextXAlignment = Enum.TextXAlignment.Center
     ErrorMessage.TextYAlignment = Enum.TextYAlignment.Center
     ErrorMessage.TextWrapped = true
     ErrorMessage.Parent = ErrorFrame
end
