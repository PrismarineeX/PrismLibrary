local cloneref = (cloneref or clonereference or function(instance)
	return instance
end)

local RunService = cloneref(game:GetService("RunService"))
local HttpService = cloneref(game:GetService("HttpService"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local Players = cloneref(game:GetService("Players"))
local TweenService = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local CoreGui = cloneref(game:GetService("CoreGui"))

local Player = Players.LocalPlayer

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
		lucide = IsExploit() and Loadstring(
			Get("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/lucide/dist/Icons.lua")
		)() or require("./lucide/dist/Icons"),
		solar = IsExploit() and Loadstring(
			Get("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/solar/dist/Icons.lua")
		)() or require("./solar/dist/Icons"),
		craft = IsExploit() and Loadstring(
			Get("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/craft/dist/Icons.lua")
		)() or require("./craft/dist/Icons"),
		geist = IsExploit() and Loadstring(
			Get("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/geist/dist/Icons.lua")
		)() or require("./geist/dist/Icons"),
		sfsymbols = IsExploit() and Loadstring(
			Get("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/sfsymbols/dist/Icons.lua")
		)() or require("./sfsymbols/dist/Icons"),
		gravity = IsExploit() and Loadstring(
			Get("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/gravity/dist/Icons.lua")
		)() or require("./gravity/dist/Icons"),
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
		IconModule.Icons[packName] = {
			Icons = {},
			Spritesheets = {},
		}
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
	elseif iconSet and iconSet[targetName] and string.find(iconSet[targetName], "rbxassetid://") then
		return DefaultFormat
				and {
					iconSet[targetName],
					{ ImageRectSize = Vector2.new(0, 0), ImageRectPosition = Vector2.new(0, 0) },
				}
			or iconSet[targetName]
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
			ThemeTag = Colors[1].ThemeTag and {
				ImageColor3 = Colors[1].ThemeTag,
			},
			Image = isrbxassetid and IconLabel or IconLabel[1],
			ImageRectSize = isrbxassetid and nil or IconLabel[2].ImageRectSize,
			ImageRectOffset = isrbxassetid and nil or IconLabel[2].ImageRectPosition,
		})

		if not isrbxassetid and IconLabel[2].Parts then
			for _, part in next, IconLabel[2].Parts do
				local IconPartLabel = IconModule.Icon(part, Icon.Type)

				local IconPart = New("ImageLabel", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					ImageColor3 = Colors[1 + _].Color or nil,
					ThemeTag = Colors[1 + _].ThemeTag and {
						ImageColor3 = Colors[1 + _].ThemeTag,
					},
					Image = IconPartLabel[1],
					ImageRectSize = IconPartLabel[2].ImageRectSize,
					ImageRectOffset = IconPartLabel[2].ImageRectPosition,
					Parent = IconFrame,
				})
			end
		end

		Icon.IconFrame = IconFrame
	else
		local IconFrame = Instance.new("ImageLabel")
		IconFrame.Size = Icon.Size
		IconFrame.BackgroundTransparency = 1
		IconFrame.ImageColor3 = Colors[1].Color
		IconFrame.Image = isrbxassetid and IconLabel or IconLabel[1]
		IconFrame.ImageRectSize = isrbxassetid and nil or IconLabel[2].ImageRectSize
		IconFrame.ImageRectOffset = isrbxassetid and nil or IconLabel[2].ImageRectPosition

		if not isrbxassetid and IconLabel[2].Parts then
			for _, part in next, IconLabel[2].Parts do
				local IconPartLabel = IconModule.Icon(part, Icon.Type)

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

		Icon.IconFrame = IconFrame
	end

	return Icon
end


local Themes = {
	Background = Color3.fromRGB(15, 15, 20),
	Content = Color3.fromRGB(25, 25, 35),
	Sidebar = Color3.fromRGB(18, 18, 28),
	Accent = Color3.fromRGB(59, 130, 246),
	Accent2 = Color3.fromRGB(37, 99, 235),
	Text = Color3.fromRGB(255, 255, 255),
	SubText = Color3.fromRGB(160, 160, 180),
	Border = Color3.fromRGB(40, 40, 55),
	ElementBg = Color3.fromRGB(30, 30, 42),
	ElementHover = Color3.fromRGB(40, 40, 55),
	ToggleOn = Color3.fromRGB(59, 130, 246),
	ToggleOff = Color3.fromRGB(50, 50, 65),
	SliderBar = Color3.fromRGB(40, 40, 55),
	SliderFill = Color3.fromRGB(59, 130, 246),
}

local function New(className, properties)
	local instance = Instance.new(className)
	for key, value in pairs(properties or {}) do
		if key == "Parent" then
			continue
		end
		if key == "ThemeTag" then
			continue
		end
		instance[key] = value
	end
	if properties and properties.Parent then
		instance.Parent = properties.Parent
	end
	return instance
end

IconModule.Init(New)

local function Tween(instance, info, properties)
	local tween = TweenService:Create(instance, info, properties)
	tween:Play()
	return tween
end

