--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/turtle"))()

local OwO = library:Window("Steal a Brainrot")

local OwO1 = library:Window("Main2")

OwO:Button("Open New GUI", function()
loadstring(game:HttpGet("https://hackmanhub.pages.dev/loader.txt"))()
  end)

OwO:Button("NEW Auto Steal", function()
loadstring(game:HttpGet("https://pastebin.com/raw/2WEXn2UR"))()
end)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- Make sure this decal is present (from original script)
if not ReplicatedStorage:FindFirstChild("juisdfj0i32i0eidsuf0iok") then
    local detection = Instance.new("Decal")
    detection.Name = "juisdfj0i32i0eidsuf0iok"
    detection.Parent = ReplicatedStorage
end

local hiddenfling = false
local flingThread

local function fling()
    local c, hrp, vel, movel = nil, nil, nil, 0.1

    while hiddenfling do
        RunService.Heartbeat:Wait()
        c = lp.Character
        hrp = c and c:FindFirstChild("HumanoidRootPart")

        if hrp then
            vel = hrp.Velocity
            hrp.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
            RunService.RenderStepped:Wait()
            hrp.Velocity = vel
            RunService.Stepped:Wait()
            hrp.Velocity = vel + Vector3.new(0, movel, 0)
            movel = -movel
        end
    end
end

-- Hook into your OwO toggle system
OwO:Toggle("Fling/Kill", false, function(state)
    hiddenfling = state

    if hiddenfling then
        flingThread = coroutine.create(fling)
        coroutine.resume(flingThread)
    else
        hiddenfling = false
    end
end)


local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local toggleRunning = false
local maxDistance = 8 -- max distance in studs

