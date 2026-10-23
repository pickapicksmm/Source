--[[ PICKA'S HUB | Keysystem window ]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

----------------------------------------------------------------
-- CONFIG
----------------------------------------------------------------
local Config = {
	Title = "Picka's Hub",
	Logo = "rbxassetid://109882288573862",
	GetKeyLink = "https://main.pickazhub.workers.dev/getkey",
	Website = "https://main.pickazhub.workers.dev/",
	DiscordLink = "https://discord.gg/R3rDNwrV7y",
	TelegramLink = "https://t.me/+MGEV4AC7LEllZDJl",
	DiscordIcon = "", -- optional rbxassetid
	TelegramIcon = "", -- optional rbxassetid
	KeyFile = "PickasHub/key.txt",
	Credits = {
		{ "Owner", "PickaMeoww" },
		{ "Administration", "JM" },
		{ "Helper", "VINI" },
	},
	Api = "https://main.pickazhub.workers.dev",
	URLs = {
		Supported = "https://raw.githubusercontent.com/PickasHub/Library.Source/refs/heads/main/Support-games",
		Premium = "https://raw.githubusercontent.com/PickasHub/PHLoader/refs/heads/main/suppoted-game/Premium",
		Keysystem = "https://raw.githubusercontent.com/PickasHub/PHLoader/refs/heads/main/suppoted-game/Keysystem",
		Keyless = "https://raw.githubusercontent.com/PickasHub/PHLoader/refs/heads/main/suppoted-game/Keyless",
	},
}

local T = {
	Bg1 = Color3.fromRGB(13, 9, 21),
	Bg2 = Color3.fromRGB(31, 17, 54),
	Side = Color3.fromRGB(9, 6, 15),
	Card = Color3.fromRGB(21, 14, 35),
	Line = Color3.fromRGB(50, 38, 80),
	Accent = Color3.fromRGB(150, 84, 255),
	Accent2 = Color3.fromRGB(104, 48, 214),
	Text = Color3.fromRGB(236, 229, 250),
	Sub = Color3.fromRGB(148, 134, 180),
}

----------------------------------------------------------------
-- HELPERS
----------------------------------------------------------------
local function new(class, props, kids)
	local o = Instance.new(class)
	local parent
	for k, v in pairs(props or {}) do
		if k == "Parent" then
			parent = v
		else
			o[k] = v
		end
	end
	for _, c in ipairs(kids or {}) do
		c.Parent = o
	end
	if parent then
		o.Parent = parent
	end
	return o
end

local function corner(r)
	return new("UICorner", { CornerRadius = UDim.new(0, r) })
end

local function stroke(color, thickness, transparency)
	return new("UIStroke", {
		Color = color,
		Thickness = thickness or 1,
		Transparency = transparency or 0.6,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

local function label(props, kids)
	props.BackgroundTransparency = 1
	props.Font = props.Font or Enum.Font.GothamMedium
	props.TextColor3 = props.TextColor3 or T.Text
	props.TextSize = props.TextSize or 14
	return new("TextLabel", props, kids)
end

local applyIcon

local function button(props, style, onClick)
	-- the text lives in its own label, so hover/press effects never touch it
	local text = props.Text or ""
	local size = props.TextSize or 14
	local iconName = props.Icon
	props.Icon = nil
	props.Text = ""
	props.TextSize = nil
	props.AutoButtonColor = false
	local primary = style == "primary"
	local base = primary and T.Accent or T.Card
	local hover = primary and Color3.fromRGB(171, 118, 255) or Color3.fromRGB(31, 22, 50)
	props.BackgroundColor3 = base
	local scale = new("UIScale", { Scale = 1 })
	local line = (not primary) and stroke(T.Line, 1, 0) or nil
	local kids = { corner(6), scale }
	if line then
		table.insert(kids, line)
	end
	local b = new("TextButton", props, kids)
	local inner = new("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 2,
		Parent = b,
	}, {
		new("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 7),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	if iconName then
		local ic = new("ImageLabel", {
			Size = UDim2.fromOffset(size + 2, size + 2),
			BackgroundTransparency = 1,
			ImageColor3 = T.Text,
			ZIndex = 2,
			LayoutOrder = 1,
			Parent = inner,
		})
		if not applyIcon(ic, iconName) then
			ic:Destroy()
		end
	end
	if text ~= "" then
		label({
			Text = text,
			Font = Enum.Font.GothamBold,
			TextSize = size,
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			ZIndex = 2,
			LayoutOrder = 2,
			Parent = inner,
		})
	end
	local info = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	b.MouseEnter:Connect(function()
		TweenService:Create(b, info, { BackgroundColor3 = hover }):Play()
		if line then
			TweenService:Create(line, info, { Color = T.Accent }):Play()
		end
	end)
	b.MouseLeave:Connect(function()
		TweenService:Create(b, info, { BackgroundColor3 = base }):Play()
		TweenService:Create(scale, info, { Scale = 1 }):Play()
		if line then
			TweenService:Create(line, info, { Color = T.Line }):Play()
		end
	end)
	b.MouseButton1Down:Connect(function()
		TweenService:Create(scale, TweenInfo.new(0.08), { Scale = 0.96 }):Play()
	end)
	b.MouseButton1Up:Connect(function()
		TweenService:Create(scale, info, { Scale = 1 }):Play()
	end)
	b.MouseButton1Click:Connect(onClick)
	return b
end

local function httpGet(url)
	local ok, res = pcall(function()
		return game:HttpGet(url)
	end)
	if ok then
		return res
	end
end

local function httpJson(url)
	local body = httpGet(url)
	if not body then
		return
	end
	local ok, data = pcall(HttpService.JSONDecode, HttpService, body)
	if ok then
		return data
	end
end

local function api(sub, path)
	for _, dom in ipairs({ "roblox.com", "roproxy.com" }) do
		local j = httpJson("https://" .. sub .. "." .. dom .. path)
		if j then
			return j
		end
	end
end

local function short(n)
	n = tonumber(n)
	if not n then
		return "?"
	end
	if n >= 1e9 then
		return string.format("%.1fB", n / 1e9)
	elseif n >= 1e6 then
		return string.format("%.1fM", n / 1e6)
	elseif n >= 1e3 then
		return string.format("%.1fK", n / 1e3)
	end
	return tostring(n)
end

local function copy(text)
	if setclipboard then
		setclipboard(text)
		return true
	elseif toclipboard then
		toclipboard(text)
		return true
	end
	return false
end

----------------------------------------------------------------
-- ICONS (Footagesus/Icons, optional)
----------------------------------------------------------------
local okI, IconsLib = pcall(function()
	return loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua"))()
end)

function applyIcon(img, name)
	if not (okI and IconsLib and IconsLib.GetIcon) then
		return false
	end
	local ok, r, rectSize, rectOffset = pcall(IconsLib.GetIcon, name)
	if not ok then
		return false
	end
	if type(r) == "table" then
		img.Image = r.Image or ""
		if r.ImageRectSize then
			img.ImageRectSize = r.ImageRectSize
		end
		if r.ImageRectPosition then
			img.ImageRectOffset = r.ImageRectPosition
		end
		return img.Image ~= ""
	elseif type(r) == "string" and r ~= "" then
		img.Image = r
		if rectSize then
			img.ImageRectSize = rectSize
		end
		if rectOffset then
			img.ImageRectOffset = rectOffset
		end
		return true
	end
	return false
end

----------------------------------------------------------------
-- DATA PARSING (Support-games / Premium / Keysystem / Keyless)
----------------------------------------------------------------
local function detectMode(s)
	s = tostring(s or ""):lower()
	local ks = s:find("key%s*system") ~= nil
	local kl = s:find("keyless") ~= nil
	if s:find("both") or (ks and kl) then
		return "both"
	end
	if kl then
		return "keyless"
	end
	if ks then
		return "keysystem"
	end
end

local function parseList(text)
	local list, seen = {}, {}
	local function add(id, url, mode, name)
		id = tonumber(id)
		if not id then
			return
		end
		local e = seen[id]
		if e then
			e.Url = e.Url or url
			e.Mode = e.Mode or mode
			e.Name = e.Name or name
			return
		end
		e = { Id = id, Url = url, Mode = mode, Name = name }
		seen[id] = e
		table.insert(list, e)
	end

	local ok, data = pcall(HttpService.JSONDecode, HttpService, text)
	if ok and type(data) == "table" then
		local function walk(k, v)
			local nk = tonumber(k)
			if v == true then
				if nk and nk > 9999 then
					add(nk)
				end
			elseif type(v) == "string" then
				if nk and nk > 9999 then
					add(nk, v:match("^https?://") and v or nil, detectMode(v))
				end
			elseif type(v) == "table" then
				local id = v.PlaceId or v.placeId or v.PlaceID or v.id or v.Id
				local url = v.Url or v.url or v.Script or v.script or v.Link or v.link
				local mode = detectMode(v.Mode or v.mode or v.Type or v.type or v.Label or v.label)
				local name = v.Name or v.name
				if id then
					add(id, url, mode, name)
				else
					if nk and nk > 9999 then
						add(nk, url, mode, name)
					end
					for kk, vv in pairs(v) do
						walk(kk, vv)
					end
				end
			end
		end
		for k, v in pairs(data) do
			walk(k, v)
		end
	else
		for line in tostring(text):gmatch("[^\r\n]+") do
			local clean = (line:gsub("https?://[^%s\"',;]+", ""))
			local id = clean:match("(%d%d%d%d%d+)")
			if id then
				add(id, line:match("https?://[^%s\"',;]+"), detectMode(line))
			end
		end
	end
	return list
end

local function toMap(list)
	local m = {}
	for _, e in ipairs(list) do
		m[e.Id] = e
	end
	return m
end

local Data = { loaded = false, fromSite = false, universes = {}, supportedList = {}, premium = {}, keysystem = {}, keyless = {} }

local function loadData()
	local function fetch(url)
		local body = httpGet(url)
		return body and parseList(body) or {}
	end
	Data.supportedList = fetch(Config.URLs.Supported)
	Data.premium = toMap(fetch(Config.URLs.Premium))
	Data.keysystem = toMap(fetch(Config.URLs.Keysystem))
	Data.keyless = toMap(fetch(Config.URLs.Keyless))
	local site = httpJson(Config.Api .. "/api/state")
	if type(site) == "table" and type(site.games) == "table" then
		local list = {}
		for _, g in ipairs(site.games) do
			local id = tonumber(tostring(g.link or ""):match("games/(%d+)"))
			if id then
				table.insert(list, {
					Id = id,
					Mode = detectMode(g.label),
					Name = g.name,
					Universe = tonumber(g.uni),
					Icon = g.img,
					Playing = g.playing,
					Visits = g.visits,
					Status = g.status,
				})
				if g.uni then
					Data.universes[tonumber(g.uni)] = true
				end
			end
		end
		Data.supportedList = list
		Data.fromSite = true
	end
	if not Data.fromSite and #Data.supportedList == 0 then
		local seen = {}
		for _, map in ipairs({ Data.keysystem, Data.keyless, Data.premium }) do
			for id, e in pairs(map) do
				if not seen[id] then
					seen[id] = true
					table.insert(Data.supportedList, e)
				end
			end
		end
	end
	Data.loaded = true
end

local function isSupported(placeId)
	if Data.universes[game.GameId] then
		return true
	end
	for _, e in ipairs(Data.supportedList) do
		if e.Id == placeId then
			return true
		end
	end
	return Data.keysystem[placeId] ~= nil or Data.keyless[placeId] ~= nil or Data.premium[placeId] ~= nil
end

local function modeLabel(e)
	local mode = e.Mode
	if not mode then
		local ks = Data.keysystem[e.Id] or Data.premium[e.Id]
		local kl = Data.keyless[e.Id]
		if ks and kl then
			mode = "both"
		elseif kl then
			mode = "keyless"
		else
			mode = "keysystem"
		end
	end
	if mode == "both" then
		return "Support: Keysystem + Keyless"
	elseif mode == "keyless" then
		return "Support: Keyless"
	end
	return "Support: Keysystem"
end

----------------------------------------------------------------
-- KEY CHECK (Picka's Hub key server)
----------------------------------------------------------------
local REASONS = {
	invalid = "Invalid key.",
	expired = "This key has expired. Renew it on the website.",
	revoked = "This key was revoked.",
	bound_to_another_account = "This key belongs to another account.",
	uid_required = "Could not read your account.",
}

local function enc(s)
	return HttpService:UrlEncode(tostring(s))
end

local currentKey

local function checkKey(key)
	key = tostring(key or ""):gsub("%s+", "")
	if key == "" then
		return false, "Enter a key first."
	end
	local data = httpJson(Config.Api .. "/api/verify?key=" .. enc(key) .. "&uid=" .. LocalPlayer.UserId .. "&gid=" .. game.GameId)
	if type(data) ~= "table" then
		return false, "Could not reach the key server."
	end
	if data.valid == true then
		currentKey = key
		return true, "Key valid.", data.premium == true
	end
	if data.reason == "wrong_game" then
		local g = tostring(data.game or "")
		return false, "This key only works in " .. (g ~= "" and g or "another game") .. "."
	end
	return false, REASONS[data.reason] or "Invalid key."
end

local function reportExecution(mode)
	local gameName = "Unknown"
	pcall(function()
		gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
	end)
	local executor = "Unknown"
	pcall(function()
		executor = identifyexecutor()
	end)
	local url = Config.Api .. "/api/executed?uid=" .. LocalPlayer.UserId
		.. "&username=" .. enc(LocalPlayer.Name)
		.. "&display=" .. enc(LocalPlayer.DisplayName)
		.. "&game=" .. enc(gameName)
		.. "&executor=" .. enc(executor)
		.. "&gid=" .. game.GameId
	if mode == "keyless" then
		url = url .. "&mode=Keyless"
	elseif currentKey then
		url = url .. "&key=" .. enc(currentKey)
	end
	task.spawn(httpGet, url)
end

local function runUrl(url)
	local src = httpGet(url)
	if not src then
		return false, "Could not download the script."
	end
	local fn = loadstring(src)
	if not fn then
		return false, "Script has an error."
	end
	task.spawn(fn)
	return true
end

----------------------------------------------------------------
-- WINDOW
----------------------------------------------------------------
local function guiParent()
	if gethui then
		local ok, h = pcall(gethui)
		if ok and h then
			return h
		end
	end
	local ok = pcall(function()
		return CoreGui.Name
	end)
	return ok and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
end

local parent = guiParent()
for _, g in ipairs(parent:GetChildren()) do
	if g.Name == "PickasHubKeysystem" or g.Name == "PickasHubNotify" then
		g:Destroy()
	end
end

local gui = new("ScreenGui", {
	Name = "PickasHubKeysystem",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})
if syn and syn.protect_gui then
	pcall(syn.protect_gui, gui)
end
gui.Parent = parent

local window = new("CanvasGroup", {
	Size = UDim2.fromOffset(580, 340),
	Position = UDim2.fromScale(0.5, 0.5),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	GroupTransparency = 1,
	Parent = gui,
}, { corner(10) })
local winScale = new("UIScale", { Scale = 0.9, Parent = window })
new("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.new(1, 1, 1),
	Parent = window,
}, {
	corner(10),
	stroke(T.Line, 1, 0),
	new("UIGradient", { Color = ColorSequence.new(T.Bg1, T.Bg2), Rotation = 125 }),
})

local closeWindow

-- Top bar
local topbar = new("Frame", { Size = UDim2.new(1, 0, 0, 46), BackgroundTransparency = 1, Parent = window })
new("ImageLabel", {
	Size = UDim2.fromOffset(28, 28),
	Position = UDim2.fromOffset(14, 9),
	BackgroundTransparency = 1,
	Image = Config.Logo,
	Parent = topbar,
})
label({
	Text = Config.Title,
	Font = Enum.Font.GothamBold,
	TextSize = 17,
	Position = UDim2.fromOffset(52, 5),
	Size = UDim2.new(1, -110, 0, 20),
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = topbar,
})
local descLabel = label({
	Text = "Loading...",
	TextSize = 12,
	TextColor3 = T.Sub,
	Position = UDim2.fromOffset(52, 25),
	Size = UDim2.new(1, -110, 0, 16),
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd,
	Parent = topbar,
})
local closeBtn = new("TextButton", {
	Text = "X",
	Font = Enum.Font.GothamBold,
	TextSize = 14,
	TextColor3 = T.Text,
	BackgroundColor3 = T.Card,
	Size = UDim2.fromOffset(28, 28),
	Position = UDim2.new(1, -40, 0, 9),
	AutoButtonColor = false,
	Parent = topbar,
}, { corner(8) })
closeBtn.MouseButton1Click:Connect(function()
	closeWindow()
end)
new("Frame", {
	Size = UDim2.new(1, 0, 0, 1),
	Position = UDim2.new(0, 0, 1, 0),
	BackgroundColor3 = T.Line,
	BackgroundTransparency = 0,
	BorderSizePixel = 0,
	Parent = topbar,
})

-- Dragging
do
	local dragging, dragStart, startPos
	topbar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging, dragStart, startPos = true, i.Position, window.Position
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if
			dragging
			and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch)
		then
			local d = i.Position - dragStart
			window.Position =
				UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
end

-- Sidebar (flush to the left edge)
local sidebar = new("Frame", {
	Position = UDim2.new(0, 0, 0, 47),
	Size = UDim2.new(0, 150, 1, -47),
	BackgroundColor3 = T.Side,
	BackgroundTransparency = 0,
	BorderSizePixel = 0,
	Parent = window,
})
new("Frame", {
	Size = UDim2.new(0, 1, 1, 0),
	Position = UDim2.new(1, -1, 0, 0),
	BackgroundColor3 = T.Line,
	BorderSizePixel = 0,
	Parent = sidebar,
})
local tabHl = new("Frame", {
	Size = UDim2.new(1, -16, 0, 34),
	Position = UDim2.fromOffset(8, 8),
	BackgroundColor3 = T.Accent,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Parent = sidebar,
}, { corner(6) })
new("Frame", {
	Size = UDim2.new(0, 3, 0, 18),
	Position = UDim2.new(0, 0, 0.5, -9),
	BackgroundColor3 = T.Accent,
	BorderSizePixel = 0,
	Parent = tabHl,
}, { corner(2) })
local tabList = new("Frame", {
	Size = UDim2.new(1, 0, 1, -70),
	BackgroundTransparency = 1,
	Parent = sidebar,
}, {
	new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
	new("UIPadding", {
		PaddingTop = UDim.new(0, 8),
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
	}),
})

-- Profile card (bottom of sidebar)
local profile = new("Frame", {
	Position = UDim2.new(0, 8, 1, -60),
	Size = UDim2.new(1, -16, 0, 52),
	BackgroundColor3 = T.Card,
	Parent = sidebar,
}, { corner(8), stroke(T.Line, 1, 0) })
local avatar = new("ImageLabel", {
	Size = UDim2.fromOffset(36, 36),
	Position = UDim2.fromOffset(8, 8),
	BackgroundColor3 = T.Bg1,
	Parent = profile,
}, { corner(18) })
task.spawn(function()
	local ok, img = pcall(function()
		return Players:GetUserThumbnailAsync(
			LocalPlayer.UserId,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size48x48
		)
	end)
	if ok then
		avatar.Image = img
	end
end)
label({
	Text = LocalPlayer.DisplayName,
	Font = Enum.Font.GothamBold,
	TextSize = 13,
	Position = UDim2.fromOffset(50, 8),
	Size = UDim2.new(1, -56, 0, 18),
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd,
	Parent = profile,
})
label({
	Text = "@" .. LocalPlayer.Name,
	TextSize = 11,
	TextColor3 = T.Sub,
	Position = UDim2.fromOffset(50, 26),
	Size = UDim2.new(1, -56, 0, 16),
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd,
	Parent = profile,
})

-- Content area
local content = new("Frame", {
	Position = UDim2.new(0, 150, 0, 47),
	Size = UDim2.new(1, -150, 1, -47),
	BackgroundTransparency = 1,
	Parent = window,
})

-- Notifications (separate gui so they can outlive the window)
local notifGui = new("ScreenGui", {
	Name = "PickasHubNotify",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	DisplayOrder = 10,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})
if syn and syn.protect_gui then
	pcall(syn.protect_gui, notifGui)
end
notifGui.Parent = parent
local notifHolder = new("Frame", {
	Size = UDim2.new(0, 290, 1, -28),
	Position = UDim2.new(1, -14, 1, -14),
	AnchorPoint = Vector2.new(1, 1),
	BackgroundTransparency = 1,
	Parent = notifGui,
}, {
	new("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
	}),
})
local KIND = {
	success = Color3.fromRGB(110, 222, 150),
	error = Color3.fromRGB(240, 98, 120),
	info = T.Accent,
}
local notifCount, notifOrder, windowClosed = 0, 0, false

local function notify(kind, title, text, duration)
	duration = duration or 3.5
	notifCount += 1
	notifOrder += 1
	local color = KIND[kind] or T.Accent
	local wrap = new("Frame", {
		Size = UDim2.new(1, 0, 0, 62),
		BackgroundTransparency = 1,
		LayoutOrder = notifOrder,
		Parent = notifHolder,
	})
	local card = new("CanvasGroup", {
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.new(0, 70, 0, 0),
		BackgroundColor3 = T.Card,
		GroupTransparency = 1,
		Parent = wrap,
	}, { corner(8), stroke(T.Line, 1, 0) })
	new("Frame", {
		Size = UDim2.new(0, 3, 1, 0),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Parent = card,
	})
	label({
		Text = title,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		Position = UDim2.fromOffset(14, 7),
		Size = UDim2.new(1, -24, 0, 18),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = card,
	})
	label({
		Text = text or "",
		TextSize = 12,
		TextColor3 = T.Sub,
		Position = UDim2.fromOffset(14, 25),
		Size = UDim2.new(1, -24, 0, 30),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		Parent = card,
	})
	local timer = new("Frame", {
		Size = UDim2.new(1, 0, 0, 2),
		Position = UDim2.new(0, 0, 1, -2),
		BackgroundColor3 = color,
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0,
		Parent = card,
	})
	TweenService:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Position = UDim2.new(0, 0, 0, 0),
		GroupTransparency = 0,
	}):Play()
	TweenService:Create(timer, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
		Size = UDim2.new(0, 0, 0, 2),
	}):Play()
	task.delay(duration, function()
		local out = TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
			Position = UDim2.new(0, 70, 0, 0),
			GroupTransparency = 1,
		})
		out:Play()
		out.Completed:Wait()
		wrap:Destroy()
		notifCount -= 1
		if notifCount == 0 and windowClosed then
			notifGui:Destroy()
		end
	end)
