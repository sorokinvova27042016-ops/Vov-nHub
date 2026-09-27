-- VovanHub v4.1 ULTRA — MM2
-- Исправлено: меню, Stats, HUD закруглён, стиль улучшен

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

local ICON_ID = "rbxassetid://85459798917792"

local SETTINGS = {
    Enabled = true,
    Wallbang = true,
    AutoShoot = true,
    TargetMurderer = true,
    FOV = 360,
    Smoothness = 0.15,
    ShootDelay = 0.08,
    ESPEnabled = true,
    ESPMurderer = true,
    ESPSheriff = true,
    ESPInnocent = true,
    ESPAvatar = true,
    ESPRainbow = false,
    SpinnerEnabled = false,
    SpinnerSpeed = 50,
    BhopEnabled = false,
    BhopSpeed = 100,
    FlingEnabled = false,
    FlingPower = 100,
    FlingKey = Enum.KeyCode.F,
    NoClipEnabled = false,
    NoClipKey = Enum.KeyCode.N,
    AutoGrabGun = false,
    AutoGrabRadius = 150,
    TpToSheriffKey = Enum.KeyCode.G,
    HaloEnabled = true,
    HaloColorIndex = 1,
    FogEnabled = true,
    FogColorIndex = 1,
    SkyEnabled = true,
    BloomEnabled = true,
    BlurOnMenu = true,
    TrailEnabled = true,
    TrailColorIndex = 1,
    TopHUD = true,
}

local HALO_COLORS = {
    {name="Золотой", color=Color3.fromRGB(255, 215, 0)},
    {name="Розовый", color=Color3.fromRGB(255, 45, 85)},
    {name="Фиолет", color=Color3.fromRGB(120, 60, 255)},
    {name="Голубой", color=Color3.fromRGB(0, 220, 255)},
    {name="Зелёный", color=Color3.fromRGB(80, 240, 120)},
    {name="Красный", color=Color3.fromRGB(255, 60, 60)},
}

local FOG_COLORS = {
    {name="Белый", color=Color3.fromRGB(200, 200, 255)},
    {name="Розовый", color=Color3.fromRGB(255, 180, 220)},
    {name="Фиолет", color=Color3.fromRGB(160, 120, 255)},
    {name="Голубой", color=Color3.fromRGB(120, 200, 255)},
    {name="Зелёный", color=Color3.fromRGB(150, 255, 180)},
}

local TRAIL_COLORS = {
    {name="Розово-фиолетовый", c1=Color3.fromRGB(255, 45, 85), c2=Color3.fromRGB(120, 60, 255), c3=Color3.fromRGB(0, 220, 255)},
    {name="Огненный", c1=Color3.fromRGB(255, 100, 0), c2=Color3.fromRGB(255, 50, 0), c3=Color3.fromRGB(255, 200, 0)},
    {name="Ледяной", c1=Color3.fromRGB(0, 220, 255), c2=Color3.fromRGB(80, 150, 255), c3=Color3.fromRGB(255, 255, 255)},
    {name="Радуга", c1=Color3.fromRGB(255, 0, 0), c2=Color3.fromRGB(0, 255, 0), c3=Color3.fromRGB(0, 0, 255)},
    {name="Матрица", c1=Color3.fromRGB(0, 255, 100), c2=Color3.fromRGB(0, 200, 80), c3=Color3.fromRGB(150, 255, 200)},
    {name="Кислота", c1=Color3.fromRGB(200, 255, 0), c2=Color3.fromRGB(100, 255, 0), c3=Color3.fromRGB(255, 255, 100)},
}

local C = {
    Bg = Color3.fromRGB(8, 8, 12),
    BgGrad1 = Color3.fromRGB(15, 10, 25),
    BgGrad2 = Color3.fromRGB(25, 15, 40),
    Panel = Color3.fromRGB(16, 16, 24),
    PanelLight = Color3.fromRGB(24, 24, 36),
    Card = Color3.fromRGB(20, 20, 30),
    CardHover = Color3.fromRGB(35, 35, 50),
    Accent = Color3.fromRGB(255, 45, 85),
    Accent2 = Color3.fromRGB(120, 60, 255),
    Accent3 = Color3.fromRGB(0, 220, 255),
    Text = Color3.fromRGB(245, 245, 255),
    TextDim = Color3.fromRGB(120, 120, 145),
    ToggleOn = Color3.fromRGB(255, 45, 85),
    ToggleOff = Color3.fromRGB(40, 40, 55),
    Success = Color3.fromRGB(80, 240, 120),
    Danger = Color3.fromRGB(255, 60, 60),
    Innocent = Color3.fromRGB(80, 240, 120),
    Murderer = Color3.fromRGB(255, 60, 60),
    Sheriff = Color3.fromRGB(60, 140, 255),
}

local roleCache = {}

local function getRole(player)
    if not player or not player.Character then return "Innocent" end
    if roleCache[player] then return roleCache[player] end
    local bp = player:FindFirstChild("Backpack")
    if bp then
        if bp:FindFirstChild("Knife") then roleCache[player] = "Murderer"; return "Murderer" end
        if bp:FindFirstChild("Gun") then roleCache[player] = "Sheriff"; return "Sheriff" end
    end
    local char = player.Character
    if char:FindFirstChild("Knife") then roleCache[player] = "Murderer"; return "Murderer" end
    if char:FindFirstChild("Gun") then roleCache[player] = "Sheriff"; return "Sheriff" end
    return "Innocent"
end

local function watchPlayer(player)
    if player == LocalPlayer then return end
    player.CharacterAdded:Connect(function(char)
        roleCache[player] = nil
        char.ChildAdded:Connect(function(child)
            if child.Name == "Knife" then roleCache[player] = "Murderer"
            elseif child.Name == "Gun" then roleCache[player] = "Sheriff" end
        end)
    end)
end

for _, p in pairs(Players:GetPlayers()) do watchPlayer(p) end
Players.PlayerAdded:Connect(watchPlayer)

