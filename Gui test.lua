local Library = {}
Library.Options = {}
Library.Keybinds = {}
Library.OpenFrames = {}
Library.Version = "1.0.0"

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = game:GetService("Workspace").CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local RenderStepped = RunService.RenderStepped
local Heartbeat = RunService.Heartbeat

local BaseGui = gethui and gethui() or game:GetService("CoreGui")
if not BaseGui then
	BaseGui = Instance.new("ScreenGui")
	BaseGui.DisplayOrder = 999
	BaseGui.ResetOnSpawn = false
	BaseGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	BaseGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

local Mobile = not RunService:IsStudio() and table.find({Enum.Platform.IOS, Enum.Platform.Android}, UserInputService:GetPlatform()) ~= nil

local Theme = {
	Name = "Dark",
	Accent = Color3.fromRGB(96, 205, 255),
	AcrylicMain = Color3.fromRGB(60, 60, 60),
	AcrylicBorder = Color3.fromRGB(90, 90, 90),
	AcrylicGradient = ColorSequence.new(Color3.fromRGB(40, 40, 40), Color3.fromRGB(40, 40, 40)),
	AcrylicNoise = 0.9,
	TitleBarLine = Color3.fromRGB(75, 75, 75),
	Tab = Color3.fromRGB(120, 120, 120),
	Element = Color3.fromRGB(120, 120, 120),
	ElementBorder = Color3.fromRGB(35, 35, 35),
	InElementBorder = Color3.fromRGB(90, 90, 90),
	ElementTransparency = 0.87,
	ToggleSlider = Color3.fromRGB(120, 120, 120),
	ToggleToggled = Color3.fromRGB(42, 42, 42),
	SliderRail = Color3.fromRGB(120, 120, 120),
	DropdownFrame = Color3.fromRGB(160, 160, 160),
	DropdownHolder = Color3.fromRGB(45, 45, 45),
	DropdownBorder = Color3.fromRGB(35, 35, 35),
	DropdownOption = Color3.fromRGB(120, 120, 120),
	Keybind = Color3.fromRGB(120, 120, 120),
	Input = Color3.fromRGB(160, 160, 160),
	InputFocused = Color3.fromRGB(10, 10, 10),
	InputIndicator = Color3.fromRGB(150, 150, 150),
	InputIndicatorFocus = Color3.fromRGB(96, 205, 255),
	Dialog = Color3.fromRGB(45, 45, 45),
	DialogHolder = Color3.fromRGB(35, 35, 35),
	DialogHolderLine = Color3.fromRGB(30, 30, 30),
	DialogButton = Color3.fromRGB(45, 45, 45),
	DialogButtonBorder = Color3.fromRGB(80, 80, 80),
	DialogBorder = Color3.fromRGB(70, 70, 70),
	DialogInput = Color3.fromRGB(55, 55, 55),
	DialogInputLine = Color3.fromRGB(160, 160, 160),
	Text = Color3.fromRGB(240, 240, 240),
	SubText = Color3.fromRGB(170, 170, 170),
	Hover = Color3.fromRGB(120, 120, 120),
	HoverChange = 0.07,
}

local DefaultProperties = {
	ScreenGui = {
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	},
	Frame = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
	},
	ScrollingFrame = {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		ScrollBarImageColor3 = Theme.Text,
		ScrollBarImageTransparency = 0.8,
		ScrollBarThickness = 4,
		BottomImage = "",
		MidImage = "",
		TopImage = "",
	},
	TextLabel = {
		BackgroundTransparency = 1,
		Font = Enum.Font.SourceSans,
		Text = "",
		TextColor3 = Theme.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
	},
	TextButton = {
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Font = Enum.Font.SourceSans,
		Text = "",
		TextColor3 = Theme.Text,
		TextSize = 14,
	},
	TextBox = {
		BackgroundTransparency = 1,
		ClearTextOnFocus = false,
		Font = Enum.Font.SourceSans,
		Text = "",
		TextColor3 = Theme.Text,
		PlaceholderColor3 = Theme.SubText,
		TextSize = 14,
	},
	ImageLabel = {
		BackgroundTransparency = 1,
		Image = "",
	},
	ImageButton = {
		BackgroundTransparency = 1,
		AutoButtonColor = false,
	},
	CanvasGroup = {
		BackgroundTransparency = 1,
	},
	UICorner = {
		CornerRadius = UDim.new(0, 4),
	},
	UIStroke = {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = Theme.ElementBorder,
		Transparency = 0.5,
	},
	UIListLayout = {
		SortOrder = Enum.SortOrder.LayoutOrder,
	},
	UIPadding = {},
	UIScale = {},
	UISizeConstraint = {},
}

local function Create(className, properties, children)
	local obj = Instance.new(className)
	local defaults = DefaultProperties[className]
	if defaults then
		for prop, value in pairs(defaults) do
			pcall(function() obj[prop] = value end)
		end
	end

	if properties then
		for prop, value in pairs(properties) do
			pcall(function() obj[prop] = value end)
		end
	end

	if children then
		for _, child in pairs(children) do
			if child then
				child.Parent = obj
			end
		end
	end

	return obj
end

local RunService = game:GetService("RunService")
local RenderStepped = RunService.RenderStepped

local function CreateSignal()
    local bindable = Instance.new("BindableEvent")
    local signal = {}
    
    function signal:Fire(...)
        bindable:Fire(...)
    end
    
    function signal:Connect(callback)
        return bindable.Event:Connect(callback)
    end
    
    function signal:Destroy()
        bindable:Destroy()
    end
    
    return signal
end

local function CreateSpring(initialValue, frequency, dampingRatio)
	frequency = frequency or 8
	dampingRatio = dampingRatio or 1
	
	local value = initialValue
	local velocity = 0
	local target = initialValue
	
	local spring = {}
	spring.Updated = CreateSignal()
	
	local connection
	
	local function step(dt)
		local f = frequency * 2 * math.pi
		local d = dampingRatio
		local g = target
		
		local p0 = value
		local v0 = velocity

		local offset = p0 - g
		local decay = math.exp(-d * f * dt)

		local p1, v1
		local c = math.sqrt(math.max(0, 1 - d * d)) -- Garante que 'c' não seja imaginário
		
		local i = math.cos(f * c * dt)
		local j = math.sin(f * c * dt)

		local safeC = math.max(c, 1e-9)
		local safeFC = math.max(f * safeC, 1e-9)

		local z = j / safeC
		local y = j / safeFC

		p1 = (offset * (i + d * z) + v0 * y) * decay + g
		v1 = (v0 * (i - z * d) - offset * (z * f)) * decay
		
		if math.abs(v1) < 0.001 and math.abs(p1 - g) < 0.001 then
			p1 = g
			v1 = 0
			if connection then
				connection:Disconnect()
				connection = nil
			end
		end
		
		value = p1
		velocity = v1
		spring.Updated:Fire(value)
	end
	
	function spring:Set(newValue)
		target = newValue
		if not connection then
			connection = RenderStepped:Connect(step)
		end
	end
	
	function spring:GetValue()
		return value
	end

	function spring:Destroy()
		if connection then
			connection:Disconnect()
		end
		spring.Updated:Destroy()
	end

	return spring
end


local function SafeCallback(func, ...)
	if not func then return end
	local success, err = pcall(func, ...)
	if not success then
		warn("[Fluent] Callback Error: " .. tostring(err))
	end
end

local function Round(num, factor)
	if factor == 0 then return math.floor(num) end
	local m = 10^factor
	return math.floor(num * m + 0.5) / m
end

local KeybindManager = {}
KeybindManager.Active = true

function KeybindManager:Initialize()
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not KeybindManager.Active then return end
		if gameProcessed and input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.MouseButton2 then
			return
		end
		
		local isTyping = UserInputService:GetFocusedTextBox()
		
		for _, keybind in pairs(Library.Keybinds) do
			local key = keybind.Value
			local match = false
			
			if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == key then
				match = true
			elseif input.UserInputType == Enum.UserInputType.MouseButton1 and key == "MouseLeft" then
				match = true
			elseif input.UserInputType == Enum.UserInputType.MouseButton2 and key == "MouseRight" then
				match = true
			end
			
			if match then
				if keybind.Mode == "Toggle" then
					if isTyping then continue end
					keybind.Toggled = not keybind.Toggled
					SafeCallback(keybind.Callback, keybind.Toggled)
				elseif keybind.Mode == "Hold" then
					if isTyping and keybind.Mode ~= "Always" then continue end
					SafeCallback(keybind.Callback, true)
				elseif keybind.Mode == "Always" then
					SafeCallback(keybind.Callback, true)
				end
			end
		end
	end)
	
	UserInputService.InputEnded:Connect(function(input)
		if not KeybindManager.Active then return end
		
		local isTyping = UserInputService:GetFocusedTextBox()

		for _, keybind in pairs(Library.Keybinds) do
			local key = keybind.Value
			local match = false
			
			if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == key then
				match = true
			elseif input.UserInputType == Enum.UserInputType.MouseButton1 and key == "MouseLeft" then
				match = true
			elseif input.UserInputType == Enum.UserInputType.MouseButton2 and key == "MouseRight" then
				match = true
			end
			
			if match then
				if keybind.Mode == "Hold" then
					if isTyping and keybind.Mode ~= "Always" then continue end
					SafeCallback(keybind.Callback, false)
				elseif keybind.Mode == "Always" then
					SafeCallback(keybind.Callback, false)
				end
			end
		end
	end)
end

KeybindManager:Initialize()

local Components = {}
local Elements = {}

