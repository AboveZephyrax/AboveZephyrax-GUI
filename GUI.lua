local SimpleGUI = {}
SimpleGUI.__index = SimpleGUI

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

function SimpleGUI:CreateWindow(config)
    config = config or {}

    local self = setmetatable({}, Window)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SimpleGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 999
    ScreenGui.IgnoreGuiInset = true

    local CoreGui = game:GetService("CoreGui")
    local mounted = pcall(function()
        ScreenGui.Parent = CoreGui
    end)
    if not mounted then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 260, 0, 360)
    Main.Position = UDim2.new(0.5, -130, 0.5, -180)
    Main.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Parent = ScreenGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Main

    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 32)
    TitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    TitleBar.BorderSizePixel = 0
    TitleBar.Active = true
    TitleBar.Parent = Main

    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
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
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = TitleBar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -70, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = config.Name or "Simple GUI"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 26, 0, 26)
    CloseBtn.Position = UDim2.new(1, -30, 0, 3)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 13
    CloseBtn.AutoButtonColor = false
    CloseBtn.Parent = TitleBar

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseBtn

    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 26, 0, 26)
    MinBtn.Position = UDim2.new(1, -60, 0, 3)
    MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 16
    MinBtn.AutoButtonColor = false
    MinBtn.Parent = TitleBar

    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(0, 6)
    MinCorner.Parent = MinBtn

    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    local Body = Instance.new("Frame")
    Body.Size = UDim2.new(1, 0, 1, -32)
    Body.Position = UDim2.new(0, 0, 0, 32)
    Body.BackgroundTransparency = 1
    Body.Parent = Main

    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Main.Size = UDim2.new(0, 260, 0, 32)
            Body.Visible = false
            MinBtn.Text = "+"
        else
            Main.Size = UDim2.new(0, 260, 0, 360)
            Body.Visible = true
            MinBtn.Text = "-"
        end
    end)

    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(1, -10, 0, 28)
    TabBar.Position = UDim2.new(0, 5, 0, 5)
    TabBar.BackgroundTransparency = 1
    TabBar.Parent = Body

    local TabBarLayout = Instance.new("UIListLayout")
    TabBarLayout.FillDirection = Enum.FillDirection.Horizontal
    TabBarLayout.Padding = UDim.new(0, 4)
    TabBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabBarLayout.Parent = TabBar

    self.ScreenGui = ScreenGui
    self.Main = Main
    self.Body = Body
    self.TabBar = TabBar
    self.Tabs = {}

    return self
end

function Window:CreateTab(name)
    local tab = setmetatable({}, Tab)

    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 74, 1, 0)
    TabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
    TabBtn.Font = Enum.Font.Gotham
    TabBtn.TextSize = 12
    TabBtn.AutoButtonColor = false
    TabBtn.LayoutOrder = #self.Tabs
    TabBtn.Parent = self.TabBar

    local TabBtnCorner = Instance.new("UICorner")
    TabBtnCorner.CornerRadius = UDim.new(0, 6)
    TabBtnCorner.Parent = TabBtn

    local Container = Instance.new("ScrollingFrame")
    Container.Size = UDim2.new(1, -10, 1, -38)
    Container.Position = UDim2.new(0, 5, 0, 38)
    Container.BackgroundTransparency = 1
    Container.BorderSizePixel = 0
    Container.ScrollBarThickness = 4
    Container.CanvasSize = UDim2.new(0, 0, 0, 0)
    Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Container.Visible = (#self.Tabs == 0)
    Container.Parent = self.Body

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 6)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Parent = Container

    tab.Container = Container
    tab.Button = TabBtn
    tab.Window = self

    table.insert(self.Tabs, tab)

    local function refreshTabColors()
        for _, t in ipairs(self.Tabs) do
            if t.Container.Visible then
                t.Button.BackgroundColor3 = Color3.fromRGB(75, 90, 130)
            else
                t.Button.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            end
        end
    end

    TabBtn.MouseButton1Click:Connect(function()
        for _, t in ipairs(self.Tabs) do
            t.Container.Visible = false
        end
        Container.Visible = true
        refreshTabColors()
    end)

    refreshTabColors()

    return tab
