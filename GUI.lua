--[[
    SimpleGUI v3
    Clean, precise, Rayfield/Fluent-inspired
]]

local SimpleGUI = {}
SimpleGUI.__index = SimpleGUI

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

local Players         = game:GetService("Players")
local LocalPlayer     = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService    = game:GetService("TweenService")
local RunService      = game:GetService("RunService")

-- ───────────────────────────── THEME ─────────────────────────────
local T = {
    BG       = Color3.fromRGB(12, 12, 18),
    SURFACE  = Color3.fromRGB(20, 20, 30),
    SURFACE2 = Color3.fromRGB(28, 28, 40),
    SURFACE3 = Color3.fromRGB(36, 36, 50),
    BORDER   = Color3.fromRGB(45, 45, 65),
    ACCENT   = Color3.fromRGB(99, 102, 241),
    ACCENTLO = Color3.fromRGB(40, 42, 110),
    TEXT     = Color3.fromRGB(235, 235, 245),
    SUBTEXT  = Color3.fromRGB(130, 130, 160),
    MUTED    = Color3.fromRGB(70, 70, 95),
    SUCCESS  = Color3.fromRGB(52, 211, 153),
    WHITE    = Color3.fromRGB(255, 255, 255),
}

local FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local MED  = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

-- ───────────────────────────── HELPERS ───────────────────────────
local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
    return c
end

local function uistroke(p, col, thick, trans)
    local s = Instance.new("UIStroke")
    s.Color          = col   or T.BORDER
    s.Thickness      = thick or 1
    s.Transparency   = trans or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p
    return s
end

local function padding(p, top, bot, left, right)
    local u = Instance.new("UIPadding")
    u.PaddingTop    = UDim.new(0, top   or 0)
    u.PaddingBottom = UDim.new(0, bot   or 0)
    u.PaddingLeft   = UDim.new(0, left  or 0)
    u.PaddingRight  = UDim.new(0, right or 0)
    u.Parent = p
    return u
end

local function listLayout(p, gap, valign)
    local l = Instance.new("UIListLayout")
    l.Padding              = UDim.new(0, gap or 6)
    l.SortOrder            = Enum.SortOrder.LayoutOrder
    l.FillDirection        = Enum.FillDirection.Vertical
    if valign then l.VerticalAlignment = valign end
    l.Parent = p
    return l
end

local function newFrame(props)
    local f = Instance.new("Frame")
    for k, v in pairs(props) do f[k] = v end
    return f
end

