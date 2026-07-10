local cloneref = (cloneref or clonereference or function(instance)
	return instance
end)

local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local TweenService = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local HttpService = cloneref(game:GetService("HttpService"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local TextService = cloneref(game:GetService("TextService"))

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local function IsExploit()
	return request and true or false
end

local function Get(url)
	if IsExploit() then
		return game:HttpGet(url)
	else
		local Success, Result = pcall(function()
			return HttpService:GetAsync(url)
		end)
		if Success then
			return Result
		else
			return ReplicatedStorage:WaitForChild("Request", 9999):InvokeServer({ Url = url })
		end
	end
end

local function Loadstring(src)
	if not IsExploit() and ReplicatedStorage:WaitForChild("Loadstring", 9999) then
		return function()
			return ReplicatedStorage:WaitForChild("Loadstring", 9999):InvokeServer(src)
		end
	else
		return loadstring(src)
	end
end

local IconModule = {
	IconsType = "lucide",
	New = nil,
	IconThemeTag = nil,
	Icons = {
		lucide = IsExploit() and Loadstring(Get("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/lucide/dist/Icons.lua"))() or require("./lucide/dist/Icons"),
		solar = IsExploit() and Loadstring(Get("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/solar/dist/Icons.lua"))() or require("./solar/dist/Icons"),
		craft = IsExploit() and Loadstring(Get("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/craft/dist/Icons.lua"))() or require("./craft/dist/Icons"),
		geist = IsExploit() and Loadstring(Get("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/geist/dist/Icons.lua"))() or require("./geist/dist/Icons"),
		sfsymbols = IsExploit() and Loadstring(Get("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/sfsymbols/dist/Icons.lua"))() or require("./sfsymbols/dist/Icons"),
		gravity = IsExploit() and Loadstring(Get("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/gravity/dist/Icons.lua"))() or require("./gravity/dist/Icons"),
	},
}

local function parseIconString(iconString)
	if type(iconString) == "string" then
		local splitIndex = iconString:find(":")
		if splitIndex then
			local iconType = iconString:sub(1, splitIndex - 1)
			local iconName = iconString:sub(splitIndex + 1)
			return iconType, iconName
		end
	end
	return nil, iconString
end

function IconModule.AddIcons(packName, iconsData)
	if type(packName) ~= "string" or type(iconsData) ~= "table" then
		error("AddIcons: packName must be string, iconsData must be table")
		return
	end
	if not IconModule.Icons[packName] then
		IconModule.Icons[packName] = { Icons = {}, Spritesheets = {} }
	end
	for iconName, iconValue in pairs(iconsData) do
		if type(iconValue) == "number" or (type(iconValue) == "string" and iconValue:match("^rbxassetid://")) then
			local imageId = iconValue
			if type(iconValue) == "number" then
				imageId = "rbxassetid://" .. tostring(iconValue)
			end
			IconModule.Icons[packName].Icons[iconName] = {
				Image = imageId,
				ImageRectSize = Vector2.new(0, 0),
				ImageRectPosition = Vector2.new(0, 0),
				Parts = nil,
			}
			IconModule.Icons[packName].Spritesheets[imageId] = imageId
		elseif type(iconValue) == "table" then
			if iconValue.Image and iconValue.ImageRectSize and iconValue.ImageRectPosition then
				local imageId = iconValue.Image
				if type(imageId) == "number" then
					imageId = "rbxassetid://" .. tostring(imageId)
				end
				IconModule.Icons[packName].Icons[iconName] = {
					Image = imageId,
					ImageRectSize = iconValue.ImageRectSize,
					ImageRectPosition = iconValue.ImageRectPosition,
					Parts = iconValue.Parts,
				}
				if not IconModule.Icons[packName].Spritesheets[imageId] then
					IconModule.Icons[packName].Spritesheets[imageId] = imageId
				end
			else
				warn("AddIcons: Invalid spritesheet data format for icon '" .. iconName .. "'")
			end
		else
			warn("AddIcons: Unsupported data type for icon '" .. iconName .. "': " .. type(iconValue))
		end
	end
end

function IconModule.SetIconsType(iconType)
	IconModule.IconsType = iconType
end

function IconModule.Init(New, IconThemeTag)
	IconModule.New = New
	IconModule.IconThemeTag = IconThemeTag
	return IconModule
end

function IconModule.Icon(Icon, Type, DefaultFormat)
	DefaultFormat = DefaultFormat ~= false
	local iconType, iconName = parseIconString(Icon)
	local targetType = iconType or Type or IconModule.IconsType
	local targetName = iconName
	local iconSet = IconModule.Icons[targetType]
	if iconSet and iconSet.Icons and iconSet.Icons[targetName] then
		return {
			iconSet.Spritesheets[tostring(iconSet.Icons[targetName].Image)],
			iconSet.Icons[targetName],
		}
	elseif iconSet and iconSet[targetName] and type(iconSet[targetName]) == "string" and string.find(iconSet[targetName], "rbxassetid://") then
		return DefaultFormat and { iconSet[targetName], { ImageRectSize = Vector2.new(0, 0), ImageRectPosition = Vector2.new(0, 0) } } or iconSet[targetName]
	end
	return nil
end

function IconModule.GetIcon(Icon, Type)
	return IconModule.Icon(Icon, Type, false)
end

function IconModule.Icon2(Icon, Type, DefaultFormat)
	return IconModule.Icon(Icon, Type, true)
end

function IconModule.Image(IconConfig)
	local Icon = {
		Icon = IconConfig.Icon or nil,
		Type = IconConfig.Type,
		Colors = IconConfig.Colors or { (IconModule.IconThemeTag or Color3.new(1, 1, 1)), Color3.new(1, 1, 1) },
		Size = IconConfig.Size or UDim2.new(0, 24, 0, 24),
		IconFrame = nil,
	}
	local Colors = {}
	for _, color in next, Icon.Colors do
		Colors[_] = {
			ThemeTag = typeof(color) == "string" and color,
			Color = typeof(color) == "Color3" and color,
		}
	end
	local IconLabel = IconModule.Icon2(Icon.Icon, Icon.Type)
	local isrbxassetid = typeof(IconLabel) == "string" and string.find(IconLabel, "rbxassetid://")
	if IconModule.New then
		local New = IconModule.New
		local IconFrame = New("ImageLabel", {
			Size = Icon.Size,
			BackgroundTransparency = 1,
			ImageColor3 = Colors[1].Color or nil,
			ThemeTag = Colors[1].ThemeTag and { ImageColor3 = Colors[1].ThemeTag },
			Image = isrbxassetid and IconLabel or (IconLabel and IconLabel[1] or ""),
			ImageRectSize = isrbxassetid and nil or (IconLabel and IconLabel[2].ImageRectSize or Vector2.new(0, 0)),
			ImageRectOffset = isrbxassetid and nil or (IconLabel and IconLabel[2].ImageRectPosition or Vector2.new(0, 0)),
		})
		if not isrbxassetid and IconLabel and IconLabel[2].Parts then
			for _, part in next, IconLabel[2].Parts do
				local IconPartLabel = IconModule.Icon(part, Icon.Type)
				if IconPartLabel then
					local IconPart = New("ImageLabel", {
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundTransparency = 1,
						ImageColor3 = Colors[1 + _].Color or nil,
						ThemeTag = Colors[1 + _].ThemeTag and { ImageColor3 = Colors[1 + _].ThemeTag },
						Image = IconPartLabel[1],
						ImageRectSize = IconPartLabel[2].ImageRectSize,
						ImageRectOffset = IconPartLabel[2].ImageRectPosition,
						Parent = IconFrame,
					})
				end
			end
		end
		Icon.IconFrame = IconFrame
	else
		local IconFrame = Instance.new("ImageLabel")
		IconFrame.Size = Icon.Size
		IconFrame.BackgroundTransparency = 1
		IconFrame.ImageColor3 = Colors[1].Color
		IconFrame.Image = isrbxassetid and IconLabel or (IconLabel and IconLabel[1] or "")
		IconFrame.ImageRectSize = isrbxassetid and nil or (IconLabel and IconLabel[2].ImageRectSize or Vector2.new(0, 0))
		IconFrame.ImageRectOffset = isrbxassetid and nil or (IconLabel and IconLabel[2].ImageRectPosition or Vector2.new(0, 0))
		if not isrbxassetid and IconLabel and IconLabel[2].Parts then
			for _, part in next, IconLabel[2].Parts do
				local IconPartLabel = IconModule.Icon(part, Icon.Type)
				if IconPartLabel then
					local IconPart = Instance.new("ImageLabel")
					IconPart.Size = UDim2.new(1, 0, 1, 0)
					IconPart.BackgroundTransparency = 1
					IconPart.ImageColor3 = Colors[1 + _].Color
					IconPart.Image = IconPartLabel[1]
					IconPart.ImageRectSize = IconPartLabel[2].ImageRectSize
					IconPart.ImageRectOffset = IconPartLabel[2].ImageRectPosition
					IconPart.Parent = IconFrame
				end
			end
		end
		Icon.IconFrame = IconFrame
	end
	return Icon
end

local Library = {}
Library.__index = Library

local Theme = {
	Background = Color3.fromRGB(10, 10, 14),
	Content = Color3.fromRGB(15, 15, 20),
	Surface = Color3.fromRGB(22, 22, 28),
	Text = Color3.fromRGB(255, 255, 255),
	TextDim = Color3.fromRGB(180, 180, 190),
	Accent = Color3.fromRGB(59, 130, 246),
	AccentDark = Color3.fromRGB(37, 99, 235),
	Border = Color3.fromRGB(35, 35, 45),
	Positive = Color3.fromRGB(34, 197, 94),
	Negative = Color3.fromRGB(239, 68, 68),
	Transparency = {
		Background = 0.15,
		Content = 0.08,
		Surface = 0.05,
	},
}

local function New(className, properties)
	local instance = Instance.new(className)
	for property, value in pairs(properties or {}) do
		if property == "ThemeTag" then
			continue
		elseif property == "Parent" then
			instance.Parent = value
		elseif property == "Text" then
			if typeof(value) == "string" or typeof(value) == "number" then
				instance[property] = value
			else
				instance[property] = tostring(value or "")
			end
		else
			instance[property] = value
		end
	end
	return instance
end

IconModule.Init(New, Theme.Text)

local function Tween(instance, info, properties)
	local tween = TweenService:Create(instance, info, properties)
	tween:Play()
	return tween
end

local function Round(instance, radius)
	local corner = New("UICorner", { CornerRadius = UDim.new(0, radius or 6), Parent = instance })
	return corner
end

local function Stroke(instance, color, thickness)
	return New("UIStroke", {
		Color = color or Theme.Border,
		Thickness = thickness or 1,
		Parent = instance,
	})
end

local function Gradient(instance, color1, color2, rotation)
	local grad = New("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, color1 or Theme.AccentDark),
			ColorSequenceKeypoint.new(1, color2 or Theme.Accent),
		}),
		Rotation = rotation or 0,
		Parent = instance,
	})
	return grad