end

function Tab:CreateLabel(text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = self.Container
    return Label
end

function Tab:CreateButton(config)
    config = config or {}
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 32)
    Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    Btn.Text = config.Name or "Button"
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 13
    Btn.AutoButtonColor = false
    Btn.Parent = self.Container

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Btn

    Btn.MouseEnter:Connect(function()
        Btn.BackgroundColor3 = Color3.fromRGB(75, 75, 90)
    end)
    Btn.MouseLeave:Connect(function()
        Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    end)
    Btn.MouseButton1Click:Connect(function()
        if config.Callback then config.Callback() end
    end)

    return Btn
end

function Tab:CreateToggle(config)
    config = config or {}
    local state = config.CurrentValue or false

    local Holder = Instance.new("Frame")
    Holder.Size = UDim2.new(1, 0, 0, 32)
    Holder.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    Holder.Parent = self.Container

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Holder

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = config.Name or "Toggle"
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Holder

    local Switch = Instance.new("Frame")
    Switch.Size = UDim2.new(0, 36, 0, 18)
    Switch.Position = UDim2.new(1, -44, 0.5, -9)
    Switch.BackgroundColor3 = state and Color3.fromRGB(80, 170, 100) or Color3.fromRGB(90, 90, 100)
    Switch.Parent = Holder

    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = Switch

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 14, 0, 14)
    Knob.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.Parent = Switch

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob

    local ClickArea = Instance.new("TextButton")
    ClickArea.Size = UDim2.new(1, 0, 1, 0)
    ClickArea.BackgroundTransparency = 1
    ClickArea.Text = ""
    ClickArea.Parent = Holder

    ClickArea.MouseButton1Click:Connect(function()
        state = not state
        Switch.BackgroundColor3 = state and Color3.fromRGB(80, 170, 100) or Color3.fromRGB(90, 90, 100)
        Knob.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        if config.Callback then config.Callback(state) end
    end)

    return Holder
end

function Tab:CreateSlider(config)
    config = config or {}
    local range = config.Range or {0, 100}
    local min, max = range[1], range[2]
    local value = config.CurrentValue or min
    local dragging = false

    local Holder = Instance.new("Frame")
    Holder.Size = UDim2.new(1, 0, 0, 44)
    Holder.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    Holder.Parent = self.Container

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Holder

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 18)
    Label.Position = UDim2.new(0, 10, 0, 2)
    Label.BackgroundTransparency = 1
    Label.Text = (config.Name or "Slider") .. ": " .. tostring(value)
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Holder

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, -20, 0, 6)
    Track.Position = UDim2.new(0, 10, 0, 28)
    Track.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    Track.Parent = Holder

    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(1, 0)
    TrackCorner.Parent = Track

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(80, 140, 220)
    Fill.Parent = Track

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = Fill

    local function update(input)
        local rel = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        value = math.floor(min + (max - min) * rel)
        Fill.Size = UDim2.new(rel, 0, 1, 0)
        Label.Text = (config.Name or "Slider") .. ": " .. tostring(value)
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

    local Holder = Instance.new("Frame")
    Holder.Size = UDim2.new(1, 0, 0, 56)
    Holder.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    Holder.Parent = self.Container

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Holder

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 18)
    Label.Position = UDim2.new(0, 10, 0, 2)
    Label.BackgroundTransparency = 1
    Label.Text = config.Name or "Input"
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Holder

    local Input = Instance.new("TextBox")
    Input.Size = UDim2.new(1, -20, 0, 26)
    Input.Position = UDim2.new(0, 10, 0, 22)
    Input.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    Input.PlaceholderText = config.PlaceholderText or ""
    Input.Text = config.CurrentValue or ""
    Input.TextColor3 = Color3.fromRGB(255, 255, 255)
    Input.PlaceholderColor3 = Color3.fromRGB(140, 140, 150)
    Input.Font = Enum.Font.Gotham
    Input.TextSize = 13
    Input.ClearTextOnFocus = false
    Input.Parent = Holder

    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 5)
    InputCorner.Parent = Input

    Input.FocusLost:Connect(function(enterPressed)
        if config.Callback then config.Callback(Input.Text, enterPressed) end
    end)

    return Holder
