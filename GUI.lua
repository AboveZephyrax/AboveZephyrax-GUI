local SimpleGUI = {}
SimpleGUI.__index = SimpleGUI

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local THEME = {
    BG          = Color3.fromRGB(13, 13, 18),
    SURFACE     = Color3.fromRGB(20, 20, 28),
    SURFACE2    = Color3.fromRGB(26, 26, 36),
    SURFACE3    = Color3.fromRGB(32, 32, 44),
    ACCENT      = Color3.fromRGB(99, 102, 241),
    ACCENT_DIM  = Color3.fromRGB(55, 57, 140),
    TEXT        = Color3.fromRGB(235, 235, 245),
    SUBTEXT     = Color3.fromRGB(140, 140, 165),
    MUTED       = Color3.fromRGB(80, 80, 100),
    SUCCESS     = Color3.fromRGB(52, 211, 153),
    BORDER      = Color3.fromRGB(40, 40, 58),
    WHITE       = Color3.fromRGB(255, 255, 255),
}

local TWEEN_FAST  = TweenInfo.new(0.15, Enum.EasingStyle.Quint)
local TWEEN_MED   = TweenInfo.new(0.25, Enum.EasingStyle.Quint)
local TWEEN_SLOW  = TweenInfo.new(0.4,  Enum.EasingStyle.Quint)

local function stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or THEME.BORDER
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function pad(parent, t, b, l, r)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.PaddingLeft   = UDim.new(0, l or 0)
    p.PaddingRight  = UDim.new(0, r or 0)
    p.Parent = parent
    return p
end

local function listLayout(parent, padding, sort)
    local l = Instance.new("UIListLayout")
    l.Padding = UDim.new(0, padding or 6)
    l.SortOrder = sort or Enum.SortOrder.LayoutOrder
    l.Parent = parent
    return l
end

local function label(parent, text, size, color, bold, xa)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, size or 14)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = color or THEME.TEXT
    l.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    l.TextSize = size or 13
    l.TextXAlignment = xa or Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

