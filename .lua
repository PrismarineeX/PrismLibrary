
local Prismarine = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local IconsModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/geist/dist/Icons.lua"))()

local Colors = {
    Background = Color3.fromRGB(8, 8, 16),
    Surface = Color3.fromRGB(16, 16, 28),
    SurfaceLight = Color3.fromRGB(24, 24, 40),
    Border = Color3.fromRGB(36, 36, 56),
    Primary = Color3.fromRGB(59, 130, 246),
    PrimaryDark = Color3.fromRGB(37, 99, 235),
    PrimaryLight = Color3.fromRGB(96, 165, 250),
    Text = Color3.fromRGB(248, 250, 252),
    TextDim = Color3.fromRGB(148, 163, 184),
    TextDark = Color3.fromRGB(100, 116, 139),
    White = Color3.fromRGB(255, 255, 255),
    Black = Color3.fromRGB(0, 0, 0),
    Success = Color3.fromRGB(34, 197, 94),
    Danger = Color3.fromRGB(239, 68, 68),
    Warning = Color3.fromRGB(234, 179, 8),
}

local function GetIcon(name, size)
    size = size or 16
    local iconData = IconsModule.Icons[name]
    if not iconData then return nil end

    local imageLabel = Instance.new("ImageLabel")
    imageLabel.BackgroundTransparency = 1
    imageLabel.Image = IconsModule.Spritesheets[tostring(iconData.Image)]
    imageLabel.ImageRectOffset = iconData.ImageRectPosition
    imageLabel.ImageRectSize = iconData.ImageRectSize
    imageLabel.Size = UDim2.fromOffset(size, size)
    imageLabel.ImageColor3 = Colors.Text

    return imageLabel
end

local function CreateIcon(name, size, parent, color)
    local icon = GetIcon(name, size)
    if not icon then return nil end
    if color then icon.ImageColor3 = color end
    if parent then icon.Parent = parent end
    return icon
end

