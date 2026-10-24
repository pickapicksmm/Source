-- PICKA'S HUB loader + full API demo
-- 1) Upload PickasHub.lua to your GitHub repo.  2) Paste this whole script into your executor.
-- Library v3.0.0. Every API of the library is used below, so you can copy any part into your own script.
local URL = "https://raw.githubusercontent.com/pickapicksmm/Source/refs/heads/main/Script/PickasHub.lua"

local function fail(msg)
    msg = "PICKA'S HUB ERROR:\n" .. tostring(msg)
    warn(msg)
    pcall(function() (setclipboard or toclipboard)(msg) end)
    pcall(function()
        local g = Instance.new("ScreenGui") g.Name = "PickasHubError" g.ResetOnSpawn = false g.IgnoreGuiInset = true g.DisplayOrder = 1000
        g.Parent = (gethui and gethui()) or game:GetService("CoreGui")
        local f = Instance.new("Frame") f.Size = UDim2.new(.9, 0, 0, 220) f.Position = UDim2.new(.05, 0, .05, 0) f.BackgroundColor3 = Color3.fromRGB(35, 10, 20) f.Parent = g
        local t = Instance.new("TextLabel") t.Size = UDim2.new(1, -12, 1, -12) t.Position = UDim2.fromOffset(6, 6) t.BackgroundTransparency = 1
        t.TextColor3 = Color3.fromRGB(255, 170, 170) t.TextWrapped = true t.TextSize = 13 t.Font = Enum.Font.Code
        t.TextXAlignment = Enum.TextXAlignment.Left t.TextYAlignment = Enum.TextYAlignment.Top t.Text = msg .. "\n(copied to clipboard)" t.Parent = f
    end)
end

print("[PickasHub] 1/3 downloading...")
local okGet, src = pcall(function() return game:HttpGet(URL) end)
if not okGet or type(src) ~= "string" or #src < 100 then return fail("Download failed. Check the raw link and that the file is uploaded.\n" .. tostring(src)) end

