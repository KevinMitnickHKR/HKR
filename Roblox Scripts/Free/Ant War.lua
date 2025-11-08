--//========= Configuration =========\\--
local universalScript = false
local universalName = "Combat" 
local initialPlace = 11157166793
local earlyScript = false
repeat task.wait() until game:IsLoaded()
if game:GetService("CoreGui"):FindFirstChild("DarkLibV4") then
    game:GetService("CoreGui").DarkLibV4:Destroy()
end

local blurEffect = Instance.new("BlurEffect", game:GetService("Lighting"))
blurEffect.Size = 15
local introEffect = false

task.spawn(function()
    if introEffect then
        game:GetService("TweenService"):Create(
            blurEffect,
            TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
            {Size = 0}
        ):Play()
    end
end)
--//========= Library Source =========\\--
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local MarketplaceService = game:GetService("MarketplaceService")

local darklib = {
  Themes = {
    Greener = {
      ["Color Hub 1"] = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(20, 20, 20)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(27.5, 27.5, 27.5)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(20, 20, 20))
      }),
      ["Color Hub 2"] = Color3.fromRGB(15, 15, 15),
      ["Color Hub 3"] = Color3.fromRGB(85, 255, 0),
      ["Color Hub 4"] = Color3.fromRGB(35, 35, 35),
      ["Color Hub 5"] = Color3.fromRGB(60, 60, 60),
      ["Color Hub 6"] = Color3.fromRGB(50, 50, 50),
      ["Color Hub 7"] = Color3.fromRGB(100, 100, 100),
      ["Color Stroke"] = Color3.fromRGB(30, 30, 30),
      ["Color Theme"] = Color3.fromRGB(68, 81, 0),
      ["Color Text"] = Color3.fromRGB(220, 220, 220),
      ["Color Dark Text"] = Color3.fromRGB(150, 150, 150),
      ["Color Effect"] = Color3.fromRGB(85, 215, 0),
      ["Color Toggle Off"] = Color3.fromRGB(50, 180, 0)
    }
  },
  Info = {
    Version = "1.0.2",
    Theme = "Greener",
    PlaceName = MarketplaceService:GetProductInfo(game.PlaceId).Name
  },
  Icons = loadstring(game:HttpGet("https://raw.githubusercontent.com/Darkmoonxhubscript/DarkLibV4/refs/heads/main/Icons.luau"))(),
  Tabs = {}
}

function GetLibVersion()
  return darklib.Info.Version
  end

function GetLibTheme()
  return darklib.Info.Theme
end

function GetPlaceName()
  return darklib.Info.PlaceName
  end

local ViewportSize = workspace.CurrentCamera.ViewportSize
local UIScale = ViewportSize.Y / 660

local function SetProps(Instance, Props)
    if Props then
        for prop, value in pairs(Props) do
            Instance[prop] = value
        end
    end
    return Instance
end

local function Create(...)
    local args = {...}
    local new = Instance.new(args[1])
    local parent = args[2]
    local props = args[3]
    
    if parent then
        new.Parent = parent
    end
    if props then
        SetProps(new, props)
    end
    return new
end

local function Corner(parent, radius)
    return Create("UICorner", parent, {
        CornerRadius = radius or UDim.new(0, 5)
    })
end

local function Stroke(parent, Colorstk, Thickness, transparecy)
    local new = Create("UIStroke", parent, {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = Colorstk or Color3.fromRGB(120, 120, 120),
        Thickness = Thickness or 0.1,
        Transparency = transparecy or 0
    })
    return new
end

function GetIcon(IconName)
  if IconName:find("rbxassetid://") or IconName:len() < 1 then return IconName end
  IconName = IconName:lower():gsub("lucide", ""):gsub("-", "")
  
  for Name, Icon in pairs(darklib.Icons) do
    Name = Name:gsub("lucide", ""):gsub("-", "")
    if Name == IconName then
      return Icon
    end
  end
  for Name, Icon in pairs(darklib.Icons) do
    Name = Name:gsub("lucide", ""):gsub("-", "")
    if Name:find(IconName) then
      return Icon
    end
  end
  return IconName
end

local function MakeDrag(Instance)
    local Dragging, DragInput, DragStart, StartPosition

    local function Update(input)
        local Delta = input.Position - DragStart
        Instance.Position = UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + Delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset + Delta.Y
        )
    end

    Instance.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPosition = Instance.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    Instance.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            Update(input)
        end
    end)
end

local function optimizeScale()
    local viewportSize = workspace.CurrentCamera.ViewportSize
    local refWidth, refHeight, refScale = 865.176453, 423.529388, 0.6088
    local currentDiagonal = math.sqrt(viewportSize.X^2 + viewportSize.Y^2)
    local refDiagonal = math.sqrt(refWidth^2 + refHeight^2)
    return refScale * (currentDiagonal / refDiagonal)
end

local UiScaleFactor = optimizeScale()
local GetTheme = darklib.Themes[darklib.Info.Theme]

local function hexToString(hex)
    if type(hex)~="string" or #hex%2~=0 then return nil end
    local out={}
    for i=1,#hex,2 do
        local b=tonumber(hex:sub(i,i+1),16)
        if not b then return nil end
        out[#out+1]=string.char(b)
    end
    return table.concat(out)
end

local function deobfuscateToken(token)
    if type(token)~="string" or token:sub(-2)~="42" then return nil,nil end
    local core=token:sub(1,-3)
    local rev=string.reverse(core)
    local decoded=hexToString(rev)
    if not decoded then return nil,nil end
    local sep=decoded:find("|",1,true)
    if not sep then return nil,nil end
    return decoded:sub(1,sep-1),decoded:sub(sep+1)
end

local status
local expiry
spawn(function()
    while true do
        local s,d=pcall(function()
            return game:GetService("HttpService"):JSONDecode(
                game:HttpGet("https://raw.githubusercontent.com/KevinMitnickHKR/HKR/main/Roblox%20Scripts/whitelist.json?t="..tick())
            )
        end)
        if s and d then
            local ns="Not Whitelisted"
            for t,_ in pairs(d)do
                local u,i=deobfuscateToken(t)
                if u==tostring(game.Players.LocalPlayer.UserId)then
                    if i:find("71572910")then
                        ns="VIP"
                    elseif i:find("06018911")then
                        local o,dt=pcall(function()return DateTime.fromIsoDate(i:match("^(.-)|"))end)
                        if o and dt then
                            expiry=dt
                            if DateTime.now().UnixTimestamp<dt.UnixTimestamp then
                                ns="Whitelisted"
                            else
                                ns="Expired"
                            end
                        end
                    elseif i:find("09172910")then
                        ns="Blacklisted"
                    end
                    break
                end
            end
            status=ns
        end
        task.wait(5)
    end
end)
repeat task.wait() until status
if earlyScript and status~="VIP" then
    introEffect = true
    repeat task.wait(9e9) until false
end

if not (status == "VIP" or universalScript) then
    local SystemGui = Create("ScreenGui", CoreGui, { Name = "WhitelistUI", ResetOnSpawn = false })
    local UiScale = Create("UIScale", SystemGui, {
        Scale = UiScaleFactor
    })

    local MainFrame = Create("Frame", SystemGui, {
        Name = "MainFrame",
        BackgroundColor3 = GetTheme["Color Hub 2"],
        Size = UDim2.new(0.5, 0, 0.35, 0),
        Position = UDim2.new(0.5,0,0.5,0),
        AnchorPoint = Vector2.new(0.5,0.5),
        BackgroundTransparency = 0.1,
        Active = true,
        ClipsDescendants = true
    })
    Corner(MainFrame, UDim.new(0,10))
    Stroke(MainFrame, GetTheme["Color Hub 2"],3,0)
    MakeDrag(MainFrame)

    local TopBar = Create("Frame", MainFrame, {
        Name = "TopBar",
        BackgroundColor3 = GetTheme["Color Stroke"],
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 0.5,
        AnchorPoint = Vector2.new(0, 0),
        Position = UDim2.new(0, 0, 0, 0)
    })
    Corner(TopBar, UDim.new(0.2, 0))
    Stroke(TopBar, GetTheme["Color Hub 2"], 1.7, 0)

    local HubTitle = Create("TextLabel", TopBar, {
        Text = "Whitelist System",
        TextColor3 = GetTheme["Color Text"],
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 1
    })

    local CloseButton = Create("TextButton", TopBar, {
        Text = "×",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 28,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 30, 0, 30),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 5, 0.5, 0)
    })
    CloseButton.MouseButton1Click:Connect(function()
        if not introEffect then introEffect = true end
        SystemGui:Destroy()
    end)

    local MinimizeButton = Create("TextButton", TopBar, {
        Text = "-",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 28,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 30, 0, 30),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0)
    })
    local Minimized = false
    MinimizeButton.MouseButton1Click:Connect(function()
        if Minimized then
            MainFrame:TweenSize(UDim2.new(0.5 * UiScaleFactor,0,0.35 * UiScaleFactor,0),"Out","Linear",0.2)
            for _,child in ipairs(MainFrame:GetChildren()) do
                if child.Name~="UICorner" and child.Name~="TopBar" and child.Name~="UIStroke" then
                    task.delay(0.1,function() child.Visible = true end)
                end
            end
            MinimizeButton.Text = "-"
            Minimized = false
        else
            MainFrame:TweenSize(UDim2.new(0.5 * UiScaleFactor,0,0,36 * UiScaleFactor),"Out","Linear",0.2)
            for _,child in ipairs(MainFrame:GetChildren()) do
                if child.Name~="UICorner" and child.Name~="TopBar" and child.Name~="UIStroke" then
                    child.Visible = false
                end
            end
            MinimizeButton.Text = "+"
            Minimized = true
        end
    end)

    local InviteFrame = Create("Frame", MainFrame, {
        BackgroundColor3 = GetTheme["Color Hub 4"],
        Size = UDim2.new(1, -40, 0, 50),
        Position = UDim2.new(0.5, 0, 0.60, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 0.3
    })
    Corner(InviteFrame, UDim.new(0, 6))
    Stroke(InviteFrame, GetTheme["Color Stroke"], 1.5, 0)

    local Icon = Create("ImageButton", InviteFrame, {
        Image = GetIcon("lucide-clipboard-copy"),
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0, 10, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1
    })

    local Link = Create("TextLabel", InviteFrame, {
        Text = "https://discord.gg/QPPJVgyX44",
        TextColor3 = Color3.fromRGB(114, 137, 218),
        Font = Enum.Font.Gotham,
        TextSize = 20,
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 45, 0, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1
    })

    Icon.MouseButton1Click:Connect(function()
        setclipboard("https://discord.gg/QPPJVgyX44")
    end)

    local StatusLabel = Create("TextLabel", MainFrame, {
        Text = "Status: Waiting...",
        TextColor3 = GetTheme["Color Text"],
        Font = Enum.Font.Gotham,
        TextSize = 14,
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5,0,0.92,0),
        BackgroundTransparency = 1
    })

    spawn(function()
        while SystemGui and SystemGui.Parent do
            local text,color = "Status: Not Whitelisted", GetTheme["Color Text"]
            if status == "Whitelisted" then
                text = "Status: Whitelisted"
                color = Color3.fromRGB(0,255,0)
                if expiry then
                    text = text.." | Expires: "..expiry:ToIsoDate()
                end
                task.wait()
                SystemGui:Destroy()
                break
            elseif status == "Expired" then
                text = "Status: Expired"
                color = Color3.fromRGB(255,0,0)
            elseif status == "Blacklisted" then
                text = "Status: Blacklisted"
                color = Color3.fromRGB(255,0,0)
            end
            StatusLabel.Text = text
            StatusLabel.TextColor3 = color
            task.wait()
        end
    end)

    repeat task.wait() until not SystemGui or (not SystemGui.Parent and status == "Whitelisted")
end

function MakeWindow(WindowConfig)
    local Title = WindowConfig[1] or WindowConfig.Title or "DarkLib V3"
    local SubTitle = WindowConfig[2] or WindowConfig.SubTitle or "V1.0"
    local Theme = WindowConfig[3] or WindowConfig.Theme or "Greener"

    darklib.Info.Theme = tostring(Theme)
    local GetTheme = darklib.Themes[darklib.Info.Theme]

    local function optimizeScale()
        local viewportSize = workspace.CurrentCamera.ViewportSize
        local refWidth, refHeight, refScale = 865.176453, 423.529388, 0.6088
        local currentDiagonal = math.sqrt(viewportSize.X^2 + viewportSize.Y^2)
        local refDiagonal = math.sqrt(refWidth^2 + refHeight^2)
        return refScale * (currentDiagonal / refDiagonal)
    end

    local UiScaleFactor = optimizeScale()

    local ScreenGui = Create("ScreenGui", CoreGui, {
        Name = "DarkLibV4",
        ResetOnSpawn = false,
        Enabled = false
    })

    local UiScale = Create("UIScale", ScreenGui, {
        Scale = UiScaleFactor
    })