function SimpleGUI:CreateWindow(config)
    config = config or {}

    local self = setmetatable({}, Window)
    self.Flags = {}
    self.SavedConfig = config.SavedConfig or {}
    self.Tabs = {}

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SimpleGUI_v2"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 999
    ScreenGui.IgnoreGuiInset = true

    local mounted = pcall(function()
        ScreenGui.Parent = game:GetService("CoreGui")
    end)
    if not mounted then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    local keybind = config.Keybind or Enum.KeyCode.RightControl
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == keybind then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 560, 0, 360)
    Main.Position = UDim2.new(0.5, -280, 0.5, -180)
    Main.BackgroundColor3 = THEME.BG
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Parent = ScreenGui
    corner(Main, 12)
    stroke(Main, THEME.BORDER, 1.5)

    local Shadow = Instance.new("ImageLabel")
    Shadow.Size = UDim2.new(1, 40, 1, 40)
    Shadow.Position = UDim2.new(0, -20, 0, -20)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://6014261993"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.4
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    Shadow.ZIndex = -1
    Shadow.Parent = Main

    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 44)
    TitleBar.BackgroundColor3 = THEME.SURFACE
    TitleBar.BorderSizePixel = 0
    TitleBar.Active = true
    TitleBar.ZIndex = 2
    TitleBar.Parent = Main
    corner(TitleBar, 12)

    local TitleBarBottom = Instance.new("Frame")
    TitleBarBottom.Size = UDim2.new(1, 0, 0, 12)
    TitleBarBottom.Position = UDim2.new(0, 0, 1, -12)
    TitleBarBottom.BackgroundColor3 = THEME.SURFACE
    TitleBarBottom.BorderSizePixel = 0
    TitleBarBottom.ZIndex = 2
    TitleBarBottom.Parent = TitleBar

    local AccentLine = Instance.new("Frame")
    AccentLine.Size = UDim2.new(0, 44, 0, 3)
    AccentLine.Position = UDim2.new(0, 44, 1, -3)
    AccentLine.BackgroundColor3 = THEME.ACCENT
    AccentLine.BorderSizePixel = 0
    AccentLine.ZIndex = 3
    AccentLine.Parent = TitleBar
    corner(AccentLine, 2)

    local TitleDot = Instance.new("Frame")
    TitleDot.Size = UDim2.new(0, 8, 0, 8)
    TitleDot.Position = UDim2.new(0, 16, 0.5, -4)
    TitleDot.BackgroundColor3 = THEME.ACCENT
    TitleDot.BorderSizePixel = 0
    TitleDot.ZIndex = 3
    TitleDot.Parent = TitleBar
    corner(TitleDot, 4)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -120, 1, 0)
    TitleLabel.Position = UDim2.new(0, 32, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = config.Name or "SimpleGUI"
    TitleLabel.TextColor3 = THEME.TEXT
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 3
    TitleLabel.Parent = TitleBar

    local SubLabel = Instance.new("TextLabel")
    SubLabel.Size = UDim2.new(0, 200, 1, 0)
    SubLabel.Position = UDim2.new(0, 32 + TitleLabel.TextBounds.X + 8, 0, 0)
    SubLabel.BackgroundTransparency = 1
    SubLabel.Text = config.SubTitle or ""
    SubLabel.TextColor3 = THEME.MUTED
    SubLabel.Font = Enum.Font.Gotham
    SubLabel.TextSize = 12
    SubLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubLabel.ZIndex = 3
    SubLabel.Parent = TitleBar

    local function makeWindowBtn(offsetX, symbol, hoverCol)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(0, 24, 0, 24)
        Btn.Position = UDim2.new(1, offsetX, 0.5, -12)
        Btn.BackgroundColor3 = THEME.SURFACE3
        Btn.Text = symbol
        Btn.TextColor3 = THEME.SUBTEXT
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 12
        Btn.AutoButtonColor = false
        Btn.ZIndex = 4
        Btn.Parent = TitleBar
        corner(Btn, 6)
        stroke(Btn, THEME.BORDER, 1)

        Btn.MouseEnter:Connect(function()
            TweenService:Create(Btn, TWEEN_FAST, {BackgroundColor3 = hoverCol or THEME.ACCENT_DIM}):Play()
        end)
        Btn.MouseLeave:Connect(function()
            TweenService:Create(Btn, TWEEN_FAST, {BackgroundColor3 = THEME.SURFACE3}):Play()
        end)
        return Btn
    end

    local CloseBtn = makeWindowBtn(-12, "✕", Color3.fromRGB(180, 50, 60))
    local MinBtn   = makeWindowBtn(-42, "–", THEME.ACCENT_DIM)

    CloseBtn.MouseButton1Click:Connect(function()
        TweenService:Create(Main, TWEEN_MED, {Size = UDim2.new(0, 560, 0, 0), BackgroundTransparency = 1}):Play()
        task.wait(0.25)
        ScreenGui:Destroy()
    end)

    local dragging, dragStart, startPos, dragInput = false, nil, nil, nil

    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local d = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    local Body = Instance.new("Frame")
    Body.Size = UDim2.new(1, 0, 1, -44)
    Body.Position = UDim2.new(0, 0, 0, 44)
    Body.BackgroundTransparency = 1
    Body.Parent = Main

    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            TweenService:Create(Main, TWEEN_MED, {Size = UDim2.new(0, 560, 0, 44)}):Play()
            Body.Visible = false
            MinBtn.Text = "+"
        else
            Body.Visible = true
            TweenService:Create(Main, TWEEN_MED, {Size = UDim2.new(0, 560, 0, 360)}):Play()
            MinBtn.Text = "–"
        end
    end)

    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Size = UDim2.new(0, 140, 1, -16)
    Sidebar.Position = UDim2.new(0, 8, 0, 8)
    Sidebar.BackgroundColor3 = THEME.SURFACE
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 2
    Sidebar.ScrollBarImageColor3 = THEME.ACCENT
    Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Sidebar.Parent = Body
    corner(Sidebar, 10)
    stroke(Sidebar, THEME.BORDER, 1)

    listLayout(Sidebar, 2)
    pad(Sidebar, 6, 6, 6, 6)

    local ContentArea = Instance.new("ScrollingFrame")
    ContentArea.Size = UDim2.new(1, -164, 1, -16)
    ContentArea.Position = UDim2.new(0, 156, 0, 8)
    ContentArea.BackgroundTransparency = 1
    ContentArea.BorderSizePixel = 0
    ContentArea.ScrollBarThickness = 3
    ContentArea.ScrollBarImageColor3 = THEME.ACCENT
    ContentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
    ContentArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ContentArea.Parent = Body

    listLayout(ContentArea, 6)
    pad(ContentArea, 0, 8, 0, 8)

    self.ScreenGui   = ScreenGui
    self.Main        = Main
    self.Body        = Body
    self.Sidebar     = Sidebar
    self.ContentArea = ContentArea

    TweenService:Create(Main, TWEEN_MED, {Size = UDim2.new(0, 560, 0, 360)}):Play()

    return self
end

function Window:SaveFlag(flag, value)
    self.Flags[flag] = value
end

