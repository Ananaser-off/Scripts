local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/ionlyusegithubformcmods/1-Line-Scripts/main/Mobile%20Friendly%20Orion')))()

local Window = OrionLib:MakeWindow({Name = "Budgie Hub | Superpower Simulator: Chakra", HidePremium = true, IntroEnabled = false, SaveConfig = false, ConfigFolder = "OrionTest"})

local Tab = Window:MakeTab({
	Name = "Main",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

Tab:AddToggle({
	Name = "Train all stats",
	Default = false,
	Callback = function(Value)
turr = Value
 while turr and task.wait(0.15) do
local ab = {"Strength", "Defense", "Agility"}
for _, tex in ipairs(ab) do
 local args = {
    [1] = tex
}

game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Training"):FireServer(unpack(args))
end
 end
	end    
})

Tab:AddToggle({
 Name = "Auto buy Strength",
 Default = false,
 Callback = function(Value)
kika = Value
  while kika and task.wait(0.05) do
local args = {
    [1] = "Strength"
}

game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("UpgradeMultiplier"):FireServer(unpack(args))
  end
 end    
})

Tab:AddToggle({
 Name = "Auto buy Defense",
 Default = false,
 Callback = function(Value)
fufu = Value
  while fufu and task.wait(0.05) do
local args = {
    [1] = "Defense"
}

game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("UpgradeMultiplier"):FireServer(unpack(args))
  end
 end    
})

Tab:AddToggle({
 Name = "Auto buy Ability",
 Default = false,
 Callback = function(Value)
fuck = Value
   while fuck and task.wait(0.05) do
local args = {
    [1] = "Agility"
}

game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("UpgradeMultiplier"):FireServer(unpack(args))
   end
 end    
})

Tab:AddButton({
 Name = "Redeem codes",
 Callback = function()
local args = {
    [1] = "SUPER"
}

game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("VerifyFollow"):InvokeServer(unpack(args))

local args = {
    [1] = "RELEASE"
}

game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("UseCode"):InvokeServer(unpack(args))

local args = {
    [1] = "2XCOINS"
}

game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("UseCode"):InvokeServer(unpack(args))
   end    
})

local shards = {"Red", "Orange", "Green", "Blue", "Purple", "Silver", "Pink"}
Tab:AddButton({
 Name = "Complete the quest by Stan Lee",
 Callback = function()
local args = {
    [1] = "Stan Lee"
}

game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("QuestGiverInteract"):FireServer(unpack(args))

for _, name in ipairs(shards) do
local args = {
    [1] = workspace:WaitForChild("ScavengerPieces"):WaitForChild(name .. " Shard")
}

game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ScavengerHunt"):FireServer(unpack(args))
end

local args = {
    [1] = "Stan Lee"
}

game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("QuestGiverInteract"):FireServer(unpack(args))
   end    
})

Tab:AddDropdown({
	Name = "TP to all type of NPC",
	Default = "1",
	Options = {"Brawler", "Goon", "Crook", "Purger", "Brute", "Destroyer"},
	Callback = function(Value)
for _, person in ipairs(workspace:GetDescendants()) do
  if person:IsA("Humanoid") and person.Parent.Name == Value and person.Health > 0 then
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = person.RootPart.CFrame * CFrame.new(0, 0, 1)
task.wait(0.4)
  end
end
	end    
})

Tab:AddToggle({
 Name = "Auto punches (Side effects)",
 Default = false,
 Callback = function(Value)
gyh = Value
    while gyh and task.wait(0.1) do
game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, true, game, 1)
    end
 end    
})

local function tatata()
local healhs = {}
for _, player in ipairs(game.Players:GetPlayers()) do
   if player.Character.Humanoid then
table.insert(healhs, player.Name .. ": " .. player.Character.Humanoid.MaxHealth)
  end
end
  return table.concat(healhs, "\n")
end

Tab:AddButton({
 Name = "Find out the HP of all players",
 Callback = function()
        OrionLib:MakeNotification({
	Name = "Budgie Hub",
	Content = "\n" .. tatata(),
	Image = "rbxassetid://4483345998",
	Time = 5
        })
   end    
})

Tab:AddButton({
 Name = "Anti afk",
 Callback = function()
 for i,v in pairs(getconnections(game.Players.LocalPlayer.Idled)) do
  v:Disable()
 end
   end    
})

Tab:AddToggle({
 Name = "Auto farm brawlers",
 Default = false,
 Callback = function(Value)
tatat = Value
  while tatat do
 for _, person in ipairs(workspace:GetDescendants()) do
    pcall(function()
      if tatat == false then return end
  if person:IsA("Humanoid") and person.Parent.Name == "Brawler" and person.Health > 0 then
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = person.RootPart.CFrame * CFrame.new(0, 0, 1)
task.wait(0.4)
   end
  end)
 end
 task.wait(0.25)
end
 end    
})

Tab:AddToggle({
 Name = "Auto farm goons",
 Default = false,
 Callback = function(Value)
tbtbt = Value
   while tbtbt do
 for _, person in ipairs(workspace:GetDescendants()) do
    pcall(function()
      if tbtbt == false then return end
  if person:IsA("Humanoid") and person.Parent.Name == "Goon" and person.Health > 0 then
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = person.RootPart.CFrame * CFrame.new(0, 0, 1)
task.wait(0.4)
   end
  end)
 end
 task.wait(0.25)
end
 end    
})

Tab:AddToggle({
 Name = "Auto farm crooks",
 Default = false,
 Callback = function(Value)
tctct = Value
  while tctct do
 for _, person in ipairs(workspace:GetDescendants()) do
    pcall(function()
      if tctct == false then return end
  if person:IsA("Humanoid") and person.Parent.Name == "Crook" and person.Health > 0 then
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = person.RootPart.CFrame * CFrame.new(0, 0, 1)
task.wait(0.4)
   end
  end)
 end
 task.wait(0.25)
end
 end    
})

Tab:AddToggle({
 Name = "Auto farm purgers",
 Default = false,
 Callback = function(Value)
tdtdt = Value
  while tdtdt do
 for _, person in ipairs(workspace:GetDescendants()) do
    pcall(function()
      if tdtdt == false then return end
  if person:IsA("Humanoid") and person.Parent.Name == "Purger" and person.Health > 0 then
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = person.RootPart.CFrame * CFrame.new(0, 0, 1)
task.wait(0.4)
   end
  end)
 end
 task.wait(0.25)
end
 end    
})

Tab:AddToggle({
 Name = "Auto farm brutes",
 Default = false,
 Callback = function(Value)
tetet = Value
  while tetet do
 for _, person in ipairs(workspace:GetDescendants()) do
    pcall(function()
      if tetet == false then return end
  if person:IsA("Humanoid") and person.Parent.Name == "Brute" and person.Health > 0 then
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = person.RootPart.CFrame * CFrame.new(0, 0, 1)
task.wait(0.4)
   end
  end)
 end
 task.wait(0.25)
end
 end    
})