local function CreateElement(title, desc, parent, hover, options)
	local Element = {}
	options = options or {}

	Element.TitleLabel = Create("TextLabel", {
		Text = title,
		TextColor3 = Theme.Text,
		TextSize = 13,
		Size = UDim2.new(1, 0, 0, 14),
		LayoutOrder = 2,
	})

	Element.Header = Create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 14),
	}, {
		Create("UIListLayout", {
			Padding = UDim.new(0, 5),
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),
	})

	if options.Icon and options.Icon ~= "" then
		Element.IconImage = Create("ImageLabel", {
			Image = options.Icon,
			Size = UDim2.fromOffset(16, 16),
			ImageColor3 = Theme.Text,
			LayoutOrder = 1,
			Parent = Element.Header,
		})
	end
	Element.TitleLabel.Parent = Element.Header

	Element.DescLabel = Create("TextLabel", {
		Text = desc,
		TextColor3 = Theme.SubText,
		TextSize = 12,
		TextWrapped = true,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 14),
	})

	Element.LabelHolder = Create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, -28, 0, 0),
	}, {
		Create("UIListLayout", {
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),
		Create("UIPadding", {
			PaddingBottom = UDim.new(0, 13),
			PaddingTop = UDim.new(0, 13),
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
		}),
		Element.Header,
		Element.DescLabel,
	})

	Element.Border = Create("UIStroke", {
		Color = Theme.ElementBorder,
	})

	Element.Frame = Create("TextButton", {
		Visible = options.Visible == nil or options.Visible,
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = Theme.ElementTransparency,
		BackgroundColor3 = Theme.Element,
		Parent = parent,
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = "",
		LayoutOrder = 7,
	}, {
		Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
		Element.Border,
		Element.LabelHolder,
	})
	
	function Element:SetTitle(newTitle)
		Element.TitleLabel.Text = newTitle
		local hasTitle = (newTitle ~= nil and newTitle ~= "")
		Element.Header.Visible = hasTitle
	end
	
	function Element:Visible(bool)
		Element.Frame.Visible = bool
	end
	
	function Element:SetDesc(newDesc)
		if newDesc == nil then newDesc = "" end
		Element.DescLabel.Visible = (newDesc ~= "")
		Element.DescLabel.Text = newDesc
	end
	
	function Element:Destroy()
		Element.Frame:Destroy()
	end
	
	Element:SetTitle(title or "")
	Element:SetDesc(desc)
	
	if hover then
		local transparencySpring = CreateSpring(Theme.ElementTransparency)
		transparencySpring.Updated:Connect(function(val)
			Element.Frame.BackgroundTransparency = val
		end)
		
		Element.Frame.MouseEnter:Connect(function()
			transparencySpring:Set(Theme.ElementTransparency - Theme.HoverChange)
		end)
		Element.Frame.MouseLeave:Connect(function()
			transparencySpring:Set(Theme.ElementTransparency)
		end)
		Element.Frame.MouseButton1Down:Connect(function()
			transparencySpring:Set(Theme.ElementTransparency + Theme.HoverChange)
		end)
		Element.Frame.MouseButton1Up:Connect(function()
			transparencySpring:Set(Theme.ElementTransparency - Theme.HoverChange)
		end)
		
		Element.Destroy = function()
			transparencySpring:Destroy()
			Element.Frame:Destroy()
		end
	end

	return Element
end

Components.CreateSection = function(title, parent, icon)
	local Section = {}

	Section.Layout = Create("UIListLayout", {
		Padding = UDim.new(0, 5),
	})

	Section.Container = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 26),
		Position = UDim2.fromOffset(0, 24),
	}, {
		Section.Layout,
	})

	local headerChildren = {}
	if icon and icon ~= "" then
		table.insert(headerChildren, Create("ImageLabel", {
			Image = icon,
			Size = UDim2.fromOffset(16, 16),
			ImageColor3 = Theme.Text,
			LayoutOrder = 1,
		}))
	end
	
	table.insert(headerChildren, Create("TextLabel", {
		RichText = true,
		Text = title,
		TextColor3 = Theme.Text,
		TextSize = 18,
		Size = UDim2.fromScale(0, 1),
		AutomaticSize = Enum.AutomaticSize.X,
		LayoutOrder = 2,
	}))

	local SectionHeader = Create("Frame", {
		Size = UDim2.new(1, -16, 0, 18),
		Position = UDim2.fromOffset(8, 2),
	}, {
		Create("UIListLayout", {
			Padding = UDim.new(0, 5),
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),
		unpack(headerChildren)
	})

	Section.Root = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 26),
		LayoutOrder = 7,
		Parent = parent,
	}, {
		SectionHeader,
		Section.Container,
	})

	Section.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		local contentY = Section.Layout.AbsoluteContentSize.Y
		Section.Container.Size = UDim2.new(1, 0, 0, contentY)
		Section.Root.Size = UDim2.new(1, 0, 0, contentY + 25)
	end)

	return Section
end

Components.CreateTab = function(window, title, icon, parent)
	local Tab = {
		Selected = false,
		Name = title,
		Type = "Tab",
	}

	local tabChildren = {}
	if icon and icon ~= "" then
		table.insert(tabChildren, Create("ImageLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			Size = UDim2.fromOffset(16, 16),
			Position = UDim2.new(0, 8, 0.5, 0),
			Image = icon,
			ImageColor3 = Theme.Text,
			ZIndex = 11,
		}))
	end
	
	table.insert(tabChildren, Create("TextLabel", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = (icon and icon ~= "") and UDim2.new(0, 30, 0.5, 0) or UDim2.new(0, 12, 0.5, 0),
		Text = title,
		RichText = true,
		TextColor3 = Theme.Text,
		TextSize = 12,
		Size = UDim2.new(1, -12, 1, 0),
		ZIndex = 11,
	}))
	
	table.insert(tabChildren, Create("UICorner", {
		CornerRadius = UDim.new(0, 6),
	}))

	Tab.Frame = Create("TextButton", {
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundTransparency = 0.92,
		Parent = parent,
		ZIndex = 10,
		BackgroundColor3 = Theme.Tab,
	}, tabChildren)

	local ContainerLayout = Create("UIListLayout", {
		Padding = UDim.new(0, 5),
	})

	Tab.ContainerFrame = Create("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		Parent = window.ContainerHolder,
		Visible = false,
		CanvasSize = UDim2.fromScale(0, 0),
		ScrollingDirection = Enum.ScrollingDirection.Y,
	}, {
		ContainerLayout,
		Create("UIPadding", {
			PaddingRight = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 1),
			PaddingTop = UDim.new(0, 1),
			PaddingBottom = UDim.new(0, 1),
		}),
	})

	ContainerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		Tab.ContainerFrame.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y + 2)
	end)

	Tab.TransparencySpring = CreateSpring(0.92)
	Tab.TransparencySpring.Updated:Connect(function(val)
		Tab.Frame.BackgroundTransparency = val
	end)

	Tab.Frame.MouseEnter:Connect(function()
		Tab.TransparencySpring:Set(Tab.Selected and 0.85 or 0.87)
	end)
	Tab.Frame.MouseLeave:Connect(function()
		Tab.TransparencySpring:Set(Tab.Selected and 0.89 or 0.92)
	end)
	Tab.Frame.MouseButton1Down:Connect(function()
		Tab.TransparencySpring:Set(0.92)
	end)
	Tab.Frame.MouseButton1Up:Connect(function()
		Tab.TransparencySpring:Set(Tab.Selected and 0.85 or 0.89)
	end)

	Tab.Container = Tab.ContainerFrame
	Tab.ScrollFrame = Tab.Container

	function Tab:AddSection(sectionTitle, sectionIcon)
		local Section = {}
		local SectionFrame = Components.CreateSection(sectionTitle, Tab.Container, sectionIcon)
		Section.Container = SectionFrame.Container
		Section.ScrollFrame = Tab.Container

		setmetatable(Section, { __index = Elements })
		return Section
	end

	return Tab
end

Components.CreateButton = function(parent)
	local Button = {}

	Button.Title = Create("TextLabel", {
		TextColor3 = Theme.Text,
		TextSize = 14,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 1),
	})

	Button.HoverFrame = Create("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.Hover,
	}, {
		Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
	})

	Button.Frame = Create("TextButton", {
		Size = UDim2.new(0, 0, 0, 32),
		Parent = parent,
		BackgroundColor3 = Theme.DialogButton,
		BackgroundTransparency = 0,
	}, {
		Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
		Create("UIStroke", {
			Transparency = 0.65,
			Color = Theme.DialogButtonBorder,
		}),
		Button.HoverFrame,
		Button.Title,
	})
	
	local transparencySpring = CreateSpring(1)
	transparencySpring.Updated:Connect(function(val)
		Button.HoverFrame.BackgroundTransparency = val
	end)
	
	Button.Frame.MouseEnter:Connect(function() transparencySpring:Set(0.97) end)
	Button.Frame.MouseLeave:Connect(function() transparencySpring:Set(1) end)
	Button.Frame.MouseButton1Down:Connect(function() transparencySpring:Set(1) end)
	Button.Frame.MouseButton1Up:Connect(function() transparencySpring:Set(0.97) end)

	return Button
end