function Window:Notify(config)
    config = config or {}
    local title    = config.Title or "Notification"
    local content  = config.Content or ""
    local duration = config.Duration or 3

    if not self.NotifHolder then
        local Holder = Instance.new("Frame")
        Holder.Size = UDim2.new(0, 280, 1, -20)
        Holder.Position = UDim2.new(1, -292, 0, 10)
        Holder.BackgroundTransparency = 1
        Holder.Parent = self.ScreenGui

        local Layout = Instance.new("UIListLayout")
        Layout.Padding = UDim.new(0, 8)
        Layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Parent = Holder

        self.NotifHolder = Holder
    end

    local Box = Instance.new("Frame")
    Box.Size = UDim2.new(1, 0, 0, 0)
    Box.AutomaticSize = Enum.AutomaticSize.Y
    Box.BackgroundColor3 = THEME.SURFACE2
    Box.BackgroundTransparency = 1
    Box.LayoutOrder = os.clock()
    Box.Parent = self.NotifHolder
    corner(Box, 10)
    local bs = stroke(Box, THEME.ACCENT, 1.5, 1)

    local AccBar = Instance.new("Frame")
    AccBar.Size = UDim2.new(0, 3, 1, 0)
    AccBar.BackgroundColor3 = THEME.ACCENT
    AccBar.BorderSizePixel = 0
    AccBar.BackgroundTransparency = 1
    AccBar.Parent = Box
    corner(AccBar, 2)

    pad(Box, 12, 12, 14, 12)
    listLayout(Box, 4)

    local TitleL = label(Box, title, 13, THEME.TEXT, true)
    TitleL.TextTransparency = 1
    TitleL.LayoutOrder = 0

    local ContentL = Instance.new("TextLabel")
    ContentL.Size = UDim2.new(1, 0, 0, 0)
    ContentL.AutomaticSize = Enum.AutomaticSize.Y
    ContentL.BackgroundTransparency = 1
    ContentL.Text = content
    ContentL.TextColor3 = THEME.SUBTEXT
    ContentL.Font = Enum.Font.Gotham
    ContentL.TextSize = 12
    ContentL.TextXAlignment = Enum.TextXAlignment.Left
    ContentL.TextWrapped = true
    ContentL.TextTransparency = 1
    ContentL.LayoutOrder = 1
    ContentL.Parent = Box

    local function tween(obj, props) TweenService:Create(obj, TWEEN_MED, props):Play() end

    tween(Box, {BackgroundTransparency = 0})
    tween(bs, {Transparency = 0})
    tween(AccBar, {BackgroundTransparency = 0})
    tween(TitleL, {TextTransparency = 0})
    tween(ContentL, {TextTransparency = 0})

    task.delay(duration, function()
        tween(Box, {BackgroundTransparency = 1})
        tween(bs, {Transparency = 1})
        tween(AccBar, {BackgroundTransparency = 1})
        tween(TitleL, {TextTransparency = 1})
        tween(ContentL, {TextTransparency = 1})
        task.wait(0.3)
        Box:Destroy()
    end)
end