end

local function MakeDraggable(frame, dragArea)
	local dragging = false
	local dragInput = nil
	local startPos = nil
	local startMousePos = nil
	local target = dragArea or frame

	target.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			startPos = frame.Position
			startMousePos = input.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	target.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - startMousePos
			frame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
			dragInput = nil
		end
	end)

	return dragging
end

local Components = {}

function Components.Label(section, config)
	config = config or {}
	local frame = New("Frame", {
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundTransparency = 1,
		Parent = section.Content,
	})
	local label = New("TextLabel", {
		Size = UDim2.new(1, -16, 1, 0),
		Position = UDim2.new(0, 8, 0, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = config.Text or "Label",
		TextColor3 = Theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Parent = frame,
	})
	return { Instance = frame, TextLabel = label }
end

function Components.Paragraph(section, config)
	config = config or {}
	local frame = New("Frame", {
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundTransparency = 1,
		Parent = section.Content,
	})
	local title = New("TextLabel", {
		Size = UDim2.new(1, -16, 0, 18),
		Position = UDim2.new(0, 8, 0, 2),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = config.Title or "Paragraph",
		TextColor3 = Theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = frame,
	})
	local content = New("TextLabel", {
		Size = UDim2.new(1, -16, 0, 18),
		Position = UDim2.new(0, 8, 0, 20),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = config.Content or "",
		TextColor3 = Theme.TextDim,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Parent = frame,
	})
	local function UpdateSize()
		local maxWidth = 0
		if content.AbsoluteSize.X > 0 then
			maxWidth = content.AbsoluteSize.X
		elseif section.Content and section.Content.AbsoluteSize.X > 0 then
			maxWidth = section.Content.AbsoluteSize.X - 24
		else
			maxWidth = 300
		end
		local success, textSize = pcall(function()
			return TextService:GetTextSize(content.Text, 12, Enum.Font.Gotham, Vector2.new(maxWidth, 9999))
		end)
		if success then
			content.Size = UDim2.new(1, -16, 0, textSize.Y)
			frame.Size = UDim2.new(1, 0, 0, 24 + textSize.Y)
		end
	end
	content:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateSize)
	task.delay(0.05, UpdateSize)
	return { Instance = frame, Title = title, Content = content }