OwO:Toggle("TP Use Touch Kill", false, function(state)
    toggleRunning = state

    if state then
        print("Toggle On")

        coroutine.wrap(function()
            while toggleRunning do
                local myChar = LocalPlayer.Character
                if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then
                    task.wait(1)
                    continue
                end
                local myHRP = myChar.HumanoidRootPart

                -- Find all players within range
                local nearbyPlayers = {}
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local targetHRP = player.Character.HumanoidRootPart
                        local dist = (targetHRP.Position - myHRP.Position).Magnitude
                        if dist <= maxDistance then
                            table.insert(nearbyPlayers, {player = player, distance = dist})
                        end
                    end
                end

                if #nearbyPlayers == 0 then
                    task.wait(1)
                    continue
                end

                -- Only one player nearby
                if #nearbyPlayers == 1 then
                    local singlePlayer = nearbyPlayers[1].player

                    while toggleRunning do
                        local targetChar = singlePlayer.Character
                        local targetHRP = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
                        local myChar = LocalPlayer.Character
                        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")

                        if not targetHRP or not myHRP then break end

                        local currentDist = (targetHRP.Position - myHRP.Position).Magnitude
                        if currentDist > maxDistance then
                            break -- out of range, don't teleport
                        end

                        -- Tween teleport
                        local targetPos = targetHRP.CFrame * CFrame.new(0, 0, -0.5)

                        for _, part in pairs(myChar:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end

                        local tweenInfo = TweenInfo.new(0.05, Enum.EasingStyle.Linear)
                        local tween = TweenService:Create(myHRP, tweenInfo, {CFrame = targetPos})
                        tween:Play()
                        tween.Completed:Wait()

                        task.wait(2)

                        for _, part in pairs(myChar:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = true
                            end
                        end
                    end
                else
                    -- More than one player nearby, find the nearest
                    local nearestPlayer = nil
                    local nearestDistance = math.huge
                    for _, entry in ipairs(nearbyPlayers) do
                        if entry.distance < nearestDistance then
                            nearestDistance = entry.distance
                            nearestPlayer = entry.player
                        end
                    end

                    if nearestPlayer and nearestPlayer.Character and nearestPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local targetHRP = nearestPlayer.Character.HumanoidRootPart
                        local currentDist = (targetHRP.Position - myHRP.Position).Magnitude

                        if currentDist <= maxDistance then
                            local targetPos = targetHRP.CFrame * CFrame.new(0, 0, -0.5)

                            for _, part in pairs(myChar:GetChildren()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = false
                                end
                            end

                            local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)
                            local tween = TweenService:Create(myHRP, tweenInfo, {CFrame = targetPos})
                            tween:Play()
                            tween.Completed:Wait()

                            task.wait(2)

                            for _, part in pairs(myChar:GetChildren()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = true
                                end
                            end
                        end
                    end
                end
            end
        end)()
    else
        print("Toggle Off")
    end
end)

OwO:Button("Auto Steal Tp Bases", function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Youifpg/Steal-a-Brainrot-op/refs/heads/main/Arbixhub-obfuscated.lua"))()
end)
OwO:Button("Open 2nd Hub", function()
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Services = setmetatable({}, { __index = function(_,k) return game:GetService(k) end })
local Players, RunService, Workspace = Services.Players, Services.RunService, Services.Workspace
local TweenService, UserInputService = Services.TweenService, Services.UserInputService
local LocalPlayer = Players.LocalPlayer
local PathfindingService = Services.PathfindingService
local Utility = {}
local Character, Humanoid
local enforceConnection, plotCon, autoResetCon, antiRagdollConn = nil, nil, nil, nil
local canRunHub = false
local lowGravityEnabled = false
local godmode = false
local infiniteJump = false
local isActive = false
local autoResetEnabled = false
local notified = false
local espPlayer = false
local espPlot = false
local function updateCharacterReferences()
	Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	Humanoid = Character:WaitForChild("Humanoid")
	Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		if godmode and Humanoid.Health < Humanoid.MaxHealth then
			Humanoid.Health = Humanoid.MaxHealth
		end
	end)
end
updateCharacterReferences()
local function startEnforceSpeed()
	if not Humanoid then return end
	enforceConnection = RunService.Heartbeat:Connect(function()
		if Humanoid.WalkSpeed ~= 44 then
			Humanoid.WalkSpeed = 44
		end
	end)
	Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		if isActive and Humanoid.WalkSpeed ~= 44 then
			Humanoid.WalkSpeed = 44
		end
	end)
end
local antiRagdollEnabled = false
function Utility.runAntiRagdoll()
    if not (Character and Humanoid) then return end
    local r = Character:FindFirstChild("HumanoidRootPart")
    if r then
        for _, x in ipairs(Character:GetDescendants()) do
            if x:IsA("BallSocketConstraint") or x:IsA("HingeConstraint") then
                Humanoid.PlatformStand = true
                r.Anchored = true
                task.delay(1, function()
                    if Humanoid then Humanoid.PlatformStand = false end
                    if Character and r then r.Anchored = false end
                end)
                break
            end
        end
    end
end
local function stopEnforceSpeed()
	if enforceConnection then
		enforceConnection:Disconnect()
		enforceConnection = nil
	end
	if Humanoid then
		Humanoid.WalkSpeed = 38
	end
end
    local function applyLowGravity(c)
        local h = c:WaitForChild("Humanoid")
        h.UseJumpPower = false
        h.JumpHeight = 40

        local r = c:WaitForChild("HumanoidRootPart")
        local bf = Instance.new("BodyForce", r)
        bf.Name = "LowGravityForce"
        bf.Force = Vector3.new(0, workspace.Gravity * r.AssemblyMass * 0.75, 0)
    end

    local function removeLowGravity(c)
        local h = c:FindFirstChild("Humanoid")
        if h then h.JumpHeight = 7.2 end

        local r = c:FindFirstChild("HumanoidRootPart")
        if r then
            local bf = r:FindFirstChild("LowGravityForce")
            if bf then bf:Destroy() end
        end
    end

    function Utility.enableLowGravity()
        lowGravityEnabled = true
        if Character then
            applyLowGravity(Character)
        end
    end

    function Utility.disableLowGravity()
        lowGravityEnabled = false
        if Character then
            removeLowGravity(Character)
        end
      end
local function killCharacter()
	task.spawn(function()
		local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid")
		while hum and hum.Health > 0 do
			hum.Health = 0
			task.wait(0.01)
		end
	end)
end
local function getOwnPlot()
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return nil end
    for _, plot in ipairs(plots:GetChildren()) do
            for _, d in ipairs(plot:GetDescendants()) do
            if d:IsA("TextLabel") and d.Text and d.Text:find(LocalPlayer.DisplayName) then
                return plot
            end
        end
        if plot.Name == LocalPlayer.Name or plot.Name == LocalPlayer.DisplayName then
            return plot
        end
    end
    return nil
end

local function checkAutoReset()
	if not autoResetEnabled then return end

	local plot = getOwnPlot()
	if not plot then return end

	local foundUnlocked = false

	for _, d in ipairs(plot:GetDescendants()) do
		if d:IsA("TextLabel") and d.Name == "LockStudio" then
			if d.Visible then
				if not notified then
					notified = true
					Utility.notify("<font color='rgb(255, 0, 0)'>Base Unlocked!</font>")
				end
				foundUnlocked = true
			end
		end
	end

	if not foundUnlocked then
		notified = false
	end
end
do
    local parentGui = gethui()
    local notifGui = parentGui:FindFirstChild("BubbleChatNotifications") or Instance.new("ScreenGui", parentGui)
    notifGui.Name = "BubbleChatNotifications"; notifGui.ResetOnSpawn = false
    local container = notifGui:FindFirstChild("NotificationContainer") or Instance.new("Frame", notifGui)
    container.Name="NotificationContainer"; container.BackgroundTransparency=1
    container.Size=UDim2.new(0,250,0,0); container.Position=UDim2.new(0,10,1,-10); container.AnchorPoint=Vector2.new(0,1)
    local layout = container:FindFirstChildOfClass("UIListLayout") or Instance.new("UIListLayout",container)
    layout.SortOrder=Enum.SortOrder.LayoutOrder; layout.Padding=UDim.new(0,8); layout.VerticalAlignment=Enum.VerticalAlignment.Bottom
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        container.Size = UDim2.new(0,250,0,layout.AbsoluteContentSize.Y)
    end)
    function Utility.notify(text)
        local f=Instance.new("Frame",container); f.Size=UDim2.new(1,0,0,4); f.BackgroundColor3=Color3.fromRGB(30,30,30)
        f.BackgroundTransparency=0.5; f.BorderSizePixel=0; f.LayoutOrder=tick()
        Instance.new("UICorner",f).CornerRadius=UDim.new(0,6); Instance.new("UIStroke",f).Color=Color3.new(0,0,0)
        local tl=Instance.new("TextLabel",f); tl.BackgroundTransparency=1; tl.Position=UDim2.new(0,10,0,4)
        tl.Size=UDim2.new(1,-20,0,18); tl.Font=Enum.Font.Gotham; tl.RichText=true
        tl.Text="<font color='rgb(0,125,255)'>Makal Hub</font> says:"; tl.TextColor3=Color3.new(1,1,1); tl.TextSize=12
        tl.TextXAlignment=Enum.TextXAlignment.Left; tl.TextTransparency=1
        local ml=Instance.new("TextLabel",f); ml.BackgroundTransparency=1; ml.Position=UDim2.new(0,10,0,26)
        ml.Size=UDim2.new(1,-20,0,28); ml.Font=Enum.Font.Gotham; ml.RichText=true
        ml.Text=text or "Notification"; ml.TextColor3=Color3.new(1,1,1); ml.TextSize=12; ml.TextWrapped=true
        ml.TextXAlignment=Enum.TextXAlignment.Left; ml.TextTransparency=1
        TweenService:Create(f,TweenInfo.new(0.4,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size=UDim2.new(1,0,0,60)}):Play()
        task.delay(0.2,function()
            TweenService:Create(tl,TweenInfo.new(0.4),{TextTransparency=0}):Play()
            TweenService:Create(ml,TweenInfo.new(0.4),{TextTransparency=0}):Play()
        end)
        task.delay(5.5,function()
            TweenService:Create(tl,TweenInfo.new(0.3),{TextTransparency=1}):Play()
            TweenService:Create(ml,TweenInfo.new(0.3),{TextTransparency=1}):Play()
            task.wait(0.3)
            local tout=TweenService:Create(f,TweenInfo.new(0.3,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Size=UDim2.new(1,0,0,4)})
            tout:Play(); tout.Completed:Wait(); f:Destroy()
        end)
    end
end
Utility.notify("<font color='rgb(102,255,0)'>Loading Steal A Brainrot Script.</font>")
do
    local stealGui
    function Utility.stealButton()
        if stealGui and stealGui.Parent then return stealGui end
        stealGui = nil

        local floatSpeed = 2
        local moveSpeed = 40

        local parent = (typeof(gethui) == "function" and gethui()) or LocalPlayer:WaitForChild("PlayerGui")
        local sg = Instance.new("ScreenGui", parent)
        sg.Name = "StealSwitchUI"
        sg.IgnoreGuiInset = true
        sg.ResetOnSpawn = false
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        local frame = Instance.new("Frame", sg)
        frame.Size = UDim2.new(0, 100, 0, 30)
        frame.Position = UDim2.new(0.5, -50, 0.87, 0)
        frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        frame.Active = true
        frame.Draggable = true

        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
        local stroke = Instance.new("UIStroke", frame)
        stroke.Color = Color3.fromRGB(0, 170, 255)
        stroke.Thickness = 1.5

        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(1, -40, 1, 0)
        label.Position = UDim2.new(0, 8, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = "Boost"
        label.TextColor3 = Color3.new(1, 1, 1)
        label.Font = Enum.Font.GothamSemibold
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left

        local toggle = Instance.new("TextButton", frame)
        toggle.Size = UDim2.new(0, 30, 0, 15)
        toggle.Position = UDim2.new(1, -35, 0.5, -7)
        toggle.BackgroundColor3 = Color3.fromRGB(30, 150, 255)
        toggle.Text = ""
        toggle.AutoButtonColor = false

        Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)
        local toggleStroke = Instance.new("UIStroke", toggle)
        toggleStroke.Color = Color3.new(1, 1, 1)
        toggleStroke.Thickness = 1

        toggle.MouseButton1Click:Connect(function()
            isActive = not isActive
            toggle.BackgroundColor3 = isActive and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(30, 150, 255)
            if isActive then startEnforceSpeed() else stopEnforceSpeed() end
        end)

        stealGui = sg
        return stealGui
    end
end
local trapConns = {}
local function nukeSpecificTouchInterest(trap)
	local open = trap:FindFirstChild("Open")
	if open then
		for _, child in ipairs(open:GetChildren()) do
			if child.Name == "TouchInterest" then
				child:Destroy()
			end
		end
		if not trapConns[trap] then
			trapConns[trap] = open.ChildAdded:Connect(function(c)
				if c.Name == "TouchInterest" then
					c:Destroy()
				end
			end)
		end
	end
end

local function scanTraps()
	for _, trap in ipairs(workspace:GetChildren()) do
		if trap.Name == "Trap" then
			nukeSpecificTouchInterest(trap)
		end
	end
end

local trapLoop = nil

local function toggleTrapTouchDestroyer(state)
	if state then
		if not trapLoop or not trapLoop.Connected then
			trapLoop = RunService.Heartbeat:Connect(scanTraps)
		end
	else
		if trapLoop then trapLoop:Disconnect() end
		for _, conn in pairs(trapConns) do conn:Disconnect() end
		table.clear(trapConns)
	end
end

local Enabled, reached = false, false
local Character, Humanoid, HRP, toggleButton
local healthConn
local function getDeliveryHitbox()
    local plot = getOwnPlot()
    if not plot then return end
    for _, d in ipairs(plot:GetDescendants()) do
        if d:IsA("BasePart") and d.Name == "DeliveryHitbox" then
            return d
        end
    end
end

local lastNormalJump = tick()
local normalJumpInterval = 3
local function computeAvoidOffset()
    if not Enabled then return Vector3.zero end
    local steer = Vector3.zero

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local other = p.Character.HumanoidRootPart
            local dist = (HRP.Position - other.Position).Magnitude

            if dist < 12 then
                local juke = nil
                for _ = 1, 5 do
                    local rand = math.random(1, 3)
                    local dir = rand == 1 and HRP.CFrame.RightVector * 8 or rand == 2 and -HRP.CFrame.RightVector * 8 or -HRP.CFrame.LookVector * 6
                    local result = Workspace:Raycast(HRP.Position, dir.Unit * 5, RaycastParams.new())
                    if not result then
                        juke = dir
                        break
                    end
                end
                if juke then steer += juke end

                if math.random() < 0.3 then Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end

                local backpack = p:FindFirstChildOfClass("Backpack")
                local tool = p.Character:FindFirstChildOfClass("Tool") or (backpack and backpack:FindFirstChildOfClass("Tool"))
                if tool then
                    local name = tool.Name:lower()
                    if name:find("medusa") or name:find("bat") or name:find("slap") or name:find("sword") then
                        steer += -HRP.CFrame.LookVector * 10
                        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end
        end
    end

    if tick() - lastNormalJump >= normalJumpInterval then
        lastNormalJump = tick()
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end

    if steer.Magnitude > 15 then steer = steer.Unit * 15 end

    return steer
end

local function monitorTouch(hitbox)
    hitbox.Touched:Connect(function(part)
        if part:IsDescendantOf(Character) then
            reached = true
            Enabled = false
            Humanoid:Move(Vector3.zero)
            toggleButton.Text = "Walk To Base: DONE"
            if enforceConnection then enforceConnection:Disconnect() end
        end
    end)
end

local function maintainHealth()
    if healthConn then healthConn:Disconnect() end
    healthConn = RunService.Heartbeat:Connect(function()
        if Humanoid and Humanoid.Health < Humanoid.MaxHealth then
            Humanoid.Health = Humanoid.MaxHealth
        end
    end)
end

local function walkSmartTo(hitbox)
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentJumpHeight = 15,
        AgentMaxSlope = 45
    })
    path:ComputeAsync(HRP.Position, hitbox.Position + Vector3.new(0,3,0))
    if path.Status ~= Enum.PathStatus.Success then return end

    for _, wp in ipairs(path:GetWaypoints()) do
        if reached or not Enabled then return end
        local done = false
        local conn = Humanoid.MoveToFinished:Connect(function() done = true end)
        Humanoid:MoveTo(wp.Position)
        while not done and not reached and Enabled and Humanoid.Health > 0 do
            if not Enabled then
                conn:Disconnect()
                Humanoid:Move(Vector3.zero)
                return
            end
            Humanoid.Health = Humanoid.MaxHealth
            if math.abs(wp.Position.Y - HRP.Position.Y) <= 6 then
                local offset = computeAvoidOffset()
                if offset.Magnitude > 1 then
                    local steer = wp.Position + offset + Vector3.new(math.random(-5,5),0,math.random(-5,5))
                    Humanoid:MoveTo(steer)
                    if offset.Magnitude < 12 then
                        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end
            RunService.Heartbeat:Wait()
        end
        conn:Disconnect()
    end
