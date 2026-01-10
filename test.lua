local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Ananaser = {}
Ananaser.__index = Ananaser

local DefaultTheme = {
	Name = "Ananaser Ultra",
	Font = Enum.Font.GothamBold,
	FontRegular = Enum.Font.Gotham,
	
	BG = Color3.fromRGB(8, 8, 12),
	Panel = Color3.fromRGB(16, 16, 22),
	Topbar = Color3.fromRGB(18, 18, 26),
	Stroke = Color3.fromRGB(70, 70, 95),
	
	Text = Color3.fromRGB(245, 245, 255),
	SubText = Color3.fromRGB(160, 160, 180),
	Disabled = Color3.fromRGB(90, 90, 100),
	
	Accent = Color3.fromRGB(255, 200, 0),
	Accent2 = Color3.fromRGB(255, 140, 0),
	AccentGlow = Color3.fromRGB(255, 230, 100),
	
	Success = Color3.fromRGB(50, 215, 75),
	Warning = Color3.fromRGB(255, 159, 10),
	Error = Color3.fromRGB(255, 69, 58),
	
	Control = Color3.fromRGB(24, 24, 34),
	ControlHover = Color3.fromRGB(32, 32, 46),
	ControlActive = Color3.fromRGB(40, 40, 56),
	
	Radius = 12,
	Pad = 12,
	
	TweenTime = 0.20,
	EaseStyle = Enum.EasingStyle.Quint,
	EaseDir = Enum.EasingDirection.Out,
}

local function create(className, props)
	local inst = Instance.new(className)
	if props then
		for k,v in pairs(props) do
			inst[k] = v
		end
	end
	return inst
end

local function tween(obj, time_, props)
	local t = time_ or DefaultTheme.TweenTime
	local info = TweenInfo.new(t, DefaultTheme.EaseStyle, DefaultTheme.EaseDir)
	local tw = TweenService:Create(obj, info, props)
	tw:Play()
	return tw
end

local function tweenElastic(obj, time_, props)
	local info = TweenInfo.new(time_, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
	local tw = TweenService:Create(obj, info, props)
	tw:Play()
	return tw
end

local function tweenBounce(obj, time_, props)
	local info = TweenInfo.new(time_, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
	local tw = TweenService:Create(obj, info, props)
	tw:Play()
	return tw
end

local function round(parent, r)
	return create("UICorner", {CornerRadius = UDim.new(0, r), Parent = parent})
end

local function stroke(parent, c, th, tr)
	local s = create("UIStroke", {
		Color = c,
		Thickness = th,
		Transparency = tr or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = parent
	})
	return s
end

local function padding(parent, p)
	return create("UIPadding", {
		PaddingLeft = UDim.new(0, p),
		PaddingRight = UDim.new(0, p),
		PaddingTop = UDim.new(0, p),
		PaddingBottom = UDim.new(0, p),
		Parent = parent
	})
end

local function list(parent, dir, padPx, align, vAlign)
	local l = create("UIListLayout", {
		FillDirection = dir,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, padPx),
		HorizontalAlignment = align or Enum.HorizontalAlignment.Left,
		VerticalAlignment = vAlign or Enum.VerticalAlignment.Top,
		Parent = parent
	})
	return l
end

local function autoCanvas(frame)
	local layout = frame:FindFirstChildOfClass("UIListLayout")
	if not layout then return end
	local function upd()
		frame.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 16)
	end
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(upd)
	upd()
end

local function gradient(parent, rot, c1, c2)
	local g = create("UIGradient", {
		Rotation = rot,
		Color = ColorSequence.new(c1, c2),
		Parent = parent
	})
	return g
end

local function shadow(parent, size, transparency)
	local s = create("ImageLabel", {
		BackgroundTransparency = 1,
		Image = "rbxasset://textures/ui/GuiImagePlaceholder.png",
		ImageColor3 = Color3.fromRGB(0,0,0),
		ImageTransparency = transparency or 0.65,
		Size = UDim2.new(1, size*2, 1, size*2),
		Position = UDim2.fromOffset(-size, -size),
		ZIndex = -1,
		Parent = parent
	})
	return s
end

local function glow(parent, color, size)
	local g = create("ImageLabel", {
		BackgroundTransparency = 1,
		Image = "rbxassetid://5028857472",
		ImageColor3 = color,
		ImageTransparency = 0.3,
		Size = UDim2.new(1, size, 1, size),
		Position = UDim2.fromOffset(-size/2, -size/2),
		ZIndex = 0,
		Parent = parent
	})
	return g
end

local function ripple(parent, x, y)
	local r = create("Frame", {
		BackgroundColor3 = Color3.fromRGB(255,255,255),
		BackgroundTransparency = 0.5,
		Size = UDim2.fromOffset(0,0),
		Position = UDim2.fromOffset(x, y),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ZIndex = 10,
		Parent = parent
	})
	round(r, 999)
	
	local maxSize = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2
	
	tween(r, 0.5, {Size = UDim2.fromOffset(maxSize, maxSize), BackgroundTransparency = 1})
	task.delay(0.5, function()
		if r.Parent then r:Destroy() end
	end)
end

local function pulse(obj)
	local orig = obj.Size
	tweenElastic(obj, 0.4, {Size = UDim2.new(orig.X.Scale, orig.X.Offset + 10, orig.Y.Scale, orig.Y.Offset + 10)})
	task.wait(0.2)
	if obj.Parent then
		tween(obj, 0.2, {Size = orig})
	end
