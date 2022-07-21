--[[


░░░░░██╗░█████╗░██╗██╗░░░░░██████╗░██████╗░███████╗░█████╗░██╗░░██╗
░░░░░██║██╔══██╗██║██║░░░░░██╔══██╗██╔══██╗██╔════╝██╔══██╗██║░██╔╝
░░░░░██║███████║██║██║░░░░░██████╦╝██████╔╝█████╗░░███████║█████═╝░
██╗░░██║██╔══██║██║██║░░░░░██╔══██╗██╔══██╗██╔══╝░░██╔══██║██╔═██╗░
╚█████╔╝██║░░██║██║███████╗██████╦╝██║░░██║███████╗██║░░██║██║░╚██╗
░╚════╝░╚═╝░░╚═╝╚═╝╚══════╝╚═════╝░╚═╝░░╚═╝╚══════╝╚═╝░░╚═╝╚═╝░░╚═╝

Private exploit script made by iamtryingtofindname#9879
Uses Artemis UI Library made by iamtryingtofindname#9879
Uses Helios file saving system made by iamtryingtofindname#9879
Part of the Kratos script library

]]--

local VERSION = "1.2.0"

if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- KRATOS SYSTEMS
local Artemis = loadstring(game:HttpGet("https://raw.githubusercontent.com/iamtryingtofindname/Kratos/main/Artemis/main.lua"))()
local Helios = loadstring(game:HttpGet("https://raw.githubusercontent.com/iamtryingtofindname/Kratos/main/Helios/main.lua"))()
local PlayerData = loadstring(game:HttpGet("https://raw.githubusercontent.com/iamtryingtofindname/Kratos/main/players.lua"))()

if not (Artemis and Helios and PlayerData) then
    error("Failed to load all Kratos systems")
end

-- SERVICES
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")
local Run = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TeleportService")
local VU = game:GetService("VirtualUser")
local Core = game:GetService("CoreGui")
local VU = game:GetService("VirtualUser")

-- GENERAL VARIABLES
local player = Players.LocalPlayer
local VehiclesFolder = workspace:WaitForChild("Vehicles")

-- VARIABLES
local ModuleUI = require(RS.Module.UI)
local SettingsModule = require(RS.Resource.Settings)

-- CONSTANTS
local DEFAULT_RANK = "User"
local DEFAULT_RANK_COLOR = Color3.new(0,1,0)
local GAME_THUMBNAIL_ID = 10196274249

-- SCRIPT VARIABLES
local CharacterFly = false
local CarFly = false

do -- rawget mod
    local old_rawget = rawget
    rawget = function(tbl,...)
        local returnValue = tbl
        for _,v in ipairs({...}) do
            returnValue = old_rawget(returnValue,v)
        end
        return returnValue
    end
end

-- HELIOS VARIABLES
local data,oldMetadata
local configs = {
    ["NoPromptWait"] = false;
    ["KeycardDoorBypass"] = false;
    ["OpenAllDoorsLoop"] = false;
    ["CarEngineSpeed"] = 0;
    ["CarSuspensionHeight"] = 0;
    ["TirePopBypass"] = false;
    ["CarTurnSpeed"] = 0;
    ["CarBrakesSpeed"] = 0;
    ["NoCellTime"] = false;
    ["AntiTaze"] = false;
    ["ToggleUI"] = Enum.KeyCode.LeftControl;
    ["CharacterFlyEnabled"] = false;
    ["CharacterFlyBind"] = Enum.KeyCode.X;
    ["CarFlyEnabled"] = false;
    ["CarFlyBind"] = Enum.KeyCode.Z;
    ["CharacterFlySpeed"] = 35;
    ["CarFlySpeed"] = 350;
}

local FILE_TREE = {
    ["configs.json"] = {}
}
local metadata = {
    ["inBeta"] = true;
    ["keybindUpdate_7/21/22_12:05AM"] = true;
}