local NotifyMenu = Create("Frame", ScreenGui, {
    Size = UDim2.new(0, 300, 1, 0),
    Position = UDim2.new(1, 0, 0, 25),
    AnchorPoint = Vector2.new(1, 0),
    BackgroundTransparency = 1
})

Create("UIPadding", NotifyMenu, {
    PaddingLeft = UDim.new(0, 25),
    PaddingTop = UDim.new(0, 25),
    PaddingBottom = UDim.new(0, 50)
})

Create("UIListLayout", NotifyMenu, {
    Padding = UDim.new(0, 25),
    VerticalAlignment = Enum.VerticalAlignment.Bottom
})

------------- NOTIFICATIONS -------------

function NewNotify(Configs)
    local TitleText = Configs.Title or Configs.Name or "Notification"
    local DescriptionText = Configs.Description or Configs.Text or "Description"
    local Time = Configs.Time or math.random(6, 7)
    local ImageId = Configs.Image or "rbxassetid://10709775560"

    local Frame1 = Create("Frame", NotifyMenu, {
        Name = "Frame1",
        Size = UDim2.new(1, 0, 0, 100),
        BackgroundTransparency = 1
    })

    local Frame2 = Create("Frame", Frame1, {
        Name = "Frame2",
        Size = UDim2.new(1, -20, 0, 100),
        BackgroundColor3 = GetTheme["Color Hub 4"],
        BackgroundTransparency = 0.1
    })
    Stroke(Frame2, GetTheme["Color Hub 2"], 3, 0.1)
    Corner(Frame2, UDim.new(0, 8))

    local TopBar = Create("Frame", Frame2, {
        BackgroundColor3 = GetTheme["Color Stroke"],
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 0.5,
        Position = UDim2.new(0, 0, 0, 0)
    })
    Corner(TopBar, UDim.new(0, 5))
    Stroke(TopBar, GetTheme["Color Hub 2"], 1.7, 0)

    local Title = Create("TextLabel", TopBar, {
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Text = TitleText,
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextColor3 = GetTheme["Color Text"],
        TextXAlignment = Enum.TextXAlignment.Center
    })

    local CloseButtonN = Create("TextButton", TopBar, {
        Text = "X",
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        BackgroundTransparency = 1,
        TextColor3 = GetTheme["Color Text"],
        Position = UDim2.new(1, -5, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        Size = UDim2.new(0, 25, 0, 25)
    })

    CloseButtonN.MouseButton1Click:Connect(function()
        Frame1:Destroy()
    end)

    local TimeBar = Create("Frame", Frame2, {
        Size = UDim2.new(1, -20, 0, 2),
        Position = UDim2.new(0, 10, 0, 30),
        BackgroundColor3 = GetTheme["Color Effect"],
        BorderSizePixel = 0
    })
    Corner(TimeBar, UDim.new(0, 1))

    local DescriptionFrame = Create("Frame", Frame2, {
        Size = UDim2.new(1, -20, 0, 60),
        Position = UDim2.new(0, 10, 0, 38),
        BackgroundTransparency = 1,
        ClipsDescendants = true
    })

    if ImageId then
        local ImageContainer = Create("Frame", DescriptionFrame, {
            Size = UDim2.new(0, 70, 1, 0),
            Position = UDim2.new(0, 0, 0, -2),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ClipsDescendants = true
        })

        local ImageLabel = Create("ImageLabel", ImageContainer, {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Image = ImageId,
            ScaleType = Enum.ScaleType.Fit
        })

        local Description = Create("TextLabel", DescriptionFrame, {
            Size = UDim2.new(1, -85, 1, 0),
            Position = UDim2.new(0, 80, 0, 0),
            Text = DescriptionText,
            Font = Enum.Font.Gotham,
            TextSize = 16,
            TextColor3 = GetTheme["Color Dark Text"],
            BackgroundTransparency = 1,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top
        })
    else
        local Description = Create("TextLabel", DescriptionFrame, {
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            Text = DescriptionText,
            Font = Enum.Font.Gotham,
            TextSize = 16,
            TextColor3 = GetTheme["Color Dark Text"],
            BackgroundTransparency = 1,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top
        })
    end

    task.spawn(function()
        local tweenInfo = TweenInfo.new(Time, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        local tween = TweenService:Create(
            TimeBar,
            tweenInfo,
            {Size = UDim2.new(0, 0, 0, 2), Position = UDim2.new(0.5, 0, 0, 30)}
        )
        tween:Play()
        tween.Completed:Wait()
        Frame1:Destroy()
    end)
end

------------- MAIN FRAME ------------- 

local MainFrame = Create("Frame", ScreenGui, {
    Name = "MainFrame",
    BackgroundColor3 = GetTheme["Color Hub 2"],
    Size = UDim2.new(0.5, 0, 0.6, 0), 
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundTransparency = 0.1,
    Active = true
})

Corner(MainFrame, UDim.new(0, 10))
Stroke(MainFrame, GetTheme["Color Hub 2"], 3, 0)
MakeDrag(MainFrame)

local TopBar = Create("Frame", MainFrame, {
    Name = "TopBar",
    BackgroundColor3 = GetTheme["Color Stroke"],
    Size = UDim2.new(1, 0, 0, 36),
    BackgroundTransparency = 0.5,
    Position = UDim2.new(0, 0, 0, 0)
})
Corner(TopBar, UDim.new(0.2, 0))
Stroke(TopBar, GetTheme["Color Hub 2"], 1.7, 0)

local HubTitle = Create("TextLabel", TopBar, {
    Name = "Title",
    Text = Title,
    TextColor3 = status == "VIP" and Color3.fromRGB(255, 215, 0) or GetTheme["Color Text"],
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    TextXAlignment = Enum.TextXAlignment.Left,
    --Size = UDim2.new(0, 0, 1, 0),
    Position = UDim2.new(0, 15, 0.5),
    AnchorPoint = Vector2.new(0, 0.5),
    AutomaticSize = "XY",
    TextWrapped = false,
    BackgroundTransparency = 1
})

local HubSubTitle = Create("TextLabel", HubTitle, {
      Size = UDim2.fromScale(0, 1),
      AutomaticSize = "X",
      AnchorPoint = Vector2.new(0, 1),
      Position = UDim2.new(1, 5, 0.9, 5),
      Text = SubTitle,
      TextColor3 = GetTheme["Color Dark Text"],
      BackgroundTransparency = 1,
      TextXAlignment = "Left",
      TextYAlignment = "Center",
      TextSize = 11,
      Font = Enum.Font.Gotham,
      Name = "SubTitle"
})

local function CreateStatusPair(parent, iconImage, text, layoutOrder, textFont, textSize, textColor, iconYOffset)
    local frame = Create("Frame", parent, {
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 1, 0),
        LayoutOrder = layoutOrder
    })

    local icon = Create("ImageLabel", frame, {
        Size = UDim2.new(0, 18, 0, 18),
        BackgroundTransparency = 1,
        Image = iconImage,
        ImageColor3 = status == "VIP" and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(255, 255, 255),
        Position = UDim2.new(0, 0, 0.5, iconYOffset or 0),
        AnchorPoint = Vector2.new(0, 0.5)
    })

    local label = Create("TextLabel", frame, {
        Text = text,
        TextColor3 = textColor or GetTheme["Color Dark Text"],
        Font = textFont or Enum.Font.GothamBold,
        TextSize = textSize or 12,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        AutomaticSize = Enum.AutomaticSize.X
    })

    return frame, icon, label
end

local StatusContainer = Create("Frame", TopBar, {
    Name = "StatusContainer",
    BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -104, 0.5, 0),
    AutomaticSize = Enum.AutomaticSize.X,
    Size = UDim2.new(0, 0, 1, 0)
})

local StatusLayout = Create("UIListLayout", StatusContainer, {
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 8)
})

local AlarmFrame, AlarmIcon, AlarmLabel = CreateStatusPair(StatusContainer, GetIcon("alarmcheck"), "", 1, Enum.Font.GothamBold, 12)
local FpsFrame, FpsIcon, FpsLabel = CreateStatusPair(StatusContainer, GetIcon("Watch"), "", 2, Enum.Font.GothamBold, 12)
local PingFrame, PingIcon, PingLabel = CreateStatusPair(StatusContainer, GetIcon("Wifi"), "", 3, Enum.Font.GothamBold, 12)
local ExpireFrame, ExpireIcon, ExpireLabel = CreateStatusPair(StatusContainer, GetIcon("Clock"), "00:00:00", 4, Enum.Font.FredokaOne, 16, Color3.fromRGB(255, 170, 0), 2)

local targetHeight = ExpireLabel.AbsoluteSize.Y
for _, frame in ipairs({AlarmFrame, FpsFrame, PingFrame, ExpireFrame}) do
    frame.Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, 0, targetHeight)
end

FpsIcon.Position = UDim2.new(0, 0, 0.5, 0)
FpsLabel.Position = UDim2.new(0, 17, 0.5, 0)

task.spawn(function()
    local Workspace = game:GetService("Workspace")
    while task.wait(1) do
        local seconds = Workspace.DistributedGameTime
        local days = math.floor(seconds / 86400)
        local hours = math.floor((seconds % 86400) / 3600)
        local mins = math.floor((seconds % 3600) / 60)
        local secs = math.floor(seconds % 60)
        local parts = {days, hours, mins, secs}
        while parts[1] == 0 and #parts > 1 do
            table.remove(parts, 1)
        end
        for i = 1, #parts do
            parts[i] = string.format("%02d", parts[i])
        end
        AlarmLabel.Text = table.concat(parts, ":")
    end
end)

local BugButton = Create("ImageButton", TopBar, {
    Name = "Bug",
    Image = GetIcon("Bug"),
    ImageColor3 = status == "VIP" and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 25, 0, 25),
    Position = UDim2.new(1, -90.65, 0.5, 0),
    AnchorPoint = Vector2.new(0, 0.5)
})

local Minimized = false
local MinimizeButton = Create("TextButton", TopBar, {
    Name = "Minimize",
    Text = "-",
    TextColor3 = status == "VIP" and Color3.fromRGB(255, 215, 0) or GetTheme["Color Text"],
    Font = Enum.Font.GothamBold,
    TextSize = 30,
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 30, 0, 30),
    Position = UDim2.new(1, -65, 0, 5)
})

local CloseButton = Create("TextButton", TopBar, {
    Name = "Close",
    Text = "×",
    TextColor3 = status == "VIP" and Color3.fromRGB(255, 215, 0) or GetTheme["Color Text"],
    Font = Enum.Font.GothamBold,
    TextSize = 35,
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 30, 0, 30),
    Position = UDim2.new(1, -35, 0, 5)
})

local FPS, frames, lastFrame = 0, 0, tick()
game:GetService("RunService").RenderStepped:Connect(function()
    frames += 1
    local frame = tick()
    if frame - lastFrame >= 1 then
        FPS = frames
        frames = 0
        lastFrame = frame
        local ping = tonumber(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString():match("%d+")) or 0
        PingLabel.Text = ping .. " MS"
        if ping >= 350 then
            PingLabel.TextColor3 = Color3.fromRGB(255,0,0)
        elseif ping >= 180 then
            PingLabel.TextColor3 = Color3.fromRGB(255,255,0)
        else
            PingLabel.TextColor3 = Color3.fromRGB(0,255,0)
        end
        FpsLabel.Text = "FPS: "  .. FPS
        if FPS < 20 then
            FpsLabel.TextColor3 = Color3.fromRGB(255,0,0)
        elseif FPS <= 30 then
            FpsLabel.TextColor3 = Color3.fromRGB(255,255,0)
        else
            FpsLabel.TextColor3 = Color3.fromRGB(0,255,0)
        end
    end
end)

local mode
local expiryUnix
local lastExpiryUnix

