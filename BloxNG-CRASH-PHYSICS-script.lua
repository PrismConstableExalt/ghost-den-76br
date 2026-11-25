-- Source: rscripts.net / speed car BloxNG (keyless, BloxNG [CRASH PHYSICS] placeId 83784149502814)
-- Author: coolguy23421 | published 2026-11-22 | unmodified, full Lua

if not game:IsLoaded() then game.Loaded:Wait() end

if getgenv and getgenv().SpeedCarCleanup then
    pcall(getgenv().SpeedCarCleanup)
end

local cloneref = cloneref or function(o) return o end
local gethui = gethui or function() return game:GetService("CoreGui") end

local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local TweenService = cloneref(game:GetService("TweenService"))
local Workspace = cloneref(game:GetService("Workspace"))

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Vec3 = Vector3.new
local math_sqrt = math.sqrt
local math_clamp = math.clamp

local Config = {
    Enabled = true,
    Speed = 1,
    KeyToHide = Enum.KeyCode.RightShift
}

local connections = {}
local charConnections = {}
local isWPressed = false
local isSPressed = false
local cachedTarget = nil
local cachedRef = nil
local isInVehicle = false

local function resetVehicle()
    cachedTarget = nil
    cachedRef = nil
    isInVehicle = false
end

local function setVehicle(target, refPart)
    cachedTarget = target
    cachedRef = refPart
    isInVehicle = (target ~= nil and refPart ~= nil)
end

local function onCharacter(char)
    for _, c in ipairs(charConnections) do c:Disconnect() end
    table.clear(charConnections)

    resetVehicle()

    local hum = char:WaitForChild("Humanoid", 4)
    local root = char:WaitForChild("HumanoidRootPart", 4)

    if hum then
        table.insert(charConnections, hum.Seated:Connect(function(active, currentSeat)
            if active and currentSeat then
                setVehicle(currentSeat.AssemblyRootPart or currentSeat, currentSeat)
            else
                resetVehicle()
            end
        end))

        if hum.SeatPart then
            setVehicle(hum.SeatPart.AssemblyRootPart or hum.SeatPart, hum.SeatPart)
            return
        end
    end

    if root and root.AssemblyRootPart and root.AssemblyRootPart ~= root then
        setVehicle(root.AssemblyRootPart, root)
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = string.format("UI_%08X", math.random(0, 0xFFFFFFF))
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = gethui() end)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 150)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner", MainFrame)
Corner.CornerRadius = UDim.new(0, 8)

local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Thickness = 1.5
Stroke.Color = Color3.fromRGB(45, 45, 45)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 32)
Title.BackgroundTransparency = 1
Title.Text = "TITAN SPEED BOOST"
Title.TextColor3 = Color3.fromRGB(255, 170, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13

local ToggleBtn = Instance.new("TextButton", MainFrame)
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 34)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.28, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
ToggleBtn.Text = "SPEED STATUS: ON"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 12
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 5)

local SpeedBox = Instance.new("TextBox", MainFrame)
SpeedBox.Size = UDim2.new(0.4, 0, 0, 28)
SpeedBox.Position = UDim2.new(0.3, 0, 0.65, 0)
SpeedBox.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
SpeedBox.Text = tostring(Config.Speed)
SpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBox.Font = Enum.Font.GothamBold
SpeedBox.TextSize = 13
Instance.new("UICorner", SpeedBox).CornerRadius = UDim.new(0, 4)

local COLOR_ON = Color3.fromRGB(0, 150, 80)
local COLOR_OFF = Color3.fromRGB(150, 30, 30)

table.insert(connections, ToggleBtn.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    ToggleBtn.Text = Config.Enabled and "SPEED STATUS: ON" or "SPEED STATUS: OFF"
    TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = Config.Enabled and COLOR_ON or COLOR_OFF
    }):Play()
end))

table.insert(connections, SpeedBox.FocusLost:Connect(function()
    local val = tonumber(SpeedBox.Text)
    if val then Config.Speed = val end
    SpeedBox.Text = tostring(Config.Speed)
end))

table.insert(connections, UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    local code = input.KeyCode
    if code == Config.KeyToHide then
        MainFrame.Visible = not MainFrame.Visible
    elseif code == Enum.KeyCode.W then
        isWPressed = true
    elseif code == Enum.KeyCode.S then
        isSPressed = true
    end
end))

table.insert(connections, UserInputService.InputEnded:Connect(function(input, gp)
    local code = input.KeyCode
    if code == Enum.KeyCode.W then
        isWPressed = false
    elseif code == Enum.KeyCode.S then
        isSPressed = false
    end
end))

table.insert(connections, RunService.Heartbeat:Connect(function(dt)
    if not isWPressed and not isSPressed then return end
    if not Config.Enabled or not isInVehicle or not cachedTarget or cachedTarget.Anchored then return end

    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum or not hum.SeatPart then
        resetVehicle()
        return
    end

    local look = cachedRef.CFrame.LookVector
    local lx, lz = look.X, look.Z
    local magSq = lx * lx + lz * lz

    if magSq > 0.0001 then
        local invMag = 1 / math_sqrt(magSq)
        local fx = lx * invMag
        local fz = lz * invMag
        local mult = isWPressed and 1 or -1
        local spd = Config.Speed

        local mass = math_clamp(cachedTarget.AssemblyMass, 50, 15000)
        local force = spd * mass * dt * 50 * mult
        cachedTarget:ApplyImpulse(Vec3(fx * force, 0, fz * force))

        local vel = cachedTarget.AssemblyLinearVelocity
        local addSpeed = spd * 0.5 * mult
        cachedTarget.AssemblyLinearVelocity = Vec3(vel.X + (fx * addSpeed), vel.Y, vel.Z + (fz * addSpeed))
    end
end))

if LP.Character then
    task.spawn(onCharacter, LP.Character)
end
table.insert(connections, LP.CharacterAdded:Connect(onCharacter))

if getgenv then
    getgenv().SpeedCarCleanup = function()
        for _, c in ipairs(connections) do
            if c and c.Connected then c:Disconnect() end
        end
        for _, c in ipairs(charConnections) do
            if c and c.Connected then c:Disconnect() end
        end
        table.clear(connections)
        table.clear(charConnections)
        resetVehicle()

        if ScreenGui then ScreenGui:Destroy() end
    end
end