-- PLAYER DATA CHECK
local Rank
local RankColor
do
    local userId = player.UserId

    if PlayerData.WhitelistEnabled then
        if not table.find(PlayerData.Whitelist,userId) then
            player:Kick("You are not whitelisted on Kratos!")
            error("Player is not whitelisted")
            task.wait(9e9)
        end
    else
        if table.find(PlayerData.Blacklist,userId) then
            player:Kick("You are blacklisted from use of Kratos!")
            task.wait(9e9)
        end
    end

    for rankName,v in pairs(PlayerData.Ranks) do
        if table.find(v.Users,userId) then
            Rank = rankName
            RankColor = v.Color
            break
        end
    end

    if Rank == nil then
        Rank = DEFAULT_RANK
        RankColor = DEFAULT_RANK_COLOR
    end
end

-- SYSTEMS INIT
local UI = Artemis.new("Kratos",{
    ["Version"] = VERSION;
})

UI:StartLoading({
    ["Title"] = Rank;
    ["ThumbnailId"] = GAME_THUMBNAIL_ID;
    ["GameName"] = "Jailbreak";
    ["TitleTextColor"] = RankColor;
})

data,oldMetadata = Helios:Init(game.PlaceId,FILE_TREE,metadata)
if typeof(data["configs.json"])=="table" then
    configs = Helios:reconcile(data["configs.json"],configs)
end

-- METADATA INIT
do
    local function wipe()
        delfolder(Helios._place_directory)
    end
    if oldMetadata["keybindUpdate_7/21/22_12:05AM"] ~= true then
        wipe()
    end
end

local Kratos = {}

-- KRATOS FUNCTIONS
do
    function Kratos:Wait()
        return Run.RenderStepped:Wait()
    end

    function Kratos:Print(...)
        print("KRATOS:", ...)
    end

    function Kratos:Warn(...)
        warn("KRATOS:", ...)
    end

    function Kratos:GetLocalCharacter()
        local c = player.Character
    
        if c and c:IsDescendantOf(workspace) and c:FindFirstChild("Head") and c.PrimaryPart and c:FindFirstChild("Humanoid") then
            if c:FindFirstChild("Humanoid") and c:FindFirstChild("Humanoid").Health > 0 then
                return c
            else
                return false
            end
        end
    end

    function Kratos:GetLocalPlayerVehicle()
        for _,v in pairs(VehiclesFolder:GetChildren()) do
            if v:FindFirstChild("Seat") and v.Seat:FindFirstChild("PlayerName") and v:FindFirstChild("Make") and v:FindFirstChild("Engine") then
                if v.Seat.PlayerName.Value == player.Name then
                    return v
                end
            end
        end
    end

    function Kratos:Init()
        Kratos.MainScript = player:WaitForChild("PlayerScripts",60):WaitForChild("LocalScript",60)
        Kratos.Doors = {}
        Kratos.Backups = {}
        for i, v in pairs(getgc(true)) do
            if type(v) == "table" then
                if rawget(v, "Event") and rawget(v, "Fireworks") then
                    Kratos.em = v.em
                    Kratos.GetVehiclePacket = v.GetVehiclePacket
                    Kratos.Fireworks = v.Fireworks
                    Kratos.Network = v.Event
                elseif rawget(v, "State") and rawget(v, "OpenFun") then
                    table.insert(Kratos.Doors, v)
                elseif rawget(v, "Ragdoll") then
                    Kratos.Backups.Ragdoll = v.Ragdoll
                end
            elseif type(v) == "function" then
                if getfenv(v).script == Kratos.MainScript then
                    local con = getconstants(v)
                    if table.find(con, "SequenceRequireState") then
                        Kratos.OpenDoor = v
                    end
                        --[[
                    elseif table.find(con, "Play") and table.find(con, "Source") and table.find(con, "FireServer") then
                        Kratos.PlaySound = v
                    elseif table.find(con, "PlusCash") then
                        Kratos.PlusCash = v
                    elseif table.find(con, "Punch") then
                        Kratos.GuiFunc = v
                    end
                    ]]--
                end
            end
        end

        local oldFireServer
        oldFireServer = hookfunction(Instance.new('RemoteEvent').FireServer, newcclosure(function(Event, ...)
            if not checkcaller() then
                local Args = {...}

            end

            return oldFireServer(Event, ...)
        end))

        coroutine.resume(coroutine.create(function()
            while Kratos:Wait() do
                data["configs.json"] = Helios:encode(configs)
                Helios:updateWithDirectory(data)
                task.wait(1)
            end
        end))
    end