local function MakeDraggable(instance, dragArea)
	local dragging = false
	local dragInput = nil
	local dragStart = nil
	local startPos = nil

	local function update(input)
		local delta = input.Position - dragStart
		instance.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end

	(dragArea or instance).InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = instance.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	(dragArea or instance).InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
end

local function ApplyCorner(instance, radius)
	local corner = New("UICorner", {
		CornerRadius = radius or UDim.new(0, 10),
		Parent = instance,
	})
	return corner
end

local function ApplyStroke(instance, color, thickness)
	local stroke = New("UIStroke", {
		Color = color or Themes.Border,
		Thickness = thickness or 1,
		Transparency = 0.6,
		Parent = instance,
	})
	return stroke
end

local function ApplyGradientText(label, color1, color2)
	local gradient = New("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, color1 or Themes.Accent),
			ColorSequenceKeypoint.new(1, color2 or Themes.Accent2),
		}),
		Rotation = 45,
		Parent = label,
	})
	return gradient
end

local function ApplyPadding(instance, top, bottom, left, right)
	local padding = New("UIPadding", {
		PaddingTop = UDim.new(0, top or 0),
		PaddingBottom = UDim.new(0, bottom or 0),
		PaddingLeft = UDim.new(0, left or 0),
		PaddingRight = UDim.new(0, right or 0),
		Parent = instance,
	})
	return padding
end

