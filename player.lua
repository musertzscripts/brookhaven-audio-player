-- Ray Field Boombox Library
-- By: [Your Name]
-- Version: 1.2

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Configuration
local DEFAULT_SOUND_ID = "rbxassetid://142376088" -- Default sound (change to your preferred default)
local MAX_DISTANCE = 100 -- Max distance for sound to be heard
local DEFAULT_VOLUME = 0.5
local DEFAULT_PITCH = 1
local DEFAULT_LOOP = true
local DEFAULT_AUTO_PLAY = true

-- Create the window
local Window = Rayfield:CreateWindow({
    Name = "Advanced Boombox Controller",
    LoadingTitle = "Ray Field Audio Suite",
    LoadingSubtitle = "by [Your Name]",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "RayFieldBoombox",
        FileName = "Configuration"
    },
    Discord = {
        Enabled = true,
        Invite = "YOUR_DISCORD_INVITE_CODE", -- Replace with your Discord invite code
        RememberJoins = true
    },
    KeySystem = false -- Set to true if you want a key system
})

-- Main tab
local MainTab = Window:CreateTab("Main Controls", 4483362458) -- Boombox icon

-- Sound controls section
local SoundSection = MainTab:CreateSection("Sound Controls")

local SoundIdInput = MainTab:CreateInput({
    Name = "Sound ID",
    PlaceholderText = "rbxassetid://...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        -- Validation happens on play
    end,
})

local VolumeSlider = MainTab:CreateSlider({
    Name = "Volume",
    Range = {0, 1},
    Increment = 0.1,
    Suffix = "x",
    Default = DEFAULT_VOLUME,
    Flag = "VolumeValue",
    Callback = function(Value)
        if CurrentSound then
            CurrentSound.Volume = Value
        end
    end
})

local PitchSlider = MainTab:CreateSlider({
    Name = "Pitch",
    Range = {0.5, 2},
    Increment = 0.1,
    Suffix = "x",
    Default = DEFAULT_PITCH,
    Flag = "PitchValue",
    Callback = function(Value)
        if CurrentSound then
            CurrentSound.PlaybackSpeed = Value
        end
    end
})

local PlayerDropdown = MainTab:CreateDropdown({
    Name = "Player's Boombox",
    Options = {},
    CurrentOption = LocalPlayer.Name,
    Flag = "PlayerSelection",
    Callback = function(Option)
        SelectedPlayer = Players:FindFirstChild(Option)
    end
})

-- Update player list
local function UpdatePlayerList()
    local options = {}
    for _, player in ipairs(Players:GetPlayers()) do
        table.insert(options, player.Name)
    end
    PlayerDropdown:UpdateOptions(options)
end

Players.PlayerAdded:Connect(UpdatePlayerList)
Players.PlayerRemoved:Connect(UpdatePlayerList)
UpdatePlayerList()

-- Advanced features section
local AdvancedSection = MainTab:CreateSection("Advanced Features")

local DistortionToggle = MainTab:CreateToggle({
    Name = "Pitch Distortion",
    CurrentValue = false,
    Flag = "DistortionEnabled",
    Callback = function(Value)
        if Value then
            StartDistortion()
        else
            StopDistortion()
        end
    end
})

local DistortionIntensity = MainTab:CreateSlider({
    Name = "Distortion Intensity",
    Range = {0.1, 2},
    Increment = 0.1,
    Suffix = "x",
    Default = 0.5,
    Flag = "DistortionIntensity",
    Callback = function(Value)
        DistortionAmount = Value
    end
})

local TPOSEnabled = MainTab:CreateToggle({
    Name = "TPOS (Time Position Offset)",
    CurrentValue = false,
    Flag = "TPOSEnabled",
    Callback = function(Value)
        if Value then
            StartTPOS()
        else
            StopTPOS()
        end
    end
})

local TPOSOffset = MainTab:CreateSlider({
    Name = "TPOS Offset (seconds)",
    Range = {-5, 5},
    Increment = 0.1,
    Suffix = "s",
    Default = 0,
    Flag = "TPOSOffset",
    Callback = function(Value)
        TPOSValue = Value
    end
})

local LoopToggle = MainTab:CreateToggle({
    Name = "Loop Sound",
    CurrentValue = DEFAULT_LOOP,
    Flag = "LoopEnabled",
    Callback = function(Value)
        if CurrentSound then
            CurrentSound.Looped = Value
        end
    end
})