end

Kratos:Init()

-- NOTIFICATION
local notify do
    local Notification = {}
    do -- notif module
        -- Decompiled with the Synapse X Luau decompiler.
        local u1 = {};
        local u2 = false;
        local v2 = {};
        v2.__index = v2;
        local u4 = require(RS.Game.GameUtil);
        local u5 = require(RS.Resource.Settings);
        local original = nil
        function v2.Init()
            --local l__em__3 = p1.em;
            original = player:WaitForChild("PlayerGui"):WaitForChild("NotificationGui",45)
            local l__NotificationGui__4 = original:Clone();
            l__NotificationGui__4.Parent = Core;
            l__NotificationGui__4.DisplayOrder = 1;
            v2.Gui = l__NotificationGui__4;
            local v5 = Instance.new("Sound");
            v5.SoundId = ("rbxassetid://%d"):format(215658476);
            v5.Parent = l__NotificationGui__4;
            v2.TypeWriterSound = v5;
            u4.OnTeamChanged:Connect(function(p2)
                v2.SetColor(u5.TeamColor[p2]);
            end);
            v2.SetColor(u5.TeamColor[u4.Team]);
        end;
        function v2.SetColor(p3)
            v2.Gui.ContainerNotification.ImageColor3 = p3;
        end;
        local u6 = nil;
        local u7 = require(RS.Std.Maid);
        local function u8()
            if not (#u1 > 0) then
                u2 = false;
                return;
            end;
            u2 = true;
            table.remove(u1, 1):Hook();
        end;
        function v2.new(p4)
            assert(p4 ~= nil);
            assert(p4.Text ~= nil);
            if p4.Text == u6 then
                return;
            end;
            local v6 = u1[1];
            if v6 and v6.Text == p4.Text then
                return;
            end;
            if p4.Duration == nil then
                p4.Duration = math.min(5, 4 * utf8.len(p4.Text) / 50);
            end;
            assert(p4.Duration ~= nil);
            local v7 = {};
            setmetatable(v7, v2);
            v7.Maid = u7.new();
            v7.Text = p4.Text;
            v7.Duration = p4.Duration;
            table.insert(u1, v7);
            if u2 == false then
                u8();
            end;
            return v7;
        end;
        local u9 = require(RS.Game.TypeWrite);
        local u10 = require(RS.Std.Audio);
        function v2.Hook(p5)
            pcall(function()
                local l__Gui__8 = v2.Gui;
                l__Gui__8.Enabled = true;
                u6 = p5.Text;
                original.ContainerNotification.Visible = false
                local u11 = 1;
                p5.Maid:GiveTask(u9(p5.Text, function(p6)
                    if p5.Maid == nil then
                        return false;
                    end;
                    if u11 == 1 then
                        v2.TypeWriterSound:Play();
                    end;
                    u11 = u11 % 3 + 1;
                    l__Gui__8.ContainerNotification.Message.Text = p6;
                end, 50));
                u10.ObjectLocal(l__Gui__8, 700153902, {
                    Volume = 0.25
                });
                task.delay(p5.Duration, function()
                    p5:Destroy();
                    original.ContainerNotification.Visible = true
                end);
            end)
        end;
        function v2.Destroy(p7)
            if p7.Maid ~= nil then
                v2.Gui.Enabled = false;
                p7.Maid:Destroy();
                p7.Maid = nil;
                u6 = nil;
                u8();
            end;
        end;

        pcall(v2.Init)

        Notification = v2
    end

    function notify(text,duration)
        text = text or "nil"
        duration = duration or math.min(5, 4 * utf8.len(text) / 50);

        pcall(function()
            local e = Notification.new({
                ["Text"] = text;
                ["Duration"] = duration;
            })
            
            Notification.Hook(e)
        end)
    end
end

-- ANTI-IDLE KICK
do
    local clickLocation = Vector2.new()
    
    player.Idled:Connect(function()
        VU:CaptureController()
        VU:ClickButton2(clickLocation)
    end)
    
end

-- NO E WAIT
do
    local cache = {}
    coroutine.resume(coroutine.create(function()
        while Kratos:Wait() do
            for _,v in pairs(rawget(ModuleUI,"CircleAction","Specs")) do
                local part = rawget(v,"Part")
                if part then
                    if configs["NoPromptWait"] then
                        cache[part] = cache[part] or v.Duration
                        rawset(v,"Duration",0)
                    else
                        rawset(v,"Duration",cache[part] or v.Duration)
                    end
                end
            end
        end
    end))
end

-- KEYCARD DOOR BYPASS
do
    local playerUtils = require(RS.Game.PlayerUtils)
    local oldHasKey = playerUtils.hasKey
    rawset(playerUtils,"hasKey",function(...)
        if configs["KeycardDoorBypass"] then
            return true
        else
            return oldHasKey(...)
        end
    end)
end

-- OPEN ALL DOORS (ONCE)
local openAllDoors do
    function openAllDoors()
        for i,v in next, Kratos.Doors do 
            Kratos.OpenDoor(v)
        end
    end
end

-- OPEN ALL DOORS (LOOP)
do
    local OPEN_ALL_DOORS_LOOP = 0.6
    local lastOpen = 0
    Run.RenderStepped:Connect(function()
        if configs["OpenAllDoorsLoop"] then
            local now = os.clock()
            if now-lastOpen >= OPEN_ALL_DOORS_LOOP then
                lastOpen = now
                openAllDoors()
            end
        end
    end)
end

do -- INF NITRO
    for _,v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "Nitro") then
            coroutine.resume(coroutine.create(function()
                while true do
                    if configs["InfNitro"] then
                        rawset(v,"Nitro",250)
                    end
                    Kratos:Wait()
                end
            end))
        end
    end