task.spawn(function()
    while true do
        local success, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(
                game:HttpGet("https://raw.githubusercontent.com/KevinMitnickHKR/HKR/main/Roblox%20Scripts/whitelist.json")
            )
        end)

        if success and data then
            local playerId = tostring(game.Players.LocalPlayer.UserId)
            local newMode, newExpiryUnix, newExpiryDT

            if universalScript then
                ExpireIcon.Image = GetIcon("Globe2")
                ExpireIcon.ImageColor3 = Color3.fromRGB(0,191,255)
                ExpireLabel.Text = "[UNIVERSAL]"
                ExpireLabel.TextColor3 = Color3.fromRGB(0,191,255)
                ExpireLabel.Font = Enum.Font.FredokaOne
                newMode = "UNIVERSAL"
            else
                for token in pairs(data) do
                    local uid, iso = deobfuscateToken(token)
                    if uid == playerId then
                        if iso:find("71572910") then
                            ExpireIcon.Image = GetIcon("Crown")
                            ExpireIcon.ImageColor3 = Color3.fromRGB(255,215,0)
                            ExpireLabel.Text = "[VIP]"
                            ExpireLabel.TextColor3 = Color3.fromRGB(255,215,0)
                            ExpireLabel.Font = Enum.Font.FredokaOne
                            newMode = "VIP"
                            break
                        elseif iso:find("06018911") then
                            local iso_part = iso:match("^(.-)|") or iso
                            if not (iso_part:match("Z$") or iso_part:match("[%+%-]%d%d:%d%d$") or iso_part:match("[%+%-]%d%d%d%d$")) then
                                iso_part = iso_part .. "Z"
                            end
                            local ok, dt = pcall(function() return DateTime.fromIsoDate(iso_part) end)
                            if ok and dt then
                                newExpiryUnix = dt.UnixTimestamp
                                newExpiryDT = dt
                                newMode = "EXP"
                                ExpireIcon.Image = GetIcon("Clock")
                                ExpireLabel.TextColor3 = Color3.fromRGB(255,170,0)
                                ExpireIcon.ImageColor3 = Color3.fromRGB(255,170,0)
                            end
                            break
                        end
                    end
                end
            end

            if newExpiryUnix and newExpiryUnix ~= lastExpiryUnix then
                expiryUnix = newExpiryUnix
                lastExpiryUnix = newExpiryUnix
            end
            if newMode then
                mode = newMode
            end
        end
        task.wait(5)
    end
end)

task.spawn(function()
    while true do
        if mode == "EXP" and expiryUnix then
            local remaining = math.max(0, expiryUnix - DateTime.now().UnixTimestamp)
            if remaining <= 0 then
                ExpireIcon.Image = ""
                ExpireLabel.Text = "Expired"
                ExpireLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                if game:GetService("CoreGui"):FindFirstChild("DarkLibV4") then
                    game:GetService("CoreGui").DarkLibV4:Destroy()
                end
                expiryUnix = nil
                lastExpiryUnix = nil
                mode = nil
            else
                local days = math.floor(remaining / 86400)
                local hours = math.floor((remaining / 3600) % 24)
                local mins = math.floor((remaining / 60) % 60)
                local secs = math.floor(remaining % 60)
                local text = string.format("%02d:%02d:%02d:%02d", days, hours, mins, secs)
                text = text:gsub("^00:", "", 1):gsub("^00:", "", 1):gsub("^00:", "", 1):gsub("^0", "", 1)
                local color = remaining <= 60 and Color3.fromRGB(139, 0, 0) or Color3.fromRGB(255, 170, 0)
                ExpireLabel.Text = text
                ExpireLabel.TextColor3 = color
                ExpireIcon.ImageColor3 = color
            end
        end
        task.wait(1)
    end
end)

MinimizeButton.MouseButton1Click:Connect(function()
  if Minimized then
    for _, Comp in pairs(MainFrame:GetChildren()) do
        if Comp.Name ~= "UICorner" and Comp.Name ~= "TopBar" and Comp.Name ~= "UIStroke" and Comp.Name ~= "ExploitersFrame" then
          task.delay(0.1, function()
            Comp.Visible = true
          end)
          end
      end
      local tween1 = TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {Size = UDim2.new(0.5, 0, 0.6, 0)})
  tween1:Play()
  MinimizeButton.Text = "-"
  Minimized = false
    elseif not Minimized then
      for _, Comp in pairs(MainFrame:GetChildren()) do
        if Comp.Name ~= "UICorner" and Comp.Name ~= "TopBar" and Comp.Name ~= "UIStroke" then
          Comp.Visible = false
          end
      end
      local tween = TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {Size = UDim2.new(0.5, 0, 0, 36)})
  tween:Play()
  MinimizeButton.Text = "+"
  Minimized = true
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    game:GetService("TweenService"):Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0)
    }):Play()
    task.delay(0.1, function()
        ScreenGui:Destroy()
    end)
end)

local ExploitersFrame = Create("Frame", MainFrame, {
    Name = "ExploitersFrame",
    Size = UDim2.new(0, 230, 0.8, 0),
    Position = UDim2.new(1, 10, 0.1, 0),
    BackgroundColor3 = GetTheme["Color Hub 2"],
    BackgroundTransparency = 0.08,
    Visible = false,
    ZIndex = 10
})
Corner(ExploitersFrame, UDim.new(0.08, 0))
Stroke(ExploitersFrame, GetTheme["Color Hub 2"], 2, 0)

local Header = Create("Frame", ExploitersFrame, {
    Size = UDim2.new(1, -10, 0, 36),
    Position = UDim2.new(0, 5, 0, 5),
    BackgroundColor3 = GetTheme["Color Hub 4"],
    ZIndex = 11
})
Corner(Header, UDim.new(0.08, 0))

Create("TextLabel", Header, {
    Text = "HKR Exploiters",
    Size = UDim2.new(1, -20, 1, 0),
    Position = UDim2.new(0, 10, 0, 0),
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextColor3 = GetTheme["Color Text"],
    BackgroundTransparency = 1,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 12
})

local ExploitersScroll = Create("ScrollingFrame", ExploitersFrame, {
    Size = UDim2.new(1, 0, 1, -46),
    Position = UDim2.new(0, 0, 0, 46),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollingDirection = Enum.ScrollingDirection.Y,
    ElasticBehavior = Enum.ElasticBehavior.Never,
    ScrollBarThickness = 0,
    ZIndex = 10
})
local listLayout = Create("UIListLayout", ExploitersScroll, {
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder
})
listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ExploitersScroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 8)
end)

local function MakeExploiterCard(nameOrUsername, inServer, player)
    local thumb, uid
    if player then
        thumb = "rbxthumb://type=AvatarHeadShot&id="..player.UserId.."&w=100&h=100"
        uid = player.UserId
    else
        thumb, uid = (function()
            local success, id = pcall(function() return game:GetService("Players"):GetUserIdFromNameAsync(nameOrUsername) end)
            if success then
                local s, t = pcall(function()
                    return game:GetService("Players"):GetUserThumbnailAsync(id, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
                end)
                return (s and t) or "rbxassetid://0", id
            end
            return "rbxassetid://0", 1
        end)()
    end

    local displayName = player and player.DisplayName or nameOrUsername
    local username = player and player.Name or nameOrUsername
    local textColor = inServer and GetTheme["Color Text"] or GetTheme["Color Dark Text"]
    local imageColor = inServer and Color3.fromRGB(85,215,0) or GetTheme["Color Hub 2"]
    local strokeColor = inServer and Color3.fromRGB(50,130,0) or GetTheme["Color Hub 2"]
    local bgColor = GetTheme["Color Hub 4"]

    local Card = Create("Frame", ExploitersScroll, {
        Size = UDim2.new(1, 0, 0, 64),
        BackgroundColor3 = bgColor,
        ZIndex = 10
    })
    Corner(Card, UDim.new(0.12, 0))

    local avatar = Create("ImageLabel", Card, {
        Size = UDim2.new(0, 52, 0, 52),
        Position = UDim2.new(0, 8, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = imageColor,
        BackgroundTransparency = 0.08,
        Image = thumb,
        ZIndex = 11
    })
    Corner(avatar, UDim.new(1, 1))
    local profileStroke = Instance.new("UIStroke")
    profileStroke.Thickness = 2.5
    profileStroke.Color = strokeColor
    profileStroke.Parent = avatar

    Create("TextLabel", Card, {
        Text = displayName,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextColor3 = textColor,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 72, 0, 8),
        Size = UDim2.new(1, -80, 0, 22),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 11
    })

    Create("TextLabel", Card, {
        Text = "@"..username,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = textColor,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 72, 0, 23),
        Size = UDim2.new(1, -80, 0, 20),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 11
    })
end

local function fetchWhitelist()
    local url = "https://raw.githubusercontent.com/KevinMitnickHKR/HKR/main/Roblox%20Scripts/whitelist.json?t="..math.floor(tick())
    local ok, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(game:HttpGet(url))
    end)
    return ok and data or {}
end

for _,plr in ipairs(game:GetService("Players"):GetPlayers()) do
    if plr.UserId ~= game:GetService("Players").LocalPlayer.UserId then
        for token in pairs(fetchWhitelist()) do
            local uid = deobfuscateToken(token)
            if uid and tonumber(uid) == plr.UserId then
                NewNotify({
                    Title = "HKR User Detected!",
                    Description = plr.DisplayName == plr.Name and plr.Name.." is a HKR User." or plr.DisplayName.."(@"..plr.Name..") is a HKR User.",
                    Image = "rbxthumb://type=AvatarHeadShot&id="..plr.UserId.."&w=100&h=100",
                    Time = 10
                })
                break
            end
        end
    end
end

game:GetService("Players").PlayerAdded:Connect(function(plr)
    if plr.UserId ~= game:GetService("Players").LocalPlayer.UserId then
        for token in pairs(fetchWhitelist()) do
            local uid = deobfuscateToken(token)
            if uid and tonumber(uid) == plr.UserId then
                NewNotify({
                    Title = "HKR User Detected!",
                    Description = plr.DisplayName == plr.Name and plr.Name.." is a HKR User." or plr.DisplayName.."(@"..plr.Name..") is a HKR User.",
                    Image = "rbxthumb://type=AvatarHeadShot&id="..plr.UserId.."&w=100&h=100",
                    Time = 8
                })
                break
            end
        end
    end
end)

local function RefreshExploiters()
    for _, c in pairs(ExploitersScroll:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    local whitelist = fetchWhitelist()
    local inServer = {}
    for token in pairs(whitelist) do
        local uid = deobfuscateToken(token)
        if uid then
            uid = tonumber(uid)
            local plr = game:GetService("Players"):GetPlayerByUserId(uid)
            if plr and plr.UserId ~= game:GetService("Players").LocalPlayer.UserId then
                table.insert(inServer, plr)
            end
        end
    end
    table.sort(inServer, function(a,b) return a.DisplayName:lower() < b.DisplayName:lower() end)
    for _, plr in ipairs(inServer) do
        MakeExploiterCard(plr.Name, true, plr)
    end
end

BugButton.MouseButton1Click:Connect(function()
    if Minimized then return end
    ExploitersFrame.Visible = not ExploitersFrame.Visible
    if ExploitersFrame.Visible then
        RefreshExploiters()
    end
end)

game:GetService("Players").PlayerAdded:Connect(function(plr)
    if ExploitersFrame.Visible then
        task.defer(RefreshExploiters)
    end
end)
game:GetService("Players").PlayerRemoving:Connect(function()
    if ExploitersFrame.Visible then
        task.defer(RefreshExploiters)
    end
end)

local LeftBar = Create("Frame", MainFrame, {
    Name = "TabsBar",
    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
    Size = UDim2.new(0, 176, 0, 270),
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 2, 0.1, 0)
})
Corner(LeftBar, UDim.new(0.05, 0))
Stroke(LeftBar, GetTheme["Color Hub 2"], 1.5, 0)

local LeftScrollFrame = Create("ScrollingFrame", LeftBar, {
    Name = "TabsScrollFrame",
    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
    BorderSizePixel = 0,
    Size = UDim2.new(1, 0, 1, 0),
    ScrollBarThickness = 0,
    ScrollBarImageTransparency = 1,
    BackgroundTransparency = 1,
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    CanvasSize = UDim2.new(),
    ElasticBehavior = Enum.ElasticBehavior.Never
})
Create("UIListLayout", LeftScrollFrame, {
  Padding = UDim.new(0, 8),
})

local RightScrollFrame = Create("Frame", MainFrame, {
    Name = "Containers",
    BackgroundColor3 = Color3.fromRGB(28, 28, 28),
    BorderSizePixel = 0,
    BackgroundTransparency = 0.5,
    Size = UDim2.new(0, 470, 0.9, 0),
    Position = UDim2.new(0.3, -15, 0.1, 0)
})
Corner(RightScrollFrame)

local Padding = Create("UIPadding", RightScrollFrame, {
        PaddingLeft = UDim.new(0, 7),
        PaddingRight = UDim.new(0, 7),
        PaddingTop = UDim.new(0, 7),
        PaddingBottom = UDim.new(0, 7)
    })


------------- MENU MOSTRA INFO DO USUARIO ------------- 

local Treco1 = Create("Frame", MainFrame, {
    Name = "Negocio",
    BackgroundColor3 = GetTheme["Color Hub 4"],
    Size = UDim2.new(0, 177, 0, 50),
    BackgroundTransparency = 0.2,
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0, 90, 1, -53)
})
Corner(Treco1, UDim.new(0, 10))  
Stroke(Treco1, GetTheme["Color Hub 2"], 1.5, 0)

local function getProfilePicture(userId)
    local playerThumbnail = Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    return playerThumbnail
end

local profilePictureUrl = getProfilePicture(player.UserId)

