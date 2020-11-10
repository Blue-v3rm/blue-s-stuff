if not game:IsLoaded() then
	game.Loaded:wait()
end

if game.PlaceId == 4042427666 then
	game:GetService('TeleportService'):Teleport(5113680396)
	return
end

if game.PlaceId ~= 5113680396 then
	return
end

local LocalPlayer = game:GetService('Players').LocalPlayer

local function waitFor(Parent, Child)
	if not Parent:FindFirstChild(Child) then
		repeat
			Parent.ChildAdded:wait()
		until Parent:FindFirstChild(Child)
	end
	return Parent:FindFirstChild(Child)
end

waitFor(LocalPlayer,'PlayerGui')
waitFor(LocalPlayer.PlayerGui,'Intro')
waitFor(LocalPlayer.PlayerGui.Intro,'PlayButton')
if not (LocalPlayer.PlayerGui.Intro.PlayButton.Size.X.Scale >= .4) or not (LocalPlayer.PlayerGui.Intro.PlayButton.Size.Y.Scale >= 0.075) then
	repeat
		LocalPlayer.PlayerGui.Intro.PlayButton:GetPropertyChangedSignal'Size':wait()
	until LocalPlayer.PlayerGui.Intro.PlayButton.Size.X.Scale >= .4 and LocalPlayer.PlayerGui.Intro.PlayButton.Size.Y.Scale >= 0.075
end
for _, v in pairs(getconnections(LocalPlayer.PlayerGui.Intro.PlayButton.MouseButton1Click)) do
	v:Fire()
end

local function cloneTable(toClone)
	local cloned = {}
	for k, v in pairs(toClone) do
		cloned[k] = v
	end
	return cloned
end

local function onCharacterAdded()
	LocalPlayer.Character:MoveTo(Vector3.new(0,1e7+8,0))
	wait(.2)
	for _, v in pairs(LocalPlayer.Character:GetChildren()) do
		if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
			v.Anchored = true 
		end
	end
	delay(.1, function()
		waitFor(LocalPlayer.Character, 'LowerTorso')
		delay(0, function() waitFor(LocalPlayer.Character.LowerTorso, 'Root'):Destroy() end)
		delay(0, function() waitFor(LocalPlayer.Character.HumanoidRootPart, 'TotalPower'):Destroy() end)
	end)
end

onCharacterAdded()
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

local ChikaraEvent = Instance.new("BindableEvent")

waitFor(LocalPlayer,'PlayerGui')
waitFor(LocalPlayer.PlayerGui, 'Main')
waitFor(LocalPlayer.PlayerGui.Main, 'MainClient')
local PlayerDataClient = require(waitFor(LocalPlayer.PlayerGui.Main.MainClient, 'PlayerDataClient'))

local realData = cloneTable(PlayerDataClient.Data)
PlayerDataClient.Data = {}
setmetatable(PlayerDataClient.Data, {__index=realData,__newindex = function(t, k, v)
	realData[k] = v
	if k == 'Chikara' then
		ChikaraEvent:Fire()
	end
end})

local function findTargetChikara()
	for _, v in pairs(workspace.MouseIgnore:GetChildren()) do
		if v.Name == 'ChikaraCrate' and v:FindFirstChild'ClickBox' then
			return v
		end
	end
	return
end

local failed = 0
while failed < 5 do
	local nextCrate = false
	spawn(function()
		ChikaraEvent.Event:wait()
		nextCrate = true
	end)
	local crate = findTargetChikara()
	while crate and crate.Parent == workspace.MouseIgnore and not nextCrate and wait(1) do
		if crate:FindFirstChild('ClickBox') then
			waitFor(LocalPlayer.Character,'HumanoidRootPart').CFrame = crate.ClickBox.CFrame
			fireclickdetector(crate.ClickBox.ClickDetector)
		else
			break
		end
	end
	if not crate then
		failed = failed + 1
		wait(2)
	end
end

local data = {}
if isfile('chikara.json') then
	data = game:GetService('HttpService'):JSONDecode(readfile('chikara.json'))
else
	data = {}
end

for jobid, joined in pairs(data) do
	if tick()-tonumber(joined) > 60*8 then
		data[jobid] = nil
	end
end
data[game.JobId] = math.floor(tick())
writefile('chikara.json',game:GetService('HttpService'):JSONEncode(data))

local baseUrl = 'https://games.roblox.com/v1/games/5113680396/servers/Public?sortOrder=Asc&limit=100'
local cursor = '&cursor=%s'
local servers = game:GetService('HttpService'):JSONDecode(game:HttpGet(baseUrl))
while wait() do
	for _, server in pairs(servers.data) do
		if not data[server.id] and server.playing < server.maxPlayers-2 then
			game:GetService('TeleportService'):TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
			wait(5)
		end
	end
	servers = game:GetService('HttpService'):JSONDecode(game:HttpGet(string.format(baseUrl..cursor, servers.nextPageCursor)))
end