end

-- VEHICLE MODS
do
    local aChassis = require(game:GetService("ReplicatedStorage").Module.AlexChassis)

    local old_update = rawget(aChassis,"Update")

    rawset(aChassis,"Update",function(...)
        local args = {...}
        local vehicleData = args[1]

        rawset(vehicleData,"GarageEngineSpeed",configs["CarEngineSpeed"])
        rawset(vehicleData,"Height",configs["CarSuspensionHeight"]+4)
        rawset(vehicleData,"TurnSpeed",configs["CarTurnSpeed"]+1.4)
        rawset(vehicleData,"GarageBrakes",configs["CarBrakesSpeed"])

        if configs["TirePopBypass"] then
            rawset(vehicleData,"AreTiresPopped",false)
            rawset(vehicleData,"TirePopProportion",0)
            rawset(vehicleData,"TirePopDuration",0)
            rawset(vehicleData,"TireHealth",1)
        end

        args[1] = vehicleData

        return old_update(unpack(args))
    end)
end

-- NO CELL TIME/ANTI TAZE
do
    Run.RenderStepped:Connect(function()
        local timeTable = rawget(SettingsModule,"Time")
        rawset(timeTable,"Cell",configs["NoCellTime"] and 0 or 20)
        rawset(timeTable,"Stunned",configs["AntiTaze"] and 0 or 2.5)
    end)
end

-- CHARACTER FLY
do
    local core

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
        core.Massless = true
    
        core.Weld.Part0 = core
        core.Weld.Part1 = char.PrimaryPart
    
        core.BodyPosition.MaxForce = Vector3.new(400000,400000,400000)
        core.BodyPosition.D = 4000
        core.BodyPosition.P = 70000
    
        core.BodyForce.Force = Vector3.new(0, char.PrimaryPart.AssemblyMass * workspace.Gravity, 0);
    
        core.Parent = workspace
    end

    local keysDown = {}
    
    Run.RenderStepped:Connect(function()
        local char = Kratos:GetLocalCharacter()
        if char and char.Humanoid.Sit == false and CharacterFly and configs["CharacterFlyEnabled"] and workspace.CurrentCamera then
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
            if keysDown[Enum.KeyCode.Space] then
                direction = direction+Vector3.new(0,1,0)
            end
    
            if math.abs(direction.X)+math.abs(direction.Y)+math.abs(direction.Z)>1 then
                local sq2 = math.sqrt(2)/2
                direction = direction*sq2
            end
    
            direction = Vector3.new(direction.X,direction.Y*0.75,direction.Z)
    
            repairCore(char)
            local current = char.PrimaryPart.Position
            local body = core.BodyPosition
            local lv = workspace.CurrentCamera.CFrame.LookVector
            local goal = CFrame.lookAt(Vector3.zero,lv)+current
            goal = goal*CFrame.new(direction*configs["CharacterFlySpeed"])
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
        end
    end)

    UIS.InputEnded:Connect(function(input,gpe)
        if input.UserInputType == Enum.UserInputType.Keyboard and not gpe then
            keysDown[input.KeyCode] = false
        end
    end)

    player.CharacterRemoving:Connect(function()
        pcall(function()
            core:Destroy()
        end)
        core = nil
    end)