local UserName_1 = player.DisplayName

local TrecoImage = Create("ImageLabel", Treco1, {
    Name = "Image",
    Size = UDim2.new(0, 35, 0, 35),
    BackgroundColor3 = status == "VIP" and Color3.fromRGB(255, 215, 0) or GetTheme["Color Hub 2"],
    BackgroundTransparency = 0.5,
    Image = profilePictureUrl,
    Position = UDim2.new(0, 10, 0, 9)
})
Corner(TrecoImage, UDim.new(1, 1))
Stroke(TrecoImage, status == "VIP" and Color3.fromRGB(255, 215, 0) or GetTheme["Color Hub 2"], 3, 0)

local TrecoTextName = Create("TextLabel", Treco1,{
        Text = UserName_1,
        BackgroundTransparency = 1,
        TextColor3 = status == "VIP" and Color3.fromRGB(255, 215, 0) or GetTheme["Color Text"],
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextDirection = "LeftToRight",
        TextScaled = true,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Size = UDim2.new(0, 120, 0, 20),
        Position = UDim2.new(0, 50, 0, 15)
    })
  
  local TrecoHoras = Create("TextLabel", Treco1,{
        Text = "Loading...",
        BackgroundTransparency = 1,
        TextColor3 = GetTheme["Color Dark Text"],
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextDirection = "LeftToRight",
        TextScaled = false,
        TextWrapped = false,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextYAlignment = Enum.TextYAlignment.Center,
        Size = UDim2.new(0, 120, 0, 20),
        Position = UDim2.new(0, 50, 0, 33)
    })
  
  local function formatTime(hour, minute)
    local suffix = hour >= 12 and "PM" or "AM"
    hour = hour % 12
    if hour == 0 then hour = 12 end
    return string.format("%d:%02d %s", hour, minute, suffix)
end

local Hide = false
task.spawn(function()
    while task.wait(0.1) do
        if not Hide then
            local currentTime = os.date("*t")
            local formattedTime = formatTime(currentTime.hour, currentTime.min)
            SetProps(TrecoHoras, {
                Text = formattedTime
            })
        end
    end
end)
  
local Treco2 = Create("TextButton", Treco1, {
    Name = "Hide/Show",
    Size = UDim2.new(0, 177, 0, 50),
    BackgroundTransparency = 1,
    Text = "",
    Position = UDim2.new(0, 0, 0, 0)
})
Treco2.MouseButton1Click:Connect(function()
    if Hide then
        SetProps(TrecoTextName, {
            Text = UserName_1,
            TextColor3 = status == "VIP" and Color3.fromRGB(255, 215, 0) or GetTheme["Color Text"]
        })
        SetProps(TrecoImage, {
            Image = profilePictureUrl,
            ImageColor3 = Color3.new(1, 1, 1),
            BackgroundColor3 = status == "VIP" and Color3.fromRGB(255, 215, 0) or GetTheme["Color Hub 2"]
        })
        Stroke(TrecoImage, status == "VIP" and Color3.fromRGB(255, 215, 0) or GetTheme["Color Hub 2"], 3, 0)
        Stroke(Treco1, status == "VIP" and Color3.fromRGB(255, 215, 0) or GetTheme["Color Hub 2"], 1.5, 0)
        local currentTime = os.date("*t")
        SetProps(TrecoHoras, {
            Text = formatTime(currentTime.hour, currentTime.min),
            TextColor3 = GetTheme["Color Text"]
        })
        Hide = false
    else
        SetProps(TrecoTextName, {
            Text = "Censored",
            TextColor3 = Color3.fromRGB(139, 0, 0)
        })
        SetProps(TrecoImage, {
            Image = "rbxassetid://13793170713",
            ImageColor3 = Color3.fromRGB(139, 0, 0),
            BackgroundColor3 = Color3.fromRGB(139, 0, 0)
        })
        Stroke(TrecoImage, Color3.fromRGB(139, 0, 0), 3, 0)
        Stroke(Treco1, Color3.fromRGB(139, 0, 0), 1.5, 0)
        SetProps(TrecoHoras, {
            Text = "KevinOnTop",
            TextColor3 = Color3.fromRGB(139, 0, 0)
        })
        Hide = true
    end
end)

------------- TABS -------------

local SelectedTab = "" 
local FirstTab = nil 

function NewTab(Configs)
    local TabName = Configs.Name or Configs.Text or "Tab Name"
    local TabIcon = Configs.Icon or "Home"
    local TabButton
    local TabFrame
     
     TabIcon = GetIcon(TabIcon)
    if not TabIcon:find("rbxassetid://") or TabIcon:gsub("rbxassetid://", ""):len() < 6 then
      TabIcon = false
    end
     
    if not FirstTab then
        FirstTab = TabName
        SelectedTab = TabName  
    end
 
    TabButton = Create("TextButton", LeftScrollFrame, {
        Name = "TabButton",
        Text = "",
        TextColor3 = Color3.fromRGB(240, 240, 240),
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        BackgroundColor3 = GetTheme["Color Stroke"],
        Size = UDim2.new(1, -10, 0, 30),
        TextWrapped = false,
        ClipsDescendants = true,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextTruncate = "SplitWord",
        AutomaticSize = Enum.AutomaticSize.X,
        Position = UDim2.new(0, 0, 0, 0),
        AutoButtonColor = false
    })
    Corner(TabButton, UDim.new(0.3, 0))  
    
    local BagulhoAzul = Create("Frame", TabButton, {
        Position = UDim2.new(0, 3, 0, 5),
        BackgroundColor3 = GetTheme["Color Hub 3"],
        Size = UDim2.new(0, 6, 0, 20),
        BackgroundTransparency = 0.8
    })
    Corner(BagulhoAzul, UDim.new(1, 0))  
    
    local TabNameLabel = Create("TextLabel", TabButton,{
        Text = TabName,
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextDirection = "LeftToRight",
        TextTruncate = "SplitWord",
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Size = UDim2.new(0, 140, 0, 20),
        Position = UDim2.new(0, 35, 0, 5)
    })
  
    local TabIcon = Create("ImageLabel", TabButton, {
        Image = TabIcon or GetIcon(Home),
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 11, 0, 5),
        ImageColor3 = Color3.fromRGB(200, 200, 200),
        BackgroundTransparency = 1
    })

    TabFrame = Create("ScrollingFrame", RightScrollFrame, {
      Name = TabName,
      BackgroundTransparency = 1,
      Size = UDim2.new(1, 0, 1, 0),
      Visible = false,
      ScrollBarThickness = 0,
      ScrollBarImageTransparency = 1,
      ElasticBehavior = Enum.ElasticBehavior.Never,
      AutomaticCanvasSize = Enum.AutomaticSize.Y,
      CanvasSize = UDim2.new()
    })

    Create("UIListLayout", TabFrame, {
        Padding = UDim.new(0, 8),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    darklib.Tabs[TabName] = TabFrame

    if SelectedTab == TabName then
      SetProps(TabNameLabel, {
        TextColor3 = Color3.fromRGB(240, 240, 240)
      })
        TabFrame.Visible = true
        local tween = TweenService:Create(BagulhoAzul, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {BackgroundTransparency = 0})
        tween:Play()
        TabButton.BackgroundColor3 = GetTheme["Color Hub 5"]
        TabIcon.ImageColor3 = GetTheme["Color Text"]
    end

    TabButton.MouseButton1Click:Connect(function()
        for _, button in pairs(LeftScrollFrame:GetChildren()) do
            if button:IsA("TextButton") then

                local azul = button:FindFirstChild("Frame")
                if azul then
                    local tween = TweenService:Create(azul, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {BackgroundTransparency = 0.8})
                    tween:Play()
                end
                
                button.BackgroundColor3 = GetTheme["Color Hub 4"]
                TabIcon.ImageColor3 = GetTheme["Color Dark Text"]
            end
        end
        
        for _, Text in pairs(LeftScrollFrame:GetDescendants()) do
            if Text:IsA("TextLabel") then
              SetProps(Text, {
        TextColor3 = GetTheme["Color Dark Text"],
      })
            end
        end
          
          for _, Img in pairs(LeftScrollFrame:GetDescendants()) do
            if Img:IsA("ImageLabel") then
              SetProps(Img, {
        ImageColor3 = GetTheme["Color Dark Text"],
      })
            end
            end
        
        local tween = TweenService:Create(BagulhoAzul, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {BackgroundTransparency = 0})
        tween:Play()
        SetProps(TabNameLabel, {
        TextColor3 = GetTheme["Color Text"]
      })
        TabButton.BackgroundColor3 = GetTheme["Color Hub 5"]
        TabIcon.ImageColor3 = GetTheme["Color Text"]

        for _, frame in pairs(darklib.Tabs) do
            frame.Visible = false
        end
        
        TabFrame.Visible = true
        SelectedTab = TabName 
    end)
    return TabFrame
end

------------- BUTTON -------------

function AddButton(Parent, Configs)
    local Name = Configs[1] or Configs.Name or Configs.Text or "Button"
    local Callback = Configs.Callback or function() print("Clicked") end
    
    local Button = Create("TextButton", Parent, {
        Name = "Button",
        Text = "",
        TextColor3 = Color3.fromRGB(240, 240, 240),
        Font = Enum.Font.GothamMedium,
        TextSize = 20,
        BackgroundColor3 = GetTheme["Color Hub 4"],
        Size = UDim2.new(0, 455, 0, 40),
        TextWrapped = false,
        Position = UDim2.new(0, 10, 0, 0),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        AutoButtonColor = false
    })
    Corner(Button, UDim.new(0.2, 0)) 

    local TextLabel = Create("TextLabel", Button, {
      Text = Name,
      TextColor3 = GetTheme["Color Text"],
      Font = Enum.Font.GothamBold,
      TextSize = 20,
      Size = UDim2.new(0, 408, 0, 40),
      TextWrapped = false,
      BackgroundTransparency = 1,
      Position = UDim2.new(0, 10, 0, 0),
      TextXAlignment = Enum.TextXAlignment.Left,
      TextYAlignment = Enum.TextYAlignment.Center
    })

    local Image = Create("ImageLabel", Button, {
        Image = "rbxassetid://10709791437",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -35, 0, 5),
        BackgroundTransparency = 1
    })

    Button.MouseButton1Click:Connect(function()
      Callback()
  local tween1 = TweenService:Create(TextLabel, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {TextColor3 = GetTheme["Color Effect"]})
  local tween2 = TweenService:Create(Image, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {ImageColor3 = GetTheme["Color Effect"]})
  tween1:Play()
  tween2:Play()
  tween1.Completed:Wait()
  local tween3 = TweenService:Create(TextLabel, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {TextColor3 = GetTheme["Color Text"]})
  local tween4 = TweenService:Create(Image, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {ImageColor3 = GetTheme["Color Text"]})
  tween3:Play()
  tween4:Play()
    end)

    return {
      Button = Button,
      TextLabel = TextLabel
    }
end

function DestroyButton(Button)
  local Button = Button
  Button.Button:Destroy()
  end

function EditButtonText(Button, Text)
  SetProps(Button.TextLabel, {
    Text = tostring(Text)
  })
end

------------- SECTION -------------

function AddSection(Parent, Configs)
    local Name = Configs[1] or Configs.Name or Configs.Text or Configs.Title or "Section"
    
    local SectionLabel = Create("TextLabel", Parent, {
        Name = "Section",
        Size = UDim2.new(0, 455, 0, 20),
        Position = UDim2.new(0, 0, 0, 0),
        Text = Name,
        Font = Enum.Font.GothamBold,
        TextColor3 = GetTheme["Color Text"],
        TextSize = 22,
        BackgroundTransparency = 1,
        TextWrapped = true,
        TextTruncate = "SplitWord",
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    })

    return {
      SectionLabel = SectionLabel
    }
end

function DestroySection(Section)
  local Section = Section
Section.SectionLabel:Destroy()
end

function EditSectionText(Section, Text)
  local Section = Section
    SetProps(Section.SectionLabel, {
      Text = tostring(Text)
    })
end

------------- TEXTLABEL -------------

function AddTextLabel(Parent, Configs)
    local Name = Configs[1] or Configs.Name or Configs.Text or Configs.Title or "TextLabel"
    
    local TextFrame = Create("Frame", Parent, {
        Name = "TextLabel",
        Size = UDim2.new(0, 455, 0, 30),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = GetTheme["Color Hub 4"],
        BackgroundTransparency = 0
    })
    Corner(TextFrame, UDim.new(0.2, 0)) 

    local TextLabel = Create("TextLabel", TextFrame, {
        Size = UDim2.new(0, 440, 0, 30),
        Position = UDim2.new(0, 10, 0, 0),
        Text = Name,
        Font = Enum.Font.GothamBold,
        TextColor3 = GetTheme["Color Text"],
        TextSize = 20,
        BackgroundTransparency = 1,
        TextWrapped = false,
        TextTruncate = "SplitWord",
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    })

    return {
      TextFrame = TextFrame,
      TextLabel = TextLabel
    }
end

function DestroyTextLabel(TextLabel)
  local TextLabel = TextLabel
TextLabel.TextFrame:Destroy()
end

function EditTextLabelText(TextLabel, Text)
  local TextLabel = TextLabel
  SetProps(TextLabel.TextLabel, {
    Text = tostring(Text)
  })
end

------------- PARAGRAPH -------------

function AddParagraph(Parent, Configs)
    local Name = Configs[1] or Configs.Name or Configs.Text or Configs.Title or "My Title"
    local FullDescription = Configs[2] or Configs.Description or Configs.SubText or Configs.SubName or Configs.SubTitle or "My Paragraph"
    
    local MaxHeight = 80
    local ExpandedHeight = 120

    local ParagraphFrame = Create("Frame", Parent, {
        Name = "Paragraph",
        Size = UDim2.new(0, 455, 0, MaxHeight),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = GetTheme["Color Hub 4"],
        BackgroundTransparency = 0
    })
    Corner(ParagraphFrame, UDim.new(0.1, 0)) 

    local ParagraphLabel1 = Create("TextLabel", ParagraphFrame, {
        Size = UDim2.new(0, 435, 0, 20),
        Position = UDim2.new(0, 10, 0, 5),
        Text = Name,
        Font = Enum.Font.GothamBold,
        TextColor3 = GetTheme["Color Text"],
        TextSize = 20,
        BackgroundTransparency = 1,
        TextWrapped = false,
        TextTruncate = "SplitWord",
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top
    })

    local function TruncateText(text, maxLength)
        if #text > maxLength then
            return string.sub(text, 1, maxLength - 3) .. "...", true
        end
        return text, false
    end

    local TruncatedDescription, IsTruncated = TruncateText(FullDescription, 100)

    local ParagraphLabel2 = Create("TextLabel", ParagraphFrame, {
        Size = UDim2.new(0, 435, 0, 50),
        Position = UDim2.new(0, 10, 0, 25),
        Text = IsTruncated and TruncatedDescription or FullDescription,
        Font = Enum.Font.GothamMedium,
        TextColor3 = IsTruncated and Color3.new(0.6, 0.6, 0.6) or GetTheme["Color Dark Text"],
        TextSize = 17,
        BackgroundTransparency = 1,
        TextWrapped = true,
        TextTruncate = "None",
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    })

    local ClickDetector = Create("TextButton", ParagraphFrame, {
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = ""
    })

    local IsExpanded = false
    ClickDetector.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if IsExpanded then
                ParagraphLabel2.Text = TruncatedDescription
                ParagraphLabel2.TextColor3 = Color3.new(0.6, 0.6, 0.6)
                ParagraphFrame.Size = UDim2.new(0, 455, 0, MaxHeight)
            else
                ParagraphLabel2.Text = FullDescription
                ParagraphLabel2.TextColor3 = GetTheme["Color Dark Text"]
                ParagraphFrame.Size = UDim2.new(0, 455, 0, ExpandedHeight)
            end
            IsExpanded = not IsExpanded
        end
    end)

    return {
        ParagraphFrame = ParagraphFrame,
        ParagraphLabel1 = ParagraphLabel1,
        ParagraphLabel2 = ParagraphLabel2
    }