function Window:CreateTab(name, icon)
    local tab = setmetatable({}, Tab)

    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, 0, 0, 34)
    TabBtn.BackgroundColor3 = THEME.SURFACE
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = (icon and (icon .. "  ") or "") .. name
    TabBtn.TextColor3 = THEME.SUBTEXT
    TabBtn.Font = Enum.Font.Gotham
    TabBtn.TextSize = 12
    TabBtn.AutoButtonColor = false
    TabBtn.LayoutOrder = #self.Tabs
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.Parent = self.Sidebar
    corner(TabBtn, 7)
    pad(TabBtn, 0, 0, 10, 0)

    local ActivePill = Instance.new("Frame")
    ActivePill.Size = UDim2.new(0, 3, 0.6, 0)
    ActivePill.Position = UDim2.new(0, 0, 0.2, 0)
    ActivePill.BackgroundColor3 = THEME.ACCENT
    ActivePill.BorderSizePixel = 0
    ActivePill.Transparency = 1
    ActivePill.BackgroundTransparency = 1
    ActivePill.Parent = TabBtn
    corner(ActivePill, 2)

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 0)
    Container.AutomaticSize = Enum.AutomaticSize.Y
    Container.BackgroundTransparency = 1
    Container.Visible = (#self.Tabs == 0)
    Container.LayoutOrder = #self.Tabs
    Container.Parent = self.ContentArea

    listLayout(Container, 6)

    local Header = Instance.new("TextLabel")
    Header.Size = UDim2.new(1, 0, 0, 28)
    Header.BackgroundTransparency = 1
    Header.Text = name
    Header.TextColor3 = THEME.TEXT
    Header.Font = Enum.Font.GothamBold
    Header.TextSize = 16
    Header.TextXAlignment = Enum.TextXAlignment.Left
    Header.LayoutOrder = 0
    Header.Parent = Container

    local Divider = Instance.new("Frame")
    Divider.Size = UDim2.new(1, 0, 0, 1)
    Divider.BackgroundColor3 = THEME.BORDER
    Divider.BorderSizePixel = 0
    Divider.LayoutOrder = 1
    Divider.Parent = Container

    local ItemsHolder = Instance.new("Frame")
    ItemsHolder.Size = UDim2.new(1, 0, 0, 0)
    ItemsHolder.AutomaticSize = Enum.AutomaticSize.Y
    ItemsHolder.BackgroundTransparency = 1
    ItemsHolder.LayoutOrder = 2
    ItemsHolder.Parent = Container

    listLayout(ItemsHolder, 6)

    tab.Container = ItemsHolder
    tab.Section   = Container
    tab.Button    = TabBtn
    tab.Pill      = ActivePill
    tab.Window    = self

    table.insert(self.Tabs, tab)

    local function refreshTabs()
        for _, t in ipairs(self.Tabs) do
            local active = t.Section.Visible
            TweenService:Create(t.Button, TWEEN_FAST, {
                TextColor3 = active and THEME.TEXT or THEME.SUBTEXT,
                BackgroundTransparency = active and 0 or 1,
                BackgroundColor3 = THEME.SURFACE3,
            }):Play()
            TweenService:Create(t.Pill, TWEEN_FAST, {BackgroundTransparency = active and 0 or 1}):Play()
        end
    end

    TabBtn.MouseEnter:Connect(function()
        if not Container.Visible then
            TweenService:Create(TabBtn, TWEEN_FAST, {BackgroundTransparency = 0, BackgroundColor3 = THEME.SURFACE2}):Play()
        end
    end)
    TabBtn.MouseLeave:Connect(function()
        if not Container.Visible then
            TweenService:Create(TabBtn, TWEEN_FAST, {BackgroundTransparency = 1}):Play()
        end
    end)

    TabBtn.MouseButton1Click:Connect(function()
        for _, t in ipairs(self.Tabs) do t.Section.Visible = false end
        Container.Visible = true
        refreshTabs()
    end)

    refreshTabs()
    return tab
end

local function makeRow(container, height)
    local Holder = Instance.new("Frame")
    Holder.Size = UDim2.new(1, 0, 0, height or 36)
    Holder.BackgroundColor3 = THEME.SURFACE2
    Holder.BorderSizePixel = 0
    Holder.Parent = container
    corner(Holder, 8)
    stroke(Holder, THEME.BORDER, 1)
    return Holder
end

function Tab:CreateLabel(text)
    local L = label(self.Container, text, 12, THEME.SUBTEXT, false)
    L.Size = UDim2.new(1, 0, 0, 16)
    return L
end

function Tab:CreateSection(name)
    local Sec = Instance.new("Frame")
    Sec.Size = UDim2.new(1, 0, 0, 0)
    Sec.AutomaticSize = Enum.AutomaticSize.Y
    Sec.BackgroundTransparency = 1
    Sec.Parent = self.Container

    listLayout(Sec, 6)

    local HeaderRow = Instance.new("Frame")
    HeaderRow.Size = UDim2.new(1, 0, 0, 22)
    HeaderRow.BackgroundTransparency = 1
    HeaderRow.LayoutOrder = 0
    HeaderRow.Parent = Sec

    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 4, 0, 14)
    Dot.Position = UDim2.new(0, 0, 0.5, -7)
    Dot.BackgroundColor3 = THEME.ACCENT
    Dot.BorderSizePixel = 0
    Dot.Parent = HeaderRow
    corner(Dot, 2)

    local SLabel = label(HeaderRow, string.upper(name), 11, THEME.SUBTEXT, true)
    SLabel.Position = UDim2.new(0, 10, 0, 0)
    SLabel.Size = UDim2.new(1, -10, 1, 0)

    local Items = Instance.new("Frame")
    Items.Size = UDim2.new(1, 0, 0, 0)
    Items.AutomaticSize = Enum.AutomaticSize.Y
    Items.BackgroundTransparency = 1
    Items.LayoutOrder = 1
    Items.Parent = Sec

    listLayout(Items, 6)

    local oldContainer = self.Container
    self.Container = Items

    return {
        End = function()
            self.Container = oldContainer
        end
    }
end

function Tab:CreateSeparator()
    local Sep = Instance.new("Frame")
    Sep.Size = UDim2.new(1, 0, 0, 1)
    Sep.BackgroundColor3 = THEME.BORDER
    Sep.BorderSizePixel = 0
    Sep.Parent = self.Container
    return Sep
end

function Tab:CreateButton(config)
    config = config or {}
    local Holder = makeRow(self.Container, 36)

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.AutoButtonColor = false
    Btn.ZIndex = 2
    Btn.Parent = Holder

    local BtnLabel = label(Holder, config.Name or "Button", 13, THEME.TEXT, false)
    BtnLabel.Position = UDim2.new(0, 12, 0, 0)
    BtnLabel.Size = UDim2.new(1, -40, 1, 0)
    BtnLabel.ZIndex = 2

    local Arrow = label(Holder, "›", 16, THEME.MUTED, true)
    Arrow.Size = UDim2.new(0, 20, 1, 0)
    Arrow.Position = UDim2.new(1, -28, 0, 0)
    Arrow.TextXAlignment = Enum.TextXAlignment.Center
    Arrow.ZIndex = 2

    Btn.MouseEnter:Connect(function()
        TweenService:Create(Holder, TWEEN_FAST, {BackgroundColor3 = THEME.SURFACE3}):Play()
        TweenService:Create(Arrow, TWEEN_FAST, {TextColor3 = THEME.ACCENT}):Play()
    end)
    Btn.MouseLeave:Connect(function()
        TweenService:Create(Holder, TWEEN_FAST, {BackgroundColor3 = THEME.SURFACE2}):Play()
        TweenService:Create(Arrow, TWEEN_FAST, {TextColor3 = THEME.MUTED}):Play()
    end)
    Btn.MouseButton1Down:Connect(function()
        TweenService:Create(Holder, TWEEN_FAST, {BackgroundColor3 = THEME.ACCENT_DIM}):Play()
    end)
    Btn.MouseButton1Up:Connect(function()
        TweenService:Create(Holder, TWEEN_FAST, {BackgroundColor3 = THEME.SURFACE3}):Play()
    end)
    Btn.MouseButton1Click:Connect(function()
        if config.Callback then config.Callback() end
    end)

    return Holder