end

-- Tabs
local pages, tabButtons, tabOrder, pageCards = {}, {}, {}, {}
local activeTab

local function reveal(card, i)
	card.Position = UDim2.fromOffset(26, 0)
	card.GroupTransparency = 1
	task.delay(0.05 + i * 0.06, function()
		if card.Parent then
			TweenService:Create(card, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Position = UDim2.fromOffset(0, 0),
				GroupTransparency = 0,
			}):Play()
		end
	end)
end

local function selectTab(name)
	activeTab = name
	for n, p in pairs(pages) do
		local show = n == name
		if show and not p.Visible then
			if #(pageCards[n] or {}) == 0 then
				p.Position = UDim2.fromOffset(0, 14)
				TweenService:Create(p, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Position = UDim2.fromOffset(0, 0),
				}):Play()
			end
		end
		p.Visible = show
	end
	for i, c in ipairs(pageCards[name] or {}) do
		reveal(c, i)
	end
	local b = tabButtons[name]
	TweenService:Create(tabHl, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Position = UDim2.fromOffset(8, 8 + (b.Index - 1) * 40),
		BackgroundTransparency = 0.88,
	}):Play()
	for n, tb in pairs(tabButtons) do
		local on = n == name
		TweenService:Create(tb.Text, TweenInfo.new(0.25), { TextColor3 = on and T.Text or T.Sub }):Play()
		TweenService:Create(tb.Icon, TweenInfo.new(0.25), { ImageColor3 = on and T.Accent or T.Sub }):Play()
	end