end

local function shimmer(parent, duration)
	local sh = create("Frame", {
		BackgroundColor3 = Color3.fromRGB(255,255,255),
		BackgroundTransparency = 0.7,
		Size = UDim2.new(0, 50, 1, 0),
		Position = UDim2.new(-0.2, 0, 0, 0),
		ZIndex = 5,
		Parent = parent
	})
	gradient(sh, 0, Color3.fromRGB(255,255,255), Color3.fromRGB(255,255,255))
	
	tween(sh, duration or 0.8, {Position = UDim2.new(1.2, 0, 0, 0)})
	task.delay(duration or 0.8, function()
		if sh.Parent then sh:Destroy() end
	end)
end

local function makeDraggable(handle, root)
	local dragging = false
	local dragStart = nil
	local startPos = nil
	
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = root.Position
		end
	end)
	
	handle.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
		if not dragStart or not startPos then return end
		
		local delta = input.Position - dragStart
		root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end)
end

local ParticleSystem = {}
ParticleSystem.__index = ParticleSystem

function ParticleSystem.new(parent, theme)
	local self = setmetatable({}, ParticleSystem)
	self.Parent = parent
	self.Theme = theme
	self.Particles = {}
	self.Active = true
	
	self.Container = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1,1),
		ZIndex = 1,
		Parent = parent
	})
	
	task.spawn(function()
		while self.Active do
			self:Emit()
			task.wait(math.random(50, 150) / 1000)
		end
	end)
	
	RunService.Heartbeat:Connect(function(dt)
		for i = #self.Particles, 1, -1 do
			local p = self.Particles[i]
			if p.Dead then
				table.remove(self.Particles, i)
			else
				p:Update(dt)
			end
		end
	end)
	
	return self
end

function ParticleSystem:Emit()
	if #self.Particles > 40 then return end
	
	local part = {
		Dead = false,
		Life = 0,
		MaxLife = math.random(20, 50) / 10,
		VelX = math.random(-30, 30),
		VelY = math.random(-80, -40),
		X = math.random(0, self.Container.AbsoluteSize.X),
		Y = self.Container.AbsoluteSize.Y,
		Size = math.random(3, 8),
	}
	
	part.Frame = create("Frame", {
		BackgroundColor3 = self.Theme.Accent,
		BackgroundTransparency = 0.2,
		Size = UDim2.fromOffset(part.Size, part.Size),
		Position = UDim2.fromOffset(part.X, part.Y),
		ZIndex = 2,
		Parent = self.Container
	})
	round(part.Frame, 999)
	
	function part:Update(dt)
		self.Life = self.Life + dt
		if self.Life >= self.MaxLife then
			self.Dead = true
			if self.Frame.Parent then self.Frame:Destroy() end
			return
		end
		
		self.VelY = self.VelY + 100 * dt
		self.X = self.X + self.VelX * dt
		self.Y = self.Y + self.VelY * dt
		
		local alpha = self.Life / self.MaxLife
		self.Frame.BackgroundTransparency = 0.2 + alpha * 0.8
		self.Frame.Position = UDim2.fromOffset(self.X, self.Y)
	end
	
	table.insert(self.Particles, part)
end

function ParticleSystem:Destroy()
	self.Active = false
	if self.Container.Parent then self.Container:Destroy() end
end

local function createSearchBar(parent, theme, onSearch)
	local bar = create("Frame", {
		BackgroundColor3 = theme.Control,
		Size = UDim2.new(1, 0, 0, 44),
		Parent = parent
	})
	round(bar, 10)
	stroke(bar, theme.Stroke, 1, 0.5)
	padding(bar, 10)
	
	local icon = create("TextLabel", {
		BackgroundTransparency = 1,
		Text = "🔍",
		TextColor3 = theme.SubText,
		Font = theme.Font,
		TextSize = 18,
		Size = UDim2.fromOffset(28, 24),
		Parent = bar
	})
	
	local input = create("TextBox", {
		BackgroundTransparency = 1,
		PlaceholderText = "Search...",
		PlaceholderColor3 = theme.SubText,
		Text = "",
		TextColor3 = theme.Text,
		Font = theme.FontRegular,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(34, 0),
		Size = UDim2.new(1, -40, 1, 0),
		ClearTextOnFocus = false,
		Parent = bar
	})
	
	input:GetPropertyChangedSignal("Text"):Connect(function()
		if onSearch then onSearch(input.Text) end
	end)
	
	return bar
end

