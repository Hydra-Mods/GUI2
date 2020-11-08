if (not vUIGlobal) then
	return
end

local vUI, GUI, Language, Assets, Settings, Defaults = vUIGlobal:get()
local GUI2 = vUI:NewPlugin("vUI_GUI2")

-- Constants
local GUI_WIDTH = 726
local GUI_HEIGHT = 340
local SPACING = 3

local HEADER_WIDTH = GUI_WIDTH - (SPACING * 2)
local HEADER_HEIGHT = 20
local HEADER_SPACING = 5

local BUTTON_LIST_WIDTH = 126
local BUTTON_LIST_HEIGHT = (GUI_HEIGHT - HEADER_HEIGHT - (SPACING * 2) - 2)

local PARENT_WIDTH = GUI_WIDTH - BUTTON_LIST_WIDTH - ((SPACING * 2) + 2)

local GROUP_HEIGHT = 80
local GROUP_WIDTH = 270

local MENU_BUTTON_WIDTH = BUTTON_LIST_WIDTH - (SPACING * 2)
local MENU_BUTTON_HEIGHT = 20

local WIDGET_HEIGHT = 20

local LABEL_SPACING = 3

local SELECTED_HIGHLIGHT_ALPHA = 0.3
local MOUSEOVER_HIGHLIGHT_ALPHA = 0.1
local LAST_ACTIVE_DROPDOWN

local MAX_WIDGETS_SHOWN = 14

local type = type
local pairs = pairs
local tinsert = table.insert
local tremove = table.remove
local tsort = table.sort
local floor = math.floor
local InCombatLockdown = InCombatLockdown
local IsModifierKeyDown = IsModifierKeyDown

GUI2.WindowHooks = {onshow = {}, onhide = {}}

-- New concept
GUI2.Categories = {}
GUI2.CategoryNames = {}
GUI2.Widgets = {}
GUI2.OnLoadCalls = {}

local Scroll = function(self)
	local FirstLeft
	local FirstRight
	local Offset = self.LeftWidgetsBG.ScrollingDisabled and 1 or self.Offset
	
	for i = 1, self.WidgetCount do
		if self.LeftWidgets[i] then
			self.LeftWidgets[i]:ClearAllPoints()
			
			if (i >= Offset) and (i <= Offset + MAX_WIDGETS_SHOWN - 1) then
				if (not FirstLeft) then
					self.LeftWidgets[i]:SetPoint("TOPLEFT", self.LeftWidgetsBG, SPACING, -SPACING)
					FirstLeft = i
				else
					self.LeftWidgets[i]:SetPoint("TOP", self.LeftWidgets[i-1], "BOTTOM", 0, -2)
				end
				
				self.LeftWidgets[i]:Show()
			else
				self.LeftWidgets[i]:Hide()
			end
		end
	end
	
	Offset = self.RightWidgetsBG.ScrollingDisabled and 1 or self.Offset
	
	for i = 1, self.WidgetCount do
		if self.RightWidgets[i] then
			self.RightWidgets[i]:ClearAllPoints()
			
			if (i >= Offset) and (i <= Offset + MAX_WIDGETS_SHOWN - 1) then
				if (not FirstRight) then
					self.RightWidgets[i]:SetPoint("TOPRIGHT", self.RightWidgetsBG, -SPACING, -SPACING)
					FirstRight = i
				else
					self.RightWidgets[i]:SetPoint("TOP", self.RightWidgets[i-1], "BOTTOM", 0, -2)
				end
				
				self.RightWidgets[i]:Show()
			else
				self.RightWidgets[i]:Hide()
			end
		end
	end
end

local SetOffsetByDelta = function(self, delta)
	if (delta == 1) then -- Up
		self.Offset = self.Offset - 1
		
		if (self.Offset <= 1) then
			self.Offset = 1
		end
	else -- Down
		self.Offset = self.Offset + 1
		
		if (self.Offset > (self.WidgetCount - (MAX_WIDGETS_SHOWN - 1))) then
			self.Offset = self.Offset - 1
		end
	end
end

local WindowOnMouseWheel = function(self, delta)
	self:SetOffsetByDelta(delta)
	self:Scroll()
	self.ScrollBar:SetValue(self.Offset)
end

local SetWindowOffset = function(self, offset)
	self.Offset = offset
	
	if (self.Offset <= 1) then
		self.Offset = 1
	elseif (self.Offset > (self.WidgetCount - MAX_WIDGETS_SHOWN - 1)) then
		self.Offset = self.Offset - 1
	end
	
	self:Scroll()
end

local WindowScrollBarOnValueChanged = function(self)
	local Parent = self:GetParent()
	
	Parent.Offset = Round(self:GetValue())
	
	Parent:Scroll()
end

local WindowScrollBarOnMouseWheel = function(self, delta)
	WindowOnMouseWheel(self:GetParent(), delta)
end

local NoScroll = function() end -- Just to prevent zooming while we're working in the GUI