Components.CreateDialog = function(window)
	local NewDialog = {
		Buttons = 0,
	}

	NewDialog.TintFrame = Create("TextButton", {
		Text = "",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		Parent = window.Root,
	}, {
		Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
	})

	local tintSpring = CreateSpring(1)
	tintSpring.Updated:Connect(function(val)
		NewDialog.TintFrame.BackgroundTransparency = val
	end)

	NewDialog.ButtonHolder = Create("Frame", {
		Size = UDim2.new(1, -40, 1, -40),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
	}, {
		Create("UIListLayout", {
			Padding = UDim.new(0, 10),
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}),
	})

	NewDialog.ButtonHolderFrame = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 70),
		Position = UDim2.new(0, 0, 1, -70),
		BackgroundColor3 = Theme.DialogHolder,
		BackgroundTransparency = 0,
	}, {
		Create("Frame", {
			Size = UDim2.new(1, 0, 0, 1),
			BackgroundColor3 = Theme.DialogHolderLine,
			BackgroundTransparency = 0,
		}),
		NewDialog.ButtonHolder,
	})

	NewDialog.Title = Create("TextLabel", {
		Text = "Dialog",
		TextColor3 = Theme.Text,
		TextSize = 22,
		Size = UDim2.new(1, 0, 0, 22),
		Position = UDim2.fromOffset(20, 25),
	})

	NewDialog.Scale = Create("UIScale", { Scale = 1.1 })
	local scaleSpring = CreateSpring(1.1)
	scaleSpring.Updated:Connect(function(val)
		NewDialog.Scale.Scale = val
	end)

	NewDialog.Root = Create("CanvasGroup", {
		Size = UDim2.fromOffset(300, 165),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		GroupTransparency = 1,
		Parent = NewDialog.TintFrame,
		BackgroundColor3 = Theme.Dialog,
		BackgroundTransparency = 0,
	}, {
		Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
		Create("UIStroke", { Transparency = 0.5, Color = Theme.DialogBorder }),
		NewDialog.Scale,
		NewDialog.Title,
		NewDialog.ButtonHolderFrame,
	})

	local rootSpring = CreateSpring(1)
	rootSpring.Updated:Connect(function(val)
		NewDialog.Root.GroupTransparency = val
	end)

	function NewDialog:Open()
		Library.DialogOpen = true
		tintSpring:Set(0.75)
		rootSpring:Set(0)
		scaleSpring:Set(1)
	end

	function NewDialog:Close()
		Library.DialogOpen = false
		tintSpring:Set(1)
		rootSpring:Set(1)
		scaleSpring:Set(1.1)
		task.wait(0.2)
		NewDialog.TintFrame:Destroy()
	end

	function NewDialog:Button(title, callback)
		NewDialog.Buttons = NewDialog.Buttons + 1
		title = title or "Button"
		
		local Button = Components.CreateButton(NewDialog.ButtonHolder)
		Button.Title.Text = title

		for _, btn in pairs(NewDialog.ButtonHolder:GetChildren()) do
			if btn:IsA("TextButton") then
				btn.Size = UDim2.new(1 / NewDialog.Buttons, -(((NewDialog.Buttons - 1) * 10) / NewDialog.Buttons), 0, 32)
			end
		end

		Button.Frame.MouseButton1Click:Connect(function()
			SafeCallback(callback)
			NewDialog:Close()
		end)

		return Button
	end

	return NewDialog
end

Components.CreateNotificationHolder = function(parent)
	Library.ActiveNotifications = Library.ActiveNotifications or {}
	
	local Holder = Create("Frame", {
		Position = UDim2.new(1, -30, 1, -30),
		Size = UDim2.new(0, 310, 1, -30),
		AnchorPoint = Vector2.new(1, 1),
		Parent = parent,
	}, {
		Create("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			Padding = UDim.new(0, 20),
		}),
	})
	
	return Holder
end

Library.Notify = function(config)
	if not Library.NotificationHolder then
		Library.NotificationHolder = Components.CreateNotificationHolder(BaseGui)
	end

	config.Title = config.Title or "Title"
	config.Content = config.Content or "Content"
	config.SubContent = config.SubContent or ""
	
	local NewNotification = { Closed = false }

	NewNotification.Title = Create("TextLabel", {
		Position = UDim2.new(0, 14, 0, 17),
		Text = config.Title,
		RichText = true,
		TextColor3 = Theme.Text,
		TextSize = 13,
		Size = UDim2.new(1, -12, 0, 12),
		TextWrapped = true,
	})

	NewNotification.ContentLabel = Create("TextLabel", {
		Text = config.Content,
		TextColor3 = Theme.Text,
		TextSize = 14,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 14),
		TextWrapped = true,
	})

	NewNotification.SubContentLabel = Create("TextLabel", {
		Text = config.SubContent,
		TextColor3 = Theme.SubText,
		TextSize = 14,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 14),
		TextWrapped = true,
	})

	NewNotification.LabelHolder = Create("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		Position = UDim2.fromOffset(14, 40),
		Size = UDim2.new(1, -28, 0, 0),
	}, {
		Create("UIListLayout", {
			Padding = UDim.new(0, 3),
		}),
		NewNotification.ContentLabel,
		NewNotification.SubContentLabel,
	})

	NewNotification.CloseButton = Create("TextButton", {
		Text = "",
		Position = UDim2.new(1, -14, 0, 13),
		Size = UDim2.fromOffset(20, 20),
		AnchorPoint = Vector2.new(1, 0),
	}, {
		Create("ImageLabel", {
			Image = "",
			Size = UDim2.fromOffset(16, 16),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			ImageColor3 = Theme.Text,
		}),
	})
	
	NewNotification.AcrylicFrame = Create("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 0.9,
		BackgroundColor3 = Theme.AcrylicMain,
		BorderSizePixel = 1,
		BorderColor3 = Theme.AcrylicBorder,
	}, {
		Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
	})

	NewNotification.Root = Create("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.fromScale(1, 0),
	}, {
		NewNotification.AcrylicFrame,
		NewNotification.Title,
		NewNotification.CloseButton,
		NewNotification.LabelHolder,
	})

	if config.Content == "" then NewNotification.ContentLabel.Visible = false end
	if config.SubContent == "" then NewNotification.SubContentLabel.Visible = false end

	NewNotification.Holder = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 200),
		Parent = Library.NotificationHolder,
	}, {
		NewNotification.Root,
	})

	local posSpring = CreateSpring(60)
	local scaleSpring = CreateSpring(1)
	
	posSpring.Updated:Connect(function(val)
		NewNotification.Root.Position = UDim2.new(scaleSpring:GetValue(), val, 0, 0)
	end)
	scaleSpring.Updated:Connect(function(val)
		NewNotification.Root.Position = UDim2.new(val, posSpring:GetValue(), 0, 0)
	end)

	function NewNotification:Close()
		if NewNotification.Closed then return end
		NewNotification.Closed = true
		
		for i, notif in pairs(Library.ActiveNotifications) do
			if notif == NewNotification then
				table.remove(Library.ActiveNotifications, i)
				break
			end
		end

		posSpring:Set(60)
		scaleSpring:Set(1)
		task.wait(0.4)
		posSpring:Destroy()
		scaleSpring:Destroy()
		NewNotification.Holder:Destroy()
	end
	
	NewNotification.CloseButton.MouseButton1Click:Connect(NewNotification.Close)

	task.spawn(function()
		local contentY = NewNotification.LabelHolder.AbsoluteSize.Y
		NewNotification.Holder.Size = UDim2.new(1, 0, 0, 58 + contentY)
		posSpring:Set(0)
		scaleSpring:Set(0)
	end)
	
	table.insert(Library.ActiveNotifications, NewNotification)

	if config.Duration then
		task.delay(config.Duration, function()
			NewNotification:Close()
		end)
	end
	
	return NewNotification
end

Components.CreateTextbox = function(parent, acrylic)
	local Textbox = {}

	Textbox.Input = Create("TextBox", {
		TextColor3 = Theme.Text,
		PlaceholderColor3 = Theme.SubText,
		TextSize = 14,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromOffset(10, 0),
	})

	Textbox.Container = Create("Frame", {
		ClipsDescendants = true,
		Position = UDim2.new(0, 6, 0, 0),
		Size = UDim2.new(1, -12, 1, 0),
	}, {
		Textbox.Input,
	})

	Textbox.Indicator = Create("Frame", {
		Size = UDim2.new(1, -4, 0, 1),
		Position = UDim2.new(0, 2, 1, 0),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = acrylic and 0.5 or 0,
		BackgroundColor3 = acrylic and Theme.InputIndicator or Theme.DialogInputLine,
	})

	Textbox.Frame = Create("Frame", {
		Size = UDim2.new(0, 0, 0, 30),
		BackgroundTransparency = acrylic and 0.9 or 0,
		BackgroundColor3 = acrylic and Theme.Input or Theme.DialogInput,
		Parent = parent,
	}, {
		Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
		Create("UIStroke", {
			Transparency = acrylic and 0.5 or 0.65,
			Color = acrylic and Theme.InElementBorder or Theme.DialogButtonBorder,
		}),
		Textbox.Indicator,
		Textbox.Container,
	})
	
	local indicatorColorSpring = CreateSpring(Textbox.Indicator.BackgroundColor3)
	indicatorColorSpring.Updated:Connect(function(val) Textbox.Indicator.BackgroundColor3 = val end)
	
	local indicatorTransSpring = CreateSpring(Textbox.Indicator.BackgroundTransparency)
	indicatorTransSpring.Updated:Connect(function(val) Textbox.Indicator.BackgroundTransparency = val end)

	local indicatorSizeSpring = CreateSpring(UDim2.new(1, -4, 0, 1))
	indicatorSizeSpring.Updated:Connect(function(val) Textbox.Indicator.Size = val end)

	local indicatorPosSpring = CreateSpring(UDim2.new(0, 2, 1, 0))
	indicatorPosSpring.Updated:Connect(function(val) Textbox.Indicator.Position = val end)
	
	local frameColorSpring = CreateSpring(Textbox.Frame.BackgroundColor3)
	frameColorSpring.Updated:Connect(function(val) Textbox.Frame.BackgroundColor3 = val end)

	Textbox.Input.Focused:Connect(function()
		indicatorColorSpring:Set(Theme.InputIndicatorFocus)
		indicatorTransSpring:Set(0)
		indicatorSizeSpring:Set(UDim2.new(1, -2, 0, 2))
		indicatorPosSpring:Set(UDim2.new(0, 1, 1, 0))
		frameColorSpring:Set(acrylic and Theme.InputFocused or Theme.DialogHolder)
	end)

	Textbox.Input.FocusLost:Connect(function()
		indicatorColorSpring:Set(acrylic and Theme.InputIndicator or Theme.DialogInputLine)
		indicatorTransSpring:Set(0.5)
		indicatorSizeSpring:Set(UDim2.new(1, -4, 0, 1))
		indicatorPosSpring:Set(UDim2.new(0, 2, 1, 0))
		frameColorSpring:Set(acrylic and Theme.Input or Theme.DialogInput)
	end)

	return Textbox
