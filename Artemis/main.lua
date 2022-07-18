-- SERVICES
local Players = game:GetService("Players")
local TS = game:GetService("TweenService")
local Run = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Core = game:GetService("CoreGui")
local MP = game:GetService("MarketplaceService")

-- VARIABLES
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- PRIVATE VARIABLES

-- CLASSES
local library = {}
local page = {}
local section = {}

library.__index = library
page.__index = page
section.__index = section

-- UTILITY
local utility = {}

do
    function utility:Wait()
        return Run.RenderStepped:Wait()
    end

    function utility:Disconnect(connection)
        pcall(function()
            connection:Disconnect()
        end)
    end

    function utility:GetPlayerThumbnail(UserId)
        return "rbxthumb://type=AvatarHeadShot&id="..UserId.."&w=420&h=420"
    end

    function utility:GetGameThumbnail(placeId) -- use in studio
        local thumbnailId = MP:GetProductInfo(placeId).IconImageAssetId
        return "rbxassetid://"..thumbnailId
    end

    function utility:Tween(object,properties,duration,...)
        assert(object and properties and duration,"Missing arguments for utility::Tween")
        local tween = TS:Create(object,TweenInfo.new(duration,...),properties)
        tween:Play()
        return tween
    end

    function utility:InitDragging(frame,button)
        button = button or frame

        assert(button and frame,"Need a frame in order to start dragging")

        -- dragging
        local _dragging = false
        local _dragging_offset

        local inputBegan = button.MouseButton1Down:Connect(function(x,y)
            _dragging = true
            _dragging_offset = Vector2.new(x,y)-frame.AbsolutePosition
        end)

        local inputEnded = button.MouseButton1Up:Connect(function()
            _dragging = false
            _dragging_offset = nil
        end)

        local updateEvent = Run.RenderStepped:Connect(function()
            if frame.Visible == false then
                _dragging = false
                _dragging_offset = nil
            end
            if _dragging and _dragging_offset then
                frame.Position = UDim2.fromOffset(mouse.X-_dragging_offset.X,mouse.Y-_dragging_offset.Y)
            end
        end)

        return {inputBegan,inputEnded,updateEvent}
    end

    function utility:HandleButton(button,callback)
        local startSize = UDim2.fromScale(1,1)
        local goalSize = UDim2.fromScale(0.8,0.8)
        local oldTween
        local duration = 0.15
        local isPressing = false

        local function down()
            pcall(function()
                oldTween:Cancel()
            end)
            button.Inner.Size = startSize
            utility:Tween(button.Inner,{Size = goalSize},duration)
            isPressing = true
        end

        local function up(doCallback)
            if isPressing then
                pcall(function()
                    oldTween:Cancel()
                end)
                utility:Tween(button.Inner,{Size = startSize},duration)
                if doCallback then
                    callback()
                end
            end
        end

        button.Inner.Button.MouseButton1Down:Connect(down)
        button.Inner.Button.MouseButton1Up:Connect(function()
            up(true)
        end)
        button.Inner.Button.MouseLeave:Connect(function()
            up()
        end)
    end
end

