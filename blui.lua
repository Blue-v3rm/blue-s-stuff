local UserInputService = game:GetService('UserInputService')
local TweenService = game:GetService('TweenService')
local function CreateObject(b,c)local d=Instance.new(b)for e,f in ipairs(c)do d[f[1]]=f[2]end;return d end
local BLUI, BLUILib = {}, {}

local GUI_PARENT = game.PlaceId == 569627493 and game.Players.LocalPlayer.PlayerGui or game.CoreGui

tbl_copy = function(tbl)
	local copy = {}
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            v = tbl_copy(v)
        end
        copy[k] = v
    end
    return copy
end

BLUI.User = {}
BLUI.User.Interface = CreateObject("ScreenGui",{{"Name","BLUI"},{"Parent",GUI_PARENT}})
BLUI.User.MB1 = false
BLUI.User.MousePosition = UserInputService:GetMouseLocation()
BLUI.User.MouseDelta = Vector2.new(0, 0)
BLUI.User.Dragging = {}
BLUI.User.Dragging.Element = nil
BLUI.User.Dragging.Velocity = Vector2.new(0,0)
BLUI.User.Settings = {
	DoubleClick = .12
}

BLUI.Elements = {}

BLUI.Classes = {}

BLUI.Classes.Window = {
	Class = "Window",
	Properties = {
		Name = "BLUI_Window",
		Draggable = true,
		Scrollable = true,
		Autoalign = true,
	},
	Internal = {Clicked=0,Minimized=false,Debounce=true};
	Elements = {},
	GUIBase = nil,
	AlignElements = function(self)
		if not self.Internal.Minimized then
			local last = 2
			for i, v in pairs(self.Elements) do
				v.GUIObject:TweenPosition(UDim2.new(0.05, 0, 1, last),Enum.EasingDirection.Out,Enum.EasingStyle.Sine,.1)
				last = last + v.Internal.Height + 2
			end
		end
	end,
	OrderElements = function(self)
		
	end,
	Create = function(self, Element, Properties)
		Properties = Properties or {}
		local LayoutOrder = #self.Elements+1
		for i, v in pairs(Properties) do
			if i == "LayoutOrder" then
				LayoutOrder = v
			end
		end
		Properties.LayoutOrder = LayoutOrder
		return BLUILib:Create(Element,Properties,self)
	end,
	Initialize = function(self)
		self.GUIObject.TextLabel.Text = self.Properties.Name
		self.GUIObject.Container.ChildAdded:Connect(function()
			wait()
			self:AlignElements()
		end)
	end,
	ToggleVisiblity = function(self)
		if self.Internal.Debounce then
			self.Internal.Debounce = false
			self.Internal.Minimized = not self.Internal.Minimized
			if self.Internal.Minimized then
				for i, v in pairs(self.Elements) do
					v.GUIObject:TweenPosition(UDim2.new(0.05, 0, 0, 0),Enum.EasingDirection.Out,Enum.EasingStyle.Sine,.1)
				end
				wait(.1)
				for i, v in pairs(self.Elements) do
					v.GUIObject.Visible = false
				end
			else
				for i, v in pairs(self.Elements) do
					v.GUIObject.Visible = true
				end
				self:AlignElements()
				wait(.1)
			end
			wait(.2)
			self.Internal.Debounce = true
		end
	end
}

do
	local GUIBase = CreateObject("Frame",{{"ZIndex",100},{"BackgroundColor3",Color3.new(0.0980392,0.462745,0.823529)},{"BorderSizePixel",0},{"Position",UDim2.new(0,100,0,100)},{"Size",UDim2.new(0,150,0,32)}})
	local UIGradient = CreateObject("UIGradient",{{"Color",ColorSequence.new(Color3.fromRGB(25,118,210),Color3.fromRGB(30,146,255))},{"Parent",GUIBase}})
	local TextLabel = CreateObject("TextLabel",{{"ZIndex",101},{"Font",Enum.Font.SourceSansLight},{"FontSize",Enum.FontSize.Size32},{"Text","BLUI_Window"},{"TextColor3",Color3.new(1,1,1)},{"TextSize",30},{"BackgroundColor3",Color3.new(0.0980392,0.462745,0.823529)},{"BackgroundTransparency",1},{"Size",UDim2.new(1,0,1,0)},{"Parent",GUIBase}})
	local Container = CreateObject("Folder",{{"Name","Container"},{"Parent",GUIBase}})
	BLUI.Classes.Window.GUIBase = GUIBase
end

