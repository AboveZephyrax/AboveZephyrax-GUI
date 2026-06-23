--[[
    SimpleGUI v2.0
    A clean, professional GUI library for Roblox
    Usage:
        local GUI = loadstring(game:HttpGet("RAW_URL"))()
        local Window = GUI:CreateWindow({ Name = "My Script", Keybind = Enum.KeyCode.RightControl })
        local Tab = Window:CreateTab("Main", "rbxassetid://...")
        Tab:CreateButton({ Name = "Click Me", Callback = function() end })
]]

local SimpleGUI = {}
SimpleGUI.__index = SimpleGUI

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

local Players     = game:GetService("Players")
local UIS         = game:GetService("UserInputService")
local TweenSvc    = game:GetService("TweenService")
local RunSvc      = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local THEME = {
    BG          = Color3.fromRGB(18, 18, 24),
    SURFACE     = Color3.fromRGB(26, 26, 34),
    ELEVATED    = Color3.fromRGB(34, 34, 44),
    BORDER      = Color3.fromRGB(50, 50, 66),
    ACCENT      = Color3.fromRGB(100, 140, 255),
    ACCENT_DIM  = Color3.fromRGB(60, 90, 180),
    SUCCESS     = Color3.fromRGB(80, 200, 120),
    WARNING     = Color3.fromRGB(240, 180, 60),
    DANGER      = Color3.fromRGB(220, 80, 80),
    TEXT        = Color3.fromRGB(240, 240, 248),
    TEXT_DIM    = Color3.fromRGB(160, 160, 180),
    TEXT_MUTED  = Color3.fromRGB(100, 100, 120),
}

local function tween(obj, props, t, style, dir)
    style = style or Enum.EasingStyle.Quart
    dir   = dir   or Enum.EasingDirection.Out
    TweenSvc:Create(obj, TweenInfo.new(t or 0.2, style, dir), props):Play()
end

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or THEME.BORDER
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.Parent = parent
    return s
end

local function frame(parent, props)
    local f = Instance.new("Frame")
    f.BackgroundColor3 = THEME.SURFACE
    f.BorderSizePixel  = 0
    for k, v in pairs(props or {}) do f[k] = v end
    f.Parent = parent
    return f
end

local function label(parent, props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Font     = Enum.Font.GothamMedium
    l.TextSize = 13
    l.TextColor3 = THEME.TEXT
    l.TextXAlignment = Enum.TextXAlignment.Left
    for k, v in pairs(props or {}) do l[k] = v end
    l.Parent = parent
    return l
end

local function button(parent, props)
    local b = Instance.new("TextButton")
    b.BackgroundColor3   = THEME.ELEVATED
    b.BorderSizePixel    = 0
    b.AutoButtonColor    = false
    b.Font               = Enum.Font.GothamMedium
    b.TextSize           = 13
    b.TextColor3         = THEME.TEXT
    b.TextXAlignment     = Enum.TextXAlignment.Left
    for k, v in pairs(props or {}) do b[k] = v end
    b.Parent = parent
    return b
end

local function makeDraggable(handle, target)
    local dragging, dragStart, startPos = false, nil, nil
    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = inp.Position
            startPos  = target.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local d = inp.Position - dragStart
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

function SimpleGUI:CreateWindow(config)
    config = config or {}

    local self      = setmetatable({}, Window)
    self.Tabs       = {}
    self.Flags      = {}
    self.SavedConfig = {}

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name           = "SimpleGUI_v2"
    ScreenGui.ResetOnSpawn   = false
    ScreenGui.DisplayOrder   = 999
    ScreenGui.IgnoreGuiInset = true
    local ok = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
    if not ok then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    local Main = frame(ScreenGui, {
        Size     = UDim2.new(0, 540, 0, 340),
        Position = UDim2.new(0.5, -270, 0.5, -170),
        BackgroundColor3 = THEME.BG,
        Active   = true,
        ClipsDescendants = false,
    })
    corner(Main, 10)
    stroke(Main, THEME.BORDER, 1)

    local Shadow = Instance.new("ImageLabel")
    Shadow.Size             = UDim2.new(1, 40, 1, 40)
    Shadow.Position         = UDim2.new(0, -20, 0, -20)
    Shadow.BackgroundTransparency = 1
    Shadow.Image            = "rbxassetid://6015897843"
    Shadow.ImageColor3      = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.5
    Shadow.ScaleType        = Enum.ScaleType.Slice
    Shadow.SliceCenter      = Rect.new(49, 49, 450, 450)
    Shadow.ZIndex           = -1
    Shadow.Parent           = Main

    local TitleBar = frame(Main, {
        Size             = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = THEME.SURFACE,
        Active           = true,
    })
    corner(TitleBar, 10)

    local TitleBottomBlock = frame(TitleBar, {
        Size             = UDim2.new(1, 0, 0, 10),
        Position         = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = THEME.SURFACE,
    })

    local AccentLine = frame(TitleBar, {
        Size             = UDim2.new(0, 3, 0, 20),
        Position         = UDim2.new(0, 12, 0.5, -10),
        BackgroundColor3 = THEME.ACCENT,
    })
    corner(AccentLine, 2)

    label(TitleBar, {
        Size     = UDim2.new(1, -120, 1, 0),
        Position = UDim2.new(0, 22, 0, 0),
        Text     = config.Name or "SimpleGUI",
        Font     = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = THEME.TEXT,
    })

    if config.SubTitle then
        label(TitleBar, {
            Size     = UDim2.new(1, -120, 1, 0),
            Position = UDim2.new(0, 22, 0, 18),
            Text     = config.SubTitle,
            Font     = Enum.Font.Gotham,
            TextSize = 11,
            TextColor3 = THEME.TEXT_MUTED,
        })
    end

    local function makeWinBtn(text, xOffset, bgColor)
        local btn = button(TitleBar, {
            Size             = UDim2.new(0, 24, 0, 24),
            Position         = UDim2.new(1, xOffset, 0.5, -12),
            BackgroundColor3 = bgColor,
            Text             = text,
            TextSize         = 13,
            TextXAlignment   = Enum.TextXAlignment.Center,
            Font             = Enum.Font.GothamBold,
        })
        corner(btn, 6)
        btn.MouseEnter:Connect(function() tween(btn, {BackgroundTransparency = 0.3}, 0.1) end)
        btn.MouseLeave:Connect(function() tween(btn, {BackgroundTransparency = 0}, 0.1) end)
        return btn
    end

    local CloseBtn = makeWinBtn("✕", -32, THEME.DANGER)
    local MinBtn   = makeWinBtn("─", -62, THEME.ELEVATED)

    makeDraggable(TitleBar, Main)

    local Body = frame(Main, {
        Size             = UDim2.new(1, 0, 1, -38),
        Position         = UDim2.new(0, 0, 0, 38),
        BackgroundTransparency = 1,
    })

    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        tween(Main, { Size = minimized and UDim2.new(0, 540, 0, 38) or UDim2.new(0, 540, 0, 340) }, 0.25, Enum.EasingStyle.Quart)
        task.delay(0.05, function()
            Body.Visible = not minimized
        end)
        MinBtn.Text = minimized and "□" or "─"
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        tween(Main, { BackgroundTransparency = 1 }, 0.2)
        task.wait(0.2)
        ScreenGui:Destroy()
    end)

    local keybind = config.Keybind or Enum.KeyCode.RightControl
    UIS.InputBegan:Connect(function(inp, gp)
        if not gp and inp.KeyCode == keybind then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)

    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Size                = UDim2.new(0, 136, 1, -12)
    Sidebar.Position            = UDim2.new(0, 6, 0, 6)
    Sidebar.BackgroundColor3    = THEME.SURFACE
    Sidebar.BorderSizePixel     = 0
    Sidebar.ScrollBarThickness  = 2
    Sidebar.ScrollBarImageColor3 = THEME.ACCENT
    Sidebar.CanvasSize          = UDim2.new(0, 0, 0, 0)
    Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Sidebar.Parent              = Body
    corner(Sidebar, 8)
    stroke(Sidebar, THEME.BORDER, 1)

    local SidebarPad = Instance.new("UIPadding")
    SidebarPad.PaddingTop    = UDim.new(0, 6)
    SidebarPad.PaddingBottom = UDim.new(0, 6)
    SidebarPad.PaddingLeft   = UDim.new(0, 6)
    SidebarPad.PaddingRight  = UDim.new(0, 6)
    SidebarPad.Parent        = Sidebar

    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.Padding    = UDim.new(0, 4)
    SidebarLayout.SortOrder  = Enum.SortOrder.LayoutOrder
    SidebarLayout.Parent     = Sidebar

    local ContentArea = Instance.new("ScrollingFrame")
    ContentArea.Size                = UDim2.new(1, -152, 1, -12)
    ContentArea.Position            = UDim2.new(0, 148, 0, 6)
    ContentArea.BackgroundTransparency = 1
    ContentArea.BorderSizePixel     = 0
    ContentArea.ScrollBarThickness  = 3
    ContentArea.ScrollBarImageColor3 = THEME.ACCENT
    ContentArea.CanvasSize          = UDim2.new(0, 0, 0, 0)
    ContentArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ContentArea.Parent              = Body

    local ContentPad = Instance.new("UIPadding")
    ContentPad.PaddingRight = UDim.new(0, 4)
    ContentPad.Parent       = ContentArea

    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Padding   = UDim.new(0, 6)
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Parent    = ContentArea

    self.ScreenGui   = ScreenGui
    self.Main        = Main
    self.Body        = Body
    self.Sidebar     = Sidebar
    self.ContentArea = ContentArea

    return self
