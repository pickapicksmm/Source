local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local PH = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/pickapicksmm/Pickas-Hub/refs/heads/main/Libray.src/PHLibrary.lua"
))()

local Window = PH:CreateWindow({
    Title = "Picka's Hub",
})

local Container

local UpgradeBaseRemote
local ClaimAllEggsRemote
local BuyTrailRemote
local RebirthRemote
local EquipBestRemote
local ClaimRewardsIndexRemote
local ClaimEggRemote
local StealEggRemote

task.spawn(function()
    pcall(function()
        Container = ReplicatedStorage
            :WaitForChild("packages", 10)
            :WaitForChild("_Index", 10)
            :WaitForChild("littensy_remo@1.5.3", 10)
            :WaitForChild("remo", 10)
            :WaitForChild("container", 10)
    end)

    if not Container then
        warn("[PICKA'S HUB] Remote container not found.")
        return
    end

    local function Get(Name)
        local Remote = Container:WaitForChild(Name, 5)

        if not Remote then
            warn("[PICKA'S HUB] Remote not found: " .. Name)
        end

        return Remote
    end

    UpgradeBaseRemote = Get("data.base.upgradeBase")
    ClaimAllEggsRemote = Get("data.base.claimAllEggs")
    BuyTrailRemote = Get("data.trailShop.buyTrail")
    RebirthRemote = Get("data.rebirth.doRebirth")
    EquipBestRemote = Get("data.base.equipBestChickens")
    ClaimRewardsIndexRemote = Container:FindFirstChild("data.index.claimMoney")
    ClaimEggRemote = Container:FindFirstChild("data.base.claimEgg")
    StealEggRemote = Container:FindFirstChild("game.nests.stealEgg")
end)

local AutoUpgrade = false
local AutoClaimEggs = false
local AutoBuyTrails = false
local AutoRebirth = false
local AutoEquipBest = false
local AutoClaimRewardsIndex = false
local AutoCollect = false
local AutoSell = false

local AutoSteal = false

local SellFilters = {
    Rarities = {
        ["Common"] = true,
        ["Uncommon"] = true,
        ["Rare"] = true,
        ["Epic"] = true,
        ["Legendary"] = false,
        ["Mythic"] = false,
        ["Divine"] = false
    },

    MaxKgToSell = 500
}

local AutoStealMovement = "Tween"

local TweenSpeed = 45
local InteractDelay = 0.7
local TeleportDelay = 0.7

local SafeSaveCFrame = nil

local SelectedZones = { "All" }

local ZoneNames = {
    "All", "Abyss", "Alien", "Beach", "Candy", "Cosmic", "Crystal", "Desert",
    "Forest", "Jungle", "Lake", "Magma", "Snow", "Volcano", "BlueLava"
}

local function GetCharacter()
    return LocalPlayer.Character
end

local function GetHumanoid()
    local Character = GetCharacter()
    if not Character then
        return nil
    end
    return Character:FindFirstChildOfClass("Humanoid")
end

local function GetRoot()
    local Character = GetCharacter()
    if not Character then
        return nil
    end
    return Character:FindFirstChild("HumanoidRootPart")
end

local function SaveSafe()
    local Root = GetRoot()

    if not Root then
        return false
    end

    SafeSaveCFrame = Root.CFrame

    return true
end