local function newLabel(props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.Gotham
    l.TextSize = 13
    l.TextColor3 = T.TEXT
    l.TextXAlignment = Enum.TextXAlignment.Left
    for k, v in pairs(props) do l[k] = v end
    return l
end

local function tw(obj, props)
    TweenService:Create(obj, FAST, props):Play()
end

-- ───────────────────────────── ROW BASE ──────────────────────────
local function makeRow(parent, height)
    local f = newFrame({
        Size             = UDim2.new(1, 0, 0, height or 36),
        BackgroundColor3 = T.SURFACE2,
        BorderSizePixel  = 0,
        Parent           = parent,
    })
    corner(f, 8)
    uistroke(f, T.BORDER, 1)
    return f
end

-- ═════════════════════════════════════════════════════════════════
--  WINDOW
-- ═════════════════════════════════════════════════════════════════
local WIN_W, WIN_H = 560, 360
local BAR_H = 42

function SimpleGUI:CreateWindow(config)
    config = config or {}

    local self        = setmetatable({}, Window)
    self.Flags        = {}
    self.SavedConfig  = config.SavedConfig or {}
    self.Tabs         = {}

    -- ── ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name          = "SimpleGUI_v3"
    ScreenGui.ResetOnSpawn  = false
    ScreenGui.DisplayOrder  = 999
    ScreenGui.IgnoreGuiInset = true
    local ok = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
    if not ok then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    local keybind = config.Keybind or Enum.KeyCode.RightControl
    UserInputService.InputBegan:Connect(function(inp)
        if inp.KeyCode == keybind then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)

    -- ── Main frame
    local Main = newFrame({
        Size             = UDim2.fromOffset(WIN_W, WIN_H),
        Position         = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2),
        BackgroundColor3 = T.BG,
        Active           = true,
        Parent           = ScreenGui,
    })
    corner(Main, 10)
    uistroke(Main, T.BORDER, 1.5)

    -- shadow image (standard roblox shadow asset)
    local Shadow = Instance.new("ImageLabel")
    Shadow.Size              = UDim2.new(1, 60, 1, 60)
    Shadow.Position          = UDim2.new(0, -30, 0, -30)
    Shadow.BackgroundTransparency = 1
    Shadow.Image             = "rbxassetid://6014261993"
    Shadow.ImageColor3       = Color3.fromRGB(0,0,0)
    Shadow.ImageTransparency = 0.45
    Shadow.ScaleType         = Enum.ScaleType.Slice
    Shadow.SliceCenter       = Rect.new(49, 49, 450, 450)
    Shadow.ZIndex            = -1
    Shadow.Parent            = Main

    -- ── Title bar (exact BAR_H, sits at top, corners only on top via overlap)
    local TitleBar = newFrame({
        Size             = UDim2.new(1, 0, 0, BAR_H),
        Position         = UDim2.fromOffset(0, 0),
        BackgroundColor3 = T.SURFACE,
        ZIndex           = 3,
        Parent           = Main,
    })
    -- Only round top corners — overlap bottom with a rect patch
    corner(TitleBar, 10)
    local TBarPatch = newFrame({
        Size             = UDim2.new(1, 0, 0, 10),
        Position         = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = T.SURFACE,
        ZIndex           = 3,
        Parent           = TitleBar,
    })

    -- Accent underline — sits right at the bottom edge of TitleBar
    -- Width matches left panel width (140) + margins (8 left + 8 gap = start of content)
    local AccentLine = newFrame({
        Size             = UDim2.fromOffset(148, 2),
        Position         = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = T.ACCENT,
        ZIndex           = 4,
        Parent           = TitleBar,
    })

    -- Title dot
    local TitleDot = newFrame({
        Size             = UDim2.fromOffset(7, 7),
        Position         = UDim2.new(0, 14, 0.5, -3),
        BackgroundColor3 = T.ACCENT,
        ZIndex           = 4,
        Parent           = TitleBar,
    })
    corner(TitleDot, 4)

    -- Title text
    local TitleLabel = newLabel({
        Size             = UDim2.new(1, -120, 1, 0),
        Position         = UDim2.new(0, 28, 0, 0),
        Text             = config.Name or "SimpleGUI",
        TextColor3       = T.TEXT,
        Font             = Enum.Font.GothamBold,
        TextSize         = 14,
        ZIndex           = 4,
        Parent           = TitleBar,
    })

    -- SubTitle (static, no TextBounds dependency)
    if config.SubTitle and config.SubTitle ~= "" then
        local SubLabel = newLabel({
            Size             = UDim2.new(0, 160, 1, 0),
            Position         = UDim2.new(0, 150, 0, 0),
            Text             = config.SubTitle,
            TextColor3       = T.MUTED,
            Font             = Enum.Font.Gotham,
            TextSize         = 12,
            ZIndex           = 4,
            Parent           = TitleBar,
        })
    end

    -- ── Window buttons (close / minimize) — anchored to right edge
    local function winBtn(offsetX, symbol, hoverCol)
        local btn = Instance.new("TextButton")
        btn.Size             = UDim2.fromOffset(26, 26)
        btn.Position         = UDim2.new(1, offsetX, 0.5, -13)
        btn.BackgroundColor3 = T.SURFACE3
        btn.Text             = symbol
        btn.TextColor3       = T.SUBTEXT
        btn.Font             = Enum.Font.GothamBold
        btn.TextSize         = 11
        btn.AutoButtonColor  = false
        btn.ZIndex           = 5
        btn.Parent           = TitleBar
        corner(btn, 7)
        uistroke(btn, T.BORDER, 1)
        btn.MouseEnter:Connect(function()
            tw(btn, {BackgroundColor3 = hoverCol or T.ACCENTLO, TextColor3 = T.WHITE})
        end)
        btn.MouseLeave:Connect(function()
            tw(btn, {BackgroundColor3 = T.SURFACE3, TextColor3 = T.SUBTEXT})
        end)
        return btn
    end

    local CloseBtn = winBtn(-10, "✕", Color3.fromRGB(160, 40, 50))
    local MinBtn   = winBtn(-42, "−", T.ACCENTLO)

    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- ── Drag
    local dragging, dragStart, startPos, dragInput = false, nil, nil, nil
    TitleBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = inp.Position
            startPos  = Main.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragInput = inp
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp == dragInput then
            local d = inp.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)

    -- ── Body (below TitleBar)
    local Body = newFrame({
        Size             = UDim2.new(1, 0, 1, -BAR_H),
        Position         = UDim2.fromOffset(0, BAR_H),
        BackgroundTransparency = 1,
        Parent           = Main,
    })

    -- Minimize
    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            TweenService:Create(Main, MED, {Size = UDim2.fromOffset(WIN_W, BAR_H)}):Play()
            Body.Visible  = false
            MinBtn.Text   = "+"
        else
            Body.Visible  = true
            TweenService:Create(Main, MED, {Size = UDim2.fromOffset(WIN_W, WIN_H)}):Play()
            MinBtn.Text   = "−"
        end
    end)

    -- ── Sidebar
    -- Exact: left=8, top=8, width=140, height = WIN_H - BAR_H - 16
    local SIDEBAR_W = 140
    local INNER_H   = WIN_H - BAR_H - 16   -- 8 top + 8 bottom margin
    local CONTENT_X = 8 + SIDEBAR_W + 8    -- 156

    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Size                  = UDim2.fromOffset(SIDEBAR_W, INNER_H)
    Sidebar.Position              = UDim2.fromOffset(8, 8)
    Sidebar.BackgroundColor3      = T.SURFACE
    Sidebar.BorderSizePixel       = 0
    Sidebar.ScrollBarThickness    = 2
    Sidebar.ScrollBarImageColor3  = T.ACCENT
    Sidebar.CanvasSize            = UDim2.new(0,0,0,0)
    Sidebar.AutomaticCanvasSize   = Enum.AutomaticSize.Y
    Sidebar.Parent                = Body
    corner(Sidebar, 8)
    uistroke(Sidebar, T.BORDER, 1)
    padding(Sidebar, 6, 6, 6, 6)
    listLayout(Sidebar, 3)

    -- ── Content area
    local CONTENT_W = WIN_W - CONTENT_X - 8

    local ContentArea = Instance.new("ScrollingFrame")
    ContentArea.Size                 = UDim2.fromOffset(CONTENT_W, INNER_H)
    ContentArea.Position             = UDim2.fromOffset(CONTENT_X, 8)
    ContentArea.BackgroundTransparency = 1
    ContentArea.BorderSizePixel      = 0
    ContentArea.ScrollBarThickness   = 3
    ContentArea.ScrollBarImageColor3 = T.ACCENT
    ContentArea.CanvasSize           = UDim2.new(0,0,0,0)
    ContentArea.AutomaticCanvasSize  = Enum.AutomaticSize.Y
    ContentArea.Parent               = Body
    padding(ContentArea, 0, 8, 2, 2)
    listLayout(ContentArea, 6)

    self.ScreenGui   = ScreenGui
    self.Main        = Main
    self.Body        = Body
    self.Sidebar     = Sidebar
    self.ContentArea = ContentArea

    return self
