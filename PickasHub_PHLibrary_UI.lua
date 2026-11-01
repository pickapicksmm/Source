--[[
    PICKA'S HUB - PHLibrary UI Migration
    Based on the uploaded stealanegg.lua.txt tab layout.

    SAFE UI-ONLY BUILD:
    - Uses the requested PHLibrary source.
    - Recreates the original navigation structure.
    - Controls only update local UI preview/settings.
    - Does not automate gameplay, manipulate game state, call game remotes,
      bypass protections, or perform stealing/farming actions.
]]

repeat task.wait() until game:IsLoaded()

local PH_LIBRARY_URL =
    "https://raw.githubusercontent.com/pickapicksmm/Pickas-Hub/refs/heads/main/Libray.src/PHLibrary.lua"

local ok, Library = pcall(function()
    return loadstring(game:HttpGet(PH_LIBRARY_URL))()
end)

if not ok or type(Library) ~= "table" then
    warn("[PICKA'S HUB] Failed to load PHLibrary:", Library)
    return
end

-- Brand styling
Library:SetAccent(Color3.fromRGB(157, 0, 255))
Library.FloatImage = 109882288573862

local Window = Library:CreateWindow({
    Title = "PICKA'S HUB",
    Tag = "PHLibrary UI",
    Game = "Steal an Egg",
    Size = Vector2.new(650, 440),
})