local function RoundCorners(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = instance
    return corner
end

local function Stroke(instance, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Colors.Border
    stroke.Thickness = thickness or 1
    stroke.Parent = instance
    return stroke
end

local function Padding(instance, top, bottom, left, right)
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, top or 0)
    pad.PaddingBottom = UDim.new(0, bottom or 0)
    pad.PaddingLeft = UDim.new(0, left or 0)
    pad.PaddingRight = UDim.new(0, right or 0)
    pad.Parent = instance
    return pad
end

local Config = {
    AutoSaveInterval = 2,
    ConfigName = "PrismarineConfig.json",
}

local SavedConfig = {}

local function LoadConfig()
    local success, result = pcall(function()
        if readfile and isfile and isfile(Config.ConfigName) then
            return HttpService:JSONDecode(readfile(Config.ConfigName))
        end
        return {}
    end)
    SavedConfig = success and result or {}
end

local function SaveConfig()
    pcall(function()
        if writefile then
            writefile(Config.ConfigName, HttpService:JSONEncode(SavedConfig))
        end
    end)
end

local function SetConfigValue(key, value)
    SavedConfig[key] = value
    SaveConfig()
end

local function GetConfigValue(key, default)
    if SavedConfig[key] ~= nil then
        return SavedConfig[key]
    end
    return default
end

local function StartAutoSave()
    task.spawn(function()
        while true do
            task.wait(Config.AutoSaveInterval)
            SaveConfig()
        end
    end)
end

function Prismarine:Init(config)
    config = config or {}
    Config.AutoSaveInterval = config.AutoSaveInterval or 2
    Config.ConfigName = config.ConfigName or "PrismarineConfig.json"

    LoadConfig()
    StartAutoSave()
end

function Prismarine:SaveConfig()
    SaveConfig()
end

function Prismarine:LoadConfig()
    LoadConfig()
    return SavedConfig
end

function Prismarine:SetConfig(key, value)
    SetConfigValue(key, value)
end

function Prismarine:GetConfig(key, default)
    return GetConfigValue(key, default)
end

function Prismarine:CreateWindow(options)
    options = options or {}
    local title = options.Title or "Prismarine"
    local icon = options.Icon or "prism"
    local size = options.Size or UDim2.fromOffset(520, 340)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PrismarineUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = PlayerGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = size
    MainFrame.Position = UDim2.fromScale(0.5, 0.5)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Colors.Surface
    MainFrame.BackgroundTransparency = 0.05
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    RoundCorners(MainFrame, 14)
    Stroke(MainFrame, Colors.Border, 1)

    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 36)
    TopBar.BackgroundColor3 = Colors.Background
    TopBar.BackgroundTransparency = 0.3
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    RoundCorners(TopBar, 14)

    local TopBarIcon = CreateIcon(icon, 18, TopBar, Colors.Primary)
    TopBarIcon.Position = UDim2.fromOffset(12, 9)
    TopBarIcon.Name = "TopBarIcon"

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(0, 200, 1, 0)
    TitleLabel.Position = UDim2.fromOffset(36, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Colors.Text
    TitleLabel.TextSize = 13
    TitleLabel.Font = Enum.Font.GothamSemibold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TopBar

    local ButtonContainer = Instance.new("Frame")
    ButtonContainer.Name = "Buttons"
    ButtonContainer.Size = UDim2.new(0, 70, 1, 0)
    ButtonContainer.Position = UDim2.new(1, -78, 0, 0)
    ButtonContainer.BackgroundTransparency = 1
    ButtonContainer.Parent = TopBar

    local function CreateTopButton(name, iconName, color, callback)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Size = UDim2.fromOffset(22, 22)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.Parent = ButtonContainer

        local iconImg = CreateIcon(iconName, 14, btn, color)
        iconImg.Position = UDim2.fromOffset(4, 4)
        iconImg.Name = name .. "Icon"

        btn.MouseEnter:Connect(function()
            iconImg.ImageColor3 = Colors.White
        end)
        btn.MouseLeave:Connect(function()
            iconImg.ImageColor3 = color
        end)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    local Minimized = false
    local OriginalSize = size

    local MinimizeBtn = CreateTopButton("Minimize", "minus", Colors.TextDim, function()
        Minimized = not Minimized
        MainFrame.Visible = false
    end)
    MinimizeBtn.Position = UDim2.fromOffset(0, 7)

    local CloseBtn = CreateTopButton("Close", "cross", Colors.Danger, function()
        local ConfirmFrame = Instance.new("Frame")
        ConfirmFrame.Name = "ConfirmFrame"
        ConfirmFrame.Size = UDim2.new(1, 0, 1, 0)
        ConfirmFrame.BackgroundColor3 = Colors.Black
        ConfirmFrame.BackgroundTransparency = 0.6
        ConfirmFrame.BorderSizePixel = 0
        ConfirmFrame.ZIndex = 100
        ConfirmFrame.Parent = ScreenGui

        local ConfirmBox = Instance.new("Frame")
        ConfirmBox.Name = "ConfirmBox"
        ConfirmBox.Size = UDim2.fromOffset(280, 120)
        ConfirmBox.Position = UDim2.fromScale(0.5, 0.5)
        ConfirmBox.AnchorPoint = Vector2.new(0.5, 0.5)
        ConfirmBox.BackgroundColor3 = Colors.Surface
        ConfirmBox.BackgroundTransparency = 0.05
        ConfirmBox.BorderSizePixel = 0
        ConfirmBox.ZIndex = 101
        ConfirmBox.Parent = ConfirmFrame
        RoundCorners(ConfirmBox, 12)
        Stroke(ConfirmBox, Colors.Border, 1)

        local ConfirmTitle = Instance.new("TextLabel")
        ConfirmTitle.Name = "Title"
        ConfirmTitle.Size = UDim2.new(1, 0, 0, 30)
        ConfirmTitle.Position = UDim2.fromOffset(0, 12)
        ConfirmTitle.BackgroundTransparency = 1
        ConfirmTitle.Text = "Close Prismarine?"
        ConfirmTitle.TextColor3 = Colors.Text
        ConfirmTitle.TextSize = 14
        ConfirmTitle.Font = Enum.Font.GothamBold
        ConfirmTitle.ZIndex = 101
        ConfirmTitle.Parent = ConfirmBox

        local ConfirmText = Instance.new("TextLabel")
        ConfirmText.Name = "Text"
        ConfirmText.Size = UDim2.new(1, -24, 0, 20)
        ConfirmText.Position = UDim2.fromOffset(12, 42)
        ConfirmText.BackgroundTransparency = 1
        ConfirmText.Text = "Are you sure you want to close the UI?"
        ConfirmText.TextColor3 = Colors.TextDim
        ConfirmText.TextSize = 11
        ConfirmText.Font = Enum.Font.Gotham
        ConfirmText.TextWrapped = true
        ConfirmText.ZIndex = 101
        ConfirmText.Parent = ConfirmBox

        local BtnContainer = Instance.new("Frame")
        BtnContainer.Name = "Buttons"
        BtnContainer.Size = UDim2.new(1, -24, 0, 32)
        BtnContainer.Position = UDim2.fromOffset(12, 76)
        BtnContainer.BackgroundTransparency = 1
        BtnContainer.ZIndex = 101
        BtnContainer.Parent = ConfirmBox

        local YesBtn = Instance.new("TextButton")
        YesBtn.Name = "Yes"
        YesBtn.Size = UDim2.new(0.48, 0, 1, 0)
        YesBtn.BackgroundColor3 = Colors.Danger
        YesBtn.BackgroundTransparency = 0.2
        YesBtn.BorderSizePixel = 0
        YesBtn.Text = "Close"
        YesBtn.TextColor3 = Colors.White
        YesBtn.TextSize = 12
        YesBtn.Font = Enum.Font.GothamSemibold
        YesBtn.ZIndex = 101
        YesBtn.Parent = BtnContainer
        RoundCorners(YesBtn, 6)

        local NoBtn = Instance.new("TextButton")
        NoBtn.Name = "No"
        NoBtn.Size = UDim2.new(0.48, 0, 1, 0)
        NoBtn.Position = UDim2.new(0.52, 0, 0, 0)
        NoBtn.BackgroundColor3 = Colors.SurfaceLight
        NoBtn.BackgroundTransparency = 0.3
        NoBtn.BorderSizePixel = 0
        NoBtn.Text = "Cancel"
        NoBtn.TextColor3 = Colors.Text
        NoBtn.TextSize = 12
        NoBtn.Font = Enum.Font.GothamSemibold
        NoBtn.ZIndex = 101
        NoBtn.Parent = BtnContainer
        RoundCorners(NoBtn, 6)
        Stroke(NoBtn, Colors.Border, 1)

        YesBtn.MouseEnter:Connect(function()
            YesBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        end)
        YesBtn.MouseLeave:Connect(function()
            YesBtn.BackgroundColor3 = Colors.Danger
        end)
        YesBtn.MouseButton1Click:Connect(function()
            ScreenGui:Destroy()
        end)

        NoBtn.MouseEnter:Connect(function()
            NoBtn.BackgroundColor3 = Colors.Surface
        end)
        NoBtn.MouseLeave:Connect(function()
            NoBtn.BackgroundColor3 = Colors.SurfaceLight
        end)
        NoBtn.MouseButton1Click:Connect(function()
            ConfirmFrame:Destroy()
        end)
    end)
    CloseBtn.Position = UDim2.fromOffset(28, 7)

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "Content"
    ContentFrame.Size = UDim2.new(1, 0, 1, -36)
    ContentFrame.Position = UDim2.fromOffset(0, 36)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = MainFrame

    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 110, 1, 0)
    Sidebar.BackgroundColor3 = Colors.Background
    Sidebar.BackgroundTransparency = 0.5
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = ContentFrame
    RoundCorners(Sidebar, 14)

    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.Padding = UDim.new(0, 3)
    SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SidebarLayout.Parent = Sidebar

    Padding(Sidebar, 8, 8, 4, 4)

    local TabContent = Instance.new("Frame")
    TabContent.Name = "TabContent"
    TabContent.Size = UDim2.new(1, -110, 1, 0)
    TabContent.Position = UDim2.fromOffset(110, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.Parent = ContentFrame

    local Pages = {}
    local Tabs = {}
    local ActiveTab = nil

    local function SelectTab(tabName)
        for name, page in pairs(Pages) do
            page.Visible = (name == tabName)
        end
        for name, tab in pairs(Tabs) do
            if name == tabName then
                tab.BackgroundColor3 = Colors.SurfaceLight
                tab.Icon.ImageColor3 = Colors.Primary
                tab.Label.TextColor3 = Colors.Primary
            else
                tab.BackgroundColor3 = Colors.Background
                tab.Icon.ImageColor3 = Colors.TextDim
                tab.Label.TextColor3 = Colors.TextDim
            end
        end
        ActiveTab = tabName
    end

    local Window = {}
    Window.ScreenGui = ScreenGui
    Window.MainFrame = MainFrame
    Window.SavedConfig = SavedConfig

    function Window:AddTab(options)
        options = options or {}
        local tabName = options.Name or "Tab"
        local tabIcon = options.Icon or "box"

        local TabButton = Instance.new("TextButton")
        TabButton.Name = tabName
        TabButton.Size = UDim2.new(1, -8, 0, 32)
        TabButton.BackgroundColor3 = Colors.Background
        TabButton.BackgroundTransparency = 0.3
        TabButton.BorderSizePixel = 0
        TabButton.Text = ""
        TabButton.LayoutOrder = #Tabs + 1
        TabButton.Parent = Sidebar
        RoundCorners(TabButton, 8)

        local tabIconImg = CreateIcon(tabIcon, 16, TabButton, Colors.TextDim)
        tabIconImg.Position = UDim2.fromOffset(10, 8)
        tabIconImg.Name = "Icon"

        local tabLabel = Instance.new("TextLabel")
        tabLabel.Name = "Label"
        tabLabel.Size = UDim2.new(1, -36, 1, 0)
        tabLabel.Position = UDim2.fromOffset(32, 0)
        tabLabel.BackgroundTransparency = 1
        tabLabel.Text = tabName
        tabLabel.TextColor3 = Colors.TextDim
        tabLabel.TextSize = 11
        tabLabel.Font = Enum.Font.Gotham
        tabLabel.TextXAlignment = Enum.TextXAlignment.Left
        tabLabel.Parent = TabButton

        local Page = Instance.new("ScrollingFrame")
        Page.Name = tabName .. "Page"
        Page.Size = UDim2.new(1, -8, 1, -8)
        Page.Position = UDim2.fromOffset(4, 4)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Colors.Primary
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.Visible = false
        Page.Parent = TabContent

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 6)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        PageLayout.Parent = Page

        Padding(Page, 4, 4, 4, 4)

        TabButton.MouseButton1Click:Connect(function()
            SelectTab(tabName)
        end)

        Pages[tabName] = Page
        Tabs[tabName] = {Button = TabButton, Icon = tabIconImg, Label = tabLabel}

        if not ActiveTab then
            SelectTab(tabName)
        end

        local TabAPI = {}
        TabAPI.Page = Page

        function TabAPI:AddSection(options)
            options = options or {}
            local sectionTitle = options.Title or "Section"
            local collapsed = options.Collapsed or false

            local Section = Instance.new("Frame")
            Section.Name = sectionTitle
            Section.Size = UDim2.new(1, -4, 0, 0)
            Section.BackgroundColor3 = Colors.Surface
            Section.BackgroundTransparency = 0.15
            Section.BorderSizePixel = 0
            Section.AutomaticSize = Enum.AutomaticSize.Y
            Section.Parent = Page
            RoundCorners(Section, 10)
            Stroke(Section, Colors.Border, 1)

            local SectionHeader = Instance.new("TextButton")
            SectionHeader.Name = "Header"
            SectionHeader.Size = UDim2.new(1, 0, 0, 32)
            SectionHeader.BackgroundTransparency = 1
            SectionHeader.Text = ""
            SectionHeader.Parent = Section

            local HeaderIcon = CreateIcon("chevron-right", 14, SectionHeader, Colors.TextDim)
            HeaderIcon.Position = UDim2.fromOffset(10, 9)
            HeaderIcon.Name = "CollapseIcon"

            local HeaderTitle = Instance.new("TextLabel")
            HeaderTitle.Name = "Title"
            HeaderTitle.Size = UDim2.new(1, -40, 1, 0)
            HeaderTitle.Position = UDim2.fromOffset(30, 0)
            HeaderTitle.BackgroundTransparency = 1
            HeaderTitle.Text = sectionTitle
            HeaderTitle.TextColor3 = Colors.Text
            HeaderTitle.TextSize = 12
            HeaderTitle.Font = Enum.Font.GothamSemibold
            HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
            HeaderTitle.Parent = SectionHeader

            local SectionContent = Instance.new("Frame")
            SectionContent.Name = "Content"
            SectionContent.Size = UDim2.new(1, -16, 0, 0)
            SectionContent.Position = UDim2.fromOffset(8, 32)
            SectionContent.BackgroundTransparency = 1
            SectionContent.BorderSizePixel = 0
            SectionContent.AutomaticSize = Enum.AutomaticSize.Y
            SectionContent.Parent = Section

            local ContentLayout = Instance.new("UIListLayout")
            ContentLayout.Padding = UDim.new(0, 4)
            ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ContentLayout.Parent = SectionContent

            Padding(SectionContent, 0, 8, 0, 0)

            local IsCollapsed = collapsed

            local function UpdateCollapse()
                if IsCollapsed then
                    SectionContent.Visible = false
                    HeaderIcon.Rotation = 0
                else
                    SectionContent.Visible = true
                    HeaderIcon.Rotation = 90
                end
            end

            UpdateCollapse()

            SectionHeader.MouseButton1Click:Connect(function()
                IsCollapsed = not IsCollapsed
                UpdateCollapse()
            end)

            local SectionAPI = {}
            SectionAPI.Content = SectionContent

            function SectionAPI:AddParagraph(options)
                options = options or {}
                local text = options.Text or "Paragraph"
                local align = options.Alignment or Enum.TextXAlignment.Left

                local ParagraphFrame = Instance.new("Frame")
                ParagraphFrame.Name = "Paragraph"
                ParagraphFrame.Size = UDim2.new(1, 0, 0, 0)
                ParagraphFrame.BackgroundTransparency = 1
                ParagraphFrame.AutomaticSize = Enum.AutomaticSize.Y
                ParagraphFrame.Parent = SectionContent

                local ParagraphLabel = Instance.new("TextLabel")
                ParagraphLabel.Name = "Text"
                ParagraphLabel.Size = UDim2.new(1, 0, 0, 0)
                ParagraphLabel.BackgroundTransparency = 1
                ParagraphLabel.Text = text
                ParagraphLabel.TextColor3 = Colors.TextDim
                ParagraphLabel.TextSize = 11
                ParagraphLabel.Font = Enum.Font.Gotham
                ParagraphLabel.TextXAlignment = align
                ParagraphLabel.TextWrapped = true
                ParagraphLabel.AutomaticSize = Enum.AutomaticSize.Y
                ParagraphLabel.Parent = ParagraphFrame

                return ParagraphLabel
            end

            function SectionAPI:AddDivider(options)
                options = options or {}
                local text = options.Text

                local DividerFrame = Instance.new("Frame")
                DividerFrame.Name = "Divider"
                DividerFrame.Size = UDim2.new(1, 0, 0, text and 24 or 12)
                DividerFrame.BackgroundTransparency = 1
                DividerFrame.Parent = SectionContent

                local LineLeft = Instance.new("Frame")
                LineLeft.Name = "LineLeft"
                LineLeft.Size = UDim2.new(0.5, text and -50 or 0, 0, 1)
                LineLeft.Position = UDim2.new(0, 0, 0.5, 0)
                LineLeft.BackgroundColor3 = Colors.Border
                LineLeft.BorderSizePixel = 0
                LineLeft.Parent = DividerFrame

                if text then
                    local DividerText = Instance.new("TextLabel")
                    DividerText.Name = "Text"
                    DividerText.Size = UDim2.new(0, 100, 1, 0)
                    DividerText.Position = UDim2.new(0.5, -50, 0, 0)
                    DividerText.BackgroundTransparency = 1
                    DividerText.Text = text
                    DividerText.TextColor3 = Colors.TextDark
                    DividerText.TextSize = 10
                    DividerText.Font = Enum.Font.Gotham
                    DividerText.TextXAlignment = Enum.TextXAlignment.Center
                    DividerText.Parent = DividerFrame
                end

                local LineRight = Instance.new("Frame")
                LineRight.Name = "LineRight"
                LineRight.Size = UDim2.new(0.5, text and -50 or 0, 0, 1)
                LineRight.Position = UDim2.new(0.5, text and 50 or 0, 0.5, 0)
                LineRight.BackgroundColor3 = Colors.Border
                LineRight.BorderSizePixel = 0
                LineRight.Parent = DividerFrame

                return DividerFrame
            end

            function SectionAPI:AddKeybind(options)
                options = options or {}
                local bindName = options.Name or "Keybind"
                local default = options.Default or Enum.KeyCode.Unknown
                local callback = options.Callback or function() end
                local flag = options.Flag

                if flag then
                    local saved = GetConfigValue(flag, nil)
                    if saved then
                        default = Enum.KeyCode[saved] or default
                    end
                end

                local BindFrame = Instance.new("Frame")
                BindFrame.Name = bindName
                BindFrame.Size = UDim2.new(1, 0, 0, 28)
                BindFrame.BackgroundTransparency = 1
                BindFrame.Parent = SectionContent

                local BindLabel = Instance.new("TextLabel")
                BindLabel.Name = "Label"
                BindLabel.Size = UDim2.new(1, -80, 1, 0)
                BindLabel.BackgroundTransparency = 1
                BindLabel.Text = bindName
                BindLabel.TextColor3 = Colors.TextDim
                BindLabel.TextSize = 11
                BindLabel.Font = Enum.Font.Gotham
                BindLabel.TextXAlignment = Enum.TextXAlignment.Left
                BindLabel.Parent = BindFrame

                local BindButton = Instance.new("TextButton")
                BindButton.Name = "Bind"
                BindButton.Size = UDim2.fromOffset(70, 22)
                BindButton.Position = UDim2.new(1, -74, 0.5, -11)
                BindButton.BackgroundColor3 = Colors.SurfaceLight
                BindButton.BackgroundTransparency = 0.3
                BindButton.BorderSizePixel = 0
                BindButton.Text = default.Name ~= "Unknown" and default.Name or "None"
                BindButton.TextColor3 = Colors.TextDim
                BindButton.TextSize = 10
                BindButton.Font = Enum.Font.Gotham
                BindButton.Parent = BindFrame
                RoundCorners(BindButton, 4)
                Stroke(BindButton, Colors.Border, 1)

                local CurrentKey = default
                local Listening = false

                BindButton.MouseButton1Click:Connect(function()
                    Listening = true
                    BindButton.Text = "..."
                    BindButton.TextColor3 = Colors.Primary
                end)

                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if Listening and not gameProcessed then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            CurrentKey = input.KeyCode
                            BindButton.Text = CurrentKey.Name
                            BindButton.TextColor3 = Colors.TextDim
                            Listening = false
                            callback(CurrentKey)
                            if flag then
                                SetConfigValue(flag, CurrentKey.Name)
                            end
                        end
                    elseif CurrentKey ~= Enum.KeyCode.Unknown and input.KeyCode == CurrentKey and not gameProcessed then
                        callback(CurrentKey)
                    end
                end)

                return {Set = function(k) CurrentKey = k; BindButton.Text = k.Name end, Get = function() return CurrentKey end}
            end

            function SectionAPI:AddToggle(options)
                options = options or {}
                local toggleName = options.Name or "Toggle"
                local default = options.Default or false
                local callback = options.Callback or function() end
                local flag = options.Flag

                if flag then
                    default = GetConfigValue(flag, default)
                end

                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Name = toggleName
                ToggleFrame.Size = UDim2.new(1, 0, 0, 28)
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.Parent = SectionContent

                local ToggleLabel = Instance.new("TextLabel")
                ToggleLabel.Name = "Label"
                ToggleLabel.Size = UDim2.new(1, -50, 1, 0)
                ToggleLabel.BackgroundTransparency = 1
                ToggleLabel.Text = toggleName
                ToggleLabel.TextColor3 = Colors.TextDim
                ToggleLabel.TextSize = 11
                ToggleLabel.Font = Enum.Font.Gotham
                ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                ToggleLabel.Parent = ToggleFrame

                local ToggleButton = Instance.new("TextButton")
                ToggleButton.Name = "Toggle"
                ToggleButton.Size = UDim2.fromOffset(36, 18)
                ToggleButton.Position = UDim2.new(1, -40, 0.5, -9)
                ToggleButton.BackgroundColor3 = Colors.SurfaceLight
                ToggleButton.BorderSizePixel = 0
                ToggleButton.Text = ""
                ToggleButton.Parent = ToggleFrame
                RoundCorners(ToggleButton, 9)
                Stroke(ToggleButton, Colors.Border, 1)

                local ToggleCircle = Instance.new("Frame")
                ToggleCircle.Name = "Circle"
                ToggleCircle.Size = UDim2.fromOffset(14, 14)
                ToggleCircle.Position = UDim2.fromOffset(2, 2)
                ToggleCircle.BackgroundColor3 = Colors.TextDim
                ToggleCircle.BorderSizePixel = 0
                ToggleCircle.Parent = ToggleButton
                RoundCorners(ToggleCircle, 7)

                local Enabled = default

                local function UpdateToggle()
                    if Enabled then
                        ToggleButton.BackgroundColor3 = Colors.Primary
                        ToggleCircle.BackgroundColor3 = Colors.White
                        ToggleCircle.Position = UDim2.fromOffset(20, 2)
                        ToggleLabel.TextColor3 = Colors.Text
                    else
                        ToggleButton.BackgroundColor3 = Colors.SurfaceLight
                        ToggleCircle.BackgroundColor3 = Colors.TextDim
                        ToggleCircle.Position = UDim2.fromOffset(2, 2)
                        ToggleLabel.TextColor3 = Colors.TextDim
                    end
                    callback(Enabled)
                    if flag then
                        SetConfigValue(flag, Enabled)
                    end
                end

                UpdateToggle()

                ToggleButton.MouseButton1Click:Connect(function()
                    Enabled = not Enabled
                    UpdateToggle()
                end)

                return {Set = function(v) Enabled = v; UpdateToggle() end, Get = function() return Enabled end}
            end

            function SectionAPI:AddDropdown(options)
                options = options or {}
                local dropName = options.Name or "Dropdown"
                local items = options.Items or {}
                local default = options.Default
                local callback = options.Callback or function() end
                local flag = options.Flag

                if flag then
                    default = GetConfigValue(flag, default)
                end

                local DropdownFrame = Instance.new("Frame")
                DropdownFrame.Name = dropName
                DropdownFrame.Size = UDim2.new(1, 0, 0, 28)
                DropdownFrame.BackgroundTransparency = 1
                DropdownFrame.Parent = SectionContent
                DropdownFrame.ClipsDescendants = true
                DropdownFrame.AutomaticSize = Enum.AutomaticSize.Y

                local DisplayFrame = Instance.new("Frame")
                DisplayFrame.Name = "Display"
                DisplayFrame.Size = UDim2.new(1, -32, 0, 28)
                DisplayFrame.BackgroundColor3 = Colors.SurfaceLight
                DisplayFrame.BackgroundTransparency = 0.3
                DisplayFrame.BorderSizePixel = 0
                DisplayFrame.Parent = DropdownFrame
                RoundCorners(DisplayFrame, 6)
                Stroke(DisplayFrame, Colors.Border, 1)

                local DropdownLabel = Instance.new("TextLabel")
                DropdownLabel.Name = "Label"
                DropdownLabel.Size = UDim2.new(1, -10, 1, 0)
                DropdownLabel.Position = UDim2.fromOffset(10, 0)
                DropdownLabel.BackgroundTransparency = 1
                DropdownLabel.Text = "Select Option"
                DropdownLabel.TextColor3 = Colors.TextDim
                DropdownLabel.TextSize = 11
                DropdownLabel.Font = Enum.Font.Gotham
                DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                DropdownLabel.Parent = DisplayFrame

                local DropdownArrow = Instance.new("TextButton")
                DropdownArrow.Name = "Arrow"
                DropdownArrow.Size = UDim2.fromOffset(28, 28)
                DropdownArrow.Position = UDim2.new(1, -28, 0, 0)
                DropdownArrow.BackgroundColor3 = Colors.SurfaceLight
                DropdownArrow.BackgroundTransparency = 0.3
                DropdownArrow.BorderSizePixel = 0
                DropdownArrow.Text = ""
                DropdownArrow.Parent = DropdownFrame
                RoundCorners(DropdownArrow, 6)
                Stroke(DropdownArrow, Colors.Border, 1)

                local ArrowIcon = CreateIcon("chevron-down", 12, DropdownArrow, Colors.TextDim)
                ArrowIcon.Position = UDim2.fromOffset(8, 8)
                ArrowIcon.Name = "ArrowIcon"

                local Selected = default
                local Opened = false
                local Overlay = nil
                local ItemsFrame = nil

                local function UpdateDropdown()
                    if Selected then
                        DropdownLabel.Text = tostring(Selected)
                        DropdownLabel.TextColor3 = Colors.Text
                    else
                        DropdownLabel.Text = "Select Option"
                        DropdownLabel.TextColor3 = Colors.TextDim
                    end
                    callback(Selected)
                    if flag then
                        SetConfigValue(flag, Selected)
                    end
                end

                local function CloseDropdown()
                    if not Opened then return end
                    Opened = false
                    ArrowIcon.Rotation = 0
                    if Overlay then
                        Overlay:Destroy()
                        Overlay = nil
                    end
                    if ItemsFrame then
                        ItemsFrame:Destroy()
                        ItemsFrame = nil
                    end
                end

                local function OpenDropdown()
                    if Opened then
                        CloseDropdown()
                        return
                    end
                    Opened = true
                    ArrowIcon.Rotation = 180

                    local mainAbsPos = MainFrame.AbsolutePosition
                    local mainAbsSize = MainFrame.AbsoluteSize
                    local dropdownAbsPos = DropdownArrow.AbsolutePosition
                    local dropdownAbsSize = DropdownArrow.AbsoluteSize

                    Overlay = Instance.new("TextButton")
                    Overlay.Name = "Overlay"
                    Overlay.Size = UDim2.new(1, 0, 1, 0)
                    Overlay.BackgroundColor3 = Colors.Black
                    Overlay.BackgroundTransparency = 0.5
                    Overlay.BorderSizePixel = 0
                    Overlay.Text = ""
                    Overlay.ZIndex = 50
                    Overlay.Parent = ScreenGui

                    ItemsFrame = Instance.new("Frame")
                    ItemsFrame.Name = "Items"
                    ItemsFrame.Size = UDim2.fromOffset(180, 0)
                    ItemsFrame.Position = UDim2.fromOffset(
                        dropdownAbsPos.X + dropdownAbsSize.X - 180,
                        mainAbsPos.Y + 40
                    )
                    ItemsFrame.BackgroundColor3 = Colors.Surface
                    ItemsFrame.BackgroundTransparency = 0.05
                    ItemsFrame.BorderSizePixel = 0
                    ItemsFrame.ZIndex = 51
                    ItemsFrame.Parent = ScreenGui
                    ItemsFrame.AutomaticSize = Enum.AutomaticSize.Y
                    RoundCorners(ItemsFrame, 10)
                    Stroke(ItemsFrame, Colors.Border, 1)

                    local maxHeight = mainAbsSize.Y - 50
                    local totalItemsHeight = #items * 28 + 8
                    if totalItemsHeight > maxHeight then
                        ItemsFrame.Size = UDim2.fromOffset(180, maxHeight)
                    end

                    local ItemsScroll = Instance.new("ScrollingFrame")
                    ItemsScroll.Name = "Scroll"
                    ItemsScroll.Size = UDim2.new(1, 0, 1, 0)
                    ItemsScroll.BackgroundTransparency = 1
                    ItemsScroll.BorderSizePixel = 0
                    ItemsScroll.ScrollBarThickness = 2
                    ItemsScroll.ScrollBarImageColor3 = Colors.Primary
                    ItemsScroll.CanvasSize = UDim2.new(0, 0, 0, totalItemsHeight)
                    ItemsScroll.ZIndex = 52
                    ItemsScroll.Parent = ItemsFrame

                    local ItemsLayout = Instance.new("UIListLayout")
                    ItemsLayout.Padding = UDim.new(0, 1)
                    ItemsLayout.SortOrder = Enum.SortOrder.LayoutOrder
                    ItemsLayout.Parent = ItemsScroll

                    Padding(ItemsScroll, 4, 4, 4, 4)

                    for _, item in ipairs(items) do
                        local ItemBtn = Instance.new("TextButton")
                        ItemBtn.Name = tostring(item)
                        ItemBtn.Size = UDim2.new(1, 0, 0, 28)
                        ItemBtn.BackgroundTransparency = 1
                        ItemBtn.Text = tostring(item)
                        ItemBtn.TextColor3 = Colors.TextDim
                        ItemBtn.TextSize = 11
                        ItemBtn.Font = Enum.Font.Gotham
                        ItemBtn.ZIndex = 53
                        ItemBtn.Parent = ItemsScroll
                        RoundCorners(ItemBtn, 4)

                        if item == Selected then
                            ItemBtn.BackgroundColor3 = Colors.Primary
                            ItemBtn.BackgroundTransparency = 0.85
                            ItemBtn.TextColor3 = Colors.Primary
                        end

                        ItemBtn.MouseEnter:Connect(function()
                            if item ~= Selected then
                                ItemBtn.BackgroundColor3 = Colors.SurfaceLight
                                ItemBtn.BackgroundTransparency = 0.3
                                ItemBtn.TextColor3 = Colors.Text
                            end
                        end)
                        ItemBtn.MouseLeave:Connect(function()
                            if item ~= Selected then
                                ItemBtn.BackgroundTransparency = 1
                                ItemBtn.TextColor3 = Colors.TextDim
                            end
                        end)
                        ItemBtn.MouseButton1Click:Connect(function()
                            Selected = item
                            UpdateDropdown()
                            CloseDropdown()
                        end)
                    end

                    Overlay.MouseButton1Click:Connect(function()
                        CloseDropdown()
                    end)
                end

                UpdateDropdown()

                DropdownArrow.MouseButton1Click:Connect(function()
                    OpenDropdown()
                end)

                return {Set = function(v) Selected = v; UpdateDropdown() end, Get = function() return Selected end}
            end

            function SectionAPI:AddSlider(options)
                options = options or {}
                local sliderName = options.Name or "Slider"
                local min = options.Min or 0
                local max = options.Max or 100
                local default = options.Default or min
                local increment = options.Increment or 1
                local callback = options.Callback or function() end
                local flag = options.Flag
                local suffix = options.Suffix or ""

                if flag then
                    default = GetConfigValue(flag, default)
                end

                local SliderFrame = Instance.new("Frame")
                SliderFrame.Name = sliderName
                SliderFrame.Size = UDim2.new(1, 0, 0, 40)
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.Parent = SectionContent

                local SliderLabel = Instance.new("TextLabel")
                SliderLabel.Name = "Label"
                SliderLabel.Size = UDim2.new(1, -50, 0, 16)
                SliderLabel.BackgroundTransparency = 1
                SliderLabel.Text = sliderName
                SliderLabel.TextColor3 = Colors.TextDim
                SliderLabel.TextSize = 11
                SliderLabel.Font = Enum.Font.Gotham
                SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                SliderLabel.Parent = SliderFrame

                local ValueLabel = Instance.new("TextLabel")
                ValueLabel.Name = "Value"
                ValueLabel.Size = UDim2.new(0, 50, 0, 16)
                ValueLabel.Position = UDim2.new(1, -50, 0, 0)
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.Text = tostring(default) .. suffix
                            ValueLabel.TextColor3 = Colors.Primary
                ValueLabel.TextSize = 11
                ValueLabel.Font = Enum.Font.GothamBold
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValueLabel.Parent = SliderFrame

                local Track = Instance.new("Frame")
                Track.Name = "Track"
                Track.Size = UDim2.new(1, 0, 0, 4)
                Track.Position = UDim2.fromOffset(0, 24)
                Track.BackgroundColor3 = Colors.SurfaceLight
                Track.BorderSizePixel = 0
                Track.Parent = SliderFrame
                RoundCorners(Track, 2)

                local Fill = Instance.new("Frame")
                Fill.Name = "Fill"
                Fill.Size = UDim2.new(0, 0, 1, 0)
                Fill.BackgroundColor3 = Colors.Primary
                Fill.BorderSizePixel = 0
                Fill.Parent = Track
                RoundCorners(Fill, 2)

                local Knob = Instance.new("Frame")
                Knob.Name = "Knob"
                Knob.Size = UDim2.fromOffset(12, 12)
                Knob.Position = UDim2.new(0, 0, 0.5, -6)
                Knob.BackgroundColor3 = Colors.White
                Knob.BorderSizePixel = 0
                Knob.Parent = Track
                RoundCorners(Knob, 6)

                local Value = default
                local Dragging = false

                local function UpdateSlider()
                    Value = math.clamp(Value, min, max)
                    Value = math.floor(Value / increment + 0.5) * increment
                    local percent = (Value - min) / (max - min)
                    Fill.Size = UDim2.new(percent, 0, 1, 0)
                    Knob.Position = UDim2.new(percent, -6, 0.5, -6)
                    ValueLabel.Text = tostring(Value) .. suffix
                    callback(Value)
                    if flag then
                        SetConfigValue(flag, Value)
                    end
                end

                UpdateSlider()

                local function SetFromInput(input)
                    local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    Value = min + (max - min) * pos
                    UpdateSlider()
                end

                Knob.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        Dragging = true
                    end
                end)

                Track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        Dragging = true
                        SetFromInput(input)
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        SetFromInput(input)
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        Dragging = false
                    end
                end)

                return {Set = function(v) Value = v; UpdateSlider() end, Get = function() return Value end}
            end

            function SectionAPI:AddButton(options)
                options = options or {}
                local btnName = options.Name or "Button"
                local btnCallback = options.Callback or function() end
                local btnIcon = options.Icon

                local ButtonFrame = Instance.new("TextButton")
                ButtonFrame.Name = btnName
                ButtonFrame.Size = UDim2.new(1, 0, 0, 28)
                ButtonFrame.BackgroundColor3 = Colors.Primary
                ButtonFrame.BackgroundTransparency = 0.2
                ButtonFrame.BorderSizePixel = 0
                ButtonFrame.Text = ""
                ButtonFrame.Parent = SectionContent
                RoundCorners(ButtonFrame, 6)

                local BtnLabel = Instance.new("TextLabel")
                BtnLabel.Name = "Label"
                BtnLabel.Size = UDim2.new(1, -20, 1, 0)
                BtnLabel.Position = UDim2.fromOffset(10, 0)
                BtnLabel.BackgroundTransparency = 1
                BtnLabel.Text = btnName
                BtnLabel.TextColor3 = Colors.White
                BtnLabel.TextSize = 11
                BtnLabel.Font = Enum.Font.GothamSemibold
                BtnLabel.Parent = ButtonFrame

                if btnIcon then
                    BtnLabel.Position = UDim2.fromOffset(32, 0)
                    local bIcon = CreateIcon(btnIcon, 14, ButtonFrame, Colors.White)
                    bIcon.Position = UDim2.fromOffset(10, 7)
                    bIcon.Name = "Icon"
                end

                ButtonFrame.MouseEnter:Connect(function()
                    ButtonFrame.BackgroundColor3 = Colors.PrimaryLight
                end)
                ButtonFrame.MouseLeave:Connect(function()
                    ButtonFrame.BackgroundColor3 = Colors.Primary
                end)
                ButtonFrame.MouseButton1Click:Connect(btnCallback)

                return ButtonFrame
            end

            function SectionAPI:AddInput(options)
                options = options or {}
                local inputName = options.Name or "Input"
                local placeholder = options.Placeholder or ""
                local default = options.Default or ""
                local callback = options.Callback or function() end
                local flag = options.Flag
                local numeric = options.Numeric or false

                if flag then
                    default = GetConfigValue(flag, default)
                end

                local InputFrame = Instance.new("Frame")
                InputFrame.Name = inputName
                InputFrame.Size = UDim2.new(1, 0, 0, 28)
                InputFrame.BackgroundTransparency = 1
                InputFrame.Parent = SectionContent

                local InputLabel = Instance.new("TextLabel")
                InputLabel.Name = "Label"
                InputLabel.Size = UDim2.new(1, -10, 0, 14)
                InputLabel.BackgroundTransparency = 1
                InputLabel.Text = inputName
                InputLabel.TextColor3 = Colors.TextDim
                InputLabel.TextSize = 10
                InputLabel.Font = Enum.Font.Gotham
                InputLabel.TextXAlignment = Enum.TextXAlignment.Left
                InputLabel.Parent = InputFrame

                local TextBox = Instance.new("TextBox")
                TextBox.Name = "TextBox"
                TextBox.Size = UDim2.new(1, 0, 0, 24)
                TextBox.Position = UDim2.fromOffset(0, 14)
                TextBox.BackgroundColor3 = Colors.SurfaceLight
                TextBox.BackgroundTransparency = 0.3
                TextBox.BorderSizePixel = 0
                TextBox.Text = default
                TextBox.PlaceholderText = placeholder
                TextBox.TextColor3 = Colors.Text
                TextBox.PlaceholderColor3 = Colors.TextDark
                TextBox.TextSize = 11
                TextBox.Font = Enum.Font.Gotham
                TextBox.ClearTextOnFocus = false
                TextBox.Parent = InputFrame
                RoundCorners(TextBox, 6)
                Stroke(TextBox, Colors.Border, 1)
                Padding(TextBox, 0, 0, 8, 8)

                TextBox.FocusLost:Connect(function()
                    if numeric then
                        local num = tonumber(TextBox.Text)
                        if num then
                            TextBox.Text = tostring(num)
                            callback(num)
                            if flag then
                                SetConfigValue(flag, num)
                            end
                        else
                            TextBox.Text = tostring(default)
                        end
                    else
                        callback(TextBox.Text)
                        if flag then
                            SetConfigValue(flag, TextBox.Text)
                        end
                    end
                end)

                return {Set = function(v) TextBox.Text = v; callback(v) end, Get = function() return TextBox.Text end}
            end

            function SectionAPI:AddLabel(options)
                options = options or {}
                local text = options.Text or "Label"

                local LabelFrame = Instance.new("TextLabel")
                LabelFrame.Name = "Label"
                LabelFrame.Size = UDim2.new(1, 0, 0, 18)
                LabelFrame.BackgroundTransparency = 1
                LabelFrame.Text = text
                LabelFrame.TextColor3 = Colors.TextDim
                LabelFrame.TextSize = 11
                LabelFrame.Font = Enum.Font.Gotham
                LabelFrame.TextXAlignment = Enum.TextXAlignment.Left
                LabelFrame.Parent = SectionContent

                return LabelFrame
            end

            function SectionAPI:AddCheckbox(options)
                options = options or {}
                local checkName = options.Name or "Checkbox"
                local default = options.Default or false
                local callback = options.Callback or function() end
                local flag = options.Flag

                if flag then
                    default = GetConfigValue(flag, default)
                end

                local CheckFrame = Instance.new("Frame")
                CheckFrame.Name = checkName
                CheckFrame.Size = UDim2.new(1, 0, 0, 28)
                CheckFrame.BackgroundTransparency = 1
                CheckFrame.Parent = SectionContent

                local CheckBox = Instance.new("TextButton")
                CheckBox.Name = "Box"
                CheckBox.Size = UDim2.fromOffset(18, 18)
                CheckBox.Position = UDim2.new(0, 0, 0.5, -9)
                CheckBox.BackgroundColor3 = Colors.SurfaceLight
                CheckBox.BackgroundTransparency = 0.3
                CheckBox.BorderSizePixel = 0
                CheckBox.Text = ""
                CheckBox.Parent = CheckFrame
                RoundCorners(CheckBox, 4)
                Stroke(CheckBox, Colors.Border, 1)

                local CheckMark = CreateIcon("check", 12, CheckBox, Colors.Primary)
                CheckMark.Position = UDim2.fromOffset(3, 3)
                CheckMark.Name = "CheckMark"
                CheckMark.Visible = default

                local CheckLabel = Instance.new("TextLabel")
                CheckLabel.Name = "Label"
                CheckLabel.Size = UDim2.new(1, -28, 1, 0)
                CheckLabel.Position = UDim2.fromOffset(26, 0)
                CheckLabel.BackgroundTransparency = 1
                CheckLabel.Text = checkName
                CheckLabel.TextColor3 = Colors.TextDim
                CheckLabel.TextSize = 11
                CheckLabel.Font = Enum.Font.Gotham
                CheckLabel.TextXAlignment = Enum.TextXAlignment.Left
                CheckLabel.Parent = CheckFrame

                local Checked = default

                local function UpdateCheckbox()
                    CheckMark.Visible = Checked
                    if Checked then
                        CheckBox.BackgroundColor3 = Colors.Primary
                        CheckBox.BackgroundTransparency = 0.8
                        CheckLabel.TextColor3 = Colors.Text
                    else
                        CheckBox.BackgroundColor3 = Colors.SurfaceLight
                        CheckBox.BackgroundTransparency = 0.3
                        CheckLabel.TextColor3 = Colors.TextDim
                    end
                    callback(Checked)
                    if flag then
                        SetConfigValue(flag, Checked)
                    end
                end

                UpdateCheckbox()

                CheckBox.MouseButton1Click:Connect(function()
                    Checked = not Checked
                    UpdateCheckbox()
                end)

                CheckLabel.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Checked = not Checked
                        UpdateCheckbox()
                    end
                end)

                return {Set = function(v) Checked = v; UpdateCheckbox() end, Get = function() return Checked end}
            end

            return SectionAPI
        end

        return TabAPI
    end

    local Dragging = false
    local DragStart = nil
    local StartPos = nil

    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPos = MainFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - DragStart
            MainFrame.Position = UDim2.new(
                StartPos.X.Scale, StartPos.X.Offset + delta.X,
                StartPos.Y.Scale, StartPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
        end
    end)

    local FloatingBtn = Instance.new("ImageButton")
    FloatingBtn.Name = "FloatingButton"
    FloatingBtn.Size = UDim2.fromOffset(48, 48)
    FloatingBtn.Position = UDim2.fromOffset(20, 200)
    FloatingBtn.BackgroundTransparency = 1
    FloatingBtn.BorderSizePixel = 0
    FloatingBtn.Image = "rbxassetid://117448160741688"
    FloatingBtn.Parent = ScreenGui
    RoundCorners(FloatingBtn, 12)

    local FDragging = false
    local FDragStart = nil
    local FStartPos = nil
    local ClickThreshold = 0.2
    local ClickStart = 0

    FloatingBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            FDragging = true
            FDragStart = input.Position
            FStartPos = FloatingBtn.Position
            ClickStart = tick()
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if FDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - FDragStart
            FloatingBtn.Position = UDim2.new(
                FStartPos.X.Scale, FStartPos.X.Offset + delta.X,
                FStartPos.Y.Scale, FStartPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local elapsed = tick() - ClickStart
            FDragging = false
            if elapsed < ClickThreshold then
                MainFrame.Visible = not MainFrame.Visible
            end
        end
    end)

    function Window:ToggleVisibility()
        MainFrame.Visible = not MainFrame.Visible
    end

    function Window:SetVisible(visible)
        MainFrame.Visible = visible
    end

    function Window:Destroy()
        ScreenGui:Destroy()
    end

    return Window
end

return Prismarine
