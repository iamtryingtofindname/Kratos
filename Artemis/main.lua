--[[


░█████╗░██████╗░████████╗███████╗███╗░░░███╗██╗░██████╗
██╔══██╗██╔══██╗╚══██╔══╝██╔════╝████╗░████║██║██╔════╝
███████║██████╔╝░░░██║░░░█████╗░░██╔████╔██║██║╚█████╗░
██╔══██║██╔══██╗░░░██║░░░██╔══╝░░██║╚██╔╝██║██║░╚═══██╗
██║░░██║██║░░██║░░░██║░░░███████╗██║░╚═╝░██║██║██████╔╝
╚═╝░░╚═╝╚═╝░░╚═╝░░░╚═╝░░░╚══════╝╚═╝░░░░░╚═╝╚═╝╚═════╝░

Private UI library made by iamtryingtofindname#9879
Used by Kratos script by iamtryingtofindname#9879

]]--

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
    function utility.BlankFunction()
    end

    function utility:Lerp(start,goal,alpha)
        return start+(goal-start)*alpha
    end

    function utility:Warn(...)
        warn("ARTEMIS:", ...)
    end

    function utility:Wait()
        return Run.RenderStepped:Wait()
    end

    function utility:Disconnect(connection)
        pcall(function()
            connection:Disconnect()
        end)
    end

    function utility:FormatNumber(number,decimalPlaces)
        assert(typeof(number)=="number","Must be a number")
        decimalPlaces = math.clamp(decimalPlaces,0,math.huge)
        local exp = 10^decimalPlaces
        number = math.round(number*exp)/exp
        local formatted = number
        while true do
            local k
            formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
            if (k==0) then
                break
            end
        end
        return formatted
    end

    function utility:GetColor(percentage, ColorKeyPoints)
        if (percentage < 0) or (percentage>1) then
            utility:Warn('getColor got out of bounds percentage (less than 0 or greater than 1')
        end
        
        local closestToLeft = ColorKeyPoints[1]
        local closestToRight = ColorKeyPoints[#ColorKeyPoints]
        local LocalPercentage = .5
        local color = closestToLeft.Value
        
        -- This loop can probably be improved by doing something like a Binary search instead
        -- This should work fine though
        for i=1,#ColorKeyPoints-1 do
            if (ColorKeyPoints[i].Time <= percentage) and (ColorKeyPoints[i+1].Time >= percentage) then
                closestToLeft = ColorKeyPoints[i]
                closestToRight = ColorKeyPoints[i+1]
                LocalPercentage = (percentage-closestToLeft.Time)/(closestToRight.Time-closestToLeft.Time)
                color = closestToLeft.Value:lerp(closestToRight.Value,LocalPercentage)
                return color
            end
        end
        utility:Warn('Color not found!')
        return color
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

        local inputBegan = button.MouseButton1Down:Connect(function()
            _dragging = true
            _dragging_offset = Vector2.new(mouse.X,mouse.Y)-frame.AbsolutePosition
        end)

        local inputEnded = mouse.Button1Up:Connect(function()
            _dragging = false
            _dragging_offset = nil
        end)

        local updateEvent = Run.RenderStepped:Connect(function()
            if frame.Visible == false or not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                _dragging = false
                _dragging_offset = nil
            end
            if _dragging and _dragging_offset then
                frame.Position = UDim2.fromOffset(mouse.X-_dragging_offset.X+(frame.AbsoluteSize.X*frame.AnchorPoint.X),mouse.Y-_dragging_offset.Y+36+(frame.AbsoluteSize.Y*frame.AnchorPoint.Y))
            end
        end)

        return {inputBegan,inputEnded,updateEvent}
    end

    function utility:HandleButton(button,callback)
        local startSize = UDim2.fromScale(1,1)
        local goalSize = UDim2.fromScale(0.925,0.925)
        local oldTween
        local duration = 0.1
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
                local ColorPickers = Instance.new("Frame")
                local UIGridLayout = Instance.new("UIGridLayout")
                local TextButton = Instance.new("TextButton")

                --Properties:

                Main.Name = "Main"
                Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
                Main.BackgroundTransparency = 1.000
                Main.Position = UDim2.new(0.5, 0, 0.5, 0)
                Main.AnchorPoint = Vector2.new(0.5,0.5)
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
                ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

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
                Title.ZIndex = 50
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
                Version.ZIndex = 50
                Version.TextXAlignment = Enum.TextXAlignment.Right

                ColorPickers.Name = "ColorPickers"
                ColorPickers.Parent = Main
                ColorPickers.AnchorPoint = Vector2.new(0.5, 0)
                ColorPickers.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                ColorPickers.BackgroundTransparency = 1.000
                ColorPickers.Position = UDim2.new(1.63760519, 0, 0, 0)
                ColorPickers.Size = UDim2.new(1.25021017, 0, 1, 0)
                
                UIGridLayout.Parent = ColorPickers
                UIGridLayout.FillDirection = Enum.FillDirection.Vertical
                UIGridLayout.CellSize = UDim2.new(0, 172, 0, 190)

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

            local currentPage = Instance.new("IntValue")
            currentPage.Name = "CurrentPage"
            currentPage.Value = 0
            currentPage.Parent = mainFrame.Background.Body

            mainFrame.Parent = UI
            loaderFrame.Parent = UI

            -- dragging
            local dragEvents = utility:InitDragging(mainFrame,mainFrame.Background.Top.Button)

            UI.Enabled = true
            UI.Parent = Core

            -- section update event
            local scrollingFrame = mainFrame.Background.Body.Main.ScrollingFrame
            local categories = mainFrame.Background.Side.Categories
            local sectionUpdateEvent = Run.RenderStepped:Connect(function()
                for _,v in pairs(categories:GetChildren()) do
                    if v:IsA("Frame") then
                        local color = currentPage.Value==v.Page.Value and Color3.new(1,1,1) or Color3.fromRGB(99, 99, 99)
                        v.TextLabel.TextColor3 = color
                        v.Frame.ImageLabel.ImageColor3 = color
                    end
                end

                for _,v in pairs(scrollingFrame:GetChildren()) do
                    if v:IsA("Frame") and v:FindFirstChild("Page") then
                        v.Visible = v.Page.Value == currentPage.Value
                    end
                end
            end)

            return setmetatable({
                ["container"] = UI;
                ["main"] = mainFrame;
                ["loader"] = loaderFrame;
                ["special"] = special;
                -- used internally
                ["_drag_events"] = dragEvents;
                ["_page_num"] = 1;
                ["_section_update"] = sectionUpdateEvent;
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

        loader.GameIcon.Image = info.ThumbnailId and "rbxassetid://"..info.ThumbnailId or ""

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
            loading.Rotation = (os.clock()*550)%360
        end)
    end

    function library:StopLoading()
        local called
        local function callback()
            if not called then
                called = true
                utility:Disconnect(self._load_event)
                utility:Wait()
                local main = self.main
                for _,v in pairs(self.container:GetChildren()) do
                    if v:IsA("Frame") then
                        v.Visible = v == main
                    end
                end
            end
        end

        self.loader.Status.Loading.Visible = false
        self.loader.Status.Load.Visible = true


        utility:HandleButton(self.loader.Status.Load,callback)
    end

    function library:CreatePage(...)
        return page.new(self,...)
    end

    function library:Toggle(toggle)
        if toggle == nil then
            toggle = not self.main.Visible
        end
        self.main.Visible = toggle
    end
end

-- PAGE FUNCTIONS
do
    function page.new(lib,name,imageId)
        local function makePage()
            -- Gui to Lua
            -- Version: 3.2

            -- Instances:

            local Category = Instance.new("Frame")
            local TextLabel = Instance.new("TextLabel")
            local Button = Instance.new("TextButton")
            local Frame = Instance.new("Frame")
            local ImageLabel = Instance.new("ImageLabel")
            local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")

            --Properties:

            Category.Name = "Category"
            Category.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Category.BackgroundTransparency = 1.000
            Category.Size = UDim2.new(1, 0, 0.036861971, 0)

            TextLabel.Parent = Category
            TextLabel.AnchorPoint = Vector2.new(0, 0.5)
            TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            TextLabel.BackgroundTransparency = 1.000
            TextLabel.Position = UDim2.new(0.258987725, 0, 0.499999911, 0)
            TextLabel.Size = UDim2.new(0.703000009, 0, 0.800000012, 0)
            TextLabel.Font = Enum.Font.Gotham
            TextLabel.Text = "Category"
            TextLabel.TextColor3 = Color3.fromRGB(99, 99, 99)
            TextLabel.ZIndex = 80
            TextLabel.TextScaled = true
            TextLabel.TextSize = 14.000
            TextLabel.TextWrapped = true
            TextLabel.TextXAlignment = Enum.TextXAlignment.Left

            Button.Name = "Button"
            Button.Parent = Category
            Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Button.BackgroundTransparency = 1.000
            Button.Size = UDim2.new(1, 0, 1, 0)
            Button.Font = Enum.Font.SourceSans
            Button.Text = ""
            Button.TextColor3 = Color3.fromRGB(0, 0, 0)
            Button.ZIndex = 100
            Button.TextSize = 14.000

            Frame.Parent = Category
            Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Frame.BackgroundTransparency = 1.000
            Frame.ZIndex = 80
            Frame.Size = UDim2.new(0.202332973, 0, 1, 0)

            ImageLabel.Parent = Frame
            ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ImageLabel.BackgroundTransparency = 1.000
            ImageLabel.Position = UDim2.new(0, 2, 0, -1)
            ImageLabel.Size = UDim2.new(1, 0, 1, 0)
            ImageLabel.Image = "http://www.roblox.com/asset/?id="
            ImageLabel.ImageColor3 = Color3.fromRGB(99, 99, 99)
            ImageLabel.ZIndex = 90

            UIAspectRatioConstraint.Parent = ImageLabel

            return Category
        end

        local pageFrame = makePage()
        local thisPageNum = lib._page_num
        lib._page_num = lib._page_num+1

        local pageNumValue = Instance.new("IntValue")
        pageNumValue.Name = "Page"
        pageNumValue.Value = tostring(thisPageNum)
        pageNumValue.Parent = pageFrame

        pageFrame.Name = thisPageNum.."_"..name
        pageFrame.TextLabel.Text = name
        pageFrame.Frame.ImageLabel.Image = "http://www.roblox.com/asset/?id="..(imageId or "") -- image ID, not decal ID

        pageFrame.Parent = lib.main.Background.Side.Categories

        local page = setmetatable({
            ["container"] = lib.container;
            ["main"] = lib.main;
            ["frame"] = pageFrame;
            ["page_num"] = thisPageNum;
            ["_section_num"] = 1;
        }, page)

        if thisPageNum == 1 then
            page:Select()
        end

        -- input events
        page._activated_event = pageFrame.Button.Activated:Connect(function()
            page:Select()
        end)

        return page
    end

    function page:Select()
        self.main.Background.Body.CurrentPage.Value = self.page_num
    end

    function page:CreateSection(...)
        return section.new(self,...)
    end
end

-- SECTION FUNCTIONS
do
    function section.new(page,name)
        local function makeSection()
            -- Gui to Lua
            -- Version: 3.2

            -- Instances:

            local Section = Instance.new("Frame")
            local UICorner = Instance.new("UICorner")
            local Contents = Instance.new("Frame")
            local UIListLayout = Instance.new("UIListLayout")
            local _0_title = Instance.new("TextLabel")
            local padding = Instance.new("Frame")
            local padding_2 = Instance.new("Frame")

            --Properties:

            Section.Name = "Section"
            Section.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            Section.BorderSizePixel = 0
            Section.Position = UDim2.new(0, 0, 0.0201096889, 0)
            Section.ZIndex = 200
            Section.Size = UDim2.new(1, 0, 0.0587934107, 0)
            Section.AutomaticSize = Enum.AutomaticSize.Y -- added

            UICorner.CornerRadius = UDim.new(0, 6)
            UICorner.Parent = Section

            Contents.Name = "Contents"
            Contents.Parent = Section
            Contents.AnchorPoint = Vector2.new(0.5, 0)
            Contents.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Contents.BackgroundTransparency = 1.000
            Contents.Position = UDim2.new(0.5, 0, 0, 12)
            Contents.Size = UDim2.new(0.899999976, 0, 1, -24)
            Contents.AutomaticSize = Enum.AutomaticSize.Y -- added

            UIListLayout.Parent = Contents
            UIListLayout.Padding = UDim.new(0, 7)

            _0_title.Name = "0_title"
            _0_title.Parent = Contents
            _0_title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            _0_title.BackgroundTransparency = 1.000
            _0_title.Size = UDim2.new(1, 0, 0, 14)
            _0_title.Font = Enum.Font.GothamMedium
            _0_title.Text = "Name"
            _0_title.TextColor3 = Color3.fromRGB(255, 255, 255)
            _0_title.TextScaled = true
            _0_title.TextSize = 14.000
            _0_title.TextWrapped = true
            _0_title.ZIndex = 200
            _0_title.TextXAlignment = Enum.TextXAlignment.Left

            padding.Name = "padding"
            padding.Parent = Section
            padding.AnchorPoint = Vector2.new(0.5, 1)
            padding.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            padding.BackgroundTransparency = 1.000
            padding.Position = UDim2.new(0.5, 0, 1, 0)
            padding.Size = UDim2.new(0.899999976, 0, 0, 12)

            padding_2.Name = "padding"
            padding_2.Parent = Section
            padding_2.AnchorPoint = Vector2.new(0.5, 0)
            padding_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            padding_2.BackgroundTransparency = 1.000
            padding_2.Position = UDim2.new(0.5, 0, 0, 0)
            padding_2.Size = UDim2.new(0.899999976, 0, 0, 12)

            return Section
        end

        local sectionFrame = makeSection()
        local pageNumValue = Instance.new("IntValue")
        pageNumValue.Name = "Page"
        local thisSectionNum = page._section_num
        page._section_num = page._section_num+1
        pageNumValue.Value = page.page_num
        pageNumValue.Parent = sectionFrame
        local scrollingFrame = page.main.Background.Body.Main.ScrollingFrame
        sectionFrame.Name  = thisSectionNum.."_"..name
        sectionFrame.Contents:FindFirstChild("0_title").Text = name
        sectionFrame.Parent = scrollingFrame

        return setmetatable({
            ["container"] = page.container;
            ["main"] = page.main;
            ["frame"] = sectionFrame;
            ["section_num"] = thisSectionNum;
            ["_element_num"] = 1;
        }, section)
    end
end

-- ELEMENT FUNCTIONS
do
    function section:CreateButton(title,callback)
        assert(title,"Invalid arguments")
        callback = callback or utility.BlankFunction
        local function makeButton()
            -- Gui to Lua
            -- Version: 3.2

            -- Instances:

            local Button = Instance.new("Frame")
            local Inner = Instance.new("Frame")
            local UICorner = Instance.new("UICorner")
            local Title = Instance.new("TextLabel")
            local Button_2 = Instance.new("TextButton")

            --Properties:

            Button.Name = "Button"
            Button.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
            Button.BackgroundTransparency = 1.000
            Button.BorderSizePixel = 0
            Button.Size = UDim2.new(1, 0, 0, 32)
            Button.ZIndex = 300

            Inner.Name = "Inner"
            Inner.Parent = Button
            Inner.AnchorPoint = Vector2.new(0.5, 0.5)
            Inner.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
            Inner.BorderSizePixel = 0
            Inner.Position = UDim2.new(0.5, 0, 0.5, 0)
            Inner.Size = UDim2.new(1, 0, 1, 0)
            Inner.ZIndex = 310

            UICorner.CornerRadius = UDim.new(0, 4)
            UICorner.Parent = Inner

            Title.Name = "Title"
            Title.Parent = Inner
            Title.AnchorPoint = Vector2.new(0.5, 0.5)
            Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Title.BackgroundTransparency = 1.000
            Title.Position = UDim2.new(0.5, 0, 0.5, 0)
            Title.Size = UDim2.new(0.927512109, 0, 0.449999958, 0)
            Title.Font = Enum.Font.Gotham
            Title.Text = "Button"
            Title.TextColor3 = Color3.fromRGB(255, 255, 255)
            Title.TextScaled = true
            Title.TextSize = 14.000
            Title.TextWrapped = true
            Title.ZIndex = 320

            Button_2.Name = "Button"
            Button_2.Parent = Inner
            Button_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Button_2.BackgroundTransparency = 1.000
            Button_2.Size = UDim2.new(1, 0, 1, 0)
            Button_2.Font = Enum.Font.SourceSans
            Button_2.Text = ""
            Button_2.TextColor3 = Color3.fromRGB(0, 0, 0)
            Button_2.TextSize = 14.000
            Button_2.ZIndex = 330

            return Button
        end

        local button = makeButton()
        button.Inner.Title.Text = title

        local thisElementNum = self._element_num
        self._element_num = self._element_num+1

        utility:HandleButton(button,callback)

        button.Name = thisElementNum.."_"..title
        button.Parent = self.frame.Contents

        return button
    end

    function section:CreateToggle(title,default,callback)
        assert(title,"Invalid arguments")
        callback = callback or utility.BlankFunction
        local function makeToggle()
            -- Gui to Lua
            -- Version: 3.2

            -- Instances:

            local Toggle = Instance.new("Frame")
            local UICorner = Instance.new("UICorner")
            local Title = Instance.new("TextLabel")
            local Toggle_2 = Instance.new("ImageLabel")
            local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
            local Switch = Instance.new("ImageLabel")
            local UIAspectRatioConstraint_2 = Instance.new("UIAspectRatioConstraint")
            local Button = Instance.new("TextButton")

            --Properties:

            Toggle.Name = "Toggle"
            Toggle.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
            Toggle.BorderSizePixel = 0
            Toggle.Size = UDim2.new(1, 0, 0, 32)
            Toggle.ZIndex = 300

            UICorner.CornerRadius = UDim.new(0, 4)
            UICorner.Parent = Toggle

            Title.Name = "Title"
            Title.Parent = Toggle
            Title.AnchorPoint = Vector2.new(0, 0.5)
            Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Title.BackgroundTransparency = 1.000
            Title.Position = UDim2.new(0.0349880569, 0, 0.5, 0)
            Title.Size = UDim2.new(0.779575229, 0, 0.449999958, 0)
            Title.Font = Enum.Font.Gotham
            Title.Text = "Toggle"
            Title.TextColor3 = Color3.fromRGB(255, 255, 255)
            Title.TextScaled = true
            Title.TextSize = 14.000
            Title.TextWrapped = true
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.ZIndex = 310

            Toggle_2.Name = "Toggle"
            Toggle_2.Parent = Toggle
            Toggle_2.AnchorPoint = Vector2.new(1, 0.5)
            Toggle_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Toggle_2.BackgroundTransparency = 1.000
            Toggle_2.Position = UDim2.new(0.970000029, 0, 0.5, 0)
            Toggle_2.Size = UDim2.new(0.156000003, 0, 0.573000014, 0)
            Toggle_2.Image = "rbxassetid://10261338527"
            Toggle_2.ImageColor3 = Color3.fromRGB(255, 0, 0)
            Toggle_2.ScaleType = Enum.ScaleType.Slice
            Toggle_2.SliceCenter = Rect.new(100, 100, 100, 100)
            Toggle_2.ZIndex = 400

            UIAspectRatioConstraint.Parent = Toggle_2
            UIAspectRatioConstraint.AspectRatio = 2.000

            Switch.Name = "Switch"
            Switch.Parent = Toggle_2
            Switch.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Switch.BackgroundTransparency = 1.000
            Switch.Size = UDim2.new(0.5, 0, 1, 0)
            Switch.Image = "rbxassetid://10261338527"
            Switch.ScaleType = Enum.ScaleType.Slice
            Switch.SliceCenter = Rect.new(100, 100, 100, 100)
            Switch.ZIndex = 500

            UIAspectRatioConstraint_2.Parent = Switch

            Button.Name = "Button"
            Button.Parent = Toggle_2
            Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Button.BackgroundTransparency = 1.000
            Button.Size = UDim2.new(1, 0, 1, 0)
            Button.Font = Enum.Font.SourceSans
            Button.Text = ""
            Button.TextColor3 = Color3.fromRGB(0, 0, 0)
            Button.TextSize = 14.000

            return Toggle
        end

        local toggle = makeToggle()
        toggle.Title.Text = title

        local thisElementNum = self._element_num
        self._element_num = self._element_num+1

        -- handle toggle
        local _toggle = default
        local startSwitch = 0
        local goalSwitch = 0.5
        local durationMultiplier = 0.5 -- 0.5 seconds
        local tween1
        local tween2

        toggle.Toggle.Switch.Position = UDim2.fromScale(default and goalSwitch or startSwitch,0)
        toggle.Toggle.ImageColor3 = default and Color3.new(0,1,0) or Color3.new(1,0,0)

        local function stopTweens()
            pcall(function()
                tween1:Cancel()
            end)
            pcall(function()
                tween2:Cancel()
            end)
        end

        local function on()
            stopTweens()
            local duration = math.abs(toggle.Toggle.Switch.Position.X.Scale-goalSwitch)*durationMultiplier
            tween1 = utility:Tween(toggle.Toggle.Switch,{Position = UDim2.fromScale(goalSwitch,0)},duration)
            tween2 = utility:Tween(toggle.Toggle,{ImageColor3 = Color3.new(0,1,0)},duration)
        end

        local function off()
            stopTweens()
            local duration = math.abs(toggle.Toggle.Switch.Position.X.Scale-startSwitch)*durationMultiplier
            tween1 = utility:Tween(toggle.Toggle.Switch,{Position = UDim2.fromScale(startSwitch,0)},duration)
            tween2 = utility:Tween(toggle.Toggle,{ImageColor3 = Color3.new(1,0,0)},duration)
        end

        toggle.Toggle.Button.Activated:Connect(function()
            _toggle = not _toggle
            if _toggle then
                on()
            else
                off()
            end
            callback(_toggle)
        end)

        toggle.Name = thisElementNum.."_"..title
        toggle.Parent = self.frame.Contents

        return toggle
    end

    function section:CreateLabel(body)
        local function makeLabel()
            -- Gui to Lua
            -- Version: 3.2

            -- Instances:

            local Label = Instance.new("Frame")
            local Frame = Instance.new("Frame")
            local UIListLayout = Instance.new("UIListLayout")
            local Title = Instance.new("TextLabel")
            local padding = Instance.new("Frame")
            local _0_padding = Instance.new("Frame")
            local UICorner = Instance.new("UICorner")
            --local padding_2 = Instance.new("Frame")

            --Properties:

            Label.Name = "Label"
            Label.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
            Label.BackgroundTransparency = 1.000
            Label.BorderSizePixel = 0
            Label.AutomaticSize = Enum.AutomaticSize.Y
            Label.Size = UDim2.new(1, 0, 0, 1)
            Label.ZIndex = 300

            Frame.Parent = Label
            Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
            Frame.Size = UDim2.new(1, 0, 1, 0)
            Frame.ZIndex = 310

            UIListLayout.Parent = Frame
            UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

            Title.Name = "Title"
            Title.Parent = Frame
            Title.AnchorPoint = Vector2.new(0.5, 0.5)
            Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Title.BackgroundTransparency = 1.000
            Title.Position = UDim2.new(0.5, 0, 0.5, 0)
            Title.Size = UDim2.new(0.930000007, 0, 0, 1)
            Title.Font = Enum.Font.Gotham
            Title.Text = "Text"
            Title.TextColor3 = Color3.fromRGB(255, 255, 255)
            Title.TextSize = 14.000
            Title.TextWrapped = true
            Title.RichText = true
            Title.AutomaticSize = Enum.AutomaticSize.Y
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.ZIndex = 320

            padding.Name = "padding"
            padding.Parent = Frame
            padding.AnchorPoint = Vector2.new(0.5, 1)
            padding.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            padding.BackgroundTransparency = 1.000
            padding.Position = UDim2.new(0.5, 0, 1, 0)
            padding.Size = UDim2.new(0.899999976, 0, 0, 9)

            _0_padding.Name = "0_padding"
            _0_padding.Parent = Frame
            _0_padding.AnchorPoint = Vector2.new(0.5, 1)
            _0_padding.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            _0_padding.BackgroundTransparency = 1.000
            _0_padding.Position = UDim2.new(0.5, 0, 1, 0)
            _0_padding.Size = UDim2.new(0.899999976, 0, 0, 9)

            UICorner.CornerRadius = UDim.new(0, 4)
            UICorner.Parent = Frame

            --[[
            padding_2.Name = "padding"
            padding_2.Parent = Label
            padding_2.AnchorPoint = Vector2.new(0.5, 1)
            padding_2.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
            padding_2.BackgroundTransparency = 1.000
            padding_2.Position = UDim2.new(0.5, 0, 1, 8)
            padding_2.Size = UDim2.new(0.899999976, 0, 0, 6)
            ]]--

            return Label
        end

        local label = makeLabel()

        local thisElementNum = self._element_num
        self._element_num = self._element_num+1

        label.Name = thisElementNum.."_".."Label"
        label.Frame.Title.Text = body
        label.Parent = self.frame.Contents

        return label
    end

    function section:CreateTextBox(title,default,callback)
        callback = callback or utility.BlankFunction
        local function makeTextBox()
            -- Gui to Lua
            -- Version: 3.2

            -- Instances:

            local TextBox = Instance.new("Frame")
            local UICorner = Instance.new("UICorner")
            local Title = Instance.new("TextLabel")
            local TextBox_2 = Instance.new("Frame")
            local UICorner_2 = Instance.new("UICorner")
            local TextBox_3 = Instance.new("TextBox")

            --Properties:

            TextBox.Name = "TextBox"
            TextBox.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
            TextBox.BorderSizePixel = 0
            TextBox.Size = UDim2.new(1, 0, 0, 32)
            TextBox.ZIndex = 500

            UICorner.CornerRadius = UDim.new(0, 4)
            UICorner.Parent = TextBox

            Title.Name = "Title"
            Title.Parent = TextBox
            Title.AnchorPoint = Vector2.new(0, 0.5)
            Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Title.BackgroundTransparency = 1.000
            Title.Position = UDim2.new(0.0349880569, 0, 0.5, 0)
            Title.Size = UDim2.new(0.367012143, 0, 0.449999958, 0)
            Title.Font = Enum.Font.Gotham
            Title.Text = "Title"
            Title.TextColor3 = Color3.fromRGB(255, 255, 255)
            Title.TextScaled = true
            Title.TextSize = 20.000
            Title.TextWrapped = true
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.ZIndex = 500

            TextBox_2.Name = "TextBox"
            TextBox_2.Parent = TextBox
            TextBox_2.AnchorPoint = Vector2.new(1, 0.5)
            TextBox_2.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
            TextBox_2.BorderSizePixel = 0
            TextBox_2.Position = UDim2.new(0.976999998, 0, 0.5, 0)
            TextBox_2.Size = UDim2.new(0.3, 0, 0.550000012, 0)
            TextBox_2.ZIndex = 500

            UICorner_2.CornerRadius = UDim.new(0, 4)
            UICorner_2.Parent = TextBox_2

            TextBox_3.Parent = TextBox_2
            TextBox_3.AnchorPoint = Vector2.new(0.5, 0.5)
            TextBox_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            TextBox_3.BackgroundTransparency = 1.000
            TextBox_3.Position = UDim2.new(0.5, 0, 0.5, 0)
            TextBox_3.Size = UDim2.new(1, -8, 0.75, 0)
            TextBox_3.Font = Enum.Font.Gotham
            TextBox_3.PlaceholderColor3 = Color3.fromRGB(255, 255, 255)
            TextBox_3.Text = "Text"
            TextBox_3.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextBox_3.TextScaled = true
            TextBox_3.TextSize = 14.000
            TextBox_3.TextWrapped = true
            TextBox_3.TextXAlignment = Enum.TextXAlignment.Center
            TextBox_3.ZIndex = 500

            return TextBox
        end

        local textBox = makeTextBox()
        textBox.Title.Text = title

        local thisElementNum = self._element_num
        self._element_num = self._element_num+1

        -- handle textBox
        local focusedX = 0.575
        local lostX = 0.3
        local tweenLength = 0.1
        local box = textBox.TextBox.TextBox
        local tween

        local function focus()
            pcall(function()
                tween:Cancel()
            end)
            textBox.TextBox.TextBox.TextXAlignment = Enum.TextXAlignment.Left
            tween = utility:Tween(textBox.TextBox,{Size = UDim2.fromScale(focusedX,0.55)},tweenLength)
        end

        local function loseFocus(enterPressed)
            pcall(function()
                tween:Cancel()
            end)
            coroutine.wrap(callback)(box.Text,enterPressed)
            textBox.TextBox.TextBox.TextXAlignment = Enum.TextXAlignment.Center
            tween = utility:Tween(textBox.TextBox,{Size = UDim2.fromScale(lostX,0.55)},tweenLength)
        end

        box.Focused:Connect(focus)
        box.FocusLost:Connect(loseFocus)

        box.Text = default or ""

        textBox.Name = thisElementNum.."_"..title
        textBox.Parent = self.frame.Contents

        return textBox
    end

    function section:CreateSlider(title,min,max,default,callback,hardLimit,decimalPlaces)
        assert(title and min and max and min<max,"Invalid arguments")
        decimalPlaces = decimalPlaces or 1
        default = default or min
        callback = callback or utility.BlankFunction
        local function makeSlider()
            -- Gui to Lua
            -- Version: 3.2

            -- Instances:

            local Slider = Instance.new("Frame")
            local UICorner = Instance.new("UICorner")
            local Title = Instance.new("TextLabel")
            local Slider_2 = Instance.new("Frame")
            local ImageLabel = Instance.new("ImageLabel")
            local Inside = Instance.new("Frame")
            local ImageLabel_2 = Instance.new("ImageLabel")
            local Button = Instance.new("TextButton")
            local Value = Instance.new("TextBox")

            --Properties:

            Slider.Name = "Slider"
            Slider.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
            Slider.BorderSizePixel = 0
            Slider.Size = UDim2.new(1, 0, 0, 50)
            Slider.ZIndex = 300

            UICorner.CornerRadius = UDim.new(0, 4)
            UICorner.Parent = Slider

            Title.Name = "Title"
            Title.Parent = Slider
            Title.AnchorPoint = Vector2.new(0, 0.5)
            Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Title.BackgroundTransparency = 1.000
            Title.Position = UDim2.new(0.0350000151, 0, 0.319999993, 0)
            Title.Size = UDim2.new(0, 213, 0, 14)
            Title.Font = Enum.Font.Gotham
            Title.Text = "Title"
            Title.TextColor3 = Color3.fromRGB(255, 255, 255)
            Title.TextScaled = true
            Title.TextSize = 14.000
            Title.TextWrapped = true
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.ZIndex = 350

            Slider_2.Name = "Slider"
            Slider_2.Parent = Slider
            Slider_2.Active = true
            Slider_2.AnchorPoint = Vector2.new(0.5, 0.5)
            Slider_2.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
            Slider_2.BackgroundTransparency = 1.000
            Slider_2.Position = UDim2.new(0.5, 0, 0.75, 0)
            Slider_2.Size = UDim2.new(0.925000012, 0, 0.100000001, 0)
            Slider_2.ZIndex = 500

            ImageLabel.Parent = Slider_2
            ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ImageLabel.BackgroundTransparency = 1.000
            ImageLabel.Size = UDim2.new(1, 0, 1, 0)
            ImageLabel.Image = "rbxassetid://10261338527"
            ImageLabel.ImageColor3 = Color3.fromRGB(24, 24, 24)
            ImageLabel.ScaleType = Enum.ScaleType.Slice
            ImageLabel.SliceCenter = Rect.new(100, 100, 100, 100)
            ImageLabel.ZIndex = 300

            Inside.Name = "Inside"
            Inside.Parent = Slider_2
            Inside.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
            Inside.BackgroundTransparency = 1.000
            Inside.Size = UDim2.new(0.5, 0, 1, 0)
            Inside.ZIndex = 300

            ImageLabel_2.Parent = Inside
            ImageLabel_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ImageLabel_2.BackgroundTransparency = 1.000
            ImageLabel_2.Size = UDim2.new(1, 0, 1, 0)
            ImageLabel_2.Image = "rbxassetid://10261338527"
            ImageLabel_2.ScaleType = Enum.ScaleType.Slice
            ImageLabel_2.SliceCenter = Rect.new(100, 100, 100, 100)
            ImageLabel_2.ZIndex = 300

            Button.Name = "Button"
            Button.Parent = Slider_2
            Button.AnchorPoint = Vector2.new(0, 0.5)
            Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Button.BackgroundTransparency = 1.000
            Button.Position = UDim2.new(0, 0, 0.5, 0)
            Button.Size = UDim2.new(1, 0, 2, 0)
            Button.Font = Enum.Font.SourceSans
            Button.Text = ""
            Button.TextColor3 = Color3.fromRGB(0, 0, 0)
            Button.TextSize = 14.000

            Value.Name = "Value"
            Value.Parent = Slider
            Value.AnchorPoint = Vector2.new(1, 0.5)
            Value.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Value.BackgroundTransparency = 1.000
            Value.Position = UDim2.new(0.964999974, 0, 0.319999993, 0)
            Value.Size = UDim2.new(0, 52, 0, 14)
            Value.Font = Enum.Font.Gotham
            Value.Text = "Value"
            Value.TextColor3 = Color3.fromRGB(255, 255, 255)
            Value.TextSize = 14.000
            Value.TextXAlignment = Enum.TextXAlignment.Right
            Value.ZIndex = 300

            return Slider
        end

        local slider = makeSlider()
        slider.Title.Text = title

        local thisElementNum = self._element_num
        self._element_num = self._element_num+1

        -- handle slider
        local dragging = false
        slider.Slider.Button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)

        local _last_text
        local _focused = false

        Run.RenderStepped:Connect(function()
            if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                dragging = false
            end
            if dragging then
                local left = slider.Slider.AbsolutePosition.X-(slider.Slider.AbsoluteSize.X/2)
                local real = mouse.X
                local percent = math.clamp((real-left-slider.Slider.AbsoluteSize.X/2)/slider.Slider.AbsoluteSize.X,0,1)
                slider.Slider.Inside.Size = UDim2.fromScale(percent,1)
                local value = min+((max-min)*percent)
                slider.Value.Text = utility:FormatNumber(value,decimalPlaces)
                coroutine.wrap(callback)(value)
            end
            if _focused == false then
                _last_text = slider.Value.Text
            end
        end)

        slider.Value.Focused:Connect(function()
            _focused = true
        end)

        slider.Value.FocusLost:Connect(function(enterPressed)
            local newValue
            if enterPressed then
                local text = slider.Value.Text
                local num = tonumber(text)
                if num then
                    if hardLimit then
                        num = math.clamp(num,min,max)
                    end
                    slider.Value.Text = utility:FormatNumber(num,decimalPlaces)
                    newValue = num
                    local percent = math.clamp((newValue-min)/(max-min),0,1)
                    slider.Slider.Inside.Size = UDim2.fromScale(percent,1)
                else
                    slider.Value.Text = _last_text
                end
            else
                slider.Value.Text = _last_text
            end

            _focused = false

            if newValue then
                coroutine.wrap(callback)(newValue)
            end
        end)

        local defaultPercent = math.clamp((default-min)/(max-min),0,1)
        slider.Slider.Inside.Size = UDim2.fromScale(defaultPercent,1)
        slider.Value.Text = utility:FormatNumber(default,decimalPlaces)

        slider.Name = thisElementNum.."_"..title
        slider.Parent = self.frame.Contents

        return slider
    end

    function section:CreateColorPicker(title,default,callback)
        assert(title,"Invalid arguments")
        default = default or Color3.new(1,1,1)
        callback = callback or utility.BlankFunction
        local function makeMainPicker()
            -- Gui to Lua
            -- Version: 3.2

            -- Instances:

            local ColorPicker = Instance.new("Frame")
            local UICorner = Instance.new("UICorner")
            local Title = Instance.new("TextLabel")
            local Color = Instance.new("Frame")
            local UICorner_2 = Instance.new("UICorner")
            local Button = Instance.new("TextButton")

            --Properties:

            ColorPicker.Name = "ColorPicker"
            ColorPicker.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
            ColorPicker.BorderSizePixel = 0
            ColorPicker.Size = UDim2.new(1, 0, 0, 32)

            UICorner.CornerRadius = UDim.new(0, 4)
            UICorner.Parent = ColorPicker

            Title.Name = "Title"
            Title.Parent = ColorPicker
            Title.AnchorPoint = Vector2.new(0, 0.5)
            Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Title.BackgroundTransparency = 1.000
            Title.Position = UDim2.new(0.0349880569, 0, 0.5, 0)
            Title.Size = UDim2.new(0.779575229, 0, 0.449999958, 0)
            Title.Font = Enum.Font.Gotham
            Title.Text = "Color Picker"
            Title.TextColor3 = Color3.fromRGB(255, 255, 255)
            Title.TextScaled = true
            Title.TextSize = 20.000
            Title.TextWrapped = true
            Title.TextXAlignment = Enum.TextXAlignment.Left

            Color.Name = "Color"
            Color.Parent = ColorPicker
            Color.AnchorPoint = Vector2.new(1, 0.5)
            Color.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            Color.BorderSizePixel = 0
            Color.Position = UDim2.new(0.977000117, 0, 0.5, 0)
            Color.Size = UDim2.new(0.135373712, 0, 0.550000012, 0)

            UICorner_2.CornerRadius = UDim.new(0, 4)
            UICorner_2.Parent = Color

            Button.Name = "Button"
            Button.Parent = Color
            Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Button.BackgroundTransparency = 1.000
            Button.Size = UDim2.new(1, 0, 1, 0)
            Button.Font = Enum.Font.SourceSans
            Button.Text = ""
            Button.TextColor3 = Color3.fromRGB(0, 0, 0)
            Button.TextSize = 14.000

            return ColorPicker
        end

        local function makePicker()
            -- Gui to Lua
            -- Version: 3.2

            -- Instances:

            local ColorPicker = Instance.new("Frame")
            local UICorner = Instance.new("UICorner")
            local Title = Instance.new("TextLabel")
            local Submit = Instance.new("Frame")
            local Inner = Instance.new("Frame")
            local UICorner_2 = Instance.new("UICorner")
            local Title_2 = Instance.new("TextLabel")
            local Button = Instance.new("TextButton")
            local RGB = Instance.new("Frame")
            local R = Instance.new("Frame")
            local Inner_2 = Instance.new("Frame")
            local UICorner_3 = Instance.new("UICorner")
            local Title_3 = Instance.new("TextLabel")
            local B = Instance.new("Frame")
            local Inner_3 = Instance.new("Frame")
            local UICorner_4 = Instance.new("UICorner")
            local Title_4 = Instance.new("TextLabel")
            local G = Instance.new("Frame")
            local Inner_4 = Instance.new("Frame")
            local UICorner_5 = Instance.new("UICorner")
            local Title_5 = Instance.new("TextLabel")
            local Rainbow = Instance.new("Frame")
            local Rainbow_2 = Instance.new("UIGradient")
            local UICorner_6 = Instance.new("UICorner")
            local Frame = Instance.new("Frame")
            local UICorner_7 = Instance.new("UICorner")
            local Button_2 = Instance.new("TextButton")
            local Second = Instance.new("Frame")
            local UICorner_8 = Instance.new("UICorner")
            local UIGradient = Instance.new("UIGradient")
            local Black = Instance.new("Frame")
            local UIGradient_2 = Instance.new("UIGradient")
            local UICorner_9 = Instance.new("UICorner")
            local Frame_2 = Instance.new("Frame")
            local ImageLabel = Instance.new("ImageLabel")
            local Button_3 = Instance.new("TextButton")
            local Close = Instance.new("ImageLabel")
            local Button_4 = Instance.new("TextButton")

            --Properties:

            ColorPicker.Name = "ColorPicker"
            ColorPicker.BackgroundColor3 = Color3.fromRGB(27, 27, 27)
            ColorPicker.Position = UDim2.new(0.134000003, 490, 0.0780000016, 0)
            ColorPicker.Size = UDim2.new(0, 172, 0, 190)
            ColorPicker.ZIndex = 20

            UICorner.CornerRadius = UDim.new(0, 6)
            UICorner.Parent = ColorPicker

            Title.Name = "Title"
            Title.Parent = ColorPicker
            Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Title.BackgroundTransparency = 1.000
            Title.Position = UDim2.new(0.0530001633, 0, 0.0500000007, 0)
            Title.Size = UDim2.new(0.690999985, 0, 0.0799999982, 0)
            Title.Font = Enum.Font.GothamMedium
            Title.Text = "Color Picker"
            Title.TextColor3 = Color3.fromRGB(255, 255, 255)
            Title.TextScaled = true
            Title.TextSize = 14.000
            Title.TextWrapped = true
            Title.TextXAlignment = Enum.TextXAlignment.Left

            Submit.Name = "Submit"
            Submit.Parent = ColorPicker
            Submit.AnchorPoint = Vector2.new(0.5, 1)
            Submit.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
            Submit.BackgroundTransparency = 1.000
            Submit.BorderSizePixel = 0
            Submit.Position = UDim2.new(0.5, 0, 0.949999988, 0)
            Submit.Size = UDim2.new(0, 150, 0, 21)

            Inner.Name = "Inner"
            Inner.Parent = Submit
            Inner.AnchorPoint = Vector2.new(0.5, 0.5)
            Inner.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
            Inner.BorderSizePixel = 0
            Inner.Position = UDim2.new(0.5, 0, 0.5, 0)
            Inner.Size = UDim2.new(1, 0, 1, 0)

            UICorner_2.CornerRadius = UDim.new(0, 4)
            UICorner_2.Parent = Inner

            Title_2.Name = "Title"
            Title_2.Parent = Inner
            Title_2.AnchorPoint = Vector2.new(0.5, 0.5)
            Title_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Title_2.BackgroundTransparency = 1.000
            Title_2.Position = UDim2.new(0.5, 0, 0.5, 0)
            Title_2.Size = UDim2.new(0.927999973, 0, 0.600000024, 0)
            Title_2.Font = Enum.Font.Gotham
            Title_2.Text = "Submit"
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

            RGB.Name = "RGB"
            RGB.Parent = ColorPicker
            RGB.AnchorPoint = Vector2.new(0.5, 1)
            RGB.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
            RGB.BackgroundTransparency = 1.000
            RGB.BorderSizePixel = 0
            RGB.Position = UDim2.new(0.5, 0, 0.824999988, 0)
            RGB.Size = UDim2.new(0, 150, 0, 21)

            R.Name = "R"
            R.Parent = RGB
            R.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
            R.BackgroundTransparency = 1.000
            R.BorderSizePixel = 0
            R.Size = UDim2.new(0.319999993, 0, 1, 0)

            Inner_2.Name = "Inner"
            Inner_2.Parent = R
            Inner_2.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
            Inner_2.BorderSizePixel = 0
            Inner_2.Size = UDim2.new(1, 0, 1, 0)

            UICorner_3.CornerRadius = UDim.new(0, 4)
            UICorner_3.Parent = Inner_2

            Title_3.Name = "Title"
            Title_3.Parent = Inner_2
            Title_3.AnchorPoint = Vector2.new(0.5, 0.5)
            Title_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Title_3.BackgroundTransparency = 1.000
            Title_3.Position = UDim2.new(0.5, 0, 0.5, 0)
            Title_3.Size = UDim2.new(0.927999973, 0, 0.600000024, 0)
            Title_3.Font = Enum.Font.Gotham
            Title_3.Text = "R: 255"
            Title_3.TextColor3 = Color3.fromRGB(255, 255, 255)
            Title_3.TextScaled = true
            Title_3.TextSize = 14.000
            Title_3.TextWrapped = true

            B.Name = "B"
            B.Parent = RGB
            B.AnchorPoint = Vector2.new(1, 0)
            B.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
            B.BackgroundTransparency = 1.000
            B.BorderSizePixel = 0
            B.Position = UDim2.new(1, 0, 0, 0)
            B.Size = UDim2.new(0.319999993, 0, 1, 0)

            Inner_3.Name = "Inner"
            Inner_3.Parent = B
            Inner_3.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
            Inner_3.BorderSizePixel = 0
            Inner_3.Size = UDim2.new(1, 0, 1, 0)

            UICorner_4.CornerRadius = UDim.new(0, 4)
            UICorner_4.Parent = Inner_3

            Title_4.Name = "Title"
            Title_4.Parent = Inner_3
            Title_4.AnchorPoint = Vector2.new(0.5, 0.5)
            Title_4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Title_4.BackgroundTransparency = 1.000
            Title_4.Position = UDim2.new(0.5, 0, 0.5, 0)
            Title_4.Size = UDim2.new(0.927999973, 0, 0.600000024, 0)
            Title_4.Font = Enum.Font.Gotham
            Title_4.Text = "B: 55"
            Title_4.TextColor3 = Color3.fromRGB(255, 255, 255)
            Title_4.TextScaled = true
            Title_4.TextSize = 14.000
            Title_4.TextWrapped = true

            G.Name = "G"
            G.Parent = RGB
            G.AnchorPoint = Vector2.new(0.5, 0)
            G.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
            G.BackgroundTransparency = 1.000
            G.BorderSizePixel = 0
            G.Position = UDim2.new(0.5, 0, 0, 0)
            G.Size = UDim2.new(0.319999993, 0, 1, 0)

            Inner_4.Name = "Inner"
            Inner_4.Parent = G
            Inner_4.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
            Inner_4.BorderSizePixel = 0
            Inner_4.Size = UDim2.new(1, 0, 1, 0)

            UICorner_5.CornerRadius = UDim.new(0, 4)
            UICorner_5.Parent = Inner_4

            Title_5.Name = "Title"
            Title_5.Parent = Inner_4
            Title_5.AnchorPoint = Vector2.new(0.5, 0.5)
            Title_5.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Title_5.BackgroundTransparency = 1.000
            Title_5.Position = UDim2.new(0.5, 0, 0.5, 0)
            Title_5.Size = UDim2.new(0.927999973, 0, 0.600000024, 0)
            Title_5.Font = Enum.Font.Gotham
            Title_5.Text = "G: 5"
            Title_5.TextColor3 = Color3.fromRGB(255, 255, 255)
            Title_5.TextScaled = true
            Title_5.TextSize = 14.000
            Title_5.TextWrapped = true

            Rainbow.Name = "Rainbow"
            Rainbow.Parent = ColorPicker
            Rainbow.AnchorPoint = Vector2.new(0.5, 0)
            Rainbow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Rainbow.Position = UDim2.new(0.5, 0, 0.600000024, 0)
            Rainbow.Size = UDim2.new(0.843023241, 0, 0.0789473653, 0)

            Rainbow_2.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 4)), ColorSequenceKeypoint.new(0.20, Color3.fromRGB(255, 255, 0)), ColorSequenceKeypoint.new(0.40, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(0.60, Color3.fromRGB(0, 255, 255)), ColorSequenceKeypoint.new(0.80, Color3.fromRGB(0, 0, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 255))}
            Rainbow_2.Name = "Rainbow"
            Rainbow_2.Parent = Rainbow

            UICorner_6.CornerRadius = UDim.new(0, 3)
            UICorner_6.Parent = Rainbow

            Frame.Parent = Rainbow
            Frame.AnchorPoint = Vector2.new(0.5, 0)
            Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Frame.Size = UDim2.new(0.0299999993, 0, 1, 0)

            UICorner_7.CornerRadius = UDim.new(0, 2)
            UICorner_7.Parent = Frame

            Button_2.Name = "Button"
            Button_2.Parent = Rainbow
            Button_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Button_2.BackgroundTransparency = 1.000
            Button_2.Size = UDim2.new(1, 0, 1, 0)
            Button_2.Font = Enum.Font.SourceSans
            Button_2.Text = ""
            Button_2.TextColor3 = Color3.fromRGB(0, 0, 0)
            Button_2.TextSize = 14.000

            Second.Name = "Second"
            Second.Parent = ColorPicker
            Second.Active = true
            Second.AnchorPoint = Vector2.new(0.5, 0)
            Second.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Second.Position = UDim2.new(0.5, 0, 0.200000003, 0)
            Second.Size = UDim2.new(0.843023241, 0, 0.346585691, 0)

            UICorner_8.CornerRadius = UDim.new(0, 3)
            UICorner_8.Parent = Second

            UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))}
            UIGradient.Parent = Second

            Black.Name = "Black"
            Black.Parent = Second
            Black.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Black.BorderSizePixel = 0
            Black.Size = UDim2.new(1, 0, 1, 0)

            UIGradient_2.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 0, 0)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 0, 0))}
            UIGradient_2.Rotation = 90
            UIGradient_2.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 1.00), NumberSequenceKeypoint.new(1.00, 0.00)}
            UIGradient_2.Parent = Black

            UICorner_9.CornerRadius = UDim.new(0, 2)
            UICorner_9.Parent = Black

            Frame_2.Parent = Black
            Frame_2.AnchorPoint = Vector2.new(0.5, 0.5)
            Frame_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Frame_2.BackgroundTransparency = 1.000
            Frame_2.Position = UDim2.new(0, 0, 0, 0)
            Frame_2.Size = UDim2.new(0, 10, 0, 10)

            ImageLabel.Parent = Frame_2
            ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ImageLabel.BackgroundTransparency = 1.000
            ImageLabel.Size = UDim2.new(1, 0, 1, 0)
            ImageLabel.Image = "http://www.roblox.com/asset/?id=10262276317"
            ImageLabel.SliceCenter = Rect.new(128, 128, 128, 128)

            Button_3.Name = "Button"
            Button_3.Parent = Second
            Button_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Button_3.BackgroundTransparency = 1.000
            Button_3.Size = UDim2.new(1, 0, 1, 0)
            Button_3.Font = Enum.Font.SourceSans
            Button_3.Text = ""
            Button_3.TextColor3 = Color3.fromRGB(0, 0, 0)
            Button_3.TextSize = 14.000

            Close.Name = "Close"
            Close.Parent = ColorPicker
            Close.AnchorPoint = Vector2.new(1, 0)
            Close.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Close.BackgroundTransparency = 1.000
            Close.Position = UDim2.new(0.970000029, 0, 0.0299999993, 0)
            Close.Size = UDim2.new(0, 20, 0, 20)
            Close.Image = "http://www.roblox.com/asset/?id=10259890025"

            Button_4.Name = "Button"
            Button_4.Parent = Close
            Button_4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Button_4.BackgroundTransparency = 1.000
            Button_4.Size = UDim2.new(1, 0, 1, 0)
            Button_4.Font = Enum.Font.SourceSans
            Button_4.Text = ""
            Button_4.TextColor3 = Color3.fromRGB(0, 0, 0)
            Button_4.TextSize = 14.000

            return ColorPicker
        end

        local main = makeMainPicker()
        main.Title.Text = title

        for _,v in pairs(main:GetDescendants()) do
            pcall(function()
                v.ZIndex = 400
            end)
        end
        main.ZIndex = 350

        local picker = makePicker()
        picker.Visible = false
        picker.Parent = self.main.ColorPickers
        picker.Title.Text = title

        for _,v in pairs(picker:GetDescendants()) do
            pcall(function()
                v.ZIndex = 400
            end)
        end

        local thisElementNum = self._element_num
        self._element_num = self._element_num+1

        -- handle color picker
        local currentColor = default
        local testingColor = Color3.new(1,1,1)
        local picker1Drag = false
        local picker2Drag = false

        local function togglePicker(toggle)
            picker.Name = os.clock()
            picker.Visible = toggle
        end

        local function updateWithColor(color)
            main.Color.BackgroundColor3 = color
        end

        local function updateRGB(color)
            picker.RGB.R.Inner.Title.Text = "R: "..math.round(color.R*255)
            picker.RGB.G.Inner.Title.Text = "G: "..math.round(color.G*255)
            picker.RGB.B.Inner.Title.Text = "B: "..math.round(color.B*255)
        end

        utility:HandleButton(picker.Submit,function()
            togglePicker(false)
            currentColor = testingColor -- submitted
            coroutine.wrap(callback)(currentColor)
            updateWithColor(currentColor)
            utility:Wait()
            updateWithColor(currentColor)
        end)

        picker.Close.Button.Activated:Connect(function()
            togglePicker(false)
            updateWithColor(currentColor)
            utility:Wait()
            updateWithColor(currentColor)
        end)

        picker.Rainbow.Button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                picker1Drag = true
            end
        end)

        picker.Second.Button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                picker2Drag = true
            end
        end)

        main.Color.Button.Activated:Connect(function()
            togglePicker(true)
        end)

        Run.RenderStepped:Connect(function()
            -- update picker positions
            if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                picker1Drag,picker2Drag = false,false
            end
            if picker1Drag and picker2Drag then
                utility:Warn("Both drag events running at same time")
                picker2Drag = false
            end
            if picker1Drag then
                local left = picker.Rainbow.AbsolutePosition.X-(picker.Rainbow.AbsoluteSize.X/2)
                local real = mouse.X
                local percent = math.clamp((real-left-picker.Rainbow.AbsoluteSize.X/2)/picker.Rainbow.AbsoluteSize.X,0,1)
                picker.Rainbow.Frame.Position = UDim2.fromScale(percent,0)
            elseif picker2Drag then
                local left = picker.Second.AbsolutePosition.X-(picker.Second.AbsoluteSize.X/2)
                local up = picker.Second.AbsolutePosition.Y
                local real = Vector2.new(mouse.X,mouse.Y)
                local percentX = math.clamp((real.X-left-picker.Second.AbsoluteSize.X/2)/picker.Second.AbsoluteSize.X,0,1)
                local percentY = math.clamp((real.Y-up)/picker.Second.AbsoluteSize.Y,0,1)
                picker.Second.Black.Frame.Position = UDim2.fromScale(percentX,percentY)
            end
            if picker.Visible then
                local baseColor = utility:GetColor(picker.Rainbow.Frame.Position.X.Scale,picker.Rainbow.Rainbow.Color.Keypoints)
                local percent_x = picker.Second.Black.Frame.Position.X.Scale
                local percent_y = picker.Second.Black.Frame.Position.Y.Scale
                local mod1Color = Color3.new(utility:Lerp(1,baseColor.R,percent_x),utility:Lerp(1,baseColor.G,percent_x),utility:Lerp(1,baseColor.B,percent_x))
                local mod2Color = Color3.new(utility:Lerp(mod1Color.R,0,percent_y),utility:Lerp(mod1Color.G,0,percent_y),utility:Lerp(mod1Color.B,0,percent_y))
                testingColor = mod2Color
                updateWithColor(testingColor)
                picker.Second.UIGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),ColorSequenceKeypoint.new(1, baseColor)})
                updateRGB(testingColor)
            end
        end)

        updateWithColor(default)

        main.Name = thisElementNum.."_"..title
        main.Parent = self.frame.Contents
        return main
    end

    function section:CreateKeybind(title,default,callback)
        callback = callback or utility.BlankFunction
        local function makeKeybind()
            -- Gui to Lua
            -- Version: 3.2

            -- Instances:

            local Keybind = Instance.new("Frame")
            local UICorner = Instance.new("UICorner")
            local Title = Instance.new("TextLabel")
            local Keybind_2 = Instance.new("Frame")
            local UICorner_2 = Instance.new("UICorner")
            local Bind = Instance.new("TextLabel")
            local Button = Instance.new("TextButton")

            --Properties:

            Keybind.Name = "Keybind"
            Keybind.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
            Keybind.BorderSizePixel = 0
            Keybind.Size = UDim2.new(1, 0, 0, 32)
            Keybind.ZIndex = 300

            UICorner.CornerRadius = UDim.new(0, 4)
            UICorner.Parent = Keybind

            Title.Name = "Title"
            Title.Parent = Keybind
            Title.AnchorPoint = Vector2.new(0, 0.5)
            Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Title.BackgroundTransparency = 1.000
            Title.Position = UDim2.new(0.0349880569, 0, 0.5, 0)
            Title.Size = UDim2.new(0.367012143, 0, 0.449999958, 0)
            Title.Font = Enum.Font.Gotham
            Title.Text = "Keybind"
            Title.TextColor3 = Color3.fromRGB(255, 255, 255)
            Title.TextScaled = true
            Title.TextSize = 20.000
            Title.TextWrapped = true
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.ZIndex = 310

            Keybind_2.Name = "Keybind"
            Keybind_2.Parent = Keybind
            Keybind_2.AnchorPoint = Vector2.new(1, 0.5)
            Keybind_2.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
            Keybind_2.BorderSizePixel = 0
            Keybind_2.Position = UDim2.new(0.976999998, 0, 0.5, 0)
            Keybind_2.Size = UDim2.new(0.3, 0, 0.550000012, 0)
            Keybind_2.ZIndex = 400

            UICorner_2.CornerRadius = UDim.new(0, 4)
            UICorner_2.Parent = Keybind_2

            Bind.Name = "Bind"
            Bind.Parent = Keybind_2
            Bind.Active = true
            Bind.AnchorPoint = Vector2.new(0.5, 0.5)
            Bind.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Bind.BackgroundTransparency = 1.000
            Bind.Position = UDim2.new(0.5, 0, 0.5, 0)
            Bind.Selectable = true
            Bind.Size = UDim2.new(1, -8, 0.75, 0)
            Bind.Font = Enum.Font.Gotham
            Bind.Text = ""
            Bind.TextColor3 = Color3.fromRGB(255, 255, 255)
            Bind.TextScaled = true
            Bind.TextSize = 14.000
            Bind.TextWrapped = true
            Bind.ZIndex = 500

            Button.Name = "Button"
            Button.Parent = Keybind_2
            Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Button.BackgroundTransparency = 1.000
            Button.Size = UDim2.new(1, 0, 1, 0)
            Button.Font = Enum.Font.SourceSans
            Button.Text = ""
            Button.TextColor3 = Color3.fromRGB(0, 0, 0)
            Button.TextSize = 14.000
            Bind.ZIndex = 510

            return Keybind
        end

        local keybind = makeKeybind()
        keybind.Title.Text = title

        local thisElementNum = self._element_num
        self._element_num = self._element_num+1

        -- handle textBox
        local _listening = false

        local function setTo(keyCode,no_callback)
            keybind.Keybind.Bind.Text = keyCode and keyCode.Name or "None"
            if no_callback ~= true then
                coroutine.wrap(callback)(keyCode)
            end
        end

        keybind.Keybind.Button.Activated:Connect(function()
            if _listening then
                setTo(nil)
            else
                keybind.Keybind.Bind.Text = "..."
            end
            _listening = not _listening
        end)

        local keyCodeBlacklist = {
            Enum.KeyCode.I;
            Enum.KeyCode.O;
            Enum.KeyCode.Insert;
            Enum.KeyCode.Delete;
        }

        UIS.InputBegan:Connect(function(input,gpe)
            if _listening and input.UserInputType == Enum.UserInputType.Keyboard and not table.find(keyCodeBlacklist,input.KeyCode) then
                _listening = false
                setTo(input.KeyCode)
            end
        end)

        setTo(default,true)

        keybind.Name = thisElementNum.."_"..title
        keybind.Parent = self.frame.Contents

        return keybind
    end

    function section:CreateDropdown(title,list,callback,closeOnUse,showLast,defaultIndex)
        assert(title,"Missing arguments")
        callback = callback or utility.BlankFunction
        list = list or {}
        if closeOnUse == nil then
            closeOnUse = true
        end
        if showLast == nil then
            showLast = false
        end
        if showLast and defaultIndex and defaultIndex>#list then
            defaultIndex = 1
        end
        local function makeDropdown()
            -- Gui to Lua
            -- Version: 3.2

            -- Instances:

            local Dropdown = Instance.new("Frame")
            local Main = Instance.new("Frame")
            local UICorner = Instance.new("UICorner")
            local Title = Instance.new("TextLabel")
            local Arrow = Instance.new("ImageLabel")
            local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
            local Button = Instance.new("TextButton")
            local Dropdown_2 = Instance.new("Frame")
            local Frame = Instance.new("Frame")
            local UICorner_2 = Instance.new("UICorner")
            local ScrollingFrame = Instance.new("ScrollingFrame")
            local UIListLayout = Instance.new("UIListLayout")
            local _0_padding = Instance.new("Frame")
            local padding = Instance.new("Frame")

            --Properties:

            Dropdown.Name = "Dropdown"
            Dropdown.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
            Dropdown.BackgroundTransparency = 1.000
            Dropdown.BorderSizePixel = 0
            Dropdown.Size = UDim2.new(1, 0, 0, 32)
            Dropdown.AutomaticSize = Enum.AutomaticSize.Y
            Dropdown.ZIndex = 300

            Main.Name = "Main"
            Main.Parent = Dropdown
            Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
            Main.BorderSizePixel = 0
            Main.Size = UDim2.new(1, 0, 0, 32)
            Main.ZIndex = 350

            UICorner.CornerRadius = UDim.new(0, 4)
            UICorner.Parent = Main

            Title.Name = "Title"
            Title.Parent = Main
            Title.AnchorPoint = Vector2.new(0, 0.5)
            Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Title.BackgroundTransparency = 1.000
            Title.Position = UDim2.new(0.0349880569, 0, 0.5, 0)
            Title.Size = UDim2.new(0.779575229, 0, 0.449999958, 0)
            Title.Font = Enum.Font.Gotham
            Title.Text = "Bruh Color"
            Title.TextColor3 = Color3.fromRGB(255, 255, 255)
            Title.TextScaled = true
            Title.TextSize = 20.000
            Title.TextWrapped = true
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.ZIndex = 370

            Arrow.Name = "Arrow"
            Arrow.Parent = Main
            Arrow.AnchorPoint = Vector2.new(1, 0.5)
            Arrow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Arrow.BackgroundTransparency = 1.000
            Arrow.Position = UDim2.new(0.976999998, 0, 0.5, 0)
            Arrow.Size = UDim2.new(0.135000005, 0, 0.550000012, 0)
            Arrow.Image = "http://www.roblox.com/asset/?id=10260760054"
            Arrow.ZIndex = 700

            UIAspectRatioConstraint.Parent = Arrow

            Button.Name = "Button"
            Button.Parent = Main
            Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Button.BackgroundTransparency = 1.000
            Button.Size = UDim2.new(1, 0, 1, 0)
            Button.Font = Enum.Font.SourceSans
            Button.Text = ""
            Button.TextColor3 = Color3.fromRGB(0, 0, 0)
            Button.TextSize = 14.000
            Button.ZIndex = 900

            Dropdown_2.Name = "Dropdown"
            Dropdown_2.Parent = Dropdown
            Dropdown_2.BackgroundColor3 = Color3.fromRGB(27, 27, 27)
            Dropdown_2.BackgroundTransparency = 1.000
            Dropdown_2.ClipsDescendants = true
            Dropdown_2.Position = UDim2.new(0, 0, 0, 32)
            Dropdown_2.Size = UDim2.new(1, 0, 0, 0)
            Dropdown_2.ZIndex = 350

            Frame.Parent = Dropdown_2
            Frame.BackgroundColor3 = Color3.fromRGB(27, 27, 27)
            Frame.Size = UDim2.new(1, 0, 0.927999973, 0)
            Frame.ZIndex = 360

            UICorner_2.CornerRadius = UDim.new(0, 4)
            UICorner_2.Parent = Frame

            ScrollingFrame.Parent = Frame
            ScrollingFrame.Active = true
            ScrollingFrame.AnchorPoint = Vector2.new(0, 0.5)
            ScrollingFrame.BackgroundColor3 = Color3.fromRGB(27, 27, 27)
            ScrollingFrame.BackgroundTransparency = 1.000
            ScrollingFrame.Position = UDim2.new(0, 0, 0.5, 0)
            ScrollingFrame.Size = UDim2.new(1, 0, 0.974137902, 0)
            ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0.5, 0)
            ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
            ScrollingFrame.ScrollBarThickness = 0
            ScrollingFrame.ZIndex = 400

            UIListLayout.Parent = ScrollingFrame
            UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            UIListLayout.Padding = UDim.new(0, 4)

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
            padding.Size = UDim2.new(1, 0, 0, 1)

            return Dropdown
        end

        local dropdown = makeDropdown()
        dropdown.Main.Title.Text = showLast and title..": "..(defaultIndex and list[defaultIndex] or "None") or title

        local thisElementNum = self._element_num
        self._element_num = self._element_num+1

        -- handle dropdown
        local closedHeight = 0
        local openHeight = 125
        local tweenLength = 0.3
        local tween1
        local tween2

        local _dropdown_open = false

        local function _stopTweens()
            pcall(function()
                tween1:Cancel()
            end)
            pcall(function()
                tween2:Cancel()
            end)
        end

        local function open()
            _dropdown_open = true
            _stopTweens()
            local percentAlready = dropdown.Dropdown.Size.Y.Offset/openHeight
            local duration = tweenLength*(1-percentAlready)
            tween1 = utility:Tween(dropdown.Dropdown,{Size = UDim2.new(1,0,0,openHeight)},duration)
            tween2 = utility:Tween(dropdown.Main.Arrow,{Rotation = 180},duration)
        end

        local function close()
            _dropdown_open = false
            _stopTweens()
            local percentAlready = 1-(dropdown.Dropdown.Size.Y.Offset/openHeight)
            local duration = tweenLength*(1-percentAlready)
            tween1 = utility:Tween(dropdown.Dropdown,{Size = UDim2.new(1,0,0,closedHeight)},duration)
            tween2 = utility:Tween(dropdown.Main.Arrow,{Rotation = 0},duration)
        end

        dropdown.Main.Button.Activated:Connect(function()
            if _dropdown_open then
                close()
            else
                open()
            end
        end)

        dropdown.Name = thisElementNum.."_"..title
        dropdown.Parent = self.frame.Contents

        local callback_bindable = Instance.new("BindableEvent")
        callback_bindable.Name = "callback"
        callback_bindable.Event:Connect(function(text,index)
            coroutine.wrap(callback)(text,index)
            if closeOnUse then
                close()
            end
            dropdown.Main.Title.Text = showLast and title..": "..text or title
        end)
        callback_bindable.Parent = dropdown

        self:UpdateDropdown(dropdown,list)

        return dropdown
    end

    -- UPDATE FUNCTIONS
    function section:ClearDropdown(dropdown)
        local scrollingFrame = dropdown.Dropdown.Frame.ScrollingFrame
        for _,v in pairs(scrollingFrame:GetChildren()) do
            if v:IsA("Frame") and v.Name ~= "0_padding" and v.Name ~= "padding" then
                v:Destroy()
            end
        end
    end
    function section:UpdateDropdown(dropdown,list)
        local scrollingFrame = dropdown.Dropdown.Frame.ScrollingFrame
        local callback = dropdown.callback

        self:ClearDropdown(dropdown)

        local function makeDropdownButton()
            -- Gui to Lua
            -- Version: 3.2

            -- Instances:

            local DropdownButton = Instance.new("Frame")
            local Inner = Instance.new("Frame")
            local UICorner = Instance.new("UICorner")
            local Title = Instance.new("TextLabel")
            local Button = Instance.new("TextButton")

            --Properties:

            DropdownButton.Name = "DropdownButton"
            DropdownButton.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
            DropdownButton.BackgroundTransparency = 1.000
            DropdownButton.BorderSizePixel = 0
            DropdownButton.Size = UDim2.new(0.949999988, 0, 0, 32)
            DropdownButton.ZIndex = 1000

            Inner.Name = "Inner"
            Inner.Parent = DropdownButton
            Inner.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
            Inner.BorderSizePixel = 0
            Inner.AnchorPoint = Vector2.new(0.5,0.5)
            Inner.Position = UDim2.fromScale(0.5,0.5)
            Inner.Size = UDim2.new(1, 0, 1, 0)
            Inner.ZIndex = 1010

            UICorner.CornerRadius = UDim.new(0, 4)
            UICorner.Parent = Inner

            Title.Name = "Title"
            Title.Parent = Inner
            Title.AnchorPoint = Vector2.new(0.5, 0.5)
            Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Title.BackgroundTransparency = 1.000
            Title.Position = UDim2.new(0.5, 0, 0.5, 0)
            Title.Size = UDim2.new(0.927512109, 0, 0.449999958, 0)
            Title.Font = Enum.Font.Gotham
            Title.Text = "DropdownButton"
            Title.TextColor3 = Color3.fromRGB(255, 255, 255)
            Title.TextScaled = true
            Title.TextSize = 14.000
            Title.TextWrapped = true
            Title.ZIndex = 1020

            Button.Name = "Button"
            Button.Parent = Inner
            Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Button.BackgroundTransparency = 1.000
            Button.Size = UDim2.new(1, 0, 1, 0)
            Button.Font = Enum.Font.SourceSans
            Button.Text = ""
            Button.TextColor3 = Color3.fromRGB(0, 0, 0)
            Button.TextSize = 14.000
            Button.ZIndex = 1100

            return DropdownButton
        end

        for i,v in ipairs(list) do
            local button = makeDropdownButton()
            button.Name = i.."_"..v
            utility:HandleButton(button,function()
                callback:Fire(v,i)
            end)
            button.Inner.Title.Text = v
            button.Parent = scrollingFrame
        end
    end
end

print("Artemis initiated")

return library