end

local function setupWalkToBaseHumanoid()
	Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	Humanoid = Character:WaitForChild("Humanoid")
	HRP = Character:WaitForChild("HumanoidRootPart")

	if enforceConnection then enforceConnection:Disconnect() end
	enforceConnection = RunService.Heartbeat:Connect(function()
		if Enabled then
			if Humanoid.WalkSpeed ~= 44 then
				Humanoid.WalkSpeed = 44
			end
			if Humanoid.Health < Humanoid.MaxHealth then
				Humanoid.Health = Humanoid.MaxHealth
			end
		end
	end)

	Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		if Enabled and Humanoid.WalkSpeed ~= 44 then
			Humanoid.WalkSpeed = 44
		end
	end)

	Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		if Enabled and Humanoid.Health < Humanoid.MaxHealth then
			Humanoid.Health = Humanoid.MaxHealth
		end
	end)
end

local function runAI()
	while true do
		repeat RunService.Heartbeat:Wait() until Enabled

		reached = false
		setupWalkToBaseHumanoid()

		local hitbox = getDeliveryHitbox()
		if not hitbox then task.wait(1) continue end

		monitorTouch(hitbox)
		walkSmartTo(hitbox)

		while Enabled and not reached and Humanoid and Humanoid.Health > 0 do
			Humanoid.Health = Humanoid.MaxHealth
			RunService.Heartbeat:Wait()
		end
	end
end

task.spawn(runAI)
function Utility.walkToBaseButton()
    if walkGui and walkGui.Parent then return walkGui end
    walkGui = nil

    local parent = (typeof(gethui) == "function" and gethui()) or LocalPlayer:WaitForChild("PlayerGui")
    local gui = Instance.new("ScreenGui", parent)
    gui.Name = "WalkToBaseUI"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 140, 0, 30)
    frame.Position = UDim2.new(0.5, -70, 0.81, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.Active = true
    frame.Draggable = true

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(70, 130, 255)
    stroke.Thickness = 2

    local button = Instance.new("TextButton", frame)
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Text = "Walk To Base: OFF"

    button.MouseButton1Click:Connect(function()
    if toggleButton.Text == "Walk To Base: DONE" then return end
    Enabled = not Enabled
    reached = false
    toggleButton.Text = Enabled and "Walk To Base: ON" or "Walk To Base: OFF"
    end)

    toggleButton = button
    walkGui = gui
    return gui
end
local resetGui
local wasGodMode = false

function Utility.smartResetButton()
    if resetGui and resetGui.Parent then return resetGui end
    resetGui = nil

    local parent = (typeof(gethui) == "function" and gethui()) or LocalPlayer:WaitForChild("PlayerGui")
    local sg = Instance.new("ScreenGui", parent)
    sg.Name = "SmartResetUI"
    sg.IgnoreGuiInset = true
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0, 100, 0, 30)
    frame.Position = UDim2.new(0.5, -50, 0.87, 0)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.Active = true
    frame.Draggable = true

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(255, 100, 100)
    stroke.Thickness = 1.5

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -40, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = "Reset"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left

    local toggle = Instance.new("TextButton", frame)
    toggle.Size = UDim2.new(0, 30, 0, 15)
    toggle.Position = UDim2.new(1, -35, 0.5, -7)
    toggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    toggle.Text = ""
    toggle.AutoButtonColor = false

    Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)
    local toggleStroke = Instance.new("UIStroke", toggle)
    toggleStroke.Color = Color3.new(1, 1, 1)
    toggleStroke.Thickness = 1

    toggle.MouseButton1Click:Connect(function()
        wasGodMode = false
        if godmode then
            wasGodMode = true
            godmode = false
            if godmodeToggle then godmodeToggle:Set(false) end
        end

        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char.Humanoid.Health = 0
        end
    end)

    LocalPlayer.CharacterAdded:Connect(function()
        if wasGodMode then
            godmode = true
            if godmodeToggle then godmodeToggle:Set(true) end
            wasGodMode = false
        end
    end)

    resetGui = sg
    return resetGui
end
local leaveGui

function Utility.leaveButton()
    if leaveGui and leaveGui.Parent then return leaveGui end
    leaveGui = nil

    local parent = (typeof(gethui) == "function" and gethui()) or LocalPlayer:WaitForChild("PlayerGui")
    local sg = Instance.new("ScreenGui", parent)
    sg.Name = "LeaveHelperUI"
    sg.IgnoreGuiInset = true
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0, 100, 0, 30)
    frame.Position = UDim2.new(0.5, -50, 0.87, 0)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.Active = true
    frame.Draggable = true

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(255, 50, 50)
    stroke.Thickness = 1.5

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -40, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = "Leave"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left

    local toggle = Instance.new("TextButton", frame)
    toggle.Size = UDim2.new(0, 30, 0, 15)
    toggle.Position = UDim2.new(1, -35, 0.5, -7)
    toggle.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    toggle.Text = ""
    toggle.AutoButtonColor = false

    Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)
    local toggleStroke = Instance.new("UIStroke", toggle)
    toggleStroke.Color = Color3.new(1, 1, 1)
    toggleStroke.Thickness = 1

    toggle.MouseButton1Click:Connect(function()
        game:Shutdown()
    end)

    leaveGui = sg
    return leaveGui
end
local brainrotESP = {}
local brainrotConnection = nil

local raritySettings = {
    ["Brainrot God"] = {Enabled = false, Color = Color3.fromRGB(0, 255, 255)},
    ["Secret"]       = {Enabled = false, Color = Color3.fromRGB(0, 0, 0)},
    ["Mythic"]       = {Enabled = false, Color = Color3.fromRGB(255, 0, 0)},
    ["Legendary"]    = {Enabled = false, Color = Color3.fromRGB(255, 255, 0)},
    ["Epic"]         = {Enabled = false, Color = Color3.fromRGB(128, 0, 128)},
    ["Rare"]         = {Enabled = false, Color = Color3.fromRGB(0, 0, 255)},
    ["Common"]       = {Enabled = false, Color = Color3.fromRGB(0, 255, 0)},
}

local function getOverheadAndRarity(podium)
    local attach = podium:FindFirstChild("Base", true)
    if attach then
        local spawn = attach:FindFirstChild("Spawn", true)
        if spawn then
            local attachment = spawn:FindFirstChild("Attachment", true)
            if attachment then
                local overhead = attachment:FindFirstChild("AnimalOverhead", true)
                if overhead then
                    local displayName = overhead:FindFirstChild("DisplayName")
                    local rarity = overhead:FindFirstChild("Rarity")
                    if displayName and rarity then
                        return displayName, rarity.Text
                    end
                end
            end
        end
    end
    return nil, nil
end

local function removeBrainrotESP(podium)
    local esp = brainrotESP[podium]
    if esp then
        if esp.nameTag then esp.nameTag:Destroy() end
        if esp.conn then esp.conn:Disconnect() end
        brainrotESP[podium] = nil
    end
end

local function createBrainrotESP(podium, displayName, rarity, color)
    local base = podium:FindFirstChild("Base") or podium.PrimaryPart or podium:FindFirstChildWhichIsA("BasePart")
    if not base then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = base
    billboard.Parent = base
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.Name = "BrainrotESP"

    local label = Instance.new("TextLabel")
    label.Parent = billboard
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextScaled = false
    label.TextSize = 16
    label.Font = Enum.Font.Gotham
    label.TextColor3 = color
    label.TextStrokeTransparency = 0.3
    label.Text = displayName.Text

    local conn = displayName:GetPropertyChangedSignal("Text"):Connect(function()
        local newDisplay, newRarity = getOverheadAndRarity(podium)
        local rs = raritySettings[newRarity]
        if not newDisplay or not rs or not rs.Enabled then
            removeBrainrotESP(podium)
        else
            local part = podium.PrimaryPart or podium:FindFirstChildWhichIsA("BasePart")
            if part and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - part.Position).Magnitude
                label.Text = string.format("%s [%.0f]", newDisplay.Text, dist)
            end
        end
    end)

    brainrotESP[podium] = {
        nameTag = billboard,
        label = label,
        displayName = displayName,
        conn = conn
    }