end

Components.CreateTitleBar = function(config)
	local TitleBar = {}

	local function BarButton(icon, pos, parent, callback)
		local Button = {}
		Button.Frame = Create("TextButton", {
			Size = UDim2.new(0, 34, 1, -8),
			AnchorPoint = Vector2.new(1, 0),
			Parent = parent,
			Position = pos,
			Text = "",
			BackgroundColor3 = Theme.Text,
		}, {
			Create("UICorner", { CornerRadius = UDim.new(0, 7) }),
			Create("ImageLabel", {
				Image = icon,
				Size = UDim2.fromOffset(16, 16),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				ImageColor3 = Theme.Text,
				Name = "Icon",
			}),
		})

		local transparencySpring = CreateSpring(1)
		transparencySpring.Updated:Connect(function(val) Button.Frame.BackgroundTransparency = val end)
		
		Button.Frame.MouseEnter:Connect(function() transparencySpring:Set(0.94) end)
		Button.Frame.MouseLeave:Connect(function() transparencySpring:Set(1) end)
		Button.Frame.MouseButton1Down:Connect(function() transparencySpring:Set(0.96) end)
		Button.Frame.MouseButton1Up:Connect(function() transparencySpring:Set(0.94) end)
		Button.Frame.MouseButton1Click:Connect(callback)
		
		return Button
	end

	local titleChildren = {}
	if config.Icon and config.Icon ~= "" then
		table.insert(titleChildren, Create("ImageLabel", {
			Image = config.Icon,
			Size = UDim2.fromOffset(20, 20),
			LayoutOrder = 1,
			ImageColor3 = Theme.Text,
		}))
	end
	
	table.insert(titleChildren, Create("TextLabel", {
		RichText = true,
		Text = config.Title,
		TextSize = 12,
		Size = UDim2.fromScale(0, 1),
		AutomaticSize = Enum.AutomaticSize.X,
		LayoutOrder = (config.Icon and config.Icon ~= "") and 2 or 1,
		TextColor3 = Theme.Text,
	}))

	TitleBar.Frame = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 42),
		Parent = config.Parent,
	}, {
		Create("Frame", {
			Size = UDim2.new(1, -16, 1, 0),
			Position = UDim2.new(0, 12, 0, 0),
		}, {
			Create("UIListLayout", {
				Padding = UDim.new(0, 5),
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
			unpack(titleChildren)
		}),
		Create("Frame", {
			BackgroundTransparency = 0.5,
			BackgroundColor3 = Theme.TitleBarLine,
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.new(0, 0, 1, 0),
		}),
	})
	
	TitleBar.CloseButton = BarButton("", UDim2.new(1, -4, 0, 4), TitleBar.Frame, function()
		Library:Destroy()
	end)
	
	TitleBar.MinButton = BarButton("", UDim2.new(1, -40, 0, 4), TitleBar.Frame, function()
		config.Window:Minimize()
	end)

	return TitleBar
end

Components.CreateWindow = function(config)
	local Window = {
		Minimized = false,
		Size = config.Size,
		TabWidth = config.TabWidth or 160,
		Position = UDim2.fromOffset(0, 0),
		Tabs = {},
		Containers = {},
		SelectedTab = 0,
		TabCount = 0,
	}
	Library.Window = Window
	
	local Dragging, DragInput, MousePos, StartPos = false
	local Resizing, ResizePos = false
	local MinimizeNotif = false

	local function CenterWindow()
		local vp = Camera.ViewportSize
		local x = math.max(0, (vp.X - Window.Size.X.Offset) / 2)
		local y = math.max(0, (vp.Y - Window.Size.Y.Offset) / 2)
		Window.Position = UDim2.fromOffset(math.floor(x), math.floor(y))
		if Window.Root then
			Window.Root.Position = Window.Position
		end
	end

	Window.AcrylicPaint = Create("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.AcrylicMain,
		BackgroundTransparency = 0.1,
	}, {
		Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
		Create("UIStroke", { Color = Theme.AcrylicBorder, Transparency = 0.5 }),
	})

	Window.Selector = Create("Frame", {
		Size = UDim2.fromOffset(4, 0),
		BackgroundColor3 = Theme.Accent,
		BackgroundTransparency = 0,
		Position = UDim2.fromOffset(0, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		ZIndex = 1,
	}, {
		Create("UICorner", { CornerRadius = UDim.new(0, 9) }),
	})

	local ResizeStartFrame = Create("Frame", {
		Size = UDim2.fromOffset(20, 20),
		Position = UDim2.new(1, -20, 1, -2),
		ZIndex = 99,
	})
	
	Window.TabHolderLayout = Create("UIListLayout", {
		Padding = UDim.new(0, 4),
	})

	Window.TabHolder = Create("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ScrollBarThickness = 0,
		BorderSizePixel = 0,
		CanvasSize = UDim2.fromScale(0, 0),
		ScrollingDirection = Enum.ScrollingDirection.Y,
		LayoutOrder = 2,
	}, {
		Window.TabHolderLayout
	})
	
	local tabFrameChildren = {
		Create("UIListLayout", {
			Padding = UDim.new(0, 8),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}),
		Create("UIPadding", {
			PaddingTop = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
		}),
		Window.Selector,
	}
	
	local tabHolderHeightOffset = 0
	
	if config.TabLogo and config.TabLogo ~= "" then
		local logoHeight = 85
		tabHolderHeightOffset = logoHeight + 8
		table.insert(tabFrameChildren, Create("ImageLabel", {
			Image = config.TabLogo,
			Size = UDim2.new(1, 0, 0, logoHeight),
			LayoutOrder = 1,
			ImageColor3 = Theme.Text,
			ScaleType = Enum.ScaleType.Fit,
		}))
	end
	
	Window.TabHolder.Size = UDim2.new(1, 0, 1, -tabHolderHeightOffset)
	table.insert(tabFrameChildren, Window.TabHolder)

	Window.TabFrame = Create("Frame", {
		Size = UDim2.new(0, Window.TabWidth, 1, -42),
		Position = UDim2.new(0, 0, 0, 42),
		ClipsDescendants = true,
	}, tabFrameChildren)

	Window.TabDisplay = Create("TextLabel", {
		RichText = true,
		Text = "Tab",
		TextColor3 = Theme.Text,
		TextSize = 28,
		Size = UDim2.new(1, -16, 0, 28),
		Position = UDim2.fromOffset(Window.TabWidth + 26, 56),
	})

	Window.ContainerHolder = Create("Frame", {
		Size = UDim2.fromScale(1, 1),
	})

	Window.ContainerAnim = Create("CanvasGroup", {
		Size = UDim2.fromScale(1, 1),
	})

	Window.ContainerCanvas = Create("Frame", {
		Size = UDim2.new(1, -Window.TabWidth - 32, 1, -102),
		Position = UDim2.fromOffset(Window.TabWidth + 26, 90),
		ClipsDescendants = true,
	}, {
		Window.ContainerAnim,
		Window.ContainerHolder
	})

	Window.Root = Create("Frame", {
		Size = Window.Size,
		Position = Window.Position,
		Parent = BaseGui,
		ClipsDescendants = true,
	}, {
		Window.AcrylicPaint,
		Window.TabDisplay,
		Window.ContainerCanvas,
		Window.TabFrame,
		ResizeStartFrame,
	})

	CenterWindow()
	Camera:GetPropertyChangedSignal("ViewportSize"):Connect(CenterWindow)

	Window.TitleBar = Components.CreateTitleBar({
		Title = config.Title,
		Icon = config.Icon,
		Parent = Window.Root,
		Window = Window,
	})
	
	local sizeSpring = CreateSpring(Window.Size)
	sizeSpring.Updated:Connect(function(val)
		Window.Root.Size = val
	end)

	local posSpring = CreateSpring(Window.Position)
	posSpring.Updated:Connect(function(val)
		Window.Root.Position = val
	end)

	Window.SelectorPosSpring = CreateSpring(17)
	Window.SelectorPosSpring.Updated:Connect(function(val)
		Window.Selector.Position = UDim2.new(0, 8, 0, val)
	end)
	
	Window.SelectorSizeSpring = CreateSpring(34)
	Window.SelectorSizeSpring.Updated:Connect(function(val)
		Window.Selector.Size = UDim2.new(1, -16, 0, val)
	end)

	Window.ContainerAnimTransparency = CreateSpring(0)
	Window.ContainerAnimTransparency.Updated:Connect(function(val)
		Window.ContainerAnim.GroupTransparency = val
	end)
	
	Window.ContainerAnimPosition = CreateSpring(94)
	Window.ContainerAnimPosition.Updated:Connect(function(val)
		Window.ContainerAnim.Position = UDim2.fromOffset(0, val)
	end)

	Window.TitleBar.Frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			MousePos = input.Position
			StartPos = Window.Root.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end
			end)
		end
	end)

	Window.TitleBar.Frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			DragInput = input
		end
	end)

	ResizeStartFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			Resizing = true
			ResizePos = input.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == DragInput and Dragging then
			local delta = input.Position - MousePos
			Window.Position = UDim2.fromOffset(StartPos.X.Offset + delta.X, StartPos.Y.Offset + delta.Y)
			posSpring:Set(Window.Position)
		end

		if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and Resizing then
			local delta = input.Position - ResizePos
			local startSize = Window.Size
			local targetSize = Vector2.new(startSize.X.Offset + delta.X, startSize.Y.Offset + delta.Y)
			local clampedSize = UDim2.fromOffset(math.clamp(targetSize.X, 470, 2048), math.clamp(targetSize.Y, 380, 2048))
			Window.Size = clampedSize
			sizeSpring:Set(clampedSize)
			ResizePos = input.Position
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if Resizing == true or input.UserInputType == Enum.UserInputType.Touch then
			Resizing = false
		end
	end)

	Window.TabHolderLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		local contentY = Window.TabHolderLayout.AbsoluteContentSize.Y
		Window.TabHolder.CanvasSize = UDim2.new(0, 0, 0, contentY + 8)
	end)

	UserInputService.InputBegan:Connect(function(input)
		if type(Library.MinimizeKeybind) == "table" and Library.MinimizeKeybind.Type == "Keybind" and not UserInputService:GetFocusedTextBox() then
			if input.KeyCode.Name == Library.MinimizeKeybind.Value then
				Window:Minimize()
			end
		elseif input.KeyCode == Library.MinimizeKey and not UserInputService:GetFocusedTextBox() then
			Window:Minimize()
		end
	end)

	function Window:Minimize()
		Window.Minimized = not Window.Minimized
		Window.Root.Visible = not Window.Minimized
		KeybindManager.Active = not Window.Minimized

		for _, option in pairs(Library.Options) do
			if option and option.Type == "Dropdown" and option.Opened then
				option:Close()
			end
		end
		
		if not MinimizeNotif then
			MinimizeNotif = true
			local key = Library.MinimizeKeybind and Library.MinimizeKeybind.Value or Library.MinimizeKey.Name
			Library:Notify({
				Title = "Interface",
				Content = "Press " .. key .. " to toggle the interface.",
				Duration = 6
			})
		end
	end

	function Window:Destroy()
		Window.Root:Destroy()
		Library.Window = nil
		for _, v in pairs(Library.Keybinds) do v:Destroy() end
		for _, v in pairs(Library.OpenFrames) do v:Destroy() end
		for _, v in pairs(Library.Options) do v:Destroy() end
	end

	function Window:Dialog(dialogConfig)
		local Dialog = Components.CreateDialog(Window)
		Dialog.Title.Text = dialogConfig.Title

		local ContentHolder = Create("ScrollingFrame", {
			Position = UDim2.fromOffset(20, 60),
			Size = UDim2.new(1, -40, 1, -110),
			CanvasSize = UDim2.fromOffset(0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Parent = Dialog.Root,
		})

		local Content = Create("TextLabel", {
			Text = dialogConfig.Content,
			TextColor3 = Theme.Text,
			TextSize = 14,
			TextYAlignment = Enum.TextYAlignment.Top,
			AutomaticSize = Enum.AutomaticSize.Y,
			TextWrapped = true,
			Size = UDim2.new(1, -8, 0, 0),
			Parent = ContentHolder,
		})

		Create("UISizeConstraint", {
			MinSize = Vector2.new(300, 165),
			MaxSize = Vector2.new(620, math.huge),
			Parent = Dialog.Root,
		})

		local maxWidth = math.min(620, Window.Size.X.Offset - 120)
		local baseWidth = math.max(300, math.min(maxWidth, Content.TextBounds.X + 40))
		Dialog.Root.Size = UDim2.fromOffset(baseWidth, 165)
		ContentHolder.Size = UDim2.new(1, -40, 1, -110)
		
		task.defer(function()
			local contentHeight = Content.TextBounds.Y
			local desired = math.clamp(contentHeight + 110, 165, 420)
			Dialog.Root.Size = UDim2.fromOffset(baseWidth, desired)
			ContentHolder.CanvasSize = UDim2.fromOffset(0, contentHeight)
		end)

		for _, button in pairs(dialogConfig.Buttons) do
			Dialog:Button(button.Title, button.Callback)
		end

		Dialog:Open()
	end
	
	function Window:GetCurrentTabPos()
		if not Window.Tabs[Window.SelectedTab] then return 0 end
		local holderPos = Window.TabHolder.AbsolutePosition.Y
		local tabPos = Window.Tabs[Window.SelectedTab].Frame.AbsolutePosition.Y
		return (tabPos - holderPos) + Window.TabHolder.CanvasPosition.Y
	end

	function Window:SelectTab(tabIndex)
		Window.SelectedTab = tabIndex

		for i, tabObject in pairs(Window.Tabs) do
			tabObject.Selected = (i == tabIndex)
			tabObject.TransparencySpring:Set(tabObject.Selected and 0.89 or 0.92)
		end
		
		Window.TabDisplay.Text = Window.Tabs[tabIndex].Name
		Window.SelectorPosSpring:Set(Window:GetCurrentTabPos())
		Window.SelectorSizeSpring:Set(Window.Tabs[tabIndex].Frame.AbsoluteSize.Y)

		task.spawn(function()
			Window.ContainerHolder.Parent = Window.ContainerAnim
			Window.ContainerAnimPosition:Set(15)
			Window.ContainerAnimTransparency:Set(1)
			task.wait(0.12)
			for _, container in pairs(Window.Containers) do
				container.Visible = false
			end
			Window.Containers[tabIndex].Visible = true
			Window.ContainerAnimPosition:Set(0)
			Window.ContainerAnimTransparency:Set(0)
			task.wait(0.12)
			Window.ContainerHolder.Parent = Window.ContainerCanvas
		end)
	end

	function Window:AddTab(tabConfig)
		Window.TabCount = Window.TabCount + 1
		local tabIndex = Window.TabCount
		
		local tab = Components.CreateTab(Window, tabConfig.Title, tabConfig.Icon, Window.TabHolder)
		
		tab.Frame.MouseButton1Click:Connect(function()
			Window:SelectTab(tabIndex)
		end)

		Window.Containers[tabIndex] = tab.ContainerFrame
		Window.Tabs[tabIndex] = tab
		
		if Window.TabCount == 1 then
			Window:SelectTab(1)
		end
		
		setmetatable(tab, { __index = Elements })
		return tab
	end

	return Window
end

Elements.AddButton = function(self, config)
	assert(config.Title, "Button - Missing Title")
	
	local ButtonFrame = CreateElement(config.Title, config.Description, self.Container, true, config)

	Create("ImageLabel", {
		Image = "",
		Size = UDim2.fromOffset(16, 16),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		ImageColor3 = Theme.Text,
		Parent = ButtonFrame.Frame,
	})

	ButtonFrame.Frame.MouseButton1Click:Connect(function()
		SafeCallback(config.Callback)
	end)

	return ButtonFrame
end

Elements.AddToggle = function(self, config)
	assert(config.Title, "Toggle - Missing Title")

	local Toggle = {
		Value = config.Default or false,
		Callback = config.Callback or function() end,
		Type = "Toggle",
	}

	local ToggleFrame = CreateElement(config.Title, config.Description, self.Container, true, config)
	ToggleFrame.DescLabel.Size = UDim2.new(1, -54, 0, 14)

	Toggle.SetTitle = ToggleFrame.SetTitle
	Toggle.SetDesc = ToggleFrame.SetDesc
	Toggle.Visible = ToggleFrame.Visible
	Toggle.Elements = ToggleFrame

	local ToggleCircle = Create("ImageLabel", {
		AnchorPoint = Vector2.new(0, 0.5),
		Size = UDim2.fromOffset(14, 14),
		Position = UDim2.new(0, 2, 0.5, 0),
		Image = "",
		ImageTransparency = 0.5,
		ImageColor3 = Theme.ToggleSlider,
	})

	local ToggleBorder = Create("UIStroke", {
		Transparency = 0.5,
		Color = Theme.ToggleSlider,
	})
	
	local toggleColorSpring = CreateSpring(Theme.ToggleSlider)
	toggleColorSpring.Updated:Connect(function(val) ToggleBorder.Color = val end)
	
	local circleColorSpring = CreateSpring(Theme.ToggleSlider)
	circleColorSpring.Updated:Connect(function(val) ToggleCircle.ImageColor3 = val end)
	
	local circlePosSpring = CreateSpring(UDim2.new(0, 2, 0.5, 0))
	circlePosSpring.Updated:Connect(function(val) ToggleCircle.Position = val end)

	local ToggleSlider = Create("Frame", {
		Size = UDim2.fromOffset(36, 18),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Parent = ToggleFrame.Frame,
		BackgroundColor3 = Theme.Accent,
	}, {
		Create("UICorner", { CornerRadius = UDim.new(0, 9) }),
		ToggleBorder,
		ToggleCircle,
	})
	
	local sliderTransSpring = CreateSpring(1)
	sliderTransSpring.Updated:Connect(function(val) ToggleSlider.BackgroundTransparency = val end)

	function Toggle:OnChanged(func)
		Toggle.Changed = func
		func(Toggle.Value)
	end

	function Toggle:SetValue(value)
		Toggle.Value = not not value
		
		toggleColorSpring:Set(Toggle.Value and Theme.Accent or Theme.ToggleSlider)
		circleColorSpring:Set(Toggle.Value and Theme.ToggleToggled or Theme.ToggleSlider)
		circlePosSpring:Set(UDim2.new(0, Toggle.Value and 19 or 2, 0.5, 0))
		sliderTransSpring:Set(Toggle.Value and 0.45 or 1)
		ToggleCircle.ImageTransparency = Toggle.Value and 0 or 0.5

		SafeCallback(Toggle.Callback, Toggle.Value)
		SafeCallback(Toggle.Changed, Toggle.Value)
	end

	function Toggle:Destroy()
		toggleColorSpring:Destroy()
		circleColorSpring:Destroy()
		circlePosSpring:Destroy()
		sliderTransSpring:Destroy()
		ToggleFrame:Destroy()
	end

	ToggleFrame.Frame.MouseButton1Click:Connect(function()
		Toggle:SetValue(not Toggle.Value)
	end)

	Toggle:SetValue(Toggle.Value)
	return Toggle
end

Elements.AddDropdown = function(self, config)
	local Dropdown = {
		Values = config.Values,
		Value = config.Default,
		Multi = config.Multi,
		Buttons = {},
		Opened = false,
		Type = "Dropdown",
		Callback = config.Callback or function() end,
	}

	if Dropdown.Multi and not config.AllowNull then
		Dropdown.Value = {}
	end

	local DropdownFrame = CreateElement(config.Title, config.Description, self.Container, false, config)
	DropdownFrame.DescLabel.Size = UDim2.new(1, -170, 0, 14)

	Dropdown.SetTitle = DropdownFrame.SetTitle
	Dropdown.SetDesc = DropdownFrame.SetDesc
	Dropdown.Visible = DropdownFrame.Visible
	Dropdown.Elements = DropdownFrame

	local DropdownDisplay = Create("TextLabel", {
		Text = "",
		TextColor3 = Theme.Text,
		TextSize = 14,
		AutomaticSize = Enum.AutomaticSize.Y,
		TextYAlignment = Enum.TextYAlignment.Center,
		Size = UDim2.new(1, -40, 0.5, 0),
		Position = UDim2.new(0, 8, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		TextTruncate = Enum.TextTruncate.AtEnd,
	})

		local DropdownIco = Create("ImageLabel", {
		Image = "", -- Usando o ID do exemplo do usuário
		Size = UDim2.fromOffset(16, 16),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0), -- Linha completada
		ImageColor3 = Theme.Text,
		Rotation = 0,
	})

	local DropdownButton = Create("TextButton", {
		Size = UDim2.fromOffset(140, 30),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Parent = DropdownFrame.Frame,
		BackgroundColor3 = Theme.DropdownFrame,
		BackgroundTransparency = 0,
	}, {
		Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
		Create("UIStroke", {
			Transparency = 0.5,
			Color = Theme.InElementBorder,
		}),
		DropdownDisplay,
		DropdownIco,
	})

	local DropdownHolder = Create("Frame", {
		Size = UDim2.new(0, 140, 0, 0),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 1, 6),
		BackgroundColor3 = Theme.DropdownHolder,
		BackgroundTransparency = 0,
		ClipsDescendants = true,
		ZIndex = 2,
		Visible = false,
	}, {
		Create("UIStroke", {
			Transparency = 0.5,
			Color = Theme.DropdownBorder,
		}),
		Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
		Create("UIListLayout", {
			Padding = UDim.new(0, 2),
		}),
		Create("UIPadding", {
			PaddingTop = UDim.new(0, 4),
			PaddingBottom = UDim.new(0, 4),
		}),
	})

	local holderSpring = CreateSpring(0)
	holderSpring.Updated:Connect(function(val)
		DropdownHolder.Size = UDim2.new(0, 140, 0, val)
	end)

	local iconRotationSpring = CreateSpring(0)
	iconRotationSpring.Updated:Connect(function(val)
		DropdownIco.Rotation = val
	end)

	function Dropdown:UpdateDisplay()
		local text
		if Dropdown.Multi then
			if #Dropdown.Value == 0 then
				text = "None"
			elseif #Dropdown.Value == 1 then
				text = Dropdown.Value[1]
			else
				text = #Dropdown.Value .. " selected"
			end
		else
			text = Dropdown.Value
		end
		DropdownDisplay.Text = text
	end

	function Dropdown:Add(val)
		if Dropdown.Multi then
			if not table.find(Dropdown.Value, val) then
				table.insert(Dropdown.Value, val)
			end
		else
			Dropdown.Value = val
		end
		Dropdown:UpdateDisplay()
		SafeCallback(Dropdown.Callback, Dropdown.Value)
		SafeCallback(Dropdown.Changed, Dropdown.Value)
	end

	function Dropdown:Remove(val)
		if Dropdown.Multi then
			for i, v in pairs(Dropdown.Value) do
				if v == val then
					table.remove(Dropdown.Value, i)
					break
				end
			end
		else
			if not config.AllowNull then return end
			Dropdown.Value = nil
		end
		Dropdown:UpdateDisplay()
		SafeCallback(Dropdown.Callback, Dropdown.Value)
		SafeCallback(Dropdown.Changed, Dropdown.Value)
	end

	function Dropdown:Toggle(val)
		if Dropdown.Multi then
			if table.find(Dropdown.Value, val) then
				Dropdown:Remove(val)
			else
				Dropdown:Add(val)
			end
		else
			if Dropdown.Value == val then
				Dropdown:Remove(val)
			else
				Dropdown:Add(val)
			end
			Dropdown:Close()
		end
	end

	function Dropdown:Close()
		Dropdown.Opened = false
		DropdownHolder.Visible = false
		DropdownHolder.Parent = DropdownFrame.Frame
		holderSpring:Set(0)
		iconRotationSpring:Set(0)
		
		if Dropdown.Connection then
			Dropdown.Connection:Disconnect()
			Dropdown.Connection = nil
		end
	end

	function Dropdown:Open()
		Dropdown.Opened = true
		DropdownHolder.Visible = true
		DropdownHolder.Parent = self.ScrollFrame
		holderSpring:Set(math.min(170, (#Dropdown.Values * 26) + 8))
		iconRotationSpring:Set(180)
		
		Dropdown.Connection = Mouse.Button1Down:Connect(function()
			local ZIndex = -1
			local Over = false
			local MousePos = UserInputService:GetMouseLocation()
			
			for _, obj in pairs(BaseGui:GetGuiObjectsAtPosition(MousePos.X, MousePos.Y)) do
				if obj:IsDescendantOf(DropdownHolder) then
					Over = true
				end
				if obj:IsDescendantOf(DropdownFrame.Frame) and not obj:IsDescendantOf(DropdownHolder) then
					Over = true
				end
			end
			
			if not Over then
				Dropdown:Close()
			end
		end)
	end

	for _, value in pairs(Dropdown.Values) do
		local Option = {}

		Option.Title = Create("TextLabel", {
			Text = value,
			TextColor3 = Theme.Text,
			TextSize = 14,
			Size = UDim2.new(1, -26, 1, 0),
			Position = UDim2.fromOffset(6, 0),
		})

		Option.Check = Create("ImageLabel", {
			Image = "rbxassetid://3926305904", -- Ícone de marca de seleção
			Size = UDim2.fromOffset(16, 16),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -6, 0.5, 0),
			ImageColor3 = Theme.Accent,
			ImageTransparency = 1,
		})

		Option.Frame = Create("TextButton", {
			Size = UDim2.new(1, -8, 0, 22),
			Position = UDim2.fromOffset(4, 0),
			BackgroundColor3 = Theme.DropdownOption,
			Parent = DropdownHolder,
			Text = "",
		}, {
			Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
			Option.Title,
			Option.Check,
		})

		local transparencySpring = CreateSpring(0.9)
		transparencySpring.Updated:Connect(function(val)
			Option.Frame.BackgroundTransparency = val
		end)

		Option.Frame.MouseEnter:Connect(function() transparencySpring:Set(0.8) end)
		Option.Frame.MouseLeave:Connect(function() transparencySpring:Set(0.9) end)
		Option.Frame.MouseButton1Down:Connect(function() transparencySpring:Set(0.7) end)
		Option.Frame.MouseButton1Up:Connect(function() transparencySpring:Set(0.8) end)

		Option.Frame.MouseButton1Click:Connect(function()
			Dropdown:Toggle(value)
		end)
		
		Dropdown.Buttons[value] = Option
	end
	
	function Dropdown:OnChanged(func)
		Dropdown.Changed = func
		
		local function update()
			for val, btn in pairs(Dropdown.Buttons) do
				local state = false
				if Dropdown.Multi then
					state = table.find(Dropdown.Value, val)
				else
					state = (Dropdown.Value == val)
				end
				btn.Check.ImageTransparency = state and 0 or 1
			end
			Dropdown:UpdateDisplay()
		end
		
		Dropdown.Changed:Connect(update)
		func(Dropdown.Value)
		update()
	end
	
	DropdownButton.MouseButton1Click:Connect(function()
		if Dropdown.Opened then
			Dropdown:Close()
		else
			Dropdown:Open()
		end
	end)
	
	function Dropdown:SetValue(value)
		if Dropdown.Multi then
			assert(type(value) == "table", "Dropdown:SetValue - Value must be a table for multi-select")
			Dropdown.Value = value
		else
			assert(table.find(Dropdown.Values, value) or (config.AllowNull and value == nil), "Dropdown:SetValue - Value not in values list")
			Dropdown.Value = value
		end
		SafeCallback(Dropdown.Changed, Dropdown.Value)
		SafeCallback(Dropdown.Callback, Dropdown.Value)
	end

	function Dropdown:Destroy()
		holderSpring:Destroy()
		iconRotationSpring:Destroy()
		DropdownFrame:Destroy()
	end

	Dropdown:OnChanged(function() end)
	table.insert(Library.Options, Dropdown)
	return Dropdown
end

Elements.AddSlider = function(self, config)
	assert(config.Title, "Slider - Missing Title")

	local Slider = {
		Min = config.Min or 0,
		Max = config.Max or 100,
		Value = config.Default or 0,
		Suffix = config.Suffix or "",
		Precise = config.Precise or 0,
		Callback = config.Callback or function() end,
		Type = "Slider",
	}

	local SliderFrame = CreateElement(config.Title, config.Description, self.Container, false, config)
	SliderFrame.DescLabel.Size = UDim2.new(1, -70, 0, 14)

	Slider.SetTitle = SliderFrame.SetTitle
	Slider.SetDesc = SliderFrame.SetDesc
	Slider.Visible = SliderFrame.Visible
	Slider.Elements = SliderFrame

	local Dragging = false

	local Display = Create("TextLabel", {
		Text = Slider.Value .. Slider.Suffix,
		TextColor3 = Theme.Text,
		TextSize = 14,
		Size = UDim2.fromOffset(60, 14),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = SliderFrame.Frame,
	})

	local SliderRail = Create("Frame", {
		Size = UDim2.new(1, -84, 0, 4),
		Position = UDim2.new(0, 10, 0.5, 12),
		BackgroundColor3 = Theme.SliderRail,
		BackgroundTransparency = 0.5,
	}, {
		Create("UICorner", { CornerRadius = UDim.new(0, 2) }),
	})

	local SliderFill = Create("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = Theme.Accent,
	}, {
		Create("UICorner", { CornerRadius = UDim.new(0, 2) }),
	})

	local SliderCircle = Create("Frame", {
		Size = UDim2.fromOffset(14, 14),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		BackgroundColor3 = Theme.Text,
		BorderSizePixel = 0,
	}, {
		Create("UICorner", { CornerRadius = UDim.new(0, 7) }),
	})

	local SliderButton = Create("TextButton", {
		Size = UDim2.new(1, 0, 0, 24),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 12),
		Text = "",
		Parent = SliderFrame.Frame,
	}, {
		SliderRail,
		SliderFill,
		SliderCircle,
	})
	
	local circleScaleSpring = CreateSpring(1)
	circleScaleSpring.Updated:Connect(function(val)
		SliderCircle.UIScale.Scale = val
	end)
	
	Create("UIScale", { Parent = SliderCircle, Scale = 1 })

	function Slider:OnChanged(func)
		Slider.Changed = func
		func(Slider.Value)
	end

	function Slider:Update(noCallback)
		local percent = (Slider.Value - Slider.Min) / (Slider.Max - Slider.Min)
		percent = math.clamp(percent, 0, 1)

		SliderFill.Size = UDim2.new(percent, 0, 1, 0)
		SliderCircle.Position = UDim2.new(percent, 0, 0.5, 0)
		Display.Text = Round(Slider.Value, Slider.Precise) .. Slider.Suffix

		if not noCallback then
			SafeCallback(Slider.Callback, Slider.Value)
			SafeCallback(Slider.Changed, Slider.Value)
		end
	end

	function Slider:SetValue(value, noCallback)
		Slider.Value = math.clamp(value, Slider.Min, Slider.Max)
		Slider:Update(noCallback)
	end
	
	local function MouseMove(input)
		local railAbsSize = SliderRail.AbsoluteSize.X
		local railAbsPos = SliderRail.AbsolutePosition.X
		
		local mousePos = input.Position.X
		local percent = (mousePos - railAbsPos) / railAbsSize
		percent = math.clamp(percent, 0, 1)

		local value = Slider.Min + (Slider.Max - Slider.Min) * percent
		Slider:SetValue(value)
	end
	
	SliderButton.MouseButton1Down:Connect(function(x, y)
		Dragging = true
		circleScaleSpring:Set(1.2)
		MouseMove(Mouse)
	end)
	
	SliderButton.MouseEnter:Connect(function() circleScaleSpring:Set(1.1) end)
	SliderButton.MouseLeave:Connect(function()
		if not Dragging then
			circleScaleSpring:Set(1)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			MouseMove(input)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if Dragging and input.UserInputType == Enum.UserInputType.MouseButton1 then
			Dragging = false
			circleScaleSpring:Set(1)
		end
	end)
	
	function Slider:Destroy()
		circleScaleSpring:Destroy()
		SliderFrame:Destroy()
	end

	Slider:OnChanged(function() end)
	Slider:SetValue(Slider.Value, true)
	table.insert(Library.Options, Slider)
	return Slider
