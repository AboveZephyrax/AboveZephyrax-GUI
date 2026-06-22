# AboveZephyrax GUI
> Simple Roblox GUI Library

---

## 📦 Loadstring

```lua
local SimpleGUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/AboveZephyrax/AboveZephyrax-GUI/main/GUI.lua"))()
```

---

## ⚡ Quick Example

```lua
local SimpleGUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/AboveZephyrax/AboveZephyrax-GUI/main/GUI.lua"))()

local Window = SimpleGUI:CreateWindow({
    Name = "Example Hub"
})

local Main = Window:CreateTab("Main")
local Visual = Window:CreateTab("Visual")

Main:CreateLabel("Hello World")

Main:CreateButton({
    Name = "Print Test",
    Callback = function()
        print("Clicked")
    end
})
```

---

## 📖 API Reference

### CreateWindow
```lua
local Window = SimpleGUI:CreateWindow({
    Name = "My Hub"
})
```

### CreateTab
```lua
local Main = Window:CreateTab("Main")
```

### CreateLabel
```lua
Main:CreateLabel("Text")
```

### CreateButton
```lua
Main:CreateButton({
    Name = "Button",
    Callback = function()
    end
})
```

### CreateToggle
```lua
Main:CreateToggle({
    Name = "Toggle",
    CurrentValue = false,
    Callback = function(state)
    end
})
```

### CreateSlider
```lua
Main:CreateSlider({
    Name = "Slider",
    Range = {0, 100},
    CurrentValue = 50,
    Callback = function(value)
    end
})
```

### CreateInput
```lua
Main:CreateInput({
    Name = "Input",
    PlaceholderText = "Type here...",
    Callback = function(text, enterPressed)
    end
})
```

### CreateDropdown
```lua
Main:CreateDropdown({
    Name = "Dropdown",
    Options = {"A", "B", "C"},
    CurrentOption = "A",
    Callback = function(selected)
    end
})
```

### CreateColorPicker
```lua
Visual:CreateColorPicker({
    Name = "Color",
    Color = Color3.fromRGB(255, 0, 0),
    Callback = function(color)
    end
})
```

### CreatePlayerPicker
```lua
Visual:CreatePlayerPicker({
    Name = "Player",
    Callback = function(player)
    end
})
```