end

function Tab:CreateToggle(config)
    config = config or {}
    local state = config.CurrentValue or false
    if config.Flag and self.Window.SavedConfig[config.Flag] ~= nil then
        state = self.Window.SavedConfig[config.Flag]
    end
    if config.Flag then self.Window.Flags[config.Flag] = state end

    local Holder = makeRow(self.Container, 36)

    local Label = label(Holder, config.Name or "Toggle", 13, THEME.TEXT, false)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.Size = UDim2.new(1, -60, 1, 0)

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(0, 38, 0, 20)
    Track.Position = UDim2.new(1, -48, 0.5, -10)
    Track.BackgroundColor3 = state and THEME.ACCENT or THEME.SURFACE3
    Track.BorderSizePixel = 0
    Track.Parent = Holder
    corner(Track, 10)
    stroke(Track, THEME.BORDER, 1)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 14, 0, 14)
    Knob.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    Knob.BackgroundColor3 = THEME.WHITE
    Knob.BorderSizePixel = 0
    Knob.Parent = Track
    corner(Knob, 7)

    local ClickArea = Instance.new("TextButton")
    ClickArea.Size = UDim2.new(1, 0, 1, 0)
    ClickArea.BackgroundTransparency = 1
    ClickArea.Text = ""
    ClickArea.ZIndex = 3
    ClickArea.Parent = Holder

    ClickArea.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(Track, TWEEN_FAST, {BackgroundColor3 = state and THEME.ACCENT or THEME.SURFACE3}):Play()
        TweenService:Create(Knob, TWEEN_FAST, {Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}):Play()
        if config.Flag then self.Window:SaveFlag(config.Flag, state) end
        if config.Callback then config.Callback(state) end
    end)

    return Holder
end

function Tab:CreateSlider(config)
    config = config or {}
    local range = config.Range or {0, 100}
    local mn, mx = range[1], range[2]
    local value  = config.CurrentValue or mn
    if config.Flag and self.Window.SavedConfig[config.Flag] ~= nil then
        value = self.Window.SavedConfig[config.Flag]
    end
    if config.Flag then self.Window.Flags[config.Flag] = value end
    local dragging = false

    local Holder = makeRow(self.Container, 50)

    local TopRow = Instance.new("Frame")
    TopRow.Size = UDim2.new(1, -24, 0, 18)
    TopRow.Position = UDim2.new(0, 12, 0, 8)
    TopRow.BackgroundTransparency = 1
    TopRow.Parent = Holder

    local SlLabel = label(TopRow, config.Name or "Slider", 12, THEME.TEXT, false)
    SlLabel.Size = UDim2.new(0.7, 0, 1, 0)

    local ValLabel = label(TopRow, tostring(value), 12, THEME.ACCENT, true)
    ValLabel.Size = UDim2.new(0.3, 0, 1, 0)
    ValLabel.Position = UDim2.new(0.7, 0, 0, 0)
    ValLabel.TextXAlignment = Enum.TextXAlignment.Right

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, -24, 0, 5)
    Track.Position = UDim2.new(0, 12, 0, 34)
    Track.BackgroundColor3 = THEME.SURFACE3
    Track.BorderSizePixel = 0
    Track.Parent = Holder
    corner(Track, 3)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((value - mn) / (mx - mn), 0, 1, 0)
    Fill.BackgroundColor3 = THEME.ACCENT
    Fill.BorderSizePixel = 0
    Fill.Parent = Track
    corner(Fill, 3)

    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 12, 0, 12)
    Dot.AnchorPoint = Vector2.new(0.5, 0.5)
    Dot.Position = UDim2.new((value - mn) / (mx - mn), 0, 0.5, 0)
    Dot.BackgroundColor3 = THEME.WHITE
    Dot.BorderSizePixel = 0
    Dot.Parent = Track
    corner(Dot, 6)
    stroke(Dot, THEME.ACCENT, 2)

    local function update(input)
        local rel = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        value = math.floor(mn + (mx - mn) * rel)
        Fill.Size = UDim2.new(rel, 0, 1, 0)
        Dot.Position = UDim2.new(rel, 0, 0.5, 0)
        ValLabel.Text = tostring(value)
        if config.Flag then self.Window:SaveFlag(config.Flag, value) end
        if config.Callback then config.Callback(value) end
    end

    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return Holder
end