end

Elements.AddKeybind = function(self, config)
	assert(config.Title, "Keybind - Missing Title")
	
	local Keybind = {
		Value = config.Default or "...",
		Mode = config.Mode or "Toggle", -- Toggle, Hold, Always
		Toggled = false,
		Callback = config.Callback or function() end,
		Type = "Keybind",
		Waiting = false,
	}

	local KeybindFrame = CreateElement(config.Title, config.Description, self.Container, false, config)
	KeybindFrame.DescLabel.Size = UDim2.new(1, -120, 0, 14)

	Keybind.SetTitle = KeybindFrame.SetTitle
	Keybind.SetDesc = KeybindFrame.SetDesc
	Keybind.Visible = KeybindFrame.Visible
	Keybind.Elements = KeybindFrame

	local KeybindDisplay = Create("TextLabel", {
		Text = Keybind.Value,
		TextColor3 = Theme.Text,
		TextSize = 14,
		AutomaticSize = Enum.AutomaticSize.Y,
		TextYAlignment = Enum.TextYAlignment.Center,
		Size = UDim2.fromScale(1, 1),
		TextXAlignment = Enum.TextXAlignment.Center,
	})
	
	local KeybindButton = Create("TextButton", {
		Size = UDim2.fromOffset(100, 30),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Parent = KeybindFrame.Frame,
		BackgroundColor3 = Theme.Keybind,
		BackgroundTransparency = 0.9,
	}, {
		Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
		Create("UIStroke", {
			Transparency = 0.5,
			Color = Theme.InElementBorder,
		}),
		KeybindDisplay,
	})
	
	local transparencySpring = CreateSpring(0.9)
	transparencySpring.Updated:Connect(function(val)
		KeybindButton.BackgroundTransparency = val
	end)
	
	KeybindButton.MouseEnter:Connect(function() transparencySpring:Set(0.8) end)
	KeybindButton.MouseLeave:Connect(function() transparencySpring:Set(Keybind.Waiting and 0.7 or 0.9) end)
	
	local inputConn
	
	function Keybind:Destroy()
		if inputConn then
			inputConn:Disconnect()
		end
		transparencySpring:Destroy()
		KeybindFrame:Destroy()
		Library.Keybinds[Keybind] = nil
	end
	
	KeybindButton.MouseButton1Click:Connect(function()
		if Keybind.Waiting then
			Keybind.Waiting = false
			transparencySpring:Set(0.9)
			KeybindDisplay.Text = Keybind.Value
			if inputConn then
				inputConn:Disconnect()
				inputConn = nil
			end
		else
			Keybind.Waiting = true
			transparencySpring:Set(0.7)
			KeybindDisplay.Text = "..."
			
			inputConn = UserInputService.InputBegan:Connect(function(input, gp)
				if gp then return end
				Keybind.Waiting = false
				transparencySpring:Set(0.9)
				
				local keyName
				if input.UserInputType == Enum.UserInputType.Keyboard then
					keyName = input.KeyCode.Name
				elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
					keyName = "MouseLeft"
				elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
					keyName = "MouseRight"
				else
					keyName = Keybind.Value
				end
				
				Keybind.Value = keyName
				KeybindDisplay.Text = Keybind.Value
				
				if inputConn then
					inputConn:Disconnect()
					inputConn = nil
				end
			end)
		end
	end)
	
	function Keybind:OnChanged(func)
		Keybind.Callback = func
	end
	
	function Keybind:SetValue(value)
		Keybind.Value = value
		KeybindDisplay.Text = value
	end
	
	function Keybind:Get()
		return Keybind.Value, Keybind.Toggled
	end
	
	Library.Keybinds[Keybind] = Keybind
	table.insert(Library.Options, Keybind)
	return Keybind