-- LIBRARY FUNCTIONS
do
    function library.new(name,special)
        assert(typeof(name)=="string","Library name either nil or not a string")
        special = special or {}
        do -- create UI
            local UI = Instance.new("ScreenGui")
            UI.Name = "Artemis"
            UI.IgnoreGuiInset = true
            UI.ResetOnSpawn = false
            UI.Enabled = false

            local function makeMain() -- call only once
                -- Gui to Lua
                -- Version: 3.2

                -- Instances:

                local Main = Instance.new("Frame")
                local UICorner = Instance.new("UICorner")
                local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
                local Background = Instance.new("Frame")
                local Side = Instance.new("Frame")
                local UICorner_2 = Instance.new("UICorner")
                local Filling = Instance.new("Frame")
                local Filling_2 = Instance.new("Frame")
                local Categories = Instance.new("Frame")
                local UIListLayout = Instance.new("UIListLayout")
                local Body = Instance.new("Frame")
                local UICorner_3 = Instance.new("UICorner")
                local Filling_3 = Instance.new("Frame")
                local Main_2 = Instance.new("Frame")
                local ScrollingFrame = Instance.new("ScrollingFrame")
                local UIListLayout_2 = Instance.new("UIListLayout")
                local _0_padding = Instance.new("Frame")
                local padding = Instance.new("Frame")
                local Filling_4 = Instance.new("Frame")
                local Top = Instance.new("Frame")
                local UICorner_4 = Instance.new("UICorner")
                local Filling_5 = Instance.new("Frame")
                local Title = Instance.new("TextLabel")
                local Version = Instance.new("TextLabel")
                local TextButton = Instance.new("TextButton")

                --Properties:

                Main.Name = "Main"
                Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
                Main.BackgroundTransparency = 1.000
                Main.Position = UDim2.new(0.5, 0, 0.5, 0)
                Main.Size = UDim2.new(0, 476, 0, 581)

                UICorner.CornerRadius = UDim.new(0, 6)
                UICorner.Parent = Main

                UIAspectRatioConstraint.Parent = Main
                UIAspectRatioConstraint.AspectRatio = 0.820

                Background.Name = "Background"
                Background.Parent = Main
                Background.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Background.BackgroundTransparency = 1.000
                Background.Size = UDim2.new(1, 0, 1, 0)
                Background.ZIndex = 0

                Side.Name = "Side"
                Side.Parent = Background
                Side.AnchorPoint = Vector2.new(0, 1)
                Side.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
                Side.LayoutOrder = 5
                Side.Position = UDim2.new(0, 0, 1, 0)
                Side.Size = UDim2.new(0.264583319, 0, 0.941480219, 0)
                Side.ZIndex = 20

                UICorner_2.CornerRadius = UDim.new(0, 6)
                UICorner_2.Parent = Side

                Filling.Name = "Filling"
                Filling.Parent = Side
                Filling.AnchorPoint = Vector2.new(0, 1)
                Filling.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
                Filling.BorderSizePixel = 0
                Filling.LayoutOrder = 5
                Filling.Position = UDim2.new(0.700787425, 0, 1, 0)
                Filling.Size = UDim2.new(0.299212575, 0, 1, 0)
                Filling.ZIndex = 4

                Filling_2.Name = "Filling"
                Filling_2.Parent = Side
                Filling_2.AnchorPoint = Vector2.new(0, 1)
                Filling_2.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
                Filling_2.BorderSizePixel = 0
                Filling_2.LayoutOrder = 5
                Filling_2.Position = UDim2.new(0, 0, 0.0548446067, 0)
                Filling_2.Size = UDim2.new(0.99999994, 0, 0.0548446067, 0)
                Filling_2.ZIndex = 4

                Categories.Name = "Categories"
                Categories.Parent = Side
                Categories.AnchorPoint = Vector2.new(0.5, 0.5)
                Categories.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Categories.BackgroundTransparency = 1.000
                Categories.Position = UDim2.new(0.496040553, 0, 0.502742231, 0)
                Categories.Size = UDim2.new(0.840903521, 0, 0.967093229, 0)
                Categories.ZIndex = 5

                UIListLayout.Parent = Categories
                UIListLayout.Padding = UDim.new(0, 10)

                Body.Name = "Body"
                Body.Parent = Background
                Body.AnchorPoint = Vector2.new(1, 1)
                Body.BackgroundColor3 = Color3.fromRGB(27, 27, 27)
                Body.LayoutOrder = 5
                Body.Position = UDim2.new(1.00000024, 0, 1, 0)
                Body.Size = UDim2.new(0.73541683, 0, 0.941480219, 0)
                Body.ZIndex = 10

                UICorner_3.CornerRadius = UDim.new(0, 6)
                UICorner_3.Parent = Body

                Filling_3.Name = "Filling"
                Filling_3.Parent = Body
                Filling_3.AnchorPoint = Vector2.new(1, 1)
                Filling_3.BackgroundColor3 = Color3.fromRGB(27, 27, 27)
                Filling_3.BorderSizePixel = 0
                Filling_3.LayoutOrder = 5
                Filling_3.Position = UDim2.new(0.999999821, 0, 0.177777782, 0)
                Filling_3.Size = UDim2.new(0.999999821, 0, 0.177777782, 0)

                Main_2.Name = "Main"
                Main_2.Parent = Body
                Main_2.AnchorPoint = Vector2.new(0.5, 0.5)
                Main_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Main_2.BackgroundTransparency = 1.000
                Main_2.Position = UDim2.new(0.5, 0, 0.5, 0)
                Main_2.Size = UDim2.new(0.90718776, 0, 1, 0)
                Main_2.ZIndex = 10

                ScrollingFrame.Parent = Main_2
                ScrollingFrame.Active = true
                ScrollingFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                ScrollingFrame.BackgroundTransparency = 1.000
                ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
                ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0.5, 0)
                ScrollingFrame.ScrollBarThickness = 0

                UIListLayout_2.Parent = ScrollingFrame
                UIListLayout_2.Padding = UDim.new(0, 10)

                _0_padding.Name = "0_padding"
                _0_padding.Parent = ScrollingFrame
                _0_padding.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                _0_padding.BackgroundTransparency = 1.000
                _0_padding.BorderSizePixel = 0
                _0_padding.Size = UDim2.new(1, 0, 0, 1)

                padding.Name = "padding"
                padding.Parent = ScrollingFrame
                padding.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                padding.BackgroundTransparency = 1.000
                padding.BorderSizePixel = 0
                padding.Size = UDim2.new(1, 0, 0, 135)

                Filling_4.Name = "Filling"
                Filling_4.Parent = Body
                Filling_4.AnchorPoint = Vector2.new(1, 1)
                Filling_4.BackgroundColor3 = Color3.fromRGB(27, 27, 27)
                Filling_4.BorderSizePixel = 0
                Filling_4.LayoutOrder = 5
                Filling_4.Position = UDim2.new(0.0980893746, 0, 1.00000012, 0)
                Filling_4.Size = UDim2.new(0.0980891213, 0, 0.177777782, 0)

                Top.Name = "Top"
                Top.Parent = Background
                Top.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
                Top.LayoutOrder = 5
                Top.Size = UDim2.new(1, 0, 0.0585197918, 0)
                Top.ZIndex = 30

                UICorner_4.CornerRadius = UDim.new(0, 6)
                UICorner_4.Parent = Top

                Filling_5.Name = "Filling"
                Filling_5.Parent = Top
                Filling_5.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
                Filling_5.BorderSizePixel = 0
                Filling_5.LayoutOrder = -5
                Filling_5.Position = UDim2.new(0, 0, 0.317073137, 0)
                Filling_5.Size = UDim2.new(1.00000024, 0, 0.682926834, 0)
                Filling_5.ZIndex = -5

                Title.Name = "Title"
                Title.Parent = Top
                Title.AnchorPoint = Vector2.new(0, 0.5)
                Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Title.BackgroundTransparency = 1.000
                Title.Position = UDim2.new(0.0339999795, 0, 0.5, 0)
                Title.Size = UDim2.new(0.803419888, 0, 0.5, 0)
                Title.Font = Enum.Font.GothamBold
                Title.Text = "Name"
                Title.TextColor3 = Color3.fromRGB(255, 255, 255)
                Title.TextScaled = true
                Title.TextSize = 14.000
                Title.TextWrapped = true
                Title.TextXAlignment = Enum.TextXAlignment.Left

                Version.Name = "Version"
                Version.Parent = Top
                Version.AnchorPoint = Vector2.new(1, 0.5)
                Version.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Version.BackgroundTransparency = 1.000
                Version.Position = UDim2.new(0.96600008, 0, 0.5, 0)
                Version.Size = UDim2.new(0.128580168, 0, 0.5, 0)
                Version.Font = Enum.Font.Gotham
                Version.Text = "v0.0.0"
                Version.TextColor3 = Color3.fromRGB(255, 255, 255)
                Version.TextScaled = true
                Version.TextSize = 14.000
                Version.TextWrapped = true
                Version.TextXAlignment = Enum.TextXAlignment.Right

                TextButton.Name = "Button"
                TextButton.Parent = Top
                TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                TextButton.BackgroundTransparency = 1.000
                TextButton.Size = UDim2.new(1, 0, 1, 0)
                TextButton.Font = Enum.Font.SourceSans
                TextButton.Text = ""
                TextButton.TextColor3 = Color3.fromRGB(0, 0, 0)
                TextButton.TextSize = 14.000

                return Main
            end

            local function makeLoader() -- call only once
                -- Gui to Lua
                -- Version: 3.2

                -- Instances:

                local Loader = Instance.new("Frame")
                local UICorner = Instance.new("UICorner")
                local GameIcon = Instance.new("ImageLabel")
                local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
                local Player = Instance.new("Frame")
                local Thumbnail = Instance.new("ImageLabel")
                local UICorner_2 = Instance.new("UICorner")
                local PlayerName = Instance.new("TextLabel")
                local Title = Instance.new("TextLabel")
                local Status = Instance.new("Frame")
                local Loading = Instance.new("TextLabel")
                local Loading_2 = Instance.new("ImageLabel")
                local UIAspectRatioConstraint_2 = Instance.new("UIAspectRatioConstraint")
                local Load = Instance.new("Frame")
                local Inner = Instance.new("Frame")
                local UICorner_3 = Instance.new("UICorner")
                local Title_2 = Instance.new("TextLabel")
                local Button = Instance.new("TextButton")
                local GameName = Instance.new("TextLabel")

                --Properties:

                Loader.Name = "Loader"
                Loader.AnchorPoint = Vector2.new(0.5, 0.5)
                Loader.BackgroundColor3 = Color3.fromRGB(27, 27, 27)
                Loader.Position = UDim2.new(0.5, 0, 0.5, 0)
                Loader.Size = UDim2.new(0, 330, 0, 474)

                UICorner.CornerRadius = UDim.new(0, 6)
                UICorner.Parent = Loader

                GameIcon.Name = "GameIcon"
                GameIcon.Parent = Loader
                GameIcon.AnchorPoint = Vector2.new(0.5, 0)
                GameIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                GameIcon.BorderSizePixel = 0
                GameIcon.Position = UDim2.new(0.5, 0, 0.147253171, 0)
                GameIcon.Size = UDim2.new(0, 269, 0, 248)
                GameIcon.Image = ""

                UIAspectRatioConstraint.Parent = GameIcon

                Player.Name = "Player"
                Player.Parent = Loader
                Player.AnchorPoint = Vector2.new(0.5, 0)
                Player.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Player.BackgroundTransparency = 1.000
                Player.Position = UDim2.new(0.5, 0, 0.689999998, 0)
                Player.Size = UDim2.new(0, 305, 0, 70)

                Thumbnail.Name = "Thumbnail"
                Thumbnail.Parent = Player
                Thumbnail.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                Thumbnail.Size = UDim2.new(0, 70, 0, 70)
                Thumbnail.ZIndex = 30
                Thumbnail.Image = ""

                UICorner_2.CornerRadius = UDim.new(1, 0)
                UICorner_2.Parent = Thumbnail

                PlayerName.Name = "PlayerName"
                PlayerName.Parent = Player
                PlayerName.AnchorPoint = Vector2.new(0, 1)
                PlayerName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                PlayerName.BackgroundTransparency = 1.000
                PlayerName.Position = UDim2.new(0.263000101, 0, 0.500000417, 0)
                PlayerName.Size = UDim2.new(0.736999989, 0, 0.371428996, 0)
                PlayerName.ZIndex = 30
                PlayerName.Font = Enum.Font.GothamBlack
                PlayerName.Text = "Player Name"
                PlayerName.TextColor3 = Color3.fromRGB(255, 255, 255)
                PlayerName.TextScaled = true
                PlayerName.TextSize = 14.000
                PlayerName.TextWrapped = true
                PlayerName.TextXAlignment = Enum.TextXAlignment.Left

                Title.Name = "Title"
                Title.Parent = Player
                Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Title.BackgroundTransparency = 1.000
                Title.Position = UDim2.new(0.263000011, 0, 0.5, 0)
                Title.Size = UDim2.new(0.736999989, 0, 0.215000004, 0)
                Title.ZIndex = 30
                Title.Font = Enum.Font.GothamBlack
                Title.Text = "Tag"
                Title.TextColor3 = Color3.fromRGB(255, 0, 0)
                Title.TextScaled = true
                Title.TextSize = 14.000
                Title.TextWrapped = true
                Title.TextXAlignment = Enum.TextXAlignment.Left

                Status.Name = "Status"
                Status.Parent = Loader
                Status.AnchorPoint = Vector2.new(0.5, 0)
                Status.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Status.BackgroundTransparency = 1.000
                Status.Position = UDim2.new(0.5, 0, 0.837679327, 0)
                Status.Size = UDim2.new(0, 305, 0, 66)

                Loading.Name = "Loading_old"
                Loading.Parent = Status
                Loading.AnchorPoint = Vector2.new(0.5, 0.5)
                Loading.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Loading.BackgroundTransparency = 1.000
                Loading.Position = UDim2.new(0.5, 0, 0.5, 0)
                Loading.Size = UDim2.new(0.899999976, 0, 0.899999976, 0)
                Loading.Visible = false
                Loading.ZIndex = 30
                Loading.Font = Enum.Font.Gotham
                Loading.Text = "_old"
                Loading.TextColor3 = Color3.fromRGB(255, 255, 255)
                Loading.TextScaled = true
                Loading.TextSize = 14.000
                Loading.TextWrapped = true

                Loading_2.Name = "Loading"
                Loading_2.Parent = Status
                Loading_2.AnchorPoint = Vector2.new(0.5, 0.5)
                Loading_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Loading_2.BackgroundTransparency = 1.000
                Loading_2.Position = UDim2.new(0.5, 0, 0.5, 0)
                Loading_2.Size = UDim2.new(1, 0, 1, 0)
                Loading_2.Visible = false
                Loading_2.Image = "http://www.roblox.com/asset/?id=10262657333"

                UIAspectRatioConstraint_2.Parent = Loading_2

                Load.Name = "Load"
                Load.Parent = Status
                Load.AnchorPoint = Vector2.new(0.5, 1)
                Load.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
                Load.BackgroundTransparency = 1.000
                Load.BorderSizePixel = 0
                Load.Position = UDim2.new(0.5, 0, 0.949999988, 0)
                Load.Size = UDim2.new(1, 0, 0, 50)

                Inner.Name = "Inner"
                Inner.Parent = Load
                Inner.AnchorPoint = Vector2.new(0.5, 0.5)
                Inner.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
                Inner.BorderSizePixel = 0
                Inner.Position = UDim2.new(0.5, 0, 0.5, 0)
                Inner.Size = UDim2.new(1, 0, 1, 0)

                UICorner_3.CornerRadius = UDim.new(0, 4)
                UICorner_3.Parent = Inner

                Title_2.Name = "Title"
                Title_2.Parent = Inner
                Title_2.AnchorPoint = Vector2.new(0.5, 0.5)
                Title_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Title_2.BackgroundTransparency = 1.000
                Title_2.Position = UDim2.new(0.5, 0, 0.5, 0)
                Title_2.Size = UDim2.new(0.927512109, 0, 0.449999958, 0)
                Title_2.Font = Enum.Font.GothamBold
                Title_2.Text = "Load Kratos"
                Title_2.TextColor3 = Color3.fromRGB(255, 255, 255)
                Title_2.TextScaled = true
                Title_2.TextSize = 14.000
                Title_2.TextWrapped = true

                Button.Name = "Button"
                Button.Parent = Inner
                Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Button.BackgroundTransparency = 1.000
                Button.Size = UDim2.new(1, 0, 1, 0)
                Button.Font = Enum.Font.SourceSans
                Button.Text = ""
                Button.TextColor3 = Color3.fromRGB(0, 0, 0)
                Button.TextSize = 14.000

                GameName.Name = "GameName"
                GameName.Parent = Loader
                GameName.AnchorPoint = Vector2.new(0.5, 0)
                GameName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                GameName.BackgroundTransparency = 1.000
                GameName.Position = UDim2.new(0.5, 0, 0.0270000007, 0)
                GameName.Size = UDim2.new(0.924242496, 0, 0.0968776047, 0)
                GameName.ZIndex = 30
                GameName.Font = Enum.Font.GothamBlack
                GameName.Text = "Game"
                GameName.TextColor3 = Color3.fromRGB(255, 255, 255)
                GameName.TextScaled = true
                GameName.TextSize = 14.000
                GameName.TextWrapped = true

                return Loader
            end

            local mainFrame = makeMain()
            local loaderFrame = makeLoader()

            mainFrame.Background.Top.Title.Text = name
            mainFrame.Background.Top.Version.Text = tostring(special["Version"] or "")

            mainFrame.Parent = UI
            loaderFrame.Parent = UI

            -- dragging
            local dragEvents = utility:InitDragging(mainFrame,mainFrame.Background.Top.Button)

            UI.Enabled = true
            UI.Parent = Core

            return setmetatable({
                ["container"] = UI;
                ["main"] = mainFrame;
                ["loader"] = loaderFrame;
                ["pages"] = {};
                ["special"] = special;
                ["_drag_events"] = dragEvents;
            }, library)
        end
    end

    function library:StartLoading(info)
        assert(self._load_event == nil,"Request to start loading while already loading")

        local container = self.container
        local loader = self.loader

        local loading = loader.Status.Loading

        loader.Player.Thumbnail.Image = utility:GetPlayerThumbnail(player.UserId)
        loader.Player.PlayerName.Text = player.Name
        loader.Player.Title.Text = info.Title or "User"
        loader.Player.Title.TextColor3 = info.TitleTextColor or Color3.new(0,1,0)

        loader.GameIcon.Image = info.ThumbnailId or ""

        loader.GameName.Text = info.GameName or "Game"

        loader.Status.Loading.Visible = true
        loader.Status.Load.Visible = false

        self._load_event = Run.RenderStepped:Connect(function()
            -- Enable the loader and disable everything else
            for _,v in pairs(container:GetChildren()) do
                if v:IsA("Frame") then
                    v.Visible = v == loader
                end
            end
            -- Animate the loading circle
            loading.Rotation = os.clock()*550
        end)
    end

    function library:StopLoading()
        local function callback()
            utility:Disconnect(self._load_event)
            utility:Wait()
            local main = self.main
            for _,v in pairs(self.container:GetChildren()) do
                if v:IsA("Frame") then
                    v.Visible = v == main
                end
            end
        end

        self.loader.Status.Loading.Visible = false
        self.loader.Status.Load.Visible = true


        utility:HandleButton(self.loader.Status.Load,callback)
    end
end

return library