end

function Window:Notify(config)
    config = config or {}
    local title    = config.Title    or "Notification"
    local content  = config.Content  or ""
    local duration = config.Duration or 3
    local ntype    = config.Type     or "info"

    local accentColor = ({
        info    = THEME.ACCENT,
        success = THEME.SUCCESS,
        warning = THEME.WARNING,
        error   = THEME.DANGER,
    })[ntype] or THEME.ACCENT

    if not self._notifHolder then
        local h = frame(self.ScreenGui, {
            Size             = UDim2.new(0, 270, 1, -20),
            Position         = UDim2.new(1, -280, 0, 10),
            BackgroundTransparency = 1,
        })
        local lay = Instance.new("UIListLayout")
        lay.Padding           = UDim.new(0, 8)
        lay.VerticalAlignment = Enum.VerticalAlignment.Bottom
        lay.SortOrder         = Enum.SortOrder.LayoutOrder
        lay.Parent            = h
        self._notifHolder = h
    end

    local Box = frame(self._notifHolder, {
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundColor3 = THEME.SURFACE,
        BackgroundTransparency = 1,
        LayoutOrder      = os.clock(),
    })
    corner(Box, 8)
    stroke(Box, accentColor, 1, 1)

    local Pad = Instance.new("UIPadding")
    Pad.PaddingTop    = UDim.new(0, 10)
    Pad.PaddingBottom = UDim.new(0, 10)
    Pad.PaddingLeft   = UDim.new(0, 12)
    Pad.PaddingRight  = UDim.new(0, 12)
    Pad.Parent        = Box

    local BoxLayout = Instance.new("UIListLayout")
    BoxLayout.Padding   = UDim.new(0, 3)
    BoxLayout.SortOrder = Enum.SortOrder.LayoutOrder
    BoxLayout.Parent    = Box

    local Indicator = frame(Box, {
        Size             = UDim2.new(0, 3, 1, 0),
        Position         = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = accentColor,
    })
    corner(Indicator, 2)

    local TL = label(Box, {
        Size         = UDim2.new(1, 0, 0, 18),
        Text         = title,
        Font         = Enum.Font.GothamBold,
        TextSize     = 13,
        TextTransparency = 1,
        LayoutOrder  = 0,
    })
    local CL = label(Box, {
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        Text             = content,
        TextSize         = 12,
        TextColor3       = THEME.TEXT_DIM,
        TextWrapped      = true,
        TextTransparency = 1,
        LayoutOrder      = 1,
    })

    Box.Position = UDim2.new(1, 10, 0, 0)
    tween(Box, { BackgroundTransparency = 0, Position = UDim2.new(0, 0, 0, 0) }, 0.3)
    tween(stroke(Box, accentColor, 1, 1), { Transparency = 0 }, 0.3)
    tween(TL, { TextTransparency = 0 }, 0.3)
    tween(CL, { TextTransparency = 0 }, 0.3)

    task.delay(duration, function()
        tween(Box, { BackgroundTransparency = 1, Position = UDim2.new(1, 10, 0, 0) }, 0.3)
        tween(TL, { TextTransparency = 1 }, 0.3)
        tween(CL, { TextTransparency = 1 }, 0.3)
        task.wait(0.35)
        Box:Destroy()
    end)