local function ReturnToSafe()
    local Root = GetRoot()

    if not Root or not SafeSaveCFrame then
        return false
    end

    if AutoStealMovement == "Teleport" then
        Root.CFrame = SafeSaveCFrame
        return true
    end

    local Distance = (Root.Position - SafeSaveCFrame.Position).Magnitude
    local Speed = math.max(tonumber(TweenSpeed) or 45, 1)
    local Duration = math.clamp(Distance / Speed, 0.05, 10)

    local Tween = TweenService:Create(
        Root,
        TweenInfo.new(Duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
        { CFrame = SafeSaveCFrame }
    )

    Tween:Play()
    Tween.Completed:Wait()

    return true
end

local function MoveToCFrame(TargetCFrame)
    local Root = GetRoot()

    if not Root or not TargetCFrame then
        return false
    end

    if not AutoSteal then
        return false
    end

    if AutoStealMovement == "Teleport" then
        Root.CFrame = TargetCFrame
        return true
    end

    local Distance = (Root.Position - TargetCFrame.Position).Magnitude
    local Speed = math.max(tonumber(TweenSpeed) or 45, 1)
    local Duration = math.clamp(Distance / Speed, 0.05, 10)

    local Tween = TweenService:Create(
        Root,
        TweenInfo.new(Duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
        { CFrame = TargetCFrame }
    )

    Tween:Play()
    Tween.Completed:Wait()

    return AutoSteal
end

local function IsZoneSelected(ZoneName)
    if not ZoneName then
        return false
    end

    if table.find(SelectedZones, "All") then
        return true
    end

    return table.find(SelectedZones, ZoneName) ~= nil
end

local function GetEggPrompt(Root)
    if not Root then
        return nil
    end

    local Prompt = Root:FindFirstChildOfClass("ProximityPrompt")

    if Prompt and Prompt.Enabled then
        return Prompt
    end

    return nil
end

local function SearchAvailableEggs()
    local Results = {}

    local Map = Workspace:FindFirstChild("Game")
        and Workspace.Game:FindFirstChild("Map")

    if not Map then
        return Results
    end

    local PlayZones = Map:FindFirstChild("PlayZones")

    if not PlayZones then
        return Results
    end

    for _, Zone in ipairs(PlayZones:GetChildren()) do
        if IsZoneSelected(Zone.Name) then
            local Nests = Zone:FindFirstChild("Nests")

            if Nests then
                for _, Nest in ipairs(Nests:GetChildren()) do
                    local Root = Nest:FindFirstChild("Root")

                    if Root and Root:IsA("BasePart") then
                        local Prompt = GetEggPrompt(Root)

                        if Prompt then
                            table.insert(Results, {
                                ZoneName = Zone.Name,
                                Nest = Nest,
                                Root = Root,
                                Prompt = Prompt
                            })
                        end
                    end
                end
            end
        end
    end

    return Results
end

local function HoldOnce(Prompt)
    if not AutoSteal then
        return false
    end

    if not Prompt
        or not Prompt:IsA("ProximityPrompt")
        or not Prompt.Enabled then
        return false
    end

    local Duration = Prompt.HoldDuration

    pcall(function()
        Prompt:InputHoldBegin()
    end)

    if Duration > 0 then
        task.wait(Duration)
    end

    pcall(function()
        Prompt:InputHoldEnd()
    end)

    return true
end

local function StealOneEgg(Egg)
    if not AutoSteal then
        return false
    end

    if not Egg or not Egg.Root or not Egg.Prompt then
        return false
    end

    if not MoveToCFrame(Egg.Root.CFrame + Vector3.new(0, 2, 0)) then
        return false
    end

    if not AutoSteal then
        return false
    end

    if InteractDelay > 0 then
        task.wait(InteractDelay)
    end

    if not AutoSteal then
        return false
    end

    local Held = HoldOnce(Egg.Prompt)

    if not Held then
        return false
    end

    if not AutoSteal then
        return false
    end

    if StealEggRemote then
        pcall(function()
            StealEggRemote:InvokeServer(Egg.ZoneName, Egg.Root.Position)
        end)
    end

    if AutoSteal then
        ReturnToSafe()
    end

    if AutoSteal and TeleportDelay > 0 then
        task.wait(TeleportDelay)
    end

    return true
end

task.spawn(function()
    while true do
        if AutoUpgrade and UpgradeBaseRemote then
            pcall(function()
                UpgradeBaseRemote:FireServer()
            end)
        end
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        if AutoClaimEggs and ClaimAllEggsRemote then
            pcall(function()
                ClaimAllEggsRemote:FireServer()
            end)
        end
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        if AutoBuyTrails and BuyTrailRemote then
            pcall(function()
                BuyTrailRemote:FireServer("grey")
            end)
        end
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        if AutoRebirth and RebirthRemote then
            pcall(function()
                RebirthRemote:FireServer()
            end)
        end
        task.wait(2)
    end
end)

task.spawn(function()
    while true do
        if AutoEquipBest and EquipBestRemote then
            pcall(function()
                EquipBestRemote:FireServer()
            end)
        end
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        if AutoClaimRewardsIndex and ClaimRewardsIndexRemote then
            pcall(function()
                ClaimRewardsIndexRemote:FireServer()
            end)
        end
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        if AutoCollect then

        end
        task.wait(1)
    end
end)

local function GetInventory()
    return LocalPlayer:FindFirstChild("Backpack")
        or LocalPlayer:FindFirstChild("Inventory")
end

local SellRemote = nil

pcall(function()
    for _, Descendant in ipairs(ReplicatedStorage:GetDescendants()) do
        if Descendant:IsA("RemoteEvent") then
            local Name = Descendant.Name:lower()

            if Name:match("sell") then
                SellRemote = Descendant
                break
            end
        end
    end
end)

local function GetItemValue(Item, AttributeName, ChildName)
    local Attribute = Item:GetAttribute(AttributeName)

    if Attribute ~= nil then
        return Attribute
    end

    local Child = Item:FindFirstChild(ChildName)

    if Child then
        return Child.Value
    end

    return nil
end

local function GetItemRarity(Item)
    return GetItemValue(Item, "Rarity", "Rarity")
end

local function GetItemWeight(Item)
    local Weight = Item:GetAttribute("Weight")

    if Weight == nil then
        Weight = Item:GetAttribute("Kg")
    end

    if Weight == nil then
        local WeightObject = Item:FindFirstChild("Weight")

        if WeightObject then
            Weight = WeightObject.Value
        end
    end

    if Weight == nil then
        return 0
    end

    if type(Weight) == "number" then
        return Weight
    end

    if type(Weight) == "string" then
        return tonumber(Weight:match("[%d%.]+")) or 0
    end

    return 0
end

task.spawn(function()
    while true do
        if AutoSell and SellRemote then
            pcall(function()
                local Inventory = GetInventory()

                if not Inventory then
                    return
                end

                local QueuedUUIDs = {}

                for _, Item in ipairs(Inventory:GetChildren()) do
                    local Rarity = GetItemRarity(Item)
                    local Weight = GetItemWeight(Item)

                    local UUID = Item:GetAttribute("UUID")
                        or Item:GetAttribute("Id")
                        or Item:GetAttribute("UniqueId")

                    if not UUID then
                        local UUIDObject = Item:FindFirstChild("UUID")

                        if UUIDObject then
                            UUID = UUIDObject.Value
                        end
                    end

                    if not UUID then
                        UUID = Item.Name
                    end

                    if Rarity
                        and SellFilters.Rarities[Rarity] == true
                        and Weight < SellFilters.MaxKgToSell
                        and UUID then
                        table.insert(QueuedUUIDs, UUID)
                    end
                end

                if #QueuedUUIDs > 0 then
                    SellRemote:FireServer(QueuedUUIDs)
                end
            end)
        end

        task.wait(0.8)
    end
end)

task.spawn(function()
    while true do
        if AutoSteal then
            local Eggs = SearchAvailableEggs()

            if #Eggs > 0 then
                StealOneEgg(Eggs[1])
            else
                task.wait(0.5)
            end
        else
            task.wait(0.25)
        end
    end
end)

local AutoTab = Window:AddTab({
    Title = "Auto",
    Icon = "zap",
})

AutoTab:AddToggle({
    Title = "Auto Upgrade",
    Tooltip = "Automatically upgrades your base.",
    Flag = "AutoUpgrade",
    Default = false,
    Callback = function(Value)
        AutoUpgrade = Value
    end
})

AutoTab:AddToggle({
    Title = "Auto Claim Eggs",
    Tooltip = "Automatically claims available eggs.",
    Flag = "AutoClaimEggs",
    Default = false,
    Callback = function(Value)
        AutoClaimEggs = Value
    end
})

AutoTab:AddToggle({
    Title = "Auto Buy Trails",
    Tooltip = "Automatically buys the configured trail.",
    Flag = "AutoBuyTrails",
    Default = false,
    Callback = function(Value)
        AutoBuyTrails = Value
    end
})

AutoTab:AddToggle({
    Title = "Auto Rebirth",
    Tooltip = "Automatically attempts to rebirth.",
    Flag = "AutoRebirth",
    Default = false,
    Callback = function(Value)
        AutoRebirth = Value
    end
})

AutoTab:AddToggle({
    Title = "Auto Equip Best",
    Tooltip = "Automatically equips your best chickens.",
    Flag = "AutoEquipBest",
    Default = false,
    Callback = function(Value)
        AutoEquipBest = Value
    end
})

AutoTab:AddToggle({
    Title = "Auto Claim Rewards Index",
    Tooltip = "Automatically claims available Rewards Index money.",
    Flag = "AutoClaimRewardsIndex",
    Default = false,
    Callback = function(Value)
        AutoClaimRewardsIndex = Value
    end
})

AutoTab:AddToggle({
    Title = "Auto Collect",
    Tooltip = "Automatically collects available rewards.",
    Flag = "AutoCollect",
    Default = false,
    Callback = function(Value)
        AutoCollect = Value
    end
})

AutoTab:AddToggle({
    Title = "Auto Sell",
    Tooltip = "Automatically sells matching inventory items.",
    Flag = "AutoSell",
    Default = false,
    Callback = function(Value)
        AutoSell = Value
    end
})

AutoTab:AddDropdown({
    Title = "Sell Rarities",
    Tooltip = "Select which rarities Auto Sell can sell.",
    Flag = "SellRarities",
    Options = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Divine" },
    Default = { "Common", "Uncommon", "Rare", "Epic" },
    Multi = true,
    Callback = function(Values)
        SellFilters.Rarities = {
            ["Common"] = false,
            ["Uncommon"] = false,
            ["Rare"] = false,
            ["Epic"] = false,
            ["Legendary"] = false,
            ["Mythic"] = false,
            ["Divine"] = false
        }

        for _, Rarity in ipairs(Values or {}) do
            SellFilters.Rarities[Rarity] = true
        end
    end
})

AutoTab:AddSlider({
    Title = "Max KG To Sell",
    Tooltip = "Only items below this weight can be sold.",
    Flag = "MaxKgToSell",
    Min = 1,
    Max = 5000,
    Step = 1,
    Default = 500,
    Callback = function(Value)
        SellFilters.MaxKgToSell = tonumber(Value) or 500
    end
})

local StealTab = Window:AddTab({
    Title = "Steal",
    Icon = "hand",
})

StealTab:AddToggle({
    Title = "Auto Steal",
    Tooltip = "Steals one egg, returns to Safe Base, then searches again.",
    Flag = "AutoSteal",
    Default = false,
    Callback = function(Value)
        AutoSteal = Value

        if Value and not SafeSaveCFrame then
            SaveSafe()
        end
    end
})

StealTab:AddDropdown({
    Title = "Select Zone",
    Tooltip = "Select which zones Auto Steal can search.",
    Flag = "SelectedZones",
    Options = ZoneNames,
    Default = { "All" },
    Multi = true,
    Callback = function(Values)

        if not Values or #Values == 0 or table.find(Values, "All") then
            SelectedZones = { "All" }
            return
        end

        local NewSelection = {}

        for _, Zone in ipairs(Values) do
            table.insert(NewSelection, Zone)
        end

        SelectedZones = NewSelection
    end
})

local ControlsTab = Window:AddTab({
    Title = "Controlls",
    Icon = "settings-2",
})

ControlsTab:AddDropdown({
    Title = "Auto Steal Movement",
    Tooltip = "Choose how Auto Steal moves to eggs and Safe Base.",
    Flag = "AutoStealMovement",
    Options = { "Tween", "Teleport" },
    Default = "Tween",
    Callback = function(Value)
        if type(Value) == "table" then
            Value = Value[1]
        end

        if Value == "Teleport" then
            AutoStealMovement = "Teleport"
        else
            AutoStealMovement = "Tween"
        end
    end
})

ControlsTab:AddSlider({
    Title = "Tween Speed",
    Tooltip = "Movement speed when Tween mode is selected.",
    Flag = "TweenSpeed",
    Min = 10,
    Max = 150,
    Step = 5,
    Default = 45,
    Callback = function(Value)
        TweenSpeed = tonumber(Value) or 45
    end
})

ControlsTab:AddSlider({
    Title = "Interact Delay",
    Tooltip = "Delay before the one-time egg hold.",
    Flag = "InteractDelay",
    Min = 0,
    Max = 3,
    Step = 0.1,
    Default = 0.7,
    Callback = function(Value)
        InteractDelay = tonumber(Value) or 0
    end
})

ControlsTab:AddSlider({
    Title = "Teleport Delay",
    Tooltip = "Delay after returning to Safe Base before searching again.",
    Flag = "TeleportDelay",
    Min = 0,
    Max = 3,
    Step = 0.1,
    Default = 0.7,
    Callback = function(Value)
        TeleportDelay = tonumber(Value) or 0
    end
})

ControlsTab:AddButton({
    Title = "Save Safe",
    Tooltip = "Saves your current position as the Safe Base.",
    ButtonText = "Save",
    Icon = "save",
    Callback = function()
        if SaveSafe() then
            PH:Notify({ Title = "Safe Base", Content = "Position saved.", Type = "Success" })
        else
            PH:Notify({ Title = "Safe Base", Content = "Could not save position.", Type = "Error" })
        end
    end
})

ControlsTab:AddButton({
    Title = "Teleport to Save Safe",
    Tooltip = "Returns you to the saved Safe Base position.",
    ButtonText = "Go",
    Icon = "map-pin",
    Callback = function()
        ReturnToSafe()
    end
})

AutoTab:Select()

PH:Notify({
    Title = "Picka's Hub",
    Content = "Loaded. Open the Auto, Steal or Controlls tab on the left.",
    Type = "Success",
})

print("[PICKA'S HUB] Loaded successfully.")
print("[PICKA'S HUB] Auto Steal: ONE egg per cycle.")
print("[PICKA'S HUB] Flow: Search -> Egg -> Hold -> Steal -> Safe -> Search.")