local function ApplyListLayout(instance, padding, alignment)
	local layout = New("UIListLayout", {
		Padding = UDim.new(0, padding or 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = alignment or Enum.HorizontalAlignment.Left,
		Parent = instance,
	})
	return layout
end


local Library = {}
Library.Windows = {}
Library.ActiveWindow = nil
Library.FloatingButton = nil

function Library:CreateWindow(config)
	config = config or {}
	local title = config.Title or "Script"
	local size = config.Size or UDim2.new(0, 580, 0, 380)

	local screenGui = New("ScreenGui", {
		Name = title .. "_UI",
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = CoreGui,
	})

	local mainFrame = New("Frame", {
		Name = "Main",
		Size = size,
		Position = UDim2.new(0.5, -size.X.Offset / 2, 0.5, -size.Y.Offset / 2),
		BackgroundColor3 = Themes.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Visible = false,
		Parent = screenGui,
	})
	ApplyCorner(mainFrame, UDim.new(0, 14))
	ApplyStroke(mainFrame, Themes.Border, 1)

	local shadow = New("ImageLabel", {
		Name = "Shadow",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, 40, 1, 40),
		BackgroundTransparency = 1,
		Image = "rbxassetid://5554236805",
		ImageColor3 = Color3.fromRGB(0, 0, 0),
		ImageTransparency = 0.6,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(50, 50, 50, 50),
		ZIndex = -1,
		Parent = mainFrame,
	})

	local topBar = New("Frame", {
		Name = "TopBar",
		Size = UDim2.new(1, 0, 0, 42),
		BackgroundColor3 = Themes.Background,
		BorderSizePixel = 0,
		Parent = mainFrame,
	})

	local topBarLine = New("Frame", {
		Name = "Line",
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = Themes.Border,
		BorderSizePixel = 0,
		BackgroundTransparency = 0.5,
		Parent = topBar,
	})

	local titleLabel = New("TextLabel", {
		Name = "Title",
		Size = UDim2.new(0, 200, 1, 0),
		Position = UDim2.new(0, 16, 0, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = title,
		TextColor3 = Themes.Text,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = topBar,
	})

	local minimizeBtn = New("TextButton", {
		Name = "Minimize",
		Size = UDim2.new(0, 32, 0, 32),
		Position = UDim2.new(1, -72, 0, 5),
		BackgroundColor3 = Themes.ElementBg,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Text = "−",
		TextColor3 = Themes.SubText,
		TextSize = 18,
		AutoButtonColor = false,
		Parent = topBar,
	})
	ApplyCorner(minimizeBtn, UDim.new(0, 8))

	local closeBtn = New("TextButton", {
		Name = "Close",
		Size = UDim2.new(0, 32, 0, 32),
		Position = UDim2.new(1, -36, 0, 5),
		BackgroundColor3 = Themes.ElementBg,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Text = "x",
		TextColor3 = Themes.SubText,
		TextSize = 18,
		AutoButtonColor = false,
		Parent = topBar,
	})
	ApplyCorner(closeBtn, UDim.new(0, 8))

	local sidebar = New("Frame", {
		Name = "Sidebar",
		Size = UDim2.new(0, 140, 1, -42),
		Position = UDim2.new(0, 0, 0, 42),
		BackgroundColor3 = Themes.Sidebar,
		BorderSizePixel = 0,
		Parent = mainFrame,
	})

	local sidebarLine = New("Frame", {
		Name = "Line",
		Size = UDim2.new(0, 1, 1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = Themes.Border,
		BorderSizePixel = 0,
		BackgroundTransparency = 0.5,
		Parent = sidebar,
	})

	local tabContainer = New("ScrollingFrame", {
		Name = "Tabs",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		ScrollBarImageTransparency = 1,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = sidebar,
	})
	ApplyPadding(tabContainer, 8, 8, 8, 8)
	local tabList = ApplyListLayout(tabContainer, 6)

	local contentFrame = New("Frame", {
		Name = "Content",
		Size = UDim2.new(1, -140, 1, -42),
		Position = UDim2.new(0, 140, 0, 42),
		BackgroundColor3 = Themes.Content,
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = mainFrame,
	})

	local contentScroll = New("ScrollingFrame", {
		Name = "Scroll",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Themes.Accent,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = contentFrame,
	})
	ApplyPadding(contentScroll, 12, 12, 12, 12)
	local contentList = ApplyListLayout(contentScroll, 10)

	local window = {
		ScreenGui = screenGui,
		MainFrame = mainFrame,
		TopBar = topBar,
		Sidebar = sidebar,
		TabContainer = tabContainer,
		ContentFrame = contentFrame,
		ContentScroll = contentScroll,
		Title = title,
		Tabs = {},
		ActiveTab = nil,
	}

	MakeDraggable(mainFrame, topBar)

	closeBtn.MouseEnter:Connect(function()
		Tween(closeBtn, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(180, 50, 50) })
	end)
	closeBtn.MouseLeave:Connect(function()
		Tween(closeBtn, TweenInfo.new(0.2), { BackgroundColor3 = Themes.ElementBg })
	end)
	closeBtn.MouseButton1Click:Connect(function()
		Tween(mainFrame, TweenInfo.new(0.25), { Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(mainFrame.Position.X.Scale, mainFrame.Position.X.Offset + size.X.Offset / 2, mainFrame.Position.Y.Scale, mainFrame.Position.Y.Offset + size.Y.Offset / 2) })
		task.wait(0.25)
		screenGui.Enabled = false
		if Library.FloatingButton then
			Library.FloatingButton.Visible = true
		end
	end)

	minimizeBtn.MouseEnter:Connect(function()
		Tween(minimizeBtn, TweenInfo.new(0.2), { BackgroundColor3 = Themes.ElementHover })
	end)
	minimizeBtn.MouseLeave:Connect(function()
		Tween(minimizeBtn, TweenInfo.new(0.2), { BackgroundColor3 = Themes.ElementBg })
	end)
	minimizeBtn.MouseButton1Click:Connect(function()
		Tween(mainFrame, TweenInfo.new(0.25), { Size = UDim2.new(0, size.X.Offset, 0, 42) })
	end)

	topBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			Tween(mainFrame, TweenInfo.new(0.25), { Size = size })
		end
	end)

	function window:Show()
		screenGui.Enabled = true
		mainFrame.Visible = true
		mainFrame.Size = UDim2.new(0, 0, 0, 0)
		mainFrame.Position = UDim2.new(0.5, -size.X.Offset / 2, 0.5, -size.Y.Offset / 2)
		Tween(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), { Size = size })
		if Library.FloatingButton then
			Library.FloatingButton.Visible = false
		end
	end

	function window:AddTab(tabConfig)
		tabConfig = tabConfig or {}
		local tabName = tabConfig.Name or "Tab"
		local tabIcon = tabConfig.Icon or "lucide:box"

		local tabBtn = New("TextButton", {
			Name = tabName,
			Size = UDim2.new(1, 0, 0, 34),
			BackgroundColor3 = Themes.ElementBg,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamSemibold,
			Text = "",
			AutoButtonColor = false,
			Parent = tabContainer,
		})
		ApplyCorner(tabBtn, UDim.new(0, 8))

		local iconData = IconModule.Image({ Icon = tabIcon, Size = UDim2.new(0, 18, 0, 18), Colors = { Themes.SubText } })
		if iconData and iconData.IconFrame then
			iconData.IconFrame.Position = UDim2.new(0, 10, 0.5, -9)
			iconData.IconFrame.Parent = tabBtn
		end

		local tabText = New("TextLabel", {
			Size = UDim2.new(1, -40, 1, 0),
			Position = UDim2.new(0, 34, 0, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamSemibold,
			Text = tabName,
			TextColor3 = Themes.SubText,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = tabBtn,
		})

		local tabContent = New("Frame", {
			Name = tabName .. "_Content",
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Visible = false,
			Parent = contentScroll,
		})
		local tabListLayout = ApplyListLayout(tabContent, 10)
		ApplyPadding(tabContent, 4, 4, 4, 4)

		local tabObj = {
			Name = tabName,
			Button = tabBtn,
			Content = tabContent,
		}

		function tabObj:Select()
			if window.ActiveTab then
				window.ActiveTab.Content.Visible = false
				Tween(window.ActiveTab.Button, TweenInfo.new(0.2), { BackgroundColor3 = Themes.ElementBg })
				window.ActiveTab.Button:FindFirstChildOfClass("TextLabel").TextColor3 = Themes.SubText
			end
			window.ActiveTab = tabObj
			tabObj.Content.Visible = true
			Tween(tabBtn, TweenInfo.new(0.2), { BackgroundColor3 = Themes.Accent })
			tabText.TextColor3 = Themes.Text
		end

		tabBtn.MouseButton1Click:Connect(function()
			tabObj:Select()
		end)

		tabBtn.MouseEnter:Connect(function()
			if window.ActiveTab ~= tabObj then
				Tween(tabBtn, TweenInfo.new(0.2), { BackgroundColor3 = Themes.ElementHover })
			end
		end)

		tabBtn.MouseLeave:Connect(function()
			if window.ActiveTab ~= tabObj then
				Tween(tabBtn, TweenInfo.new(0.2), { BackgroundColor3 = Themes.ElementBg })
			end
		end)

		function tabObj:AddSection(sectionConfig)
			sectionConfig = sectionConfig or {}
			local sectionName = sectionConfig.Name or "Section"
			local collapsed = sectionConfig.Collapsed or false

			local sectionFrame = New("Frame", {
				Name = sectionName,
				Size = UDim2.new(1, 0, 0, 36),
				BackgroundColor3 = Themes.ElementBg,
				BorderSizePixel = 0,
				ClipsDescendants = true,
				Parent = tabContent,
			})
			ApplyCorner(sectionFrame, UDim.new(0, 10))
			ApplyStroke(sectionFrame, Themes.Border, 1)

			local sectionHeader = New("TextButton", {
				Name = "Header",
				Size = UDim2.new(1, 0, 0, 36),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamSemibold,
				Text = "",
				AutoButtonColor = false,
				Parent = sectionFrame,
			})

			local headerText = New("TextLabel", {
				Size = UDim2.new(1, -40, 1, 0),
				Position = UDim2.new(0, 12, 0, 0),
				BackgroundTransparency = 1,
				Font = Enum.Font.GothamSemibold,
				Text = sectionName,
				TextColor3 = Themes.Text,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = sectionHeader,
			})
			ApplyGradientText(headerText, Themes.Accent, Themes.Accent2)

			local arrowIcon = IconModule.Image({ Icon = "lucide:chevron-down", Size = UDim2.new(0, 16, 0, 16), Colors = { Themes.SubText } })
			if arrowIcon and arrowIcon.IconFrame then
				arrowIcon.IconFrame.Position = UDim2.new(1, -26, 0.5, -8)
				arrowIcon.IconFrame.Rotation = collapsed and -90 or 0
				arrowIcon.IconFrame.Parent = sectionHeader
			end

			local sectionContent = New("Frame", {
				Name = "Content",
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(0, 0, 0, 36),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ClipsDescendants = true,
				Parent = sectionFrame,
			})
			local sectionList = ApplyListLayout(sectionContent, 8)
			ApplyPadding(sectionContent, 6, 10, 10, 10)

			local isOpen = not collapsed
			local contentHeight = 0

			sectionList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				contentHeight = sectionList.AbsoluteContentSize.Y + 16
				if isOpen then
					sectionFrame.Size = UDim2.new(1, 0, 0, 36 + contentHeight)
				end
			end)

			local function toggleSection()
				isOpen = not isOpen
				if isOpen then
					contentHeight = sectionList.AbsoluteContentSize.Y + 16
					Tween(sectionFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart), { Size = UDim2.new(1, 0, 0, 36 + contentHeight) })
					if arrowIcon and arrowIcon.IconFrame then
						Tween(arrowIcon.IconFrame, TweenInfo.new(0.25), { Rotation = 0 })
					end
				else
					Tween(sectionFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart), { Size = UDim2.new(1, 0, 0, 36) })
					if arrowIcon and arrowIcon.IconFrame then
						Tween(arrowIcon.IconFrame, TweenInfo.new(0.25), { Rotation = -90 })
					end
				end
			end

			sectionHeader.MouseButton1Click:Connect(toggleSection)

			if not collapsed then
				contentHeight = sectionList.AbsoluteContentSize.Y + 16
				sectionFrame.Size = UDim2.new(1, 0, 0, 36 + contentHeight)
			end

			local sectionObj = {
				Frame = sectionFrame,
				Content = sectionContent,
			}

			function sectionObj:AddButton(btnConfig)
				btnConfig = btnConfig or {}
				local btnText = btnConfig.Name or "Button"
				local callback = btnConfig.Callback or function() end

				local btn = New("TextButton", {
					Size = UDim2.new(1, 0, 0, 32),
					BackgroundColor3 = Themes.ElementHover,
					BorderSizePixel = 0,
					Font = Enum.Font.GothamSemibold,
					Text = btnText,
					TextColor3 = Themes.Text,
					TextSize = 13,
					AutoButtonColor = false,
					Parent = sectionContent,
				})
				ApplyCorner(btn, UDim.new(0, 8))

				btn.MouseEnter:Connect(function()
					Tween(btn, TweenInfo.new(0.2), { BackgroundColor3 = Themes.Accent })
				end)
				btn.MouseLeave:Connect(function()
					Tween(btn, TweenInfo.new(0.2), { BackgroundColor3 = Themes.ElementHover })
				end)
				btn.MouseButton1Click:Connect(function()
					Tween(btn, TweenInfo.new(0.1), { Size = UDim2.new(0.98, 0, 0, 32) })
					task.wait(0.05)
					Tween(btn, TweenInfo.new(0.1), { Size = UDim2.new(1, 0, 0, 32) })
					callback()
				end)

				return btn
			end

			function sectionObj:AddToggle(toggleConfig)
				toggleConfig = toggleConfig or {}
				local toggleName = toggleConfig.Name or "Toggle"
				local default = toggleConfig.Default or false
				local callback = toggleConfig.Callback or function() end

				local toggleFrame = New("Frame", {
					Size = UDim2.new(1, 0, 0, 32),
					BackgroundColor3 = Themes.ElementHover,
					BorderSizePixel = 0,
					Parent = sectionContent,
				})
				ApplyCorner(toggleFrame, UDim.new(0, 8))

				local toggleLabel = New("TextLabel", {
					Size = UDim2.new(1, -60, 1, 0),
					Position = UDim2.new(0, 12, 0, 0),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamSemibold,
					Text = toggleName,
					TextColor3 = Themes.Text,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = toggleFrame,
				})

				local toggleBtn = New("Frame", {
					Size = UDim2.new(0, 40, 0, 22),
					Position = UDim2.new(1, -52, 0.5, -11),
					BackgroundColor3 = default and Themes.ToggleOn or Themes.ToggleOff,
					BorderSizePixel = 0,
					Parent = toggleFrame,
				})
				ApplyCorner(toggleBtn, UDim.new(1, 0))

				local toggleCircle = New("Frame", {
					Size = UDim2.new(0, 16, 0, 16),
					Position = default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
					BackgroundColor3 = Themes.Text,
					BorderSizePixel = 0,
					Parent = toggleBtn,
				})
				ApplyCorner(toggleCircle, UDim.new(1, 0))

				local enabled = default

				local function updateToggle()
					enabled = not enabled
					Tween(toggleBtn, TweenInfo.new(0.2), { BackgroundColor3 = enabled and Themes.ToggleOn or Themes.ToggleOff })
					Tween(toggleCircle, TweenInfo.new(0.2), { Position = enabled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8) })
					callback(enabled)
				end

				local clickArea = New("TextButton", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = "",
					Parent = toggleFrame,
				})
				clickArea.MouseButton1Click:Connect(updateToggle)

				return {
					Set = function(val)
						enabled = val
						Tween(toggleBtn, TweenInfo.new(0.2), { BackgroundColor3 = enabled and Themes.ToggleOn or Themes.ToggleOff })
						Tween(toggleCircle, TweenInfo.new(0.2), { Position = enabled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8) })
						callback(enabled)
					end,
					Get = function() return enabled end,
				}
			end

			function sectionObj:AddSlider(sliderConfig)
				sliderConfig = sliderConfig or {}
				local sliderName = sliderConfig.Name or "Slider"
				local min = sliderConfig.Min or 0
				local max = sliderConfig.Max or 100
				local default = sliderConfig.Default or min
				local increment = sliderConfig.Increment or 1
				local callback = sliderConfig.Callback or function() end

				local sliderFrame = New("Frame", {
					Size = UDim2.new(1, 0, 0, 48),
					BackgroundColor3 = Themes.ElementHover,
					BorderSizePixel = 0,
					Parent = sectionContent,
				})
				ApplyCorner(sliderFrame, UDim.new(0, 8))

				local sliderLabel = New("TextLabel", {
					Size = UDim2.new(0.7, 0, 0, 20),
					Position = UDim2.new(0, 12, 0, 4),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamSemibold,
					Text = sliderName,
					TextColor3 = Themes.Text,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = sliderFrame,
				})

				local valueLabel = New("TextLabel", {
					Size = UDim2.new(0.3, -16, 0, 20),
					Position = UDim2.new(0.7, 4, 0, 4),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBold,
					Text = tostring(default),
					TextColor3 = Themes.Accent,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Right,
					Parent = sliderFrame,
				})

				local sliderBar = New("Frame", {
					Size = UDim2.new(1, -24, 0, 6),
					Position = UDim2.new(0, 12, 0, 30),
					BackgroundColor3 = Themes.SliderBar,
					BorderSizePixel = 0,
					Parent = sliderFrame,
				})
				ApplyCorner(sliderBar, UDim.new(1, 0))

				local sliderFill = New("Frame", {
					Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
					BackgroundColor3 = Themes.SliderFill,
					BorderSizePixel = 0,
					Parent = sliderBar,
				})
				ApplyCorner(sliderFill, UDim.new(1, 0))

				local sliderKnob = New("Frame", {
					Size = UDim2.new(0, 14, 0, 14),
					Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7),
					BackgroundColor3 = Themes.Text,
					BorderSizePixel = 0,
					Parent = sliderBar,
				})
				ApplyCorner(sliderKnob, UDim.new(1, 0))

				local dragging = false
				local currentValue = default

				local function updateValue(input)
					local pos = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
					local raw = min + (max - min) * pos
					currentValue = math.floor((raw / increment) + 0.5) * increment
					currentValue = math.clamp(currentValue, min, max)

					local scale = (currentValue - min) / (max - min)
					sliderFill.Size = UDim2.new(scale, 0, 1, 0)
					sliderKnob.Position = UDim2.new(scale, -7, 0.5, -7)
					valueLabel.Text = tostring(currentValue)
					callback(currentValue)
				end

				sliderBar.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true
						updateValue(input)
					end
				end)

				UserInputService.InputChanged:Connect(function(input)
					if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
						updateValue(input)
					end
				end)

				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = false
					end
				end)

				return {
					Set = function(val)
						currentValue = math.clamp(val, min, max)
						local scale = (currentValue - min) / (max - min)
						sliderFill.Size = UDim2.new(scale, 0, 1, 0)
						sliderKnob.Position = UDim2.new(scale, -7, 0.5, -7)
						valueLabel.Text = tostring(currentValue)
						callback(currentValue)
					end,
					Get = function() return currentValue end,
				}
			end

			function sectionObj:AddDropdown(dropConfig)
				dropConfig = dropConfig or {}
				local dropName = dropConfig.Name or "Dropdown"
				local options = dropConfig.Options or {}
				local default = dropConfig.Default or nil
				local callback = dropConfig.Callback or function() end

				local dropFrame = New("Frame", {
					Size = UDim2.new(1, 0, 0, 34),
					BackgroundColor3 = Themes.ElementHover,
					BorderSizePixel = 0,
					ClipsDescendants = true,
					Parent = sectionContent,
				})
				ApplyCorner(dropFrame, UDim.new(0, 8))

				local dropHeader = New("TextButton", {
					Size = UDim2.new(1, 0, 0, 34),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamSemibold,
					Text = "",
					AutoButtonColor = false,
					Parent = dropFrame,
				})

				local dropLabel = New("TextLabel", {
					Size = UDim2.new(0.5, 0, 1, 0),
					Position = UDim2.new(0, 12, 0, 0),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamSemibold,
					Text = dropName,
					TextColor3 = Themes.Text,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = dropHeader,
				})

				local selectedLabel = New("TextLabel", {
					Size = UDim2.new(0.5, -40, 1, 0),
					Position = UDim2.new(0.5, 0, 0, 0),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamSemibold,
					Text = default or "Select...",
					TextColor3 = Themes.SubText,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Right,
					Parent = dropHeader,
				})

				local arrowIcon = IconModule.Image({ Icon = "lucide:chevron-down", Size = UDim2.new(0, 14, 0, 14), Colors = { Themes.SubText } })
				if arrowIcon and arrowIcon.IconFrame then
					arrowIcon.IconFrame.Position = UDim2.new(1, -24, 0.5, -7)
					arrowIcon.IconFrame.Parent = dropHeader
				end

				local optionsFrame = New("Frame", {
					Size = UDim2.new(1, 0, 0, 0),
					Position = UDim2.new(0, 0, 0, 34),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Parent = dropFrame,
				})
				local optionsList = ApplyListLayout(optionsFrame, 4)
				ApplyPadding(optionsFrame, 4, 8, 10, 10)

				local isOpen = false
				local selected = default

				local function refreshOptions()
					for _, child in pairs(optionsFrame:GetChildren()) do
						if child:IsA("TextButton") then
							child:Destroy()
						end
					end

					for _, opt in ipairs(options) do
						local optBtn = New("TextButton", {
							Size = UDim2.new(1, 0, 0, 28),
							BackgroundColor3 = Themes.ElementBg,
							BorderSizePixel = 0,
							Font = Enum.Font.GothamSemibold,
							Text = tostring(opt),
							TextColor3 = (selected == opt) and Themes.Accent or Themes.Text,
							TextSize = 12,
							AutoButtonColor = false,
							Parent = optionsFrame,
						})
						ApplyCorner(optBtn, UDim.new(0, 6))

						optBtn.MouseEnter:Connect(function()
							Tween(optBtn, TweenInfo.new(0.15), { BackgroundColor3 = Themes.ElementHover })
						end)
						optBtn.MouseLeave:Connect(function()
							Tween(optBtn, TweenInfo.new(0.15), { BackgroundColor3 = Themes.ElementBg })
						end)
						optBtn.MouseButton1Click:Connect(function()
							selected = opt
							selectedLabel.Text = tostring(selected)
							callback(selected)
							isOpen = false
							Tween(dropFrame, TweenInfo.new(0.2), { Size = UDim2.new(1, 0, 0, 34) })
							if arrowIcon and arrowIcon.IconFrame then
								Tween(arrowIcon.IconFrame, TweenInfo.new(0.2), { Rotation = 0 })
							end
							refreshOptions()
						end)
					end
				end

				refreshOptions()

				dropHeader.MouseButton1Click:Connect(function()
					isOpen = not isOpen
					if isOpen then
						local optsHeight = #options * 32 + 12
						Tween(dropFrame, TweenInfo.new(0.2), { Size = UDim2.new(1, 0, 0, 34 + optsHeight) })
						if arrowIcon and arrowIcon.IconFrame then
							Tween(arrowIcon.IconFrame, TweenInfo.new(0.2), { Rotation = 180 })
						end
					else
						Tween(dropFrame, TweenInfo.new(0.2), { Size = UDim2.new(1, 0, 0, 34) })
						if arrowIcon and arrowIcon.IconFrame then
							Tween(arrowIcon.IconFrame, TweenInfo.new(0.2), { Rotation = 0 })
						end
					end
				end)

				return {
					Set = function(val)
						selected = val
						selectedLabel.Text = tostring(selected)
						callback(selected)
						refreshOptions()
					end,
					Get = function() return selected end,
					Refresh = function(newOpts)
						options = newOpts
						refreshOptions()
					end,
				}
			end

			function sectionObj:AddMultiDropdown(multiConfig)
				multiConfig = multiConfig or {}
				local multiName = multiConfig.Name or "Multi Dropdown"
				local options = multiConfig.Options or {}
				local default = multiConfig.Default or {}
				local callback = multiConfig.Callback or function() end

				local multiFrame = New("Frame", {
					Size = UDim2.new(1, 0, 0, 34),
					BackgroundColor3 = Themes.ElementHover,
					BorderSizePixel = 0,
					ClipsDescendants = true,
					Parent = sectionContent,
				})
				ApplyCorner(multiFrame, UDim.new(0, 8))

				local multiHeader = New("TextButton", {
					Size = UDim2.new(1, 0, 0, 34),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamSemibold,
					Text = "",
					AutoButtonColor = false,
					Parent = multiFrame,
				})

				local multiLabel = New("TextLabel", {
					Size = UDim2.new(0.5, 0, 1, 0),
					Position = UDim2.new(0, 12, 0, 0),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamSemibold,
					Text = multiName,
					TextColor3 = Themes.Text,
					TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = multiHeader,
				})

				local selectedLabel = New("TextLabel", {
					Size = UDim2.new(0.5, -40, 1, 0),
					Position = UDim2.new(0.5, 0, 0, 0),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamSemibold,
					Text = #default > 0 and table.concat(default, ", ") or "Select...",
					TextColor3 = Themes.SubText,
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Right,
					TextTruncate = Enum.TextTruncate.AtEnd,
					Parent = multiHeader,
				})

				local arrowIcon = IconModule.Image({ Icon = "lucide:chevron-down", Size = UDim2.new(0, 14, 0, 14), Colors = { Themes.SubText } })
				if arrowIcon and arrowIcon.IconFrame then
					arrowIcon.IconFrame.Position = UDim2.new(1, -24, 0.5, -7)
					arrowIcon.IconFrame.Parent = multiHeader
				end

				local optionsFrame = New("Frame", {
					Size = UDim2.new(1, 0, 0, 0),
					Position = UDim2.new(0, 0, 0, 34),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Parent = multiFrame,
				})
				local optionsList = ApplyListLayout(optionsFrame, 4)
				ApplyPadding(optionsFrame, 4, 8, 10, 10)

				local isOpen = false
				local selected = {}
				for _, v in ipairs(default) do
					table.insert(selected, v)
				end

				local function updateLabel()
					if #selected == 0 then
						selectedLabel.Text = "Select..."
					else
						selectedLabel.Text = table.concat(selected, ", ")
					end
				end

				local function refreshOptions()
					for _, child in pairs(optionsFrame:GetChildren()) do
						if child:IsA("TextButton") then
							child:Destroy()
						end
					end

					for _, opt in ipairs(options) do
						local isSelected = table.find(selected, opt) ~= nil

						local optBtn = New("TextButton", {
							Size = UDim2.new(1, 0, 0, 28),
							BackgroundColor3 = isSelected and Themes.Accent or Themes.ElementBg,
							BorderSizePixel = 0,
							Font = Enum.Font.GothamSemibold,
							Text = tostring(opt),
							TextColor3 = isSelected and Themes.Text or Themes.SubText,
							TextSize = 12,
							AutoButtonColor = false,
							Parent = optionsFrame,
						})
						ApplyCorner(optBtn, UDim.new(0, 6))

						optBtn.MouseEnter:Connect(function()
							if not table.find(selected, opt) then
								Tween(optBtn, TweenInfo.new(0.15), { BackgroundColor3 = Themes.ElementHover })
							end
						end)
						optBtn.MouseLeave:Connect(function()
							if not table.find(selected, opt) then
								Tween(optBtn, TweenInfo.new(0.15), { BackgroundColor3 = Themes.ElementBg })
							end
						end)
						optBtn.MouseButton1Click:Connect(function()
							local idx = table.find(selected, opt)
							if idx then
								table.remove(selected, idx)
							else
								table.insert(selected, opt)
							end
							updateLabel()
							callback(selected)
							refreshOptions()
						end)
					end
				end

				refreshOptions()

				multiHeader.MouseButton1Click:Connect(function()
					isOpen = not isOpen
					if isOpen then
						local optsHeight = #options * 32 + 12
						Tween(multiFrame, TweenInfo.new(0.2), { Size = UDim2.new(1, 0, 0, 34 + optsHeight) })
						if arrowIcon and arrowIcon.IconFrame then
							Tween(arrowIcon.IconFrame, TweenInfo.new(0.2), { Rotation = 180 })
						end
					else
						Tween(multiFrame, TweenInfo.new(0.2), { Size = UDim2.new(1, 0, 0, 34) })
						if arrowIcon and arrowIcon.IconFrame then
							Tween(arrowIcon.IconFrame, TweenInfo.new(0.2), { Rotation = 0 })
						end
					end
				end)

				return {
					Set = function(vals)
						selected = {}
						for _, v in ipairs(vals) do
							table.insert(selected, v)
						end
						updateLabel()
						callback(selected)
						refreshOptions()
					end,
					Get = function() return selected end,
					Refresh = function(newOpts)
						options = newOpts
						refreshOptions()
					end,
				}
			end

			function sectionObj:AddLabel(text)
				local label = New("TextLabel", {
					Size = UDim2.new(1, 0, 0, 22),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamSemibold,
					Text = text or "Label",
					TextColor3 = Themes.SubText,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextWrapped = true,
					Parent = sectionContent,
				})
				return label
			end

			function sectionObj:AddTextBox(boxConfig)
				boxConfig = boxConfig or {}
				local boxName = boxConfig.Name or "TextBox"
				local default = boxConfig.Default or ""
				local placeholder = boxConfig.Placeholder or "..."
				local callback = boxConfig.Callback or function() end

				local boxFrame = New("Frame", {
					Size = UDim2.new(1, 0, 0, 56),
					BackgroundColor3 = Themes.ElementHover,
					BorderSizePixel = 0,
					Parent = sectionContent,
				})
				ApplyCorner(boxFrame, UDim.new(0, 8))

				local boxLabel = New("TextLabel", {
					Size = UDim2.new(1, -16, 0, 18),
					Position = UDim2.new(0, 10, 0, 4),
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamSemibold,
					Text = boxName,
					TextColor3 = Themes.Text,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = boxFrame,
				})

				local textBox = New("TextBox", {
					Size = UDim2.new(1, -20, 0, 26),
					Position = UDim2.new(0, 10, 0, 26),
					BackgroundColor3 = Themes.ElementBg,
					BorderSizePixel = 0,
					Font = Enum.Font.GothamSemibold,
					Text = default,
					PlaceholderText = placeholder,
					TextColor3 = Themes.Text,
					PlaceholderColor3 = Themes.SubText,
					TextSize = 12,
					ClearTextOnFocus = false,
					Parent = boxFrame,
				})
				ApplyCorner(textBox, UDim.new(0, 6))
				ApplyPadding(textBox, 0, 0, 8, 8)

				textBox.FocusLost:Connect(function()
					callback(textBox.Text)
				end)

				return {
					Set = function(val)
						textBox.Text = tostring(val)
						callback(textBox.Text)
					end,
					Get = function() return textBox.Text end,
				}
			end

			return sectionObj
		end

		table.insert(window.Tabs, tabObj)
		if #window.Tabs == 1 then
			tabObj:Select()
		end

		return tabObj
	end

	function window:CreateFloatingButton()
		local floatSize = UDim2.new(0, 48, 0, 48)
		local floatBtn = New("Frame", {
			Name = "FloatingButton",
			Size = floatSize,
			Position = UDim2.new(0, 20, 0, 20),
			BackgroundColor3 = Themes.Accent,
			BorderSizePixel = 0,
			ZIndex = 100,
			Parent = screenGui,
		})
		ApplyCorner(floatBtn, UDim.new(0, 12))

		local floatStroke = ApplyStroke(floatBtn, Themes.Accent2, 1)
		floatStroke.Transparency = 0.3

		local floatShadow = New("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, 20, 1, 20),
			BackgroundTransparency = 1,
			Image = "rbxassetid://5554236805",
			ImageColor3 = Color3.fromRGB(0, 0, 0),
			ImageTransparency = 0.7,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(50, 50, 50, 50),
			ZIndex = 99,
			Parent = floatBtn,
		})

		local floatIcon = IconModule.Image({ Icon = "lucide:menu", Size = UDim2.new(0, 22, 0, 22), Colors = { Themes.Text } })
		if floatIcon and floatIcon.IconFrame then
			floatIcon.IconFrame.Position = UDim2.new(0.5, -11, 0.5, -11)
			floatIcon.IconFrame.Parent = floatBtn
		end

		local clickArea = New("TextButton", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = "",
			ZIndex = 101,
			Parent = floatBtn,
		})

		MakeDraggable(floatBtn)

		clickArea.MouseButton1Click:Connect(function()
			window:Show()
		end)

		Library.FloatingButton = floatBtn
		return floatBtn
	end

	table.insert(Library.Windows, window)
	Library.ActiveWindow = window

	return window
end

return Library