local atmosphere, sky, bloom, blur

atmosphere = Instance.new("Atmosphere")
atmosphere.Density = 0.5
atmosphere.Offset = 0.3
atmosphere.Color = FOG_COLORS[1].color
atmosphere.Decay = Color3.fromRGB(100, 100, 150)
atmosphere.Glare = 0.7
atmosphere.Haze = 2.5
atmosphere.Enabled = SETTINGS.FogEnabled
atmosphere.Parent = Lighting

if SETTINGS.SkyEnabled then
    sky = Instance.new("Sky")
    sky.SkyboxBk = "rbxassetid://159454299"
    sky.SkyboxDn = "rbxassetid://159454296"
    sky.SkyboxFt = "rbxassetid://159454293"
    sky.SkyboxLf = "rbxassetid://159454286"
    sky.SkyboxRt = "rbxassetid://159454300"
    sky.SkyboxUp = "rbxassetid://159454288"
    sky.SunAngularSize = 11
    sky.MoonAngularSize = 11
    sky.StarCount = 3000
    sky.Parent = Lighting
end

if SETTINGS.BloomEnabled then
    bloom = Instance.new("BloomEffect")
    bloom.Intensity = 1.2
    bloom.Size = 28
    bloom.Threshold = 0.85
    bloom.Parent = Lighting
end

local cc = Instance.new("ColorCorrectionEffect")
cc.Brightness = 0.06
cc.Contrast = 0.2
cc.Saturation = 0.25
cc.TintColor = Color3.fromRGB(255, 240, 255)
cc.Parent = Lighting

blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = Lighting

local halo = Instance.new("BillboardGui")
halo.Name = "VovanHalo"
halo.Size = UDim2.new(0, 100, 0, 100)
halo.AlwaysOnTop = true
halo.StudsOffset = Vector3.new(0, 4, 0)
halo.Enabled = SETTINGS.HaloEnabled
halo.Parent = LocalPlayer:WaitForChild("PlayerGui")

local ring = Instance.new("ImageLabel")
ring.Size = UDim2.new(1, 0, 1, 0)
ring.BackgroundTransparency = 1
ring.Image = "rbxassetid://5028857084"
ring.ImageColor3 = HALO_COLORS[SETTINGS.HaloColorIndex].color
ring.ImageTransparency = 0.2
ring.Parent = halo

task.spawn(function()
    while halo.Parent do
        TweenService:Create(ring, TweenInfo.new(1), {ImageTransparency = 0.5}):Play()
        TweenService:Create(ring, TweenInfo.new(1), {Size = UDim2.new(1.1, 0, 1.1, 0)}):Play()
        task.wait(1)
        TweenService:Create(ring, TweenInfo.new(1), {ImageTransparency = 0.2}):Play()
        TweenService:Create(ring, TweenInfo.new(1), {Size = UDim2.new(1, 0, 1, 0)}):Play()
        task.wait(1)
    end
end)

local function bindHalo(char)
    local head = char:WaitForChild("Head", 5)
    if head then halo.Adornee = head end
end

if LocalPlayer.Character then bindHalo(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(bindHalo)

local UI = {}
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VovanHub"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- =============================================
-- TOP HUD (ЗАКРУГЛЁННЫЙ)
-- =============================================
local topHud = Instance.new("Frame")
topHud.Name = "TopHUD"
topHud.Size = UDim2.new(0, 620, 0, 60)
topHud.Position = UDim2.new(0.5, -310, 0, 10)
topHud.BackgroundColor3 = C.Panel
topHud.BackgroundTransparency = 0.1
topHud.BorderSizePixel = 0
topHud.Visible = SETTINGS.TopHUD
topHud.Parent = screenGui

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 22)
topCorner.Parent = topHud

local topStroke = Instance.new("UIStroke")
topStroke.Color = C.Accent
topStroke.Thickness = 1.8
topStroke.Transparency = 0.2
topStroke.Parent = topHud

local topGrad = Instance.new("UIGradient")
topGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, C.Accent),
    ColorSequenceKeypoint.new(0.5, C.Accent2),
    ColorSequenceKeypoint.new(1, C.Accent3)
}
topGrad.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 0.7),
    NumberSequenceKeypoint.new(0.5, 0.4),
    NumberSequenceKeypoint.new(1, 0.7)
}
topGrad.Parent = topHud

local hudIcon = Instance.new("ImageLabel")
hudIcon.Size = UDim2.new(0, 44, 0, 44)
hudIcon.Position = UDim2.new(0, 8, 0.5, -22)
hudIcon.BackgroundColor3 = C.PanelLight
hudIcon.Image = ICON_ID
hudIcon.Parent = topHud

local hudIconCorner = Instance.new("UICorner")
hudIconCorner.CornerRadius = UDim.new(1, 0)
hudIconCorner.Parent = hudIcon

local hudName = Instance.new("TextLabel")
hudName.Size = UDim2.new(0, 180, 0, 22)
hudName.Position = UDim2.new(0, 60, 0, 10)
hudName.BackgroundTransparency = 1
hudName.Text = LocalPlayer.DisplayName
hudName.TextColor3 = C.Text
hudName.Font = Enum.Font.GothamBold
hudName.TextSize = 14
hudName.TextXAlignment = Enum.TextXAlignment.Left
hudName.Parent = topHud

local hudRole = Instance.new("TextLabel")
hudRole.Size = UDim2.new(0, 180, 0, 16)
hudRole.Position = UDim2.new(0, 60, 0, 32)
hudRole.BackgroundTransparency = 1
hudRole.Text = "Role: Innocent"
hudRole.TextColor3 = C.Innocent
hudRole.Font = Enum.Font.Gotham
hudRole.TextSize = 11
hudRole.TextXAlignment = Enum.TextXAlignment.Left
hudRole.Parent = topHud