print("[PickasHub] 2/3 compiling... (" .. #src .. " bytes)")
local fn, cerr = loadstring(src)
if not fn then return fail("Compile error: " .. tostring(cerr)) end

print("[PickasHub] 3/3 running...")
local okRun, Library = xpcall(fn, function(e) return tostring(e) .. "\n" .. debug.traceback() end)
if not okRun then return fail("Runtime error: " .. tostring(Library)) end
print("[PickasHub] library v" .. tostring(Library.Version))

---------------------------------------------------------------- your script below
local okM, errM = xpcall(function()
    local N = function(t, c, ty) Library:Notify({ Title = t, Content = c, Type = ty or "Info" }) end

    ----------------------------------------------------------- WINDOW
    local Window = Library:CreateWindow({
        Title = "Picka's Hub",                 -- window title
        -- Tag = "Android",                    -- device tag (auto-detected when omitted)
        -- Game = "My Game",                   -- game tag (auto-detected when omitted)
        -- Size = Vector2.new(620, 400),
        OpenSize = 48,                         -- size of the floating open button
        ToggleKey = Enum.KeyCode.RightShift,   -- desktop hotkey
        FloatImage = 109882288573862,          -- image asset of the floating button
        -- General = false,                    -- set to false to hide the built-in General tab
    })
    Window:AddTag({ Text = "v1.0", Icon = "tag" })                       -- extra tag in the title
    Window:AddTag({ Text = "VIP", Icon = "crown", Color = Color3.fromRGB(255, 200, 80) })
    Window:SetUserCard({ Status = "Online" })                            -- UserId / Display / Name / Status

    ----------------------------------------------------------- TAB 1: CONTROLS
    local Controls = Window:AddTab({ Title = "Controls", Icon = "sliders-horizontal" })

    local Basic = Controls:AddSubTab({ Title = "Basic", Icon = "mouse-pointer-click" })
    Basic:AddSection({ Title = "Buttons" })
    Basic:AddButton({ Title = "Notification", ButtonText = "Test", Icon = "bell", Tooltip = "Shows a notification",
        Callback = function() N("Hello", "This is a notification.", "Success") end })
    Basic:AddSection({ Title = "Switches" })
    local tg = Basic:AddToggle({ Title = "Toggle", Default = false, Flag = "Toggle", Callback = function(v) print("Toggle", v) end })
    Basic:AddCheckbox({ Title = "Checkbox", Default = true, Flag = "Checkbox", Callback = function(v) print("Checkbox", v) end })
    Basic:AddRadio({ Title = "Radio", Options = { "Easy", "Normal", "Hard" }, Default = "Normal", Flag = "Radio", Callback = function(v) print("Radio", v) end })
    Basic:AddButton({ Title = "Set toggle on", ButtonText = "Set", Icon = "check", Callback = function() tg:Set(true) print("Get:", tg:Get()) end })

    local Values = Controls:AddSubTab({ Title = "Values", Icon = "sliders-horizontal" })
    Values:AddSection({ Title = "Numbers" })
    Values:AddSlider({ Title = "Slider", Min = 0, Max = 100, Step = 1, Default = 25, Suffix = "%", Flag = "Slider", Callback = function(v) print("Slider", v) end })
    Values:AddRangeSlider({ Title = "Range Slider", Min = 0, Max = 100, Default = { 20, 60 }, Flag = "Range", Callback = function(v) print("Range", v[1], v[2]) end })
    Values:AddSection({ Title = "Text" })
    Values:AddInput({ Title = "Input", Placeholder = "Type here", Flag = "Input", Callback = function(v) print("Input", v) end })
    Values:AddTextbox({ Title = "Textbox", Placeholder = "Multi-line text", Height = 96, Flag = "Textbox", Callback = function(v) print("Textbox", v) end })
    Values:AddSearchbar({ Placeholder = "Filter this page..." })
    Values:AddSection({ Title = "Pickers" })
    Values:AddKeybind({ Title = "Keybind", Default = Enum.KeyCode.G, Flag = "Key", Callback = function(k) print("Key set", k) end, OnPress = function() N("Keybind", "G pressed") end })
    Values:AddColorpicker({ Title = "Colorpicker", Default = Color3.fromRGB(150, 85, 255), Flag = "Color", Callback = function(c) print("Color", c) end })
    Values:AddDatePicker({ Title = "Date Picker", Flag = "Date", Callback = function(v) print("Date", v) end })
    Values:AddTimePicker({ Title = "Time Picker", Flag = "Time", Callback = function(v) print("Time", v) end })

    local Drops = Controls:AddSubTab({ Title = "Dropdowns", Icon = "list" })
    local dd = Drops:AddDropdown({ Title = "Dropdown", Options = { "Apple", "Banana", "Cherry" }, Default = "Banana", Flag = "Drop", Callback = function(v) print("Drop", v) end })
    Drops:AddDropdown({ Title = "Multi Dropdown", Options = { "NPC", "Boss", "Player", "Chest" }, Multi = true, Default = { "NPC" }, Flag = "Multi", Callback = function(v) print("Multi", table.concat(v, ",")) end })
    Drops:AddMultiDropdown({ Title = "MultiDropdown shortcut", Options = { "One", "Two", "Three" }, Flag = "Multi2" })
    Drops:AddDropdown({ Title = "Long list (search)", Options = { "Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot", "Golf", "Hotel" }, Flag = "Long" })
    Drops:AddButton({ Title = "Change options", ButtonText = "Update", Icon = "refresh-cw", Callback = function() dd:SetOptions({ "Red", "Green", "Blue" }) dd:Set("Green") end })
    Drops:AddButton({ Title = "Open dropdown", ButtonText = "Open", Icon = "chevron-down", Callback = function() dd:Open() end })

    ----------------------------------------------------------- TAB 2: DISPLAY
    local Display = Window:AddTab({ Title = "Display", Icon = "layout-dashboard" })

    local Text = Display:AddSubTab({ Title = "Text", Icon = "type" })
    Text:AddSection({ Title = "Text" })
    Text:AddLabel({ Title = "Label" })
    Text:AddParagraph({ Title = "Paragraph", Content = "A title with a longer description under it. It wraps onto several lines when needed." })
    Text:AddDivider()
    Text:AddLink({ Text = "Link (tap to copy)", Url = "https://example.com" })
    Text:AddCodeBlock({ Language = "lua", Code = 'print("Hello from Picka\'s Hub")\nlocal x = 1 + 1' })
    Text:AddSection({ Title = "Tags and badges" })
    Text:AddTag({ Text = "Online", Icon = "wifi" })
    Text:AddTag({ Tags = { { Text = "Android", Icon = "smartphone" }, { Text = "Beta", Icon = "flask-conical" }, { Text = "New" } } })
    Text:AddBadge({ Text = "Badge", Color = Color3.fromRGB(80, 220, 140) })
    Text:AddSection({ Title = "Alerts" })
    Text:AddAlert({ Title = "Info", Content = "Something good to know.", Type = "Info" })
    Text:AddAlert({ Title = "Success", Content = "It worked.", Type = "Success" })
    Text:AddAlert({ Title = "Warning", Content = "Be careful.", Type = "Warning" })
    Text:AddAlert({ Title = "Error", Content = "Something failed.", Type = "Error" })

    local Status = Display:AddSubTab({ Title = "Status", Icon = "activity" })
    Status:AddSection({ Title = "Progress" })
    local pb = Status:AddProgressBar({ Title = "Progress Bar", Value = 40 })
    Status:AddLoadingBar({ Title = "Loading Bar" })
    Status:AddSpinner({ Size = 28 })
    Status:AddStatus({ Text = "Server", State = "Online" })
    Status:AddStatus({ Text = "Backup", State = "Idle" })
    Status:AddStatus({ Text = "Database", State = "Busy" })
    Status:AddStatus({ Text = "Mirror", State = "Offline" })
    Status:AddSection({ Title = "Steps and pages" })
    local st = Status:AddStepper({ Steps = { "Start", "Setup", "Finish" }, Current = 1, Callback = function(n) print("Step", n) end })
    Status:AddPagination({ Total = 5, Current = 1, Callback = function(p) print("Page", p) end })
    Status:AddBreadcrumb({ Items = { "Home", "Library", "Docs" }, Callback = function(i, n) print("Crumb", i, n) end })
    Status:AddButton({ Title = "Progress +10", ButtonText = "Add", Icon = "plus", Callback = function() pb:Set(math.random(10, 100)) end })
    Status:AddButton({ Title = "Next step", ButtonText = "Next", Icon = "arrow-right", Callback = function() st:Next() end })

    local Data = Display:AddSubTab({ Title = "Data", Icon = "database" })
    Data:AddSection({ Title = "Information" })
    Data:AddInfo({ Title = "Info row", Value = "Some value", Copy = true })
    Data:AddDual({ Left = { Title = "Left", Value = "123" }, Right = { Title = "Right", Value = "456" } })
    Data:AddGameCard({})
    Data:AddCommunityCard({ Title = "My Community", Link = "discord.gg/example", Icon = "discord", Color = Color3.fromRGB(88, 101, 242) })
    Data:AddSection({ Title = "People" })
    Data:AddProfile({ Status = "Playing" })
    Data:AddAvatar({ Size = 48 })
    Data:AddSection({ Title = "Tables" })
    Data:AddTable({ Columns = { "Name", "Score", "Rank" }, Rows = { { "Ann", 120, 1 }, { "Ben", 95, 2 }, { "Cy", 80, 3 } } })
    Data:AddList({ Items = { "First", "Second", "Third", "Fourth" }, Height = 110, Callback = function(v) print("List", v) end })
    local con = Data:AddConsole({ Height = 110 })
    con:Log("Info line") con:Log("Success line", "Success") con:Log("Warning line", "Warning") con:Log("Error line", "Error")
    Data:AddSection({ Title = "Media" })
    Data:AddImage({ Image = "rbxassetid://109882288573862", Height = 110 })
    Data:AddIcon({ Icon = "star", Size = 24 })

    ----------------------------------------------------------- TAB 3: LAYOUT
    local Layout = Window:AddTab({ Title = "Layout", Icon = "layout-grid" })
    local box = Layout:AddGroupbox({ Title = "Groupbox", Icon = "box" })
    box:AddToggle({ Title = "Inside a groupbox", Flag = "GB1" })
    box:AddSlider({ Title = "Also inside", Min = 0, Max = 10, Default = 5, Flag = "GB2" })
    local card = Layout:AddCard({ Title = "Card", Icon = "square", Content = "A card with text and elements." })
    card:AddButton({ Title = "Card button", ButtonText = "Go", Icon = "play", Callback = function() N("Card", "Button pressed") end })
    local col = Layout:AddCollapsible({ Title = "Collapsible", Icon = "chevrons-down", Open = false })
    col:AddLabel({ Title = "Hidden until opened" })
    local area = Layout:AddScrollArea({ Height = 110 })
    for i = 1, 8 do area:AddLabel({ Title = "Scroll row " .. i }) end

    ----------------------------------------------------------- TAB 4: API (window + library functions)
    local Api = Window:AddTab({ Title = "API", Icon = "code" })

    local Win = Api:AddSubTab({ Title = "Window", Icon = "app-window" })
    Win:AddButton({ Title = "Dialog", ButtonText = "Open", Icon = "message-square", Callback = function()
        Window:Dialog({ Title = "Dialog", Content = "Choose an option.", Buttons = { { Text = "Cancel" }, { Text = "OK", Icon = "check", Callback = function() N("Dialog", "OK pressed", "Success") end } } })
    end })
    Win:AddButton({ Title = "Modal with elements", ButtonText = "Open", Icon = "layers", Callback = function()
        local m = Window:Modal({ Title = "Modal", Content = "Elements work inside it too." })
        m:AddToggle({ Title = "A toggle" })
        m:AddButton({ Title = "Close", ButtonText = "Close", Icon = "x", Callback = function() m:Close() end })
    end })
    Win:AddButton({ Title = "Window:SetTitle", ButtonText = "Set", Icon = "pencil", Callback = function() Window:SetTitle("Hub " .. math.random(1, 99)) end })
    Win:AddButton({ Title = "Window:SetTag", ButtonText = "Set", Icon = "tag", Callback = function() Window:SetTag("Custom") end })
    Win:AddButton({ Title = "Window:SetGame", ButtonText = "Set", Icon = "gamepad-2", Callback = function() Window:SetGame("Another game") end })
    Win:AddButton({ Title = "Window:SetUserCard", ButtonText = "Set", Icon = "user", Callback = function() Window:SetUserCard({ Display = "Player", Name = "player", Status = "Away" }) end })
    Win:AddSlider({ Title = "Window:SetOpenSize", Min = 30, Max = 80, Default = 48, Callback = function(v) Window:SetOpenSize(v) end })
    Win:AddButton({ Title = "Window:ToggleSidebar()", ButtonText = "Toggle", Icon = "panel-left", Callback = function() Window:ToggleSidebar() end })
    Win:AddButton({ Title = "Window:SetSidebar(true)", ButtonText = "Collapse", Icon = "chevron-left", Callback = function() Window:SetSidebar(true) end })
    Win:AddButton({ Title = "Window:SetSidebar(false)", ButtonText = "Expand", Icon = "chevron-right", Callback = function() Window:SetSidebar(false) end })
    Win:AddButton({ Title = "Window:Toggle (back in 2s)", ButtonText = "Hide", Icon = "eye-off", Callback = function()
        Window:SetVisible(false) task.delay(2, function() Window:SetVisible(true) end)
    end })

    local Lib = Api:AddSubTab({ Title = "Library", Icon = "library" })
    Lib:AddSection({ Title = "Notifications" })
    for _, ty in ipairs({ "Info", "Success", "Warning", "Error" }) do
        Lib:AddButton({ Title = "Notify: " .. ty, ButtonText = ty, Icon = "bell", Callback = function() Library:Notify({ Title = ty, Content = "Library:Notify example", Type = ty, Duration = 4 }) end })
    end
    Lib:AddButton({ Title = "Library:Toast", ButtonText = "Toast", Icon = "message-circle", Callback = function() Library:Toast("Toast message") end })
    Lib:AddSection({ Title = "Appearance" })
    Lib:AddColorpicker({ Title = "Library:SetAccent", Default = Library.Theme.Accent, Callback = function(c) Library:SetAccent(c) end })
    Lib:AddSlider({ Title = "Library:SetGlass", Min = 0, Max = .8, Step = .05, Default = .2, Callback = function(v) Library:SetGlass(v) end })
    Lib:AddSlider({ Title = "Library:SetRadius", Min = 4, Max = 24, Default = 16, Callback = function(v) Library:SetRadius(v) end })
    Lib:AddSection({ Title = "Language" })
    Lib:AddButton({ Title = "Library:SetLanguage('Japan')", ButtonText = "Set", Icon = "languages", Callback = function() Library:SetLanguage("Japan") end })
    Lib:AddButton({ Title = "Library:SetLanguage('English')", ButtonText = "Set", Icon = "languages", Callback = function() Library:SetLanguage("English") end })
    Lib:AddButton({ Title = "Library:T('Save')", ButtonText = "Show", Icon = "type", Callback = function() N("Library:T", Library:T("Save") .. "  (" .. tostring(Library.Lang) .. ")") end })

    local Cfg = Api:AddSubTab({ Title = "Configs", Icon = "save" })
    Cfg:AddButton({ Title = "Library:SaveConfig('demo')", ButtonText = "Save", Icon = "save", Callback = function() N("SaveConfig", tostring(Library:SaveConfig("demo")), "Success") end })
    Cfg:AddButton({ Title = "Library:LoadConfig('demo')", ButtonText = "Load", Icon = "download", Callback = function() N("LoadConfig", tostring(Library:LoadConfig("demo"))) end })
    Cfg:AddButton({ Title = "Library:ListConfigs()", ButtonText = "List", Icon = "list", Callback = function() N("ListConfigs", table.concat(Library:ListConfigs(), ", ")) end })
    Cfg:AddButton({ Title = "Library:DeleteConfig('demo')", ButtonText = "Delete", Icon = "trash", Callback = function() Library:DeleteConfig("demo") N("DeleteConfig", "demo", "Warning") end })
    Cfg:AddButton({ Title = "Library.Flags (print)", ButtonText = "Print", Icon = "terminal", Callback = function()
        for k, v in pairs(Library.Flags) do print(k, v) end
    end })

    -- Window:Destroy() removes the whole interface.
    N("Loaded", "Every API is on the Controls, Display, Layout and API tabs.")
end, function(e) return tostring(e) .. "\n" .. debug.traceback() end)
if not okM then fail("Script error: " .. tostring(errM)) end