end

local function updateBrainrotESP()
    for _, plot in ipairs(workspace.Plots:GetChildren()) do
        local podiums = plot:FindFirstChild("AnimalPodiums")
        if podiums then
            for _, podium in ipairs(podiums:GetChildren()) do
                local displayName, rarity = getOverheadAndRarity(podium)
                local rs = raritySettings[rarity]
                if displayName and rarity and rs and rs.Enabled then
                    if not brainrotESP[podium] then
                        createBrainrotESP(podium, displayName, rarity, rs.Color)
                    end
                else
                    removeBrainrotESP(podium)
                end
            end
        end
    end
    for podium, data in pairs(brainrotESP) do
        if not podium.Parent then
            removeBrainrotESP(podium)
        elseif data.displayName and data.label then
            local part = podium.PrimaryPart or podium:FindFirstChildWhichIsA("BasePart")
            if part and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - part.Position).Magnitude
                data.label.Text = string.format("%s [%.0f]", data.displayName.Text, dist)
            end
        end
    end
end

function StartBrainrotESP()
    if brainrotConnection then return end
    brainrotConnection = RunService.Heartbeat:Connect(updateBrainrotESP)
end

function StopBrainrotESP()
    if brainrotConnection then
        brainrotConnection:Disconnect()
        brainrotConnection = nil
    end
    for podium in pairs(brainrotESP) do
        removeBrainrotESP(podium)
    end
end
local ReplicatedStorage = Services.ReplicatedStorage --pluh im lazy vro please continue pls plsplsplspslsplspslspslspslsllalaaaaaaa
local Net = ReplicatedStorage.Packages.Net
local RequestBuy = Net:FindFirstChild("RF/CoinsShopService/RequestBuy")

local allItems = {
    {Name = "Slap", ID = "Basic Slap"},
    {Name = "Iron Slap", ID = "Iron Slap"},
    {Name = "Gold Slap", ID = "Gold Slap"},
    {Name = "Diamond Slap", ID = "Diamond Slap"},
    {Name = "Emerald Slap", ID = "Emerald Slap"},
    {Name = "Ruby Slap", ID = "Ruby Slap"},
    {Name = "Dark Matter Slap", ID = "Dark Matter Slap"},
    {Name = "Flame Slap", ID = "Flame Slap"},
    {Name = "Nuclear Slap", ID = "Nuclear Slap"},
    {Name = "Galaxy Slap", ID = "Galaxy Slap"},
    {Name = "Trap", ID = "Trap"},
    {Name = "Bee Launcher", ID = "Bee Launcher"},
    {Name = "Rage Table", ID = "Rage Table"},
    {Name = "Grapple Hook", ID = "Grapple Hook"},
    {Name = "Taser Gun", ID = "Taser Gun"},
    {Name = "Boogie Bomb", ID = "Boogie Bomb"},
    {Name = "Medusa's Head", ID = "Medusa's Head"},
    {Name = "Web Slinger", ID = "Web Slinger"},
    {Name = "Quantum Cloner", ID = "Quantum Cloner"},
    {Name = "All Seeing Sentry", ID = "All Seeing Sentry"},
    {Name = "Laser Cape", ID = "Laser Cape"},
    {Name = "Speed Coil", ID = "Speed Coil"},
    {Name = "Gravity Coil", ID = "Gravity Coil"},
    {Name = "Coil Combo", ID = "Coil Combo"},
    {Name = "Invisibility Cloak", ID = "Invisibility Cloak"},
    {Name = "Rainbowrath Sword",ID = "Rainbowrath Sword"}, 
    {Name = "Laser Cape", ID = "Laser Cape"},
    {Name = "Glitched Slap", ID = "Glitched Slap"},
    {Name = "Body Swap Potion", ID = "Body Swap Potion"},
    {Name = "Splatter Slap", ID = "Splatter Slap"},
    {Name = "Paintball Gun", ID = "Paintball Gun"}
}
local itemNames = {}
for _, item in ipairs(allItems) do
    table.insert(itemNames, item.Name)
end
local espPlayers = {}
local espPlots = {}

local function removePlayerESP(player)
	local esp = espPlayers[player]
	if esp then
		if esp.highlight then esp.highlight:Destroy() end
		if esp.nameTag then esp.nameTag:Destroy() end
		if esp.box then esp.box:Destroy() end
		espPlayers[player] = nil
	end
end

local function createPlayerESP(player)
	if player == Players.LocalPlayer or espPlayers[player] or not espPlayer then return end
	local character = player.Character
	if not (character and character.Parent) then return end
	local head = character:FindFirstChild("Head")
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not (head and hrp) then return end

	local highlight = Instance.new("Highlight")
	highlight.Adornee = character
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 1
	highlight.FillColor = Color3.fromRGB(80, 170, 255)
	highlight.Parent = character

	local billboard = Instance.new("BillboardGui")
	billboard.Adornee = head
	billboard.AlwaysOnTop = true
	billboard.Size = UDim2.new(0, 100, 0, 20)
	billboard.StudsOffset = Vector3.new(0, 2.5, 0)
	billboard.Name = "NameESP"
	billboard.Parent = head

	local nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Size = UDim2.new(1, 0, 1, 0)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextScaled = true
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextStrokeTransparency = 0.5
	nameLabel.Text = player.DisplayName
	nameLabel.Parent = billboard

	local box = Instance.new("BoxHandleAdornment")
	box.Adornee = hrp
	box.AlwaysOnTop = true
	box.ZIndex = 5
	box.Size = hrp.Size + Vector3.new(0.1, 0.1, 0.1)
	box.Color3 = Color3.fromRGB(80, 170, 255)
	box.Transparency = 0.3
	box.Name = "HRPBox"
	box.Parent = hrp

	espPlayers[player] = {
		highlight = highlight,
		nameTag = billboard,
		box = box
	}
end

local function updateESPState()
	if not espPlayer then
		for player in pairs(espPlayers) do
			removePlayerESP(player)
		end
	else
		for _, p in ipairs(Players:GetPlayers()) do
			if not espPlayers[p] then
				createPlayerESP(p)
			end
		end
	end
end

for _, p in ipairs(Players:GetPlayers()) do
	p.CharacterAdded:Connect(function()
		task.wait(1)
		removePlayerESP(p)
		createPlayerESP(p)
	end)
	if p.Character then
		createPlayerESP(p)
	end
end

Players.PlayerAdded:Connect(function(p)
	p.CharacterAdded:Connect(function()
		task.wait(1)
		removePlayerESP(p)
		createPlayerESP(p)
	end)
end)

Players.PlayerRemoving:Connect(removePlayerESP)

LocalPlayer.CharacterAdded:Connect(function()
	for p in pairs(espPlayers) do
		removePlayerESP(p)
	end
end)

local function isValidPlot(plot)
	local block = plot:FindFirstChild("Purchases") and plot.Purchases:FindFirstChild("PlotBlock")
	local main = block and block:FindFirstChild("Main")
	local gui = main and main:FindFirstChild("BillboardGui")
	return main, gui
end

local function getPlotOwnerText(plot)
	local s = plot:FindFirstChild("PlotSign")
	local sg = s and s:FindFirstChild("SurfaceGui")
	local f = sg and sg:FindFirstChild("Frame")
	local lbl = f and f:FindFirstChild("TextLabel")
	local txt = lbl and lbl.Text
	if not txt or txt:find("Empty Base") then return nil end
	return txt:match("^(.-)'s Base$") or nil
end

local function createPlotESP(plot, owner, main, gui, lock, remaining)
	local espGui = Instance.new("BillboardGui")
	espGui.Adornee = main
	espGui.Parent = main
	espGui.Size = UDim2.new(0, 200, 0, 32)
	espGui.StudsOffset = Vector3.new(0, 30, 0)
	espGui.AlwaysOnTop = true

	local label = Instance.new("TextLabel")
	label.Parent = espGui
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextScaled = false
	label.TextSize = 15
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Text = owner .. " | ..."
	label.TextWrapped = true

	espPlots[plot] = {
		gui = espGui,
		label = label,
		remaining = remaining,
		lock = lock,
		owner = owner
	}
end

local function destroyPlotESP(plot)
	local data = espPlots[plot]
	if data then
		if data.gui then data.gui:Destroy() end
		espPlots[plot] = nil
	end
end