local hudPing = Instance.new("TextLabel")
hudPing.Size = UDim2.new(0, 100, 0, 22)
hudPing.Position = UDim2.new(0, 250, 0, 10)
hudPing.BackgroundTransparency = 1
hudPing.Text = "Ping: 0"
hudPing.TextColor3 = C.Accent3
hudPing.Font = Enum.Font.GothamBold
hudPing.TextSize = 13
hudPing.Parent = topHud

local hudFps = Instance.new("TextLabel")
hudFps.Size = UDim2.new(0, 100, 0, 22)
hudFps.Position = UDim2.new(0, 250, 0, 32)
hudFps.BackgroundTransparency = 1
hudFps.Text = "FPS: 0"
hudFps.TextColor3 = C.Success
hudFps.Font = Enum.Font.GothamBold
hudFps.TextSize = 12
hudFps.Parent = topHud

local hudNC = Instance.new("TextLabel")
hudNC.Size = UDim2.new(0, 120, 0, 22)
hudNC.Position = UDim2.new(0, 370, 0, 10)
hudNC.BackgroundTransparency = 1
hudNC.Text = "NoClip: OFF"
hudNC.TextColor3 = C.Danger
hudNC.Font = Enum.Font.GothamBold
hudNC.TextSize = 12
hudNC.Parent = topHud

local hudAngles = Instance.new("TextLabel")
hudAngles.Size = UDim2.new(0, 150, 0, 42)
hudAngles.Position = UDim2.new(1, -160, 0.5, -21)
hudAngles.BackgroundTransparency = 1
hudAngles.Text = "Yaw: 0\nPitch: 0"
hudAngles.TextColor3 = C.Accent2
hudAngles.Font = Enum.Font.GothamBold
hudAngles.TextSize = 11
hudAngles.TextXAlignment = Enum.TextXAlignment.Right
hudAngles.Parent = topHud

task.spawn(function()
    local t = 0
    while topHud.Parent do
        t = (t + 1) % 3
        if t == 0 then
            TweenService:Create(topStroke, TweenInfo.new(1), {Color = C.Accent}):Play()
        elseif t == 1 then
            TweenService:Create(topStroke, TweenInfo.new(1), {Color = C.Accent2}):Play()
        else
            TweenService:Create(topStroke, TweenInfo.new(1), {Color = C.Accent3}):Play()
        end
        task.wait(1)
    end
end)

local fpsCounter = 0
local fpsTimer = 0
local currentFps = 0

task.spawn(function()
    while topHud.Parent do
        task.wait(0.5)
        local ok, ping = pcall(function()
            return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
        end)
        hudPing.Text = "Ping: " .. math.floor(ok and ping or 0)
        hudFps.Text = "FPS: " .. currentFps
        local look = Camera.CFrame.LookVector
        local yaw = math.deg(math.atan2(-look.X, -look.Z))
        local pitch = math.deg(math.asin(look.Y))
        hudAngles.Text = string.format("Yaw: %.0f\nPitch: %.0f", yaw, pitch)
        local myRole = getRole(LocalPlayer)
        hudRole.Text = "Role: " .. myRole
        if myRole == "Murderer" then hudRole.TextColor3 = C.Murderer
        elseif myRole == "Sheriff" then hudRole.TextColor3 = C.Sheriff
        else hudRole.TextColor3 = C.Innocent end
        hudNC.Text = "NoClip: " .. (SETTINGS.NoClipEnabled and "ON" or "OFF")
        hudNC.TextColor3 = SETTINGS.NoClipEnabled and C.Success or C.Danger
    end
end)

RunService.RenderStepped:Connect(function(dt)
    fpsCounter = fpsCounter + 1
    fpsTimer = fpsTimer + dt
    if fpsTimer >= 1 then
        currentFps = fpsCounter
        fpsCounter = 0
        fpsTimer = 0
    end
end)

-- =============================================
-- ГЛАВНОЕ МЕНЮ (ЗАКРУГЛЁННОЕ)
-- =============================================
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 760, 0, 580)
main.Position = UDim2.new(0.5, -380, 0.5, -290)
main.BackgroundColor3 = C.Bg
main.BorderSizePixel = 0
main.Visible = true
main.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 24)
mainCorner.Parent = main

local bgImage = Instance.new("ImageLabel")
bgImage.Size = UDim2.new(1, 0, 1, 0)
bgImage.BackgroundTransparency = 1
bgImage.Image = ICON_ID
bgImage.ImageTransparency = 0.9
bgImage.ScaleType = Enum.ScaleType.Crop
bgImage.ZIndex = 0
bgImage.Parent = main

local bgImageCorner = Instance.new("UICorner")
bgImageCorner.CornerRadius = UDim.new(0, 24)
bgImageCorner.Parent = bgImage

local bgGrad = Instance.new("UIGradient")
bgGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, C.BgGrad1),
    ColorSequenceKeypoint.new(0.5, C.Bg),
    ColorSequenceKeypoint.new(1, C.BgGrad2)
}
bgGrad.Rotation = 45
bgGrad.Transparency = NumberSequence.new(0.2)
bgGrad.Parent = bgImage

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = C.Accent
mainStroke.Thickness = 2.5
mainStroke.Transparency = 0.2
mainStroke.Parent = main

task.spawn(function()
    local colors = {C.Accent, C.Accent2, C.Accent3}
    local i = 0
    while main.Parent do
        i = (i % 3) + 1
        TweenService:Create(mainStroke, TweenInfo.new(2, Enum.EasingStyle.Sine), {Color = colors[i]}):Play()
        task.wait(2)
    end
end)

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 70)
header.BackgroundColor3 = C.Panel
header.BackgroundTransparency = 0.15
header.BorderSizePixel = 0
header.ZIndex = 2
header.Parent = main

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 24)
headerCorner.Parent = header

local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 24)
headerFix.Position = UDim2.new(0, 0, 1, -24)
headerFix.BackgroundColor3 = C.Panel
headerFix.BackgroundTransparency = 0.15
headerFix.BorderSizePixel = 0
headerFix.ZIndex = 2
headerFix.Parent = header