end

function Tab:CreateDropdown(config)
    config = config or {}
    local options = config.Options or {}
    local selected = config.CurrentOption or options[1]
    local open = false

    local Holder = Instance.new("Frame")
    Holder.Size = UDim2.new(1, 0, 0, 32)
    Holder.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    Holder.ClipsDescendants = false
    Holder.Parent = self.Container
    Holder.ZIndex = 2

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Holder

    local Display = Instance.new("TextButton")
    Display.Size = UDim2.new(1, 0, 0, 32)
    Display.BackgroundTransparency = 1
    Display.Text = (config.Name or "Dropdown") .. ": " .. tostring(selected)
    Display.TextColor3 = Color3.fromRGB(255, 255, 255)
    Display.Font = Enum.Font.Gotham
    Display.TextSize = 13
    Display.ZIndex = 2
    Display.Parent = Holder

    local List = Instance.new("Frame")
    List.Size = UDim2.new(1, 0, 0, #options * 26)
    List.Position = UDim2.new(0, 0, 1, 2)
    List.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    List.Visible = false
    List.ZIndex = 5
    List.Parent = Holder

    local ListCorner = Instance.new("UICorner")
    ListCorner.CornerRadius = UDim.new(0, 6)
    ListCorner.Parent = List

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = List

    for _, option in ipairs(options) do
        local OptBtn = Instance.new("TextButton")
        OptBtn.Size = UDim2.new(1, 0, 0, 26)
        OptBtn.BackgroundTransparency = 1
        OptBtn.Text = tostring(option)
        OptBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
        OptBtn.Font = Enum.Font.Gotham
        OptBtn.TextSize = 12
        OptBtn.ZIndex = 6
        OptBtn.Parent = List

        OptBtn.MouseButton1Click:Connect(function()
            selected = option
            Display.Text = (config.Name or "Dropdown") .. ": " .. tostring(selected)
            List.Visible = false
            open = false
            Holder.Size = UDim2.new(1, 0, 0, 32)
            if config.Callback then config.Callback(selected) end
        end)
    end

    Display.MouseButton1Click:Connect(function()
        open = not open
        List.Visible = open
        if open then
            Holder.Size = UDim2.new(1, 0, 0, 32 + (#options * 26) + 2)
        else
            Holder.Size = UDim2.new(1, 0, 0, 32)
        end
    end)

    return Holder
end

function Tab:CreateColorPicker(config)
    config = config or {}
    local color = config.Color or Color3.fromRGB(255, 0, 0)
    local hue = select(1, color:ToHSV())

    local Holder = Instance.new("Frame")
    Holder.Size = UDim2.new(1, 0, 0, 32)
    Holder.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    Holder.ClipsDescendants = false
    Holder.Parent = self.Container
    Holder.ZIndex = 2

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Holder

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = config.Name or "Color"
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 2
    Label.Parent = Holder

    local Swatch = Instance.new("TextButton")
    Swatch.Size = UDim2.new(0, 26, 0, 20)
    Swatch.Position = UDim2.new(1, -34, 0.5, -10)
    Swatch.BackgroundColor3 = color
    Swatch.Text = ""
    Swatch.ZIndex = 2
    Swatch.Parent = Holder

    local SwatchCorner = Instance.new("UICorner")
    SwatchCorner.CornerRadius = UDim.new(0, 4)
    SwatchCorner.Parent = Swatch

    local Panel = Instance.new("Frame")
    Panel.Size = UDim2.new(1, 0, 0, 40)
    Panel.Position = UDim2.new(0, 0, 1, 2)
    Panel.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    Panel.Visible = false
    Panel.ZIndex = 5
    Panel.Parent = Holder

    local PanelCorner = Instance.new("UICorner")
    PanelCorner.CornerRadius = UDim.new(0, 6)
    PanelCorner.Parent = Panel

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, -20, 0, 14)
    Track.Position = UDim2.new(0, 10, 0.5, -7)
    Track.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Track.ZIndex = 6
    Track.Parent = Panel

    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(0, 7)
    TrackCorner.Parent = Track

    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    })
    Gradient.Parent = Track

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 6, 1, 6)
    Knob.AnchorPoint = Vector2.new(0.5, 0.5)
    Knob.Position = UDim2.new(hue, 0, 0.5, 0)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 1
    Knob.ZIndex = 7
    Knob.Parent = Track

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(0, 3)
    KnobCorner.Parent = Knob

    local dragging = false

    local function update(input)
        local rel = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        Knob.Position = UDim2.new(rel, 0, 0.5, 0)
        color = Color3.fromHSV(rel, 1, 1)
        Swatch.BackgroundColor3 = color
        if config.Callback then config.Callback(color) end
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

    Swatch.MouseButton1Click:Connect(function()
        Panel.Visible = not Panel.Visible
        if Panel.Visible then
            Holder.Size = UDim2.new(1, 0, 0, 32 + 40)
        else
            Holder.Size = UDim2.new(1, 0, 0, 32)
        end
    end)

    return Holder