local function newWindow(config)
	config = config or {}
	
	local theme = table.clone(DefaultTheme)
	if config.Theme then
		for k,v in pairs(config.Theme) do
			theme[k] = v
		end
	end
	
	local title = config.Title or "Ananaser Hub"
	local subtitle = config.Subtitle or "Premium UI Library"
	local icon = config.Icon or "🍍"
	
	local sg = create("ScreenGui", {
		Name = "AnanaserHubUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
		Parent = PlayerGui
	})
	
	local blur = create("BlurEffect", {
		Size = 0,
		Parent = game.Lighting
	})
	
	local overlay = create("Frame", {
		Name = "Overlay",
		BackgroundColor3 = theme.BG,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1,1),
		Parent = sg
	})
	
	local notifyLayer = create("Frame", {
		Name = "NotifyLayer",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1,1),
		ZIndex = 100,
		Parent = overlay
	})
	
	local root = create("Frame", {
		Name = "Root",
		BackgroundColor3 = theme.Panel,
		BackgroundTransparency = 0.05,
		Size = UDim2.fromOffset(820, 520),
		Position = UDim2.fromScale(0.5, 1.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Parent = overlay
	})
	round(root, theme.Radius + 4)
	stroke(root, theme.Stroke, 1.5, 0.25)
	
	local glowBg = glow(root, theme.AccentGlow, 100)
	glowBg.ImageTransparency = 0.75
	
	local topbar = create("Frame", {
		Name = "Topbar",
		BackgroundColor3 = theme.Topbar,
		BackgroundTransparency = 0.1,
		Size = UDim2.new(1, 0, 0, 64),
		Parent = root
	})
	round(topbar, theme.Radius + 4)
	padding(topbar, theme.Pad + 4)
	gradient(topbar, 90, theme.Topbar, Color3.fromRGB(theme.Topbar.R + 5, theme.Topbar.G + 5, theme.Topbar.B + 10))
	
	local topLayout = list(topbar, Enum.FillDirection.Horizontal, 12, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
	
	local iconLbl = create("TextLabel", {
		BackgroundTransparency = 1,
		Text = icon,
		Font = theme.Font,
		TextSize = 28,
		Size = UDim2.fromOffset(40, 40),
		Parent = topbar
	})
	
	local titleWrap = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -280, 1, 0),
		Parent = topbar
	})
	
	local titleLbl = create("TextLabel", {
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = theme.Text,
		Font = theme.Font,
		TextSize = 22,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1,0,0,28),
		Parent = titleWrap
	})
	
	local subLbl = create("TextLabel", {
		BackgroundTransparency = 1,
		Text = subtitle,
		TextColor3 = theme.SubText,
		Font = theme.FontRegular,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0,0,0,28),
		Size = UDim2.new(1,0,0,20),
		Parent = titleWrap
	})
	
	local btnWrap = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 180, 1, 0),
		Parent = topbar
	})
	local btnLayout = list(btnWrap, Enum.FillDirection.Horizontal, 10, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)
	
	local function iconButton(text, color)
		local b = create("TextButton", {
			BackgroundColor3 = color or theme.Control,
			AutoButtonColor = false,
			Text = text,
			TextColor3 = theme.Text,
			Font = theme.Font,
			TextSize = 16,
			Size = UDim2.fromOffset(42, 38),
			Parent = btnWrap
		})
		round(b, 10)
		stroke(b, theme.Stroke, 1.3, 0.45)
		
		b.MouseEnter:Connect(function()
			tween(b, 0.14, {BackgroundColor3 = theme.ControlHover})
			pulse(b)
		end)
		b.MouseLeave:Connect(function()
			tween(b, 0.14, {BackgroundColor3 = color or theme.Control})
		end)
		return b
	end
	
	local settingsBtn = iconButton("⚙️")
	local minimizeBtn = iconButton("—")
	local closeBtn = iconButton("✕", Color3.fromRGB(40, 20, 20))
	
	local body = create("Frame", {
		Name = "Body",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, -64),
		Position = UDim2.new(0,0,0,64),
		Parent = root
	})
	
	local sidebar = create("Frame", {
		Name = "Sidebar",
		BackgroundColor3 = theme.Panel,
		BackgroundTransparency = 0.3,
		Size = UDim2.new(0, 220, 1, 0),
		Parent = body
	})
	padding(sidebar, theme.Pad)
	gradient(sidebar, 45, Color3.fromRGB(theme.Panel.R + 3, theme.Panel.G + 3, theme.Panel.B + 5), theme.Panel)
	
	local searchBar = createSearchBar(sidebar, theme, function(query)
	end)
	
	local tabBar = create("ScrollingFrame", {
		Name = "TabBar",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 5,
		ScrollBarImageTransparency = 0.3,
		Size = UDim2.new(1, 0, 1, -56),
		Position = UDim2.new(0, 0, 0, 54),
		CanvasSize = UDim2.fromOffset(0,0),
		Parent = sidebar
	})
	local tabList = list(tabBar, Enum.FillDirection.Vertical, 10)
	autoCanvas(tabBar)
	
	local pages = create("Frame", {
		Name = "Pages",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -220, 1, 0),
		Position = UDim2.new(0, 220, 0, 0),
		Parent = body
	})
	
	local particles = ParticleSystem.new(root, theme)
	
	local window = {
		ScreenGui = sg,
		Root = root,
		Pages = pages,
		TabBar = tabBar,
		NotifyLayer = notifyLayer,
		
		Theme = theme,
		Tabs = {},
		State = {},
		Keybinds = {},
		Particles = particles,
		Blur = blur,
	}
	
	local function adapt()
		local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
		local w = math.clamp(vp.X * 0.88, 420, 900)
		local h = math.clamp(vp.Y * 0.76, 360, 600)
		root.Size = UDim2.fromOffset(w, h)
	end
	adapt()
	if workspace.CurrentCamera then
		workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(adapt)
	end
	
	makeDraggable(topbar, root)
	
	tween(overlay, 0.3, {BackgroundTransparency = 0.2})
	tween(blur, 0.3, {Size = 18})
	task.wait(0.15)
	tweenElastic(root, 0.7, {Position = UDim2.fromScale(0.5, 0.5)})
	shimmer(root, 1.2)
	
	local minimized = false
	minimizeBtn.MouseButton1Click:Connect(function()
		ripple(minimizeBtn, minimizeBtn.AbsoluteSize.X/2, minimizeBtn.AbsoluteSize.Y/2)
		minimized = not minimized
		if minimized then
			tween(body, 0.25, {Size = UDim2.new(1,0,0,0)})
			tween(root, 0.25, {Size = UDim2.fromOffset(root.AbsoluteSize.X, 64)})
		else
			adapt()
			tween(body, 0.25, {Size = UDim2.new(1,0,1,-64)})
		end
	end)
	
	closeBtn.MouseButton1Click:Connect(function()
		ripple(closeBtn, closeBtn.AbsoluteSize.X/2, closeBtn.AbsoluteSize.Y/2)
		tween(root, 0.3, {Position = UDim2.fromScale(0.5, 1.5)})
		tween(overlay, 0.3, {BackgroundTransparency = 1})
		tween(blur, 0.3, {Size = 0})
		task.wait(0.35)
		particles:Destroy()
		sg:Destroy()
	end)
	
	function window:MakeNotification(t_, c_, time_, ntype)
		local t = time_ or 4
		local col = theme.Accent
		if ntype == "success" then col = theme.Success
		elseif ntype == "warning" then col = theme.Warning
		elseif ntype == "error" then col = theme.Error
		end
		
		local card = create("Frame", {
			BackgroundColor3 = theme.Panel,
			BackgroundTransparency = 0.1,
			Size = UDim2.fromOffset(360, 96),
			Position = UDim2.new(1, 20, 1, -20),
			AnchorPoint = Vector2.new(1, 1),
			Parent = self.NotifyLayer
		})
		round(card, 14)
		stroke(card, col, 2, 0.3)
		padding(card, 14)
		gradient(card, 90, theme.Panel, Color3.fromRGB(theme.Panel.R + 5, theme.Panel.G + 5, theme.Panel.B + 8))
		
		local accentBar = create("Frame", {
			BackgroundColor3 = col,
			Size = UDim2.new(0, 4, 1, 0),
			Position = UDim2.fromOffset(0, 0),
			Parent = card
		})
		round(accentBar, 2)
		
		local tl = create("TextLabel", {
			BackgroundTransparency = 1,
			Text = t_,
			TextColor3 = theme.Text,
			Font = theme.Font,
			TextSize = 17,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(14, 0),
			Size = UDim2.new(1,-14,0,24),
			Parent = card
		})
		
		local cl = create("TextLabel", {
			BackgroundTransparency = 1,
			Text = c_,
			TextColor3 = theme.SubText,
			Font = theme.FontRegular,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			Position = UDim2.new(0,14,0,28),
			Size = UDim2.new(1,-14,1,-28),
			Parent = card
		})
		
		card.BackgroundTransparency = 1
		tweenBounce(card, 0.5, {Position = UDim2.new(1, -20, 1, -20)})
		tween(card, 0.3, {BackgroundTransparency = 0.1})
		shimmer(card, 0.9)
		
		task.delay(t, function()
			if card.Parent then
				tween(card, 0.25, {Position = UDim2.new(1, 20, 1, -20), BackgroundTransparency = 1})
				task.wait(0.3)
				if card.Parent then card:Destroy() end
			end
		end)
	end
	
	function window:SelectTab(tab)
		for _,t in ipairs(self.Tabs) do
			tween(t.Button, 0.18, {BackgroundColor3 = self.Theme.Control})
			t.Button.TextColor3 = self.Theme.Text
			t.Page.Visible = false
		end
		tween(tab.Button, 0.18, {BackgroundColor3 = self.Theme.ControlActive})
		tab.Button.TextColor3 = self.Theme.Accent
		tab.Page.Visible = true
		shimmer(tab.Button, 0.6)
	end
	
	function window:ExportConfig()
		return HttpService:JSONEncode(self.State)
	end
	
	function window:ImportConfig(json)
		local ok, data = pcall(function() return HttpService:JSONDecode(json) end)
		if ok and typeof(data) == "table" then
			self.State = data
		end
	end
	
	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.UserInputType == Enum.UserInputType.Keyboard then
			local key = input.KeyCode.Name
			local fn = window.Keybinds[key]
			if fn then pcall(fn) end
		end
	end)
	
	function window:MakeTab(name, emoji)
		local btn = create("TextButton", {
			BackgroundColor3 = self.Theme.Control,
			AutoButtonColor = false,
			Text = "",
			Size = UDim2.new(1,0,0,50),
			Parent = self.TabBar
		})
		round(btn, 12)
		stroke(btn, self.Theme.Stroke, 1.2, 0.45)
		padding(btn, 12)
		gradient(btn, 90, self.Theme.Control, Color3.fromRGB(self.Theme.Control.R + 2, self.Theme.Control.G + 2, self.Theme.Control.B + 6))
		
		local btnLayout = list(btn, Enum.FillDirection.Horizontal, 10, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
		
		local emojiLbl = create("TextLabel", {
			BackgroundTransparency = 1,
			Text = emoji or "📦",
			Font = self.Theme.Font,
			TextSize = 22,
			Size = UDim2.fromOffset(32, 32),
			Parent = btn
		})
		
		local nameLbl = create("TextLabel", {
			BackgroundTransparency = 1,
			Text = name,
			TextColor3 = self.Theme.Text,
			Font = self.Theme.Font,
			TextSize = 15,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, -42, 1, 0),
			Parent = btn
		})
		
		btn.MouseEnter:Connect(function()
			if not btn:FindFirstChild("Selected") then
				tween(btn, 0.14, {BackgroundColor3 = self.Theme.ControlHover})
			end
		end)
		btn.MouseLeave:Connect(function()
			if not btn:FindFirstChild("Selected") then
				tween(btn, 0.14, {BackgroundColor3 = self.Theme.Control})
			end
		end)
		
		local page = create("ScrollingFrame", {
			Name = name .. "_Page",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 7,
			ScrollBarImageTransparency = 0.35,
			Size = UDim2.fromScale(1,1),
			CanvasSize = UDim2.fromOffset(0,0),
			Visible = false,
			Parent = self.Pages
		})
		padding(page, self.Theme.Pad + 4)
		local lay = list(page, Enum.FillDirection.Vertical, 14)
		autoCanvas(page)
		
		local tab = {Button = btn, Page = page, Sections = {}}
		
		function tab:AddSection(title_)
			local sec = create("Frame", {
				BackgroundColor3 = self.Theme.Control,
				BackgroundTransparency = 0.2,
				Size = UDim2.new(1, 0, 0, 10),
				AutomaticSize = Enum.AutomaticSize.Y,
				Parent = page
			})
			round(sec, 14)
			stroke(sec, self.Theme.Stroke, 1.3, 0.5)
			padding(sec, 16)
			gradient(sec, 135, Color3.fromRGB(self.Theme.Control.R + 3, self.Theme.Control.G + 3, self.Theme.Control.B + 8), self.Theme.Control)
			
			local header = create("TextLabel", {
				BackgroundTransparency = 1,
				Text = title_,
				TextColor3 = self.Theme.Accent,
				Font = self.Theme.Font,
				TextSize = 17,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1,0,0,22),
				Parent = sec
			})
			
			local underline = create("Frame", {
				BackgroundColor3 = self.Theme.Accent,
				BackgroundTransparency = 0.6,
				Position = UDim2.new(0,0,0,26),
				Size = UDim2.new(0, 60, 0, 2),
				Parent = sec
			})
			round(underline, 1)
			
			local content = create("Frame", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0,0,0,36),
				Size = UDim2.new(1,0,1,-36),
				AutomaticSize = Enum.AutomaticSize.Y,
				Parent = sec
			})
			list(content, Enum.FillDirection.Vertical, 12)
			
			local section = {}
			
			function section:AddLabel(text)
				local l = create("TextLabel", {
					BackgroundTransparency = 1,
					Text = text,
					TextColor3 = self.Theme.SubText,
					Font = self.Theme.FontRegular,
					TextSize = 14,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					AutomaticSize = Enum.AutomaticSize.Y,
					Size = UDim2.new(1,0,0,0),
					Parent = content
				})
				return l
			end
			
			function section:AddParagraph(title, text)
				local wrap = create("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1,0,0,0),
					AutomaticSize = Enum.AutomaticSize.Y,
					Parent = content
				})
				list(wrap, Enum.FillDirection.Vertical, 6)
				
				local t = create("TextLabel", {
					BackgroundTransparency = 1,
					Text = title,
					TextColor3 = self.Theme.Text,
					Font = self.Theme.Font,
					TextSize = 15,
					TextXAlignment = Enum.TextXAlignment.Left,
					AutomaticSize = Enum.AutomaticSize.Y,
					Size = UDim2.new(1,0,0,0),
					Parent = wrap
				})
				
				local c = create("TextLabel", {
					BackgroundTransparency = 1,
					Text = text,
					TextColor3 = self.Theme.SubText,
					Font = self.Theme.FontRegular,
					TextSize = 13,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					AutomaticSize = Enum.AutomaticSize.Y,
					Size = UDim2.new(1,0,0,0),
					Parent = wrap
				})
				return wrap
			end
			
			function section:AddButton(text, cb)
				local b = create("TextButton", {
					BackgroundColor3 = self.Theme.Control,
					AutoButtonColor = false,
					Text = text,
					TextColor3 = self.Theme.Text,
					Font = self.Theme.Font,
					TextSize = 15,
					Size = UDim2.new(1,0,0,48),
					Parent = content
				})
				round(b, 12)
				stroke(b, self.Theme.Stroke, 1.2, 0.5)
				gradient(b, 90, Color3.fromRGB(self.Theme.Control.R + 4, self.Theme.Control.G + 4, self.Theme.Control.B + 8), self.Theme.Control)
				
				b.MouseEnter:Connect(function()
					tween(b, 0.14, {BackgroundColor3 = self.Theme.ControlHover})
				end)
				b.MouseLeave:Connect(function()
					tween(b, 0.14, {BackgroundColor3 = self.Theme.Control})
				end)
				b.MouseButton1Click:Connect(function()
					ripple(b, b.AbsoluteSize.X/2, b.AbsoluteSize.Y/2)
					tween(b, 0.1, {BackgroundColor3 = self.Theme.Accent})
					task.delay(0.12, function()
						if b.Parent then tween(b, 0.18, {BackgroundColor3 = self.Theme.Control}) end
					end)
					task.spawn(function() pcall(cb) end)
				end)
				return b
			end
			
			function section:AddToggle(id, text, default, cb)
				self.State[id] = self.State[id] ~= nil and self.State[id] or default
				
				local row = create("Frame", {
					BackgroundColor3 = self.Theme.Control,
					BackgroundTransparency = 0.3,
					Size = UDim2.new(1,0,0,52),
					Parent = content
				})
				round(row, 12)
				stroke(row, self.Theme.Stroke, 1.2, 0.55)
				padding(row, 14)
				gradient(row, 90, Color3.fromRGB(self.Theme.Control.R + 2, self.Theme.Control.G + 2, self.Theme.Control.B + 5), self.Theme.Control)
				
				local lbl = create("TextLabel", {
					BackgroundTransparency = 1,
					Text = text,
					TextColor3 = self.Theme.Text,
					Font = self.Theme.Font,
					TextSize = 15,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = UDim2.new(1, -70, 1, 0),
					Parent = row
				})
				
				local box = create("TextButton", {
					BackgroundColor3 = self.Theme.Panel,
					AutoButtonColor = false,
					Text = "",
					Size = UDim2.fromOffset(54, 28),
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -6, 0.5, 0),
					Parent = row
				})
				round(box, 14)
				stroke(box, self.Theme.Stroke, 1.3, 0.5)
				
				local knob = create("Frame", {
					BackgroundColor3 = self.Theme.SubText,
					Size = UDim2.fromOffset(22, 22),
					Position = UDim2.new(0, 3, 0.5, 0),
					AnchorPoint = Vector2.new(0, 0.5),
					Parent = box
				})
				round(knob, 11)
				
				local glowKnob = glow(knob, self.Theme.Accent, 30)
				glowKnob.ImageTransparency = 1
				
				local function apply(state)
					self.State[id] = state
					if state then
						tweenElastic(knob, 0.4, {Position = UDim2.new(1, -25, 0.5, 0), BackgroundColor3 = self.Theme.Accent})
						tween(glowKnob, 0.3, {ImageTransparency = 0.4})
					else
						tween(knob, 0.25, {Position = UDim2.new(0, 3, 0.5, 0), BackgroundColor3 = self.Theme.SubText})
						tween(glowKnob, 0.3, {ImageTransparency = 1})
					end
					task.spawn(function() pcall(cb, state) end)
				end
				
				box.MouseButton1Click:Connect(function()
					ripple(box, box.AbsoluteSize.X/2, box.AbsoluteSize.Y/2)
					apply(not self.State[id])
				end)
				
				apply(self.State[id])
				return row
			end
			
			function section:AddSlider(id, text, minV, maxV, step, default, cb)
				self.State[id] = self.State[id] ~= nil and self.State[id] or default
				
				local row = create("Frame", {
					BackgroundColor3 = self.Theme.Control,
					BackgroundTransparency = 0.3,
					Size = UDim2.new(1,0,0,68),
					Parent = content
				})
				round(row, 12)
				stroke(row, self.Theme.Stroke, 1.2, 0.55)
				padding(row, 14)
				gradient(row, 90, Color3.fromRGB(self.Theme.Control.R + 2, self.Theme.Control.G + 2, self.Theme.Control.B + 5), self.Theme.Control)
				
				local lbl = create("TextLabel", {
					BackgroundTransparency = 1,
					Text = text,
					TextColor3 = self.Theme.Text,
					Font = self.Theme.Font,
					TextSize = 15,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = UDim2.new(1, -100, 0, 20),
					Parent = row
				})
				
				local valLbl = create("TextLabel", {
					BackgroundTransparency = 1,
					Text = tostring(self.State[id]),
					TextColor3 = self.Theme.Accent,
					Font = self.Theme.Font,
					TextSize = 15,
					TextXAlignment = Enum.TextXAlignment.Right,
					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.new(1, 0, 0, 0),
					Size = UDim2.new(0, 90, 0, 20),
					Parent = row
				})
				
				local bar = create("Frame", {
					BackgroundColor3 = self.Theme.Panel,
					Position = UDim2.new(0,0,0,32),
					Size = UDim2.new(1,0,0,20),
					Parent = row
				})
				round(bar, 10)
				stroke(bar, self.Theme.Stroke, 1.2, 0.6)
				
				local fill = create("Frame", {
					BackgroundColor3 = self.Theme.Accent,
					Size = UDim2.new(0,0,1,0),
					Parent = bar
				})
				round(fill, 10)
				gradient(fill, 90, self.Theme.Accent, self.Theme.Accent2)
				
				local fillGlow = glow(fill, self.Theme.AccentGlow, 40)
				fillGlow.ImageTransparency = 0.5
				
				local dragging = false
				
				local function quantize(x)
					local s = step
					local v = math.clamp(x, minV, maxV)
					return math.floor((v - minV) / s + 0.5) * s + minV
				end
				
				local function setValue(v, silent)
					v = quantize(v)
					self.State[id] = v
					valLbl.Text = tostring(v)
					local a = (v - minV) / (maxV - minV)
					tween(fill, 0.12, {Size = UDim2.new(a, 0, 1, 0)})
					if not silent then task.spawn(function() pcall(cb, v) end) end
				end
				
				local function readFromInput(inputPosX)
					local x = inputPosX - bar.AbsolutePosition.X
					local a = math.clamp(x / bar.AbsoluteSize.X, 0, 1)
					local v = minV + (maxV - minV) * a
					setValue(v, false)
				end
				
				bar.InputBegan:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
						dragging = true
						readFromInput(inp.Position.X)
					end
				end)
				bar.InputEnded:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
						dragging = false
					end
				end)
				UserInputService.InputChanged:Connect(function(inp)
					if not dragging then return end
					if inp.UserInputType ~= Enum.UserInputType.MouseMovement and inp.UserInputType == Enum.UserInputType.Touch then return end
					readFromInput(inp.Position.X)
				end)
				
				setValue(self.State[id], true)
				return row
			end
			
			function section:AddTextbox(id, text, placeholder, default, cb)
				self.State[id] = self.State[id] ~= nil and self.State[id] or default
				
				local row = create("Frame", {
					BackgroundColor3 = self.Theme.Control,
					BackgroundTransparency = 0.3,
					Size = UDim2.new(1,0,0,52),
					Parent = content
				})
				round(row, 12)
				stroke(row, self.Theme.Stroke, 1.2, 0.55)
				padding(row, 14)
				gradient(row, 90, Color3.fromRGB(self.Theme.Control.R + 2, self.Theme.Control.G + 2, self.Theme.Control.B + 5), self.Theme.Control)
				
				local lbl = create("TextLabel", {
					BackgroundTransparency = 1,
					Text = text,
					TextColor3 = self.Theme.Text,
					Font = self.Theme.Font,
					TextSize = 15,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = UDim2.new(0.42,0,1,0),
					Parent = row
				})
				
				local tb = create("TextBox", {
					BackgroundColor3 = self.Theme.Panel,
					Text = self.State[id],
					PlaceholderText = placeholder,
					TextColor3 = self.Theme.Text,
					PlaceholderColor3 = self.Theme.SubText,
					Font = self.Theme.FontRegular,
					TextSize = 14,
					ClearTextOnFocus = false,
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -6, 0.5, 0),
					Size = UDim2.new(0.54, -8, 0, 34),
					Parent = row
				})
				round(tb, 10)
				stroke(tb, self.Theme.Stroke, 1.2, 0.6)
				
				tb.Focused:Connect(function()
					tween(tb, 0.2, {BackgroundColor3 = self.Theme.ControlActive})
				end)
				tb.FocusLost:Connect(function()
					tween(tb, 0.2, {BackgroundColor3 = self.Theme.Panel})
					self.State[id] = tb.Text
					task.spawn(function() pcall(cb, tb.Text) end)
				end)
				
				return row
			end
			
			function section:AddKeybind(id, text, defaultKey, cb)
				local keyName = self.State[id] or defaultKey.Name
				self.State[id] = keyName
				
				local row = create("Frame", {
					BackgroundColor3 = self.Theme.Control,
					BackgroundTransparency = 0.3,
					Size = UDim2.new(1,0,0,52),
					Parent = content
				})
				round(row, 12)
				stroke(row, self.Theme.Stroke, 1.2, 0.55)
				padding(row, 14)
				gradient(row, 90, Color3.fromRGB(self.Theme.Control.R + 2, self.Theme.Control.G + 2, self.Theme.Control.B + 5), self.Theme.Control)
				
				local lbl = create("TextLabel", {
					BackgroundTransparency = 1,
					Text = text,
					TextColor3 = self.Theme.Text,
					Font = self.Theme.Font,
					TextSize = 15,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = UDim2.new(0.55,0,1,0),
					Parent = row
				})
				
				local btn = create("TextButton", {
					BackgroundColor3 = self.Theme.Panel,
					AutoButtonColor = false,
					Text = keyName,
					TextColor3 = self.Theme.SubText,
					Font = self.Theme.Font,
					TextSize = 14,
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -6, 0.5, 0),
					Size = UDim2.new(0.40, -8, 0, 34),
					Parent = row
				})
				round(btn, 10)
				stroke(btn, self.Theme.Stroke, 1.2, 0.6)
				
				local listening = false
				local function bindKey(k)
					for key, _ in pairs(self.Keybinds) do
						if key == self.State[id] then
							self.Keybinds[key] = nil
						end
					end
					self.State[id] = k
					btn.Text = k
					btn.TextColor3 = self.Theme.SubText
					self.Keybinds[k] = cb
				end
				
				self.Keybinds[keyName] = cb
				
				btn.MouseButton1Click:Connect(function()
					if listening then return end
					listening = true
					btn.Text = "..."
					btn.TextColor3 = self.Theme.Accent
					ripple(btn, btn.AbsoluteSize.X/2, btn.AbsoluteSize.Y/2)
					
					local conn; conn = UserInputService.InputBegan:Connect(function(inp, gp)
						if gp then return end
						if inp.UserInputType == Enum.UserInputType.Keyboard then
							conn:Disconnect()
							listening = false
							bindKey(inp.KeyCode.Name)
						end
					end)
				end)
				
				return row
			end
			
			function section:AddDropdown(id, text, options, default, cb)
				self.State[id] = self.State[id] or default
				
				local open = false
				
				local wrap = create("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1,0,0,52),
					Parent = content
				})
				
				local row = create("Frame", {
					BackgroundColor3 = self.Theme.Control,
					BackgroundTransparency = 0.3,
					Size = UDim2.new(1,0,0,52),
					Parent = wrap
				})
				round(row, 12)
				stroke(row, self.Theme.Stroke, 1.2, 0.55)
				padding(row, 14)
				gradient(row, 90, Color3.fromRGB(self.Theme.Control.R + 2, self.Theme.Control.G + 2, self.Theme.Control.B + 5), self.Theme.Control)
				
				local lbl = create("TextLabel", {
					BackgroundTransparency = 1,
					Text = text,
					TextColor3 = self.Theme.Text,
					Font = self.Theme.Font,
					TextSize = 15,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = UDim2.new(0.50,0,1,0),
					Parent = row
				})
				
				local btn = create("TextButton", {
					BackgroundColor3 = self.Theme.Panel,
					AutoButtonColor = false,
					Text = self.State[id],
					TextColor3 = self.Theme.SubText,
					Font = self.Theme.FontRegular,
					TextSize = 14,
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -6, 0.5, 0),
					Size = UDim2.new(0.46, -8, 0, 34),
					Parent = row
				})
				round(btn, 10)
				stroke(btn, self.Theme.Stroke, 1.2, 0.6)
				
				local arrow = create("TextLabel", {
					BackgroundTransparency = 1,
					Text = "▼",
					TextColor3 = self.Theme.SubText,
					Font = self.Theme.Font,
					TextSize = 12,
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -8, 0.5, 0),
					Size = UDim2.fromOffset(16, 16),
					Parent = btn
				})
				
				local list = create("Frame", {
					BackgroundColor3 = self.Theme.Panel,
					Size = UDim2.new(1, 0, 0, 0),
					Position = UDim2.new(0, 0, 0, 58),
					ClipsDescendants = true,
					Visible = false,
					Parent = wrap
				})
				round(list, 12)
				stroke(list, self.Theme.Stroke, 1.2, 0.5)
				
				local listContent = create("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					Parent = list
				})
				padding(listContent, 8)
				list(listContent, Enum.FillDirection.Vertical, 6)
				
				for _, opt in ipairs(options) do
					local optBtn = create("TextButton", {
						BackgroundColor3 = self.Theme.Control,
						AutoButtonColor = false,
						Text = opt,
						TextColor3 = self.Theme.Text,
						Font = self.Theme.FontRegular,
						TextSize = 14,
						Size = UDim2.new(1, 0, 0, 36),
						Parent = listContent
					})
					round(optBtn, 10)
					
					optBtn.MouseEnter:Connect(function()
						tween(optBtn, 0.12, {BackgroundColor3 = self.Theme.ControlHover})
					end)
					optBtn.MouseLeave:Connect(function()
						tween(optBtn, 0.12, {BackgroundColor3 = self.Theme.Control})
					end)
					
					optBtn.MouseButton1Click:Connect(function()
						self.State[id] = opt
						btn.Text = opt
						ripple(optBtn, optBtn.AbsoluteSize.X/2, optBtn.AbsoluteSize.Y/2)
						task.spawn(function() pcall(cb, opt) end)
						
						open = false
						list.Visible = false
						tween(list, 0.2, {Size = UDim2.new(1, 0, 0, 0)})
						tween(arrow, 0.2, {Rotation = 0})
						tween(wrap, 0.2, {Size = UDim2.new(1, 0, 0, 52)})
					end)
				end
				
				local targetHeight = #options * 42 + 16
				
				btn.MouseButton1Click:Connect(function()
					open = not open
					ripple(btn, btn.AbsoluteSize.X/2, btn.AbsoluteSize.Y/2)
					if open then
						list.Visible = true
						tweenElastic(list, 0.4, {Size = UDim2.new(1, 0, 0, targetHeight)})
						tween(arrow, 0.2, {Rotation = 180})
						tween(wrap, 0.2, {Size = UDim2.new(1, 0, 0, 58 + targetHeight)})
					else
						tween(list, 0.2, {Size = UDim2.new(1, 0, 0, 0)})
						tween(arrow, 0.2, {Rotation = 0})
						tween(wrap, 0.2, {Size = UDim2.new(1, 0, 0, 52)})
						task.delay(0.25, function()
							list.Visible = false
						end)
					end
				end)
				
				return wrap
			end
			
			function section:AddColorPicker(id, text, default, cb)
				self.State[id] = self.State[id] or default
				
				local row = create("Frame", {
					BackgroundColor3 = self.Theme.Control,
					BackgroundTransparency = 0.3,
					Size = UDim2.new(1,0,0,52),
					Parent = content
				})
				round(row, 12)
				stroke(row, self.Theme.Stroke, 1.2, 0.55)
				padding(row, 14)
				gradient(row, 90, Color3.fromRGB(self.Theme.Control.R + 2, self.Theme.Control.G + 2, self.Theme.Control.B + 5), self.Theme.Control)
				
				local lbl = create("TextLabel", {
					BackgroundTransparency = 1,
					Text = text,
					TextColor3 = self.Theme.Text,
					Font = self.Theme.Font,
					TextSize = 15,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = UDim2.new(0.65,0,1,0),
					Parent = row
				})
				
				local preview = create("Frame", {
					BackgroundColor3 = self.State[id],
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -6, 0.5, 0),
					Size = UDim2.fromOffset(50, 34),
					Parent = row
				})
				round(preview, 10)
				stroke(preview, self.Theme.Stroke, 1.2, 0.4)
				
				return row
			end
			
			function section:AddDivider()
				local div = create("Frame", {
					BackgroundColor3 = self.Theme.Stroke,
					BackgroundTransparency = 0.5,
					Size = UDim2.new(1, 0, 0, 2),
					Parent = content
				})
				round(div, 1)
				return div
			end
			
			return section
		end
		
		btn.MouseButton1Click:Connect(function()
			self:SelectTab(tab)
		end)
		
		table.insert(self.Tabs, tab)
		if #self.Tabs == 1 then
			self:SelectTab(tab)
			btn.BackgroundColor3 = self.Theme.ControlActive
			nameLbl.TextColor3 = self.Theme.Accent
		end
		
		return tab
	end
	
	return window
end

function Ananaser:MakeWindow(config)
	return newWindow(config)
end

return setmetatable({}, Ananaser)