end

function Components.Button(section, config)
	config = config or {}
	local frame = New("Frame", {
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundTransparency = 1,
		Parent = section.Content,
	})
	local button = New("TextButton", {
		Size = UDim2.new(1, -16, 1, -4),
		Position = UDim2.new(0, 8, 0, 2),
		BackgroundColor3 = Theme.Surface,
		BackgroundTransparency = Theme.Transparency.Surface,
		Font = Enum.Font.GothamMedium,
		Text = config.Text or "Button",
		TextColor3 = Theme.Text,
		TextSize = 13,
		AutoButtonColor = false,
		Parent = frame,
	})
	Round(button, 6)
	Stroke(button)
	local grad = Gradient(button, Theme.AccentDark, Theme.Accent, 90)
	grad.Enabled = false

	button.MouseEnter:Connect(function()
		Tween(button, TweenInfo.new(0.2), { BackgroundColor3 = Theme.Content })
	end)
	button.MouseLeave:Connect(function()
		Tween(button, TweenInfo.new(0.2), { BackgroundColor3 = Theme.Surface })
	end)
	button.MouseButton1Down:Connect(function()
		grad.Enabled = true
		Tween(button, TweenInfo.new(0.15), { BackgroundTransparency = 0 })
	end)
	button.MouseButton1Up:Connect(function()
		grad.Enabled = false
		Tween(button, TweenInfo.new(0.15), { BackgroundTransparency = Theme.Transparency.Surface })
		if config.Callback then
			config.Callback()
		end
	end)
	return { Instance = frame, Button = button }
end

function Components.Toggle(section, config)
	config = config or {}
	local value = config.Default or false
	local frame = New("Frame", {
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundTransparency = 1,
		Parent = section.Content,
	})
	local label = New("TextLabel", {
		Size = UDim2.new(1, -60, 1, 0),
		Position = UDim2.new(0, 8, 0, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = config.Text or "Toggle",
		TextColor3 = Theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = frame,
	})
	local toggleFrame = New("Frame", {
		Size = UDim2.new(0, 40, 0, 22),
		Position = UDim2.new(1, -52, 0.5, -11),
		BackgroundColor3 = Theme.Surface,
		BackgroundTransparency = 0.1,
		Active = true,
		Parent = frame,
	})
	Round(toggleFrame, 11)
	Stroke(toggleFrame)
	local knob = New("Frame", {
		Size = UDim2.new(0, 16, 0, 16),
		Position = UDim2.new(0, 3, 0.5, -8),
		BackgroundColor3 = Theme.Text,
		Parent = toggleFrame,
	})
	Round(knob, 8)
	local grad = Gradient(toggleFrame, Theme.AccentDark, Theme.Accent)
	grad.Enabled = value

	local function Set(newValue)
		value = newValue
		grad.Enabled = value
		if value then
			Tween(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quart), { Position = UDim2.new(1, -19, 0.5, -8) })
			Tween(toggleFrame, TweenInfo.new(0.2), { BackgroundTransparency = 0 })
		else
			Tween(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quart), { Position = UDim2.new(0, 3, 0.5, -8) })
			Tween(toggleFrame, TweenInfo.new(0.2), { BackgroundTransparency = 0.1 })
		end
		if config.Callback then
			config.Callback(value)
		end
	end

	toggleFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			Set(not value)
		end
	end)

	Set(value)
	return { Instance = frame, Set = Set, Get = function() return value end }
end

function Components.Slider(section, config)
	config = config or {}
	local min = config.Min or 0
	local max = config.Max or 100
	local value = config.Default or min
	local increment = config.Increment or 1
	local dragging = false

	local frame = New("Frame", {
		Size = UDim2.new(1, 0, 0, 48),
		BackgroundTransparency = 1,
		Parent = section.Content,
	})
	local label = New("TextLabel", {
		Size = UDim2.new(1, -60, 0, 18),
		Position = UDim2.new(0, 8, 0, 2),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = config.Text or "Slider",
		TextColor3 = Theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = frame,
	})
	local valueLabel = New("TextLabel", {
		Size = UDim2.new(0, 50, 0, 18),
		Position = UDim2.new(1, -58, 0, 2),
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		Text = tostring(value),
		TextColor3 = Theme.TextDim,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = frame,
	})
	local sliderBg = New("Frame", {
		Size = UDim2.new(1, -16, 0, 6),
		Position = UDim2.new(0, 8, 0, 30),
		BackgroundColor3 = Theme.Surface,
		BackgroundTransparency = 0.1,
		Active = true,
		Parent = frame,
	})
	Round(sliderBg, 3)
	local fill = New("Frame", {
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = Theme.Accent,
		BackgroundTransparency = 0,
		Parent = sliderBg,
	})
	Round(fill, 3)
	Gradient(fill, Theme.AccentDark, Theme.Accent)
	local knob = New("Frame", {
		Size = UDim2.new(0, 14, 0, 14),
		Position = UDim2.new(0, -7, 0.5, -7),
		BackgroundColor3 = Theme.Text,
		Parent = fill,
	})
	Round(knob, 7)

	local function Update(input)
		local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
		local raw = min + (max - min) * pos
		value = math.floor((raw / increment) + 0.5) * increment
		value = math.clamp(value, min, max)
		local percent = (value - min) / (max - min)
		fill.Size = UDim2.new(percent, 0, 1, 0)
		valueLabel.Text = tostring(value)
		if config.Callback then
			config.Callback(value)
		end
	end

	sliderBg.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			Update(input)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			Update(input)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	local function Set(newValue)
		value = math.clamp(newValue, min, max)
		local percent = (value - min) / (max - min)
		fill.Size = UDim2.new(percent, 0, 1, 0)
		valueLabel.Text = tostring(value)
		if config.Callback then
			config.Callback(value)
		end
	end

	Set(value)
	return { Instance = frame, Set = Set, Get = function() return value end }