local logo = Instance.new("ImageLabel")
logo.Size = UDim2.new(0, 56, 0, 56)
logo.Position = UDim2.new(0, 14, 0, 7)
logo.BackgroundColor3 = C.Accent
logo.Image = ICON_ID
logo.ZIndex = 3
logo.Parent = header

local logoCorner = Instance.new("UICorner")
logoCorner.CornerRadius = UDim.new(0, 16)
logoCorner.Parent = logo

logo.MouseEnter:Connect(function()
    TweenService:Create(logo, TweenInfo.new(0.3), {Rotation = 360}):Play()
end)

local avatarFrame = Instance.new("Frame")
avatarFrame.Size = UDim2.new(0, 44, 0, 44)
avatarFrame.Position = UDim2.new(0, 80, 0, 13)
avatarFrame.BackgroundColor3 = C.PanelLight
avatarFrame.ZIndex = 3
avatarFrame.Parent = header

local avatarCorner = Instance.new("UICorner")
avatarCorner.CornerRadius = UDim.new(1, 0)
avatarCorner.Parent = avatarFrame

local avatarImg = Instance.new("ImageLabel")
avatarImg.Size = UDim2.new(1, 0, 1, 0)
avatarImg.BackgroundTransparency = 1
avatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
avatarImg.ZIndex = 4
avatarImg.Parent = avatarFrame

local avatarImgCorner = Instance.new("UICorner")
avatarImgCorner.CornerRadius = UDim.new(1, 0)
avatarImgCorner.Parent = avatarImg

avatarFrame.MouseEnter:Connect(function()
    TweenService:Create(avatarFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 50, 0, 50), Position = UDim2.new(0, 77, 0, 10)}):Play()
end)
avatarFrame.MouseLeave:Connect(function()
    TweenService:Create(avatarFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 44, 0, 44), Position = UDim2.new(0, 80, 0, 13)}):Play()
end)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 340, 0, 32)
title.Position = UDim2.new(0, 134, 0, 10)
title.BackgroundTransparency = 1
title.Text = "VOVANHUB"
title.TextColor3 = C.Text
title.Font = Enum.Font.GothamBlack
title.TextSize = 28
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 3
title.Parent = header

local titleGrad = Instance.new("UIGradient")
titleGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, C.Accent),
    ColorSequenceKeypoint.new(0.5, C.Accent2),
    ColorSequenceKeypoint.new(1, C.Accent3)
}
titleGrad.Parent = title

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(0, 340, 0, 18)
subtitle.Position = UDim2.new(0, 134, 0, 42)
subtitle.BackgroundTransparency = 1
subtitle.Text = "MM2  •  v4.1 ULTRA  •  " .. LocalPlayer.Name
subtitle.TextColor3 = C.TextDim
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 11
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.ZIndex = 3
subtitle.Parent = header

local status = Instance.new("TextLabel")
status.Size = UDim2.new(0, 140, 0, 28)
status.Position = UDim2.new(1, -196, 0, 21)
status.BackgroundColor3 = C.Success
status.Text = "● ONLINE"
status.TextColor3 = C.Text
status.Font = Enum.Font.GothamBold
status.TextSize = 11
status.ZIndex = 3
status.Parent = header

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(1, 0)
statusCorner.Parent = status

task.spawn(function()
    while status.Parent do
        TweenService:Create(status, TweenInfo.new(1), {BackgroundTransparency = 0.3}):Play()
        task.wait(1)
        TweenService:Create(status, TweenInfo.new(1), {BackgroundTransparency = 0}):Play()
        task.wait(1)
    end
end)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -52, 0, 15)
closeBtn.BackgroundColor3 = C.PanelLight
closeBtn.Text = "✕"
closeBtn.TextColor3 = C.Text
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.ZIndex = 3
closeBtn.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 12)
closeCorner.Parent = closeBtn

closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.2), {BackgroundColor3 = C.Danger, Rotation = 90}):Play()
end)
closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.2), {BackgroundColor3 = C.PanelLight, Rotation = 0}):Play()
end)

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 210, 1, -70)
sidebar.Position = UDim2.new(0, 0, 0, 70)
sidebar.BackgroundColor3 = C.Panel
sidebar.BackgroundTransparency = 0.15
sidebar.BorderSizePixel = 0
sidebar.ZIndex = 2
sidebar.Parent = main

local sidebarFix = Instance.new("Frame")
sidebarFix.Size = UDim2.new(0, 15, 1, 0)
sidebarFix.Position = UDim2.new(1, -15, 0, 0)
sidebarFix.BackgroundColor3 = C.Panel
sidebarFix.BackgroundTransparency = 0.15
sidebarFix.BorderSizePixel = 0
sidebarFix.ZIndex = 2
sidebarFix.Parent = sidebar

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -210, 1, -70)
content.Position = UDim2.new(0, 210, 0, 70)
content.BackgroundTransparency = 1
content.ZIndex = 3
content.Parent = main

local categories = {}
local categoryButtons = {}

function UI.createCategory(name, icon)
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -28, 1, -28)
    page.Position = UDim2.new(0, 14, 0, 14)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = C.Accent
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.ZIndex = 3
    page.Parent = content
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page
    
    categories[name] = page
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -16, 0, 48)
    btn.Position = UDim2.new(0, 8, 0, 8 + (#categoryButtons * 54))
    btn.BackgroundColor3 = C.Panel
    btn.BackgroundTransparency = 0.3
    btn.Text = "  " .. icon .. "  " .. name
    btn.TextColor3 = C.TextDim
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.ZIndex = 3
    btn.Parent = sidebar
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 14)
    btnCorner.Parent = btn
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = C.PanelLight
    btnStroke.Thickness = 1
    btnStroke.Transparency = 0.7
    btnStroke.Parent = btn
    
    table.insert(categoryButtons, btn)
    
    btn.MouseButton1Click:Connect(function()
        UI.switchCategory(name)
    end)
    
    btn.MouseEnter:Connect(function()
        if not categories[name].Visible then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = C.CardHover}):Play()
            TweenService:Create(btn, TweenInfo.new(0.2), {Size = UDim2.new(1, -12, 0, 48), Position = UDim2.new(0, 6, 0, 8 + (table.find(categoryButtons, btn) - 1) * 54)}):Play()
        end
    end)
    
    btn.MouseLeave:Connect(function()
        if not categories[name].Visible then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = C.Panel}):Play()
            TweenService:Create(btn, TweenInfo.new(0.2), {Size = UDim2.new(1, -16, 0, 48), Position = UDim2.new(0, 8, 0, 8 + (table.find(categoryButtons, btn) - 1) * 54)}):Play()
        end
    end)
    
    return page
