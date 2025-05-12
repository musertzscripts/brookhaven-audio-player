local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Services
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Configuration
local DEFAULT_SOUND_ID = "rbxassetid://142376088" -- Default boombox sound
local MAX_DISTANCE = 100
local DEFAULT_VOLUME = 0.5
local DEFAULT_PITCH = 1
local DEFAULT_LOOP = true
local DEFAULT_AUTO_PLAY = true

-- Create Window
local Window = Rayfield:CreateWindow({
    Name = "Advanced Boombox Controller",
    LoadingTitle = "Loading Boombox Suite",
    LoadingSubtitle = "by YourName",
    ConfigurationSaving = {
       Enabled = true,
       FolderName = "RayfieldBoombox",
       FileName = "Config"
    },
    Discord = {
       Enabled = false,
       Invite = "noinvitelink",
       RememberJoins = true
    },
    KeySystem = false
})

-- Main Tab
local MainTab = Window:CreateTab("Main", 4483362458) -- Boombox icon

-- Sound Controls Section
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
    Options = {"LocalPlayer"},
    CurrentOption = "LocalPlayer",
    Flag = "PlayerSelection",
    Callback = function(Option)
        SelectedPlayer = Option == "LocalPlayer" and Players.LocalPlayer or Players:FindFirstChild(Option)
    end
})

-- Update player list
local function UpdatePlayerList()
    local options = {"LocalPlayer"}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            table.insert(options, player.Name)
        end
    end
    PlayerDropdown:UpdateOptions(options)
end

Players.PlayerAdded:Connect(UpdatePlayerList)
Players.PlayerRemoved:Connect(UpdatePlayerList)
UpdatePlayerList()

-- Advanced Features Section
MainTab:CreateSection("Advanced Features")

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
    Name = "TPOS (Time Position)",
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
    Name = "TPOS Offset (sec)",
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
    Name = "Auto Play",
    CurrentValue = DEFAULT_AUTO_PLAY,
    Flag = "AutoPlayEnabled",
    Callback = function(Value)
        -- Handled when sound is loaded
    end
})

-- Effects Section
MainTab:CreateSection("Sound Effects")

local ReverbToggle = MainTab:CreateToggle({
    Name = "Reverb Effect",
    CurrentValue = false,
    Flag = "ReverbEnabled",
    Callback = function(Value)
        if CurrentSound then
            if Value then
                ApplyReverb()
            else
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
                ApplyEcho()
            else
                RemoveEcho()
            end
        end
    end
})

-- Player Controls Section
MainTab:CreateSection("Controls")

local PlayButton = MainTab:CreateButton({
    Name = "▶️ Play Sound",
    Callback = function()
        PlaySound()
    end
})

local StopButton = MainTab:CreateButton({
    Name = "⏹️ Stop Sound",
    Callback = function()
        StopSound()
    end
})

local EquipButton = MainTab:CreateButton({
    Name = "🎒 Equip Boombox",
    Callback = function()
        EquipBoombox()
    end
})

-- Variables
local CurrentSound = nil
local CurrentBoombox = nil
local SelectedPlayer = Players.LocalPlayer
local DistortionAmount = 0.5
local TPOSValue = 0
local DistortionConnection = nil
local TPOSConnection = nil

-- Functions
function FindBoombox(player)
    if not player then return nil end
    
    -- Check backpack
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
    local player = SelectedPlayer or Players.LocalPlayer
    local boombox = FindBoombox(player)
    
    if boombox then
        if player == Players.LocalPlayer then
            local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:EquipTool(boombox)
            end
        end
        CurrentBoombox = boombox
        Rayfield:Notify({
            Title = "Boombox Equipped",
            Content = "Using "..player.Name.."'s boombox",
            Duration = 3,
            Image = 4483362458
        })
    else
        Rayfield:Notify({
            Title = "Error",
            Content = "No boombox found for "..player.Name,
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
        Rayfield:Notify({
            Title = "Invalid Sound ID",
            Content = "Please enter a valid sound ID",
            Duration = 3,
            Image = 4483362458
        })
        return
    end
    
    -- Format sound ID
    if soundId:match("^%d+$") then
        soundId = "rbxassetid://"..soundId
    end
    
    -- Stop current sound
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
        local character = Players.LocalPlayer.Character
        if character then
            CurrentSound.Parent = character:FindFirstChild("Head") or character
        end
    end
    
    -- Load and play
    CurrentSound.Loaded:Connect(function()
        if AutoPlayToggle.Value then
            CurrentSound:Play()
            
            -- Apply effects
            if ReverbToggle.Value then ApplyReverb() end
            if EchoToggle.Value then ApplyEcho() end
            if DistortionToggle.Value then StartDistortion() end
            if TPOSEnabled.Value then StartTPOS() end
            
            Rayfield:Notify({
                Title = "Playing Sound",
                Content = "Now playing: "..soundId,
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
    
    RemoveReverb() -- Clear existing
    
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
    
    RemoveEcho() -- Clear existing
    
    local echo = Instance.new("EchoSoundEffect")
    echo.Enabled = true
    echo.Delay = 0.5
    echo.Feedback = 0.5
    echo.WetLevel = 0.5
    echo.Parent = CurrentSound
end

function RemoveEcho()
    if not CurrentSound then return end
    
    for _, effect in ipairs(CurrentSound:GetChildren()) do
        if effect:IsA("EchoSoundEffect") then
            effect:Destroy()
        end
    end
end

-- Settings Tab
local SettingsTab = Window:CreateTab("Settings", 9753762469)
SettingsTab:CreateLabel("Boombox Controller v1.0")
SettingsTab:CreateLabel("Made for Xeno Executor")
SettingsTab:CreateButton({
    Name = "Unload Script",
    Callback = function()
        Rayfield:Destroy()
    end
})

-- Auto-equip on start
task.spawn(function()
    task.wait(2)
    EquipBoombox()
end)