local function updatePlots()
	local plotsFolder = Workspace:FindFirstChild("Plots")
	if not plotsFolder then return end

	for _, plot in ipairs(plotsFolder:GetChildren()) do
		local owner = getPlotOwnerText(plot)
		local hasESP = espPlots[plot]

		if owner then
			local main, gui = isValidPlot(plot)
			if not main or not gui then continue end

			local lock = gui:FindFirstChild("LockStudio")
			local remaining = gui:FindFirstChild("RemainingTime")
			if not lock or not remaining then continue end

			if not hasESP then
				createPlotESP(plot, owner, main, gui, lock, remaining)
			else
				local data = espPlots[plot]
				if data.owner ~= owner then
					destroyPlotESP(plot)
					createPlotESP(plot, owner, main, gui, lock, remaining)
				elseif data.lock.Visible then
					data.label.Text = data.owner .. " | UNLOCKED!"
					data.label.TextColor3 = Color3.fromRGB(0, 255, 0)
				else
					data.label.Text = data.owner .. " | Time: " .. (data.remaining.Text or "?")
					data.label.TextColor3 = Color3.fromRGB(255, 50, 50)
				end
			end
		elseif hasESP then
			destroyPlotESP(plot)
		end
	end
end

function Utility.startPlotESP()
	if not plotCon then
		plotCon = RunService.Heartbeat:Connect(updatePlots)
	end
end

function Utility.stopPlotESP()
	if plotCon then
		plotCon:Disconnect()
		plotCon = nil
	end
	for plot, d in pairs(espPlots) do
		if d.gui then d.gui:Destroy() end
		espPlots[plot] = nil
	end
end

LocalPlayer.CharacterAdded:Connect(function()
	task.wait(0.1)
	updateCharacterReferences()
	if isActive then
		startEnforceSpeed()
	end
	if lowGravityEnabled then
		task.delay(0.1, function()
			applyLowGravity(Character)
		end)
	end
end)
function Utility.getOwnPlot()
    return getOwnPlot()
end
function Utility.updateESPState()
    return updateESPState()
end
function Utility.updatePlots()
    return updatePlots()
end
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local function teleportToSky()
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
rootPart.CFrame = rootPart.CFrame + Vector3.new(0, 180, 0)  
rootPart.Anchored = true  
task.wait(1)  
rootPart.Anchored = false
end
local function tweenToBase()
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local deliveryHitbox = getDeliveryHitbox()  
if not deliveryHitbox then  
    warn("No DeliveryHitbox found!")  
    rootPart.Anchored = false  
    return  
end  

local targetPos = deliveryHitbox.Position + Vector3.new(0, 5, 0)  
local currentPos = rootPart.Position  
local halfwayPos = currentPos + ((targetPos - currentPos) * 0.5)  
local driftGoal = {  
    CFrame = CFrame.new(halfwayPos)  
}  
local driftTween = TweenService:Create(  
    rootPart,  
    TweenInfo.new(1, Enum.EasingStyle.Linear),  
    driftGoal  
)  
driftTween:Play()  
driftTween.Completed:Connect(function()  
    rootPart.Anchored = false  
end)
end
local translations = {
["en"] = {
Title = "Steal Helper",
Teleport = "Teleport To Sky",
Tween = "Tween To Base",
Warning = "Please click Tween To Base ONLY when you're on top of your base."
},
["id"] = {
Title = "Pembantu Mencuri",
Teleport = "Teleport ke Langit",
Tween = "Tween ke Base",
Warning = "Klik Tween ke Base HANYA saat kamu di atas base-mu."
},
["vi"] = {
Title = "Công Cụ Bay & Về Căn Cứ",
Teleport = "Dịch Chuyển Lên Trời",
Tween = "Tween Về Căn Cứ",
Warning = "Chỉ bấm Tween Về Căn Cứ khi bạn đang ở trên căn cứ."
}
}

local localeId = LocalPlayer.LocaleId:lower()
local langCode = localeId:split("-")[1]
local t = translations[langCode] or translations["en"]
local stealhelper
function Utility.StealHelper()
if stealhelper and stealhelper.Parent then return end
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SkyBaseUI"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false
stealhelper = ScreenGui
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 260, 0, 180)
Frame.Position = UDim2.new(0.5, -130, 0.5, -90)
Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = Frame

local UIStroke = Instance.new("UIStroke")
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Color = Color3.fromRGB(60, 60, 70)
UIStroke.Thickness = 2
UIStroke.Parent = Frame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = t.Title
TitleLabel.Font = Enum.Font.GothamSemibold
TitleLabel.TextSize = 16
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Parent = Frame

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, -20, 0, 40)
InfoLabel.Position = UDim2.new(0, 10, 0, 30)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = t.Warning
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextWrapped = true
InfoLabel.TextSize = 12
InfoLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
InfoLabel.Parent = Frame

local TPButton = Instance.new("TextButton")
TPButton.Size = UDim2.new(1, -40, 0, 35)
TPButton.Position = UDim2.new(0, 20, 0, 80)
TPButton.Text = t.Teleport
TPButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
TPButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TPButton.Font = Enum.Font.Gotham
TPButton.TextSize = 14
TPButton.Parent = Frame

local TPButtonCorner = Instance.new("UICorner")
TPButtonCorner.CornerRadius = UDim.new(0, 8)
TPButtonCorner.Parent = TPButton

local TweenButton = Instance.new("TextButton")
TweenButton.Size = UDim2.new(1, -40, 0, 35)
TweenButton.Position = UDim2.new(0, 20, 0, 125)
TweenButton.Text = t.Tween
TweenButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
TweenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TweenButton.Font = Enum.Font.Gotham
TweenButton.TextSize = 14
TweenButton.Parent = Frame

local TweenButtonCorner = Instance.new("UICorner")
TweenButtonCorner.CornerRadius = UDim.new(0, 8)
TweenButtonCorner.Parent = TweenButton

local FooterLabel = Instance.new("TextLabel")
FooterLabel.Size = UDim2.new(1, -20, 0, 20)
FooterLabel.Position = UDim2.new(0, 10, 1, -20)
FooterLabel.BackgroundTransparency = 1
FooterLabel.Text = "Makal Hub"
FooterLabel.Font = Enum.Font.GothamSemibold
FooterLabel.TextSize = 12
FooterLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
FooterLabel.TextYAlignment = Enum.TextYAlignment.Center
FooterLabel.TextXAlignment = Enum.TextXAlignment.Right
FooterLabel.Parent = Frame

local function addHover(button, hoverColor)
local originalColor = button.BackgroundColor3
button.MouseEnter:Connect(function()
button.BackgroundColor3 = hoverColor
end)
button.MouseLeave:Connect(function()
button.BackgroundColor3 = originalColor
end)
end

addHover(TPButton, Color3.fromRGB(100, 160, 210))
addHover(TweenButton, Color3.fromRGB(76, 224, 143))