end

function UI.switchCategory(name)
    for catName, page in pairs(categories) do
        page.Visible = (catName == name)
    end
    for _, btn in pairs(categoryButtons) do
        if btn.Text:find(name) then
            TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = C.Accent}):Play()
            TweenService:Create(btn, TweenInfo.new(0.3), {TextColor3 = C.Text}):Play()
        else
            TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = C.Panel}):Play()
            TweenService:Create(btn, TweenInfo.new(0.3), {TextColor3 = C.TextDim}):Play()
        end
    end
end

function UI.createToggle(parent, name, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundColor3 = C.Card
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0
    frame.ZIndex = 3
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = C.PanelLight
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80, 1, 0)
    label.Position = UDim2.new(0, 16, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = C.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 4
    label.Parent = frame
    
    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(0, 50, 0, 25)
    toggle.Position = UDim2.new(1, -66, 0.5, -12.5)
    toggle.BackgroundColor3 = default and C.ToggleOn or C.ToggleOff
    toggle.ZIndex = 4
    toggle.Parent = frame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggle
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 19, 0, 19)
    knob.Position = default and UDim2.new(1, -21, 0.5, -9.5) or UDim2.new(0, 3, 0.5, -9.5)
    knob.BackgroundColor3 = C.Text
    knob.ZIndex = 5
    knob.Parent = toggle
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    
    local state = default
    
    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.ZIndex = 6
    clickBtn.Parent = frame
    
    clickBtn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(toggle, TweenInfo.new(0.3, Enum.EasingStyle.Back), {BackgroundColor3 = state and C.ToggleOn or C.ToggleOff}):Play()
        TweenService:Create(knob, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Position = state and UDim2.new(1, -21, 0.5, -9.5) or UDim2.new(0, 3, 0.5, -9.5)}):Play()
        callback(state)
    end)
    
    frame.MouseEnter:Connect(function()
        TweenService:Create(frame, TweenInfo.new(0.2), {BackgroundColor3 = C.CardHover}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Color = C.Accent, Transparency = 0.3}):Play()
    end)
    frame.MouseLeave:Connect(function()
        TweenService:Create(frame, TweenInfo.new(0.2), {BackgroundColor3 = C.Card}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Color = C.PanelLight, Transparency = 0.5}):Play()
    end)
end