end

function Window:SaveFlag(flag, value)
    self.Flags[flag] = value
end

-- ─────────────────────────── NOTIFY ──────────────────────────────
function Window:Notify(config)
    config = config or {}
    local title    = config.Title    or "Notifikasi"
    local content  = config.Content  or ""
    local duration = config.Duration or 3

    if not self.NotifHolder then
        local h = newFrame({
            Size                 = UDim2.fromOffset(280, 400),
            Position             = UDim2.new(1, -292, 1, -410),
            BackgroundTransparency = 1,
            Parent               = self.ScreenGui,
        })
        listLayout(h, 8, Enum.VerticalAlignment.Bottom)
        self.NotifHolder = h
    end

    local Box = newFrame({
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundColor3 = T.SURFACE2,
        BackgroundTransparency = 1,
        LayoutOrder      = os.clock(),
        Parent           = self.NotifHolder,
    })
    corner(Box, 10)
    local bs = uistroke(Box, T.ACCENT, 1.5, 1)

    -- accent left bar
    local Bar = newFrame({
        Size             = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = T.ACCENT,
        BackgroundTransparency = 1,
        ZIndex           = 2,
        Parent           = Box,
    })
    corner(Bar, 2)

    padding(Box, 12, 12, 14, 12)
    listLayout(Box, 4)

    local TL = newLabel({
        Size = UDim2.new(1, 0, 0, 16),
        Text = title, Font = Enum.Font.GothamBold, TextSize = 13,
        TextTransparency = 1, LayoutOrder = 0, Parent = Box,
    })
    local CL = Instance.new("TextLabel")
    CL.Size = UDim2.new(1, 0, 0, 0)
    CL.AutomaticSize = Enum.AutomaticSize.Y
    CL.BackgroundTransparency = 1
    CL.Text = content
    CL.TextColor3 = T.SUBTEXT
    CL.Font = Enum.Font.Gotham
    CL.TextSize = 12
    CL.TextXAlignment = Enum.TextXAlignment.Left
    CL.TextWrapped = true
    CL.TextTransparency = 1
    CL.LayoutOrder = 1
    CL.Parent = Box

    TweenService:Create(Box, MED, {BackgroundTransparency = 0}):Play()
    TweenService:Create(bs,  MED, {Transparency = 0}):Play()
    TweenService:Create(Bar, MED, {BackgroundTransparency = 0}):Play()
    TweenService:Create(TL,  MED, {TextTransparency = 0}):Play()
    TweenService:Create(CL,  MED, {TextTransparency = 0}):Play()

    task.delay(duration, function()
        TweenService:Create(Box, MED, {BackgroundTransparency = 1}):Play()
        TweenService:Create(bs,  MED, {Transparency = 1}):Play()
        TweenService:Create(Bar, MED, {BackgroundTransparency = 1}):Play()
        TweenService:Create(TL,  MED, {TextTransparency = 1}):Play()
        TweenService:Create(CL,  MED, {TextTransparency = 1}):Play()
        task.wait(0.3)
        Box:Destroy()
    end)
end