end

local order = 0
local function addTab(name, iconName)
	order += 1
	local btn = new("TextButton", {
		Name = name,
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = order,
		Parent = tabList,
	})
	local ic = new("ImageLabel", {
		Size = UDim2.fromOffset(18, 18),
		Position = UDim2.new(0, 14, 0.5, -9),
		BackgroundTransparency = 1,
		ImageColor3 = T.Sub,
		Parent = btn,
	})
	applyIcon(ic, iconName)
	local tx = label({
		Text = name,
		Position = UDim2.fromOffset(40, 0),
		Size = UDim2.new(1, -46, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = T.Sub,
		Parent = btn,
	})
	local page = new("Frame", {
		Name = name,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = content,
	}, {
		new("UIPadding", {
			PaddingTop = UDim.new(0, 14),
			PaddingBottom = UDim.new(0, 14),
			PaddingLeft = UDim.new(0, 14),
			PaddingRight = UDim.new(0, 14),
		}),
	})
	pages[name] = page
	tabButtons[name] = { Btn = btn, Text = tx, Icon = ic, Index = order }
	table.insert(tabOrder, name)
	btn.MouseEnter:Connect(function()
		if activeTab ~= name then
			TweenService:Create(tx, TweenInfo.new(0.2), { TextColor3 = T.Text }):Play()
		end
	end)
	btn.MouseLeave:Connect(function()
		if activeTab ~= name then
			TweenService:Create(tx, TweenInfo.new(0.2), { TextColor3 = T.Sub }):Play()
		end
	end)
	btn.MouseButton1Click:Connect(function()
		if activeTab ~= name then
			selectTab(name)
		end
	end)
	return page
end

-- a card that slides/fades in whenever its tab is opened
local function cardIn(pageName, parentFrame, height, layoutOrder)
	local wrap = new("Frame", {
		Size = UDim2.new(1, 0, 0, height),
		BackgroundTransparency = 1,
		LayoutOrder = layoutOrder,
		Parent = parentFrame,
	})
	local card = new("CanvasGroup", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = T.Card,
		Parent = wrap,
	}, { corner(8), stroke(T.Line, 1, 0) })
	pageCards[pageName] = pageCards[pageName] or {}
	table.insert(pageCards[pageName], card)
	if pages[pageName] and pages[pageName].Visible then
		reveal(card, #pageCards[pageName])
	end
	return card
end

----------------------------------------------------------------
-- MAIN TAB
----------------------------------------------------------------
local mainPage = addTab("Main", "house")
local col = new("Frame", {
	Size = UDim2.new(0, 330, 0, 0),
	AutomaticSize = Enum.AutomaticSize.Y,
	Position = UDim2.fromScale(0.5, 0.5),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	Parent = mainPage,
}, {
	new("UIListLayout", {
		Padding = UDim.new(0, 12),
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
	}),
})

-- key box with a key icon on the left
local keyHolder = new("Frame", {
	Size = UDim2.new(1, 0, 0, 48),
	BackgroundColor3 = T.Card,
	LayoutOrder = 1,
	Parent = col,
}, { corner(6) })
local keyStroke = stroke(T.Line, 1, 0)
keyStroke.Parent = keyHolder
local keyIcon = new("ImageLabel", {
	Size = UDim2.fromOffset(18, 18),
	Position = UDim2.new(0, 14, 0.5, -9),
	BackgroundTransparency = 1,
	ImageColor3 = T.Sub,
	Parent = keyHolder,
})
applyIcon(keyIcon, "key")
local keyBox = new("TextBox", {
	Size = UDim2.new(1, -48, 1, 0),
	Position = UDim2.fromOffset(42, 0),
	BackgroundTransparency = 1,
	PlaceholderText = "Put Key Here...",
	PlaceholderColor3 = T.Sub,
	Text = "",
	TextColor3 = T.Text,
	Font = Enum.Font.Gotham,
	TextSize = 15,
	TextXAlignment = Enum.TextXAlignment.Left,
	ClearTextOnFocus = false,
	Parent = keyHolder,
})
keyBox.Focused:Connect(function()
	TweenService:Create(keyStroke, TweenInfo.new(0.2), { Color = T.Accent }):Play()
	TweenService:Create(keyIcon, TweenInfo.new(0.2), { ImageColor3 = T.Accent }):Play()
end)
keyBox.FocusLost:Connect(function()
	TweenService:Create(keyStroke, TweenInfo.new(0.2), { Color = T.Line }):Play()
	TweenService:Create(keyIcon, TweenInfo.new(0.2), { ImageColor3 = T.Sub }):Play()
end)

pcall(function()
	if isfile and isfile(Config.KeyFile) then
		keyBox.Text = readfile(Config.KeyFile)
	end
end)

local row = new("Frame", {
	Size = UDim2.new(1, 0, 0, 44),
	BackgroundTransparency = 1,
	LayoutOrder = 2,
	Parent = col,
}, {
	new("UIListLayout", {
		Padding = UDim.new(0, 10),
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}),
})

-- status overlay (checking / loading), shown in place of the controls
local status = new("CanvasGroup", {
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	GroupTransparency = 1,
	Visible = false,
	Parent = mainPage,
})
local sCol = new("Frame", {
	Size = UDim2.new(0, 280, 0, 0),
	AutomaticSize = Enum.AutomaticSize.Y,
	Position = UDim2.fromScale(0.5, 0.5),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	Parent = status,
}, {
	new("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
	}),
})
local sIcon = new("ImageLabel", {
	Size = UDim2.fromOffset(34, 34),
	BackgroundTransparency = 1,
	ImageColor3 = T.Accent,
	LayoutOrder = 1,
	Parent = sCol,
})
local sIconScale = new("UIScale", { Scale = 1, Parent = sIcon })
local sTitle = label({
	Text = "",
	Font = Enum.Font.GothamBold,
	TextSize = 17,
	Size = UDim2.new(1, 0, 0, 22),
	LayoutOrder = 2,
	Parent = sCol,
})
local sSub = label({
	Text = "",
	TextSize = 12,
	TextColor3 = T.Sub,
	Size = UDim2.new(1, 0, 0, 16),
	LayoutOrder = 3,
	Parent = sCol,
})
local sTrack = new("Frame", {
	Size = UDim2.new(1, 0, 0, 4),
	BackgroundColor3 = T.Line,
	BorderSizePixel = 0,
	LayoutOrder = 4,
	Parent = sCol,
}, { corner(2) })
local sFill = new("Frame", {
	Size = UDim2.fromScale(0, 1),
	BackgroundColor3 = T.Accent,
	BorderSizePixel = 0,
	Parent = sTrack,
}, { corner(2) })