function UI.createSlider(parent, name, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 64)
    frame.BackgroundColor3 = C.Card
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0
    frame.ZIndex = 3
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = C.PanelLight
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -24, 0, 26)
    label.Position = UDim2.new(0, 16, 0, 6)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. default
    label.TextColor3 = C.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 4
    label.Parent = frame
    
    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1, -32, 0, 10)
    barBg.Position = UDim2.new(0, 16, 0, 44)
    barBg.BackgroundColor3 = C.ToggleOff
    barBg.BorderSizePixel = 0
    barBg.ZIndex = 4
    barBg.Parent = frame
    
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = barBg
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = C.Accent
    fill.BorderSizePixel = 0
    fill.ZIndex = 5
    fill.Parent = barBg
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local fillGrad = Instance.new("UIGradient")
    fillGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, C.Accent),
        ColorSequenceKeypoint.new(1, C.Accent2)
    }
    fillGrad.Parent = fill
    
    local drag = false
    
    local clickArea = Instance.new("TextButton")
    clickArea.Size = UDim2.new(1, -32, 0, 28)
    clickArea.Position = UDim2.new(0, 16, 0, 34)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.ZIndex = 6
    clickArea.Parent = frame
    
    local function update(x)
        local rel = math.clamp((x - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
        local val = min + (max - min) * rel
        val = math.floor(val * 100) / 100
        fill.Size = UDim2.new(rel, 0, 1, 0)
        label.Text = name .. ": " .. val
        callback(val)
    end
    
    clickArea.MouseButton1Down:Connect(function()
        drag = true
        update(Mouse.X)
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if drag and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(Mouse.X)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = false
        end
    end)
end

function UI.createColorPicker(parent, name, colors, defaultIndex, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundColor3 = C.Card
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0
    frame.ZIndex = 3
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = C.PanelLight
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80, 1, 0)
    label.Position = UDim2.new(0, 16, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. colors[defaultIndex].name
    label.TextColor3 = C.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 4
    label.Parent = frame
    
    local colorBox = Instance.new("Frame")
    colorBox.Size = UDim2.new(0, 50, 0, 25)
    colorBox.Position = UDim2.new(1, -66, 0.5, -12.5)
    colorBox.BackgroundColor3 = colors[defaultIndex].color or colors[defaultIndex].c1
    colorBox.ZIndex = 4
    colorBox.Parent = frame
    
    local colorBoxCorner = Instance.new("UICorner")
    colorBoxCorner.CornerRadius = UDim.new(0, 8)
    colorBoxCorner.Parent = colorBox
    
    local index = defaultIndex
    
    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.ZIndex = 6
    clickBtn.Parent = frame
    
    clickBtn.MouseButton1Click:Connect(function()
        index = (index % #colors) + 1
        local c = colors[index]
        label.Text = name .. ": " .. c.name
        TweenService:Create(colorBox, TweenInfo.new(0.3), {BackgroundColor3 = c.color or c.c1}):Play()
        callback(index, c)
    end)
    
    frame.MouseEnter:Connect(function()
        TweenService:Create(frame, TweenInfo.new(0.2), {BackgroundColor3 = C.CardHover}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Color = C.Accent, Transparency = 0.3}):Play()
    end)
    frame.MouseLeave:Connect(function()
        TweenService:Create(frame, TweenInfo.new(0.2), {BackgroundColor3 = C.Card}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Color = C.PanelLight, Transparency = 0.5}):Play()
    end)
end

function UI.createLabel(parent, text, color, size)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, size or 40)
    label.BackgroundColor3 = C.Card
    label.BackgroundTransparency = 0.3
    label.Text = text
    label.TextColor3 = color or C.TextDim
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.ZIndex = 3
    label.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = label
    
    return label
end

local combat = UI.createCategory("Combat", "⚔")
UI.createLabel(combat, "  AIMBOT (только Sheriff)", C.Accent, 40)
UI.createToggle(combat, "Enabled", SETTINGS.Enabled, function(v) SETTINGS.Enabled = v end)
UI.createToggle(combat, "Wallbang", SETTINGS.Wallbang, function(v) SETTINGS.Wallbang = v end)
UI.createToggle(combat, "Auto Shoot", SETTINGS.AutoShoot, function(v) SETTINGS.AutoShoot = v end)
UI.createToggle(combat, "Target Murderer", SETTINGS.TargetMurderer, function(v) SETTINGS.TargetMurderer = v end)
UI.createSlider(combat, "FOV", 0, 360, SETTINGS.FOV, function(v) SETTINGS.FOV = v end)
UI.createSlider(combat, "Smoothness", 0, 1, SETTINGS.Smoothness, function(v) SETTINGS.Smoothness = v end)
UI.createSlider(combat, "Shoot Delay", 0.01, 0.5, SETTINGS.ShootDelay, function(v) SETTINGS.ShootDelay = v end)

local visuals = UI.createCategory("Visuals", "👁")
UI.createLabel(visuals, "  WALLHACK + АВАТАРКИ", C.Accent, 40)
UI.createToggle(visuals, "ESP Enabled", SETTINGS.ESPEnabled, function(v) SETTINGS.ESPEnabled = v end)
UI.createToggle(visuals, "Murderer (красный)", SETTINGS.ESPMurderer, function(v) SETTINGS.ESPMurderer = v end)
UI.createToggle(visuals, "Sheriff (синий)", SETTINGS.ESPSheriff, function(v) SETTINGS.ESPSheriff = v end)
UI.createToggle(visuals, "Innocent (зелёный)", SETTINGS.ESPInnocent, function(v) SETTINGS.ESPInnocent = v end)
UI.createToggle(visuals, "Показывать аватарки", SETTINGS.ESPAvatar, function(v) SETTINGS.ESPAvatar = v end)
UI.createToggle(visuals, "Rainbow ESP", SETTINGS.ESPRainbow, function(v) SETTINGS.ESPRainbow = v end)

local effects = UI.createCategory("Effects", "✨")
UI.createLabel(effects, "  ВИЗУАЛЬНЫЕ ЭФФЕКТЫ", C.Accent, 40)
UI.createToggle(effects, "Нимб над головой", SETTINGS.HaloEnabled, function(v) halo.Enabled = v end)
UI.createColorPicker(effects, "Цвет нимба", HALO_COLORS, SETTINGS.HaloColorIndex, function(idx, c)
    SETTINGS.HaloColorIndex = idx
    TweenService:Create(ring, TweenInfo.new(0.3), {ImageColor3 = c.color}):Play()
end)
UI.createToggle(effects, "Туман", SETTINGS.FogEnabled, function(v) atmosphere.Enabled = v end)
UI.createColorPicker(effects, "Цвет тумана", FOG_COLORS, SETTINGS.FogColorIndex, function(idx, c)
    SETTINGS.FogColorIndex = idx
    TweenService:Create(atmosphere, TweenInfo.new(0.5), {Color = c.color}):Play()
end)
UI.createToggle(effects, "Шейдер неба", SETTINGS.SkyEnabled, function(v) if sky then sky.Enabled = v end end)
UI.createToggle(effects, "Bloom (свечение)", SETTINGS.BloomEnabled, function(v) if bloom then bloom.Enabled = v end end)
UI.createToggle(effects, "Blur при меню", SETTINGS.BlurOnMenu, function(v) SETTINGS.BlurOnMenu = v end)
UI.createToggle(effects, "Trail за игроком", SETTINGS.TrailEnabled, function(v) SETTINGS.TrailEnabled = v end)
UI.createColorPicker(effects, "Цвет Trail", TRAIL_COLORS, SETTINGS.TrailColorIndex, function(idx, c)
    SETTINGS.TrailColorIndex = idx
    if trail then
        TweenService:Create(trail, TweenInfo.new(0.5), {
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, c.c1),
                ColorSequenceKeypoint.new(0.5, c.c2),
                ColorSequenceKeypoint.new(1, c.c3)
            }
        }):Play()
    end
end)
UI.createToggle(effects, "Top HUD", SETTINGS.TopHUD, function(v) topHud.Visible = v end)

local movement = UI.createCategory("Movement", "🏃")
UI.createLabel(movement, "  SPINNER", C.Accent, 40)
UI.createToggle(movement, "Spinner", SETTINGS.SpinnerEnabled, function(v) SETTINGS.SpinnerEnabled = v end)
UI.createSlider(movement, "Spinner Speed", 1, 200, SETTINGS.SpinnerSpeed, function(v) SETTINGS.SpinnerSpeed = v end)
UI.createLabel(movement, "  BHOP", C.Accent, 40)
UI.createToggle(movement, "Bhop", SETTINGS.BhopEnabled, function(v) SETTINGS.BhopEnabled = v end)
UI.createSlider(movement, "Bhop Speed", 16, 1000, SETTINGS.BhopSpeed, function(v) SETTINGS.BhopSpeed = v end)
UI.createLabel(movement, "  NO-CLIP", C.Accent, 40)
UI.createToggle(movement, "No-Clip", SETTINGS.NoClipEnabled, function(v) SETTINGS.NoClipEnabled = v end)
UI.createLabel(movement, "  Клавиша: N", C.TextDim)