end

function DestroyParagraph(TextLabel)
  local TextLabel = TextLabel
TextLabel.TextFrame:Destroy()
end

function EditParagraphTitle(Paragraph, Text)
  local Paragraph = Paragraph
  SetProps(Paragraph.ParagraphLabel1, {
    Text = tostring(Text)
  })
end

function EditParagraphDescription(Paragraph, Text)
  local Paragraph = Paragraph
  SetProps(Paragraph.ParagraphLabel2, {
    Text = tostring(Text)
  })
end

------------- TOGGLE -------------

function AddToggle(Parent, Configs)
    local Name = Configs[1] or Configs.Name or Configs.Text or Configs.Title or "Toggle"
    local Default = Configs[2] or Configs.Default or false
    local Callback = Configs[3] or Configs.Callback or function() end

if Default == nil or Default == "nil" then
  Default = false
end

    local ToggleFrame1 = Create("Frame", Parent, {
        Name = "Toggle",
        Size = UDim2.new(0, 455, 0, 40),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = GetTheme["Color Hub 4"],
        BackgroundTransparency = 0
    })
    Corner(ToggleFrame1, UDim.new(0.2, 0))

    
    local ToggleFrame2 = Create("Frame", ToggleFrame1, {
        Size = UDim2.new(0, 60, 0, 28),
        Position = UDim2.new(1, -70, 0, 6),
        BackgroundColor3 = GetTheme["Color Hub 5"],
        BackgroundTransparency = 0
    })
    --local Stroke1 = Stroke(ToggleFrame2, GetTheme["Color Hub 6"], 2.5)
    Corner(ToggleFrame2, UDim.new(2, 0))

    local ToggleActive = Create("Frame", ToggleFrame1, {
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0.1, 345, 1, -11),
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = GetTheme["Color Toggle Off"],
        BackgroundTransparency = 0.8,
        BorderMode = "Middle",
        BorderSizePixel = 0
        
    })
    --local Stroke2 = Stroke(ToggleActive, GetTheme["Color Hub 5"], 2.8)
    Corner(ToggleActive, UDim.new(5, 0))

local TextToggle = Create("TextLabel", ToggleFrame1, {
        Text = Name,
        TextColor3 = GetTheme["Color Text"],
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 350, 0, 40),
        Position = UDim2.new(0, 10, 0, 0),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        TextTruncate = "SplitWord",
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    })

    local ToggleButtonArea = Create("TextButton", ToggleFrame1, {
        Text = "",
        Size = UDim2.new(0, 60, 0, 28),
        Position = UDim2.new(1, -70, 0, 6),
        BackgroundTransparency = 1
    })

    local ToggleState = Default

    ToggleButtonArea.MouseButton1Click:Connect(function()
        if ToggleState then
    SetProps(ToggleActive, {
      BackgroundColor3 = GetTheme["Color Toggle Off"],
      BackgroundTransparency = 0.8
    })
          local tween = TweenService:Create(ToggleActive, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {Position = UDim2.new(0.1, 345, 1, -11)})
          tween:Play()
          tween.Completed:Wait()
            ToggleState = false
        elseif not ToggleState then
    SetProps(ToggleActive, {
      BackgroundTransparency = 0,
      BackgroundColor3 = GetTheme["Color Hub 3"]
    })
          local tween = TweenService:Create(ToggleActive, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {Position = UDim2.new(1, -34, 1, -11)})
          tween:Play()
          tween.Completed:Wait()
            ToggleState = true
        end
        Callback(ToggleState)
    end)

if Default then
    SetProps(ToggleActive, {
      BackgroundTransparency = 0,
      BackgroundColor3 = GetTheme["Color Hub 3"]
    })
      local tween = TweenService:Create(ToggleActive, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {Position = UDim2.new(1, -34, 1, -11)})
          tween:Play()
          tween.Completed:Wait()
        ToggleState = true
        Callback(ToggleState)
    end

    return {
      ToggleFrame1 = ToggleFrame1,
      TextToggle = TextToggle
    }
end

function DestroyToggle(Toggle)
  local Toggle = Toggle
Toggle.ToggleFrame1:Destroy()
end

function EditToggleText(Toggle, Text)
  local Toggle = Toggle
  SetProps(Toggle.TextToggle, {
    Text = tostring(Text)
  })
end

------------- TEXT BOX -------------

function AddTextBox(Parent, Configs)
  local Name = Configs[1] or Configs.Name or Configs.Text or "TextBox"
  local Default = Configs[2] or Configs.Default or ""
  local AutoClear = Configs[3] or Configs.AutoClear or false
  local PlaceHolder = Configs[4] or Configs.PlaceHolder or "Input"
  local Callback = Configs[5] or Configs.Callback or function() end
  
  if Default == nil or Default == "nil" then
  Default = ""
end

  local TextBoxFrame = Create("Frame", Parent, {
        Name = "TextBox",
        Size = UDim2.new(0, 455, 0, 40),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = GetTheme["Color Hub 4"],
        BackgroundTransparency = 0
    })
    Corner(TextBoxFrame, UDim.new(0.2, 0))
     
     local TextBoxText = Create("TextLabel", TextBoxFrame, {
        Text = Name,
        TextColor3 = Color3.fromRGB(240, 240, 240),
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 250, 0, 25),
        Position = UDim2.new(0, 10, 0, 8),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        TextTruncate = "SplitWord",
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    })
  
  local TextBox = Create("TextBox", TextBoxFrame, {
    Size = UDim2.new(0, 120, 1, -10),
    Position = UDim2.new(1, -130, 0, 5),
    ClearTextOnFocus = AutoClear,
    BackgroundColor3 = GetTheme["Color Hub 5"],
    BackgroundTransparency = 0,
    Text = Default,
    TextColor3 = GetTheme["Color Text"],
    Font = Enum.Font.GothamBold,
    PlaceholderColor3 = GetTheme["Color Dark Text"],
    PlaceholderText = PlaceHolder,
    TextScaled = true
  })
  Stroke(TextBox, GetTheme["Color Stroke"], 2)
  Corner(TextBox)
  
  local Image = Create("ImageLabel", TextBoxFrame, {
        Image = "rbxassetid://15637081879",
        Size = UDim2.new(0, 25, 0, 25),
        Position = UDim2.new(1, -165, 0, 8),
        BackgroundTransparency = 1
    })
  
  Callback(Default)
  TextBox.Focused:Connect(function()
  local tween2 = TweenService:Create(Image, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {ImageColor3 = GetTheme["Color Effect"]})
  tween2:Play()
  end)
  
  TextBox.FocusLost:Connect(function()
    local tween4 = TweenService:Create(Image, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {ImageColor3 = Color3.fromRGB(255, 255, 255)})
  tween4:Play()
    Callback(TextBox.Text)
  end)
     return {
       TextBoxFrame = TextBoxFrame,
       TextBoxText = TextBoxText,
       TextBox = TextBox
     }
  end

function DestroyTextBox(TextBox)
  local TextBox = TextBox
TextBox.TextBoxFrame:Destroy()
end

function EditTextBoxText(TextBox, Text)
  local TextBox = TextBox
  SetProps(TextBox.TextBoxText, {
    Text = tostring(Text)
  })
end

function EditTextBoxInputText(TextBox, Text)
  local TextBox = TextBox
  SetProps(TextBox.TextBox, {
    Text = tostring(Text)
  })
end

function EditTextBoxPlaceholder(TextBox, Text)
  local TextBox = TextBox
  SetProps(TextBox.TextBox, {
    PlaceholderText = tostring(Text)
  })
end

------------- SLIDER -------------

function AddSlider(Parent, Configs)
    local Name = Configs[1] or Configs.Name or Configs.Text or "Slider"
    local Min = Configs[2] or Configs.Min or 0
    local Max = Configs[3] or Configs.Max or 100
    local Increase = Configs[4] or Configs.Increase or 1
    local Default = Configs[5] or Configs.Default or 20
    local Callback = Configs[6] or Configs.Callback or function() end

if Default == nil or Default == "nil" then
  Default = 20
end

    local function SnapToIncrease(value)
        return math.floor(value / Increase + 0.5) * Increase
    end

    Default = math.clamp(SnapToIncrease(Default), Min, Max)
   local defaultPosition = (Default - Min) / (Max - Min)

   Min, Max = Min / Increase, Max / Increase

    local SliderFrame = Create("Frame", Parent, {
        Name = "Slider",
        Size = UDim2.new(0, 455, 0, 40),
        BackgroundColor3 = GetTheme["Color Hub 4"]
    })
    Corner(SliderFrame, UDim.new(0.2, 0))

    local SliderLabel = Create("TextLabel", SliderFrame, {
        Text = Name,
        Size = UDim2.new(1, -230, 0, 25),
        Position = UDim2.new(0, 10, 0, 8),
        Font = Enum.Font.GothamBold,
        TextColor3 = GetTheme["Color Text"],
        BackgroundTransparency = 1,
        TextSize = 20,
        TextTruncate = "SplitWord",
        TextXAlignment = Enum.TextXAlignment.Left,
    })
  
  local SliderValueLabelFrameBackground = Create("Frame", SliderFrame, {
    Size = UDim2.new(1, -410, 0, 25),
    Position = UDim2.new(0, 240, 0, 8),
    BorderSizePixel = 0,
    BackgroundColor3 = GetTheme["Color Stroke"]
  })Corner(SliderValueLabelFrameBackground, UDim.new(0, 7))