end

function Tab:CreatePlayerPicker(config)
    config = config or {}

    local Holder = Instance.new("Frame")
    Holder.Size = UDim2.new(1, 0, 0, 56)
    Holder.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    Holder.ClipsDescendants = false
    Holder.Parent = self.Container
    Holder.ZIndex = 2

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Holder

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 18)
    Label.Position = UDim2.new(0, 10, 0, 2)
    Label.BackgroundTransparency = 1
    Label.Text = config.Name or "Player"
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 2
    Label.Parent = Holder

    local Input = Instance.new("TextBox")
    Input.Size = UDim2.new(1, -20, 0, 26)
    Input.Position = UDim2.new(0, 10, 0, 22)
    Input.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    Input.PlaceholderText = config.PlaceholderText or "ketik nama player..."
    Input.Text = ""
    Input.TextColor3 = Color3.fromRGB(255, 255, 255)
    Input.PlaceholderColor3 = Color3.fromRGB(140, 140, 150)
    Input.Font = Enum.Font.Gotham
    Input.TextSize = 13
    Input.ClearTextOnFocus = true
    Input.ZIndex = 2
    Input.Parent = Holder

    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 5)
    InputCorner.Parent = Input

    local List = Instance.new("Frame")
    List.Size = UDim2.new(1, 0, 0, 0)
    List.Position = UDim2.new(0, 0, 1, 0)
    List.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    List.Visible = false
    List.ZIndex = 5
    List.Parent = Holder

    local ListCorner = Instance.new("UICorner")
    ListCorner.CornerRadius = UDim.new(0, 6)
    ListCorner.Parent = List

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = List

    local function refresh(filter)
        for _, child in ipairs(List:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        filter = string.lower(filter or "")
        local matches = {}

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local lowerName = string.lower(plr.Name)
                if filter == "" or string.find(lowerName, filter, 1, true) then
                    table.insert(matches, plr)
                end
            end
        end

        for _, plr in ipairs(matches) do
            local OptBtn = Instance.new("TextButton")
            OptBtn.Size = UDim2.new(1, 0, 0, 24)
            OptBtn.BackgroundTransparency = 1
            OptBtn.Text = plr.Name
            OptBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
            OptBtn.Font = Enum.Font.Gotham
            OptBtn.TextSize = 12
            OptBtn.ZIndex = 6
            OptBtn.Parent = List

            OptBtn.MouseButton1Click:Connect(function()
                Input.Text = plr.Name
                List.Visible = false
                List.Size = UDim2.new(1, 0, 0, 0)
                Holder.Size = UDim2.new(1, 0, 0, 56)
                if config.Callback then config.Callback(plr) end
            end)
        end

        List.Size = UDim2.new(1, 0, 0, #matches * 24)
        List.Visible = #matches > 0
        Holder.Size = UDim2.new(1, 0, 0, 56 + (List.Visible and (#matches * 24) or 0))
    end

    Input:GetPropertyChangedSignal("Text"):Connect(function()
        refresh(Input.Text)
    end)

    Input.Focused:Connect(function()
        refresh("")
    end)

    Input.FocusLost:Connect(function()
        task.wait(0.15)
        List.Visible = false
        Holder.Size = UDim2.new(1, 0, 0, 56)
    end)

    return Holder
end

return SimpleGUI