TPButton.MouseButton1Click:Connect(teleportToSky)
TweenButton.MouseButton1Click:Connect(tweenToBase)
return stealhelper
end
local W=WindUI:CreateWindow{Title="Steal A Brainrot | Makal Hub",Icon="sparkles",IconThemed=true,Author="Makal Hub",Folder="Makal Hub",Theme="Dark",Transparent=true,Size=UDim2.fromOffset(600,300),Configuration={Enabled=True,FileName="stealabrainrot"},Discord={Enabled=true,Invite="N3eDFJ9UCF"},KeySystem=false}
local Tab=W:Tab{Title="Main",Icon="house"}
local T2 = W:Tab{Title="Visuals",Icon="scan-eye"}
local shop = W:Tab{Title="Buy Items",Icon="shopping-cart"}
espPlayerToggle = T2:Toggle{
    Title   = "Player ESP",
    Value   = false,
    Config  = "Playeresp",
    Callback = function(v)
        espPlayer = v
        Utility.updateESPState()
    end
}
espPlotToggle = T2:Toggle{
    Title   = "Plot ESP",
    Value   = false,
    Config  = "plotesp",
    Callback = function(v)
        espPlot = v
        if v then Utility.startPlotESP() else Utility.stopPlotESP() end
    end
}
T2:Section{Title = "Brainrot ESP"}
commonToggle = T2:Toggle{
    Title   = "Common",
    Value   = false,
    Config  = "commonesp",
    Callback = function(v)
        raritySettings["Common"].Enabled = v
        if v then StartBrainrotESP() end
    end
}
rareToggle = T2:Toggle{
    Title   = "Rare",
    Value   = false,
    Config  = "rareesp",
    Callback = function(v)
        raritySettings["Rare"].Enabled = v
        if v then StartBrainrotESP() end
    end
}
epicToggle = T2:Toggle{
    Title   = "Epic",
    Value   = false,
    Config  = "epicesp",
    Callback = function(v)
        raritySettings["Epic"].Enabled = v
        if v then StartBrainrotESP() end
    end
}
legendaryToggle = T2:Toggle{
    Title   = "Legendary",
    Value   = false,
    Config  = "legenesp",
    Callback = function(v)
        raritySettings["Legendary"].Enabled = v
        if v then StartBrainrotESP() end
    end
}
mythicToggle = T2:Toggle{
    Title   = "Mythic",
    Value   = false,
    Config  = "mythesp",
    Callback = function(v)
        raritySettings["Mythic"].Enabled = v
        if v then StartBrainrotESP() end
    end
}
godToggle = T2:Toggle{
    Title   = "Brainrot God",
    Value   = false,
    Config  = "godesp",
    Callback = function(v)
        raritySettings["Brainrot God"].Enabled = v
        if v then StartBrainrotESP() end
    end
}
secretToggle = T2:Toggle{
    Title   = "Secret",
    Value   = false,
    Config  = "secretesp",
    Callback = function(v)
        raritySettings["Secret"].Enabled = v
        if v then StartBrainrotESP() end
    end
}
Tab:Section{Title = "Self Modification"}
antiRagdollToggle = Tab:Toggle{
    Title   = "Anti Ragdoll",
    Value   = false,
    Config  = "ragdoll",
    Callback = function(v)
        antiRagdollEnabled = v
    end
}
godmodeToggle = Tab:Toggle{
    Title    = "God Mode",
    Value    = false,
    Config   = "god",
    Callback = function(v)
        godmode = v
    end
}
infjumpToggle = Tab:Toggle{
    Title    = "Infinite Jump",
    Value    = false,
    Config   = "infjump",
    Callback = function(v)
        infiniteJump = v
    end
}
Tab:Section{Title = "Steal Helper"}
walkButtonToggle = Tab:Toggle{
    Title   = "Show Walk To Base Button [BETA]",
    Value   = false,
    Config  = "basebutton",
    Desc    = "This not only walk normally but with Automation of Avoidance!",
    Callback = function(v)
        if v then
            walkGui = Utility.walkToBaseButton()
        else
            if walkGui then
                walkGui:Destroy()
                walkGui = nil
            end
        end
    end
}
boostButtonToggle = Tab:Toggle{
    Title    = "Show Boost Steal Button",
    Value    = false,
    Config   = "booststealbttn",
    Callback = function(v)
        if v then
            stealGui = Utility.stealButton()
        else
            if stealGui then
                stealGui:Destroy()
                stealGui = nil
            end
        end
    end
}
local stealGui
stealhelping = Tab:Toggle{
    Title    = "Show Semi Instant Steal Button",
    Value    = false,
    Config   = "semiinstant",
    Callback = function(v)
        if v then
            stealGui = Utility.StealHelper()
        else
            if stealGui then
                stealGui:Destroy()
                stealGui = nil
            end
        end
    end
}
boostJumpToggle = Tab:Toggle{
    Title    = "Boost Jumppower",
    Value    = false,
    Config   = "boostjmp",
    Callback = function(v)
        if v then Utility.enableLowGravity() else Utility.disableLowGravity() end
    end
}
Tab:Section{Title = "Miscellaneous"}
autoNotifyToggle = Tab:Toggle{
    Title    = "Auto Notify on Unlock",
    Value    = false,
    Config   = "notifyunlck",
    Callback = function(v)
        autoResetEnabled = v
        if not v then notified = false end
    end
}
smartResetToggle = Tab:Toggle{
    Title = "Show Reset Button",
    Value = false,
    Config = "smartreset",
    Callback = function(v)
        if v then
            resetGui = Utility.smartResetButton()
        else
            if resetGui then
                resetGui:Destroy()
                resetGui = nil
            end
        end
    end
}
leaveGuiToggle = Tab:Toggle{
    Title = "Show Leave Button",
    Value = false,
    Config = "leavehelper",
    Callback = function(v)
        if v then
            leaveGui = Utility.leaveButton()
        else
            if leaveGui then
                leaveGui:Destroy()
                leaveGui = nil
            end
        end
    end
}
disableTrapToggle = Tab:Toggle{
    Title    = "Disable Trap",
    Value    = false,
    Config   = "disabletrap",
    Callback = function(v)
        toggleTrapTouchDestroyer(v)
    end
}
shop:Dropdown({
    Title = "Buy Item",
    Desc = "Select an item to buy",
    Values = itemNames,
    Default = itemNames[1],
    Callback = function(selected)
        for _, item in ipairs(allItems) do
            if item.Name == selected then
                local success, result = pcall(function()
                    return RequestBuy:InvokeServer(item.ID)
                end)
                if success then
                    Utility.notify("<font color='rgb(0, 255, 0)'>[✔] Successfully bought:</font> " .. selected)
                else
                    Utility.notify("<font color='rgb(255, 0, 0)'>[✖] Error buying:</font> " .. tostring(result))
                end
                break
            end
        end
    end
})
local HttpService = game:GetService("HttpService")
local ConfigManager = W.ConfigManager
local baseDir = "WindUI/" .. W.Folder .. "/config/"
local autoFile = baseDir .. "__auto.json"
if not isfolder("WindUI") then makefolder("WindUI") end
if not isfolder("WindUI/" .. W.Folder) then makefolder("WindUI/" .. W.Folder) end
if not isfolder(baseDir) then makefolder(baseDir) end
local CurrentName = ""
local AutoLoad = false

local function RegisterAll(cfg)
    if not espPlayerToggle then
        task.spawn(function()
            repeat task.wait() until espPlayerToggle and godmodeToggle and infjumpToggle and walkButtonToggle
            RegisterAll(cfg)
        end)
        return
    end

    cfg:Register("Playeresp", espPlayerToggle)
    cfg:Register("plotesp", espPlotToggle)
    cfg:Register("commonesp", commonToggle)
    cfg:Register("rareesp", rareToggle)
    cfg:Register("epicesp", epicToggle)
    cfg:Register("legenesp", legendaryToggle)
    cfg:Register("mythesp", mythicToggle)
    cfg:Register("godesp", godToggle)
    cfg:Register("secretesp", secretToggle)
    cfg:Register("ragdoll", antiRagdollToggle)
    cfg:Register("god", godmodeToggle)
    cfg:Register("infjump", infjumpToggle)
    cfg:Register("basebutton", walkButtonToggle)
    cfg:Register("booststealbttn", boostButtonToggle)
    cfg:Register("boostjmp", boostJumpToggle)
    cfg:Register("notifyunlck", autoNotifyToggle)
    cfg:Register("disabletrap", disableTrapToggle)
    cfg:Register("smartreset", smartResetToggle)
    cfg:Register("leavehelper", leaveGuiToggle)
    cfg:Register("semiinstant", stealhelping)
end

local cfgTab = W:Tab({ Title = "Configs" })

local cfgDropdown = cfgTab:Dropdown({
    Title = "Select Config",
    Desc = "Pick a saved config",
    Values = ConfigManager:AllConfigs(),
    Value = "",
    Callback = function(name)
        if name and name ~= "" then
            writefile(autoFile, HttpService:JSONEncode({ last = name }))

            if AutoLoad then
                local cfg = ConfigManager:CreateConfig(name)
                RegisterAll(cfg)
                task.wait(0.1)
                local ok, raw = pcall(readfile, cfg.Path)
                if ok and raw ~= "" then
                    local ok2, data = pcall(HttpService.JSONDecode, HttpService, raw)
                    if ok2 and data and data.Elements then
                        cfg:Load()
                    end
                end
            end
        end
    end
})

local nameInput = cfgTab:Input({
    Title = "Config Name",
    Placeholder = "Type a name",
    Default = "",
    Callback = function(txt) CurrentName = txt or "" end
})

cfgTab:Button({
    Title = "Save New",
    Callback = function()
        if CurrentName ~= "" then
            local cfg = ConfigManager:CreateConfig(CurrentName)
            RegisterAll(cfg)
            cfg:Save()
            cfgDropdown:Refresh(ConfigManager:AllConfigs())
            cfgDropdown:Select(CurrentName)
        end
    end
})

cfgTab:Button({
    Title = "Load",
    Callback = function()
        local sel = cfgDropdown.Value
        if sel and sel ~= "" then
            local cfg = ConfigManager:CreateConfig(sel)
            RegisterAll(cfg)
            task.wait(0.1)
            local ok, raw = pcall(readfile, cfg.Path)
            if ok and raw ~= "" then
                local ok2, data = pcall(HttpService.JSONDecode, HttpService, raw)
                if ok2 and data and data.Elements then
                    cfg:Load()
                end
            end
        end
    end
})

cfgTab:Toggle({
    Title = "Auto Load",
    Value = false,
    Callback = function(v)
        AutoLoad = v
    end
})

cfgTab:Button({
    Title = "Update",
    Callback = function()
        if cfgDropdown.Value ~= "" then
            local cfg = ConfigManager:CreateConfig(cfgDropdown.Value)
            RegisterAll(cfg)
            cfg:Save()
        end
    end
})

cfgTab:Button({
    Title = "Rename",
    Callback = function()
        local old = cfgDropdown.Value
        local new = CurrentName
        if old and old ~= "" and new and new ~= "" then
            local oldPath = "WindUI/" .. W.Folder .. "/config/" .. old .. ".json"
            local newPath = "WindUI/" .. W.Folder .. "/config/" .. new .. ".json"
            if isfile(oldPath) then
                writefile(newPath, readfile(oldPath))
                delfile(oldPath)
                cfgDropdown:Refresh(ConfigManager:AllConfigs())
                cfgDropdown:Select(new)
                writefile(autoFile, HttpService:JSONEncode({ last = new }))
            end
        end
    end
})