local function shakeKey()
	keyStroke.Color = KIND.error
	local base = col.Position
	for _, dx in ipairs({ -9, 9, -6, 6, -3, 3, 0 }) do
		TweenService:Create(col, TweenInfo.new(0.045), {
			Position = UDim2.new(base.X.Scale, dx, base.Y.Scale, base.Y.Offset),
		}):Play()
		task.wait(0.045)
	end
	TweenService:Create(keyStroke, TweenInfo.new(0.5), { Color = T.Line }):Play()
end

local spinning = false
task.spawn(function()
	while gui.Parent do
		if spinning then
			sIcon.Rotation = (sIcon.Rotation + 7) % 360
		else
			sIcon.Rotation = 0
		end
		task.wait(1 / 60)
	end
end)

local function showStatus()
	col.Visible = false
	status.Visible = true
	status.GroupTransparency = 1
	sFill.Size = UDim2.fromScale(0, 1)
	TweenService:Create(status, TweenInfo.new(0.25), { GroupTransparency = 0 }):Play()
end

local function hideStatus()
	spinning = false
	local t = TweenService:Create(status, TweenInfo.new(0.2), { GroupTransparency = 1 })
	t:Play()
	t.Completed:Wait()
	status.Visible = false
	col.Visible = true
end

local function setStatus(title, sub, color, iconName, progress)
	sTitle.Text = title
	sTitle.TextColor3 = color or T.Text
	sSub.Text = sub or ""
	sTitle.TextTransparency = 1
	sSub.TextTransparency = 1
	TweenService:Create(sTitle, TweenInfo.new(0.3), { TextTransparency = 0 }):Play()
	TweenService:Create(sSub, TweenInfo.new(0.3), { TextTransparency = 0 }):Play()
	sIcon.Image = ""
	sIcon.ImageRectSize = Vector2.new(0, 0)
	sIcon.ImageRectOffset = Vector2.new(0, 0)
	if iconName then
		if not applyIcon(sIcon, iconName) and iconName == "loader-circle" then
			applyIcon(sIcon, "loader")
		end
	end
	sIcon.ImageColor3 = color or T.Accent
	spinning = iconName == "loader-circle"
	if not spinning and iconName then
		sIconScale.Scale = 0
		TweenService:Create(sIconScale, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Scale = 1,
		}):Play()
	else
		sIconScale.Scale = 1
	end
	TweenService:Create(sFill, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = UDim2.fromScale(progress, 1),
	}):Play()
