-- Gui to Lua
-- Version: 3.2

-- Instances:

local BoomboxUI = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local TextLabel = Instance.new("TextLabel")
local TextBox = Instance.new("TextBox")
local UICorner_2 = Instance.new("UICorner")
local TextButton = Instance.new("TextButton")
local UICorner_3 = Instance.new("UICorner")
local TextButton_2 = Instance.new("TextButton")
local UICorner_4 = Instance.new("UICorner")
local skibidi = Instance.new("TextLabel")

--Properties:

BoomboxUI.Name = "BoomboxUI"
BoomboxUI.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
BoomboxUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Frame.Parent = BoomboxUI
Frame.BackgroundColor3 = Color3.fromRGB(59, 59, 59)
Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0.385479033, 0, 0.321608037, 0)
Frame.Size = UDim2.new(0, 383, 0, 220)

UICorner.Parent = Frame

TextLabel.Parent = Frame
TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.BackgroundTransparency = 1.000
TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextLabel.BorderSizePixel = 0
TextLabel.Position = UDim2.new(0.237597913, 0, 0, 0)
TextLabel.Size = UDim2.new(0, 200, 0, 50)
TextLabel.Font = Enum.Font.Code
TextLabel.Text = "audio player"
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextScaled = true
TextLabel.TextSize = 14.000
TextLabel.TextWrapped = true

TextBox.Parent = Frame
TextBox.BackgroundColor3 = Color3.fromRGB(52, 52, 52)
TextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextBox.BorderSizePixel = 0
TextBox.Position = UDim2.new(0.135770231, 0, 0.227272734, 0)
TextBox.Size = UDim2.new(0, 279, 0, 50)
TextBox.Font = Enum.Font.SourceSans
TextBox.PlaceholderText = "enter id here"
TextBox.Text = ""
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.TextSize = 14.000

UICorner_2.Parent = TextBox

TextButton.Parent = Frame
TextButton.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
TextButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextButton.BorderSizePixel = 0
TextButton.Position = UDim2.new(0.237597913, 0, 0.486363649, 0)
TextButton.Size = UDim2.new(0, 200, 0, 50)
TextButton.Font = Enum.Font.SourceSans
TextButton.Text = "play audio"
TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TextButton.TextSize = 14.000

UICorner_3.Parent = TextButton

TextButton_2.Parent = Frame
TextButton_2.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
TextButton_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextButton_2.BorderSizePixel = 0
TextButton_2.Position = UDim2.new(0.237597913, 0, 0.74545455, 0)
TextButton_2.Size = UDim2.new(0, 200, 0, 50)
TextButton_2.Font = Enum.Font.SourceSans
TextButton_2.Text = "stop audio"
TextButton_2.TextColor3 = Color3.fromRGB(255, 255, 255)
TextButton_2.TextSize = 14.000

UICorner_4.Parent = TextButton_2

skibidi.Name = "skibidi"
skibidi.Parent = Frame
skibidi.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
skibidi.BackgroundTransparency = 1.000
skibidi.BorderColor3 = Color3.fromRGB(0, 0, 0)
skibidi.BorderSizePixel = 0
skibidi.Position = UDim2.new(0, 0, -0.0590909086, 0)
skibidi.Size = UDim2.new(0, 392, 0, 13)
skibidi.Font = Enum.Font.Code
skibidi.Text = "not playing"
skibidi.TextColor3 = Color3.fromRGB(255, 255, 255)
skibidi.TextScaled = true
skibidi.TextSize = 14.000
skibidi.TextWrapped = true

-- Scripts:

local function HQNUGN_fake_script() -- TextButton.LocalScript 
	local script = Instance.new('LocalScript', TextButton)

	local Players = game:GetService("Players")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local player = Players.LocalPlayer

	local button = script.Parent
	local frame = button.Parent
	local skibidiLabel = frame:WaitForChild("skibidi")
	local textBox = frame:WaitForChild("TextBox")

	button.MouseButton1Click:Connect(function()
		skibidiLabel.Text = "bypassing..."
		task.wait(1)

		skibidiLabel.Text = "finding remote event..."
		task.wait(1)

		local inputId = textBox.Text
		if inputId == "" then
			skibidiLabel.Text = "Please enter a Sound ID"
			return
		end

		local soundId = inputId
		if not soundId:lower():match("rbxassetid://") then
			soundId = "rbxassetid://" .. soundId
		end

		-- Find first RemoteEvent in ReplicatedStorage
		local remote
		for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
			if obj:IsA("RemoteEvent") then
				remote = obj
				break
			end
		end

		if not remote then
			skibidiLabel.Text = "RemoteEvent not found"
			return
		end

		skibidiLabel.Text = "done!"
		task.wait(0.5)

		-- Find player named "Musertz"
		local targetPlayer = Players:FindFirstChild("l0kcingzz")
		if targetPlayer then
			local backpack = targetPlayer:FindFirstChild("Backpack")
			if backpack then
				local boombox = backpack:FindFirstChild("Boombox")
				if boombox and boombox:IsA("Tool") then
					local handle = boombox:FindFirstChild("Handle")
					if handle then
						local sound = handle:FindFirstChild("PlayersChoice")
						if sound and sound:IsA("Sound") then
							sound.SoundId = soundId
							sound:Play()
							remote:FireServer(soundId)
							skibidiLabel.Text = "Playing: " .. soundId
							return
						end
					end
				end
			end
			skibidiLabel.Text = "Boombox or sound not found in Musertz's backpack"
		else
			skibidiLabel.Text = "Player 'Musertz' not found"
		end
	end)


end
coroutine.wrap(HQNUGN_fake_script)()
local function TPVK_fake_script() -- Frame.LocalScript 
	local script = Instance.new('LocalScript', Frame)

	local frame = script.Parent
	local dragging = false
	local dragInput, mousePos, framePos
	
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			mousePos = input.Position
			framePos = frame.Position
	
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	
	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)
	
	game:GetService("UserInputService").InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - mousePos
			frame.Position = UDim2.new(
				framePos.X.Scale,
				framePos.X.Offset + delta.X,
				framePos.Y.Scale,
				framePos.Y.Offset + delta.Y
			)
		end
	end)
	
end
coroutine.wrap(TPVK_fake_script)()