local Tabs = {
    Home = Window:AddTab({ Title = "Home", Icon = "house" }),
    Farm = Window:AddTab({ Title = "Farm", Icon = "sprout" }),
    Progression = Window:AddTab({ Title = "Progress", Icon = "trending-up" }),
    Predictor = Window:AddTab({ Title = "Predictor", Icon = "chart-no-axes-combined" }),
    ESP = Window:AddTab({ Title = "ESP", Icon = "scan-eye" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "wrench" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}

local function section(tab, title)
    return tab:AddSection({ Title = title })
end

local function paragraph(parent, title, content)
    return parent:AddParagraph({
        Title = title,
        Content = content,
    })
end

local function button(parent, title, callback)
    return parent:AddButton({
        Title = title,
        ButtonText = "Open",
        Callback = callback,
    })
end

local function localToggle(parent, title, description)
    local state = false
    parent:AddToggle({
        Title = title,
        Default = false,
        Tooltip = description or "UI preview toggle only.",
        Callback = function(value)
            state = value
            Library:Toast(title .. (state and " enabled (UI only)" or " disabled"))
        end,
    })
end

-- HOME
do
    local s = section(Tabs.Home, "WELCOME")
    paragraph(
        s,
        "PICKA'S HUB",
        "PHLibrary interface migration preview. This build recreates the original tab structure using your requested library."
    )
    s:AddProfile({ Status = "PHLibrary UI build" })
    s:AddBadge({ Text = "UI-ONLY BUILD", Color = Color3.fromRGB(157, 0, 255) })

    local links = section(Tabs.Home, "COMMUNITY")
    button(links, "Copy Discord Invite", function()
        if setclipboard then
            setclipboard("https://discord.gg/R3rDNwrV7y")
            Library:Toast("Discord invite copied")
        else
            Library:Notify({ Title = "Discord", Content = "https://discord.gg/R3rDNwrV7y" })
        end
    end)
    button(links, "Copy Telegram Link", function()
        if setclipboard then
            setclipboard("https://t.me/pickapicksm")
            Library:Toast("Telegram link copied")
        else
            Library:Notify({ Title = "Telegram", Content = "https://t.me/pickapicksm" })
        end
    end)
end

-- FARM: UI placeholders only; no gameplay automation is connected.
do
    local s = section(Tabs.Farm, "FARM CONTROLS")
    paragraph(
        s,
        "Automation modules not connected",
        "The uploaded source contains gameplay automation and game-remote interactions. Those actions are intentionally not migrated into this UI-only build."
    )
    local labels = {
        "Auto Steal",
        "Auto Place Egg",
        "Auto Treadmill",
        "Auto Hatch",
        "Auto Equip Best",
        "Auto Favorite Pet",
        "Auto Fuse Machine",
        "Auto Sell Pet",
        "Auto Sell Egg",
        "Auto Farm Drones",
    }
    for _, name in ipairs(labels) do
        localToggle(s, name, "Disabled placeholder. No game action is attached.")
    end
end

-- PROGRESSION: display-only placeholders.
do
    local s = section(Tabs.Progression, "PROGRESSION")
    paragraph(
        s,
        "Progression status",
        "Read-only display placeholder. Connect only to data and actions in a Roblox experience you own or are authorized to develop."
    )
    localToggle(s, "Show Progression Panel", "Local UI visibility preview only.")
    localToggle(s, "Show Rebirth Information", "Local UI preview only.")
end

-- PREDICTOR: informational panel placeholders.
do
    local s = section(Tabs.Predictor, "PET PREDICTOR")
    paragraph(
        s,
        "Pet Predictor",
        "Prediction data is not connected in this migration. This panel is reserved for authorized, read-only game data."
    )
    s:AddDropdown({
        Title = "Egg Scope",
        Options = { "Placed Eggs (In Pen)", "All Eggs (Inc. Inventory)" },
        Default = "Placed Eggs (In Pen)",
        Callback = function(value)
            Library:Toast("Preview scope: " .. tostring(value))
        end,
    })
    s:AddDropdown({
        Title = "Sort Pets By",
        Options = { "Income (Highest)", "Rarity (Highest)", "Time (Ready Soon)" },
        Default = "Income (Highest)",
        Callback = function(value)
            Library:Toast("Preview sort: " .. tostring(value))
        end,
    })
    button(s, "Refresh Pet Preview", function()
        Library:Notify({ Title = "Predictor", Content = "No live game data is connected." })
    end)

    local f = section(Tabs.Predictor, "FUSE PREDICTOR")
    paragraph(f, "Fuse Predictor", "Reserved for read-only prediction information.")
    button(f, "Refresh Fuse Preview", function()
        Library:Notify({ Title = "Fuse Predictor", Content = "No live game data is connected." })
    end)
end

-- ESP: inert UI settings only.
do
    local s = section(Tabs.ESP, "VISUAL OPTIONS")
    paragraph(
        s,
        "ESP options",
        "These switches are UI placeholders only. They do not create highlights, reveal hidden objects, or inspect other players."
    )
    localToggle(s, "ESP Eggs", "UI placeholder only.")
    localToggle(s, "ESP Rare Eggs", "UI placeholder only.")
    localToggle(s, "ESP Guards", "UI placeholder only.")
    localToggle(s, "ESP Event Objects", "UI placeholder only.")
end

-- MISC
do
    local s = section(Tabs.Misc, "GENERAL")
    paragraph(s, "Utilities", "General interface options and local preview controls.")
    localToggle(s, "Low Effects Preview", "Local preference preview only.")
    localToggle(s, "Compact UI Preview", "Local preference preview only.")
    button(s, "Show Build Information", function()
        Library:Notify({
            Title = "PICKA'S HUB",
            Content = "PHLibrary UI migration | Safe UI-only build",
            Duration = 5,
        })
    end)
end

-- SETTINGS
do
    local s = section(Tabs.Settings, "APPEARANCE")
    s:AddSlider({
        Title = "Window Glass",
        Min = 0,
        Max = 0.8,
        Step = 0.05,
        Default = 0.2,
        Callback = function(value)
            Library:SetGlass(value)
        end,
    })

    s:AddDropdown({
        Title = "Language",
        Options = Library.Languages,
        Default = Library.Lang or "English",
        Callback = function(value)
            if Library:SetLanguage(value) then
                Library:Toast("Language: " .. tostring(value))
            end
        end,
    })

    local info = section(Tabs.Settings, "BUILD INFORMATION")
    paragraph(
        info,
        "Migration notes",
        "Original tabs preserved: Home, Farm, Progress, Predictor, ESP, Misc, Settings. Gameplay automation and remote calls are not included."
    )
    button(info, "Reset Accent Color", function()
        Library:SetAccent(Color3.fromRGB(157, 0, 255))
        Library:Toast("Accent reset")
    end)
end

Library:Notify({
    Title = "PICKA'S HUB",
    Content = "PHLibrary UI loaded successfully.",
    Duration = 4,
})