end

function Components.Dropdown(section, config)
	config = config or {}
	local options = config.Options or {}
	local value = config.Default or (options[1] or nil)
	local open = false

	local frame = New("Frame", {
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundTransparency = 1,
		Parent = section.Content,
		ClipsDescendants = false,
	})
	local label = New("TextLabel", {
		Size = UDim2.new(1, -120, 0, 18),
		Position = UDim2.new(0, 8, 0, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = config.Text or "Select Option",
		TextColor3 = Theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = frame,
	})
	local dropdown = New("TextButton", {
		Size = UDim2.new(0, 100, 0, 24),
		Position = UDim2.new(1, -108, 0, 4),
		BackgroundColor3 = Theme.Surface,
		BackgroundTransparency = 0.1,
		Font = Enum.Font.Gotham,
		Text = value or "Select...",
		TextColor3 = Theme.Text,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutoButtonColor = false,
		Parent = frame,
	})
	Round(dropdown, 4)
	Stroke(dropdown)
	New("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 22), Parent = dropdown })
	local arrow = New("ImageLabel", {
		Size = UDim2.new(0, 12, 0, 12),
		Position = UDim2.new(1, -18, 0.5, -6),
		BackgroundTransparency = 1,
		ImageColor3 = Theme.TextDim,
		Image = "rbxassetid://10709791437",
		Parent = dropdown,
	})
	local listFrame = New("Frame", {
		Size = UDim2.new(0, 100, 0, 0),
		Position = UDim2.new(0, 0, 1, 4),
		BackgroundColor3 = Theme.Content,
		BackgroundTransparency = 0.02,
		Visible = false,
		Parent = dropdown,
		ZIndex = 10,
	})
	Round(listFrame, 6)
	Stroke(listFrame)
	New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = listFrame })
	New("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), Parent = listFrame })

	local function Refresh()
		for _, child in pairs(listFrame:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
		for _, option in ipairs(options) do
			local btn = New("TextButton", {
				Size = UDim2.new(1, -8, 0, 22),
				Position = UDim2.new(0, 4, 0, 0),
				BackgroundColor3 = Theme.Surface,
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				Text = tostring(option),
				TextColor3 = (option == value) and Theme.Accent or Theme.Text,
				TextSize = 11,
				AutoButtonColor = false,
				Parent = listFrame,
				ZIndex = 11,
			})
			Round(btn, 4)
			btn.MouseEnter:Connect(function()
				Tween(btn, TweenInfo.new(0.15), { BackgroundTransparency = 0.1 })
			end)
			btn.MouseLeave:Connect(function()
				Tween(btn, TweenInfo.new(0.15), { BackgroundTransparency = 1 })
			end)
			btn.MouseButton1Click:Connect(function()
				value = option
				dropdown.Text = tostring(value)
				open = false
				listFrame.Visible = false
				Tween(arrow, TweenInfo.new(0.2), { Rotation = 0 })
				Refresh()
				if config.Callback then
					config.Callback(value)
				end
			end)
		end
		local count = math.min(#options, 6)
		listFrame.Size = UDim2.new(0, 100, 0, count * 24 + 6)
	end

	dropdown.MouseButton1Click:Connect(function()
		open = not open
		listFrame.Visible = open
		Tween(arrow, TweenInfo.new(0.2), { Rotation = open and 180 or 0 })
	end)

	Refresh()

	local function Set(newValue)
		value = newValue
		dropdown.Text = tostring(value or "Select...")
		Refresh()
		if config.Callback then
			config.Callback(value)
		end
	end

	return { Instance = frame, Set = Set, Get = function() return value end, Refresh = function(newOptions) options = newOptions or options; Refresh() end }
end

function Components.MultiDropdown(section, config)
	config = config or {}
	local options = config.Options or {}
	local values = config.Default or {}
	local open = false

	local frame = New("Frame", {
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundTransparency = 1,
		Parent = section.Content,
		ClipsDescendants = false,
	})
	local label = New("TextLabel", {
		Size = UDim2.new(1, -120, 0, 18),
		Position = UDim2.new(0, 8, 0, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = config.Text or "Select Options",
		TextColor3 = Theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = frame,
	})
	local dropdown = New("TextButton", {
		Size = UDim2.new(0, 100, 0, 24),
		Position = UDim2.new(1, -108, 0, 4),
		BackgroundColor3 = Theme.Surface,
		BackgroundTransparency = 0.1,
		Font = Enum.Font.Gotham,
		Text = #values > 0 and table.concat(values, ", ") or "Select...",
		TextColor3 = Theme.Text,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutoButtonColor = false,
		Parent = frame,
	})
	Round(dropdown, 4)
	Stroke(dropdown)
	New("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 22), Parent = dropdown })
	local arrow = New("ImageLabel", {
		Size = UDim2.new(0, 12, 0, 12),
		Position = UDim2.new(1, -18, 0.5, -6),
		BackgroundTransparency = 1,
		ImageColor3 = Theme.TextDim,
		Image = "rbxassetid://10709791437",
		Parent = dropdown,
	})
	local listFrame = New("Frame", {
		Size = UDim2.new(0, 100, 0, 0),
		Position = UDim2.new(0, 0, 1, 4),
		BackgroundColor3 = Theme.Content,
		BackgroundTransparency = 0.02,
		Visible = false,
		Parent = dropdown,
		ZIndex = 10,
	})
	Round(listFrame, 6)
	Stroke(listFrame)
	New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = listFrame })
	New("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), Parent = listFrame })

	local function IsSelected(option)
		for _, v in ipairs(values) do
			if v == option then return true end
		end
		return false
	end

	local function Refresh()
		for _, child in pairs(listFrame:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
		for _, option in ipairs(options) do
			local selected = IsSelected(option)
			local btn = New("TextButton", {
				Size = UDim2.new(1, -8, 0, 22),
				Position = UDim2.new(0, 4, 0, 0),
				BackgroundColor3 = selected and Theme.Accent or Theme.Surface,
				BackgroundTransparency = selected and 0.3 or 1,
				Font = Enum.Font.Gotham,
				Text = tostring(option),
				TextColor3 = selected and Theme.Text or Theme.TextDim,
				TextSize = 11,
				AutoButtonColor = false,
				Parent = listFrame,
				ZIndex = 11,
			})
			Round(btn, 4)
			btn.MouseEnter:Connect(function()
				if not IsSelected(option) then
					Tween(btn, TweenInfo.new(0.15), { BackgroundTransparency = 0.1 })
				end
			end)
			btn.MouseLeave:Connect(function()
				if not IsSelected(option) then
					Tween(btn, TweenInfo.new(0.15), { BackgroundTransparency = 1 })
				end
			end)
			btn.MouseButton1Click:Connect(function()
				if IsSelected(option) then
					for i, v in ipairs(values) do
						if v == option then
							table.remove(values, i)
							break
						end
					end
				else
					table.insert(values, option)
				end
				dropdown.Text = #values > 0 and table.concat(values, ", ") or "Select..."
				Refresh()
				if config.Callback then
					config.Callback(values)
				end
			end)
		end
		local count = math.min(#options, 6)
		listFrame.Size = UDim2.new(0, 100, 0, count * 24 + 6)
	end

	dropdown.MouseButton1Click:Connect(function()
		open = not open
		listFrame.Visible = open
		Tween(arrow, TweenInfo.new(0.2), { Rotation = open and 180 or 0 })
	end)

	Refresh()

	local function Set(newValues)
		values = newValues or {}
		dropdown.Text = #values > 0 and table.concat(values, ", ") or "Select..."
		Refresh()
		if config.Callback then
			config.Callback(values)
		end
	end

	return { Instance = frame, Get = function() return values end, Set = Set, Refresh = function(newOptions) options = newOptions or options; Refresh() end }
end

function Components.Input(section, config)
	config = config or {}
	local frame = New("Frame", {
		Size = UDim2.new(1, 0, 0, 52),
		BackgroundTransparency = 1,
		Parent = section.Content,
	})
	local label = New("TextLabel", {
		Size = UDim2.new(1, -16, 0, 18),
		Position = UDim2.new(0, 8, 0, 2),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = config.Text or "Input",
		TextColor3 = Theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = frame,
	})
	local box = New("TextBox", {
		Size = UDim2.new(1, -16, 0, 28),
		Position = UDim2.new(0, 8, 0, 22),
		BackgroundColor3 = Theme.Surface,
		BackgroundTransparency = 0.1,
		Font = Enum.Font.Gotham,
		Text = config.Default or "",
		TextColor3 = Theme.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		Parent = frame,
	})
	Round(box, 6)
	Stroke(box)
	New("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = box })

	box.Focused:Connect(function()
		Tween(box, TweenInfo.new(0.2), { BackgroundColor3 = Theme.Content })
	end)
	box.FocusLost:Connect(function()
		Tween(box, TweenInfo.new(0.2), { BackgroundColor3 = Theme.Surface })
		if config.Callback then
			config.Callback(box.Text)
		end
	end)

	return { Instance = frame, Get = function() return box.Text end, Set = function(text) box.Text = tostring(text or ""); if config.Callback then config.Callback(box.Text) end end }
end

function Components.Keybind(section, config)
	config = config or {}
	local value = config.Default or Enum.KeyCode.Unknown
	local listening = false

	local frame = New("Frame", {
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundTransparency = 1,
		Parent = section.Content,
	})
	local label = New("TextLabel", {
		Size = UDim2.new(1, -70, 1, 0),
		Position = UDim2.new(0, 8, 0, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = config.Text or "Keybind",
		TextColor3 = Theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = frame,
	})
	local bind = New("TextButton", {
		Size = UDim2.new(0, 60, 0, 24),
		Position = UDim2.new(1, -70, 0.5, -12),
		BackgroundColor3 = Theme.Surface,
		BackgroundTransparency = 0.1,
		Font = Enum.Font.Gotham,
		Text = value ~= Enum.KeyCode.Unknown and value.Name or "...",
		TextColor3 = Theme.Text,
		TextSize = 11,
		AutoButtonColor = false,
		Parent = frame,
	})
	Round(bind, 6)
	Stroke(bind)

	bind.MouseButton1Click:Connect(function()
		if listening then return end
		listening = true
		bind.Text = "..."
		Tween(bind, TweenInfo.new(0.2), { BackgroundColor3 = Theme.Accent, TextColor3 = Theme.Text })
	end)

	UserInputService.InputBegan:Connect(function(input)
		if listening and input.UserInputType == Enum.UserInputType.Keyboard then
			listening = false
			value = input.KeyCode
			bind.Text = value.Name
			Tween(bind, TweenInfo.new(0.2), { BackgroundColor3 = Theme.Surface, TextColor3 = Theme.Text })
			if config.Callback then
				config.Callback(value)
			end
		elseif not listening and input.KeyCode == value and config.OnPressed then
			config.OnPressed()
		end
	end)

	return { Instance = frame, Get = function() return value end, Set = function(key) value = key; bind.Text = value.Name end }
end

local Section = {}
Section.__index = Section

function Section.New(tab, config)
	config = config or {}
	local self = setmetatable({}, Section)
	self.Elements = {}
	self.Collapsed = false

	-- FIX: Shifted slightly right (12 instead of 8)
	self.Instance = New("Frame", {
		Size = UDim2.new(1, -16, 0, 36),
		Position = UDim2.new(0, 14, 0, 0),
		BackgroundColor3 = Theme.Content,
		BackgroundTransparency = Theme.Transparency.Content,
		Parent = tab.Content,
		ClipsDescendants = true,
	})
	Round(self.Instance, 10)
	Stroke(self.Instance)

	self.Header = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = config.Name or "Section",
		TextColor3 = Theme.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutoButtonColor = false,
		Parent = self.Instance,
	})
	New("UIPadding", { PaddingLeft = UDim.new(0, 12), Parent = self.Header })

	local iconData = IconModule.Icon2("lucide:chevron-down", nil, true)
	local isrbx = typeof(iconData) == "string" and string.find(iconData, "rbxassetid://")
	self.Arrow = New("ImageLabel", {
		Size = UDim2.new(0, 16, 0, 16),
		Position = UDim2.new(1, -32, 0.5, -8),
		BackgroundTransparency = 1,
		ImageColor3 = Theme.TextDim,
		Image = isrbx and iconData or (iconData and iconData[1] or ""),
		ImageRectSize = isrbx and nil or (iconData and iconData[2].ImageRectSize or nil),
		ImageRectOffset = isrbx and nil or (iconData and iconData[2].ImageRectPosition or nil),
		Parent = self.Header,
	})

	self.Content = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		Position = UDim2.new(0, 0, 0, 36),
		BackgroundTransparency = 1,
		Parent = self.Instance,
		ClipsDescendants = true,
	})
	local layout = New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4), Parent = self.Content })
	New("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), Parent = self.Content })

	-- FIX: No animation on expand/collapse - direct snap
	local function UpdateSize()
		local height = 36
		if not self.Collapsed then
			height = height + layout.AbsoluteContentSize.Y
		end
		self.Instance.Size = UDim2.new(1, -16, 0, height)
	end

	self.Content.ChildAdded:Connect(function()
		task.wait()
		UpdateSize()
	end)
	self.Content.ChildRemoved:Connect(UpdateSize)
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSize)

	-- FIX: No tween on arrow rotation either - direct snap
	self.Header.MouseButton1Click:Connect(function()
		self.Collapsed = not self.Collapsed
		self.Arrow.Rotation = self.Collapsed and -90 or 0
		UpdateSize()
	end)

	if config.Collapsible == false then
		self.Arrow.Visible = false
		self.Header.AutoButtonColor = false
		self.Header.Active = false
	end

	UpdateSize()

	self.CreateLabel = function(cfg) return Components.Label(self, cfg) end
	self.CreateParagraph = function(cfg) return Components.Paragraph(self, cfg) end
	self.CreateButton = function(cfg) local el = Components.Button(self, cfg); UpdateSize(); return el end
	self.CreateToggle = function(cfg) local el = Components.Toggle(self, cfg); UpdateSize(); return el end
	self.CreateSlider = function(cfg) local el = Components.Slider(self, cfg); UpdateSize(); return el end
	self.CreateDropdown = function(cfg) local el = Components.Dropdown(self, cfg); UpdateSize(); return el end
	self.CreateMultiDropdown = function(cfg) local el = Components.MultiDropdown(self, cfg); UpdateSize(); return el end
	self.CreateInput = function(cfg) local el = Components.Input(self, cfg); UpdateSize(); return el end
	self.CreateKeybind = function(cfg) local el = Components.Keybind(self, cfg); UpdateSize(); return el end

	return self
end

local Tab = {}
Tab.__index = Tab

function Tab.New(window, config)
	config = config or {}
	local self = setmetatable({}, Tab)
	self.Sections = {}

	self.Button = New("TextButton", {
		Size = UDim2.new(1, -16, 0, 44),
		Position = UDim2.new(0, 8, 0, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = "",
		TextColor3 = Theme.TextDim,
		TextSize = 14,
		AutoButtonColor = false,
		Parent = window.TabBar,
	})

	if config.Icon then
		local iconData = IconModule.Icon2(config.Icon, nil, true)
		local isrbx = typeof(iconData) == "string" and string.find(iconData, "rbxassetid://")
		self.Icon = New("ImageLabel", {
			Size = UDim2.new(0, 18, 0, 18),
			Position = UDim2.new(0, 10, 0.5, -9),
			BackgroundTransparency = 1,
			ImageColor3 = Theme.TextDim,
			Image = isrbx and iconData or (iconData and iconData[1] or ""),
			ImageRectSize = isrbx and nil or (iconData and iconData[2].ImageRectSize or nil),
			ImageRectOffset = isrbx and nil or (iconData and iconData[2].ImageRectPosition or nil),
			Parent = self.Button,
		})
		self.TextLabel = New("TextLabel", {
			Size = UDim2.new(1, -40, 1, 0),
			Position = UDim2.new(0, 36, 0, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamMedium,
			Text = config.Name or "Tab",
			TextColor3 = Theme.TextDim,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = self.Button,
		})
	else
		self.TextLabel = New("TextLabel", {
			Size = UDim2.new(1, -16, 1, 0),
			Position = UDim2.new(0, 12, 0, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamMedium,
			Text = config.Name or "Tab",
			TextColor3 = Theme.TextDim,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = self.Button,
		})
	end

	self.Indicator = New("Frame", {
		Size = UDim2.new(0, 3, 0, 0),
		Position = UDim2.new(0, 0, 0.5, 0),
		BackgroundColor3 = Theme.Accent,
		Parent = self.Button,
	})
	Gradient(self.Indicator, Theme.AccentDark, Theme.Accent, 90)

	self.Content = New("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.Accent,
		Visible = false,
		Parent = window.ContentArea,
	})
	local contentLayout = New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), Parent = self.Content })
	New("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), Parent = self.Content })

	contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.Content.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 16)
	end)

	self.Button.MouseEnter:Connect(function()
		if window.ActiveTab ~= self then
			Tween(self.Button, TweenInfo.new(0.2), { BackgroundTransparency = 0.9, BackgroundColor3 = Theme.Surface })
			if self.TextLabel then Tween(self.TextLabel, TweenInfo.new(0.2), { TextColor3 = Theme.Text }) end
			if self.Icon then Tween(self.Icon, TweenInfo.new(0.2), { ImageColor3 = Theme.Text }) end
		end
	end)
	self.Button.MouseLeave:Connect(function()
		if window.ActiveTab ~= self then
			Tween(self.Button, TweenInfo.new(0.2), { BackgroundTransparency = 1 })
			if self.TextLabel then Tween(self.TextLabel, TweenInfo.new(0.2), { TextColor3 = Theme.TextDim }) end
			if self.Icon then Tween(self.Icon, TweenInfo.new(0.2), { ImageColor3 = Theme.TextDim }) end
		end
	end)
	self.Button.MouseButton1Click:Connect(function()
		window:SelectTab(self)
	end)

	self.CreateSection = function(cfg) return Section.New(self, cfg) end

	return self
