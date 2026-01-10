--!strict
-- AnanaserUI.lua (single-file starter library)
-- Put in a LocalScript / ModuleScript inside your experience.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Ananaser = {}
Ananaser.__index = Ananaser

-- ========= Theme =========
local DefaultTheme = {
	Name = "Ananaser Dark",
	Font = Enum.Font.Gotham,
	FontBold = Enum.Font.GothamBold,

	BG = Color3.fromRGB(14, 14, 18),
	Panel = Color3.fromRGB(18, 18, 24),
	Topbar = Color3.fromRGB(20, 20, 28),
	Stroke = Color3.fromRGB(60, 60, 80),

	Text = Color3.fromRGB(235, 235, 245),
	SubText = Color3.fromRGB(170, 170, 185),

	Accent = Color3.fromRGB(255, 196, 0), -- "ананас"
	Accent2 = Color3.fromRGB(255, 128, 0),

	Control = Color3.fromRGB(26, 26, 36),
	ControlHover = Color3.fromRGB(32, 32, 46),

	Radius = 10,
	Pad = 10,

	TweenTime = 0.18,
	EaseStyle = Enum.EasingStyle.Quint,
	EaseDir = Enum.EasingDirection.Out,
}

-- ========= Utils =========
local function create(className: string, props: {[string]: any}?)
	local inst = Instance.new(className)
	if props then
		for k,v in pairs(props) do
			(inst :: any)[k] = v
		end
	end
	return inst
end

local function tween(obj: Instance, time_: number?, props: {[string]: any})
	local t = time_ or DefaultTheme.TweenTime
	local info = TweenInfo.new(t, DefaultTheme.EaseStyle, DefaultTheme.EaseDir)
	local tw = TweenService:Create(obj, info, props)
	tw:Play()
	return tw
end

local function round(parent: Instance, r: number)
	return create("UICorner", {CornerRadius = UDim.new(0, r), Parent = parent})
end

local function stroke(parent: Instance, c: Color3, th: number, tr: number?)
	local s = create("UIStroke", {
		Color = c,
		Thickness = th,
		Transparency = tr or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = parent
	})
	return s
end

local function padding(parent: Instance, p: number)
	return create("UIPadding", {
		PaddingLeft = UDim.new(0, p),
		PaddingRight = UDim.new(0, p),
		PaddingTop = UDim.new(0, p),
		PaddingBottom = UDim.new(0, p),
		Parent = parent
	})
end

local function list(parent: Instance, dir: Enum.FillDirection, padPx: number, align: Enum.HorizontalAlignment?, vAlign: Enum.VerticalAlignment?)
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

local function autoCanvas(frame: ScrollingFrame)
	local layout = frame:FindFirstChildOfClass("UIListLayout")
	if not layout then return end
	local function upd()
		frame.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 12)
	end
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(upd)
	upd()
end

-- ========= Drag =========
local function makeDraggable(handle: GuiObject, root: GuiObject)
	local dragging = false
	local dragStart: Vector2? = nil
	local startPos: UDim2? = nil

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

-- ========= Main =========
type Window = {
	ScreenGui: ScreenGui,
	Root: Frame,
	Pages: Frame,
	TabBar: ScrollingFrame,
	NotifyLayer: Frame,

	Theme: typeof(DefaultTheme),
	Tabs: {any},
	State: {[string]: any},
	Keybinds: {[string]: ()->()},

	SelectTab: (self: any, tab: any) -> (),
	MakeNotification: (self: any, title: string, content: string, t: number?) -> (),
	ExportConfig: (self: any) -> string,
	ImportConfig: (self: any, json: string) -> (),
}

