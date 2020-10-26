local blue = game.Players.LocalPlayer
local mc = blue.PlayerGui.Main.MainClient
local concealEnabled = false
local conceal, concealcon = Instance.new("BindableEvent")
conceal.Event:Connect(function()
	if concealEnabled then
		local gui = blue.Character.HumanoidRootPart.TotalPower
		if gui.Enabled then
    		gui.Parent = nil
    		gui.Enabled = false
    		wait()
    		gui.Parent = blue.Character.HumanoidRootPart
    	end
	else
		require(mc.NotifModule).Notify('You must respawn for your total power to appear.')
	end
end)

local mt = getrawmetatable(game)
local __namecall = mt.__namecall
make_writeable(mt,true)
mt.__namecall = function(self, ...)
	local method = getnamecallmethod()
	local args = {...}
	if typeof(method) == 'string' and method == 'InvokeServer' and self.ClassName == 'RemoteFunction' then
		if args[1] == 'WS' or args[1] == 'JP' then
			local inc = args[2] and 5 or -5
			local newStat = (args[1]=='WS' and blue.Character.Humanoid.WalkSpeed+inc) or (args[1]=='JP' and blue.Character.Humanoid.JumpPower+inc)
			return {'A', newStat}
		elseif args[1] == "CP" and not game:GetService('MarketplaceService'):UserOwnsGamePassAsync(blue.UserId, 7257155) then
			concealEnabled = not concealEnabled
			conceal:Fire()
			return 'A' 
		end
	end
	return __namecall(self, ...)
end
make_writeable(mt,false)

local fly, speedidx

for i, f in pairs(getconnections(blue.CharacterAdded)) do
    if f.Function and debug.getinfo(f.Function).short_src == mc:GetFullName() then
        fly = debug.getupvalues(f.Function)[1]
        for _, v in pairs(debug.getupvalues(fly)) do
            if v==20 and type(v) == 'number' then
                speedidx = _
                break
            end
        end
    end
end

local function onCharacterAdded()
	repeat wait() until blue.Character and blue.Character:FindFirstChild('HumanoidRootPart') and blue.Character.HumanoidRootPart:FindFirstChild('BodyPosition')
	local bp = blue.Character.HumanoidRootPart.BodyPosition
	bp.Changed:Connect(function(prop)
		if prop == 'Position' then
			debug.setupvalue(fly, 22, blue.Character.Humanoid.WalkSpeed)
		end
	end)
end
blue.CharacterAdded:Connect(onCharacterAdded)
onCharacterAdded()