end

Elements.AddInput = function(self, config)
	assert(config.Title, "Input - Missing Title")

	local Input = {
		Value = config.Default or "",
		Callback = config.Callback or function() end,
		Type = "Input",
	}

	local InputFrame = CreateElement(config.Title, config.Description, self.Container, false, config)
	
	local Textbox = Components.CreateTextbox(InputFrame.Frame, true)
	Textbox.Frame.LayoutOrder = 8
	Textbox.Frame.Size = UDim2.new(1, -20, 0, 30)
	Textbox.Frame.Position = UDim2.new(0, 10, 0, 0)
	Textbox.Input.Text = Input.Value
	Textbox.Input.PlaceholderText = config.Placeholder or ""
	
	if config.Numeric then
		Textbox.Input.Text = tostring(Input.Value)
		Textbox.Input:GetPropertyChangedSignal("Text"):Connect(function()
			Textbox.Input.Text = Textbox.Input.Text:gsub("[^%d%.%-]", "")
		end)
	end
	
	local labelHolder = InputFrame.LabelHolder
	local padding = labelHolder:FindFirstChildOfClass("UIPadding")
	padding.PaddingBottom = UDim.new(0, 8)
	
	InputFrame.Frame.Size = UDim2.new(1, 0, 0, 0) -- Recalc size
	
	Input.SetTitle = InputFrame.SetTitle
	Input.SetDesc = InputFrame.SetDesc
	Input.Visible = InputFrame.Visible
	Input.Elements = InputFrame

	Textbox.Input.FocusLost:Connect(function(enterPressed)
		local text = Textbox.Input.Text
		if config.Numeric then
			local num = tonumber(text)
			if num == nil then
				num = config.Default or 0
				Textbox.Input.Text = tostring(num)
			end
			Input.Value = num
		else
			Input.Value = text
		end
		
		if enterPressed then
			SafeCallback(Input.Callback, Input.Value)
			SafeCallback(Input.Changed, Input.Value)
		end
	end)
	
	function Input:OnChanged(func)
		Input.Changed = func
		func(Input.Value)
	end

	function Input:SetValue(value, noCallback)
		Input.Value = value
		Textbox.Input.Text = tostring(value)
		if not noCallback then
			SafeCallback(Input.Callback, Input.Value)
			SafeCallback(Input.Changed, Input.Value)
		end
	end
	
	function Input:Destroy()
		InputFrame:Destroy()
	end

	Input:OnChanged(function() end)
	table.insert(Library.Options, Input)
	return Input
