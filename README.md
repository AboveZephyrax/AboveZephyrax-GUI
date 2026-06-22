AboveZephyrax GUI

Simple Roblox GUI Library.

Loadstring

local SimpleGUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/AboveZephyrax/AboveZephyrax-GUI/main/GUI.lua"))()

Quick Example

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

API Reference

Create Window

local Window = SimpleGUI:CreateWindow({
    Name = "My Hub"
})

Create Tab

local Main = Window:CreateTab("Main")

Label

Main:CreateLabel("Text")

Button

Main:CreateButton({
    Name = "Button",
    Callback = function()
    end
})

Toggle

Main:CreateToggle({
    Name = "Toggle",
    CurrentValue = false,
    Callback = function(state)
    end
})

Slider

Main:CreateSlider({
    Name = "Slider",
    Range = {0, 100},
    CurrentValue = 50,
    Callback = function(value)
    end
})

Input

Main:CreateInput({
    Name = "Input",
    PlaceholderText = "Type here...",
    Callback = function(text, enterPressed)
    end
})

Dropdown

Main:CreateDropdown({
    Name = "Dropdown",
    Options = {"A", "B", "C"},
    CurrentOption = "A",
    Callback = function(selected)
    end
})

Color Picker

Visual:CreateColorPicker({
    Name = "Color",
    Color = Color3.fromRGB(255, 0, 0),
    Callback = function(color)
    end
})

Player Picker

Visual:CreatePlayerPicker({
    Name = "Player",
    Callback = function(player)
    end
})