local AddWindowScrollBar = function(self)
	local LeftMaxValue = (#self.LeftWidgets - (MAX_WIDGETS_SHOWN - 1))
	local RightMaxValue = (#self.RightWidgets - (MAX_WIDGETS_SHOWN - 1))
	
	self.MaxScroll = max(LeftMaxValue, RightMaxValue, 1)
	self.WidgetCount = max(#self.LeftWidgets, #self.RightWidgets)
	
	self.ScrollParent = CreateFrame("Frame", nil, self, "BackdropTemplate")
	self.ScrollParent:SetPoint("TOPRIGHT", self, 0, 0)
	self.ScrollParent:SetPoint("BOTTOMRIGHT", self, 0, 0)
	self.ScrollParent:SetWidth(WIDGET_HEIGHT)
	self.ScrollParent:SetBackdrop(vUI.BackdropAndBorder)
	self.ScrollParent:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-main-color"]))
	self.ScrollParent:SetBackdropBorderColor(0, 0, 0)
	
	local ScrollBar = CreateFrame("Slider", nil, self, "BackdropTemplate")
	ScrollBar:SetPoint("TOPLEFT", self.ScrollParent, 3, -3)
	ScrollBar:SetPoint("BOTTOMRIGHT", self.ScrollParent, -3, 3)
	ScrollBar:SetThumbTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	ScrollBar:SetOrientation("VERTICAL")
	ScrollBar:SetValueStep(1)
	ScrollBar:SetBackdrop(vUI.BackdropAndBorder)
	ScrollBar:SetBackdropColor(vUI:HexToRGB(Settings["ui-widget-bg-color"]))
	ScrollBar:SetBackdropBorderColor(0, 0, 0)
	ScrollBar:SetMinMaxValues(1, self.MaxScroll)
	ScrollBar:SetValue(1)
	ScrollBar:EnableMouseWheel(true)
	ScrollBar:SetScript("OnMouseWheel", WindowScrollBarOnMouseWheel)
	ScrollBar:SetScript("OnValueChanged", WindowScrollBarOnValueChanged)
	
	ScrollBar.Window = self
	
	local Thumb = ScrollBar:GetThumbTexture() 
	Thumb:SetSize(ScrollBar:GetWidth(), WIDGET_HEIGHT)
	Thumb:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Thumb:SetVertexColor(0, 0, 0)
	
	ScrollBar.NewTexture = ScrollBar:CreateTexture(nil, "BORDER")
	ScrollBar.NewTexture:SetPoint("TOPLEFT", Thumb, 0, 0)
	ScrollBar.NewTexture:SetPoint("BOTTOMRIGHT", Thumb, 0, 0)
	ScrollBar.NewTexture:SetTexture(Assets:GetTexture("Blank"))
	ScrollBar.NewTexture:SetVertexColor(0, 0, 0)
	
	ScrollBar.NewTexture2 = ScrollBar:CreateTexture(nil, "OVERLAY")
	ScrollBar.NewTexture2:SetPoint("TOPLEFT", ScrollBar.NewTexture, 1, -1)
	ScrollBar.NewTexture2:SetPoint("BOTTOMRIGHT", ScrollBar.NewTexture, -1, 1)
	ScrollBar.NewTexture2:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	ScrollBar.NewTexture2:SetVertexColor(vUI:HexToRGB(Settings["ui-widget-bright-color"]))
	
	ScrollBar.Progress = ScrollBar:CreateTexture(nil, "ARTWORK")
	ScrollBar.Progress:SetPoint("TOPLEFT", ScrollBar, 1, -1)
	ScrollBar.Progress:SetPoint("BOTTOMRIGHT", ScrollBar.NewTexture, "TOPRIGHT", -1, 0)
	ScrollBar.Progress:SetTexture(Assets:GetTexture("Blank"))
	ScrollBar.Progress:SetVertexColor(vUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	self:EnableMouseWheel(true)
	
	self.Scroll = Scroll
	self.SetWindowOffset = SetWindowOffset
	self.SetOffsetByDelta = SetOffsetByDelta
	self.ScrollBar = ScrollBar
	
	self:SetWindowOffset(1)
	
	ScrollBar:Show()
	
	if (self.MaxScroll == 1) then
		Thumb:Hide()
		ScrollBar.NewTexture:Hide()
		ScrollBar.NewTexture2:Hide()
		ScrollBar.Progress:Hide()
		self:SetScript("OnMouseWheel", NoScroll)
	else
		self:SetScript("OnMouseWheel", WindowOnMouseWheel)
	end
end

function GUI2:SortButtons()
	tsort(self.Categories, function(a, b)
		return a.Name < b.Name
	end)
	
	self.NumShownButtons = 0
	
	for i = 1, #self.Categories do
		tsort(self.Categories[i].Buttons, function(a, b)
			return a.Name < b.Name
		end)
		
		for j = 1, #self.Categories[i].Buttons do
			if (j == 1) then
				self.Categories[i].Buttons[j]:SetPoint("TOPLEFT", self.Categories[i], "BOTTOMLEFT", 0, -2)
			else
				self.Categories[i].Buttons[j]:SetPoint("TOPLEFT", self.Categories[i].Buttons[j-1], "BOTTOMLEFT", 0, -2)
			end
			
			self.NumShownButtons = self.NumShownButtons + 1
		end
		
		if (i == 1) then
			self.Categories[i]:SetPoint("TOPLEFT", self.SelectionParent, "TOPLEFT", SPACING, -SPACING)
		elseif #self.Categories[i-1].Buttons then
			self.Categories[i]:SetPoint("TOPLEFT", self.Categories[i-1].Buttons[#self.Categories[i-1].Buttons], "BOTTOMLEFT", 0, -2)
		else
			-- But this has to actually consider anchoring to the previous categories children, not the last category
			self.Categories[i]:SetPoint("TOPLEFT", self.Categories[i-1], "BOTTOMLEFT", 0, -2)
		end
		
		self.NumShownButtons = self.NumShownButtons + 1
	end
end

function GUI2:CreateCategory(name)
	local Category = CreateFrame("Frame", nil, self)
	Category:SetSize(MENU_BUTTON_WIDTH, MENU_BUTTON_HEIGHT)
	Category:SetFrameLevel(self:GetFrameLevel() + 2)
	Category.SortName = name
	Category.Name = name
	Category.Buttons = {}
	
	Category.Text = Category:CreateFontString(nil, "OVERLAY")
	Category.Text:SetPoint("CENTER", Category, 0, 0)
	--Category.Text:SetSize(GROUP_WIDTH - 6, WIDGET_HEIGHT) -- Explicit size ruins the lines below
	vUI:SetFontInfo(Category.Text, Settings["ui-widget-font"], Settings["ui-font-size"])
	Category.Text:SetJustifyH("CENTER")
	Category.Text:SetText(format("|cFF%s%s|r", Settings["ui-widget-color"], name))
	
	-- Header Left Line
	Category.Left = CreateFrame("Frame", nil, Category, "BackdropTemplate")
	Category.Left:SetHeight(4)
	Category.Left:SetPoint("LEFT", Category, 0, 0)
	Category.Left:SetPoint("RIGHT", Category.Text, "LEFT", -SPACING, 0)
	Category.Left:SetBackdrop(vUI.BackdropAndBorder)
	Category.Left:SetBackdropColor(0, 0, 0)
	Category.Left:SetBackdropBorderColor(0, 0, 0)
	
	Category.Left.Texture = Category.Left:CreateTexture(nil, "OVERLAY")
	Category.Left.Texture:SetPoint("TOPLEFT", Category.Left, 1, -1)
	Category.Left.Texture:SetPoint("BOTTOMRIGHT", Category.Left, -1, 1)
	Category.Left.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	Category.Left.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-button-texture-color"]))
	
	-- Header Right Line
	Category.Right = CreateFrame("Frame", nil, Category, "BackdropTemplate")
	Category.Right:SetHeight(4)
	Category.Right:SetPoint("RIGHT", Category, 0, 0)
	Category.Right:SetPoint("LEFT", Category.Text, "RIGHT", SPACING, 0)
	Category.Right:SetBackdrop(vUI.BackdropAndBorder)
	Category.Right:SetBackdropColor(0, 0, 0)
	Category.Right:SetBackdropBorderColor(0, 0, 0)
	
	Category.Right.Texture = Category.Right:CreateTexture(nil, "OVERLAY")
	Category.Right.Texture:SetPoint("TOPLEFT", Category.Right, 1, -1)
	Category.Right.Texture:SetPoint("BOTTOMRIGHT", Category.Right, -1, 1)
	Category.Right.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	Category.Right.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-button-texture-color"]))
	
	self.TotalSelections = (self.TotalSelections or 0) + 1
	
	tinsert(self.Categories, Category)
	self.CategoryNames[name] = Category
end

local SortWindow = function(self)
	local NumLeftWidgets = #self.LeftWidgets
	local NumRightWidgets = #self.RightWidgets
	
	if NumLeftWidgets then
		for i = 1, NumLeftWidgets do
			self.LeftWidgets[i]:ClearAllPoints()
		
			if (i == 1) then
				self.LeftWidgets[i]:SetPoint("TOPLEFT", self.LeftWidgetsBG, SPACING, -SPACING)
			else
				self.LeftWidgets[i]:SetPoint("TOP", self.LeftWidgets[i-1], "BOTTOM", 0, -2)
			end
		end
	end
	
	if NumRightWidgets then
		for i = 1, NumRightWidgets do
			self.RightWidgets[i]:ClearAllPoints()
			
			if (i == 1) then
				self.RightWidgets[i]:SetPoint("TOPRIGHT", self.RightWidgetsBG, -SPACING, -SPACING)
			else
				self.RightWidgets[i]:SetPoint("TOP", self.RightWidgets[i-1], "BOTTOM", 0, -2)
			end
		end
	end
	
	AddWindowScrollBar(self)
end

function GUI2:CreateWidgetWindow(category, name, parent)
	-- Window
	local Window = CreateFrame("Frame", nil, self, "BackdropTemplate")
	Window:SetWidth(PARENT_WIDTH)
	Window:SetPoint("BOTTOMRIGHT", self, -SPACING, SPACING)
	Window:SetPoint("TOPRIGHT", self.CloseButton, "BOTTOMRIGHT", 0, -2)
	Window:SetBackdropBorderColor(0, 0, 0)
	Window:Hide()
	
	Window.LeftWidgetsBG = CreateFrame("Frame", nil, Window)
	Window.LeftWidgetsBG:SetWidth(GROUP_WIDTH + (SPACING * 2))
	Window.LeftWidgetsBG:SetPoint("TOPLEFT", Window, 16, 0)
	Window.LeftWidgetsBG:SetPoint("BOTTOMLEFT", Window, 16, 0)
	
	Window.LeftWidgetsBG.Backdrop = CreateFrame("Frame", nil, Window, "BackdropTemplate")
	Window.LeftWidgetsBG.Backdrop:SetWidth(GROUP_WIDTH + (SPACING * 2))
	Window.LeftWidgetsBG.Backdrop:SetPoint("TOPLEFT", Window.LeftWidgetsBG, 0, 0)
	Window.LeftWidgetsBG.Backdrop:SetPoint("BOTTOMLEFT", Window.LeftWidgetsBG, 0, 0)
	Window.LeftWidgetsBG.Backdrop:SetBackdrop(vUI.BackdropAndBorder)
	Window.LeftWidgetsBG.Backdrop:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-main-color"]))
	Window.LeftWidgetsBG.Backdrop:SetBackdropBorderColor(0, 0, 0)
	
	Window.RightWidgetsBG = CreateFrame("Frame", nil, Window)
	Window.RightWidgetsBG:SetWidth(GROUP_WIDTH + (SPACING * 2))
	Window.RightWidgetsBG:SetPoint("TOPLEFT", Window.LeftWidgetsBG, "TOPRIGHT", 2, 0)
	Window.RightWidgetsBG:SetPoint("BOTTOMLEFT", Window.LeftWidgetsBG, "BOTTOMRIGHT", 2, 0)
	
	Window.RightWidgetsBG.Backdrop = CreateFrame("Frame", nil, Window, "BackdropTemplate")
	Window.RightWidgetsBG.Backdrop:SetWidth(GROUP_WIDTH + (SPACING * 2))
	Window.RightWidgetsBG.Backdrop:SetPoint("TOPLEFT", Window.RightWidgetsBG, 0, 0)
	Window.RightWidgetsBG.Backdrop:SetPoint("BOTTOMLEFT", Window.RightWidgetsBG, 0, 0)
	Window.RightWidgetsBG.Backdrop:SetBackdrop(vUI.BackdropAndBorder)
	Window.RightWidgetsBG.Backdrop:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-main-color"]))
	Window.RightWidgetsBG.Backdrop:SetBackdropBorderColor(0, 0, 0)
	
	Window.Parent = self
	Window.Button = Button
	Window.SortWindow = SortWindow
	Window.LeftWidgets = {}
	Window.RightWidgets = {}
	
	Window.LeftWidgetsBG.Widgets = Window.LeftWidgets
	Window.LeftWidgetsBG.DisableScrolling = DisableScrolling
	Window.RightWidgetsBG.Widgets = Window.RightWidgets
	Window.RightWidgetsBG.DisableScrolling = DisableScrolling
	
	for Name, Function in pairs(self.Widgets) do
		Window.LeftWidgetsBG[Name] = Function
		Window.RightWidgetsBG[Name] = Function
	end
	
	if (parent and self.OnLoadCalls[category][parent].Children) then
		for i = 1, #self.OnLoadCalls[category][parent].Children[name].Calls do
			self.OnLoadCalls[category][parent].Children[name].Calls[1](Window.LeftWidgetsBG, Window.RightWidgetsBG)
			
			tremove(self.OnLoadCalls[category][parent].Children[name].Calls, 1)
		end
	else
		for i = 1, #self.OnLoadCalls[category][name].Calls do
			self.OnLoadCalls[category][name].Calls[1](Window.LeftWidgetsBG, Window.RightWidgetsBG)
			
			tremove(self.OnLoadCalls[category][name].Calls, 1)
		end
	end
	
	if (#Window.LeftWidgetsBG.Widgets > 0) then
		Window.LeftWidgetsBG:CreateFooter()
	end
	
	if (#Window.RightWidgetsBG.Widgets > 0) then
		Window.RightWidgetsBG:CreateFooter()
	end
	
	Window:SortWindow()
	
	return Window
end

function GUI2:ShowWindow(category, name, parent)
	-- add hooks here?
	for i = 1, #self.Categories do
		for j = 1, #self.Categories[i].Buttons do
			if parent then
				if (self.Categories[i].Buttons[j].Name == parent and self.Categories[i].Buttons[j].Children) then
					for o = 1, #self.Categories[i].Buttons[j].Children do
						if (self.Categories[i].Buttons[j].Children[o].Name == name) then
							if (not self.Categories[i].Buttons[j].Children[o].Window) then
								local Window = self:CreateWidgetWindow(category, name, parent)
								
								self.Categories[i].Buttons[j].Children[o].Window = Window
							end
							
							self.Categories[i].Buttons[j].Window:Hide()
							
							self.Categories[i].Buttons[j].Children[o].FadeIn:Play()
							self.Categories[i].Buttons[j].Children[o].Window:Show()
						elseif self.Categories[i].Buttons[j].Children[o].Window then
							self.Categories[i].Buttons[j].Children[o].Window:Hide()
							
							if (self.Categories[i].Buttons[j].Children[o].Selected:GetAlpha() > 0) then
								self.Categories[i].Buttons[j].Children[o].FadeOut:Play()
							end
						end
					end
				elseif self.Categories[i].Buttons[j].Window then
					self.Categories[i].Buttons[j].Window:Hide()
				end
			elseif (self.Categories[i].Name == category) and (self.Categories[i].Buttons[j].Name == name) then
				if (not self.Categories[i].Buttons[j].Window) then
					local Window = self:CreateWidgetWindow(category, name, parent)
					
					self.Categories[i].Buttons[j].Window = Window
				end
				
				self.Categories[i].Buttons[j].FadeIn:Play()
				self.Categories[i].Buttons[j].Window:Show()
				
				if self.Categories[i].Buttons[j].Children then
					for o = 1, #self.Categories[i].Buttons[j].Children do
						if self.Categories[i].Buttons[j].Children[o].Window then
							self.Categories[i].Buttons[j].Children[o].Window:Hide()
						end
						
						self.Categories[i].Buttons[j].Children[o]:Hide()
					end
					
					self.Categories[i].Buttons[j].ChildrenShown = true
				end
			else
				if self.Categories[i].Buttons[j].Window then
					self.Categories[i].Buttons[j].Window:Hide()
					
					if (self.Categories[i].Buttons[j].Selected:GetAlpha() > 0) then
						self.Categories[i].Buttons[j].FadeOut:Play()
					end
					
					if self.Categories[i].Buttons[j].Children then
						for o = 1, #self.Categories[i].Buttons[j].Children do
							if self.Categories[i].Buttons[j].Children[o].Window then
								self.Categories[i].Buttons[j].Children[o].Window:Hide()
							end
							
							self.Categories[i].Buttons[j].Children[o]:Hide()
						end
						
						self.Categories[i].Buttons[j].ChildrenShown = false
					end
				end
			end
		end
	end
	
	self:ScrollSelections()
	
	--CloseLastDropdown()
end

local WindowButtonOnEnter = function(self)
	self.Highlight:SetAlpha(MOUSEOVER_HIGHLIGHT_ALPHA)
end

local WindowButtonOnLeave = function(self)
	self.Highlight:SetAlpha(0)
end

local WindowButtonOnMouseUp = function(self)
	if self.Texture then
		self.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-button-texture-color"]))
	end
	
	GUI2:ShowWindow(self.Category, self.Name, self.Parent)
end

local WindowButtonOnMouseDown = function(self)
	if (not self.Texture) then
		return
	end

	local R, G, B = vUI:HexToRGB(Settings["ui-button-texture-color"])
	
	self.Texture:SetVertexColor(R * 0.85, G * 0.85, B * 0.85)
end

function GUI2:CreateWindow(category, name, parent)
	if (not self.CategoryNames[category]) then
		self:CreateCategory(category)
	end
	
	local Category = self.CategoryNames[category]
	
	local Button = CreateFrame("Frame", nil, self, "BackdropTemplate")
	Button:SetSize(MENU_BUTTON_WIDTH, MENU_BUTTON_HEIGHT, "BackdropTemplate")
	Button:SetFrameLevel(self:GetFrameLevel() + 2)
	Button.Name = name
	Button.Category = category
	Button:SetScript("OnEnter", WindowButtonOnEnter)
	Button:SetScript("OnLeave", WindowButtonOnLeave)
	Button:SetScript("OnMouseUp", WindowButtonOnMouseUp)
	Button:SetScript("OnMouseDown", WindowButtonOnMouseDown)
	
	Button.Selected = Button:CreateTexture(nil, "OVERLAY")
	Button.Selected:SetPoint("TOPLEFT", Button, 1, -1)
	Button.Selected:SetPoint("BOTTOMRIGHT", Button, -1, 1)
	Button.Selected:SetVertexColor(vUI:HexToRGB(Settings["ui-widget-color"]))
	Button.Selected:SetAlpha(0)
	
	Button.Highlight = Button:CreateTexture(nil, "OVERLAY")
	Button.Highlight:SetPoint("TOPLEFT", Button, 1, -1)
	Button.Highlight:SetPoint("BOTTOMRIGHT", Button, -1, 1)
	Button.Highlight:SetTexture(Assets:GetTexture("Blank"))
	Button.Highlight:SetVertexColor(1, 1, 1, 0.4)
	Button.Highlight:SetAlpha(0)
	
	Button.Text = Button:CreateFontString(nil, "OVERLAY")
	Button.Text:SetSize(MENU_BUTTON_WIDTH - 6, MENU_BUTTON_HEIGHT)
	
	Button.Fade = CreateAnimationGroup(Button.Selected)
	
	Button.FadeIn = Button.Fade:CreateAnimation("Fade")
	Button.FadeIn:SetEasing("in")
	Button.FadeIn:SetDuration(0.15)
	Button.FadeIn:SetChange(SELECTED_HIGHLIGHT_ALPHA)
	
	Button.FadeOut = Button.Fade:CreateAnimation("Fade")
	Button.FadeOut:SetEasing("out")
	Button.FadeOut:SetDuration(0.15)
	Button.FadeOut:SetChange(0)
	
	if parent then
		Button.Parent = parent
		
		Button.Text:SetPoint("LEFT", Button, LABEL_SPACING*3, -1)
		Button.Text:SetJustifyH("LEFT")
		vUI:SetFontInfo(Button.Text, Settings["ui-widget-font"], 12)
		Button.Text:SetText("|cFF" .. Settings["ui-widget-font-color"] .. name .. "|r")
		
		Button.Selected:SetTexture(Assets:GetTexture("Blank"))
		
		for j = 1, #Category.Buttons do
			if (Category.Buttons[j].Name == parent) then
				if (not Category.Buttons[j].Children) then
					Category.Buttons[j].Children = {}
				end
				
				tinsert(Category.Buttons[j].Children, Button)
				
				break
			end
		end
	else
		Button:SetBackdrop(vUI.BackdropAndBorder)
		Button:SetBackdropColor(0, 0, 0)
		Button:SetBackdropBorderColor(0, 0, 0)
		
		Button.Texture = Button:CreateTexture(nil, "ARTWORK")
		Button.Texture:SetPoint("TOPLEFT", Button, 1, -1)
		Button.Texture:SetPoint("BOTTOMRIGHT", Button, -1, 1)
		Button.Texture:SetTexture(Assets:GetTexture(Settings["ui-button-texture"]))
		Button.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-button-texture-color"]))
		
		Button.Selected:SetTexture(Assets:GetTexture("RenHorizonUp"))
		
		Button.Text:SetPoint("CENTER", Button, 0, -1)
		Button.Text:SetJustifyH("CENTER")
		vUI:SetFontInfo(Button.Text, Settings["ui-widget-font"], Settings["ui-header-font-size"])
		Button.Text:SetText("|cFF" .. Settings["ui-button-font-color"] .. name .. "|r")
		
		tinsert(Category.Buttons, Button)
		
		self.TotalSelections = (self.TotalSelections or 0) + 1
	end
end

function GUI2:AddSettings(category, name, arg1, arg2)
	if (not self.OnLoadCalls[category]) then
		self.OnLoadCalls[category] = {}
	end
	
	if (not self.OnLoadCalls[category][name]) then
		self.OnLoadCalls[category][name] = {Calls = {}}
	end
	
	if (type(arg1) == "function") then
		tinsert(self.OnLoadCalls[category][name].Calls, arg1)
		
		self:CreateWindow(category, name)
	elseif (type(arg1) == "string") then
		if (not self.OnLoadCalls[category][arg1].Children) then
			self.OnLoadCalls[category][arg1].Children = {}
		end
		
		self.OnLoadCalls[category][arg1].Children[name] = {Calls = {}}
		
		tinsert(self.OnLoadCalls[category][arg1].Children[name].Calls, arg2)
		
		self:CreateWindow(category, name, arg1)
	end
end

GUI2.SortScrollButtons = {}

function GUI2:ScrollSelections()
	local Count = 0
	
	-- Collect buttons
	for i = 1, #self.SortScrollButtons do
		tremove(self.SortScrollButtons, 1)
	end
	
	for i = 1, #self.Categories do
		Count = Count + 1
		
		if (Count >= self.Offset) and (Count <= self.Offset + MAX_WIDGETS_SHOWN - 1) then
			tinsert(self.SortScrollButtons, self.Categories[i])
		end
		
		self.Categories[i]:Hide()
		
		for j = 1, #self.Categories[i].Buttons do
			Count = Count + 1
				
			if (Count >= self.Offset) and (Count <= self.Offset + MAX_WIDGETS_SHOWN - 1) then
				tinsert(self.SortScrollButtons, self.Categories[i].Buttons[j])
			end
		
			if self.Categories[i].Buttons[j].ChildrenShown then
				for o = 1, #self.Categories[i].Buttons[j].Children do
					Count = Count + 1
				
					if (Count >= self.Offset) and (Count <= self.Offset + MAX_WIDGETS_SHOWN - 1) then
						tinsert(self.SortScrollButtons, self.Categories[i].Buttons[j].Children[o])
						self.Categories[i].Buttons[j].Children[o]:Show()
					else
						self.Categories[i].Buttons[j].Children[o]:Hide()
					end
				end
			end
			
			self.Categories[i].Buttons[j]:Hide()
		end
	end
	
	self.TotalSelections = Count
	
	self.ScrollBar:SetMinMaxValues(1, (Count - MAX_WIDGETS_SHOWN) + 1)
	
	for i = 1, #self.SortScrollButtons do
		if self.SortScrollButtons[i] then
			self.SortScrollButtons[i]:ClearAllPoints()
			
			if (i == 1) then
				self.SortScrollButtons[i]:SetPoint("TOPLEFT", self.SelectionParent, SPACING, -SPACING)
			else
				self.SortScrollButtons[i]:SetPoint("TOP", self.SortScrollButtons[i-1], "BOTTOM", 0, -2)
			end
			
			self.SortScrollButtons[i]:Show()
		end
	end
end

function GUI2:SetSelectionOffset(offset)
	self.Offset = offset
	
	if (self.Offset <= 1) then
		self.Offset = 1
	elseif (self.Offset > (self.TotalSelections - MAX_WIDGETS_SHOWN - 1)) then
		self.Offset = self.Offset - 1
	end
	
	self:ScrollSelections()
end

local SetSelectionOffsetByDelta = function(self, delta)
	if (delta == 1) then -- Up
		self.Offset = self.Offset - 1
		
		if (self.Offset <= 1) then
			self.Offset = 1
		end
	else -- Down
		self.Offset = self.Offset + 1
		
		if (self.Offset > (self.TotalSelections - (MAX_WIDGETS_SHOWN - 1))) then
			self.Offset = self.Offset - 1
		end
	end
end

local SelectionOnMouseWheel = function(self, delta)
	self:SetSelectionOffsetByDelta(delta)
	self:ScrollSelections()
	self.ScrollBar:SetValue(self.Offset)
end

local Round = function(num, dec)
	local Mult = 10 ^ (dec or 0)
	
	return floor(num * Mult + 0.5) / Mult
end

local SelectionScrollBarOnValueChanged = function(self)
	GUI2.Offset = Round(self:GetValue())
	
	GUI2:ScrollSelections()
end

local SelectionParentOnMouseWheel = function(self, delta)
	SelectionOnMouseWheel(self:GetParent(), delta)
end

local SelectionScrollBarOnMouseWheel = function(self, delta)
	SelectionOnMouseWheel(self:GetParent():GetParent(), delta)
end

local FadeOnFinished = function(self)
	self.Parent:Hide()
end

function GUI2:CreateGUI()
	-- This just makes the animation look better. That's all. ಠ_ಠ
	self.BlackTexture = self:CreateTexture(nil, "BACKGROUND")
	self.BlackTexture:SetPoint("TOPLEFT", self, 0, 0)
	self.BlackTexture:SetPoint("BOTTOMRIGHT", self, 0, 0)
	self.BlackTexture:SetTexture(Assets:GetTexture("Blank"))
	self.BlackTexture:SetVertexColor(0, 0, 0)
	
	self:SetFrameStrata("HIGH")
	self:SetSize(GUI_WIDTH, GUI_HEIGHT)
	self:SetPoint("CENTER", vUI.UIParent, 0, 0)
	self:SetBackdrop(vUI.BackdropAndBorder)
	self:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	self:SetBackdropBorderColor(0, 0, 0)
	self:EnableMouse(true)
	self:SetMovable(true)
	self:RegisterForDrag("LeftButton")
	self:SetScript("OnDragStart", self.StartMoving)
	self:SetScript("OnDragStop", self.StopMovingOrSizing)
	self:SetClampedToScreen(true)
	self:SetScale(0.2)
	self:Hide()
	
	self.Group = CreateAnimationGroup(self)
	
	self.ScaleIn = self.Group:CreateAnimation("Scale")
	self.ScaleIn:SetEasing("in")
	self.ScaleIn:SetDuration(0.15)
	self.ScaleIn:SetChange(1)
	
	self.FadeIn = self.Group:CreateAnimation("Fade")
	self.FadeIn:SetEasing("in")
	self.FadeIn:SetDuration(0.15)
	self.FadeIn:SetChange(1)
	
	self.ScaleOut = self.Group:CreateAnimation("Scale")
	self.ScaleOut:SetEasing("out")
	self.ScaleOut:SetDuration(0.15)
	self.ScaleOut:SetChange(0.2)
	
	self.FadeOut = self.Group:CreateAnimation("Fade")
	self.FadeOut:SetEasing("out")
	self.FadeOut:SetDuration(0.15)
	self.FadeOut:SetChange(0)
	self.FadeOut:SetScript("OnFinished", FadeOnFinished)
	
	self.Fader = self.Group:CreateAnimation("Fade")
	self.Fader:SetDuration(0.15)
	
	-- Header
	self.Header = CreateFrame("Frame", nil, self, "BackdropTemplate")
	self.Header:SetSize(HEADER_WIDTH - (HEADER_HEIGHT - 2) - SPACING - 1, HEADER_HEIGHT)
	self.Header:SetPoint("TOPLEFT", self, SPACING, -SPACING)
	self.Header:SetBackdrop(vUI.BackdropAndBorder)
	self.Header:SetBackdropColor(0, 0, 0, 0)
	self.Header:SetBackdropBorderColor(0, 0, 0)
	
	self.Header.Texture = self.Header:CreateTexture(nil, "ARTWORK")
	self.Header.Texture:SetPoint("TOPLEFT", self.Header, 1, -1)
	self.Header.Texture:SetPoint("BOTTOMRIGHT", self.Header, -1, 1)
	self.Header.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	self.Header.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	self.Header.Text = self.Header:CreateFontString(nil, "OVERLAY")
	self.Header.Text:SetPoint("CENTER", self.Header, 0, -1)
	self.Header.Text:SetSize(HEADER_WIDTH - 6, HEADER_HEIGHT)
	vUI:SetFontInfo(self.Header.Text, Settings["ui-header-font"], Settings["ui-title-font-size"])
	self.Header.Text:SetJustifyH("CENTER")
	self.Header.Text:SetTextColor(vUI:HexToRGB(Settings["ui-header-font-color"]))
	self.Header.Text:SetText(format(Language["- vUI version %s -"], vUI.UIVersion))
	
	-- Selection parent
	self.SelectionParent = CreateFrame("Frame", nil, self, "BackdropTemplate")
	self.SelectionParent:SetWidth(BUTTON_LIST_WIDTH + 16)
	self.SelectionParent:SetPoint("BOTTOMLEFT", self, SPACING, SPACING)
	self.SelectionParent:SetPoint("TOPLEFT", self.Header, "BOTTOMLEFT", 0, -2)
	self.SelectionParent:SetBackdrop(vUI.BackdropAndBorder)
	self.SelectionParent:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-main-color"]))
	self.SelectionParent:SetBackdropBorderColor(0, 0, 0)
	self.SelectionParent:SetScript("OnMouseWheel", SelectionParentOnMouseWheel)
	
	-- Selection scrollbar
	local ScrollBar = CreateFrame("Slider", nil, self.SelectionParent, "BackdropTemplate")
	ScrollBar:SetWidth(14)
	ScrollBar:SetPoint("TOPRIGHT", self.SelectionParent, -3, -3)
	ScrollBar:SetPoint("BOTTOMRIGHT", self.SelectionParent, -3, 3)
	ScrollBar:SetThumbTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	ScrollBar:SetOrientation("VERTICAL")
	ScrollBar:SetValueStep(1)
	ScrollBar:SetBackdrop(vUI.BackdropAndBorder)
	ScrollBar:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-main-color"]))
	ScrollBar:SetBackdropBorderColor(0, 0, 0)
	ScrollBar:EnableMouseWheel(true)
	ScrollBar:SetScript("OnMouseWheel", SelectionScrollBarOnMouseWheel)
	ScrollBar:SetScript("OnValueChanged", SelectionScrollBarOnValueChanged)
	
	--self.ScrollSelections = ScrollSelections
	--self.SetSelectionOffset = SetSelectionOffset
	self.SetSelectionOffsetByDelta = SetSelectionOffsetByDelta
	self.ScrollBar = ScrollBar
	
	local Thumb = ScrollBar:GetThumbTexture() 
	Thumb:SetSize(ScrollBar:GetWidth(), WIDGET_HEIGHT)
	Thumb:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Thumb:SetVertexColor(0, 0, 0)
	
	ScrollBar.NewTexture = ScrollBar:CreateTexture(nil, "BORDER")
	ScrollBar.NewTexture:SetPoint("TOPLEFT", Thumb, 0, 0)
	ScrollBar.NewTexture:SetPoint("BOTTOMRIGHT", Thumb, 0, 0)
	ScrollBar.NewTexture:SetTexture(Assets:GetTexture("Blank"))
	ScrollBar.NewTexture:SetVertexColor(0, 0, 0)
	
	ScrollBar.NewTexture2 = ScrollBar:CreateTexture(nil, "OVERLAY")
	ScrollBar.NewTexture2:SetPoint("TOPLEFT", ScrollBar.NewTexture, 1, -1)
	ScrollBar.NewTexture2:SetPoint("BOTTOMRIGHT", ScrollBar.NewTexture, -1, 1)
	ScrollBar.NewTexture2:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	ScrollBar.NewTexture2:SetVertexColor(vUI:HexToRGB(Settings["ui-widget-bright-color"]))
	
	ScrollBar.Progress = ScrollBar:CreateTexture(nil, "ARTWORK")
	ScrollBar.Progress:SetPoint("TOPLEFT", ScrollBar, 1, -1)
	ScrollBar.Progress:SetPoint("BOTTOMRIGHT", ScrollBar.NewTexture, "TOPRIGHT", -1, 0)
	ScrollBar.Progress:SetTexture(Assets:GetTexture("Blank"))
	ScrollBar.Progress:SetVertexColor(vUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	-- Close button
	self.CloseButton = CreateFrame("Frame", nil, self, "BackdropTemplate")
	self.CloseButton:SetSize(HEADER_HEIGHT, HEADER_HEIGHT)
	self.CloseButton:SetPoint("TOPRIGHT", self, -SPACING, -SPACING)
	self.CloseButton:SetBackdrop(vUI.BackdropAndBorder)
	self.CloseButton:SetBackdropColor(0, 0, 0, 0)
	self.CloseButton:SetBackdropBorderColor(0, 0, 0)
	self.CloseButton:SetScript("OnEnter", function(self) self.Cross:SetVertexColor(vUI:HexToRGB("C0392B")) end)
	self.CloseButton:SetScript("OnLeave", function(self) self.Cross:SetVertexColor(vUI:HexToRGB("EEEEEE")) end)
	self.CloseButton:SetScript("OnMouseUp", function(self)
		self.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-header-texture-color"]))
		
		GUI2.ScaleOut:Play()
		GUI2.FadeOut:Play()
		
		if (GUI2.ColorPicker and GUI2.ColorPicker:GetAlpha() > 0) then
			GUI2.ColorPicker.FadeOut:Play()
		end
	end)
	
	self.CloseButton:SetScript("OnMouseDown", function(self)
		local R, G, B = vUI:HexToRGB(Settings["ui-header-texture-color"])
		
		self.Texture:SetVertexColor(R * 0.85, G * 0.85, B * 0.85)
	end)
	
	self.CloseButton.Texture = self.CloseButton:CreateTexture(nil, "ARTWORK")
	self.CloseButton.Texture:SetPoint("TOPLEFT", self.CloseButton, 1, -1)
	self.CloseButton.Texture:SetPoint("BOTTOMRIGHT", self.CloseButton, -1, 1)
	self.CloseButton.Texture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	self.CloseButton.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-header-texture-color"]))
	
	self.CloseButton.Cross = self.CloseButton:CreateTexture(nil, "OVERLAY")
	self.CloseButton.Cross:SetPoint("CENTER", self.CloseButton, 0, 0)
	self.CloseButton.Cross:SetSize(16, 16)
	self.CloseButton.Cross:SetTexture(Assets:GetTexture("Close"))
	self.CloseButton.Cross:SetVertexColor(vUI:HexToRGB("EEEEEE"))
	
	self:SortButtons()
	
	self.ScrollBar:SetMinMaxValues(1, ((self.NumShownButtons or 15) - MAX_WIDGETS_SHOWN) + 1)
	self.ScrollBar:SetValue(1)
	self:SetSelectionOffset(1)
	self.ScrollBar:Show()
	
	self:ShowWindow("General", "General")
	
	self.Loaded = true
end

function GUI2:Toggle()
	if self.Loaded then
		if self:IsVisible() then
			self.ScaleOut:Play()
			self.FadeOut:Play()
		else
			self:SetAlpha(0)
			self:Show()
			self.ScaleIn:Play()
			self.FadeIn:Play()
		end
	else
		self:CreateGUI()
		
		self:SetAlpha(0)
		self:Show()
		self.ScaleIn:Play()
		self.FadeIn:Play()
	end
end

GUI2_Toggle = function() -- temp global access, remove me -- /run GUI2_Toggle()
	GUI2:Toggle()
end