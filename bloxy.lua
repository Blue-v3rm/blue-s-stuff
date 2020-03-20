local SMRF = game:GetService("ReplicatedStorage").SwagsManagerRemoteFunction
local LocalPlayer = game:GetService('Players').LocalPlayer
local UserInputService = game:GetService('UserInputService')
local Mouse = LocalPlayer:GetMouse()
local BLUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Blue-v3rm/blue-s-stuff/master/blui.lua"))()
local Swag = {}

function getMySwag()
	local mySwag = {}
	for i, v in pairs(SMRF:InvokeServer("GetPlayerSwagsData").value) do
		if v.purchased then
			table.insert(mySwag, {v.name,v.equipped})
		end
	end
	return mySwag
end

function equipAllSwag(name)
	for i, v in pairs(getMySwag()) do
		if not v[2] then
			SMRF:InvokeServer("EquipSwag",{["swagName"]=v[1]})
		end
	end
end

function unequipAllSwag(name)
	for i, v in pairs(getMySwag()) do
		if v[2] then
			SMRF:InvokeServer("UnequipSwag",{["swagName"]=v[1]})
		end
	end
end

function dropAllSwag()
	for i, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do 
		if v:IsA("Accessory") and v.Name ~= "antigrab" then 
			v.AncestryChanged:Connect(function()
				if v.Parent ~= workspace and v.Parent ~= nil then
					game:GetService('RunService').RenderStepped:wait()
					v.Parent = workspace
					if v.Parent == nil then
						for i, v in pairs(Swag) do
							table.remove(Swag, i)
							break
						end
					end
				end	
			end)
			v.Parent = workspace
			table.insert(Swag, v)
		end
	end
end

do
	local antigrab = Instance.new("Hat",LocalPlayer.Character)
	antigrab.Name = "antigrab"
	local handle = Instance.new("Part",antigrab)
	handle.Name = "Handle"
	handle.Massless = true
end
do
	local antigrab = Instance.new("Accessory",LocalPlayer.Character)
	antigrab.Name = "antigrab"
	local handle = Instance.new("Part",antigrab)
	handle.Name = "Handle"
	handle.Massless = true
end


game:GetService('RunService').RenderStepped:Connect(function()
	LocalPlayer.MaximumSimulationRadius = math.huge
	LocalPlayer.SimulationRadius = math.huge
	game.StarterGui:SetCoreGuiEnabled(4,true)
end)

spawn(function()
	while wait() do
		equipAllSwag()
		dropAllSwag()
		unequipAllSwag()
	end
end)

spawn(function()
	LocalPlayer.Character.Head.Anchored = true
	wait(2)	
	LocalPlayer.Character.Head.Anchored = false
end)

local Window = BLUI:Create("Window",{Name="SWAG!!"})
local Shoot = Window:Create("Toggle",{Name="Shoot"})
local Build = Window:Create("Toggle",{Name="Build"})
Shoot:Connect(function(Value)
	if Value then
		if Build.Properties.Value then
			Build:Toggle()
		end
		Shoot.Internal.Connection = Mouse.Button1Down:Connect(function()
			if Shoot.Properties.Value then
				repeat
					local validProjectile
					for i, v in pairs(Swag) do
						if v:FindFirstChild("Handle") and not v.Handle:FindFirstChild("BodyPosition") then
							if (Vector3.new(v.Handle.Position.X,LocalPlayer.Character.Head.Position.Y,v.Handle.Position.Z)-(LocalPlayer.Character.Head.Position)).magnitude<100 then
								validProjectile = v
								table.remove(Swag,i)
								break
							end
						else
							table.remove(Swag, i)
						end
					end
					if validProjectile.Handle:FindFirstChild("BodyPosition") then
						validProjectile.Handle.BodyPosition:Destroy()
					end
					validProjectile.Handle.BodyVelocity.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
					validProjectile.Handle.BodyVelocity.Velocity = CFrame.new(validProjectile.Handle.Position, Mouse.Hit.p).lookVector *300
					game:GetService('Debris'):AddItem(validProjectile.Handle.BodyVelocity, .3)
					wait(.2)
				until not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
			end
		end)
	else
		if Shoot.Internal.Connection then
			Shoot.Internal.Connection:Disconnect()
			Shoot.Internal.Connection = false
		end
	end
end)

Build:Connect(function(Value)
	if Value then
		if Shoot.Properties.Value then
			Shoot:Toggle()
		end
		Build.Internal.Connection = Mouse.Button1Down:Connect(function()
			if Build.Properties.Value then
				repeat
					local validProjectile
					for i, v in pairs(Swag) do
						if v:FindFirstChild("Handle") and not v.Handle:FindFirstChild("BodyPosition") then
							validProjectile = v
							break
						else
							table.remove(Swag, i)
						end
					end
					for i, v in pairs(validProjectile:GetDescendants()) do
						if v:IsA("BasePart") then
							v.CanCollide = false
						end
					end
					validProjectile.Handle.BodyVelocity.MaxForce = Vector3.new(0,0,0)
					local BodyPosition = validProjectile.Handle:FindFirstChild("BodyPosition") or Instance.new("BodyPosition", validProjectile.Handle)
					BodyPosition.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
					BodyPosition.D = BodyPosition.D / 5
					BodyPosition.Position = Mouse.Hit.p
					BodyPosition.Parent = validProjectile.Handle
					wait(.07)
				until not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or not Build.Properties.Value
			end
		end)
	else
		if Build.Internal.Connection then
			print("Disconnect")
			Build.Internal.Connection:Disconnect()
			Build.Internal.Connection = false
		end
	end
end)

loadstring(game:HttpGet("https://raw.githubusercontent.com/Blue-v3rm/blue-s-stuff/master/freecam.lua"))()
local FREECAM_MACRO_KB = {Enum.KeyCode.LeftShift, Enum.KeyCode.P}
local FreecamEnabled = false
game:GetService('ContextActionService'):BindActionAtPriority("FreecamToggleEvent", function(actionName,state)
	if state == Enum.UserInputState.Begin then
		FreecamEnabled = not FreecamEnabled
	end
end, false, Enum.ContextActionPriority.Low.Value-1,FREECAM_MACRO_KB[#FREECAM_MACRO_KB])

while wait() do
	if FreecamEnabled then 
		LocalPlayer.Character:SetPrimaryPartCFrame(workspace.CurrentCamera.CFrame +Vector3.new(0,10,0))
	end
	for i, v in pairs(Swag) do
		
		if v.Parent == LocalPlayer.Character then v.Parent = workspace end
		if v:FindFirstChild("Handle") then
			local bv = v.Handle:FindFirstChild("BodyVelocity") or Instance.new("BodyVelocity",v.Handle)
			bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
			if v.Handle.Position.Y < 900 then
				bv.Velocity = Vector3.new(0,5,0)
			else
				bv.Velocity = Vector3.new(0,0,0)
			end
		end
	end
end