end

local Window = {}
Window.__index = Window

function Window.New(config)
	config = config or {}
	local self = setmetatable({}, Window)
	self.Tabs = {}
	self.ActiveTab = nil
	self.Minimized = false
	self.Visible = true

	local parent = config.Parent or (gethui and gethui()) or CoreGui

	self.ScreenGui = New("ScreenGui", {
		Name = config.Title or "UI",
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = parent,
		ResetOnSpawn = false,
	})

	-- FIX: More rounded corners (12px) for smoother look
	self.MainFrame = New("Frame", {
		Size = UDim2.new(0, 480, 0, 320),
		Position = UDim2.new(0.5, -240, 0.5, -160),
		BackgroundColor3 = Theme.Background,
		BackgroundTransparency = Theme.Transparency.Background,
		Parent = self.ScreenGui,
		ClipsDescendants = true,
	})
	Round(self.MainFrame, 16)
	Stroke(self.MainFrame)

	self.TitleBar = New("Frame", {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = Theme.Surface,
		BackgroundTransparency = 0.2,
		Parent = self.MainFrame,
	})
	Round(self.TitleBar, 10)
	local titleGrad = Gradient(self.TitleBar, Theme.AccentDark, Theme.Accent, 0)
	titleGrad.Enabled = false

	-- FIX: Title width adjusted for bigger buttons
	local titleText = New("TextLabel", {
		Size = UDim2.new(1, -140, 1, 0),
		Position = UDim2.new(0, 16, 0, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = config.Title or "Script",
		TextColor3 = Theme.Text,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = self.TitleBar,
	})
	Gradient(titleText, Theme.Accent, Color3.fromRGB(200, 220, 255), 90)

	self.Sidebar = New("Frame", {
		Size = UDim2.new(0, 150, 1, -36),
		Position = UDim2.new(0, 0, 0, 36),
		BackgroundColor3 = Theme.Content,
		BackgroundTransparency = Theme.Transparency.Content,
		Parent = self.MainFrame,
		ClipsDescendants = true,
	})
	Round(self.Sidebar, 10)

	self.TabBar = New("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ScrollBarThickness = 0,
		Parent = self.Sidebar,
	})
	local tabLayout = New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4), Parent = self.TabBar })
	New("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), Parent = self.TabBar })

	tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.TabBar.CanvasSize = UDim2.new(0, 0, 0, tabLayout.AbsoluteContentSize.Y + 16)
	end)

	self.ContentArea = New("Frame", {
		Size = UDim2.new(1, -150, 1, -36),
		Position = UDim2.new(0, 150, 0, 36),
		BackgroundTransparency = 1,
		Parent = self.MainFrame,
		ClipsDescendants = true,
	})
	Round(self.ContentArea, 10)

	-- FIX: Bigger minimize and close buttons (52x52)
	local minimizeBtn = New("TextButton", {
		Size = UDim2.new(0, 36, 0, 36),
		Position = UDim2.new(1, -76, 0.5, -18),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = "−",
		TextColor3 = Theme.TextDim,
		TextSize = 18,
		AutoButtonColor = false,
		Parent = self.TitleBar,
	})
	minimizeBtn.MouseEnter:Connect(function()
		Tween(minimizeBtn, TweenInfo.new(0.2), { TextColor3 = Theme.Text })
	end)
	minimizeBtn.MouseLeave:Connect(function()
		Tween(minimizeBtn, TweenInfo.new(0.2), { TextColor3 = Theme.TextDim })
	end)
	minimizeBtn.MouseButton1Click:Connect(function()
		self:Minimize()
	end)

	local closeBtn = New("TextButton", {
		Size = UDim2.new(0, 36, 0, 36),
		Position = UDim2.new(1, -56, 0.5, -18),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = "×",
		TextColor3 = Theme.TextDim,
		TextSize = 20,
		AutoButtonColor = false,
		Parent = self.TitleBar,
	})
	closeBtn.MouseEnter:Connect(function()
		Tween(closeBtn, TweenInfo.new(0.2), { TextColor3 = Theme.Negative })
	end)
	closeBtn.MouseLeave:Connect(function()
		Tween(closeBtn, TweenInfo.new(0.2), { TextColor3 = Theme.TextDim })
	end)
	closeBtn.MouseButton1Click:Connect(function()
		self:ShowCloseConfirmation()
	end)

	MakeDraggable(self.MainFrame, self.TitleBar)

	local floatingSize = UDim2.new(0, 44, 0, 44)
	local floatingPos = UDim2.new(0, 20, 0.5, -22)
	local floatingIcon = "lucide:layout-grid"

	self.FloatingButton = New("TextButton", {
		Size = floatingSize,
		Position = floatingPos,
		BackgroundColor3 = Theme.Accent,
		BackgroundTransparency = 0.1,
		Text = "",
		AutoButtonColor = false,
		Parent = self.ScreenGui,
		ZIndex = 10,
		Active = true,
	})
	Round(self.FloatingButton, 10)
	Gradient(self.FloatingButton, Theme.AccentDark, Theme.Accent, 135)
	Stroke(self.FloatingButton, Theme.Accent, 1)

	local fIconData = IconModule.Icon2(floatingIcon, nil, true)
	local fIsrbx = typeof(fIconData) == "string" and string.find(fIconData, "rbxassetid://")
	self.FloatingIcon = New("ImageLabel", {
		Size = UDim2.new(0, 20, 0, 20),
		Position = UDim2.new(0.5, -10, 0.5, -10),
		BackgroundTransparency = 1,
		ImageColor3 = Theme.Text,
		Image = fIsrbx and fIconData or (fIconData and fIconData[1] or ""),
		ImageRectSize = fIsrbx and nil or (fIconData and fIconData[2].ImageRectSize or nil),
		ImageRectOffset = fIsrbx and nil or (fIconData and fIconData[2].ImageRectPosition or nil),
		Parent = self.FloatingButton,
		ZIndex = 11,
	})

	self.FloatingButton.MouseEnter:Connect(function()
		Tween(self.FloatingButton, TweenInfo.new(0.2), { BackgroundTransparency = 0 })
	end)
	self.FloatingButton.MouseLeave:Connect(function()
		Tween(self.FloatingButton, TweenInfo.new(0.2), { BackgroundTransparency = 0.1 })
	end)
	self.FloatingButton.MouseButton1Click:Connect(function()
		self:ToggleVisible()
	end)

	MakeDraggable(self.FloatingButton)

	function self:SelectTab(tab)
		if self.ActiveTab then
			self.ActiveTab.Content.Visible = false
			Tween(self.ActiveTab.Indicator, TweenInfo.new(0.2), { Size = UDim2.new(0, 3, 0, 0) })
			if self.ActiveTab.TextLabel then Tween(self.ActiveTab.TextLabel, TweenInfo.new(0.2), { TextColor3 = Theme.TextDim }) end
			if self.ActiveTab.Icon then Tween(self.ActiveTab.Icon, TweenInfo.new(0.2), { ImageColor3 = Theme.TextDim }) end
			Tween(self.ActiveTab.Button, TweenInfo.new(0.2), { BackgroundTransparency = 1 })
		end
		self.ActiveTab = tab
		tab.Content.Visible = true
		Tween(tab.Indicator, TweenInfo.new(0.3, Enum.EasingStyle.Quart), { Size = UDim2.new(0, 3, 0, 28), Position = UDim2.new(0, 0, 0.5, -14) })
		if tab.TextLabel then Tween(tab.TextLabel, TweenInfo.new(0.2), { TextColor3 = Theme.Text }) end
		if tab.Icon then Tween(tab.Icon, TweenInfo.new(0.2), { ImageColor3 = Theme.Text }) end
		Tween(tab.Button, TweenInfo.new(0.2), { BackgroundTransparency = 0.9, BackgroundColor3 = Theme.Surface })
	end

	function self:Minimize()
		self.MainFrame.Visible = false
		self.FloatingButton.Visible = true
	end

	function self:ToggleVisible()
		self.MainFrame.Visible = not self.MainFrame.Visible
		self.FloatingButton.Visible = not self.MainFrame.Visible
	end

	-- FIX: No dark overlay, just popup dialog centered on screen
	function self:ShowCloseConfirmation()
		local dialog = New("Frame", {
			Size = UDim2.new(0, 260, 0, 120),
			Position = UDim2.new(0.5, -130, 0.5, -60),
			BackgroundColor3 = Theme.Background,
			BackgroundTransparency = 0.05,
			ZIndex = 101,
			Parent = self.ScreenGui,
		})
		Round(dialog, 12)
		Stroke(dialog)

		local title = New("TextLabel", {
			Size = UDim2.new(1, -32, 0, 30),
			Position = UDim2.new(0, 16, 0, 12),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Text = "Close UI?",
			TextColor3 = Theme.Text,
			TextSize = 15,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 102,
			Parent = dialog,
		})

		local msg = New("TextLabel", {
			Size = UDim2.new(1, -32, 0, 40),
			Position = UDim2.new(0, 16, 0, 44),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Text = "Are you sure you want to close this UI?",
			TextColor3 = Theme.TextDim,
			TextSize = 13,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 102,
			Parent = dialog,
		})

		local yesBtn = New("TextButton", {
			Size = UDim2.new(0, 80, 0, 32),
			Position = UDim2.new(1, -180, 1, -44),
			BackgroundColor3 = Theme.Negative,
			BackgroundTransparency = 0.1,
			Font = Enum.Font.GothamBold,
			Text = "Yes",
			TextColor3 = Theme.Text,
			TextSize = 13,
			AutoButtonColor = false,
			ZIndex = 102,
			Parent = dialog,
		})
		Round(yesBtn, 6)

		local noBtn = New("TextButton", {
			Size = UDim2.new(0, 80, 0, 32),
			Position = UDim2.new(1, -92, 1, -44),
			BackgroundColor3 = Theme.Surface,
			BackgroundTransparency = 0.1,
			Font = Enum.Font.GothamBold,
			Text = "No",
			TextColor3 = Theme.Text,
			TextSize = 13,
			AutoButtonColor = false,
			ZIndex = 102,
			Parent = dialog,
		})
		Round(noBtn, 6)
		Stroke(noBtn)

		yesBtn.MouseButton1Click:Connect(function()
			dialog:Destroy()
			self:Destroy()
		end)

		noBtn.MouseButton1Click:Connect(function()
			dialog:Destroy()
		end)
	end

	function self:Destroy()
		self.ScreenGui:Destroy()
	end

	self.CreateTab = function(cfg) return Tab.New(self, cfg) end

	return self
end

function Library:CreateWindow(config)
	return Window.New(config)
end

return Library