end

function Window:SaveFlag(flag, value)
    self.Flags[flag]       = value
    self.SavedConfig[flag] = value
end

function Window:GetFlag(flag)
    return self.Flags[flag]
end

function Window:CreateTab(name, icon)
    local tab = setmetatable({}, Tab)

    local TabBtn = button(self.Sidebar, {
        Size             = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = THEME.ELEVATED,
        BackgroundTransparency = 1,
        Text             = "",
        LayoutOrder      = #self.Tabs,
        AutoButtonColor  = false,
    })
    corner(TabBtn, 7)

    local BtnLayout = Instance.new("UIListLayout")
    BtnLayout.FillDirection  = Enum.FillDirection.Horizontal
    BtnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    BtnLayout.Padding        = UDim.new(0, 7)
    BtnLayout.Parent         = TabBtn

    local BtnPad = Instance.new("UIPadding")
    BtnPad.PaddingLeft  = UDim.new(0, 10)
    BtnPad.Parent       = TabBtn

    if icon and icon ~= "" then
        local Ico = Instance.new("ImageLabel")
        Ico.Size                  = UDim2.new(0, 14, 0, 14)
        Ico.BackgroundTransparency = 1
        Ico.Image                 = icon
        Ico.ImageColor3           = THEME.TEXT_DIM
        Ico.Parent                = TabBtn
    end

    local BtnLabel = label(TabBtn, {
        Size       = UDim2.new(1, 0, 1, 0),
        Text       = name,
        Font       = Enum.Font.GothamMedium,
        TextSize   = 12,
        TextColor3 = THEME.TEXT_DIM,
    })

    local ActiveBar = frame(TabBtn, {
        Size             = UDim2.new(0, 3, 0, 16),
        Position         = UDim2.new(1, -3, 0.5, -8),
        BackgroundColor3 = THEME.ACCENT,
        BackgroundTransparency = 1,
    })
    corner(ActiveBar, 2)

    local Container = frame(self.ContentArea, {
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Visible          = (#self.Tabs == 0),
        LayoutOrder      = #self.Tabs,
    })

    local ContainerLayout = Instance.new("UIListLayout")
    ContainerLayout.Padding   = UDim.new(0, 6)
    ContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContainerLayout.Parent    = Container

    tab.Container = Container
    tab.Button    = TabBtn
    tab.Window    = self
    tab._label    = BtnLabel
    tab._bar      = ActiveBar

    table.insert(self.Tabs, tab)

    local function setActive(isActive)
        if isActive then
            tween(TabBtn, { BackgroundTransparency = 0, BackgroundColor3 = THEME.ELEVATED }, 0.15)
            tween(BtnLabel, { TextColor3 = THEME.TEXT }, 0.15)
            tween(ActiveBar, { BackgroundTransparency = 0 }, 0.15)
        else
            tween(TabBtn, { BackgroundTransparency = 1 }, 0.15)
            tween(BtnLabel, { TextColor3 = THEME.TEXT_DIM }, 0.15)
            tween(ActiveBar, { BackgroundTransparency = 1 }, 0.15)
        end
    end

    if #self.Tabs == 1 then setActive(true) end

    TabBtn.MouseEnter:Connect(function()
        if not Container.Visible then
            tween(TabBtn, { BackgroundTransparency = 0.6 }, 0.1)
        end
    end)
    TabBtn.MouseLeave:Connect(function()
        if not Container.Visible then
            tween(TabBtn, { BackgroundTransparency = 1 }, 0.1)
        end
    end)

    TabBtn.MouseButton1Click:Connect(function()
        for _, t in ipairs(self.Tabs) do
            t.Container.Visible = false
            t:_setActive(false)
        end
        Container.Visible = true
        setActive(true)
    end)

    tab._setActive = setActive

    return tab
end

function Tab:CreateSection(name)
    local SectionFrame = frame(self.Container, {
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
    })

    local SectionLayout = Instance.new("UIListLayout")
    SectionLayout.Padding   = UDim.new(0, 5)
    SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SectionLayout.Parent    = SectionFrame

    local HeaderRow = frame(SectionFrame, {
        Size             = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        LayoutOrder      = 0,
    })

    local Line1 = frame(HeaderRow, {
        Size             = UDim2.new(0.12, 0, 0, 1),
        Position         = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = THEME.BORDER,
    })

    label(HeaderRow, {
        Size         = UDim2.new(1, 0, 1, 0),
        Text         = name,
        Font         = Enum.Font.GothamBold,
        TextSize     = 11,
        TextColor3   = THEME.TEXT_MUTED,
        TextXAlignment = Enum.TextXAlignment.Center,
    })

    local Line2 = frame(HeaderRow, {
        Size             = UDim2.new(0.12, 0, 0, 1),
        Position         = UDim2.new(0.88, 0, 0.5, 0),
        BackgroundColor3 = THEME.BORDER,
    })

    local ItemsHolder = frame(SectionFrame, {
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder      = 1,
    })

    local ItemsLayout = Instance.new("UIListLayout")
    ItemsLayout.Padding   = UDim.new(0, 5)
    ItemsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ItemsLayout.Parent    = ItemsHolder

    local sectionTab = setmetatable({}, Tab)
    sectionTab.Container = ItemsHolder
    sectionTab.Window    = self.Window
    return sectionTab
end

function Tab:CreateLabel(text)
    local L = label(self.Container, {
        Size       = UDim2.new(1, 0, 0, 22),
        Text       = text,
        TextSize   = 12,
        TextColor3 = THEME.TEXT_DIM,
    })
    return L
end

function Tab:CreateButton(config)
    config = config or {}

    local Holder = frame(self.Container, {
        Size             = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = THEME.ELEVATED,
    })
    corner(Holder, 7)
    stroke(Holder, THEME.BORDER, 1)

    local Layout = Instance.new("UIListLayout")
    Layout.FillDirection  = Enum.FillDirection.Horizontal
    Layout.VerticalAlignment = Enum.VerticalAlignment.Center
    Layout.Padding        = UDim.new(0, 8)
    Layout.Parent         = Holder

    local Pad = Instance.new("UIPadding")
    Pad.PaddingLeft  = UDim.new(0, 12)
    Pad.PaddingRight = UDim.new(0, 12)
    Pad.Parent       = Holder

    label(Holder, {
        Size       = UDim2.new(1, 0, 1, 0),
        Text       = config.Name or "Button",
        Font       = Enum.Font.GothamMedium,
        TextSize   = 13,
    })

    local ClickArea = button(Holder, {
        Size             = UDim2.new(1, 0, 1, 0),
        Position         = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text             = "",
        ZIndex           = 5,
    })

    ClickArea.MouseEnter:Connect(function()
        tween(Holder, { BackgroundColor3 = THEME.BORDER }, 0.12)
    end)
    ClickArea.MouseLeave:Connect(function()
        tween(Holder, { BackgroundColor3 = THEME.ELEVATED }, 0.12)
    end)
    ClickArea.MouseButton1Down:Connect(function()
        tween(Holder, { BackgroundColor3 = THEME.ACCENT_DIM }, 0.08)
    end)
    ClickArea.MouseButton1Up:Connect(function()
        tween(Holder, { BackgroundColor3 = THEME.BORDER }, 0.08)
    end)
    ClickArea.MouseButton1Click:Connect(function()
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
    if config.Flag then self.Window:SaveFlag(config.Flag, state) end

    local Holder = frame(self.Container, {
        Size             = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = THEME.ELEVATED,
    })
    corner(Holder, 7)
    stroke(Holder, THEME.BORDER, 1)

    local Pad = Instance.new("UIPadding")
    Pad.PaddingLeft  = UDim.new(0, 12)
    Pad.PaddingRight = UDim.new(0, 12)
    Pad.Parent       = Holder

    label(Holder, {
        Size       = UDim2.new(1, -50, 1, 0),
        Text       = config.Name or "Toggle",
        Font       = Enum.Font.GothamMedium,
        TextSize   = 13,
    })

    if config.Description then
        label(Holder, {
            Size       = UDim2.new(1, -50, 1, 0),
            Position   = UDim2.new(0, 12, 0, 18),
            Text       = config.Description,
            TextSize   = 11,
            TextColor3 = THEME.TEXT_MUTED,
        })
        Holder.Size = UDim2.new(1, 0, 0, 46)
    end

    local Track = frame(Holder, {
        Size             = UDim2.new(0, 38, 0, 20),
        Position         = UDim2.new(1, -38, 0.5, -10),
        BackgroundColor3 = state and THEME.ACCENT or THEME.BORDER,
    })
    corner(Track, 10)

    local Knob = frame(Track, {
        Size             = UDim2.new(0, 14, 0, 14),
        Position         = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    })
    corner(Knob, 7)

    local ClickArea = button(Holder, {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = "",
        ZIndex           = 5,
    })

    ClickArea.MouseEnter:Connect(function()
        tween(Holder, { BackgroundColor3 = THEME.BORDER }, 0.12)
    end)
    ClickArea.MouseLeave:Connect(function()
        tween(Holder, { BackgroundColor3 = THEME.ELEVATED }, 0.12)
    end)

    ClickArea.MouseButton1Click:Connect(function()
        state = not state
        tween(Track, { BackgroundColor3 = state and THEME.ACCENT or THEME.BORDER }, 0.18)
        tween(Knob, { Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7) }, 0.18)
        if config.Flag then self.Window:SaveFlag(config.Flag, state) end
        if config.Callback then config.Callback(state) end
    end)

    return Holder
end

function Tab:CreateSlider(config)
    config = config or {}
    local range = config.Range or {0, 100}
    local min, max = range[1], range[2]
    local value = math.clamp(config.CurrentValue or min, min, max)
    local suffix = config.Suffix or ""
    if config.Flag and self.Window.SavedConfig[config.Flag] ~= nil then
        value = self.Window.SavedConfig[config.Flag]
    end
    if config.Flag then self.Window:SaveFlag(config.Flag, value) end

    local Holder = frame(self.Container, {
        Size             = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = THEME.ELEVATED,
    })
    corner(Holder, 7)
    stroke(Holder, THEME.BORDER, 1)

    local Pad = Instance.new("UIPadding")
    Pad.PaddingLeft  = UDim.new(0, 12)
    Pad.PaddingRight = UDim.new(0, 12)
    Pad.Parent       = Holder

    local TopRow = frame(Holder, {
        Size             = UDim2.new(1, 0, 0, 22),
        Position         = UDim2.new(0, 0, 0, 6),
        BackgroundTransparency = 1,
    })

    label(TopRow, {
        Size       = UDim2.new(0.7, 0, 1, 0),
        Text       = config.Name or "Slider",
        Font       = Enum.Font.GothamMedium,
        TextSize   = 13,
    })

    local ValLabel = label(TopRow, {
        Size           = UDim2.new(0.3, 0, 1, 0),
        Position       = UDim2.new(0.7, 0, 0, 0),
        Text           = tostring(value) .. suffix,
        TextSize       = 12,
        TextColor3     = THEME.ACCENT,
        Font           = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Right,
    })

    local Track = frame(Holder, {
        Size             = UDim2.new(1, 0, 0, 6),
        Position         = UDim2.new(0, 0, 0, 36),
        BackgroundColor3 = THEME.BG,
    })
    corner(Track, 3)

    local Fill = frame(Track, {
        Size             = UDim2.new((value - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = THEME.ACCENT,
    })
    corner(Fill, 3)

    local KnobHandle = frame(Track, {
        Size             = UDim2.new(0, 14, 0, 14),
        AnchorPoint      = Vector2.new(0.5, 0.5),
        Position         = UDim2.new((value - min) / (max - min), 0, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        ZIndex           = 5,
    })
    corner(KnobHandle, 7)

    local dragging = false

    local function updateSlider(inputPos)
        local rel = math.clamp((inputPos.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        local rawVal = min + (max - min) * rel
        local step = config.Increment or 1
        value = math.floor(rawVal / step + 0.5) * step
        value = math.clamp(value, min, max)
        local pct = (value - min) / (max - min)
        Fill.Size = UDim2.new(pct, 0, 1, 0)
        KnobHandle.Position = UDim2.new(pct, 0, 0.5, 0)
        ValLabel.Text = tostring(value) .. suffix
        if config.Flag then self.Window:SaveFlag(config.Flag, value) end
        if config.Callback then config.Callback(value) end
    end

    Track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSlider(inp.Position)
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(inp.Position)
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return Holder
end

function Tab:CreateInput(config)
    config = config or {}
    local currentVal = config.CurrentValue or ""
    if config.Flag and self.Window.SavedConfig[config.Flag] ~= nil then
        currentVal = self.Window.SavedConfig[config.Flag]
    end
    if config.Flag then self.Window:SaveFlag(config.Flag, currentVal) end

    local Holder = frame(self.Container, {
        Size             = UDim2.new(1, 0, 0, 58),
        BackgroundColor3 = THEME.ELEVATED,
    })
    corner(Holder, 7)
    stroke(Holder, THEME.BORDER, 1)

    local Pad = Instance.new("UIPadding")
    Pad.PaddingLeft  = UDim.new(0, 12)
    Pad.PaddingRight = UDim.new(0, 12)
    Pad.Parent       = Holder

    label(Holder, {
        Size     = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 5),
        Text     = config.Name or "Input",
        Font     = Enum.Font.GothamMedium,
        TextSize = 13,
    })

    local InputFrame = frame(Holder, {
        Size             = UDim2.new(1, 0, 0, 26),
        Position         = UDim2.new(0, 0, 0, 28),
        BackgroundColor3 = THEME.BG,
    })
    corner(InputFrame, 5)
    local InputStroke = stroke(InputFrame, THEME.BORDER, 1)

    local InputBox = Instance.new("TextBox")
    InputBox.Size                = UDim2.new(1, -8, 1, 0)
    InputBox.Position            = UDim2.new(0, 4, 0, 0)
    InputBox.BackgroundTransparency = 1
    InputBox.PlaceholderText     = config.PlaceholderText or "Type here..."
    InputBox.Text                = currentVal
    InputBox.TextColor3          = THEME.TEXT
    InputBox.PlaceholderColor3   = THEME.TEXT_MUTED
    InputBox.Font                = Enum.Font.Gotham
    InputBox.TextSize            = 12
    InputBox.ClearTextOnFocus    = false
    InputBox.Parent              = InputFrame

    InputBox.Focused:Connect(function()
        tween(InputStroke, { Color = THEME.ACCENT }, 0.15)
    end)
    InputBox.FocusLost:Connect(function(enter)
        tween(InputStroke, { Color = THEME.BORDER }, 0.15)
        if config.Flag then self.Window:SaveFlag(config.Flag, InputBox.Text) end
        if config.Callback then config.Callback(InputBox.Text, enter) end
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
    if config.Flag then self.Window:SaveFlag(config.Flag, selected) end
    local open = false

    local Holder = frame(self.Container, {
        Size             = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = THEME.ELEVATED,
        ClipsDescendants = false,
        ZIndex           = 2,
    })
    corner(Holder, 7)
    stroke(Holder, THEME.BORDER, 1)

    local Pad = Instance.new("UIPadding")
    Pad.PaddingLeft  = UDim.new(0, 12)
    Pad.PaddingRight = UDim.new(0, 10)
    Pad.Parent       = Holder

    local NameLabel = label(Holder, {
        Size       = UDim2.new(0.5, 0, 1, 0),
        Text       = config.Name or "Dropdown",
        Font       = Enum.Font.GothamMedium,
        TextSize   = 13,
        ZIndex     = 2,
    })

    local ValLabel = label(Holder, {
        Size           = UDim2.new(0.5, -20, 1, 0),
        Position       = UDim2.new(0.5, 0, 0, 0),
        Text           = tostring(selected or "Select..."),
        TextSize       = 12,
        TextColor3     = THEME.ACCENT,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex         = 2,
    })

    local Arrow = label(Holder, {
        Size           = UDim2.new(0, 16, 1, 0),
        Position       = UDim2.new(1, -16, 0, 0),
        Text           = "▾",
        TextSize       = 14,
        TextColor3     = THEME.TEXT_DIM,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex         = 2,
    })

    local List = frame(Holder, {
        Size             = UDim2.new(1, 0, 0, #options * 28),
        Position         = UDim2.new(0, 0, 1, 4),
        BackgroundColor3 = THEME.ELEVATED,
        Visible          = false,
        ZIndex           = 10,
        ClipsDescendants = true,
    })
    corner(List, 7)
    stroke(List, THEME.BORDER, 1)

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent    = List

    for i, option in ipairs(options) do
        local Opt = button(List, {
            Size             = UDim2.new(1, 0, 0, 28),
            BackgroundColor3 = THEME.ELEVATED,
            BackgroundTransparency = 1,
            Text             = "",
            LayoutOrder      = i,
            ZIndex           = 11,
        })

        local OptPad = Instance.new("UIPadding")
        OptPad.PaddingLeft = UDim.new(0, 12)
        OptPad.Parent      = Opt

        label(Opt, {
            Size       = UDim2.new(1, 0, 1, 0),
            Text       = tostring(option),
            TextSize   = 12,
            TextColor3 = option == selected and THEME.ACCENT or THEME.TEXT_DIM,
            ZIndex     = 12,
        })

        Opt.MouseEnter:Connect(function()
            tween(Opt, { BackgroundTransparency = 0.7 }, 0.1)
        end)
        Opt.MouseLeave:Connect(function()
            tween(Opt, { BackgroundTransparency = 1 }, 0.1)
        end)
        Opt.MouseButton1Click:Connect(function()
            selected = option
            ValLabel.Text = tostring(selected)
            open = false
            List.Visible = false
            tween(Arrow, { Rotation = 0 }, 0.15)
            Holder.Size = UDim2.new(1, 0, 0, 34)
            if config.Flag then self.Window:SaveFlag(config.Flag, selected) end
            if config.Callback then config.Callback(selected) end
        end)
    end

    local ClickArea = button(Holder, {
        Size             = UDim2.new(1, 0, 0, 34),
        BackgroundTransparency = 1,
        Text             = "",
        ZIndex           = 5,
    })

    ClickArea.MouseButton1Click:Connect(function()
        open = not open
        List.Visible = open
        tween(Arrow, { Rotation = open and 180 or 0 }, 0.15)
        if open then
            Holder.Size = UDim2.new(1, 0, 0, 34 + (#options * 28) + 4)
        else
            Holder.Size = UDim2.new(1, 0, 0, 34)
        end
    end)

    return Holder
end

function Tab:CreateColorPicker(config)
    config = config or {}
    local color = config.Color or Color3.fromRGB(100, 140, 255)
    if config.Flag and self.Window.SavedConfig[config.Flag] ~= nil then
        local c = self.Window.SavedConfig[config.Flag]
        color = Color3.new(c.R, c.G, c.B)
    end
    if config.Flag then
        self.Window:SaveFlag(config.Flag, { R = color.R, G = color.G, B = color.B })
    end

    local hue, sat, val = color:ToHSV()
    local open = false

    local Holder = frame(self.Container, {
        Size             = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = THEME.ELEVATED,
        ClipsDescendants = false,
        ZIndex           = 2,
    })
    corner(Holder, 7)
    stroke(Holder, THEME.BORDER, 1)

    local Pad = Instance.new("UIPadding")
    Pad.PaddingLeft  = UDim.new(0, 12)
    Pad.PaddingRight = UDim.new(0, 12)
    Pad.Parent       = Holder

    label(Holder, {
        Size       = UDim2.new(1, -44, 1, 0),
        Text       = config.Name or "Color",
        Font       = Enum.Font.GothamMedium,
        TextSize   = 13,
        ZIndex     = 2,
    })

    local Swatch = frame(Holder, {
        Size             = UDim2.new(0, 28, 0, 18),
        Position         = UDim2.new(1, -28, 0.5, -9),
        BackgroundColor3 = color,
        ZIndex           = 3,
    })
    corner(Swatch, 4)
    stroke(Swatch, THEME.BORDER, 1)

    local SwatchBtn = button(Swatch, {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = "",
        ZIndex           = 4,
    })

    local Panel = frame(Holder, {
        Size             = UDim2.new(1, 0, 0, 100),
        Position         = UDim2.new(0, 0, 1, 4),
        BackgroundColor3 = THEME.ELEVATED,
        Visible          = false,
        ZIndex           = 8,
    })
    corner(Panel, 7)
    stroke(Panel, THEME.BORDER, 1)

    local PanelPad = Instance.new("UIPadding")
    PanelPad.PaddingTop    = UDim.new(0, 8)
    PanelPad.PaddingBottom = UDim.new(0, 8)
    PanelPad.PaddingLeft   = UDim.new(0, 10)
    PanelPad.PaddingRight  = UDim.new(0, 10)
    PanelPad.Parent        = Panel

    local PanelLayout = Instance.new("UIListLayout")
    PanelLayout.Padding   = UDim.new(0, 8)
    PanelLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PanelLayout.Parent    = Panel

    local function makeColorTrack(gradientColors, layoutOrder)
        local TrackHolder = frame(Panel, {
            Size             = UDim2.new(1, 0, 0, 14),
            BackgroundColor3 = Color3.fromRGB(255,255,255),
            LayoutOrder      = layoutOrder,
            ZIndex           = 9,
        })
        corner(TrackHolder, 7)

        local Gradient = Instance.new("UIGradient")
        Gradient.Color  = gradientColors
        Gradient.Parent = TrackHolder

        local Knob2 = frame(TrackHolder, {
            Size             = UDim2.new(0, 10, 1, 4),
            AnchorPoint      = Vector2.new(0.5, 0.5),
            Position         = UDim2.new(0, 0, 0.5, 0),
            BackgroundColor3 = Color3.fromRGB(255,255,255),
            ZIndex           = 10,
        })
        corner(Knob2, 3)
        stroke(Knob2, THEME.BORDER, 1)

        return TrackHolder, Knob2
    end

    local hueTrack, hueKnob = makeColorTrack(ColorSequence.new({
        ColorSequenceKeypoint.new(0,    Color3.fromRGB(255,0,0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,255,0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
        ColorSequenceKeypoint.new(0.5,  Color3.fromRGB(0,255,255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,0,255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
        ColorSequenceKeypoint.new(1,    Color3.fromRGB(255,0,0)),
    }), 0)

    local satTrack, satKnob = makeColorTrack(ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(1, Color3.fromHSV(hue, 1, 1)),
    }), 1)

    local valTrack, valKnob = makeColorTrack(ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255)),
    }), 2)

    hueKnob.Position = UDim2.new(hue, 0, 0.5, 0)
    satKnob.Position = UDim2.new(sat, 0, 0.5, 0)
    valKnob.Position = UDim2.new(val, 0, 0.5, 0)

    local function refreshColor()
        color = Color3.fromHSV(hue, sat, val)
        Swatch.BackgroundColor3 = color
        satTrack:FindFirstChildWhichIsA("UIGradient").Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV(hue, 1, 1)),
        })
        if config.Flag then self.Window:SaveFlag(config.Flag, { R = color.R, G = color.G, B = color.B }) end
        if config.Callback then config.Callback(color) end
    end

    local function makeDragTrack(track, knob, callback)
        local drag = false
        track.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                drag = true
                local rel = math.clamp((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                knob.Position = UDim2.new(rel, 0, 0.5, 0)
                callback(rel)
            end
        end)
        UIS.InputChanged:Connect(function(inp)
            if drag and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                local rel = math.clamp((inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                knob.Position = UDim2.new(rel, 0, 0.5, 0)
                callback(rel)
            end
        end)
        UIS.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
        end)
    end

    makeDragTrack(hueTrack, hueKnob, function(v) hue = v; refreshColor() end)
    makeDragTrack(satTrack, satKnob, function(v) sat = v; refreshColor() end)
    makeDragTrack(valTrack, valKnob, function(v) val = v; refreshColor() end)

    SwatchBtn.MouseButton1Click:Connect(function()
        open = not open
        Panel.Visible = open
        Holder.Size = open and UDim2.new(1, 0, 0, 34 + 104) or UDim2.new(1, 0, 0, 34)
    end)

    return Holder
end

function Tab:CreatePlayerPicker(config)
    config = config or {}

    local Holder = frame(self.Container, {
        Size             = UDim2.new(1, 0, 0, 58),
        BackgroundColor3 = THEME.ELEVATED,
        ClipsDescendants = false,
        ZIndex           = 2,
    })
    corner(Holder, 7)
    stroke(Holder, THEME.BORDER, 1)

    local Pad = Instance.new("UIPadding")
    Pad.PaddingLeft  = UDim.new(0, 12)
    Pad.PaddingRight = UDim.new(0, 12)
    Pad.Parent       = Holder

    label(Holder, {
        Size     = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 5),
        Text     = config.Name or "Player",
        Font     = Enum.Font.GothamMedium,
        TextSize = 13,
        ZIndex   = 2,
    })

    local InputFrame = frame(Holder, {
        Size             = UDim2.new(1, 0, 0, 26),
        Position         = UDim2.new(0, 0, 0, 28),
        BackgroundColor3 = THEME.BG,
        ZIndex           = 2,
    })
    corner(InputFrame, 5)
    local InputStroke = stroke(InputFrame, THEME.BORDER, 1)

    local InputBox = Instance.new("TextBox")
    InputBox.Size              = UDim2.new(1, -8, 1, 0)
    InputBox.Position          = UDim2.new(0, 4, 0, 0)
    InputBox.BackgroundTransparency = 1
    InputBox.PlaceholderText   = config.PlaceholderText or "Search player..."
    InputBox.Text              = ""
    InputBox.TextColor3        = THEME.TEXT
    InputBox.PlaceholderColor3 = THEME.TEXT_MUTED
    InputBox.Font              = Enum.Font.Gotham
    InputBox.TextSize          = 12
    InputBox.ClearTextOnFocus  = true
    InputBox.ZIndex            = 3
    InputBox.Parent            = InputFrame

    InputBox.Focused:Connect(function()
        tween(InputStroke, { Color = THEME.ACCENT }, 0.15)
    end)
    InputBox.FocusLost:Connect(function()
        tween(InputStroke, { Color = THEME.BORDER }, 0.15)
    end)

    local List = frame(Holder, {
        Size             = UDim2.new(1, 0, 0, 0),
        Position         = UDim2.new(0, 0, 1, 4),
        BackgroundColor3 = THEME.ELEVATED,
        Visible          = false,
        ZIndex           = 8,
        ClipsDescendants = true,
    })
    corner(List, 7)
    stroke(List, THEME.BORDER, 1)

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent    = List

    local function refresh(filter)
        for _, c in ipairs(List:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
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
        for _, plr in ipairs(matches) do
            local Opt = button(List, {
                Size             = UDim2.new(1, 0, 0, 28),
                BackgroundColor3 = THEME.ELEVATED,
                BackgroundTransparency = 1,
                Text             = "",
                ZIndex           = 9,
            })
            local OptPad = Instance.new("UIPadding")
            OptPad.PaddingLeft = UDim.new(0, 10)
            OptPad.Parent      = Opt
            label(Opt, {
                Size       = UDim2.new(1, 0, 1, 0),
                Text       = plr.Name,
                TextSize   = 12,
                TextColor3 = THEME.TEXT_DIM,
                ZIndex     = 10,
            })
            Opt.MouseEnter:Connect(function() tween(Opt, { BackgroundTransparency = 0.7 }, 0.1) end)
            Opt.MouseLeave:Connect(function() tween(Opt, { BackgroundTransparency = 1 }, 0.1) end)
            Opt.MouseButton1Click:Connect(function()
                InputBox.Text = plr.Name
                List.Visible = false
                Holder.Size = UDim2.new(1, 0, 0, 58)
                if config.Callback then config.Callback(plr) end
            end)
        end
        List.Size = UDim2.new(1, 0, 0, #matches * 28)
        List.Visible = #matches > 0
        Holder.Size = UDim2.new(1, 0, 0, 58 + (List.Visible and (#matches * 28) + 4 or 0))
    end

    InputBox:GetPropertyChangedSignal("Text"):Connect(function() refresh(InputBox.Text) end)
    InputBox.Focused:Connect(function() refresh("") end)
    InputBox.FocusLost:Connect(function()
        task.wait(0.2)
        List.Visible = false
        Holder.Size = UDim2.new(1, 0, 0, 58)
    end)

    return Holder
end

function Tab:CreateKeybind(config)
    config = config or {}
    local currentKey = config.CurrentKey or Enum.KeyCode.Unknown
    if config.Flag and self.Window.SavedConfig[config.Flag] ~= nil then
        currentKey = self.Window.SavedConfig[config.Flag]
    end
    if config.Flag then self.Window:SaveFlag(config.Flag, currentKey) end
    local listening = false

    local Holder = frame(self.Container, {
        Size             = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = THEME.ELEVATED,
    })
    corner(Holder, 7)
    stroke(Holder, THEME.BORDER, 1)

    local Pad = Instance.new("UIPadding")
    Pad.PaddingLeft  = UDim.new(0, 12)
    Pad.PaddingRight = UDim.new(0, 12)
    Pad.Parent       = Holder

    label(Holder, {
        Size       = UDim2.new(1, -80, 1, 0),
        Text       = config.Name or "Keybind",
        Font       = Enum.Font.GothamMedium,
        TextSize   = 13,
    })

    local KeyBtn = button(Holder, {
        Size             = UDim2.new(0, 72, 0, 22),
        Position         = UDim2.new(1, -72, 0.5, -11),
        BackgroundColor3 = THEME.BG,
        Text             = currentKey.Name,
        TextSize         = 11,
        TextXAlignment   = Enum.TextXAlignment.Center,
        Font             = Enum.Font.GothamBold,
        TextColor3       = THEME.ACCENT,
        ZIndex           = 3,
    })
    corner(KeyBtn, 5)
    stroke(KeyBtn, THEME.BORDER, 1)

    KeyBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        KeyBtn.Text = "..."
        tween(KeyBtn, { BackgroundColor3 = THEME.ACCENT_DIM }, 0.1)

        local conn
        conn = UIS.InputBegan:Connect(function(inp, gp)
            if gp then return end
            if inp.UserInputType == Enum.UserInputType.Keyboard then
                currentKey = inp.KeyCode
                KeyBtn.Text = currentKey.Name
                tween(KeyBtn, { BackgroundColor3 = THEME.BG }, 0.1)
                listening = false
                conn:Disconnect()
                if config.Flag then self.Window:SaveFlag(config.Flag, currentKey) end
                if config.Callback then config.Callback(currentKey) end
            end
        end)
    end)

    KeyBtn.MouseEnter:Connect(function()
        if not listening then tween(KeyBtn, { BackgroundColor3 = THEME.ELEVATED }, 0.1) end
    end)
    KeyBtn.MouseLeave:Connect(function()
        if not listening then tween(KeyBtn, { BackgroundColor3 = THEME.BG }, 0.1) end
    end)

    return Holder
end

function Tab:CreateMultiDropdown(config)
    config = config or {}
    local options  = config.Options or {}
    local selected = {}
    if config.Flag and self.Window.SavedConfig[config.Flag] ~= nil then
        selected = self.Window.SavedConfig[config.Flag]
    end
    if config.Flag then self.Window:SaveFlag(config.Flag, selected) end
    local open = false

    local function getDisplay()
        if #selected == 0 then return "None" end
        if #selected > 2 then return #selected .. " selected" end
        return table.concat(selected, ", ")
    end

    local Holder = frame(self.Container, {
        Size             = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = THEME.ELEVATED,
        ClipsDescendants = false,
        ZIndex           = 2,
    })
    corner(Holder, 7)
    stroke(Holder, THEME.BORDER, 1)

    local Pad = Instance.new("UIPadding")
    Pad.PaddingLeft  = UDim.new(0, 12)
    Pad.PaddingRight = UDim.new(0, 10)
    Pad.Parent       = Holder

    label(Holder, {
        Size       = UDim2.new(0.45, 0, 1, 0),
        Text       = config.Name or "Multi Select",
        Font       = Enum.Font.GothamMedium,
        TextSize   = 13,
        ZIndex     = 2,
    })

    local ValLabel = label(Holder, {
        Size           = UDim2.new(0.5, -20, 1, 0),
        Position       = UDim2.new(0.45, 0, 0, 0),
        Text           = getDisplay(),
        TextSize       = 12,
        TextColor3     = THEME.ACCENT,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex         = 2,
    })

    local Arrow = label(Holder, {
        Size           = UDim2.new(0, 16, 1, 0),
        Position       = UDim2.new(1, -16, 0, 0),
        Text           = "▾",
        TextSize       = 14,
        TextColor3     = THEME.TEXT_DIM,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex         = 2,
    })

    local List = frame(Holder, {
        Size             = UDim2.new(1, 0, 0, #options * 28),
        Position         = UDim2.new(0, 0, 1, 4),
        BackgroundColor3 = THEME.ELEVATED,
        Visible          = false,
        ZIndex           = 10,
        ClipsDescendants = true,
    })
    corner(List, 7)
    stroke(List, THEME.BORDER, 1)

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent    = List

    local optRows = {}
    for i, option in ipairs(options) do
        local isOn = table.find(selected, option) ~= nil

        local Row = frame(List, {
            Size             = UDim2.new(1, 0, 0, 28),
            BackgroundColor3 = THEME.ELEVATED,
            BackgroundTransparency = 1,
            LayoutOrder      = i,
            ZIndex           = 11,
        })

        local RowPad = Instance.new("UIPadding")
        RowPad.PaddingLeft  = UDim.new(0, 10)
        RowPad.PaddingRight = UDim.new(0, 10)
        RowPad.Parent       = Row

        label(Row, {
            Size       = UDim2.new(1, -24, 1, 0),
            Text       = tostring(option),
            TextSize   = 12,
            TextColor3 = isOn and THEME.ACCENT or THEME.TEXT_DIM,
            ZIndex     = 12,
        })

        local Check = frame(Row, {
            Size             = UDim2.new(0, 14, 0, 14),
            Position         = UDim2.new(1, -14, 0.5, -7),
            BackgroundColor3 = isOn and THEME.ACCENT or THEME.BORDER,
            ZIndex           = 12,
        })
        corner(Check, 3)

        local CheckMark = label(Check, {
            Size           = UDim2.new(1, 0, 1, 0),
            Text           = "✓",
            TextSize       = 10,
            TextColor3     = Color3.fromRGB(255, 255, 255),
            TextXAlignment = Enum.TextXAlignment.Center,
            BackgroundTransparency = 1,
            BackgroundColor3 = Color3.fromRGB(0,0,0),
            ZIndex         = 13,
        })
        CheckMark.Visible = isOn

        table.insert(optRows, { row = Row, check = Check, checkMark = CheckMark, label = Row:FindFirstChildWhichIsA("TextLabel"), option = option })

        local RowBtn = button(Row, {
            Size             = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text             = "",
            ZIndex           = 14,
        })

        RowBtn.MouseEnter:Connect(function() tween(Row, { BackgroundTransparency = 0.7 }, 0.1) end)
        RowBtn.MouseLeave:Connect(function() tween(Row, { BackgroundTransparency = 1 }, 0.1) end)
        RowBtn.MouseButton1Click:Connect(function()
            local idx = table.find(selected, option)
            if idx then
                table.remove(selected, idx)
                isOn = false
            else
                table.insert(selected, option)
                isOn = true
            end
            tween(Check, { BackgroundColor3 = isOn and THEME.ACCENT or THEME.BORDER }, 0.12)
            CheckMark.Visible = isOn
            ValLabel.Text = getDisplay()
            if config.Flag then self.Window:SaveFlag(config.Flag, selected) end
            if config.Callback then config.Callback(selected) end
        end)
    end

    local ClickArea = button(Holder, {
        Size             = UDim2.new(1, 0, 0, 34),
        BackgroundTransparency = 1,
        Text             = "",
        ZIndex           = 5,
    })

    ClickArea.MouseButton1Click:Connect(function()
        open = not open
        List.Visible = open
        tween(Arrow, { Rotation = open and 180 or 0 }, 0.15)
        Holder.Size = open and UDim2.new(1, 0, 0, 34 + (#options * 28) + 4) or UDim2.new(1, 0, 0, 34)
    end)

    return Holder
end

return SimpleGUI