BLUI.Classes.Toggle = {
	Class = "Toggle",
	Properties = {
		Name = "BLUI_Toggle",
		Value = false,
		LayoutOrder = 1,
	},
	Internal = {
		Debounce = true,
		Height = 30,
	},
	Elements = {},
	Connections = {},
	GUIBase = nil,
	Toggle = function(self,...)
		self.Properties.Value = not self.Properties.Value
		TweenService:Create(
			self.GUIObject.TextButton,
			TweenInfo.new(
				0.15,
				Enum.EasingStyle.Sine,
				Enum.EasingDirection.Out
			),
			{
				BackgroundColor3 = self.Properties.Value and Color3.fromRGB(31, 170, 0) or Color3.fromRGB(59, 64, 72)
			}
		):Play()
	end,
	AlignElements = function(self)
		if not self.Internal.Minimized then
			local last = 2
			for i, v in pairs(self.Elements) do
				v.GUIObject:TweenPosition(UDim2.new(0, 3, 1, last),Enum.EasingDirection.Out,Enum.EasingStyle.Sine,.2)
				last = last + v.Internal.Height + 2
			end
		end
	end,
	Connect = function(self,Function)
		table.insert(self.Connections, Function)
	end,
	Initialize = function(self)
		game:GetService('RunService').RenderStepped:wait()
		self.GUIObject.TextClipping.TextLabel.Text = self.Properties.Name
		self.GUIObject.TextButton.BackgroundColor3 = (self.Properties.Value and Color3.fromRGB(31,170,0) or Color3.fromRGB(59, 64, 72))
		self.GUIObject.LayoutOrder = self.Properties.LayoutOrder
		self.GUIObject.TextButton.MouseButton1Down:Connect(function(...)
			if self.Internal.Debounce then
				self.Internal.Debounce = false
				local args = {...}
				self.Toggle(self,...)
				for i, v in pairs(self.Connections) do
					spawn(function() v(self.Properties.Value, unpack(args)) end)
				end
				wait(.2)
				self.Internal.Debounce = true
			end
		end)
	end,
	Create = function(self, Element, Properties)
		self.Internal.Height = self.Internal.Height + BLUI.Classes[Element].Internal.Height + 2
		Properties = Properties or {}
		local LayoutOrder = #self.Elements+1
		for i, v in pairs(Properties) do
			if i == "LayoutOrder" then
				LayoutOrder = v
			end
		end
		Properties.LayoutOrder = LayoutOrder
		return BLUILib:Create(Element,Properties,self)
	end,
}

do
	local Toggle = CreateObject("Frame",{{"ZIndex",50},{"BackgroundColor3",Color3.new(0.152941,0.172549,0.203922)},{"BorderSizePixel",0},{"Position",UDim2.new(0.0500000007,0,1,2)},{"Size",UDim2.new(0.899999976,0,0,30)},{"Name","Toggle"}})
	local Button = CreateObject("TextButton",{{"ZIndex",51},{"AutoButtonColor",false},{"Font",Enum.Font.SourceSans},{"FontSize",Enum.FontSize.Size14},{"Text",""},{"TextColor3",Color3.new(0,0,0)},{"TextSize",14},{"TextTransparency",1},{"BackgroundColor3",Color3.fromRGB(39, 44, 52)},{"BorderSizePixel",2},{"Position",UDim2.new(1,-25,0,5)},{"Size",UDim2.new(0,20,0,20)},{"Parent",Toggle}})
	local Clipping = CreateObject("Frame",{{"BackgroundColor3",Color3.new(1,1,1)},{"BackgroundTransparency",1},{"ClipsDescendants",},{"Position",UDim2.new(0,10,0,5)},{"Size",UDim2.new(1,-40,1,-10)},{"Name","TextClipping"},{"Parent",Toggle}})
	local Label = CreateObject("TextLabel",{{"ZIndex",51},{"Font",Enum.Font.SourceSans},{"FontSize",Enum.FontSize.Size24},{"Text","BLUI_Toggle"},{"TextColor3",Color3.new(0.784314,0.784314,0.784314)},{"TextSize",20},{"TextXAlignment",Enum.TextXAlignment.Left},{"BackgroundColor3",Color3.new(1,1,1)},{"BackgroundTransparency",1},{"Size",UDim2.new(1,0,1,0)},{"Parent",Clipping}})
	local Container = CreateObject("Folder",{{"Name","Container"},{"Parent",Toggle}})
	BLUI.Classes.Toggle.GUIBase = Toggle
end