cfgTab:Button({
    Title = "Delete",
    Callback = function()
        local sel = cfgDropdown.Value
        if sel and sel ~= "" then
            local path = "WindUI/" .. W.Folder .. "/config/" .. sel .. ".json"
            if isfile(path) then delfile(path) end
            cfgDropdown:Refresh(ConfigManager:AllConfigs())
        end
    end
})

cfgTab:Button({
    Title = "Refresh",
    Callback = function()
        cfgDropdown:Refresh(ConfigManager:AllConfigs())
    end
})

local ok, raw = pcall(readfile, autoFile)
if ok and raw ~= "" then
    local succ, dat = pcall(HttpService.JSONDecode, HttpService, raw)
    if succ and dat and dat.last then
        cfgDropdown:Select(dat.last)
        local cfg = ConfigManager:CreateConfig(dat.last)
        RegisterAll(cfg)
        task.wait(0.1)
        local ok2, raw2 = pcall(readfile, cfg.Path)
        if ok2 and raw2 ~= "" then
            local ok3, dat2 = pcall(HttpService.JSONDecode, HttpService, raw2)
            if ok3 and dat2 and dat2.Elements then
                cfg:Load()
                AutoLoad = true
            end
        end
    end
end
task.wait(2)
Utility.notify("<font color='rgb(102,255,0)'>Script Loaded Successfully.</font>")
RunService.Heartbeat:Connect(function()
	Character = LocalPlayer.Character
	Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
	if not Humanoid then return end

	if isActive and Humanoid.WalkSpeed ~= 44 then
		Humanoid.WalkSpeed = 44
	end

	if godmode and Humanoid.Health < Humanoid.MaxHealth then
		Humanoid.Health = Humanoid.MaxHealth
	end

	if antiRagdollEnabled then
		Utility.runAntiRagdoll()
	end

	if espPlayer then
		Utility.updateESPState()
	end

	if espPlot then
		Utility.updatePlots()
	end

	if autoResetEnabled then
		checkAutoReset()
	end
end)
UserInputService.JumpRequest:Connect(function()
    if infiniteJump and Humanoid and Humanoid:GetState() ~= Enum.HumanoidStateType.Seated then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        local HRP = Humanoid.Parent:FindFirstChild("HumanoidRootPart")
        if HRP then
            HRP.AssemblyLinearVelocity = Vector3.new(HRP.AssemblyLinearVelocity.X, 50, HRP.AssemblyLinearVelocity.Z)
            task.wait(0.03)
            HRP.AssemblyLinearVelocity = Vector3.new(HRP.AssemblyLinearVelocity.X, 50, HRP.AssemblyLinearVelocity.Z)
        end
    end
end)
end)
OwO:Button("Infinite Cash", function()
while true do
game:GetService("Players").LocalPlayer.PlayerGui.LeftBottom.LeftBottom.Currency.Text = "20e6"
wait(0)
end
end)

OwO:Button("Lock Base", function()
game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Health = 0
end)
OwO:Toggle("Anti Steal", false, function(v)
if v then
			-- Saat toggle ON
			-- Zona Perlindungan Toggle-able Version
if getgenv().ProtectionEnabled == nil then
	getgenv().ProtectionEnabled = false
end

local player = game.Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")
local plots = workspace:WaitForChild("Plots")

local zone = nil

local function getStructureBaseHome()
	for _, base in pairs(plots:GetChildren()) do
		if base:IsA("Model") then
			for _, descendant in pairs(base:GetDescendants()) do
				if descendant:IsA("TextLabel") and string.find(descendant.Text, player.Name) then
					local decorations = base:FindFirstChild("Decorations")
					if decorations then
						local innerModel = decorations:FindFirstChild("Model")
						if innerModel then
							local children = innerModel:GetChildren()
							if #children >= 5 then
								local targetPart = children[5]
								if targetPart:IsA("BasePart") then
									return targetPart
								end
							end
						end
					end
				end
			end
		end
	end
	return nil
end

local function isInsidePart(part, position)
	local localPos = part.CFrame:pointToObjectSpace(position)
	local halfSize = part.Size / 2
	return math.abs(localPos.X) <= halfSize.X and
	       math.abs(localPos.Y) <= halfSize.Y and
	       math.abs(localPos.Z) <= halfSize.Z
end

getgenv().activateProtection = function()
	if getgenv().ProtectionEnabled then return end
	getgenv().ProtectionEnabled = true
	getgenv().ProtectionThread = true

	StarterGui:SetCore("SendNotification", {
		Title = "Anti Steal On",
		Text = "You will leave the game if a player going to your base.",
		Duration = 10
	})

	local basePart = getStructureBaseHome()
	if basePart then
		zone = Instance.new("Part", workspace)
		zone.Anchored = true
		zone.CanCollide = false
		zone.Transparency = 0.5
		zone.BrickColor = BrickColor.new("Really red")
		zone.Size = Vector3.new(37, 42, 70)
		zone.CFrame = basePart.CFrame
		zone.Name = "ExitZone"

		print("dwawdawd")

		task.spawn(function()
			while getgenv().ProtectionEnabled and getgenv().ProtectionThread do
				for _, plr in pairs(game.Players:GetPlayers()) do
					if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
						local pos = plr.Character.HumanoidRootPart.Position
						if isInsidePart(zone, pos) then
							print("⚠️ Player lain masuk! Keluar game...")
							getgenv().ProtectionThread = false
							game:Shutdown()
							break
						end
					end
				end
				task.wait(0.1) -- ✅ Hemat performa, hanya cek 3 kali per detik
			end
		end)
	else
		warn("")
	end
end

getgenv().deactivateProtection = function()
	getgenv().ProtectionEnabled = false
	getgenv().ProtectionThread = false
	if zone and zone.Parent then
		zone:Destroy()
	end
	print("")
end
			task.delay(0.2, function()
				if getgenv().activateProtection then
					getgenv().activateProtection()
				end
			end)
		else
			-- Saat toggle OFF
			if getgenv().deactivateProtection then
				getgenv().deactivateProtection()
			end
		end
end)
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local heightOffset = 173.1
local hrp

local function getHRP()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

-- Keep hrp updated on respawn
player.CharacterAdded:Connect(function(char)
    hrp = char:WaitForChild("HumanoidRootPart")
end)

hrp = getHRP()

OwO:Toggle("Auto Steal Skywalk", false, function(enabled)
    if not hrp then
        hrp = getHRP()
    end
    if enabled then
        hrp.CFrame = hrp.CFrame + Vector3.new(0, heightOffset, 0)
    else
        hrp.CFrame = hrp.CFrame - Vector3.new(0, heightOffset, 0)
    end
end)

-- 🛠 Equip + attack
local function attackAllTools()
	local char = player.Character
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")

	if humanoid then
		for _, tool in ipairs(char:GetChildren()) do
			if tool:IsA("Tool") then
				if humanoid:FindFirstChildOfClass("Tool") ~= tool then
					humanoid:EquipTool(tool)
				end
				pcall(function()
					tool:Activate()
				end)
			end
		end
	end
end

-- ✅ Toggle setup
OwO:Toggle("Auto Tp + Kill Aura", false, function(Value)
	autoFarmActive = Value

	if autoFarmActive then
		autoFarmConnection = RunService.RenderStepped:Connect(function()
			local nearest = getNearestPlayer()
			if nearest and nearest.Character and nearest.Character:FindFirstChild("HumanoidRootPart") then
				tweenTo(nearest.Character.HumanoidRootPart)
				attackAllTools()
			end
		end)
	else
		if autoFarmConnection then
			autoFarmConnection:Disconnect()
			autoFarmConnection = nil
		end
	end
end)


local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local killAuraRunning = false
local killAuraConnection

OwO:Toggle("Kill Aura", false, function(Value)
    killAuraRunning = Value

    -- If turned ON
    if killAuraRunning then
        killAuraConnection = RunService.RenderStepped:Connect(function()
            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")

            if humanoid then
                for _, tool in ipairs(character:GetChildren()) do
                    if tool:IsA("Tool") then
                        -- Equip tool if not already equipped
                        if humanoid:FindFirstChildOfClass("Tool") ~= tool then
                            humanoid:EquipTool(tool)
                        end

                        -- Try to attack
                        pcall(function()
                            tool:Activate()
                        end)
                    end
                end
            end
        end)

    -- If turned OFF
    else
        if killAuraConnection then
            killAuraConnection:Disconnect()
            killAuraConnection = nil
        end
    end
end)



OwO1:Toggle("Walkspeed (Fixed)", false, function(Value)
if Value then
  getgenv().WalkSpeedValue = 46;

local Player = game:service'Players'.LocalPlayer;

Player.Character.Humanoid:GetPropertyChangedSignal'WalkSpeed':Connect(function()

Player.Character.Humanoid.WalkSpeed = getgenv().WalkSpeedValue;

end)

Player.Character.Humanoid.WalkSpeed = getgenv().WalkSpeedValue;
else
  getgenv().WalkSpeedValue = 34; --set your desired walkspeed here

local Player = game:service'Players'.LocalPlayer;

Player.Character.Humanoid:GetPropertyChangedSignal'WalkSpeed':Connect(function()

Player.Character.Humanoid.WalkSpeed = getgenv().WalkSpeedValue;

end)

Player.Character.Humanoid.WalkSpeed = getgenv().WalkSpeedValue;
end
end)