local fling = UI.createCategory("Fling", "💥")
UI.createLabel(fling, "  FLING", C.Accent, 40)
UI.createToggle(fling, "Fling Enabled", SETTINGS.FlingEnabled, function(v) SETTINGS.FlingEnabled = v end)
UI.createSlider(fling, "Fling Power", 10, 500, SETTINGS.FlingPower, function(v) SETTINGS.FlingPower = v end)
UI.createLabel(fling, "  Клавиша: F", C.TextDim)

local grab = UI.createCategory("Grab", "🔫")
UI.createLabel(grab, "  AUTO-GRAB GUN", C.Accent, 40)
UI.createToggle(grab, "Auto-Grab Gun", SETTINGS.AutoGrabGun, function(v) SETTINGS.AutoGrabGun = v end)
UI.createSlider(grab, "Grab Radius", 10, 500, SETTINGS.AutoGrabRadius, function(v) SETTINGS.AutoGrabRadius = v end)
UI.createLabel(grab, "  TP TO SHERIFF — G", C.TextDim)

local info = UI.createCategory("Info", "ℹ")
UI.createLabel(info, "  VOVANHUB v4.1 ULTRA", C.Accent, 40)
UI.createLabel(info, "  Status: Undetected", C.Success)
UI.createLabel(info, "  Insert / RightShift — menu", C.TextDim)
UI.createLabel(info, "  N — NoClip | F — Fling | G — TP", C.TextDim)
UI.createLabel(info, "  Made by Vovan", C.Accent2)

UI.switchCategory("Combat")

local dragging, dragStart, startPos = false, nil, nil

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

local menuOpen = true

local function toggleMenu()
    menuOpen = not menuOpen
    if menuOpen then
        main.Visible = true
        main.Size = UDim2.new(0, 0, 0, 0)
        main.Rotation = -5
        TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 760, 0, 580),
            Rotation = 0
        }):Play()
        if SETTINGS.BlurOnMenu then
            TweenService:Create(blur, TweenInfo.new(0.3), {Size = 14}):Play()
        end
    else
        TweenService:Create(main, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 0, 0, 0),
            Rotation = 5
        }):Play()
        if SETTINGS.BlurOnMenu then
            TweenService:Create(blur, TweenInfo.new(0.3), {Size = 0}):Play()
        end
        task.wait(0.25)
        main.Visible = false
        main.Rotation = 0
    end
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Insert or input.KeyCode == Enum.KeyCode.RightShift then
        toggleMenu()
    end
    if input.KeyCode == SETTINGS.NoClipKey then
        SETTINGS.NoClipEnabled = not SETTINGS.NoClipEnabled
    end
    if input.KeyCode == SETTINGS.FlingKey and SETTINGS.FlingEnabled then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and LocalPlayer.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                local myHrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp and myHrp then
                    local dist = (hrp.Position - myHrp.Position).Magnitude
                    if dist < 30 then
                        local dir = (hrp.Position - myHrp.Position).Unit
                        hrp.Velocity = dir * SETTINGS.FlingPower + Vector3.new(0, 50, 0)
                    end
                end
            end
        end
    end
    if input.KeyCode == SETTINGS.TpToSheriffKey then
        local sheriff = nil
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and getRole(p) == "Sheriff" and p.Character then
                sheriff = p
                break
            end
        end
        if sheriff and sheriff.Character and LocalPlayer.Character then
            local hrp = sheriff.Character:FindFirstChild("HumanoidRootPart")
            local myHrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp and myHrp then
                myHrp.CFrame = hrp.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end
end)

closeBtn.MouseButton1Click:Connect(function() toggleMenu() end)

RunService.Stepped:Connect(function()
    if not SETTINGS.NoClipEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
        end
    end
end)

local lastShot = 0
local aimAccum = 0