end

local busy = false

local function loadScript(url, mode)
	setStatus("Loading script", "Downloading...", nil, "loader-circle", 0.75)
	local ok, err = runUrl(url)
	if ok then
		reportExecution(mode)
		setStatus("Done", "Starting " .. Config.Title, KIND.success, "check", 1)
		task.wait(0.7)
		closeWindow()
	else
		hideStatus()
		notify("error", "Load failed", err)
		busy = false
	end
end

local function waitForData()
	local waited = 0
	while not Data.loaded and waited < 10 do
		task.wait(0.2)
		waited += 0.2
	end
end

button({
	Text = "Submit",
	Icon = "check",
	TextSize = 15,
	Size = UDim2.new(0.5, -5, 1, 0),
	LayoutOrder = 1,
	Parent = row,
}, "primary", function()
	if busy then
		return
	end
	busy = true
	task.spawn(function()
		showStatus()
		setStatus("Checking key", "Contacting the key server...", nil, "loader-circle", 0.35)
		local ok, msg, premium = checkKey(keyBox.Text)
		task.wait(0.5)
		if not ok then
			hideStatus()
			task.spawn(shakeKey)
			notify("error", "Invalid key", msg)
			busy = false
			return
		end
		pcall(function()
			if writefile then
				if makefolder and isfolder and not isfolder("PickasHub") then
					makefolder("PickasHub")
				end
				writefile(Config.KeyFile, keyBox.Text)
			end
		end)
		waitForData()
		local id = game.PlaceId
		local ks, pr = Data.keysystem[id], Data.premium[id]
		local url
		if premium then
			url = (pr and pr.Url) or (ks and ks.Url)
		else
			url = ks and ks.Url
			if not url and pr then
				hideStatus()
				notify("error", "Premium only", "This game needs a premium key.")
				busy = false
				return
			end
		end
		if not url then
			hideStatus()
			notify("error", "Not supported", "This game is not in the supported list.")
			busy = false
			return
		end
		setStatus("Key valid", "Welcome, " .. LocalPlayer.DisplayName, KIND.success, "check", 0.55)
		notify("success", "Key valid", premium and "Premium access granted." or "Access granted.")
		task.wait(1)
		loadScript(url)
	end)
end)