OwO1:Button("Fly (Works)", function()
loadstring(game:HttpGet(('https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt')))()
end)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer


OwO1:Button("Get All Tools", function()
    local itemsFolder = ReplicatedStorage:FindFirstChild("Items")
    if not itemsFolder then
        warn("Items folder not found in ReplicatedStorage!")
        return
    end

    for _, tool in pairs(itemsFolder:GetChildren()) do
        if tool:IsA("Tool") then
            -- Clone the tool and put it in player's backpack
            local toolClone = tool:Clone()
            toolClone.Parent = player.Backpack
        end
    end
end)


OwO:Label("Credits to LH", Color3.fromRGB(127, 143, 166))
local RunService = game:GetService("RunService")

local activeConnections = {}
local activeEspGuis = {}
local espCounts = {}
local brainrotOnly = false -- 🔁 Toggle control

-- Rarity -> Color
local rarityColors = {
	Common = Color3.fromRGB(180, 180, 180),
	Uncommon = Color3.fromRGB(100, 255, 100),
	Rare = Color3.fromRGB(100, 200, 255),
	Epic = Color3.fromRGB(180, 100, 255),
	Legendary = Color3.fromRGB(255, 100, 100),
	Mythic = Color3.fromRGB(255, 200, 0),
	["Brainrot God"] = Color3.fromRGB(255, 0, 255)
}

local function getColorForRarity(text)
	for rarity, color in pairs(rarityColors) do
		if string.lower(text) == string.lower(rarity) then
			return color
		end
	end
	return Color3.fromRGB(255, 255, 255)
end

local function createESP(rarityLabel)
	if not rarityLabel:IsA("TextLabel") or rarityLabel.Name ~= "Rarity" then return end

	if brainrotOnly and rarityLabel.Text ~= "Brainrot God" then
		return -- ❌ Don't create ESP if not "Brainrot God"
	end

	local billboard = rarityLabel:FindFirstAncestorWhichIsA("BillboardGui")
	if not billboard then return end

	local adornee = billboard.Parent
	if not adornee or not adornee:IsA("Attachment") then return end

	espCounts[adornee] = (espCounts[adornee] or 0) + 1
	local offsetIndex = espCounts[adornee]

	local espGui = Instance.new("BillboardGui")
	espGui.Name = "RarityESP"
	espGui.Adornee = adornee
	espGui.Size = UDim2.new(0, 200, 0, 50)
	espGui.AlwaysOnTop = true
	espGui.StudsOffset = Vector3.new(0, 2 + (offsetIndex - 1) * 0.8, 0)
	espGui.MaxDistance = 1e6
	espGui.Parent = adornee

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextStrokeColor3 = Color3.new(0, 0, 0)
	label.TextStrokeTransparency = 0.3
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Text = rarityLabel.Text
	label.TextColor3 = getColorForRarity(rarityLabel.Text)
	label.Parent = espGui

	local conn = RunService.RenderStepped:Connect(function()
		if rarityLabel and label then
			label.Text = rarityLabel.Text
			label.TextColor3 = getColorForRarity(rarityLabel.Text)
		end
	end)

	table.insert(activeConnections, conn)
	table.insert(activeEspGuis, espGui)
end

local function scanForRarityLabels()
	espCounts = {}
	for _, descendant in ipairs(workspace:GetDescendants()) do
		if descendant:IsA("TextLabel") and descendant.Name == "Rarity" then
			createESP(descendant)
		end
	end
end

local function clearAllESP()
	for _, conn in ipairs(activeConnections) do
		pcall(function() conn:Disconnect() end)
	end
	activeConnections = {}

	for _, gui in ipairs(activeEspGuis) do
		pcall(function() gui:Destroy() end)
	end
	activeEspGuis = {}

	espCounts = {}
end

-- 🌟 Main ESP Toggle
OwO1:Toggle("Pet Rarity ESP", false, function(Value)
	if Value then
		scanForRarityLabels()
	else
		clearAllESP()
	end
end)

-- 🧠 Filter Toggle: Only show "Brainrot God"
OwO1:Toggle("Esp Brainrot God", false, function(Value)
	brainrotOnly = Value
	clearAllESP()
	scanForRarityLabels()
end)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local espGuis = {} -- [mainPart] = { gui = BillboardGui, label = TextLabel }
local conn

OwO1:Toggle("Lock Base ESP (FIXED)", false, function(enabled)
    if enabled then
        local plotsFolder = workspace:FindFirstChild("Plots")
        if not plotsFolder then
            warn("No Plots folder found in workspace!")
            return
        end

        -- Create ESP for each plot Main part
        for _, plot in pairs(plotsFolder:GetChildren()) do
            local mainPart = plot:FindFirstChild("Purchases")
                and plot.Purchases:FindFirstChild("PlotBlock")
                and plot.Purchases.PlotBlock:FindFirstChild("Main")

            if mainPart then
                local espGui = Instance.new("BillboardGui")
                espGui.Name = "LockBaseESP"
                espGui.Adornee = mainPart
                espGui.Size = UDim2.new(0, 300, 0, 450)
                espGui.AlwaysOnTop = true
                espGui.MaxDistance = 1e6
                espGui.StudsOffset = Vector3.new(0, 10, 0)
                espGui.Parent = mainPart

                local espLabel = Instance.new("TextLabel")
                espLabel.Size = UDim2.new(1, 0, 1, 0)
                espLabel.BackgroundTransparency = 1
                espLabel.TextColor3 = Color3.fromRGB(0, 128, 255)
                espLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                espLabel.TextStrokeTransparency = 0
                espLabel.Font = Enum.Font.GothamBlack
                espLabel.TextScaled = true
                espLabel.TextWrapped = true
                espLabel.ZIndex = 10
                espLabel.Text = "Loading..."
                espLabel.Parent = espGui

                espGuis[mainPart] = {gui = espGui, label = espLabel, plot = plot}
            end
        end

        -- Update loop to refresh each ESP's text from its plot's RemainingTime label
        conn = RunService.RenderStepped:Connect(function()
            for mainPart, data in pairs(espGuis) do
                local remainingTimeLabel = data.plot:FindFirstChild("Purchases")
                    and data.plot.Purchases:FindFirstChild("PlotBlock")
                    and data.plot.Purchases.PlotBlock:FindFirstChild("Main")
                    and data.plot.Purchases.PlotBlock.Main:FindFirstChild("BillboardGui")
                    and data.plot.Purchases.PlotBlock.Main.BillboardGui:FindFirstChild("RemainingTime")

                if remainingTimeLabel and remainingTimeLabel:IsA("TextLabel") then
                    data.label.Text = remainingTimeLabel.Text
                else
                    data.label.Text = "No Time Found"
                end
            end
        end)

    else
        -- Cleanup all ESP GUIs and disconnect update loop
        if conn then
            conn:Disconnect()
            conn = nil
        end

        for mainPart, data in pairs(espGuis) do
            if data.gui and data.gui.Parent then
                data.gui:Destroy()
            end
        end
        espGuis = {}
    end
end)



OwO1:Button("Max Prompts Distance", function()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Override settings for all prompts
local function overridePrompt(prompt)
    if prompt:IsA("ProximityPrompt") then
        prompt.MaxActivationDistance = math.huge
        prompt.RequiresLineOfSight = false
    end
end

-- Apply to all existing prompts
for _, obj in pairs(workspace:GetDescendants()) do
    overridePrompt(obj)
end

-- Apply to future prompts
workspace.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("ProximityPrompt") then
        overridePrompt(descendant)
    end
end)

-- Listen for E key press
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.E then
        local closestPrompt = nil
        local closestDistance = math.huge

        for _, prompt in pairs(workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                local parentPart = prompt.Parent:IsA("BasePart") and prompt.Parent or prompt.Parent:FindFirstChildWhichIsA("BasePart")
                if parentPart then
                    local dist = (parentPart.Position - HumanoidRootPart.Position).Magnitude
                    if dist < closestDistance then
                        closestDistance = dist
                        closestPrompt = prompt
                    end
                end
            end
        end

        if closestPrompt then
            fireproximityprompt(closestPrompt, 1)
        end
    end
end)

end)

OwO1:Button("Instant Prompt", function()
-- Instant apply to all existing
for _, v in ipairs(workspace:GetDescendants()) do
    if v:IsA("ProximityPrompt") then
        v.HoldDuration = 0
    end
end

-- Watch for new ones added later
workspace.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("ProximityPrompt") then
        descendant.HoldDuration = 0
    end
end)

end)

-- Connect toggle
OwO1:Toggle("Auto Rebirth", false, function(Value)
 a = Value
        while a do task.wait(5)
        pcall(function()
game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Net"):WaitForChild("RF/Rebirth/RequestRebirth"):InvokeServer()


end)
end
end)

