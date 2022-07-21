local Players = game:GetService("Players")
local Run = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local camera = workspace.CurrentCamera

local player = Players.LocalPlayer

local core
local speed = 20

local function getLocalCharacter()
    local c = player.Character

    if c and c:IsDescendantOf(workspace) and c:FindFirstChild("Head") and c.PrimaryPart and c:FindFirstChild("Humanoid") then
        if c:FindFirstChild("Humanoid") and c:FindFirstChild("Humanoid").Health > 0 then
            return c
        else
            return false
        end
    end
end

local function repairCore(char)
    if core == nil then
        core = Instance.new("Part")
        Instance.new("Weld").Parent = core
        Instance.new("BodyPosition").Parent = core
        Instance.new("BodyForce").Parent = core
    end
    core.Size = Vector3.new(2,5.6,2)
    core.Anchored = false
    core.CanCollide = true
    core.Transparency = 1
    core.CanTouch = false
    core.CanQuery = false

    core.Weld.Part0 = core
    core.Weld.Part1 = char.PrimaryPart

    core.BodyPosition.MaxForce = Vector3.new(400000,400000,400000)
    core.BodyPosition.D = 4000
    core.BodyPosition.P = 70000

    core.BodyForce.Force = Vector3.new(0, char.PrimaryPart.AssemblyMass * workspace.Gravity, 0);

    core.Parent = workspace
end

local CharacterFly = true
local keysDown = {}

Run.RenderStepped:Connect(function()
    local char = getLocalCharacter()
    if char and CharacterFly and workspace.CurrentCamera then
        local direction = Vector3.new()

        if keysDown[Enum.KeyCode.W] then
            direction = direction+Vector3.new(0,0,-1)
        end
        if keysDown[Enum.KeyCode.S] then
            direction = direction+Vector3.new(0,0,1)
        end
        if keysDown[Enum.KeyCode.A] then
            direction = direction+Vector3.new(-1,0,0)
        end
        if keysDown[Enum.KeyCode.D] then
            direction = direction+Vector3.new(1,0,0)
        end

        if direction.X ~= 0 and direction.Z ~= 0 then
            local sqrt2 = math.sqrt(2)
            direction = Vector3.new(direction.X*sqrt2,direction.Y,direction.Z*sqrt2)
        end

        repairCore(char)
        local current = char.PrimaryPart.Position
        local body = core.BodyPosition
        local lv = workspace.CurrentCamera.CFrame.LookVector
        local goal = CFrame.lookAt(Vector3.zero,lv)+current
        goal = goal*CFrame.new(direction*speed)
        char.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
        body.Position = goal.Position
    else
        pcall(function()
            core:Destroy()
        end)
        pcall(function()
            char.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,true)
        end)
        core = nil
    end
end)

UIS.InputBegan:Connect(function(input,gpe)
    if input.UserInputType == Enum.UserInputType.Keyboard and not gpe then
        keysDown[input.KeyCode] = true
        if input.KeyCode == Enum.KeyCode.X then
            CharacterFly = not CharacterFly
        end
    end
end)

UIS.InputEnded:Connect(function(input,gpe)
    if input.UserInputType == Enum.UserInputType.Keyboard and not gpe then
        keysDown[input.KeyCode] = false
    end
end)

player.CharacterRemoving:Connect(function()
    CharacterFly = false
    pcall(function()
        core:Destroy()
    end)
    core = nil
end)