button({
	Text = "Get a key",
	Icon = "external-link",
	TextSize = 15,
	Size = UDim2.new(0.5, -5, 1, 0),
	LayoutOrder = 2,
	Parent = row,
}, "ghost", function()
	if copy(Config.GetKeyLink) then
		notify("info", "Link copied", "Open it in your browser to get a key.")
	else
		notify("info", "Get a key", Config.GetKeyLink, 6)
	end
end)

button({
	Text = "Keyless Mode",
	Icon = "zap",
	TextSize = 15,
	Size = UDim2.new(1, 0, 0, 40),
	LayoutOrder = 3,
	Parent = col,
}, "ghost", function()
	if busy then
		return
	end
	busy = true
	task.spawn(function()
		waitForData()
		local e = Data.keyless[game.PlaceId]
		if not (e and e.Url) then
			notify("error", "Keyless unavailable", "This game has no keyless script.")
			busy = false
			return
		end
		showStatus()
		setStatus("Keyless Mode", "Activating...", nil, "loader-circle", 0.35)
		task.wait(0.8)
		setStatus("Keyless mode activated", "No key needed for this game", KIND.success, "check", 0.55)
		notify("success", "Keyless mode activated", "Loading the script...")
		task.wait(1)
		loadScript(e.Url, "keyless")
	end)
end)