end

Elements.AddLabel = function(self, config)
	assert(config.Title, "Label - Missing Title")
	
	local LabelFrame = CreateElement(config.Title, config.Description, self.Container, false, config)
	
	LabelFrame.SetTitle = LabelFrame.SetTitle
	LabelFrame.SetDesc = LabelFrame.SetDesc
	LabelFrame.Visible = LabelFrame.Visible
	LabelFrame.Elements = LabelFrame

	function LabelFrame:Destroy()
		LabelFrame.Frame:Destroy()
	end
	
	return LabelFrame
end

Elements.AddColorPicker = function(self, config)
	assert(config.Title, "ColorPicker - Missing Title")

	local ColorPicker = {
		Value = config.Default or Color3.new(1, 1, 1),
		Callback = config.Callback or function() end,
		Type = "ColorPicker",
	}

	local ColorFrame = CreateElement(config.Title, config.Description, self.Container, false, config)
	ColorFrame.DescLabel.Size = UDim2.new(1, -54, 0, 14)

	ColorPicker.SetTitle = ColorFrame.SetTitle
	ColorPicker.SetDesc = ColorFrame.SetDesc
	ColorPicker.Visible = ColorFrame.Visible
	ColorPicker.Elements = ColorFrame

	local ColorDisplay = Create("Frame", {
		Size = UDim2.fromOffset(36, 18),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Parent = ColorFrame.Frame,
		BackgroundColor3 = ColorPicker.Value,
		BackgroundTransparency = config.Transparency or 0,
	}, {
		Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
		Create("UIStroke", {
			Transparency = 0.5,
			Color = Theme.InElementBorder,
		}),
	})
	
	-- Armazena o frame do seletor se estiver aberto
	local PickerFrame = nil

	function ColorPicker:OnChanged(func)
		ColorPicker.Changed = func
		func(ColorPicker.Value)
	end
	
	function ColorPicker:SetValue(value, noCallback)
		ColorPicker.Value = value
		ColorDisplay.BackgroundColor3 = value
		
		if not noCallback then
			SafeCallback(ColorPicker.Callback, ColorPicker.Value)
			SafeCallback(ColorPicker.Changed, ColorPicker.Value)
		end
		
		if PickerFrame then
			PickerFrame.HueSlider:SetValue(ColorPicker.Value:ToHSV())
			PickerFrame.SatValSlider:SetValue(ColorPicker.Value)
		end
	end

	function ColorPicker:Destroy()
		if PickerFrame then
			PickerFrame:Destroy()
		end
		ColorFrame:Destroy()
	end
	
	ColorFrame.Frame.MouseButton1Click:Connect(function()
		if PickerFrame then
			PickerFrame:Destroy()
			PickerFrame = nil
			table.remove(Library.OpenFrames, 1) -- Gerenciamento básico
			return
		end

		PickerFrame = Create("Frame", {
			Size = UDim2.fromOffset(200, 230),
			Position = UDim2.new(1, 10, 0, 0),
			Parent = ColorFrame.Frame,
			BackgroundColor3 = Theme.DropdownHolder,
			ZIndex = 3,
		}, {
			Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
			Create("UIStroke", { Color = Theme.DropdownBorder, Transparency = 0.5 }),
		})
		
		table.insert(Library.OpenFrames, PickerFrame)
		
		local hue = 0
		local sat, val = 1, 1
		local transparency = ColorDisplay.BackgroundTransparency
		
		local function updateFromHSV()
			local color = Color3.fromHSV(hue, sat, val)
			ColorPicker:SetValue(color)
		end

		-- Seletor de Saturação/Valor
		local SatValPicker = Create("TextButton", {
			Size = UDim2.new(1, -20, 0, 150),
			Position = UDim2.fromOffset(10, 10),
			Text = "",
		}, {
			Create("UIGradient", {
				Color = ColorSequence.new(Color3.new(1,1,1), Color3.fromHSV(hue, 1, 1)),
				Rotation = 90,
			}),
			Create("UIGradient", {
				Color = ColorSequence.new(Color3.new(0,0,0,0), Color3.new(0,0,0,1)),
				Rotation = 0,
			}),
			Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
			Create("UIStroke", { Color = Theme.InElementBorder, Transparency = 0.5 }),
		})
		SatValPicker.Parent = PickerFrame
		
		local SatValCursor = Create("Frame", {
			Size = UDim2.fromOffset(10, 10),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.new(1,1,1),
			Parent = SatValPicker,
		}, {
			Create("UICorner", { CornerRadius = UDim.new(0, 5) }),
			Create("UIStroke", { Color = Color3.new(0,0,0), Thickness = 1 }),
		})
		
		local function UpdateSatVal(input)
			local absSize = SatValPicker.AbsoluteSize
			local absPos = SatValPicker.AbsolutePosition
			local x = math.clamp((input.Position.X - absPos.X) / absSize.X, 0, 1)
			local y = math.clamp((input.Position.Y - absPos.Y) / absSize.Y, 0, 1)
			
			sat = x
			val = 1 - y
			
			SatValCursor.Position = UDim2.fromScale(x, y)
			updateFromHSV()
		end

		-- Slider de Matiz (Hue)
		local HuePicker = Create("TextButton", {
			Size = UDim2.new(1, -20, 0, 20),
			Position = UDim2.new(0, 10, 0, 170),
			Text = "",
		}, {
			Create("UIGradient", {
				Color = ColorSequence.new{
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
					ColorSequenceKeypoint.new(0.166, Color3.fromRGB(255, 255, 0)),
					ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
					ColorSequenceKeypoint.new(0.666, Color3.fromRGB(0, 0, 255)),
					ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
				},
			}),
			Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
			Create("UIStroke", { Color = Theme.InElementBorder, Transparency = 0.5 }),
		})
		HuePicker.Parent = PickerFrame

		local HueCursor = Create("Frame", {
			Size = UDim2.new(0, 4, 1, 4),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0, 0.5),
			BackgroundColor3 = Color3.new(1,1,1),
			Parent = HuePicker,
		}, {
			Create("UIStroke", { Color = Color3.new(0,0,0), Thickness = 1 }),
		})
		
		local function UpdateHue(input)
			local absSize = HuePicker.AbsoluteSize
			local absPos = HuePicker.AbsolutePosition
			local x = math.clamp((input.Position.X - absPos.X) / absSize.X, 0, 1)
			
			hue = x
			
			HueCursor.Position = UDim2.new(x, 0, 0.5, 0)
			local satValGradient = SatValPicker:FindFirstChildOfClass("UIGradient")
			satValGradient.Color = ColorSequence.new(Color3.new(1,1,1), Color3.fromHSV(hue, 1, 1))
			updateFromHSV()
		end
		
		-- Lógica de arrastar
		local draggingHue, draggingSatVal = false, false
		
		HuePicker.MouseButton1Down:Connect(function() draggingHue = true UpdateHue(Mouse) end)
		SatValPicker.MouseButton1Down:Connect(function() draggingSatVal = true UpdateSatVal(Mouse) end)
		
		UserInputService.InputChanged:Connect(function(input)
			if draggingHue and input.UserInputType == Enum.UserInputType.MouseMovement then
				UpdateHue(input)
			elseif draggingSatVal and input.UserInputType == Enum.UserInputType.MouseMovement then
				UpdateSatVal(input)
			end
		end)
		
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				draggingHue, draggingSatVal = false, false
			end
		end)

		-- Input Hex
		local HexInput = Components.CreateTextbox(PickerFrame, false)
		HexInput.Frame.Size = UDim2.new(1, -20, 0, 30)
		HexInput.Frame.Position = UDim2.fromOffset(10, 195)
		HexInput.Input.PlaceholderText = "Hex"
		
		local function updateHex()
			HexInput.Input.Text = ColorPicker.Value:ToHex()
		end
		
		HexInput.Input.FocusLost:Connect(function(enterPressed)
			if enterPressed then
				local color = Color3.fromHex(HexInput.Input.Text)
				ColorPicker:SetValue(color)
			end
		end)
		
		-- Definir estado inicial
		local h, s, v = ColorPicker.Value:ToHSV()
		hue, sat, val = h, s, v
		
		HueCursor.Position = UDim2.new(hue, 0, 0.5, 0)
		SatValCursor.Position = UDim2.fromScale(sat, 1 - val)
		local satValGradient = SatValPicker:FindFirstChildOfClass("UIGradient")
		satValGradient.Color = ColorSequence.new(Color3.new(1,1,1), Color3.fromHSV(hue, 1, 1))
		updateHex()

		PickerFrame.HueSlider = { SetValue = function(h,s,v)
			hue, sat, val = h, s, v
			HueCursor.Position = UDim2.new(hue, 0, 0.5, 0)
			local satValGradient = SatValPicker:FindFirstChildOfClass("UIGradient")
			satValGradient.Color = ColorSequence.new(Color3.new(1,1,1), Color3.fromHSV(hue, 1, 1))
			updateHex()
		end }
		
		PickerFrame.SatValSlider = { SetValue = function(color)
			local h, s, v = color:ToHSV()
			hue, sat, val = h, s, v
			SatValCursor.Position = UDim2.fromScale(sat, 1 - val)
			updateHex()
		end }
		
		ColorPicker.Changed:Connect(updateHex)
	end)

	ColorPicker:OnChanged(function() end)
	ColorPicker:SetValue(ColorPicker.Value, true)
	table.insert(Library.Options, ColorPicker)
	return ColorPicker
end

---
-- Inicialização da Biblioteca
---

function Library:CreateWindow(config)
	assert(not Library.Window, "Window already created")
	
	config = config or {}
	config.Title = config.Title or "Fluent"
	config.Size = config.Size or UDim2.fromOffset(570, 420)
	config.MinimizeKey = config.MinimizeKey or Enum.KeyCode.RightShift
	
	local Window = Components.CreateWindow(config)
	
	Library.MinimizeKey = config.MinimizeKey
	Library.MinimizeKeybind = config.MinimizeKeybind
	
	function Library:Notify(notifConfig)
		return Library.Notify(notifConfig)
	end

	function Library:Dialog(dialogConfig)
		return Window:Dialog(dialogConfig)
	end
	
	function Library:AddTab(tabConfig)
		return Window:AddTab(tabConfig)
	end

	function Library:Destroy()
		Window:Destroy()
	end
	
	return Window
end

function Library:Init()
	-- Esta função está aqui para compatibilidade, mas a lógica principal de inicialização
	-- agora é tratada por CreateWindow.
	warn("[Fluent] Library:Init() is deprecated. Use Library:CreateWindow() instead.")
end

return Library