end

-- CAR FLY
do
    local core

    local velocity = "velocity"
    local gyro = "gyro"

    local function repairCore(car)
        if car.Engine:FindFirstChild(velocity)==nil then
            Instance.new("BodyVelocity").Parent = car.Engine
            car.Engine.BodyVelocity.Name = velocity
        end
        if car.Engine:FindFirstChild(gyro)==nil then
            Instance.new("BodyGyro").Parent = car.Engine
            car.Engine.BodyGyro.Name = gyro
        end

        car.Engine:FindFirstChild(velocity).MaxForce = Vector3.new(9e9,9e9,9e9)
        car.Engine:FindFirstChild(velocity).P = 1250

        car.Engine:FindFirstChild(gyro).MaxTorque = Vector3.new(9e9,9e9,9e9)
        car.Engine:FindFirstChild(gyro).D = 500
        car.Engine:FindFirstChild(gyro).P = 90000
    end

    local keysDown = {}
--[[
    local lastCFrame = nil
    workspace.CurrentCamera:GetPropertyChangedSignal("CFrame"):Connect(function()
        if Kratos:GetLocalPlayerVehicle() then
            if workspace.CurrentCamera.CFrame ~= lastCFrame and not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                workspace.CurrentCamera.CFrame = lastCFrame
            else
                lastCFrame = workspace.CurrentCamera.CFrame
            end
        end
    end)
]]--
    Run.RenderStepped:Connect(function()
        local char = Kratos:GetLocalCharacter()
        local car = Kratos:GetLocalPlayerVehicle()
        if char and car and CarFly and configs["CarFlyEnabled"] and workspace.CurrentCamera then
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

            if math.abs(direction.X)+math.abs(direction.Z)>1 then
                local sq2 = math.sqrt(2)/2
                direction = direction*sq2
            end

            repairCore(car)

            local camCFrame = workspace.CurrentCamera.CFrame
            local engCFrame = CFrame.lookAt(Vector3.zero,camCFrame.LookVector)+car.Engine.Position
            local goal = CFrame.new(Vector3.zero,engCFrame.LookVector)*(direction*configs["CarFlySpeed"])
            car.Engine:FindFirstChild(velocity).Velocity = goal
            car.Engine:FindFirstChild(gyro).CFrame = camCFrame
        else
            pcall(function()
                core:Destroy()
            end)
            core = nil
        end
    end)

    UIS.InputBegan:Connect(function(input,gpe)
        if input.UserInputType == Enum.UserInputType.Keyboard and not gpe then
            keysDown[input.KeyCode] = true
        end
    end)

    UIS.InputEnded:Connect(function(input,gpe)
        if input.UserInputType == Enum.UserInputType.Keyboard and not gpe then
            keysDown[input.KeyCode] = false
        end
    end)

    player.CharacterRemoving:Connect(function()
        pcall(function()
            core:Destroy()
        end)
        core = nil
    end)
end