----------------------------------------------------------------
-- CREDITS TAB
----------------------------------------------------------------
local creditsPage = addTab("Credits", "users")
new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = creditsPage })
for i, c in ipairs(Config.Credits) do
	local card = cardIn("Credits", creditsPage, 56, i)
	label({
		Text = c[1],
		TextSize = 12,
		TextColor3 = T.Sub,
		Position = UDim2.fromOffset(14, 8),
		Size = UDim2.new(1, -28, 0, 16),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = card,
	})
	label({
		Text = c[2],
		Font = Enum.Font.GothamBold,
		TextSize = 17,
		Position = UDim2.fromOffset(14, 26),
		Size = UDim2.new(1, -28, 0, 22),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = card,
	})
end

do
	local card = cardIn("Credits", creditsPage, 56, #Config.Credits + 1)
	local shown = Config.Website:gsub("^https?://", "")
	shown = shown:gsub("/$", "")
	label({
		Text = "Website",
		TextSize = 12,
		TextColor3 = T.Sub,
		Position = UDim2.fromOffset(14, 8),
		Size = UDim2.new(1, -120, 0, 16),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = card,
	})
	label({
		Text = shown,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		Position = UDim2.fromOffset(14, 26),
		Size = UDim2.new(1, -120, 0, 22),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = card,
	})
	button({
		Text = "Copy",
		Icon = "copy",
		Size = UDim2.fromOffset(80, 30),
		Position = UDim2.new(1, -90, 0.5, -15),
		Parent = card,
	}, "primary", function()
		if copy(Config.Website) then
			notify("success", "Link copied", "Website link copied.")
		else
			notify("error", "Copy not supported", "Your executor has no clipboard function.")
		end
	end)
end

----------------------------------------------------------------
-- CLOUD TAB (supported games)
----------------------------------------------------------------
local cloudPage = addTab("Cloud", "cloud")
local cloudList = new("ScrollingFrame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 3,
	ScrollBarImageColor3 = T.Accent,
	CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	Parent = cloudPage,
}, {
	new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
	new("UIPadding", { PaddingRight = UDim.new(0, 6) }),
})
local cloudHint = label({
	Text = "Loading games...",
	TextColor3 = T.Sub,
	Size = UDim2.new(1, 0, 0, 24),
	Parent = cloudList,
})

local function fetchInfo(placeId)
	local u = api("apis", "/universes/v1/places/" .. placeId .. "/universe")
	local uid = u and u.universeId
	if not uid then
		return
	end
	local g = api("games", "/v1/games?universeIds=" .. uid)
	local info = g and g.data and g.data[1]
	local t = api(
		"thumbnails",
		"/v1/games/icons?universeIds=" .. uid .. "&returnPolicy=PlaceHolder&size=150x150&format=Png&isCircular=false"
	)
	local imgUrl = t and t.data and t.data[1] and t.data[1].imageUrl
	return {
		Universe = uid,
		Name = info and info.name,
		Playing = info and info.playing,
		Visits = info and info.visits,
		Icon = imgUrl,
	}
end

local function iconAsset(url, uid)
	local fallback = "rbxthumb://type=GameIcon&id=" .. uid .. "&w=150&h=150"
	if not (writefile and getcustomasset and url) then
		return fallback
	end
	local ok, asset = pcall(function()
		local bytes = game:HttpGet(url)
		if makefolder and isfolder and not isfolder("PickasHub") then
			makefolder("PickasHub")
		end
		local path = "PickasHub/icon_" .. uid .. ".png"
		writefile(path, bytes)
		return getcustomasset(path)
	end)
	return ok and asset or fallback
end