local function findTarget()
    local closest, shortestDist = nil, math.huge
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        local humanoid = player.Character:FindFirstChild("Humanoid")
        local head = player.Character:FindFirstChild("Head")
        if not humanoid or not head or humanoid.Health <= 0 then continue end
        local role = getRole(player)
        if role ~= "Murderer" then continue end
        if not SETTINGS.TargetMurderer then continue end
        local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
        if not onScreen and not SETTINGS.Wallbang then continue end
        local dist = (mousePos - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
        if dist < SETTINGS.FOV and dist < shortestDist then
            shortestDist = dist
            closest = player
        end
    end
    return closest
end

RunService.Heartbeat:Connect(function(dt)
    if not SETTINGS.Enabled then return end
    if getRole(LocalPlayer) ~= "Sheriff" then return end
    aimAccum = aimAccum + dt
    if aimAccum < 0.03 then return end
    aimAccum = 0
    local target = findTarget()
    if target and target.Character then
        local head = target.Character:FindFirstChild("Head")
        if head then
            if SETTINGS.Wallbang then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
            else
                local cur = Camera.CFrame
                local tgt = CFrame.new(cur.Position, head.Position)
                Camera.CFrame = cur:Lerp(tgt, 1 - SETTINGS.Smoothness)
            end
            if SETTINGS.AutoShoot then
                local now = tick()
                if now - lastShot >= SETTINGS.ShootDelay then
                    lastShot = now
                    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                end
            end
        end
    end
end)

local espHighlights = {}
local espBillboards = {}
local espAccum = 0
local hue = 0

local function clearESP()
    for _, hl in pairs(espHighlights) do
        if hl then hl:Destroy() end
    end
    for _, bb in pairs(espBillboards) do
        if bb then bb:Destroy() end
    end
    espHighlights = {}
    espBillboards = {}
end

RunService.Heartbeat:Connect(function(dt)
    if not SETTINGS.ESPEnabled then
        if next(espHighlights) then clearESP() end
        return
    end
    espAccum = espAccum + dt
    if espAccum < 0.1 then return end
    espAccum = 0
    if SETTINGS.ESPRainbow then
        hue = (hue + 0.01) % 1
    end
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        if not char then
            if espHighlights[player] then espHighlights[player]:Destroy(); espHighlights[player] = nil end
            if espBillboards[player] then espBillboards[player]:Destroy(); espBillboards[player] = nil end
            continue
        end
        local head = char:FindFirstChild("Head")
        if not head then continue end
        local role = getRole(player)
        local color, show
        if SETTINGS.ESPRainbow then
            color = Color3.fromHSV(hue, 1, 1)
            show = true
        else
            if role == "Murderer" and SETTINGS.ESPMurderer then
                color = C.Murderer; show = true
            elseif role == "Sheriff" and SETTINGS.ESPSheriff then
                color = C.Sheriff; show = true
            elseif role == "Innocent" and SETTINGS.ESPInnocent then
                color = C.Innocent; show = true
            end
        end
        if not show then
            if espHighlights[player] then espHighlights[player]:Destroy(); espHighlights[player] = nil end
            if espBillboards[player] then espBillboards[player]:Destroy(); espBillboards[player] = nil end
            continue
        end
        if not espHighlights[player] then
            local hl = Instance.new("Highlight")
            hl.Name = "VovanESP"
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.FillTransparency = 0.5
            hl.OutlineTransparency = 0
            hl.FillColor = color
            hl.OutlineColor = color
            hl.Parent = char
            espHighlights[player] = hl
        else
            espHighlights[player].FillColor = color
            espHighlights[player].OutlineColor = color
            espHighlights[player].Parent = char
        end
        if SETTINGS.ESPAvatar then
            if not espBillboards[player] then
                local bb = Instance.new("BillboardGui")
                bb.Size = UDim2.new(0, 50, 0, 50)
                bb.AlwaysOnTop = true
                bb.StudsOffset = Vector3.new(0, 2.5, 0)
                bb.Parent = screenGui
                local img = Instance.new("ImageLabel")
                img.Size = UDim2.new(1, 0, 1, 0)
                img.BackgroundTransparency = 1
                img.Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"
                img.Parent = bb
                local imgCorner = Instance.new("UICorner")
                imgCorner.CornerRadius = UDim.new(1, 0)
                imgCorner.Parent = img
                local imgStroke = Instance.new("UIStroke")
                imgStroke.Color = color
                imgStroke.Thickness = 2
                imgStroke.Parent = img
                bb.Adornee = head
                espBillboards[player] = bb
            else
                espBillboards[player].Adornee = head
                local img = espBillboards[player]:FindFirstChildOfClass("ImageLabel")
                if img and img:FindFirstChildOfClass("UIStroke") then
                    img.UIStroke.Color = color
                end
            end
        elseif espBillboards[player] then
            espBillboards[player]:Destroy()
            espBillboards[player] = nil
        end
    end
end)

local spinAngle = 0

RunService:BindToRenderStep("VovanMovement", Enum.RenderPriority.Camera.Value + 1, function(dt)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    if SETTINGS.SpinnerEnabled then
        spinAngle = spinAngle + math.rad(SETTINGS.SpinnerSpeed * dt * 60)
        spinAngle = spinAngle % (math.pi * 2)
        local pos = hrp.Position
        hrp.CFrame = CFrame.new(pos) * CFrame.Angles(0, spinAngle, 0)
    end
    if SETTINGS.BhopEnabled then
        if hum.MoveDirection.Magnitude > 0 then
            hum.WalkSpeed = SETTINGS.BhopSpeed
            if hum:GetState() == Enum.HumanoidStateType.Landed then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        else
            hum.WalkSpeed = 16
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if not SETTINGS.FlingEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local myHrp = char:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = (hrp.Position - myHrp.Position).Magnitude
                if dist < 20 then
                    local dir = (hrp.Position - myHrp.Position).Unit
                    hrp.Velocity = dir * SETTINGS.FlingPower + Vector3.new(0, 30, 0)
                end
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if not SETTINGS.AutoGrabGun then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "Gun" and obj:IsA("Tool") then
            local handle = obj:FindFirstChild("Handle")
            if handle then
                local dist = (hrp.Position - handle.Position).Magnitude
                if dist <= SETTINGS.AutoGrabRadius then
                    hrp.CFrame = CFrame.new(handle.Position + Vector3.new(0, 2, 0))
                    break
                end
            end
        end
    end
end)

local trail

local function setupTrail(char)
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if not hrp then return end
    local a0 = Instance.new("Attachment")
    a0.Position = Vector3.new(0, 0.5, 0)
    a0.Parent = hrp
    local a1 = Instance.new("Attachment")
    a1.Position = Vector3.new(0, -0.5, 0)
    a1.Parent = hrp
    local c = TRAIL_COLORS[SETTINGS.TrailColorIndex]
    local tr = Instance.new("Trail")
    tr.Attachment0 = a0
    tr.Attachment1 = a1
    tr.Lifetime = 0.8
    tr.MinLength = 0
    tr.WidthScale = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0)
    }
    tr.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, c.c1),
        ColorSequenceKeypoint.new(0.5, c.c2),
        ColorSequenceKeypoint.new(1, c.c3)
    }
    tr.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(1, 1)
    }
    tr.Enabled = SETTINGS.TrailEnabled
    tr.Parent = hrp
    trail = tr
end

if LocalPlayer.Character then setupTrail(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(setupTrail)

task.spawn(function()
    while true do
        task.wait(0.3)
        if trail then
            trail.Enabled = SETTINGS.TrailEnabled
        end
    end
end)

print("⚡ VovanHub v4.1 ULTRA loaded.")
print("Insert / RightShift — menu | N — NoClip | F — Fling | G — TP Sheriff")
