-- DevAdminServer (ServerScriptService)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- List of authorized UserIds (Add your Roblox UserId here)
local AUTHORIZED_ADMINS = {
    [game.CreatorId] = true, -- Automatically authorizes the place creator/owner
    -- [123456789] = true,  -- Add additional developer user IDs if needed
}

-- Create or reference RemoteEvent for Developer Actions
local devRemote = ReplicatedStorage:FindFirstChild("DevAdminRemote")
if not devRemote then
    devRemote = Instance.new("RemoteEvent")
    devRemote.Name = "DevAdminRemote"
    devRemote.Parent = ReplicatedStorage
end

-- Verify admin permissions
local function isAdmin(player)
    return AUTHORIZED_ADMINS[player.UserId] == true or player.UserId == game.CreatorId
end

devRemote.OnServerEvent:Connect(function(player, action, payload)
    if not isAdmin(player) then
        warn(player.Name .. " attempted unauthorized Dev Admin execution.")
        return
    end

    local leaderstats = player:FindFirstChild("leaderstats")

    if action == "AddSpeed" then
        local amount = tonumber(payload) or 10000
        local speedStat = leaderstats and leaderstats:FindFirstChild("Speed")
        if speedStat then
            speedStat.Value = speedStat.Value + amount
        end
        -- Also update character walkspeed if tied to humanoid
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = math.clamp(char.Humanoid.WalkSpeed + (amount / 100), 16, 500)
        end

    elseif action == "AddWins" then
        local amount = tonumber(payload) or 1000
        local winsStat = leaderstats and leaderstats:FindFirstChild("Wins")
        if winsStat then
            winsStat.Value = winsStat.Value + amount
        end

    elseif action == "AddRebirths" then
        local amount = tonumber(payload) or 1
        local rebirthStat = leaderstats and leaderstats:FindFirstChild("Rebirths")
        if rebirthStat then
            rebirthStat.Value = rebirthStat.Value + amount
        end

    elseif action == "UnlockAllWorlds" then
        -- Set world access flags or attributes
        player:SetAttribute("MaxWorldUnlocked", 99)
        player:SetAttribute("VIPUnlocked", true)
        print("[DevAdmin] Unlocked all worlds for " .. player.Name)

    elseif action == "UnlockAllSuits" then
        -- Trigger inventory unlocking logic or attributes
        player:SetAttribute("AllSuitsUnlocked", true)
        print("[DevAdmin] Unlocked all suits for " .. player.Name)

    elseif action == "TeleportToEnd" then
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local finishLine = workspace:FindFirstChild("FinishLine") or workspace:FindFirstChild("WinZone")
        if root and finishLine then
            root.CFrame = finishLine.CFrame + Vector3.new(0, 5, 0)
        end
    end
end)