local function addGameCard(e, idx)
	local card = cardIn("Cloud", cloudList, 76, idx)
	local thumb = new("ImageLabel", {
		Size = UDim2.fromOffset(56, 56),
		Position = UDim2.fromOffset(10, 10),
		BackgroundColor3 = T.Bg1,
		Parent = card,
	}, { corner(8) })
	local nameL = label({
		Text = e.Name or ("Place " .. e.Id),
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		Position = UDim2.fromOffset(76, 8),
		Size = UDim2.new(1, -200, 0, 18),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = card,
	})
	local statL = label({
		Text = "Online: ...  |  Visits: ...",
		TextSize = 12,
		TextColor3 = T.Sub,
		Position = UDim2.fromOffset(76, 28),
		Size = UDim2.new(1, -200, 0, 16),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = card,
	})
	label({
		Text = modeLabel(e) .. (e.Status and ("  |  " .. e.Status) or ""),
		TextSize = 12,
		TextColor3 = T.Accent,
		Font = Enum.Font.GothamBold,
		Position = UDim2.fromOffset(76, 48),
		Size = UDim2.new(1, -200, 0, 16),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = card,
	})
	button({
		Text = "",
		Icon = "link",
		Size = UDim2.fromOffset(30, 30),
		Position = UDim2.new(1, -118, 0.5, -15),
		Parent = card,
	}, "ghost", function()
		if copy("https://www.roblox.com/games/" .. e.Id) then
			notify("success", "Game link copied", "Paste it in your browser to join.")
		else
			notify("error", "Copy not supported", "Your executor has no clipboard function.")
		end
	end)
	button({
		Text = "Join",
		Icon = "play",
		Size = UDim2.fromOffset(72, 30),
		Position = UDim2.new(1, -82, 0.5, -15),
		Parent = card,
	}, "primary", function()
		notify("info", "Teleporting", "Place ID " .. e.Id)
		local ok, err = pcall(function()
			TeleportService:Teleport(e.Id, LocalPlayer)
		end)
		if not ok then
			local ok2, err2 = pcall(function()
				TeleportService:TeleportAsync(e.Id, { LocalPlayer })
			end)
			if not ok2 then
				notify("error", "Teleport failed", tostring(err2 or err))
			end
		end
	end)
	task.spawn(function()
		local info
		if e.Universe then
			info = { Universe = e.Universe, Name = e.Name, Playing = e.Playing, Visits = e.Visits, Icon = e.Icon }
		else
			info = fetchInfo(e.Id)
		end
		if not info then
			return
		end
		if info.Name then
			nameL.Text = info.Name
		end
		statL.Text = "Online: " .. short(info.Playing) .. "  |  Visits: " .. short(info.Visits)
		thumb.Image = iconAsset(info.Icon, info.Universe)
	end)
end

----------------------------------------------------------------
-- COMMUNITY TAB
----------------------------------------------------------------
local communityPage = addTab("Community", "message-circle")
new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = communityPage })

local function addLinkCard(i, title, link, iconId, letter)
	local card = cardIn("Community", communityPage, 64, i)
	local box = new("Frame", {
		Size = UDim2.fromOffset(42, 42),
		Position = UDim2.fromOffset(10, 11),
		BackgroundColor3 = T.Bg1,
		Parent = card,
	}, { corner(8), stroke(T.Line, 1, 0) })
	if iconId ~= "" then
		new("ImageLabel", {
			Size = UDim2.fromOffset(26, 26),
			Position = UDim2.fromOffset(8, 8),
			BackgroundTransparency = 1,
			Image = iconId,
			Parent = box,
		})
	else
		label({
			Text = letter,
			TextColor3 = T.Sub,
			Font = Enum.Font.GothamBold,
			TextSize = 20,
			Size = UDim2.fromScale(1, 1),
			Parent = box,
		})
	end
	label({
		Text = title,
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		Position = UDim2.fromOffset(62, 11),
		Size = UDim2.new(1, -175, 0, 20),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = card,
	})
	label({
		Text = link,
		TextSize = 11,
		TextColor3 = T.Sub,
		Position = UDim2.fromOffset(62, 33),
		Size = UDim2.new(1, -175, 0, 18),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = card,
	})
	button({
		Text = "Copy",
		Icon = "copy",
		Size = UDim2.fromOffset(80, 30),
		Position = UDim2.new(1, -90, 0.5, -15),
		Parent = card,
	}, "primary", function()
		if copy(link) then
			notify("success", "Link copied", title)
		else
			notify("error", "Copy not supported", "Your executor has no clipboard function.")
		end
	end)
end

addLinkCard(1, "Discord Community", Config.DiscordLink, Config.DiscordIcon, "D")
addLinkCard(2, "Telegram Community", Config.TelegramLink, Config.TelegramIcon, "T")

----------------------------------------------------------------
-- START
----------------------------------------------------------------
closeWindow = function()
	if windowClosed then
		return
	end
	windowClosed = true
	TweenService:Create(winScale, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
		Scale = 0.9,
	}):Play()
	local t = TweenService:Create(window, TweenInfo.new(0.28, Enum.EasingStyle.Quad), { GroupTransparency = 1 })
	t:Play()
	t.Completed:Wait()
	gui:Destroy()
	if notifCount == 0 then
		notifGui:Destroy()
	end
end

-- intro: sidebar slides in from the edge, then the tab items appear one by one
sidebar.Position = UDim2.new(0, -150, 0, 47)
for _, n in ipairs(tabOrder) do
	tabButtons[n].Text.TextTransparency = 1
	tabButtons[n].Icon.ImageTransparency = 1
end
selectTab("Main")
task.delay(0.18, function()
	TweenService:Create(sidebar, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Position = UDim2.new(0, 0, 0, 47),
	}):Play()
	for i, n in ipairs(tabOrder) do
		task.delay(0.25 + i * 0.07, function()
			TweenService:Create(tabButtons[n].Text, TweenInfo.new(0.35), { TextTransparency = 0 }):Play()
			TweenService:Create(tabButtons[n].Icon, TweenInfo.new(0.35), { ImageTransparency = 0 }):Play()
		end)
	end
end)
TweenService:Create(winScale, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
	Scale = 1,
}):Play()
TweenService:Create(window, TweenInfo.new(0.35, Enum.EasingStyle.Quad), { GroupTransparency = 0 }):Play()

local tpFail = TeleportService.TeleportInitFailed:Connect(function(player, _, message)
	if player == LocalPlayer then
		notify("error", "Teleport failed", tostring(message))
	end
end)
gui.Destroying:Connect(function()
	tpFail:Disconnect()
end)

task.spawn(function()
	local gameName = game.Name
	pcall(function()
		gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
	end)
	loadData()
	descLabel.Text = gameName .. (isSupported(game.PlaceId) and " (Supported)" or " (Not Supported)")

	cloudHint:Destroy()
	if #Data.supportedList == 0 then
		label({
			Text = "No supported games found.",
			TextColor3 = T.Sub,
			Size = UDim2.new(1, 0, 0, 24),
			Parent = cloudList,
		})
	end
	for i, e in ipairs(Data.supportedList) do
		addGameCard(e, i)
	end
end)