local AutoPlayToggle = MainTab:CreateToggle({
    Name = "Auto Play on Load",
    CurrentValue = DEFAULT_AUTO_PLAY,
    Flag = "AutoPlayEnabled",
    Callback = function(Value)
        -- Handled when sound is loaded
    end
})

-- Effects section
local EffectsSection = MainTab:CreateSection("Sound Effects")

local ReverbToggle = MainTab:CreateToggle({
    Name = "Reverb Effect",
    CurrentValue = false,
    Flag = "ReverbEnabled",
    Callback = function(Value)
        if CurrentSound then
            if Value then
                CurrentSound:SetAttribute("Reverb", true)
                ApplyReverb()
            else
                CurrentSound:SetAttribute("Reverb", false)
                RemoveReverb()
            end
        end
    end
})

local EchoToggle = MainTab:CreateToggle({
    Name = "Echo Effect",
    CurrentValue = false,
    Flag = "EchoEnabled",
    Callback = function(Value)
        if CurrentSound then
            if Value then
                CurrentSound:SetAttribute("Echo", true)
                ApplyEcho()
            else
                CurrentSound:SetAttribute("Echo", false)
                RemoveEcho()
            end
        end
    end
})

-- Player controls
local PlayButton = MainTab:CreateButton({
    Name = "Play Sound",
    Callback = function()
        PlaySound()
    end
})

local StopButton = MainTab:CreateButton({
    Name = "Stop Sound",
    Callback = function()
        StopSound()
    end
})

local EquipButton = MainTab:CreateButton({
    Name = "Equip Boombox",
    Callback = function()
        EquipBoombox()
    end
})

-- Variables
local CurrentSound = nil
local CurrentBoombox = nil
local DistortionAmount = 0.5
local TPOSValue = 0
local DistortionConnection = nil
local TPOSConnection = nil

-- Functions
function FindBoombox(player)
    if not player then return nil end
    
    -- Check backpack first
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") and (item.Name:lower():find("boom") or item.Name:lower():find("radio")) then
                return item
            end
        end
    end
    
    -- Check character
    local character = player.Character
    if character then
        for _, item in ipairs(character:GetChildren()) do
            if item:IsA("Tool") and (item.Name:lower():find("boom") or item.Name:lower():find("radio")) then
                return item
            end
        end
    end
    
    return nil
end

function EquipBoombox()
    local player = SelectedPlayer or LocalPlayer
    local boombox = FindBoombox(player)
    
    if boombox then
        if player == LocalPlayer then
            LocalPlayer.Character.Humanoid:EquipTool(boombox)
        end
        CurrentBoombox = boombox
        RayField:Notify({
            Title = "Boombox Equipped",
            Content = "Successfully equipped " .. player.Name .. "'s boombox",
            Duration = 3,
            Image = 4483362458
        })
    else
        RayField:Notify({
            Title = "Error",
            Content = "No boombox found in " .. player.Name .. "'s inventory",
            Duration = 3,
            Image = 4483362458
        })
    end
end

function PlaySound()
    local soundId = SoundIdInput.Value
    if soundId == "" then soundId = DEFAULT_SOUND_ID end
    
    -- Validate sound ID
    if not soundId:match("^rbxassetid://%d+$") and not soundId:match("^%d+$") then
        RayField:Notify({
            Title = "Invalid Sound ID",
            Content = "Please enter a valid sound ID (e.g., 142376088 or rbxassetid://142376088)",
            Duration = 3,
            Image = 4483362458
        })
        return
    end
    
    -- Format sound ID if needed
    if soundId:match("^%d+$") then
        soundId = "rbxassetid://" .. soundId
    end
    
    -- Stop current sound if playing
    if CurrentSound then
        CurrentSound:Stop()
        CurrentSound:Destroy()
        CurrentSound = nil
    end
    
    -- Create new sound
    CurrentSound = Instance.new("Sound")
    CurrentSound.SoundId = soundId
    CurrentSound.Volume = VolumeSlider.Value
    CurrentSound.PlaybackSpeed = PitchSlider.Value
    CurrentSound.Looped = LoopToggle.Value
    CurrentSound.RollOffMode = Enum.RollOffMode.InverseTapered
    CurrentSound.RollOffMinDistance = 5
    CurrentSound.RollOffMaxDistance = MAX_DISTANCE
    
    -- Parent sound
    if CurrentBoombox then
        CurrentSound.Parent = CurrentBoombox.Handle or CurrentBoombox
    else
        CurrentSound.Parent = LocalPlayer.Character:FindFirstChild("Head") or LocalPlayer.Character
    end
    
    -- Load sound
    CurrentSound.Loaded:Connect(function()
        if AutoPlayToggle.Value then
            CurrentSound:Play()
            
            -- Apply effects if they're enabled
            if ReverbToggle.Value then ApplyReverb() end
            if EchoToggle.Value then ApplyEcho() end
            if DistortionToggle.Value then StartDistortion() end
            if TPOSEnabled.Value then StartTPOS() end
            
            RayField:Notify({
                Title = "Sound Playing",
                Content = "Now playing sound ID: " .. soundId,
                Duration = 3,
                Image = 4483362458
            })
        end
    end)
    
    CurrentSound:Load()