Stroke(SliderValueLabelFrameBackground, GetTheme["Color Hub 5"], 2)

    local SliderValueLabel = Create("TextLabel", SliderValueLabelFrameBackground, {
        Text = tostring(Default),
        Size = UDim2.new(1, -90, 0, 25),
        Position = UDim2.new(0, 46, 0, 0),
        Font = Enum.Font.Gotham,
        TextColor3 = GetTheme["Color Text"],
        BackgroundTransparency = 1,
        TextSize = 20,
        TextScaled = true,
        TextTruncate = "SplitWord",
        TextDirection = "RightToLeft"
    })

    local SliderBarBackground = Create("Frame", SliderFrame, {
        Size = UDim2.new(1, -305, 0, 8),
        Position = UDim2.new(0, 295, 0, 16),
        BackgroundColor3 = GetTheme["Color Hub 5"]
    })
    Corner(SliderBarBackground)

    local SliderBar = Create("Frame", SliderBarBackground, {
        Size = UDim2.fromScale((Default - Min) / (Max - Min), 1),
        BackgroundColor3 = GetTheme["Color Hub 3"]
    })
    Corner(SliderBar)

    local SliderButton = Create("Frame", SliderBarBackground, {
        Size = UDim2.new(0, 10, 0, 24),
        Position = UDim2.fromScale((Default - Min) / (Max - Min), 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    })
    Corner(SliderButton)

    local function UpdateSliderValue(position)
        local scaledValue = math.clamp(position, 0, 1)
        local newValue = math.floor((scaledValue * (Max - Min)) + Min)
        newValue = SnapToIncrease(newValue)

        SliderButton.Position = UDim2.new(scaledValue, 0, 0.5, 0)
        SliderBar.Size = UDim2.new(scaledValue, 0, 1, 0)
        SliderValueLabel.Text = tostring(newValue * Increase)
        Callback(newValue * Increase)
    end

    local defaultPosition = (Default - Min) / (Max - Min)
    UpdateSliderValue(defaultPosition)

local dragging = false

    SliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local connection
            connection = UIS.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local relativePosition = (input.Position.X - SliderBarBackground.AbsolutePosition.X) / SliderBarBackground.AbsoluteSize.X
                    UpdateSliderValue(relativePosition)
                    local tween1 = TweenService:Create(SliderValueLabel, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {Rotation = math.random(-15, 15)})
                    tween1:Play()
                    tween1.Completed:Wait()
                    local tween2 = TweenService:Create(SliderValueLabel, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {Rotation = 0})
                    tween2:Play()
                end
            end)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    connection:Disconnect()
                end
            end)
        end
    end)

    return {
        SliderFrame = SliderFrame,
        SliderLabel = SliderLabel,
        SliderValueLabel = SliderValueLabel,
        Min = Min,
        Max = Max,
        Increase = Increase,
        Func = UpdateSliderValue
    }
end


function DestroySlider(Slider)
  local Slider = Slider
Slider.SliderFrame:Destroy()
end

function EditSliderText(Slider, Text)
  local Slider = Slider
  SetProps(Slider.SliderLabel, {
    Text = tostring(Text)
  })
end

function EditSliderValue(Slider, Value)
  local Slider = Slider
  local Min = Slider.Min
  local Max = Slider.Max
  local NewValue = (Value - Min) / (Max - Min)
  
  Slider.Func(NewValue)
  SetProps(Slider.SliderValueLabel, {
    Text = tostring(Value)
  })
end

------------- DROPDOWN -------------

function AddDropDown(Parent, Configs)
    local Name = Configs[1] or Configs.Name or Configs.Text or Configs.Title or "Dropdown"
    local Options = Configs[2] or Configs.Options or {"1", "2"}
    local MultiSelect = Configs[3] or Configs.MultiSelect or false
    local Default = Configs[4] or Configs.Default or (MultiSelect and {} or "1")
    local Callback = Configs[5] or Configs.Callback or function() end

    local OpcoesAtuais = {}
    local OpcoesClicadas = {}

    local DropdownFrame = Create("Frame", Parent, {
        Name = "Dropdown",
        Size = UDim2.new(0, 455, 0, 40),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = GetTheme["Color Hub 4"],
        BackgroundTransparency = 0
    })
    Corner(DropdownFrame, UDim.new(0, 10))

    local DropButton = Create("TextButton", DropdownFrame, {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -40, 0, 5),
        BackgroundColor3 = GetTheme["Color Hub 4"],
        BackgroundTransparency = 1,
        Text = ""
    })

    local DropDownText1 = Create("TextLabel", DropdownFrame, {
        Size = UDim2.new(1, -210, 0, 25),
        Position = UDim2.new(0, 10, 0, 8),
        Text = Name,
        Font = Enum.Font.GothamBold,
        TextColor3 = GetTheme["Color Text"],
        TextSize = 20,
        BackgroundTransparency = 1,
        TextWrapped = false,
        TextTruncate = "SplitWord",
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    })

    local DropDownText2Frame = Create("Frame", DropdownFrame, {
        Size = UDim2.new(0, 150, 0, 30),
        Position = UDim2.new(0, 260, 0, 5),
        BackgroundColor3 = GetTheme["Color Hub 5"],
        BackgroundTransparency = 0
    })
    Corner(DropDownText2Frame)

    local DropDownText2 = Create("TextLabel", DropdownFrame, {
        Size = UDim2.new(0, 150, 0, 30),
        Position = UDim2.new(0, 260, 0, 5),
        Text = MultiSelect and table.concat(Default, ", ") or Default,
        Font = Enum.Font.GothamMedium,
        TextColor3 = GetTheme["Color Text"],
        TextSize = 15,
        BackgroundTransparency = 1,
        TextScaled = true,
        TextDirection = "RightToLeft",
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center
    })

    local ListDrop = Create("ScrollingFrame", DropdownFrame, {
        Name = "listdrop",
        Size = UDim2.new(1, -4, 1, -41),
        Position = UDim2.new(0, 2, 1, 0),
        AnchorPoint = Vector2.new(0, 1),
        Visible = false,
        BackgroundTransparency = 1,
        BackgroundColor3 = Color3.fromRGB(100, 100, 100),
        ScrollingDirection = "Y",
        ElasticBehavior = "Never",
        ScrollBarThickness = 0,
        AutomaticCanvasSize = "Y",
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })

    local Setinha = Create("ImageLabel", DropdownFrame, {
        Image = "rbxassetid://6031090990",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -40, 0, 5),
        BackgroundTransparency = 1
    })

    Create("UIPadding", ListDrop, {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 0)
    })

    Create("UIListLayout", ListDrop, {
        Padding = UDim.new(0, 5)
    })

    local function AddOption(optName)
        local NewOption = Create("TextButton", ListDrop, {
            Name = "Option",
            Size = UDim2.new(1, 0, 0, 20),
            Text = "",
            TextSize = 15,
            Font = Enum.Font.GothamBold,
            TextColor3 = GetTheme["Color Text"],
            BackgroundTransparency = 0.5,
            TextXAlignment = "Left",
            AutoButtonColor = false,
            BackgroundColor3 = GetTheme["Color Hub 6"],
        })
        Corner(NewOption)

        local TextLabel = Create("TextLabel", NewOption, {
            Name = "OptionTextLabel",
            Size = UDim2.new(0, 415, 0, 20),
            Position = UDim2.new(0, 12, 0, 0),
            Text = optName,
            TextSize = 15,
            Font = Enum.Font.GothamBold,
            TextColor3 = GetTheme["Color Dark Text"],
            BackgroundTransparency = 1,
            TextXAlignment = "Left",
            TextWrapped = false,
            TextTruncate = "SplitWord"
        })

        local BagulhoAzul = Create("Frame", NewOption, {
            Name = "BagulhoAzul",
            Position = UDim2.new(0, 3, 0, 2),
            BackgroundColor3 = GetTheme["Color Hub 3"],
            Size = UDim2.new(0, 5, 0, 16),
            BackgroundTransparency = 0.7
        })
        Corner(BagulhoAzul)

        local isSelected = false
        if MultiSelect then
            if typeof(Default) == "table" and table.find(Default, optName) then
                isSelected = true
                table.insert(OpcoesClicadas, NewOption)
                DropDownText2.Text = table.concat(Default, ", ")
            end
        else
            if optName == Default then
                isSelected = true
                DropDownText2.Text = optName
                Callback(optName)
            end
        end

        if isSelected then
            local tween5 = TweenService:Create(BagulhoAzul, TweenInfo.new(0.2), {BackgroundTransparency = 0})
            tween5:Play()
            TextLabel.TextColor3 = GetTheme["Color Text"]
            NewOption.BackgroundColor3 = GetTheme["Color Hub 7"]
        end

        NewOption.MouseButton1Click:Connect(function()
            if not MultiSelect then
                for _, v in pairs(ListDrop:GetChildren()) do
                    if v.Name == "Option" then
                        TweenService:Create(v.BagulhoAzul, TweenInfo.new(0.2), {BackgroundTransparency = 0.7}):Play()
                        v.OptionTextLabel.TextColor3 = GetTheme["Color Dark Text"]
                        v.BackgroundColor3 = GetTheme["Color Hub 6"]
                    end
                end

                TweenService:Create(BagulhoAzul, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
                TextLabel.TextColor3 = GetTheme["Color Text"]
                NewOption.BackgroundColor3 = GetTheme["Color Hub 7"]
                DropDownText2.Text = optName
                Callback(optName)
            else
                if table.find(OpcoesClicadas, NewOption) then
                    if #OpcoesClicadas > 1 then
                        for i, option in ipairs(OpcoesClicadas) do
                            if option == NewOption then
                                table.remove(OpcoesClicadas, i)
                                break
                            end
                        end
                        TweenService:Create(BagulhoAzul, TweenInfo.new(0.2), {BackgroundTransparency = 0.7}):Play()
                        TextLabel.TextColor3 = GetTheme["Color Dark Text"]
                        NewOption.BackgroundColor3 = GetTheme["Color Hub 6"]
                    end
                else
                    table.insert(OpcoesClicadas, NewOption)
                    TweenService:Create(BagulhoAzul, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
                    TextLabel.TextColor3 = GetTheme["Color Text"]
                    NewOption.BackgroundColor3 = GetTheme["Color Hub 7"]
                end

                local selectedText = ""
                for _, option in ipairs(OpcoesClicadas) do
                    selectedText = selectedText .. option:FindFirstChild("OptionTextLabel").Text .. ", "
                end
                DropDownText2.Text = string.sub(selectedText, 1, -3)
                Callback(DropDownText2.Text)
            end
        end)

        if not table.find(OpcoesAtuais, optName) then
            table.insert(OpcoesAtuais, optName)
            ListDrop.CanvasSize += UDim2.new(0, 0, 0, 25)
        end
    end

    for _, opt in ipairs(Options) do
        AddOption(opt)
    end

    local DropdownOn = false
    DropButton.MouseButton1Click:Connect(function()
        local FrameSizeNew = UDim2.new(0, 455, 0, 100)
        for i, v in ipairs(ListDrop:GetChildren()) do
            if v.Name == "Option" and i <= 7 then
                FrameSizeNew += UDim2.new(0, 0, 0, 35)
            end
        end

        DropdownOn = not DropdownOn
        ListDrop.Visible = DropdownOn
        TweenService:Create(Setinha, TweenInfo.new(0.2), {Rotation = DropdownOn and 180 or 0}):Play()
        TweenService:Create(DropdownFrame, TweenInfo.new(0.2), {Size = DropdownOn and FrameSizeNew or UDim2.new(0, 455, 0, 40)}):Play()
    end)

    ListDrop.CanvasSize += UDim2.new(0, 0, 0, 10)

    function RefreshDropdown(_, NewOptions)
        for _, v in pairs(ListDrop:GetChildren()) do
            if v.Name == "Option" then
                v:Destroy()
            end
        end

        OpcoesAtuais = {}
        ListDrop.CanvasSize = UDim2.new(0, 0, 0, 0)
        for _, opt in ipairs(NewOptions) do
            AddOption(opt)
        end
    end

    return DropdownFrame
end


------------- EXTRA FUNCTIONS -------------

function AddMinimizeButton(Configs)
    local ImageId = Configs[1] or Configs.Icon or Configs.Logo or "10734897102"

    if not ImageId or ImageId == "nil" then
        ImageId = "10734897102"
    end

    if not ImageId:find("rbxassetid://") then
        ImageId = "rbxassetid://" .. ImageId
    end

    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")

    local function detectPlatform()
        if UserInputService.GetPlatform then
            local platform = UserInputService:GetPlatform()
            if platform == Enum.Platform.Android or platform == Enum.Platform.IOS then
                return "Mobile"
            elseif platform == Enum.Platform.Windows or platform == Enum.Platform.OSX then
                return "PC"
            elseif platform == Enum.Platform.XBoxOne then
                return "Console"
            end
        end
        if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
            return "Mobile"
        elseif UserInputService.MouseEnabled then
            return "PC"
        end
        return "Unknown"
    end

    local deviceType = detectPlatform()

    local MinimizeButton = Create("ImageButton", ScreenGui, {
        Image = ImageId,
        AnchorPoint = Vector2.new(0, 0),
        Size = UDim2.new(0, 50, 0, 50),
        Position = UDim2.new(0, 117, 0, 68),
        BackgroundTransparency = 0,
        BackgroundColor3 = GetTheme["Color Hub 5"],
        Visible = true,
        AutoButtonColor = false
    })

    Stroke(MinimizeButton)
    Corner(MinimizeButton, UDim.new(0, 9))
    MakeDrag(MinimizeButton)

    local state = true
    local size = MainFrame.Size
    local pos = MainFrame.Position

    if deviceType == "PC" then
        MainFrame.Visible = false
        state = false
    end

    local function Minimize()
        TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        task.delay(0.1, function()
            MainFrame.Visible = false
            MainFrame.Size = size
            MainFrame.Position = pos
        end)
        state = false
    end

    local function Restore()
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MainFrame.Position = pos
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = size
        }):Play()
        state = true
    end

    UIS.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == Enum.KeyCode.LeftControl and not gameProcessed then
            if Minimized then return end
            if state then Minimize() else Restore() end
        end
    end)

    MinimizeButton.MouseButton1Click:Connect(function()
        if Minimized then return end
        if state then Minimize() else Restore() end
    end)

    if deviceType == "PC" then
        NewNotify({
            Title = "Notification",
            Description = "LeftControl to toggle the UI.",
            Image = nil,
            Time = 4
        })
    end

    return MinimizeButton