-- UI INITIATION
do
    -- two underscores (__) at beggining of ui objects to differ from normal naming conventions

    -- PAGES
    do -- Player Page
        local __player = UI:CreatePage("Player",10288655901)

        local __character = __player:CreateSection("Character")
        local __utilities = __player:CreateSection("Utilities")

        __character:CreateToggle("Character Fly",configs["CharacterFlyEnabled"],function(newValue)
            notify("Character fly binded to "..configs["CharacterFlyBind"].Name)
            configs["CharacterFlyEnabled"] = newValue
            CharacterFly = false
        end)

        __utilities:CreateSlider("Character Fly Speed",5,80,configs["CharacterFlySpeed"],function(newValue)
            configs["CharacterFlySpeed"] = newValue
        end,true,0)

        __utilities:CreateToggle("No E Wait",configs["NoPromptWait"],function(newValue)
            configs["NoPromptWait"] = newValue;
        end)

        __utilities:CreateToggle("Keycard Door Bypass",configs["KeycardDoorBypass"],function(newValue)
            configs["KeycardDoorBypass"] = newValue;
        end)

        __utilities:CreateButton("Open All Doors",openAllDoors)

        __utilities:CreateToggle("Loop Open All Doors",configs["OpenAllDoorsLoop"],function(newValue)
            configs["OpenAllDoorsLoop"] = newValue;
        end)

        __utilities:CreateToggle("No Cell Time",configs["NoCellTime"],function(newValue)
            configs["NoCellTime"] = newValue;
        end)

        __utilities:CreateToggle("Anti-Taze",configs["AntiTaze"],function(newValue)
            configs["AntiTaze"] = newValue;
        end)
    end
    do -- Vehicle Page
        local __vehicle = UI:CreatePage("Vehicle",10253587852)

        local __utilities = __vehicle:CreateSection("Utilities")
        local __carMods = __vehicle:CreateSection("Car Mods")

        __utilities:CreateToggle("Inf Nitro",configs["InfNitro"],function(newValue)
            configs["InfNitro"] = newValue
        end)

        __utilities:CreateToggle("Car Fly",configs["CarFlyEnabled"],function(newValue)
            notify("Car fly binded to "..configs["CarFlyBind"].Name)
            configs["CarFlyEnabled"] = newValue
            CarFly = false
        end)

        __utilities:CreateSlider("Car Fly Speed",5,500,configs["CarFlySpeed"],function(newValue)
            configs["CarFlySpeed"] = newValue
        end,true,0)

        __carMods:CreateSlider("Engine Speed",0,120,configs["CarEngineSpeed"],function(newValue)
            configs["CarEngineSpeed"] = newValue
        end,true,0)

        __carMods:CreateSlider("Turn Speed",0,60,configs["CarTurnSpeed"],function(newValue)
            configs["CarTurnSpeed"] = newValue/10
        end,true,0)

        __carMods:CreateSlider("Suspension Height",0,100,configs["CarSuspensionHeight"],function(newValue)
            configs["CarSuspensionHeight"] = newValue
        end,true,0)

        __carMods:CreateSlider("Brakes Speed",0,120,configs["CarBrakesSpeed"],function(newValue)
            configs["CarBrakesSpeed"] = newValue
        end,true,0)

        __carMods:CreateToggle("Tire Pop Bypass",configs["TirePopBypass"],function(newValue)
            configs["TirePopBypass"] = newValue
        end,true)
    end
    do -- Keybinds Page
        local __vehicle = UI:CreatePage("Keybinds",10298464250)

        local __ui = __vehicle:CreateSection("UI")
        local __other = __vehicle:CreateSection("Other")

        __ui:CreateKeybind("Toggle UI",configs["ToggleUI"],function(newValue)
            configs["ToggleUI"] = newValue
        end)

        __other:CreateKeybind("Character Fly Bind",configs["CharacterFlyBind"],function(newValue)
            configs["CharacterFlyBind"] = newValue
        end)

        __other:CreateKeybind("Car Fly Bind",configs["CarFlyBind"],function(newValue)
            configs["CarFlyBind"] = newValue
        end)

        -- Input
        UIS.InputBegan:Connect(function(input,gpe)
            if input.UserInputType == Enum.UserInputType.Keyboard and not gpe then
                if input.KeyCode == configs["ToggleUI"] then
                    UI:Toggle()
                elseif input.KeyCode == configs["CharacterFlyBind"] then
                    CharacterFly = not CharacterFly
                elseif input.KeyCode == configs["CarFlyBind"] then
                    CarFly = not CarFly
                end
            end
        end)
    end
end

-- DONE LOADING
UI:StopLoading()
print("Kratos v"..VERSION.." initiated")