-- ═════════════════════════════════════════════════════════════════
--  TAB
-- ═════════════════════════════════════════════════════════════════
function Window:CreateTab(name, icon)
    local tab = setmetatable({}, Tab)

    -- Sidebar button
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size             = UDim2.new(1, 0, 0, 32)
    TabBtn.BackgroundColor3 = T.SURFACE
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text             = (icon and icon.." " or "") .. name
    TabBtn.TextColor3       = T.SUBTEXT
    TabBtn.Font             = Enum.Font.Gotham
    TabBtn.TextSize         = 12
    TabBtn.TextXAlignment   = Enum.TextXAlignment.Left
    TabBtn.AutoButtonColor  = false
    TabBtn.LayoutOrder      = #self.Tabs
    TabBtn.Parent           = self.Sidebar
    corner(TabBtn, 7)
    padding(TabBtn, 0, 0, 10, 0)

    -- Active pill on left edge
    local Pill = newFrame({
        Size             = UDim2.fromOffset(3, 16),
        Position         = UDim2.new(0, 0, 0.5, -8),
        BackgroundColor3 = T.ACCENT,
        BackgroundTransparency = 1,
        ZIndex           = 2,
        Parent           = TabBtn,
    })
    corner(Pill, 2)

    -- Content container for this tab
    local Container = newFrame({
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Visible          = (#self.Tabs == 0),
        LayoutOrder      = #self.Tabs,
        Parent           = self.ContentArea,
    })
    listLayout(Container, 6)

    -- Tab header inside content
    local Header = newLabel({
        Size      = UDim2.new(1, 0, 0, 26),
        Text      = name,
        Font      = Enum.Font.GothamBold,
        TextSize  = 16,
        TextColor3 = T.TEXT,
        LayoutOrder = 0,
        Parent    = Container,
    })

    local Divider = newFrame({
        Size             = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = T.BORDER,
        LayoutOrder      = 1,
        Parent           = Container,
    })

    -- Items holder (actual widgets go here)
    local Items = newFrame({
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder      = 2,
        Parent           = Container,
    })
    listLayout(Items, 6)

    tab.Container = Items
    tab.Section   = Container
    tab.Button    = TabBtn
    tab.Pill      = Pill
    tab.Window    = self
    table.insert(self.Tabs, tab)

    local function refreshTabs()
        for _, t in ipairs(self.Tabs) do
            local active = t.Section.Visible
            tw(t.Button, {
                TextColor3          = active and T.TEXT or T.SUBTEXT,
                BackgroundColor3    = active and T.SURFACE3 or T.SURFACE,
                BackgroundTransparency = active and 0 or 1,
            })
            tw(t.Pill, {BackgroundTransparency = active and 0 or 1})
        end
    end

    TabBtn.MouseEnter:Connect(function()
        if not Container.Visible then
            tw(TabBtn, {BackgroundTransparency = 0, BackgroundColor3 = T.SURFACE2})
        end
    end)
    TabBtn.MouseLeave:Connect(function()
        if not Container.Visible then
            tw(TabBtn, {BackgroundTransparency = 1})
        end
    end)
    TabBtn.MouseButton1Click:Connect(function()
        for _, t in ipairs(self.Tabs) do
            t.Section.Visible = false
        end
        Container.Visible = true
        refreshTabs()
    end)

    refreshTabs()
    return tab
end

-- ═════════════════════════════════════════════════════════════════
--  SECTION / SEPARATOR
-- ═════════════════════════════════════════════════════════════════
function Tab:CreateSection(name)
    local Wrapper = newFrame({
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent           = self.Container,
    })
    listLayout(Wrapper, 6)

    -- header row
    local HRow = newFrame({
        Size             = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        LayoutOrder      = 0,
        Parent           = Wrapper,
    })

    local Dot = newFrame({
        Size             = UDim2.fromOffset(3, 12),
        Position         = UDim2.new(0, 0, 0.5, -6),
        BackgroundColor3 = T.ACCENT,
        Parent           = HRow,
    })
    corner(Dot, 2)

    newLabel({
        Size       = UDim2.new(1, -10, 1, 0),
        Position   = UDim2.fromOffset(10, 0),
        Text       = string.upper(name),
        TextColor3 = T.MUTED,
        Font       = Enum.Font.GothamBold,
        TextSize   = 10,
        Parent     = HRow,
    })

    local Items = newFrame({
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder      = 1,
        Parent           = Wrapper,
    })
    listLayout(Items, 6)

    local saved = self.Container
    self.Container = Items

    return {
        End = function()
            self.Container = saved
        end
    }
end

function Tab:CreateSeparator()
    newFrame({
        Size             = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = T.BORDER,
        BorderSizePixel  = 0,
        Parent           = self.Container,
    })
end

-- ═════════════════════════════════════════════════════════════════
--  LABEL
-- ═════════════════════════════════════════════════════════════════
function Tab:CreateLabel(text)
    return newLabel({
        Size       = UDim2.new(1, 0, 0, 16),
        Text       = text,
        TextColor3 = T.SUBTEXT,
        TextSize   = 12,
        Parent     = self.Container,
    })
end

-- ═════════════════════════════════════════════════════════════════
--  BUTTON
-- ═════════════════════════════════════════════════════════════════
function Tab:CreateButton(config)
    config = config or {}
    local Row = makeRow(self.Container, 36)

    -- invisible clickable layer
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1,0,1,0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.AutoButtonColor = false
    Btn.ZIndex = 3
    Btn.Parent = Row

    newLabel({
        Size       = UDim2.new(1, -44, 1, 0),
        Position   = UDim2.fromOffset(12, 0),
        Text       = config.Name or "Button",
        Font       = Enum.Font.Gotham,
        TextSize   = 13,
        ZIndex     = 2,
        Parent     = Row,
    })

    local Arrow = newLabel({
        Size       = UDim2.fromOffset(24, 36),
        Position   = UDim2.new(1, -30, 0, 0),
        Text       = "›",
        TextColor3 = T.MUTED,
        Font       = Enum.Font.GothamBold,
        TextSize   = 18,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex     = 2,
        Parent     = Row,
    })

    Btn.MouseEnter:Connect(function()
        tw(Row,   {BackgroundColor3 = T.SURFACE3})
        tw(Arrow, {TextColor3 = T.ACCENT})
    end)
    Btn.MouseLeave:Connect(function()
        tw(Row,   {BackgroundColor3 = T.SURFACE2})
        tw(Arrow, {TextColor3 = T.MUTED})
    end)
    Btn.MouseButton1Down:Connect(function()
        tw(Row, {BackgroundColor3 = T.ACCENTLO})
    end)
    Btn.MouseButton1Up:Connect(function()
        tw(Row, {BackgroundColor3 = T.SURFACE3})
    end)
    Btn.MouseButton1Click:Connect(function()
        if config.Callback then config.Callback() end
    end)

    return Row
end

-- ═════════════════════════════════════════════════════════════════
--  TOGGLE
-- ═════════════════════════════════════════════════════════════════
function Tab:CreateToggle(config)
    config = config or {}
    local state = config.CurrentValue or false
    if config.Flag and self.Window.SavedConfig[config.Flag] ~= nil then
        state = self.Window.SavedConfig[config.Flag]
    end
    if config.Flag then self.Window.Flags[config.Flag] = state end

    local Row = makeRow(self.Container, 36)

    newLabel({
        Size     = UDim2.new(1, -60, 1, 0),
        Position = UDim2.fromOffset(12, 0),
        Text     = config.Name or "Toggle",
        Parent   = Row,
    })

    -- Track: 38x20, right-aligned with 10px margin
    local Track = newFrame({
        Size             = UDim2.fromOffset(38, 20),
        Position         = UDim2.new(1, -48, 0.5, -10),
        BackgroundColor3 = state and T.ACCENT or T.SURFACE3,
        Parent           = Row,
    })
    corner(Track, 10)
    uistroke(Track, T.BORDER, 1)

    -- Knob: 14x14
    -- OFF: X=3, ON: X=38-3-14=21
    local Knob = newFrame({
        Size             = UDim2.fromOffset(14, 14),
        Position         = state and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3),
        BackgroundColor3 = T.WHITE,
        Parent           = Track,
    })
    corner(Knob, 7)

    local Click = Instance.new("TextButton")
    Click.Size = UDim2.new(1,0,1,0)
    Click.BackgroundTransparency = 1
    Click.Text = ""
    Click.ZIndex = 3
    Click.Parent = Row

    Click.MouseButton1Click:Connect(function()
        state = not state
        tw(Track, {BackgroundColor3 = state and T.ACCENT or T.SURFACE3})
        TweenService:Create(Knob, FAST, {
            Position = state and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3)
        }):Play()
        if config.Flag then self.Window:SaveFlag(config.Flag, state) end
        if config.Callback then config.Callback(state) end
    end)

    return Row