BLUI.Classes.TextInput = {
	Class = "TextInput",
	Properties = {
		Name = "BLUI_Input",
		Value = '...',
		Mode = 'num', -- num, text, player,
		DefaultValue = nil,
	},
	Internal = {
		Height = 25,
	},
	Elements = {},
	Connections = {},
	GUIBase = nil,
	Connect = function(self, Function)
		table.insert(self.Connections, Function)
	end,
	Initialize = function(self)
		game:GetService('RunService').RenderStepped:wait()
		if self.Properties.Mode == 'plr' then
			self.GUIObject.TextBox.TextXAlignment = Enum.TextXAlignment.Left
			self.GUIObject.TextBox.TextLabel.TextXAlignment = Enum.TextXAlignment.Left
		end
		self.GUIObject.TextBox.TextLabel.Text = ""
		self.GUIObject.TextBox.PlaceholderText = self.Properties.DefaultValue
		self.GUIObject.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
			local Text = self.GUIObject.TextBox.Text
			self.GUIObject.TextBox.TextLabel.Text = ""
			if self.Properties.Mode == 'num' then
				self.GUIObject.TextBox.Text = Text:gsub("%D+","")
			elseif self.Properties.Mode == 'plr' and #self.GUIObject.TextBox.Text>0 then
				for i, v in pairs(game:GetService('Players'):GetPlayers()) do
					if v.Name:lower():sub(1, #Text) == Text:lower() then
						self.GUIObject.TextBox.TextLabel.Text = v.Name
					end
				end
			end
		end)
		self.GUIObject.TextBox.FocusLost:Connect(function(enterPressed)
			if enterPressed then
				if self.Properties.Mode == 'num' then
					self.Properties.Value = tonumber(self.GUIObject.TextBox.Text)
				elseif self.Properties.Mode == 'plr' then
					if self.GUIObject.TextBox.TextLabel.Text ~= "" then
						self.Properties.Value = game:GetService('Players')[self.GUIObject.TextBox.TextLabel.Text]
						self.GUIObject.TextBox.Text = self.GUIObject.TextBox.TextLabel.Text
						self.GUIObject.TextBox.TextLabel.Text = ""
					end
				else
					self.Properties.Value = self.GUIObject.TextBox.Text
				end
				for i, v in pairs(self.Connections) do
					spawn(function() v(self.Properties.Value) end)
				end
			end
		end)
	end
}

do
	local Frame = CreateObject("Frame",{{"BackgroundColor3",Color3.new(0.160784,0.262745,0.305882)},{"BorderSizePixel",0},{"Position",UDim2.new(0,3,1,2)},{"Size",UDim2.new(1,-6,0,25)}})
	local TextBox = CreateObject("TextBox",{{"Font",Enum.Font.SourceSans},{"FontSize",Enum.FontSize.Size18},{"PlaceholderColor3",Color3.new(0.784314,0.784314,0.784314)},{"PlaceholderText","..."},{"Text",""},{"TextColor3",Color3.new(0.745098,0.745098,0.745098)},{"TextSize",16},{"BackgroundColor3",Color3.new(1,1,1)},{"BackgroundTransparency",0.89999997615814},{"Position",UDim2.new(0,3,0,3)},{"Size",UDim2.new(1,-6,1,-6)},{"Parent",Frame}})
	local TextLabel = CreateObject("TextLabel",{{"Font",Enum.Font.SourceSans},{"FontSize",Enum.FontSize.Size18},{"Text","..."},{"TextColor3",Color3.new(0.784314,0.784314,0.784314)},{"TextSize",16},{"BackgroundColor3",Color3.new(1,1,1)},{"BackgroundTransparency",1},{"Size",UDim2.new(1,0,1,0)},{"Parent",TextBox}})
	BLUI.Classes.TextInput.GUIBase = Frame
end

BLUI.Classes.Button = {
	Class = "Button",
	Properties = {
		Name = "BLUI_Button",
	},
	Internal = {
		Height = 30,
	},
	Elements = {},
	Connections = {},
	GUIBase = nil,
	Connect = function(self, Function)
		table.insert(self.Connections, Function)
	end,
	Initialize = function(self)
		self.GUIObject.TextButton.TextLabel.Text = self.Properties.Name
	end
}

do
	local Frame = CreateObject("Frame",{{"BackgroundColor3",Color3.new(0.152941,0.172549,0.203922)},{"BorderSizePixel",0},{"Position",UDim2.new(0.0500000007,0,1,60)},{"Size",UDim2.new(0.899999976,0,0,30)},{"Name","Trigger"}})
	local Button = CreateObject("TextButton",{{"Font",Enum.Font.SourceSansLight},{"FontSize",Enum.FontSize.Size14},{"Text",""},{"TextColor3",Color3.new(1,1,1)},{"TextSize",14},{"BackgroundColor3",Color3.new(0.278431,0.298039,0.345098)},{"Position",UDim2.new(0,5,0,5)},{"Size",UDim2.new(1,-10,0,20)},{"Parent",Frame}})
	local Label = CreateObject("TextLabel",{{"Font",Enum.Font.SourceSans},{"FontSize",Enum.FontSize.Size18},{"Text","Button"},{"TextColor3",Color3.new(0.784314,0.784314,0.784314)},{"TextSize",18},{"BackgroundColor3",Color3.new(1,1,1)},{"BackgroundTransparency",1},{"Size",UDim2.new(1,0,1,0)},{"Parent",Button}})
	BLUI.Classes.GUIBase = Frame