function Tab:CreateInput(config)
    config = config or {}
    local currentValue = config.CurrentValue or ""
    if config.Flag and self.Window.SavedConfig[config.Flag] ~= nil then
        currentValue = self.Window.SavedConfig[config.Flag]
    end
    if config.Flag then self.Window.Flags[config.Flag] = currentValue end

    local Holder = makeRow(self.Container, 56)

    local InLabel = label(Holder, config.Name or "Input", 12, THEME.SUBTEXT, false)
    InLabel.Position = UDim2.new(0, 12, 0, 6)
    InLabel.Size = UDim2.new(1, -24, 0, 14)

    local InputBg = Instance.new("Frame")
    InputBg.Size = UDim2.new(1, -24, 0, 26)
    InputBg.Position = UDim2.new(0, 12, 0, 22)
    InputBg.BackgroundColor3 = THEME.BG
    InputBg.BorderSizePixel = 0
    InputBg.Parent = Holder
    corner(InputBg, 6)
    local inputStroke = stroke(InputBg, THEME.BORDER, 1)

    local Input = Instance.new("TextBox")
    Input.Size = UDim2.new(1, -16, 1, 0)
    Input.Position = UDim2.new(0, 8, 0, 0)
    Input.BackgroundTransparency = 1
    Input.PlaceholderText = config.PlaceholderText or ""
    Input.Text = currentValue
    Input.TextColor3 = THEME.TEXT
    Input.PlaceholderColor3 = THEME.MUTED
    Input.Font = Enum.Font.Gotham
    Input.TextSize = 12
    Input.ClearTextOnFocus = false
    Input.TextXAlignment = Enum.TextXAlignment.Left
    Input.Parent = InputBg

    Input.Focused:Connect(function()
        TweenService:Create(inputStroke, TWEEN_FAST, {Color = THEME.ACCENT}):Play()
    end)
    Input.FocusLost:Connect(function(enterPressed)
        TweenService:Create(inputStroke, TWEEN_FAST, {Color = THEME.BORDER}):Play()
        if config.Flag then self.Window:SaveFlag(config.Flag, Input.Text) end
        if config.Callback then config.Callback(Input.Text, enterPressed) end
    end)

    return Holder
end