end

-- ═════════════════════════════════════════════════════════════════
--  SLIDER
-- ═════════════════════════════════════════════════════════════════
function Tab:CreateSlider(config)
    config = config or {}
    local range = config.Range or {0, 100}
    local mn, mx = range[1], range[2]
    local value  = math.clamp(config.CurrentValue or mn, mn, mx)
    if config.Flag and self.Window.SavedConfig[config.Flag] ~= nil then
        value = self.Window.SavedConfig[config.Flag]
    end
    if config.Flag then self.Window.Flags[config.Flag] = value end

    local Row = makeRow(self.Container, 52)

    -- Name + value
    local NameLabel = newLabel({
        Size     = UDim2.new(0.65, -12, 0, 20),
        Position = UDim2.fromOffset(12, 8),
        Text     = config.Name or "Slider",
        TextSize = 12,
        Parent   = Row,
    })

    local ValLabel = newLabel({
        Size           = UDim2.new(0.35, -12, 0, 20),
        Position       = UDim2.new(0.65, 0, 0, 8),
        Text           = tostring(value),
        TextColor3     = T.ACCENT,
        Font           = Enum.Font.GothamBold,
        TextSize       = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent         = Row,
    })

    -- Track bar: full width minus 24px margins, at Y=34
    local TrackBg = newFrame({
        Size             = UDim2.new(1, -24, 0, 6),
        Position         = UDim2.fromOffset(12, 34),
        BackgroundColor3 = T.SURFACE3,
        Parent           = Row,
    })
    corner(TrackBg, 3)

    local ratio = (value - mn) / (mx - mn)

    local Fill = newFrame({
        Size             = UDim2.new(ratio, 0, 1, 0),
        BackgroundColor3 = T.ACCENT,
        Parent           = TrackBg,
    })
    corner(Fill, 3)

    -- Dot knob centered on track, absolute positioned
    -- Dot is 14x14, centered vertically on the 6px track → Y offset = -4
    local Dot = newFrame({
        Size             = UDim2.fromOffset(14, 14),
        AnchorPoint      = Vector2.new(0.5, 0.5),
        Position         = UDim2.new(ratio, 0, 0.5, 0),
        BackgroundColor3 = T.WHITE,
        ZIndex           = 2,
        Parent           = TrackBg,
    })
    corner(Dot, 7)
    uistroke(Dot, T.ACCENT, 2)

    -- Drag logic using mouse screen position vs TrackBg absolute
    local sliding = false

    local function updateFromMouse(mouseX)
        local abs = TrackBg.AbsolutePosition.X
        local sz  = TrackBg.AbsoluteSize.X
        if sz <= 0 then return end
        local rel = math.clamp((mouseX - abs) / sz, 0, 1)
        value = mn + math.floor((mx - mn) * rel + 0.5)
        -- clamp to integer steps
        local displayRel = (value - mn) / (mx - mn)
        Fill.Size = UDim2.new(displayRel, 0, 1, 0)
        Dot.Position = UDim2.new(displayRel, 0, 0.5, 0)
        ValLabel.Text = tostring(value)
        if config.Flag then self.Window:SaveFlag(config.Flag, value) end
        if config.Callback then config.Callback(value) end
    end

    -- Click on track itself
    TrackBg.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            updateFromMouse(inp.Position.X)
        end
    end)

    -- Also catch clicks on the Fill and Dot
    Fill.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            sliding = true
        end
    end)
    Dot.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            sliding = true
        end
    end)

    UserInputService.InputChanged:Connect(function(inp)
        if not sliding then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch then
            updateFromMouse(inp.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)

    return Row
end

-- ═════════════════════════════════════════════════════════════════
--  INPUT
-- ═════════════════════════════════════════════════════════════════
function Tab:CreateInput(config)
    config = config or {}
    local cv = config.CurrentValue or ""
    if config.Flag and self.Window.SavedConfig[config.Flag] ~= nil then
        cv = self.Window.SavedConfig[config.Flag]
    end
    if config.Flag then self.Window.Flags[config.Flag] = cv end

    local Row = makeRow(self.Container, 58)

    newLabel({
        Size     = UDim2.new(1, -24, 0, 16),
        Position = UDim2.fromOffset(12, 7),
        Text     = config.Name or "Input",
        TextColor3 = T.SUBTEXT,
        TextSize = 12,
        Parent   = Row,
    })

    local InBg = newFrame({
        Size             = UDim2.new(1, -24, 0, 26),
        Position         = UDim2.fromOffset(12, 25),
        BackgroundColor3 = T.BG,
        Parent           = Row,
    })
    corner(InBg, 6)
    local istroke = uistroke(InBg, T.BORDER, 1)

    local Input = Instance.new("TextBox")
    Input.Size              = UDim2.new(1, -16, 1, 0)
    Input.Position          = UDim2.fromOffset(8, 0)
    Input.BackgroundTransparency = 1
    Input.PlaceholderText   = config.PlaceholderText or ""
    Input.Text              = cv
    Input.TextColor3        = T.TEXT
    Input.PlaceholderColor3 = T.MUTED
    Input.Font              = Enum.Font.Gotham
    Input.TextSize          = 12
    Input.TextXAlignment    = Enum.TextXAlignment.Left
    Input.ClearTextOnFocus  = false
    Input.Parent            = InBg

    Input.Focused:Connect(function()
        tw(istroke, {Color = T.ACCENT})
    end)
    Input.FocusLost:Connect(function(enter)
        tw(istroke, {Color = T.BORDER})
        if config.Flag then self.Window:SaveFlag(config.Flag, Input.Text) end
        if config.Callback then config.Callback(Input.Text, enter) end
    end)

    return Row
end

-- ═════════════════════════════════════════════════════════════════
--  DROPDOWN
-- ═════════════════════════════════════════════════════════════════
function Tab:CreateDropdown(config)
    config = config or {}
    local options  = config.Options or {}
    local selected = config.CurrentOption or options[1]
    if config.Flag and self.Window.SavedConfig[config.Flag] ~= nil then
        selected = self.Window.SavedConfig[config.Flag]
    end
    if config.Flag then self.Window.Flags[config.Flag] = selected end

    local ITEM_H   = 28
    local CLOSED_H = 36
    local open = false

    local Wrapper = newFrame({
        Size             = UDim2.new(1, 0, 0, CLOSED_H),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        ZIndex           = 10,
        Parent           = self.Container,
    })

    local Row = makeRow(Wrapper, CLOSED_H)
    Row.ZIndex = 10
    Row.ClipsDescendants = false

    -- Label (left)
    newLabel({
        Size       = UDim2.new(0.5, -12, 1, 0),
        Position   = UDim2.fromOffset(12, 0),
        Text       = config.Name or "Dropdown",
        TextColor3 = T.SUBTEXT,
        TextSize   = 12,
        ZIndex     = 11,
        Parent     = Row,
    })

    -- Selected value (right of center)
    local SelLabel = newLabel({
        Size           = UDim2.new(0.5, -32, 1, 0),
        Position       = UDim2.new(0.5, 0, 0, 0),
        Text           = tostring(selected or "Select..."),
        TextColor3     = T.TEXT,
        Font           = Enum.Font.GothamBold,
        TextSize       = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex         = 11,
        Parent         = Row,
    })

    -- Chevron
    local Chev = newLabel({
        Size           = UDim2.fromOffset(24, 36),
        Position       = UDim2.new(1, -28, 0, 0),
        Text           = "▾",
        TextColor3     = T.MUTED,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextSize       = 13,
        ZIndex         = 11,
        Parent         = Row,
    })

    -- Dropdown list panel
    local LIST_H = #options * ITEM_H + 8
    local List = newFrame({
        Size             = UDim2.new(1, 0, 0, LIST_H),
        Position         = UDim2.new(0, 0, 1, 4),
        BackgroundColor3 = T.SURFACE3,
        Visible          = false,
        ZIndex           = 20,
        Parent           = Row,
    })
    corner(List, 8)
    uistroke(List, T.BORDER, 1)
    padding(List, 4, 4, 0, 0)
    listLayout(List, 0)

    for i, opt in ipairs(options) do
        local OBtn = Instance.new("TextButton")
        OBtn.Size             = UDim2.new(1, 0, 0, ITEM_H)
        OBtn.BackgroundColor3 = T.SURFACE3
        OBtn.BackgroundTransparency = 1
        OBtn.Text             = tostring(opt)
        OBtn.TextColor3       = T.SUBTEXT
        OBtn.Font             = Enum.Font.Gotham
        OBtn.TextSize         = 12
        OBtn.TextXAlignment   = Enum.TextXAlignment.Left
        OBtn.AutoButtonColor  = false
        OBtn.ZIndex           = 21
        OBtn.LayoutOrder      = i
        OBtn.Parent           = List
        padding(OBtn, 0, 0, 12, 0)

        OBtn.MouseEnter:Connect(function()
            tw(OBtn, {BackgroundTransparency = 0, BackgroundColor3 = T.SURFACE2, TextColor3 = T.TEXT})
        end)
        OBtn.MouseLeave:Connect(function()
            tw(OBtn, {BackgroundTransparency = 1, TextColor3 = T.SUBTEXT})
        end)
        OBtn.MouseButton1Click:Connect(function()
            selected = opt
            SelLabel.Text = tostring(selected)
            open = false
            List.Visible = false
            Wrapper.Size = UDim2.new(1, 0, 0, CLOSED_H)
            Row.Size     = UDim2.fromOffset(0, CLOSED_H)
            Row.Size     = UDim2.new(1, 0, 0, CLOSED_H)
            TweenService:Create(Chev, FAST, {Rotation = 0}):Play()
            if config.Flag then self.Window:SaveFlag(config.Flag, selected) end
            if config.Callback then config.Callback(selected) end
        end)
    end

    -- Toggle button (covers Row header)
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(1, 0, 0, CLOSED_H)
    ToggleBtn.BackgroundTransparency = 1
    ToggleBtn.Text = ""
    ToggleBtn.ZIndex = 12
    ToggleBtn.Parent = Row

    ToggleBtn.MouseButton1Click:Connect(function()
        open = not open
        List.Visible = open
        local totalH = CLOSED_H + (open and (LIST_H + 4) or 0)
        Wrapper.Size = UDim2.new(1, 0, 0, totalH)
        Row.Size     = UDim2.new(1, 0, 0, CLOSED_H)
        TweenService:Create(Chev, FAST, {Rotation = open and 180 or 0}):Play()
    end)

    return Wrapper
end

-- ═════════════════════════════════════════════════════════════════
--  COLOR PICKER
-- ═════════════════════════════════════════════════════════════════
function Tab:CreateColorPicker(config)
    config = config or {}
    local color = config.Color or Color3.fromRGB(99, 102, 241)
    if config.Flag and self.Window.SavedConfig[config.Flag] ~= nil then
        local c = self.Window.SavedConfig[config.Flag]
        color = Color3.new(c.R, c.G, c.B)
    end
    if config.Flag then self.Window.Flags[config.Flag] = {R = color.R, G = color.G, B = color.B} end
    local hue = select(1, color:ToHSV())

    local CLOSED_H  = 36
    local PANEL_H   = 46
    local open = false

    local Wrapper = newFrame({
        Size             = UDim2.new(1, 0, 0, CLOSED_H),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        ZIndex           = 8,
        Parent           = self.Container,
    })

    local Row = makeRow(Wrapper, CLOSED_H)
    Row.ZIndex = 8
    Row.ClipsDescendants = false

    newLabel({
        Size     = UDim2.new(1, -54, 1, 0),
        Position = UDim2.fromOffset(12, 0),
        Text     = config.Name or "Color",
        ZIndex   = 9,
        Parent   = Row,
    })

    local Swatch = Instance.new("TextButton")
    Swatch.Size             = UDim2.fromOffset(28, 20)
    Swatch.Position         = UDim2.new(1, -38, 0.5, -10)
    Swatch.BackgroundColor3 = color
    Swatch.Text             = ""
    Swatch.AutoButtonColor  = false
    Swatch.ZIndex           = 9
    Swatch.Parent           = Row
    corner(Swatch, 5)
    uistroke(Swatch, T.BORDER, 1.5)

    -- Panel
    local Panel = newFrame({
        Size             = UDim2.new(1, 0, 0, PANEL_H),
        Position         = UDim2.new(0, 0, 1, 4),
        BackgroundColor3 = T.SURFACE3,
        Visible          = false,
        ZIndex           = 15,
        Parent           = Row,
    })
    corner(Panel, 8)
    uistroke(Panel, T.BORDER, 1)

    -- Hue track
    local Track = newFrame({
        Size             = UDim2.new(1, -24, 0, 16),
        Position         = UDim2.new(0, 12, 0.5, -8),
        BackgroundColor3 = T.WHITE,
        ZIndex           = 16,
        Parent           = Panel,
    })
    corner(Track, 8)

    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,    Color3.fromRGB(255,0,0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,255,0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0,255,255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,0,255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
        ColorSequenceKeypoint.new(1,    Color3.fromRGB(255,0,0)),
    })
    Gradient.Parent = Track

    -- Hue knob
    local HKnob = newFrame({
        Size             = UDim2.fromOffset(8, 22),
        AnchorPoint      = Vector2.new(0.5, 0.5),
        Position         = UDim2.new(hue, 0, 0.5, 0),
        BackgroundColor3 = T.WHITE,
        ZIndex           = 17,
        Parent           = Track,
    })
    corner(HKnob, 4)
    uistroke(HKnob, Color3.fromRGB(0,0,0), 1, 0.5)

    local sliding = false

    local function updateHue(mouseX)
        local abs = Track.AbsolutePosition.X
        local sz  = Track.AbsoluteSize.X
        if sz <= 0 then return end
        local rel = math.clamp((mouseX - abs) / sz, 0, 1)
        HKnob.Position = UDim2.new(rel, 0, 0.5, 0)
        color = Color3.fromHSV(rel, 1, 1)
        Swatch.BackgroundColor3 = color
        if config.Flag then self.Window:SaveFlag(config.Flag, {R = color.R, G = color.G, B = color.B}) end
        if config.Callback then config.Callback(color) end
    end

    Track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            updateHue(inp.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if not sliding then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch then
            updateHue(inp.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)

    Swatch.MouseButton1Click:Connect(function()
        open = not open
        Panel.Visible = open
        local totalH = CLOSED_H + (open and (PANEL_H + 4) or 0)
        Wrapper.Size = UDim2.new(1, 0, 0, totalH)
        Row.Size     = UDim2.new(1, 0, 0, CLOSED_H)
    end)

    return Wrapper
end

-- ═════════════════════════════════════════════════════════════════
--  PLAYER PICKER
-- ═════════════════════════════════════════════════════════════════
function Tab:CreatePlayerPicker(config)
    config = config or {}

    local ITEM_H   = 28
    local CLOSED_H = 58

    local Wrapper = newFrame({
        Size             = UDim2.new(1, 0, 0, CLOSED_H),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        ZIndex           = 9,
        Parent           = self.Container,
    })

    local Row = makeRow(Wrapper, CLOSED_H)
    Row.ZIndex = 9
    Row.ClipsDescendants = false

    newLabel({
        Size       = UDim2.new(1, -24, 0, 16),
        Position   = UDim2.fromOffset(12, 7),
        Text       = config.Name or "Player",
        TextColor3 = T.SUBTEXT,
        TextSize   = 12,
        ZIndex     = 10,
        Parent     = Row,
    })

    local InBg = newFrame({
        Size             = UDim2.new(1, -24, 0, 26),
        Position         = UDim2.fromOffset(12, 25),
        BackgroundColor3 = T.BG,
        ZIndex           = 10,
        Parent           = Row,
    })
    corner(InBg, 6)
    local ps = uistroke(InBg, T.BORDER, 1)

    local Input = Instance.new("TextBox")
    Input.Size              = UDim2.new(1, -16, 1, 0)
    Input.Position          = UDim2.fromOffset(8, 0)
    Input.BackgroundTransparency = 1
    Input.PlaceholderText   = config.PlaceholderText or "ketik nama player..."
    Input.Text              = ""
    Input.TextColor3        = T.TEXT
    Input.PlaceholderColor3 = T.MUTED
    Input.Font              = Enum.Font.Gotham
    Input.TextSize          = 12
    Input.TextXAlignment    = Enum.TextXAlignment.Left
    Input.ClearTextOnFocus  = true
    Input.ZIndex            = 11
    Input.Parent            = InBg

    Input.Focused:Connect(function()  tw(ps, {Color = T.ACCENT}) end)
    Input.FocusLost:Connect(function() tw(ps, {Color = T.BORDER}) end)

    -- Results list
    local List = newFrame({
        Size             = UDim2.new(1, 0, 0, 0),
        Position         = UDim2.new(0, 0, 1, 4),
        BackgroundColor3 = T.SURFACE3,
        Visible          = false,
        ZIndex           = 18,
        Parent           = Row,
    })
    corner(List, 8)
    uistroke(List, T.BORDER, 1)
    padding(List, 4, 4, 0, 0)
    listLayout(List, 0)

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
        for i, plr in ipairs(matches) do
            local OBtn = Instance.new("TextButton")
            OBtn.Size             = UDim2.new(1, 0, 0, ITEM_H)
            OBtn.BackgroundColor3 = T.SURFACE3
            OBtn.BackgroundTransparency = 1
            OBtn.Text             = plr.Name
            OBtn.TextColor3       = T.SUBTEXT
            OBtn.Font             = Enum.Font.Gotham
            OBtn.TextSize         = 12
            OBtn.TextXAlignment   = Enum.TextXAlignment.Left
            OBtn.AutoButtonColor  = false
            OBtn.ZIndex           = 19
            OBtn.LayoutOrder      = i
            OBtn.Parent           = List
            padding(OBtn, 0, 0, 12, 0)

            OBtn.MouseEnter:Connect(function()
                tw(OBtn, {BackgroundTransparency = 0, BackgroundColor3 = T.SURFACE2, TextColor3 = T.TEXT})
            end)
            OBtn.MouseLeave:Connect(function()
                tw(OBtn, {BackgroundTransparency = 1, TextColor3 = T.SUBTEXT})
            end)
            OBtn.MouseButton1Click:Connect(function()
                Input.Text = plr.Name
                List.Visible = false
                Wrapper.Size = UDim2.new(1, 0, 0, CLOSED_H)
                if config.Callback then config.Callback(plr) end
            end)
        end

        local listH = #matches * ITEM_H + 8
        List.Size    = UDim2.new(1, 0, 0, listH)
        List.Visible = #matches > 0
        Wrapper.Size = UDim2.new(1, 0, 0, CLOSED_H + (List.Visible and (listH + 4) or 0))
    end

    Input:GetPropertyChangedSignal("Text"):Connect(function() refresh(Input.Text) end)
    Input.Focused:Connect(function() refresh("") end)
    Input.FocusLost:Connect(function()
        task.wait(0.15)
        List.Visible = false
        Wrapper.Size = UDim2.new(1, 0, 0, CLOSED_H)
    end)

    return Wrapper
end

return SimpleGUI