end

function AddFloatToggle(Configs)
  local Name = Configs[1] or Configs.Name or Configs.Text or "Toggle"
  local Callback = Configs[2] or Configs.Callback or function() end
  
  local FloatToggle = Create("Frame", ScreenGui, {
    Size = UDim2.new(0, 100, 0, 60),
    Position = UDim2.new(0.8, 0, 0.8, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = GetTheme["Color Hub 5"],
    Draggable = true,
    Active = true,
    Visible = true,
  })Corner(FloatToggle)
   MakeDrag(FloatToggle)
  
  local TextLabel = Create("TextLabel", FloatToggle, {
    Size = UDim2.new(1, 0, 0, 20),
    TextSize = 20,
    Font = Enum.Font.GothamBold,
    TextColor3 = Color3.fromRGB(240, 240, 240),
    Text = Name,
    BackgroundTransparency = 1,
    TextScaled = true,
  })
  
  local Button = Create("TextButton", FloatToggle, {
    Size = UDim2.new(1, 0, 0, 40),
    Position = UDim2.new(0, 0, 0, 20),
    BackgroundTransparency = 1,
    Text = ""
  })
  
  local Frame = Create("Frame", Button, {
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Size = UDim2.new(1, -40, 1, -15),
    BackgroundTransparency = 1
  })Corner(Frame, UDim.new(2, 0))
  
  local Frame2 = Create("Frame", Frame, {
    Position = UDim2.new(0, 5, 0.5, 0),
    AnchorPoint = Vector2.new(0, 0.5),
    Size = UDim2.new(0, 17, 0, 17),
    BackgroundTransparency = 1
  })Corner(Frame2, UDim.new(5, 0))
  
  Stroke(Frame, GetTheme["Color Hub 6"], 1)
  Stroke(Frame2, GetTheme["Color Hub 5"], 1)
  
  local OnOff = false
  Callback(OnOff)
  Button.MouseButton1Click:Connect(function()
    if OnOff == false then
      TweenService:Create(Frame2, TweenInfo.new(0.2, Enum.EasingStyle.Linear),
      {Position = UDim2.new(1, -22, 0.5, 0)}):Play()
    else
      TweenService:Create(Frame2, TweenInfo.new(0.2, Enum.EasingStyle.Linear),
      {Position = UDim2.new(0, 5, 0.5, 0)}):Play()
    end
    OnOff = not OnOff
    Callback(OnOff)
  end)
  
  return FloatToggle
end

function AddDiscordInvite(Parent, Configs)
  local Name = Configs[1] or Configs.Name or Configs.Text or "DarkMoonHub Community"
  local Description = Configs[2] or Configs.Description or "Join our discord community to receive information about the next update"
  local Logo = Configs[3] or Configs.Logo or Configs.Icon or "10734897102"
  local Invite = Configs[4] or Configs.Invite or "https://discord.gg/YDXM43cBU6"
  
  if not Logo:find("rbxassetid://") then
       Logo = "rbxassetid://" .. Logo
       end
  
  local DiscordInviteFrame = Create("Frame", Parent, {
        Name = "DiscordInvite",
        Size = UDim2.new(0, 455, 0, 120),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = GetTheme["Color Hub 4"],
        BackgroundTransparency = 0,
    })
    Corner(DiscordInviteFrame, UDim.new(0, 10))

    local ServerName = Create("TextLabel", DiscordInviteFrame, {
        Name = "ServerName",
        Size = UDim2.new(0, 380, 0, 20),
        Position = UDim2.new(0, 10, 0, 1),
        Text = Name,
        Font = Enum.Font.FredokaOne,
        TextColor3 = Color3.fromRGB(243, 243, 243),
        TextSize = 20,
        BackgroundTransparency = 1,
        TextTruncate = "SplitWord",
        TextWrapped = false,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    })
  
  local Description = Create("TextLabel", DiscordInviteFrame, {
        Name = "Description",
        Size = UDim2.new(0, 370, 0, 40),
        Position = UDim2.new(0, 80, 0, 20),
        Text = Description,
        Font = Enum.Font.Gotham,
        TextTruncate = "SplitWord",
        TextColor3 = Color3.fromRGB(180, 180, 180),
        TextSize = 20,
        BackgroundTransparency = 1,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    })
  
  local ServerInviteLink = Create("TextLabel", DiscordInviteFrame, {
        Name = "ServerInviteLink",
        Size = UDim2.new(0, 370, 0, 20),
        Position = UDim2.new(0, 80, 0, 60),
        Text = Invite,
        TextTruncate = "SplitWord",
        Font = Enum.Font.FredokaOne,
        TextColor3 = Color3.fromRGB(40, 150, 255),
        TextSize = 20,
        BackgroundTransparency = 1,
        TextWrapped = false,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    })
  
  local ServerIcon = Create("ImageLabel", DiscordInviteFrame, {
     Name = "ServerIcon",
     Image = Logo,
     Size = UDim2.new(0, 55, 0, 55),
     Position = UDim2.new(1, -440, 0, 23),
     BackgroundTransparency = 1
   })Corner(ServerIcon, UDim.new(0, 4))Stroke(ServerIcon, GetTheme["Color Hub 5"], 2)
  
  local JoinButton = Create("TextButton", DiscordInviteFrame, {
    Name = "JoinButton",
    Size = UDim2.new(1, -14, 0, 30),
    AnchorPoint = Vector2.new(0.5, 1),
    Position = UDim2.new(0.5, 0, 1, -7),
    Text = "Join Server",
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextScaled = true,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundColor3 = Color3.fromRGB(50, 150, 50),
    AutoButtonColor = false
  })Corner(JoinButton, UDim.new(0, 6))
  
  local ClickDelay
      JoinButton.Activated:Connect(function()
        setclipboard(Invite)
        if ClickDelay then return end
        
        ClickDelay = true
        SetProps(JoinButton, {
          Text = "Copied to Clipboard!",
          BackgroundColor3 = Color3.fromRGB(100, 100, 100),
          TextColor3 = Color3.fromRGB(150, 150, 150)
        })task.wait(5)
        SetProps(JoinButton, {
          Text = "Join Server",
          BackgroundColor3 = Color3.fromRGB(50, 150, 50),
          TextColor3 = Color3.fromRGB(255, 255, 225)
        })ClickDelay = false
      end)
      
      return DiscordInviteFrame
end

end

--//========= Window =========\\--
local Window = MakeWindow({
    Title = universalScript and universalName or (pcall(game.GetService(game,"MarketplaceService").GetProductInfo,game:GetService("MarketplaceService"),initialPlace)and select(2,pcall(game.GetService(game,"MarketplaceService").GetProductInfo,game:GetService("MarketplaceService"),initialPlace)).Name or"GAME"),
    SubTitle = "V1.0",
    Theme = "Greener"
})

AddMinimizeButton({
    Icon = "105855861857949"
})

--//========= Tabs =========\\--
local utilitiesTab = NewTab({
    Name = "Utilities",
    Icon = "Hammer"
})

local visualTab = NewTab({
    Name = "Visual Mods",
    Icon = "View"
})
    
local chamsTab = NewTab({
    Name = "Chams",
    Icon = "Highlighter"
})

--//========= Script =========\\--
local killAuraMode = "Single"
local killAuraC
local autoBiteC
local autoStingC
local autoDigC
local highlightC

local function autoDig()
    autoDigC = game:GetService("RunService").Heartbeat:Connect(function()
        local p = game.Players.LocalPlayer
        local c = p.Character
        if c and c:FindFirstChild("HumanoidRootPart") then
            local s = c.HumanoidRootPart.Position + c.HumanoidRootPart.CFrame.LookVector * 1.5
            local r = workspace:Raycast(s, c.HumanoidRootPart.CFrame.LookVector * 2, RaycastParams.new({workspace.Map.Blocks}, Enum.RaycastFilterType.Whitelist))

            if r and r.Instance and (c.HumanoidRootPart.Position - r.Position).Magnitude <= 4 then
                game:GetService("ReplicatedStorage").ServerEvents.Dig:FireServer(r.Instance.Position)
            end
        end
    end)
end

local function killAura()
    local t = 0
    local currentTarget = nil
    killAuraC = game:GetService("RunService").Heartbeat:Connect(function()
        local lp = game.Players.LocalPlayer
        if lp.Character and lp.Character:FindFirstChild("Humanoid") and lp.Character.Humanoid.Health > 0 then
            if killAuraMode == "Single" then
                if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = currentTarget.Character.HumanoidRootPart
                    local hum = currentTarget.Character.Humanoid
                    local dist = (lp.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                    if hum.Health <= 0 or dist > 20 then
                        currentTarget = nil
                    else
                        game.ReplicatedStorage.ServerEvents.Bite:FireServer("Bite", hum, hrp)
                        if tick() - t >= 0.4 then
                            t = tick()
                            local s = Instance.new("Sound", lp.Character.HumanoidRootPart)
                            s.SoundId = "rbxassetid://9125466839"
                            s:Play()
                            local a = Instance.new("Animation")
                            a.AnimationId = "rbxassetid://11157253523"
                            local tr = lp.Character.Humanoid:FindFirstChildOfClass("Animator"):LoadAnimation(a)
                            tr:Play()
                            tr:AdjustSpeed(0.5)
                            task.wait(0.4)
                            tr:Stop()
                        end
                    end
                else
                    local lowest = nil
                    local lowestHealth = math.huge
                    for _, v in ipairs(game.Players:GetPlayers()) do
                        if v ~= lp and v.Team ~= lp.Team and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                            local d = (lp.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                            if d < 20 and v.Character.Humanoid.Health < lowestHealth then
                                lowest = v
                                lowestHealth = v.Character.Humanoid.Health
                            end
                        end
                    end
                    currentTarget = lowest
                end
            end
            if killAuraMode == "Multi" then
                for _, v in ipairs(game.Players:GetPlayers()) do
                    if v ~= lp and v.Team ~= lp.Team and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                        local d = (lp.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                        if d < 20 then
                            game.ReplicatedStorage.ServerEvents.Bite:FireServer("Bite", v.Character.Humanoid, v.Character.HumanoidRootPart)
                            if tick() - t >= 0.4 then
                                t = tick()
                                local s = Instance.new("Sound", lp.Character.HumanoidRootPart)
                                s.SoundId = "rbxassetid://9125466839"
                                s:Play()
                                local a = Instance.new("Animation")
                                a.AnimationId = "rbxassetid://11157253523"
                                local tr = lp.Character.Humanoid:FindFirstChildOfClass("Animator"):LoadAnimation(a)
                                tr:Play()
                                tr:AdjustSpeed(0.5)
                                task.wait(0.4)
                                tr:Stop()
                            end
                        end
                    end
                end
            end
            for _, c in pairs(game.Workspace.Map.Chambers:GetChildren()) do
                if c:FindFirstChild("Queen") and c.Name ~= lp.Team.Name then
                    local q = c.Queen
                    if q:FindFirstChild("Humanoid") and q.Humanoid.Health > 0 and q:FindFirstChild("HumanoidRootPart") then
                        local dist = (lp.Character.HumanoidRootPart.Position - q.HumanoidRootPart.Position).Magnitude
                        if dist < 20 then
                            game.ReplicatedStorage.ServerEvents.Bite:FireServer("Bite", q.Humanoid, q.HumanoidRootPart)
                        end
                    end
                end
            end
        end
    end)
end

local function autoBite()
    local t = 0
    autoBiteC = game:GetService("RunService").Heartbeat:Connect(function()
        local lp = game.Players.LocalPlayer
        if lp.Character and lp.Character:FindFirstChild("Humanoid") and lp.Character.Humanoid.Health > 0 then
            for _, v in ipairs(game.Players:GetPlayers()) do
                if v ~= lp and v.Team ~= lp.Team and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                    local d = (lp.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                    if d < 20 and tick() - t >= 0.5 then
                        t = tick()
                        game.ReplicatedStorage.ServerEvents.Bite:FireServer("Bite", v.Character.Humanoid, v.Character.HumanoidRootPart)
                        local s = Instance.new("Sound", lp.Character.HumanoidRootPart)
                        s.SoundId = "rbxassetid://9125466839"
                        s:Play()
                        local a = Instance.new("Animation")
                        a.AnimationId = "rbxassetid://11157253523"
                        local tr = lp.Character.Humanoid:FindFirstChildOfClass("Animator"):LoadAnimation(a)
                        tr:Play()
                        tr:AdjustSpeed(0.5)
                        task.wait(0.4)
                        tr:Stop()
                    end
                end
            end
            for _, c in pairs(game.Workspace.Map.Chambers:GetChildren()) do
                if c:FindFirstChild("Queen") and c.Name ~= lp.Team.Name then
                    local q = c.Queen
                    if q:FindFirstChild("Humanoid") and q.Humanoid.Health > 0 and q:FindFirstChild("HumanoidRootPart") and (lp.Character.HumanoidRootPart.Position - q.HumanoidRootPart.Position).Magnitude < 20 and tick() - t >= 0.5 then
                        t = tick()
                        game.ReplicatedStorage.ServerEvents.Bite:FireServer("Bite", q.Humanoid, q.HumanoidRootPart)
                    end
                end
            end
        end
    end)
end

local function autoSting()
    local t = 0
    autoStingC = game:GetService("RunService").Heartbeat:Connect(function()
        local lp = game.Players.LocalPlayer
        if lp.Character and lp.Character:FindFirstChild("Humanoid") and lp.Character.Humanoid.Health > 0 then
            for _, v in ipairs(game.Players:GetPlayers()) do
                if v ~= lp and v.Team ~= lp.Team and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                    local d = (lp.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
                    if d < 20 then
                        game.ReplicatedStorage.ServerEvents.Sting:FireServer("Sting", v.Character.Humanoid, v.Character.HumanoidRootPart)
                    end
                end
            end
            for _, c in pairs(game.Workspace.Map.Chambers:GetChildren()) do
                if c:FindFirstChild("Queen") and c.Name ~= lp.Team.Name then
                    local q = c.Queen
                    if q:FindFirstChild("Humanoid") and q.Humanoid.Health > 0 and q:FindFirstChild("HumanoidRootPart") and (lp.Character.HumanoidRootPart.Position - q.HumanoidRootPart.Position).Magnitude < 20 then
                        game.ReplicatedStorage.ServerEvents.Sting:FireServer("Sting", q.Humanoid, q.HumanoidRootPart)
                    end
                end
            end
        end
    end)
end

local function highlight()
    highlightC = game:GetService("RunService").Heartbeat:Connect(function()
        for _, p in ipairs(game.Players:GetPlayers()) do
            if p ~= game.Players.LocalPlayer and p.Team ~= game.Players.LocalPlayer.Team and p.Character then
                local humanoid = p.Character:FindFirstChild("Humanoid")
                if humanoid then
                    if humanoid.Health > 0 then
                        if not p.Character:FindFirstChild("Highlight") then
                            local h = Instance.new("Highlight")
                            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            h.Enabled = true
                            h.FillColor = Color3.fromRGB(255, 0, 0)
                            h.FillTransparency = 1
                            h.OutlineColor = p.TeamColor.Color
                            h.OutlineTransparency = 0
                            h.Parent = p.Character
                        end
                        if not p.Character:FindFirstChild("TeamMarker") then
                            local billboard = Instance.new("BillboardGui")
                            billboard.Name = "TeamMarker"
                            billboard.Parent = p.Character
                            billboard.Size = UDim2.new(0, 4, 0, 4)
                            billboard.Adornee = p.Character:FindFirstChild("Head")
                            billboard.Active = true
                            billboard.AlwaysOnTop = true
                            billboard.Brightness = 1
                            billboard.DistanceLowerLimit = 0
                            billboard.DistanceUpperLimit = -1
                            billboard.Enabled = true
                            billboard.LightInfluence = 1
                            billboard.MaxDistance = math.huge
                            billboard.ClipsDescendants = true
                            local textLabel = Instance.new("TextLabel")
                            textLabel.Name = "TextStuff"
                            textLabel.Parent = billboard
                            textLabel.Size = UDim2.new(1, 0, 1, 0)
                            textLabel.Position = UDim2.new(0, 0, 0, 0)
                            textLabel.BackgroundColor3 = p.TeamColor.Color
                            textLabel.BackgroundTransparency = 0
                            textLabel.BorderColor3 = Color3.fromRGB(27, 42, 53)
                            textLabel.BorderMode = Enum.BorderMode.Outline
                            textLabel.BorderSizePixel = 1
                            textLabel.Text = ""
                            textLabel.TextSize = 14
                            textLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
                            textLabel.TextStrokeTransparency = 0.8
                            textLabel.TextTransparency = 0
                            textLabel.TextDirection = Enum.TextDirection.Auto
                            textLabel.TextScaled = true
                            textLabel.FontFace = Font.new("rbxasset://fonts/families/HighwayGothic.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
                            textLabel.LineHeight = 1
                            textLabel.MaxVisibleGraphemes = -1
                        end
                    else
                        local highlight = p.Character:FindFirstChild("Highlight")
                        if highlight then
                            highlight:Destroy()
                        end
                        local teamMarker = p.Character:FindFirstChild("TeamMarker")
                        if teamMarker then
                            teamMarker:Destroy()
                        end
                    end
                end
            end
        end
    end)
end

local invasionTracerC
local function invasionTracer()
    local gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    gui.IgnoreGuiInset = true
    local txt = Instance.new("TextLabel", gui)
    txt.AnchorPoint = Vector2.new(0.5, 0)
    txt.Position = UDim2.new(0.5, 0, 0, 25)
    txt.Size = UDim2.new(0, 500, 0, 60)
    txt.BackgroundTransparency = 1
    txt.Font = Enum.Font.FredokaOne
    txt.TextScaled = true
    txt.TextColor3 = Color3.fromRGB(255, 140, 0)
    txt.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    txt.TextStrokeTransparency = 0
    txt.Visible = false
    invasionTracerC = game:GetService("RunService").RenderStepped:Connect(function()
        if not game.Players.LocalPlayer.Team then txt.Visible = false return end
        if not workspace.Map.Chambers:FindFirstChild(game.Players.LocalPlayer.Team.Name) then txt.Visible = false return end
        if not workspace.Map.Chambers[game.Players.LocalPlayer.Team.Name]:FindFirstChild("ChamberMud") then txt.Visible = false return end
        local count = 0
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= game.Players.LocalPlayer and p.Team ~= game.Players.LocalPlayer.Team and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                if (p.Character.HumanoidRootPart.Position - workspace.Map.Chambers[game.Players.LocalPlayer.Team.Name].ChamberMud.Position).Magnitude <= 20 then
                    count += 1
                end
            end
        end
        if count > 0 then
            txt.Text = count .. " Enemies are near your Chamber"
            txt.Visible = true
        else
            txt.Visible = false
        end
    end)
end

--// Elements \\--
AddSection(utilitiesTab, {
    Text = "Main"
})

AddDropDown(utilitiesTab, {
    Name = "Kill Aura Mode",
    Options = {
        "Single",
        "Multi"
  },
    MultiSelect = false,
    Default = "Single",
    Callback = function(v)
        killAuraMode = v
    end
})

AddToggle(utilitiesTab, {
    Name = "Kill Aura",
    Default = false,
    Callback = function(v)
        if v then
            killAura()
        else
            killAuraC:Disconnect()
        end
    end
})

AddToggle(utilitiesTab, {
    Name = "Auto Bite",
    Default = false,
    Callback = function(v)
        if v then
            autoBite()
        else
            autoBiteC:Disconnect()
        end
    end
})

AddToggle(utilitiesTab, {
    Name = "Auto Dig",
    Default = false,
    Callback = function(v)
        if v then
            autoDig()
        else
            autoDigC:Disconnect()
        end
    end
})

AddToggle(utilitiesTab, {
    Name = "Auto Sting",
    Default = false,
    Callback = function(v)
        if v then
            autoSting()
        else
            autoStingC:Disconnect()
        end
    end
})

local ii
AddToggle(utilitiesTab, {
    Name = "Instant Interact",
    Default = false,
    Callback = function(v)
        if v then
            ii = game:GetService("ProximityPromptService").PromptButtonHoldBegan:Connect(function(prompt)
                fireproximityprompt(prompt)
            end)
        else
            ii:Disconnect()
        end
    end
})

local autoCollectC
AddToggle(utilitiesTab, {
    Name = "Auto Collect",
    Default = false,
    Callback = function(v)
        if v then
            autoCollectC = game:GetService("RunService").Heartbeat:Connect(function()
                if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    for _,a in ipairs({"Concrete Clan","Leaf Kingdom","Golden Empire","Fire Nation"}) do
                        for _,b in ipairs(workspace.Map.Chambers[a].Larvae:GetChildren()) do
                            if b:FindFirstChild("Base") and b.Base:FindFirstChildOfClass("ProximityPrompt") and (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - b.Base.Position).Magnitude <= b.Base:FindFirstChildOfClass("ProximityPrompt").MaxActivationDistance then
                                fireproximityprompt(b.Base:FindFirstChildOfClass("ProximityPrompt"))
                            end
                        end
                    end
                end
            end)
        else
            if autoCollectC then
                autoCollectC:Disconnect()
                autoCollectC = nil
            end
        end
    end
})

AddToggle(chamsTab, {
    Name = "Enemy Chams",
    Default = false,
    Callback = function(v)
        if v then
            highlight()
        else
            highlightC:Disconnect()
        end
    end
})

--//========= Visual Mods =========\\--
AddSection(visualTab, {
    Text = "Main"
})

local fullBrightEnabled = false
AddButton(visualTab, {
    Name = "FullBright",
    Callback = function()
        fullBrightEnabled = true
    end
})

local noFogEnabled = false
AddButton(visualTab, {
    Name = "NoFog",
    Callback = function()
        noFogEnabled = true
    end
})

task.spawn(function()
    local Lighting = game:GetService("Lighting")
    local targetBrightness = 1
    local targetClockTime = 12
    local targetGlobalShadows = false
    local targetAmbient = Color3.fromRGB(178, 178, 178)
    local targetFogEnd = 100000

    while true do
        if fullBrightEnabled then
            if Lighting.Brightness ~= targetBrightness
            or Lighting.ClockTime ~= targetClockTime
            or Lighting.GlobalShadows ~= targetGlobalShadows
            or Lighting.Ambient ~= targetAmbient then
                Lighting.Brightness = targetBrightness
                Lighting.ClockTime = targetClockTime
                Lighting.GlobalShadows = targetGlobalShadows
                Lighting.Ambient = targetAmbient
            end
        end

        if noFogEnabled then
            if Lighting.FogEnd ~= targetFogEnd then
                Lighting.FogEnd = targetFogEnd
            end

            local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
            if atmosphere then
                atmosphere:Destroy()
            end
        end

        task.wait(0.05)
    end
end)

local removeVFXConn
local disabledFX = {}
AddToggle(visualTab, {
	Name = "Remove Visual Effects",
	Default = false,
	Callback = function(v)
		if v then
			for _, x in pairs(game.Lighting:GetChildren()) do
				if tostring(x.ClassName):lower():find("effect") and x.Enabled then
					table.insert(disabledFX, x)
					x.Enabled = false
				end
			end
			removeVFXConn = game.Lighting.ChildAdded:Connect(function(x)
				if tostring(x.ClassName):lower():find("effect") and x.Enabled then
					table.insert(disabledFX, x)
					x.Enabled = false
				end
			end)
		else
			for _, x in pairs(disabledFX) do
				if x and x.Parent == game.Lighting then x.Enabled = true end
			end
			disabledFX = {}
			if removeVFXConn then removeVFXConn:Disconnect() removeVFXConn = nil end
		end
	end
})

AddToggle(chamsTab, {
    Name = "Invasion Tracer",
    Default = false,
    Callback = function(v)
        if v then
            invasionTracer()
        else
            invasionTracerC:Disconnect()
        end
    end
})

introEffect = true