function Tab:CreateDropdown(config)
    config = config or {}
    local options  = config.Options or {}
    local selected = config.CurrentOption or options[1]
    if config.Flag and self.Window.SavedConfig[config.Flag] ~= nil then
        selected = self.Window.SavedConfig[config.Flag]
    end
    if config.Flag then self.Window.Flags[config.Flag] = selected end
    local open = false

    local Holder = makeRow(self.Container, 36)
    Holder.ClipsDescendants = false
    Holder.ZIndex = 10

    local DLabel = label(Holder, config.Name or "Dropdown", 12, THEME.SUBTEXT, false)
    DLabel.Position = UDim2.new(0, 12, 0, 0)
    DLabel.Size = UDim2.new(0.5, -12, 1, 0)
    DLabel.ZIndex = 10

    local SelLabel = label(Holder, tostring(selected or "Select..."), 12, THEME.TEXT, true)
    SelLabel.Position = UDim2.new(0.5, 0, 0, 0)
    SelLabel.Size = UDim2.new(0.5, -36, 1, 0)
    SelLabel.TextXAlignment = Enum.TextXAlignment.Right
    SelLabel.ZIndex = 10

    local ChevLabel = label(Holder, "▾", 13, THEME.MUTED, false)
    ChevLabel.Size = UDim2.new(0, 24, 1, 0)
    ChevLabel.Position = UDim2.new(1, -30, 0, 0)
    ChevLabel.TextXAlignment = Enum.TextXAlignment.Center
    ChevLabel.ZIndex = 10

    local List = Instance.new("Frame")
    List.Size = UDim2.new(1, 0, 0, #options * 28)
    List.Position = UDim2.new(0, 0, 1, 4)
    List.BackgroundColor3 = THEME.SURFACE3
    List.Visible = false
    List.ZIndex = 20
    List.Parent = Holder
    corner(List, 8)
    stroke(List, THEME.BORDER, 1)

    listLayout(List, 0)
    pad(List, 4, 4, 0, 0)

    for i, option in ipairs(options) do
        local OptBtn = Instance.new("TextButton")
        OptBtn.Size = UDim2.new(1, 0, 0, 28)
        OptBtn.BackgroundTransparency = 1
        OptBtn.Text = tostring(option)
        OptBtn.TextColor3 = THEME.SUBTEXT
        OptBtn.Font = Enum.Font.Gotham
        OptBtn.TextSize = 12
        OptBtn.TextXAlignment = Enum.TextXAlignment.Left
        OptBtn.ZIndex = 21
        OptBtn.LayoutOrder = i
        OptBtn.Parent = List
        pad(OptBtn, 0, 0, 12, 0)

        OptBtn.MouseEnter:Connect(function()
            TweenService:Create(OptBtn, TWEEN_FAST, {BackgroundTransparency = 0, BackgroundColor3 = THEME.SURFACE2}):Play()
            TweenService:Create(OptBtn, TWEEN_FAST, {TextColor3 = THEME.TEXT}):Play()
        end)
        OptBtn.MouseLeave:Connect(function()
            TweenService:Create(OptBtn, TWEEN_FAST, {BackgroundTransparency = 1}):Play()
            TweenService:Create(OptBtn, TWEEN_FAST, {TextColor3 = THEME.SUBTEXT}):Play()
        end)
        OptBtn.MouseButton1Click:Connect(function()
            selected = option
            SelLabel.Text = tostring(selected)
            List.Visible = false
            open = false
            Holder.Size = UDim2.new(1, 0, 0, 36)
            TweenService:Create(ChevLabel, TWEEN_FAST, {Rotation = 0}):Play()
            if config.Flag then self.Window:SaveFlag(config.Flag, selected) end
            if config.Callback then config.Callback(selected) end
        end)
    end

    local ClickArea = Instance.new("TextButton")
    ClickArea.Size = UDim2.new(1, 0, 0, 36)
    ClickArea.BackgroundTransparency = 1
    ClickArea.Text = ""
    ClickArea.ZIndex = 11
    ClickArea.Parent = Holder

    ClickArea.MouseButton1Click:Connect(function()
        open = not open
        List.Visible = open
        if open then
            Holder.Size = UDim2.new(1, 0, 0, 36 + (#options * 28) + 4)
            TweenService:Create(ChevLabel, TWEEN_FAST, {Rotation = 180}):Play()
        else
            Holder.Size = UDim2.new(1, 0, 0, 36)
            TweenService:Create(ChevLabel, TWEEN_FAST, {Rotation = 0}):Play()
        end
    end)

    return Holder
end

function Tab:CreateColorPicker(config)
    config = config or {}
    local color = config.Color or Color3.fromRGB(99, 102, 241)
    if config.Flag and self.Window.SavedConfig[config.Flag] ~= nil then
        local c = self.Window.SavedConfig[config.Flag]
        color = Color3.new(c.R, c.G, c.B)
    end
    if config.Flag then self.Window.Flags[config.Flag] = {R = color.R, G = color.G, B = color.B} end
    local hue = select(1, color:ToHSV())

    local Holder = makeRow(self.Container, 36)
    Holder.ClipsDescendants = false
    Holder.ZIndex = 8

    local CLabel = label(Holder, config.Name or "Color", 13, THEME.TEXT, false)
    CLabel.Position = UDim2.new(0, 12, 0, 0)
    CLabel.Size = UDim2.new(1, -60, 1, 0)
    CLabel.ZIndex = 8

    local Swatch = Instance.new("TextButton")
    Swatch.Size = UDim2.new(0, 28, 0, 20)
    Swatch.Position = UDim2.new(1, -38, 0.5, -10)
    Swatch.BackgroundColor3 = color
    Swatch.Text = ""
    Swatch.ZIndex = 8
    Swatch.Parent = Holder
    corner(Swatch, 5)
    stroke(Swatch, THEME.BORDER, 1.5)

    local Panel = Instance.new("Frame")
    Panel.Size = UDim2.new(1, 0, 0, 46)
    Panel.Position = UDim2.new(0, 0, 1, 4)
    Panel.BackgroundColor3 = THEME.SURFACE3
    Panel.Visible = false
    Panel.ZIndex = 15
    Panel.Parent = Holder
    corner(Panel, 8)
    stroke(Panel, THEME.BORDER, 1)

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, -24, 0, 14)
    Track.Position = UDim2.new(0, 12, 0.5, -7)
    Track.BackgroundColor3 = THEME.WHITE
    Track.ZIndex = 16
    Track.Parent = Panel
    corner(Track, 7)

    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,255,0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,0,255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0))
    })
    Gradient.Parent = Track

    local HKnob = Instance.new("Frame")
    HKnob.Size = UDim2.new(0, 6, 1, 6)
    HKnob.AnchorPoint = Vector2.new(0.5, 0.5)
    HKnob.Position = UDim2.new(hue, 0, 0.5, 0)
    HKnob.BackgroundColor3 = THEME.WHITE
    HKnob.ZIndex = 17
    HKnob.Parent = Track
    corner(HKnob, 3)
    stroke(HKnob, THEME.BORDER, 1.5)

    local dragging = false

    local function update(input)
        local rel = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        HKnob.Position = UDim2.new(rel, 0, 0.5, 0)
        color = Color3.fromHSV(rel, 1, 1)
        Swatch.BackgroundColor3 = color
        if config.Flag then self.Window:SaveFlag(config.Flag, {R = color.R, G = color.G, B = color.B}) end
        if config.Callback then config.Callback(color) end
    end

    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; update(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    Swatch.MouseButton1Click:Connect(function()
        Panel.Visible = not Panel.Visible
        if Panel.Visible then
            Holder.Size = UDim2.new(1, 0, 0, 36 + 46 + 4)
        else
            Holder.Size = UDim2.new(1, 0, 0, 36)
        end
    end)

    return Holder
end

function Tab:CreatePlayerPicker(config)
    config = config or {}

    local Holder = makeRow(self.Container, 56)
    Holder.ClipsDescendants = false
    Holder.ZIndex = 9

    local PPLabel = label(Holder, config.Name or "Player", 12, THEME.SUBTEXT, false)
    PPLabel.Position = UDim2.new(0, 12, 0, 6)
    PPLabel.Size = UDim2.new(1, -24, 0, 14)
    PPLabel.ZIndex = 9

    local InputBg = Instance.new("Frame")
    InputBg.Size = UDim2.new(1, -24, 0, 26)
    InputBg.Position = UDim2.new(0, 12, 0, 22)
    InputBg.BackgroundColor3 = THEME.BG
    InputBg.BorderSizePixel = 0
    InputBg.ZIndex = 9
    InputBg.Parent = Holder
    corner(InputBg, 6)
    local ppStroke = stroke(InputBg, THEME.BORDER, 1)

    local Input = Instance.new("TextBox")
    Input.Size = UDim2.new(1, -16, 1, 0)
    Input.Position = UDim2.new(0, 8, 0, 0)
    Input.BackgroundTransparency = 1
    Input.PlaceholderText = config.PlaceholderText or "ketik nama player..."
    Input.Text = ""
    Input.TextColor3 = THEME.TEXT
    Input.PlaceholderColor3 = THEME.MUTED
    Input.Font = Enum.Font.Gotham
    Input.TextSize = 12
    Input.ClearTextOnFocus = true
    Input.ZIndex = 10
    Input.TextXAlignment = Enum.TextXAlignment.Left
    Input.Parent = InputBg

    Input.Focused:Connect(function()
        TweenService:Create(ppStroke, TWEEN_FAST, {Color = THEME.ACCENT}):Play()
    end)
    Input.FocusLost:Connect(function()
        TweenService:Create(ppStroke, TWEEN_FAST, {Color = THEME.BORDER}):Play()
    end)

    local List = Instance.new("Frame")
    List.Size = UDim2.new(1, 0, 0, 0)
    List.Position = UDim2.new(0, 0, 1, 4)
    List.BackgroundColor3 = THEME.SURFACE3
    List.Visible = false
    List.ZIndex = 18
    List.Parent = Holder
    corner(List, 8)
    stroke(List, THEME.BORDER, 1)

    listLayout(List, 0)
    pad(List, 4, 4, 0, 0)

    local function refresh(filter)
        for _, child in ipairs(List:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end

        filter = string.lower(filter or "")
        local matches = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                if filter == "" or string.find(string.lower(plr.Name), filter, 1, true) then
                    table.insert(matches, plr)
                end
            end
        end

        for i, plr in ipairs(matches) do
            local OptBtn = Instance.new("TextButton")
            OptBtn.Size = UDim2.new(1, 0, 0, 28)
            OptBtn.BackgroundTransparency = 1
            OptBtn.Text = plr.Name
            OptBtn.TextColor3 = THEME.SUBTEXT
            OptBtn.Font = Enum.Font.Gotham
            OptBtn.TextSize = 12
            OptBtn.TextXAlignment = Enum.TextXAlignment.Left
            OptBtn.ZIndex = 19
            OptBtn.LayoutOrder = i
            OptBtn.Parent = List
            pad(OptBtn, 0, 0, 12, 0)

            OptBtn.MouseEnter:Connect(function()
                TweenService:Create(OptBtn, TWEEN_FAST, {BackgroundTransparency = 0, BackgroundColor3 = THEME.SURFACE2}):Play()
                TweenService:Create(OptBtn, TWEEN_FAST, {TextColor3 = THEME.TEXT}):Play()
            end)
            OptBtn.MouseLeave:Connect(function()
                TweenService:Create(OptBtn, TWEEN_FAST, {BackgroundTransparency = 1}):Play()
                TweenService:Create(OptBtn, TWEEN_FAST, {TextColor3 = THEME.SUBTEXT}):Play()
            end)
            OptBtn.MouseButton1Click:Connect(function()
                Input.Text = plr.Name
                List.Visible = false
                Holder.Size = UDim2.new(1, 0, 0, 56)
                if config.Callback then config.Callback(plr) end
            end)
        end

        List.Size = UDim2.new(1, 0, 0, #matches * 28 + 8)
        List.Visible = #matches > 0
        Holder.Size = UDim2.new(1, 0, 0, 56 + (List.Visible and (#matches * 28 + 8) or 0))
    end

    Input:GetPropertyChangedSignal("Text"):Connect(function() refresh(Input.Text) end)
    Input.Focused:Connect(function() refresh("") end)
    Input.FocusLost:Connect(function()
        task.wait(0.15)
        List.Visible = false
        Holder.Size = UDim2.new(1, 0, 0, 56)
    end)

    return Holder
end

return SimpleGUI