end

function StopSound()
    if CurrentSound then
        CurrentSound:Stop()
        CurrentSound:Destroy()
        CurrentSound = nil
        
        -- Clean up effects
        if DistortionConnection then
            DistortionConnection:Disconnect()
            DistortionConnection = nil
        end
        
        if TPOSConnection then
            TPOSConnection:Disconnect()
            TPOSConnection = nil
        end
    end
end

function StartDistortion()
    if not CurrentSound then return end
    
    if DistortionConnection then
        DistortionConnection:Disconnect()
    end
    
    local basePitch = PitchSlider.Value
    local time = 0
    
    DistortionConnection = RunService.Heartbeat:Connect(function(delta)
        time = time + delta
        CurrentSound.PlaybackSpeed = basePitch + (math.sin(time * 5) * DistortionAmount * 0.1)
    end)
end

function StopDistortion()
    if DistortionConnection then
        DistortionConnection:Disconnect()
        DistortionConnection = nil
    end
    
    if CurrentSound then
        CurrentSound.PlaybackSpeed = PitchSlider.Value
    end
end

function StartTPOS()
    if not CurrentSound then return end
    
    if TPOSConnection then
        TPOSConnection:Disconnect()
    end
    
    TPOSConnection = RunService.Heartbeat:Connect(function()
        if CurrentSound.IsPlaying then
            CurrentSound.TimePosition = CurrentSound.TimePosition + (TPOSValue * 0.01)
        end
    end)
end

function StopTPOS()
    if TPOSConnection then
        TPOSConnection:Disconnect()
        TPOSConnection = nil
    end
end

function ApplyReverb()
    if not CurrentSound then return end
    
    -- Create reverb effect
    local reverb = Instance.new("ReverbSoundEffect")
    reverb.Enabled = true
    reverb.DecayTime = 3
    reverb.Density = 0.8
    reverb.DryLevel = 1
    reverb.WetLevel = 0.5
    reverb.Parent = CurrentSound
end

function RemoveReverb()
    if not CurrentSound then return end
    
    for _, effect in ipairs(CurrentSound:GetChildren()) do
        if effect:IsA("ReverbSoundEffect") then
            effect:Destroy()
        end
    end
end

function ApplyEcho()
    if not CurrentSound then return end
    
    -- Create echo effect
    local echo = Instance.new("EchoSoundEffect")
    echo.Enabled = true
    echo.Delay = 0.5
    echo.Feedback = 0.5
    echo.WetLevel = 0.5
    echo.Parent = CurrentSoundvbfhuoejrbcijrtbcijebcf
end

function RemoveEcho()
    if not CurrentSound then return end
    
    for _, effect in ipairs(CurrentShr4ound:GetChildren()) do
        if effect:IsA("EchoSoundEffect") then
            effect:Destroy()
        end
    end
end

-- Initialize
local SettingsTab = Window:CreateTab("Settings", 9753762469) -- Settings icon
SettingsTab:CreateLabel("Ray Field Boombox Controller v1.2")
SettingsTab:CreateLabel("Created by [Your Name]")
SettingsTab:CreateButton({
    Name = "Unload Script",
    Callback = function()
        Window:Destroy()
    end
})

-- Auto-equip boombox if found
spawn(function()
    wait(2) -- Wait for character to load
    EquipBoombox()
end)
