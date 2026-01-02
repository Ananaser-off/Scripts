local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/GhostDuckyy/UI-Libraries/refs/heads/main/Orion/source.lua'))()
local Window = OrionLib:MakeWindow({Name = "Ananaser ESP", HidePremium = false, SaveConfig = true, ConfigFolder = "AnanaserESP"})

local Config = {
    Enabled = true,
    ShowBox = true,
    ShowName = true,
    ShowTeam = false,
    Range = 2500,
    EnemyColor = Color3.fromRGB(255, 50, 50),
    TeamColor = Color3.fromRGB(0, 255, 0),
    TextSize = 14
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ESP_Cache = {}

local function RemoveESP(char)
    if ESP_Cache[char] then
        if ESP_Cache[char].Folder then ESP_Cache[char].Folder:Destroy() end
        ESP_Cache[char] = nil
    end
end

local function CreateESP(player, char)
    if ESP_Cache[char] then return end
    
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("Head")
    if not root then return end

    local folder = Instance.new("Folder")
    folder.Name = "AnanaserESP_Visuals"
    folder.Parent = char

    local box = Instance.new("BoxHandleAdornment")
    box.Name = "Box"
    box.Adornee = root
    box.Size = char:GetExtentsSize()
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Transparency = 0.5
    box.Color3 = Config.EnemyColor
    box.Visible = false 
    box.Parent = folder

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NameTag"
    billboard.Adornee = root
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Visible = false
    billboard.Parent = folder

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.new(0,0,0)
    label.TextColor3 = Config.EnemyColor
    label.Font = Enum.Font.GothamBold
    label.TextSize = Config.TextSize
    label.Text = player.Name
    label.Parent = billboard

    ESP_Cache[char] = {
        Folder = folder,
        Box = box,
        Billboard = billboard,
        Label = label,
        Player = player,
        Root = root
    }
end

local function UpdateESP()
    for char, data in pairs(ESP_Cache) do
        local player = data.Player
        local root = data.Root
        
        if not char or not char.Parent or not root or not player then
            RemoveESP(char)
            continue
        end

        if not Config.Enabled then
            data.Folder.Parent = nil
            continue
        else
            data.Folder.Parent = char
        end

        local isTeammate = (player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team)
        if isTeammate and not Config.ShowTeam then
            data.Folder.Parent = nil
            continue
        end

        local dist = (Camera.CFrame.Position - root.Position).Magnitude
        if dist > Config.Range then
            data.Folder.Parent = nil
            continue
        end

        local color = isTeammate and Config.TeamColor or Config.EnemyColor
        data.Box.Color3 = color
        data.Label.TextColor3 = color

        if Config.ShowBox then
            data.Box.Visible = true
            data.Box.Size = char:GetExtentsSize()
        else
            data.Box.Visible = false
        end

        if Config.ShowName then
            data.Billboard.Visible = true
            data.Label.TextSize = Config.TextSize
            data.Label.Text = string.format("%s\n[%d m]", player.Name, math.floor(dist))
        else
            data.Billboard.Visible = false
        end
    end
end

local function OnCharacterAdded(char, player)
    task.wait(0.5)
    CreateESP(player, char)
    
    char.AncestryChanged:Connect(function(_, parent)
        if not parent then RemoveESP(char) end
    end)
end

local function OnPlayerAdded(player)
    if player == LocalPlayer then return end
    
    if player.Character then 
        OnCharacterAdded(player.Character, player) 
    end
    
    player.CharacterAdded:Connect(function(char)
        OnCharacterAdded(char, player)
    end)
end

for _, p in ipairs(Players:GetPlayers()) do
    OnPlayerAdded(p)
end
Players.PlayerAdded:Connect(OnPlayerAdded)

RunService.RenderStepped:Connect(UpdateESP)

local VisualsTab = Window:MakeTab({Name = "Visuals", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local SettingsTab = Window:MakeTab({Name = "Settings", Icon = "rbxassetid://4483345998", PremiumOnly = false})

VisualsTab:AddToggle({
	Name = "Enable ESP",
	Default = true,
	Callback = function(Value)
		Config.Enabled = Value
	end    
})

VisualsTab:AddToggle({
	Name = "Show Boxes",
	Default = true,
	Callback = function(Value)
		Config.ShowBox = Value
	end    
})

VisualsTab:AddToggle({
	Name = "Show Names & Distance",
	Default = true,
	Callback = function(Value)
		Config.ShowName = Value
	end    
})

VisualsTab:AddToggle({
	Name = "Show Teammates",
	Default = false,
	Callback = function(Value)
		Config.ShowTeam = Value
	end    
})

VisualsTab:AddColorpicker({
	Name = "Enemy Color",
	Default = Color3.fromRGB(255, 50, 50),
	Callback = function(Value)
		Config.EnemyColor = Value
	end	  
})

VisualsTab:AddColorpicker({
	Name = "Team Color",
	Default = Color3.fromRGB(0, 255, 0),
	Callback = function(Value)
		Config.TeamColor = Value
	end	  
})

SettingsTab:AddSlider({
	Name = "Render Distance",
	Min = 100,
	Max = 5000,
	Default = 2500,
	Color = Color3.fromRGB(255,255,255),
	Increment = 100,
	ValueName = "studs",
	Callback = function(Value)
		Config.Range = Value
	end    
})

SettingsTab:AddSlider({
	Name = "Text Size",
	Min = 8,
	Max = 24,
	Default = 14,
	Color = Color3.fromRGB(255,255,255),
	Increment = 1,
	ValueName = "px",
	Callback = function(Value)
		Config.TextSize = Value
	end    
})

OrionLib:Init()