local function newWindow(config: {[string]: any}?): Window
	config = config or {}

	local theme = table.clone(DefaultTheme)
	if config.Theme then
		for k,v in pairs(config.Theme) do
			(theme :: any)[k] = v
		end
	end

	local title = config.Title or "Ananaser Hub"
	local subtitle = config.Subtitle or "Custom UI Library"

	local sg = create("ScreenGui", {
		Name = "AnanaserHubUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
		Parent = PlayerGui
	})

	local overlay = create("Frame", {
		Name = "Overlay",
		BackgroundColor3 = theme.BG,
		BackgroundTransparency = 0.15,
		Size = UDim2.fromScale(1,1),
		Parent = sg
	})

	local root = create("Frame", {
		Name = "Root",
		BackgroundColor3 = theme.Panel,
		Size = UDim2.fromOffset(720, 430),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Parent = overlay
	})
	round(root, theme.Radius)
	stroke(root, theme.Stroke, 1, 0.35)

	local topbar = create("Frame", {
		Name = "Topbar",
		BackgroundColor3 = theme.Topbar,
		Size = UDim2.new(1, 0, 0, 52),
		Parent = root
	})
	round(topbar, theme.Radius)
	padding(topbar, theme.Pad)

	local topLayout = list(topbar, Enum.FillDirection.Horizontal, 10, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)

	local titleWrap = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -140, 1, 0),
		Parent = topbar
	})

	local titleLbl = create("TextLabel", {
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = theme.Text,
		Font = theme.FontBold,
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1,0,0,22),
		Parent = titleWrap
	})

	local subLbl = create("TextLabel", {
		BackgroundTransparency = 1,
		Text = subtitle,
		TextColor3 = theme.SubText,
		Font = theme.Font,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0,0,0,22),
		Size = UDim2.new(1,0,0,18),
		Parent = titleWrap
	})

	local btnWrap = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 140, 1, 0),
		Parent = topbar
	})
	local btnLayout = list(btnWrap, Enum.FillDirection.Horizontal, 8, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)

	local function iconButton(text: string)
		local b = create("TextButton", {
			BackgroundColor3 = theme.Control,
			AutoButtonColor = false,
			Text = text,
			TextColor3 = theme.Text,
			Font = theme.FontBold,
			TextSize = 14,
			Size = UDim2.fromOffset(38, 32),
			Parent = btnWrap
		})
		round(b, 8)
		stroke(b, theme.Stroke, 1, 0.55)
		b.MouseEnter:Connect(function() tween(b, 0.12, {BackgroundColor3 = theme.ControlHover}) end)
		b.MouseLeave:Connect(function() tween(b, 0.12, {BackgroundColor3 = theme.Control}) end)
		return b
	end

	local minimizeBtn = iconButton("—")
	local closeBtn = iconButton("X")

	local body = create("Frame", {
		Name = "Body",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, -52),
		Position = UDim2.new(0,0,0,52),
		Parent = root
	})

	local sidebar = create("Frame", {
		Name = "Sidebar",
		BackgroundColor3 = theme.Panel,
		Size = UDim2.new(0, 200, 1, 0),
		Parent = body
	})
	padding(sidebar, theme.Pad)

	local tabBar = create("ScrollingFrame", {
		Name = "TabBar",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageTransparency = 0.35,
		Size = UDim2.new(1, 0, 1, 0),
		CanvasSize = UDim2.fromOffset(0,0),
		Parent = sidebar
	})
	local tabList = list(tabBar, Enum.FillDirection.Vertical, 8)
	autoCanvas(tabBar)

	local pages = create("Frame", {
		Name = "Pages",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -200, 1, 0),
		Position = UDim2.new(0, 200, 0, 0),
		Parent = body
	})

	local notifyLayer = create("Frame", {
		Name = "NotifyLayer",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1,1),
		Parent = overlay
	})

	-- Mobile: shrink default size on small screens
	local function adapt()
		local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
		local w = math.clamp(vp.X * 0.92, 340, 760)
		local h = math.clamp(vp.Y * 0.72, 300, 520)
		root.Size = UDim2.fromOffset(w, h)
	end
	adapt()
	if workspace.CurrentCamera then
		workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(adapt)
	end

	makeDraggable(topbar, root)

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
	} :: any

	local minimized = false
	minimizeBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			tween(body, 0.2, {Size = UDim2.new(1,0,0,0)})
			tween(root, 0.2, {Size = UDim2.fromOffset(root.AbsoluteSize.X, 52)})
		else
			adapt()
			tween(body, 0.2, {Size = UDim2.new(1,0,1,-52)})
		end
	end)

	closeBtn.MouseButton1Click:Connect(function()
		sg:Destroy()
	end)

	function window:MakeNotification(t_: string, c_: string, time_: number?)
		local t = time_ or 3

		local card = create("Frame", {
			BackgroundColor3 = self.Theme.Panel,
			Size = UDim2.fromOffset(320, 86),
			Position = UDim2.new(1, -20, 1, -20),
			AnchorPoint = Vector2.new(1, 1),
			Parent = self.NotifyLayer
		})
		round(card, 12)
		stroke(card, self.Theme.Stroke, 1, 0.45)
		padding(card, 12)

		local tl = create("TextLabel", {
			BackgroundTransparency = 1,
			Text = t_,
			TextColor3 = self.Theme.Text,
			Font = self.Theme.FontBold,
			TextSize = 15,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1,0,0,18),
			Parent = card
		})

		local cl = create("TextLabel", {
			BackgroundTransparency = 1,
			Text = c_,
			TextColor3 = self.Theme.SubText,
			Font = self.Theme.Font,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			Position = UDim2.new(0,0,0,22),
			Size = UDim2.new(1,0,1,-22),
			Parent = card
		})

		card.BackgroundTransparency = 1
		tween(card, 0.18, {BackgroundTransparency = 0})
		task.delay(t, function()
			if card.Parent then
				tween(card, 0.18, {BackgroundTransparency = 1})
				task.wait(0.2)
				if card.Parent then card:Destroy() end
			end
		end)
	end

	function window:SelectTab(tab)
		for _,t in ipairs(self.Tabs) do
			t.Button.BackgroundColor3 = self.Theme.Control
			t.Page.Visible = false
		end
		tab.Button.BackgroundColor3 = self.Theme.ControlHover
		tab.Page.Visible = true
	end

	-- Config export/import (state only; you decide where to store it)
	function window:ExportConfig(): string
		return HttpService:JSONEncode(self.State)
	end
	function window:ImportConfig(json: string)
		local ok, data = pcall(function() return HttpService:JSONDecode(json) end)
		if ok and typeof(data) == "table" then
			self.State = data
			-- Controls should read state on refresh; you can also broadcast an event here.
		end
	end

	-- Global keybind handler
	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.UserInputType == Enum.UserInputType.Keyboard then
			local key = input.KeyCode.Name
			local fn = window.Keybinds[key]
			if fn then pcall(fn) end
		end
	end)

	-- Public: create tab
	function window:MakeTab(name: string)
		local btn = create("TextButton", {
			BackgroundColor3 = self.Theme.Control,
			AutoButtonColor = false,
			Text = name,
			TextColor3 = self.Theme.Text,
			Font = self.Theme.FontBold,
			TextSize = 14,
			Size = UDim2.new(1,0,0,40),
			Parent = self.TabBar
		})
		round(btn, 10)
		stroke(btn, self.Theme.Stroke, 1, 0.55)

		btn.MouseEnter:Connect(function() tween(btn, 0.12, {BackgroundColor3 = self.Theme.ControlHover}) end)
		btn.MouseLeave:Connect(function()
			-- if selected stays hover; simplest approach: reapply selection after
			-- but for now keep it subtle:
			tween(btn, 0.12, {BackgroundColor3 = self.Theme.Control})
		end)

		local page = create("ScrollingFrame", {
			Name = name .. "_Page",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 6,
			ScrollBarImageTransparency = 0.4,
			Size = UDim2.fromScale(1,1),
			CanvasSize = UDim2.fromOffset(0,0),
			Visible = false,
			Parent = self.Pages
		})
		padding(page, self.Theme.Pad)
		local lay = list(page, Enum.FillDirection.Vertical, 10)
		autoCanvas(page)

		local tab = {Button = btn, Page = page, Sections = {}} :: any

		function tab:AddSection(title_: string)
			local sec = create("Frame", {
				BackgroundColor3 = self.Theme.Panel,
				Size = UDim2.new(1, 0, 0, 10), -- will autosize via layout if you want; leaving fixed-ish
				AutomaticSize = Enum.AutomaticSize.Y,
				Parent = page
			})
			round(sec, 12)
			stroke(sec, self.Theme.Stroke, 1, 0.6)
			padding(sec, 12)

			local header = create("TextLabel", {
				BackgroundTransparency = 1,
				Text = title_,
				TextColor3 = self.Theme.Text,
				Font = self.Theme.FontBold,
				TextSize = 15,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1,0,0,18),
				Parent = sec
			})

			local content = create("Frame", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0,0,0,24),
				Size = UDim2.new(1,0,1,-24),
				AutomaticSize = Enum.AutomaticSize.Y,
				Parent = sec
			})
			list(content, Enum.FillDirection.Vertical, 8)
			create("UIListLayout", {Parent = content}) -- (keep stable ordering)

			local section = {} :: any

			function section:AddLabel(text: string)
				local l = create("TextLabel", {
					BackgroundTransparency = 1,
					Text = text,
					TextColor3 = self.Theme.SubText,
					Font = self.Theme.Font,
					TextSize = 13,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					AutomaticSize = Enum.AutomaticSize.Y,
					Size = UDim2.new(1,0,0,0),
					Parent = content
				})
				return l
			end

			function section:AddButton(text: string, cb: ()->() )
				local b = create("TextButton", {
					BackgroundColor3 = self.Theme.Control,
					AutoButtonColor = false,
					Text = text,
					TextColor3 = self.Theme.Text,
					Font = self.Theme.FontBold,
					TextSize = 14,
					Size = UDim2.new(1,0,0,40),
					Parent = content
				})
				round(b, 10)
				stroke(b, self.Theme.Stroke, 1, 0.55)

				b.MouseEnter:Connect(function() tween(b, 0.12, {BackgroundColor3 = self.Theme.ControlHover}) end)
				b.MouseLeave:Connect(function() tween(b, 0.12, {BackgroundColor3 = self.Theme.Control}) end)
				b.MouseButton1Click:Connect(function()
					tween(b, 0.08, {BackgroundColor3 = self.Theme.Accent})
					task.delay(0.09, function()
						if b.Parent then tween(b, 0.14, {BackgroundColor3 = self.Theme.Control}) end
					end)
					task.spawn(function() pcall(cb) end)
				end)
				return b
			end

			function section:AddToggle(id: string, text: string, default: boolean, cb: (boolean)->() )
				self.State[id] = self.State[id] ~= nil and self.State[id] or default

				local row = create("Frame", {
					BackgroundColor3 = self.Theme.Control,
					Size = UDim2.new(1,0,0,40),
					Parent = content
				})
				round(row, 10)
				stroke(row, self.Theme.Stroke, 1, 0.55)
				padding(row, 10)

				local lbl = create("TextLabel", {
					BackgroundTransparency = 1,
					Text = text,
					TextColor3 = self.Theme.Text,
					Font = self.Theme.FontBold,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = UDim2.new(1, -60, 1, 0),
					Parent = row
				})

				local box = create("TextButton", {
					BackgroundColor3 = self.Theme.Panel,
					AutoButtonColor = false,
					Text = "",
					Size = UDim2.fromOffset(46, 24),
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -6, 0.5, 0),
					Parent = row
				})
				round(box, 12)
				stroke(box, self.Theme.Stroke, 1, 0.55)

				local knob = create("Frame", {
					BackgroundColor3 = self.Theme.SubText,
					Size = UDim2.fromOffset(18, 18),
					Position = UDim2.new(0, 3, 0.5, 0),
					AnchorPoint = Vector2.new(0, 0.5),
					Parent = box
				})
				round(knob, 9)

				local function apply(state: boolean)
					self.State[id] = state
					if state then
						tween(knob, 0.14, {Position = UDim2.new(1, -21, 0.5, 0), BackgroundColor3 = self.Theme.Accent})
					else
						tween(knob, 0.14, {Position = UDim2.new(0, 3, 0.5, 0), BackgroundColor3 = self.Theme.SubText})
					end
					task.spawn(function() pcall(cb, state) end)
				end

				box.MouseButton1Click:Connect(function()
					apply(not self.State[id])
				end)

				apply(self.State[id])
				return row
			end

			function section:AddSlider(id: string, text: string, minV: number, maxV: number, step: number, default: number, cb: (number)->() )
				self.State[id] = self.State[id] ~= nil and self.State[id] or default

				local row = create("Frame", {
					BackgroundColor3 = self.Theme.Control,
					Size = UDim2.new(1,0,0,54),
					Parent = content
				})
				round(row, 10)
				stroke(row, self.Theme.Stroke, 1, 0.55)
				padding(row, 10)

				local lbl = create("TextLabel", {
					BackgroundTransparency = 1,
					Text = text,
					TextColor3 = self.Theme.Text,
					Font = self.Theme.FontBold,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = UDim2.new(1, -90, 0, 18),
					Parent = row
				})

				local valLbl = create("TextLabel", {
					BackgroundTransparency = 1,
					Text = tostring(self.State[id]),
					TextColor3 = self.Theme.SubText,
					Font = self.Theme.FontBold,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Right,
					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.new(1, 0, 0, 0),
					Size = UDim2.new(0, 80, 0, 18),
					Parent = row
				})

				local bar = create("Frame", {
					BackgroundColor3 = self.Theme.Panel,
					Position = UDim2.new(0,0,0,26),
					Size = UDim2.new(1,0,0,16),
					Parent = row
				})
				round(bar, 8)
				stroke(bar, self.Theme.Stroke, 1, 0.65)

				local fill = create("Frame", {
					BackgroundColor3 = self.Theme.Accent,
					Size = UDim2.new(0,0,1,0),
					Parent = bar
				})
				round(fill, 8)

				local dragging = false

				local function quantize(x: number)
					local s = step
					local v = math.clamp(x, minV, maxV)
					return math.floor((v - minV) / s + 0.5) * s + minV
				end

				local function setValue(v: number, silent: boolean?)
					v = quantize(v)
					self.State[id] = v
					valLbl.Text = tostring(v)
					local a = (v - minV) / (maxV - minV)
					tween(fill, 0.08, {Size = UDim2.new(a, 0, 1, 0)})
					if not silent then task.spawn(function() pcall(cb, v) end) end
				end

				local function readFromInput(inputPosX: number)
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
					if inp.UserInputType ~= Enum.UserInputType.MouseMovement and inp.UserInputType ~= Enum.UserInputType.Touch then return end
					readFromInput(inp.Position.X)
				end)

				setValue(self.State[id], true)
				return row
			end

			function section:AddTextbox(id: string, text: string, placeholder: string, default: string, cb: (string)->() )
				self.State[id] = self.State[id] ~= nil and self.State[id] or default

				local row = create("Frame", {
					BackgroundColor3 = self.Theme.Control,
					Size = UDim2.new(1,0,0,44),
					Parent = content
				})
				round(row, 10)
				stroke(row, self.Theme.Stroke, 1, 0.55)
				padding(row, 10)

				local lbl = create("TextLabel", {
					BackgroundTransparency = 1,
					Text = text,
					TextColor3 = self.Theme.Text,
					Font = self.Theme.FontBold,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = UDim2.new(0.48,0,1,0),
					Parent = row
				})

				local tb = create("TextBox", {
					BackgroundColor3 = self.Theme.Panel,
					Text = self.State[id],
					PlaceholderText = placeholder,
					TextColor3 = self.Theme.Text,
					PlaceholderColor3 = self.Theme.SubText,
					Font = self.Theme.Font,
					TextSize = 14,
					ClearTextOnFocus = false,
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -4, 0.5, 0),
					Size = UDim2.new(0.50, -6, 0, 28),
					Parent = row
				})
				round(tb, 8)
				stroke(tb, self.Theme.Stroke, 1, 0.65)

				tb.FocusLost:Connect(function()
					self.State[id] = tb.Text
					task.spawn(function() pcall(cb, tb.Text) end)
				end)

				return row
			end

			function section:AddKeybind(id: string, text: string, defaultKey: Enum.KeyCode, cb: ()->() )
				local keyName = (self.State[id] :: any) or defaultKey.Name
				self.State[id] = keyName

				local row = create("Frame", {
					BackgroundColor3 = self.Theme.Control,
					Size = UDim2.new(1,0,0,44),
					Parent = content
				})
				round(row, 10)
				stroke(row, self.Theme.Stroke, 1, 0.55)
				padding(row, 10)

				local lbl = create("TextLabel", {
					BackgroundTransparency = 1,
					Text = text,
					TextColor3 = self.Theme.Text,
					Font = self.Theme.FontBold,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = UDim2.new(0.60,0,1,0),
					Parent = row
				})

				local btn = create("TextButton", {
					BackgroundColor3 = self.Theme.Panel,
					AutoButtonColor = false,
					Text = keyName,
					TextColor3 = self.Theme.SubText,
					Font = self.Theme.FontBold,
					TextSize = 13,
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -4, 0.5, 0),
					Size = UDim2.new(0.36, -6, 0, 28),
					Parent = row
				})
				round(btn, 8)
				stroke(btn, self.Theme.Stroke, 1, 0.65)

				local listening = false
				local function bindKey(k: string)
					-- remove old binding
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

				-- apply initial
				self.Keybinds[keyName] = cb

				btn.MouseButton1Click:Connect(function()
					if listening then return end
					listening = true
					btn.Text = "Press..."
					btn.TextColor3 = self.Theme.Accent

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

			return section
		end

		btn.MouseButton1Click:Connect(function()
			self:SelectTab(tab)
		end)

		table.insert(self.Tabs, tab)
		-- select first
		if #self.Tabs == 1 then
			self:SelectTab(tab)
			btn.BackgroundColor3 = self.Theme.ControlHover
		end

		return tab
	end

	return window
end

function Ananaser:MakeWindow(config: {[string]: any}?): Window
	return newWindow(config)
end

return setmetatable({}, Ananaser)