end

function BLUILib:Create(Element,Properties,Parent)
	if BLUI.Classes[Element] then
		local newElement = tbl_copy(BLUI.Classes[Element])
		Properties = Properties or {}
		for Property, Value in pairs(Properties) do
			newElement.Properties[Property] = Value
		end
		newElement.GUIObject = newElement.GUIBase:Clone()
		if newElement.Class == "Window" then
			table.insert(BLUI.Elements, newElement)
			newElement.GUIObject.Parent = BLUI.User.Interface
			newElement.GUIObject.Position = UDim2.new(0,100+(170*#BLUI.Elements),0,100)
		else
			table.insert(Parent.Elements, newElement)
			newElement.GUIObject.Parent = Parent.GUIObject.Container
			Parent:AlignElements()
		end
		newElement:Initialize()
		game:GetService('RunService').RenderStepped:Wait()
		return newElement
	end
end

UserInputService.InputBegan:Connect(function(InputObject)
	if InputObject.UserInputType == Enum.UserInputType.MouseButton1 then
		BLUI.User.MB1 = true
		local MouseLocation = UserInputService:GetMouseLocation()
		for i, Element in pairs(BLUI.Elements) do
			local GUIObject = Element.GUIObject
			if Element.Properties.Draggable then
				if MouseLocation.X >= GUIObject.AbsolutePosition.X and MouseLocation.X <= GUIObject.AbsolutePosition.X + GUIObject.AbsoluteSize.X then
					if MouseLocation.Y-35 >= GUIObject.AbsolutePosition.Y and MouseLocation.Y-35 <= GUIObject.AbsolutePosition.Y + GUIObject.AbsoluteSize.Y then
						BLUI.User.Dragging.Element = Element
						if Element.Internal.Debounce then
							if tick()-Element.Internal.Clicked<BLUI.User.Settings.DoubleClick then
								Element:ToggleVisiblity()
							end
							Element.Internal.Clicked = tick()
						end
					end
				end
			end
		end
	elseif InputObject.UserInputType == Enum.UserInputType.Keyboard then
		if InputObject.KeyCode == Enum.KeyCode.CapsLock then
			BLUI.User.Interface.Enabled = not BLUI.User.Interface.Enabled
		end
	end
end)

UserInputService.InputChanged:Connect(function(InputObject)
	if InputObject.UserInputType == Enum.UserInputType.MouseMovement then
		
	end
end)

UserInputService.InputEnded:Connect(function(InputObject)
	if InputObject.UserInputType == Enum.UserInputType.MouseButton1 then
		BLUI.User.MB1 = false
		if BLUI.User.Dragging.Element then
			BLUI.User.Dragging.Element = nil
		end
	end
end)

game:GetService('RunService'):BindToRenderStep("DragGUI", Enum.RenderPriority.Input.Value-1, function()
	BLUI.User.MouseDelta = (UserInputService:GetMouseLocation()-BLUI.User.MousePosition)
	BLUI.User.MousePosition = UserInputService:GetMouseLocation()
	if BLUI.User.Dragging.Element then
		BLUI.User.Dragging.Element.Velocity = BLUI.User.Dragging.Velocity
	end
	BLUI.User.Dragging.Velocity = BLUI.User.Dragging.Velocity:lerp(BLUI.User.MouseDelta,.9)
	for i, Element in pairs(BLUI.Elements) do
		if Element.Velocity and Element.Velocity.magnitude > 0 and Element.Properties.Draggable then
			if Element.GUIObject.AbsolutePosition.X <= 0 and Element.Velocity.X < 0 or Element.GUIObject.AbsolutePosition.X+Element.GUIObject.AbsoluteSize.X >= workspace.CurrentCamera.ViewportSize.X and Element.Velocity.X > 0 then
				Element.Velocity = Element.Velocity *Vector2.new(-1,1)
			end
			if Element.GUIObject.AbsolutePosition.Y <= 0 and Element.Velocity.Y < 0 or Element.GUIObject.AbsolutePosition.Y+Element.GUIObject.AbsoluteSize.Y >= workspace.CurrentCamera.ViewportSize.Y-35 and Element.Velocity.Y > 0 then
				Element.Velocity = Element.Velocity *Vector2.new(1,-1)
			end
			Element.GUIObject.Position = Element.GUIObject.Position + UDim2.new(0, Element.Velocity.X, 0, Element.Velocity.Y)
			Element.Velocity = Element.Velocity *.8
		end
	end
end)

return BLUILib
