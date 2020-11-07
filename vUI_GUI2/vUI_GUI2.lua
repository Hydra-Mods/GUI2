if (not vUIGlobal) then
	return
end

local vUI, GUI, Language, Assets, Settings, Defaults = vUIGlobal:get()
local GUI2 = vUI:NewPlugin("vUI_GUI2")

--[[
	Goals:
	Load on demand, page by page
	Support sub pages
	Support categories
	
	-- General
		Action Bars
			Bar 1
			Bar 2
			Bar 3
		Auras
		Bags
		General
		...
		UnitFrames
			Player
			Target
			Pet
	-- Info
		Credit
		Debug
		Plugins
	
--]]

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
local tonumber = tonumber
local tinsert = table.insert
local tremove = table.remove
local tsort = table.sort
local match = string.match
local upper = string.upper
local lower = string.lower
local sub = string.sub
local gsub = string.gsub
local find = string.find
local floor = math.floor
local InCombatLockdown = InCombatLockdown
local IsModifierKeyDown = IsModifierKeyDown
local GetMouseFocus = GetMouseFocus

GUI2.WindowHooks = {onshow = {}, onhide = {}}

-- New concept
GUI2.Categories = {}
GUI2.CategoryNames = {}
GUI2.Widgets = {}

local TrimHex = function(s)
	local Subbed = match(s, "|c%x%x%x%x%x%x%x%x(.-)|r")
	
	return Subbed or s
end

-- Line
GUI2.Widgets.CreateLine = function(self, text)
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetSize(GROUP_WIDTH, WIDGET_HEIGHT)
	--Anchor.ID = CreateID(text)
	
	Anchor.Text = Anchor:CreateFontString(nil, "OVERLAY")
	Anchor.Text:SetPoint("LEFT", Anchor, HEADER_SPACING, 0)
	Anchor.Text:SetSize(GROUP_WIDTH - 6, WIDGET_HEIGHT)
	vUI:SetFontInfo(Anchor.Text, Settings["ui-widget-font"], Settings["ui-font-size"])
	Anchor.Text:SetJustifyH("LEFT")
	Anchor.Text:SetText(format("|cFF%s%s|r", Settings["ui-widget-font-color"], text))
	
	tinsert(self.Widgets, Anchor)
	
	return Anchor.Text
end

-- Double Line
GUI2.Widgets.CreateDoubleLine = function(self, left, right)
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetSize(GROUP_WIDTH, WIDGET_HEIGHT)
	--Anchor.ID = CreateID(left)
	
	left = tostring(left)
	right = tostring(right)
	
	Anchor.Left = Anchor:CreateFontString(nil, "OVERLAY")
	Anchor.Left:SetPoint("LEFT", Anchor, HEADER_SPACING, 0)
	Anchor.Left:SetSize((GROUP_WIDTH / 2) - 6, WIDGET_HEIGHT)
	vUI:SetFontInfo(Anchor.Left, Settings["ui-widget-font"], Settings["ui-font-size"])
	Anchor.Left:SetJustifyH("LEFT")
	Anchor.Left:SetText(format("|cFF%s%s|r", Settings["ui-widget-font-color"], left))
	
	Anchor.Right = Anchor:CreateFontString(nil, "OVERLAY")
	Anchor.Right:SetPoint("RIGHT", Anchor, -HEADER_SPACING, 0)
	Anchor.Right:SetSize((GROUP_WIDTH / 2) - 6, WIDGET_HEIGHT)
	vUI:SetFontInfo(Anchor.Right, Settings["ui-widget-font"], Settings["ui-font-size"])
	Anchor.Right:SetJustifyH("RIGHT")
	Anchor.Right:SetText(format("|cFF%s%s|r", Settings["ui-widget-font-color"], right))
	
	tinsert(self.Widgets, Anchor)
	
	return Anchor.Left
end

-- Message
local CheckString = vUI.UIParent:CreateFontString(nil, "OVERLAY")
CheckString:SetWidth(GROUP_WIDTH - 6)
CheckString:SetJustifyH("LEFT")

GUI2.Widgets.CreateMessage = function(self, text) -- Create as many lines as needed for the message
	vUI:SetFontInfo(CheckString, Settings["ui-widget-font"], Settings["ui-font-size"])
	CheckString:SetText(text)
	
	local Line = ""
	local NewLine = ""
	local Indent = 0
	
	for word in string.gmatch(text, "(%S+)") do
		NewLine = Line .. (Indent == 0 and "" or " ") .. word
		
		CheckString:SetText(NewLine)
		
		if (CheckString:GetStringWidth() >= (GROUP_WIDTH - 6)) then
			if find(Line, "(%S+)$") then -- A word needs to be wrapped
				self:CreateLine(Line)
				Line = word -- Start a new line with the wrapped word
				Indent = 1
			else
				self:CreateLine(NewLine)
				Line = "" -- Start a new line
				Indent = 0
			end
		else
			Line = NewLine
			Indent = 1
		end
	end
	
	self:CreateLine(Line)
end

-- Header
GUI2.Widgets.CreateHeader = function(self, text)
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetSize(GROUP_WIDTH, WIDGET_HEIGHT)
	Anchor.IsHeader = true
	
	Anchor.Text = Anchor:CreateFontString(nil, "OVERLAY")
	Anchor.Text:SetPoint("CENTER", Anchor, 0, 0)
	Anchor.Text:SetHeight(WIDGET_HEIGHT)
	vUI:SetFontInfo(Anchor.Text, Settings["ui-header-font"], Settings["ui-font-size"]) -- 14
	Anchor.Text:SetJustifyH("CENTER")
	Anchor.Text:SetText("|cFF"..Settings["ui-header-font-color"]..text.."|r")
	
	-- Header Left Line
	local HeaderLeft = CreateFrame("Frame", nil, Anchor, "BackdropTemplate")
	HeaderLeft:SetHeight(4)
	HeaderLeft:SetPoint("LEFT", Anchor, 0, 0)
	HeaderLeft:SetPoint("RIGHT", Anchor.Text, "LEFT", -SPACING, 0)
	HeaderLeft:SetBackdrop(vUI.BackdropAndBorder)
	HeaderLeft:SetBackdropColor(0, 0, 0)
	HeaderLeft:SetBackdropBorderColor(0, 0, 0)
	
	HeaderLeft.NewTexture = HeaderLeft:CreateTexture(nil, "OVERLAY")
	HeaderLeft.NewTexture:SetPoint("TOPLEFT", HeaderLeft, 1, -1)
	HeaderLeft.NewTexture:SetPoint("BOTTOMRIGHT", HeaderLeft, -1, 1)
	HeaderLeft.NewTexture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	HeaderLeft.NewTexture:SetVertexColor(vUI:HexToRGB(Settings["ui-button-texture-color"]))
	
	-- Header Right Line
	local HeaderRight = CreateFrame("Frame", nil, Anchor, "BackdropTemplate")
	HeaderRight:SetHeight(4)
	HeaderRight:SetPoint("RIGHT", Anchor, 0, 0)
	HeaderRight:SetPoint("LEFT", Anchor.Text, "RIGHT", SPACING, 0)
	HeaderRight:SetBackdrop(vUI.BackdropAndBorder)
	HeaderRight:SetBackdropColor(0, 0, 0)
	HeaderRight:SetBackdropBorderColor(0, 0, 0)
	
	HeaderRight.NewTexture = HeaderRight:CreateTexture(nil, "OVERLAY")
	HeaderRight.NewTexture:SetPoint("TOPLEFT", HeaderRight, 1, -1)
	HeaderRight.NewTexture:SetPoint("BOTTOMRIGHT", HeaderRight, -1, 1)
	HeaderRight.NewTexture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	HeaderRight.NewTexture:SetVertexColor(vUI:HexToRGB(Settings["ui-button-texture-color"]))
	
	tinsert(self.Widgets, Anchor)
	
	return Anchor.Text
end

-- Footer
GUI2.Widgets.CreateFooter = function(self)
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetSize(GROUP_WIDTH, WIDGET_HEIGHT)
	Anchor.IsHeader = true
	
	-- Header Left Line
	local Line = CreateFrame("Frame", nil, Anchor, "BackdropTemplate")
	Line:SetHeight(4)
	Line:SetPoint("LEFT", Anchor, 0, 0)
	Line:SetPoint("RIGHT", Anchor, 0, 0)
	Line:SetBackdrop(vUI.BackdropAndBorder)
	Line:SetBackdropColor(vUI:HexToRGB(Settings["ui-button-texture-color"]))
	Line:SetBackdropBorderColor(0, 0, 0)
	
	Line.NewTexture = Line:CreateTexture(nil, "OVERLAY")
	Line.NewTexture:SetPoint("TOPLEFT", Line, 1, -1)
	Line.NewTexture:SetPoint("BOTTOMRIGHT", Line, -1, 1)
	Line.NewTexture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	Line.NewTexture:SetVertexColor(vUI:HexToRGB(Settings["ui-button-texture-color"]))
	
	tinsert(self.Widgets, Anchor)
	
	return Header
end

-- Header
GUI2.Widgets.CreateSupportHeader = function(self, text)
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetSize(GROUP_WIDTH, WIDGET_HEIGHT)
	Anchor.IsHeader = true
	
	Anchor.Text = Anchor:CreateFontString(nil, "OVERLAY")
	Anchor.Text:SetPoint("CENTER", Anchor, 0, 0)
	Anchor.Text:SetHeight(WIDGET_HEIGHT)
	vUI:SetFontInfo(Anchor.Text, Settings["ui-header-font"], Settings["ui-font-size"]) -- 14
	Anchor.Text:SetJustifyH("CENTER")
	Anchor.Text:SetText("|cFF"..Settings["ui-header-font-color"]..text.."|r")
	
	-- Header Left Line
	local HeaderLeft = CreateFrame("Frame", nil, Anchor, "BackdropTemplate")
	HeaderLeft:SetHeight(4)
	HeaderLeft:SetPoint("LEFT", Anchor, 0, 0)
	HeaderLeft:SetPoint("RIGHT", Anchor.Text, "LEFT", -20, 0)
	HeaderLeft:SetBackdrop(vUI.BackdropAndBorder)
	HeaderLeft:SetBackdropColor(0, 0, 0)
	HeaderLeft:SetBackdropBorderColor(0, 0, 0)
	
	HeaderLeft.NewTexture = HeaderLeft:CreateTexture(nil, "OVERLAY")
	HeaderLeft.NewTexture:SetPoint("TOPLEFT", HeaderLeft, 1, -1)
	HeaderLeft.NewTexture:SetPoint("BOTTOMRIGHT", HeaderLeft, -1, 1)
	HeaderLeft.NewTexture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	HeaderLeft.NewTexture:SetVertexColor(vUI:HexToRGB(Settings["ui-button-texture-color"]))
	
	HeaderLeft.Star = HeaderLeft:CreateTexture(nil, "OVERLAY")
	HeaderLeft.Star:SetPoint("LEFT", HeaderLeft.NewTexture, "RIGHT", 1, -1)
	HeaderLeft.Star:SetSize(16, 16)
	HeaderLeft.Star:SetTexture(Assets:GetTexture("Small Star"))
	HeaderLeft.Star:SetVertexColor(vUI:HexToRGB("FFB900"))
	
	-- Header Right Line
	local HeaderRight = CreateFrame("Frame", nil, Anchor, "BackdropTemplate")
	HeaderRight:SetHeight(4)
	HeaderRight:SetPoint("RIGHT", Anchor, 0, 0)
	HeaderRight:SetPoint("LEFT", Anchor.Text, "RIGHT", 16, 0)
	HeaderRight:SetBackdrop(vUI.BackdropAndBorder)
	HeaderRight:SetBackdropColor(0, 0, 0)
	HeaderRight:SetBackdropBorderColor(0, 0, 0)
	
	HeaderRight.NewTexture = HeaderRight:CreateTexture(nil, "OVERLAY")
	HeaderRight.NewTexture:SetPoint("TOPLEFT", HeaderRight, 1, -1)
	HeaderRight.NewTexture:SetPoint("BOTTOMRIGHT", HeaderRight, -1, 1)
	HeaderRight.NewTexture:SetTexture(Assets:GetTexture(Settings["ui-header-texture"]))
	HeaderRight.NewTexture:SetVertexColor(vUI:HexToRGB(Settings["ui-button-texture-color"]))
	
	HeaderRight.Star = HeaderRight:CreateTexture(nil, "OVERLAY")
	HeaderRight.Star:SetPoint("RIGHT", HeaderRight.NewTexture, "LEFT", -1, -1)
	HeaderRight.Star:SetSize(16, 16)
	HeaderRight.Star:SetTexture(Assets:GetTexture("Small Star"))
	HeaderRight.Star:SetVertexColor(vUI:HexToRGB("FFB900"))
	
	tinsert(self.Widgets, Anchor)
	
	return Anchor.Text
end

-- Switch
local SWITCH_WIDTH = 50
local SWITCH_TRAVEL = SWITCH_WIDTH - WIDGET_HEIGHT

local SwitchOnMouseUp = function(self)
	if self.Move:IsPlaying() then
		return
	end
	
	self.Thumb:ClearAllPoints()
	
	if self.Value then
		self.Thumb:SetPoint("RIGHT", self, 0, 0)
		self.Move:SetOffset(-SWITCH_TRAVEL, 0)
		self.Value = false
	else
		self.Thumb:SetPoint("LEFT", self, 0, 0)
		self.Move:SetOffset(SWITCH_TRAVEL, 0)
		self.Value = true
	end
	
	self.Move:Play()
	
	SetVariable(self.ID, self.Value)
	
	if self.ReloadFlag then
		vUI:DisplayPopup(Language["Attention"], Language["You have changed a setting that requires a UI reload. Would you like to reload the UI now?"], "Accept", self.Hook, "Cancel", nil, self.Value, self.ID)
	elseif self.Hook then
		self.Hook(self.Value, self.ID)
	end
end

local SwitchOnMouseWheel = function(self, delta)
	if (not IsModifierKeyDown()) then
		return
	end
	
	local CurrentValue = self.Value
	local NewValue
	
	if (delta < 0) then
		NewValue = false
	else
		NewValue = true
	end
	
	if (CurrentValue ~= NewValue) then
		SwitchOnMouseUp(self) -- This is already set up to handle everything, so just pass it along
	end
end

local SwitchOnEnter = function(self)
	self.Highlight:SetAlpha(MOUSEOVER_HIGHLIGHT_ALPHA)
	
	if IsModifierKeyDown() then
		self:SetScript("OnMouseWheel", self.OnMouseWheel)
	end
end

local SwitchOnLeave = function(self)
	self.Highlight:SetAlpha(0)
	
	if self:HasScript("OnMouseWheel") then
		self:SetScript("OnMouseWheel", nil)
	end
end

local SwitchEnable = function(self)
	self.Switch:EnableMouse(true)
	self.Switch:EnableMouseWheel(true)
	
	self.Switch.Flavor:SetVertexColor(vUI:HexToRGB(Settings["ui-widget-color"]))
end

local SwitchDisable = function(self)
	self.Switch:EnableMouse(false)
	self.Switch:EnableMouseWheel(false)
	
	self.Switch.Flavor:SetVertexColor(vUI:HexToRGB("A5A5A5"))
end

local SwitchRequiresReload = function(self, flag)
	self.ReloadFlag = flag
	
	return self
end

GUI2.Widgets.CreateSwitch = function(self, id, value, label, tooltip, hook)
	if (Settings[id] ~= nil) then
		value = Settings[id]
	end
	
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetSize(GROUP_WIDTH, WIDGET_HEIGHT)
	Anchor.ID = id
	Anchor.Text = label
	Anchor.Tooltip = tooltip
	Anchor.Enable = SwitchEnable
	Anchor.Disable = SwitchDisable
	
	Anchor:SetScript("OnEnter", AnchorOnEnter)
	Anchor:SetScript("OnLeave", AnchorOnLeave)
	
	local Switch = CreateFrame("Frame", nil, Anchor, "BackdropTemplate")
	Switch:SetSize(SWITCH_WIDTH, WIDGET_HEIGHT)
	Switch:SetPoint("RIGHT", Anchor, 0, 0)
	Switch:SetBackdrop(vUI.BackdropAndBorder)
	Switch:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-main-color"]))
	Switch:SetBackdropBorderColor(0, 0, 0)
	Switch:SetScript("OnMouseUp", SwitchOnMouseUp)
	Switch:SetScript("OnEnter", SwitchOnEnter)
	Switch:SetScript("OnLeave", SwitchOnLeave)
	Switch.Value = value
	Switch.Hook = hook
	Switch.Tooltip = tooltip
	Switch.ID = id
	Switch.RequiresReload = SwitchRequiresReload
	Switch.OnMouseWheel = SwitchOnMouseWheel
	
	Switch.BG = Switch:CreateTexture(nil, "ARTWORK")
	Switch.BG:SetPoint("TOPLEFT", Switch, 1, -1)
	Switch.BG:SetPoint("BOTTOMRIGHT", Switch, -1, 1)
	Switch.BG:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Switch.BG:SetVertexColor(vUI:HexToRGB(Settings["ui-widget-bg-color"]))
	
	Switch.Thumb = CreateFrame("Frame", nil, Switch, "BackdropTemplate")
	Switch.Thumb:SetSize(WIDGET_HEIGHT, WIDGET_HEIGHT)
	Switch.Thumb:SetBackdrop(vUI.BackdropAndBorder)
	Switch.Thumb:SetBackdropBorderColor(0, 0, 0)
	Switch.Thumb:SetBackdropColor(vUI:HexToRGB(Settings["ui-widget-bright-color"]))
	Switch.Thumb:SetPoint(Switch.Value and "RIGHT" or "LEFT", Switch, 0, 0)
	
	Switch.ThumbTexture = Switch.Thumb:CreateTexture(nil, "ARTWORK")
	Switch.ThumbTexture:SetSize(WIDGET_HEIGHT - 2, WIDGET_HEIGHT - 2)
	Switch.ThumbTexture:SetPoint("TOPLEFT", Switch.Thumb, 1, -1)
	Switch.ThumbTexture:SetPoint("BOTTOMRIGHT", Switch.Thumb, -1, 1)
	Switch.ThumbTexture:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Switch.ThumbTexture:SetVertexColor(vUI:HexToRGB(Settings["ui-widget-bright-color"]))
	
	Switch.Flavor = Switch:CreateTexture(nil, "ARTWORK")
	Switch.Flavor:SetPoint("TOPLEFT", Switch, "TOPLEFT", 1, -1)
	Switch.Flavor:SetPoint("BOTTOMRIGHT", Switch.Thumb, "BOTTOMLEFT", 0, 1)
	Switch.Flavor:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Switch.Flavor:SetVertexColor(vUI:HexToRGB(Settings["ui-widget-color"]))
	
	Switch.Text = Anchor:CreateFontString(nil, "OVERLAY")
	Switch.Text:SetPoint("LEFT", Anchor, LABEL_SPACING, 0)
	Switch.Text:SetSize(GROUP_WIDTH - SWITCH_WIDTH - 6, WIDGET_HEIGHT)
	vUI:SetFontInfo(Switch.Text, Settings["ui-widget-font"], Settings["ui-font-size"])
	Switch.Text:SetJustifyH("LEFT")
	Switch.Text:SetText("|cFF"..Settings["ui-widget-font-color"]..label.."|r")
	
	Switch.Highlight = Switch:CreateTexture(nil, "HIGHLIGHT")
	Switch.Highlight:SetPoint("TOPLEFT", Switch, 1, -1)
	Switch.Highlight:SetPoint("BOTTOMRIGHT", Switch, -1, 1)
	Switch.Highlight:SetTexture(Assets:GetTexture("Blank"))
	Switch.Highlight:SetVertexColor(1, 1, 1, 0.4)
	Switch.Highlight:SetAlpha(0)
	
	Switch.Move = CreateAnimationGroup(Switch.Thumb):CreateAnimation("Move")
	Switch.Move:SetEasing("in")
	Switch.Move:SetDuration(0.1)
	
	Anchor.Switch = Switch
	
	tinsert(self.Widgets, Anchor)
	
	return Switch
end

-- Dropdown
local DROPDOWN_WIDTH = 130
local DROPDOWN_HEIGHT = 20
local DROPDOWN_FADE_DELAY = 3 -- To be implemented
local DROPDOWN_MAX_SHOWN = 8

local SetArrowUp = function(button)
	button.ArrowTop.Anim:SetChange(2)
	button.ArrowBottom.Anim:SetChange(6)
	
	button.ArrowTop.Anim:Play()
	button.ArrowBottom.Anim:Play()
end

local SetArrowDown = function(button)
	button.ArrowTop.Anim:SetChange(6)
	button.ArrowBottom.Anim:SetChange(2)
	
	button.ArrowTop.Anim:Play()
	button.ArrowBottom.Anim:Play()
end

local CloseLastDropdown = function(compare)
	if (LAST_ACTIVE_DROPDOWN and LAST_ACTIVE_DROPDOWN.Menu:IsShown() and (LAST_ACTIVE_DROPDOWN ~= compare)) then
		if (not LAST_ACTIVE_DROPDOWN.Menu.FadeOut:IsPlaying()) then
			LAST_ACTIVE_DROPDOWN.Menu.FadeOut:Play()
			SetArrowDown(LAST_ACTIVE_DROPDOWN)
		end
	end
end

local DropdownButtonOnMouseUp = function(self)
	if self.ArrowBottom.Anim:IsPlaying() then
		return
	end
	
	self.Parent.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-widget-bright-color"]))
	
	if self.Menu:IsVisible() then
		self.Menu.FadeOut:Play()
		SetArrowDown(self)
	else
		for i = 1, #self.Menu do
			if self.Parent.SpecificType then
				if (self.Menu[i].Key == self.Parent.Value) then
					self.Menu[i].Selected:Show()
				else
					self.Menu[i].Selected:Hide()
				end
			else
				if (self.Menu[i].Value == self.Parent.Value) then
					self.Menu[i].Selected:Show()
				else
					self.Menu[i].Selected:Hide()
				end
			end
		end
		
		CloseLastDropdown(self)
		self.Menu:Show()
		self.Menu.FadeIn:Play()
		SetArrowUp(self)
	end
	
	LAST_ACTIVE_DROPDOWN = self
end

local DropdownButtonOnMouseDown = function(self)
	local R, G, B = HexToRGB(Settings["ui-widget-bright-color"])
	
	self.Parent.Texture:SetVertexColor(R * 0.85, G * 0.85, B * 0.85)
end

local MenuItemOnMouseUp = function(self)
	self.Parent.FadeOut:Play()
	SetArrowDown(self.GrandParent.Button)
	
	self.Highlight:SetAlpha(0)
	self.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-widget-bright-color"]))
	
	if self.GrandParent.SpecificType then
		SetVariable(self.ID, self.Key)
		
		self.GrandParent.Value = self.Key
		
		if self.GrandParent.ReloadFlag then
			vUI:DisplayPopup(Language["Attention"], Language["You have changed a setting that requires a UI reload. Would you like to reload the UI now?"], "Accept", self.GrandParent.Hook, "Cancel", nil, self.Key, self.ID)
		elseif self.GrandParent.Hook then
			self.GrandParent.Hook(self.Key, self.ID)
		end
	else
		SetVariable(self.ID, self.Value)
		
		self.GrandParent.Value = self.Value
		
		if self.GrandParent.ReloadFlag then
			vUI:DisplayPopup(Language["Attention"], Language["You have changed a setting that requires a UI reload. Would you like to reload the UI now?"], "Accept", self.GrandParent.Hook, "Cancel", nil, self.Value, self.ID)
		elseif self.GrandParent.Hook then
			self.GrandParent.Hook(self.Value, self.ID)
		end
	end
	
	if (self.GrandParent.SpecificType == "Texture") then
		self.GrandParent.Texture:SetTexture(Assets:GetTexture(self.Key))
	elseif (self.GrandParent.SpecificType == "Font") then
		vUI:SetFontInfo(self.GrandParent.Current, self.Key, Settings["ui-font-size"])
	end
	
	self.GrandParent.Current:SetText(self.Key)
end

local MenuItemOnMouseDown = function(self)
	local R, G, B = HexToRGB(Settings["ui-widget-bright-color"])
	
	self.Texture:SetVertexColor(R * 0.85, G * 0.85, B * 0.85)
end

local DropdownUpdateList = function(self)
	
end

local DropdownOnEnter = function(self)
	self.Highlight:SetAlpha(MOUSEOVER_HIGHLIGHT_ALPHA)
end

local DropdownOnLeave = function(self)
	self.Highlight:SetAlpha(0)
end

local MenuItemOnEnter = function(self)
	self.Highlight:SetAlpha(MOUSEOVER_HIGHLIGHT_ALPHA)
end

local MenuItemOnLeave = function(self)
	self.Highlight:SetAlpha(0)
end

local DropdownEnable = function(self)
	self.Dropdown.Button:EnableMouse(true)
	
	self.Dropdown.Current:SetTextColor(vUI:HexToRGB("FFFFFF"))
	
	self.Dropdown.Button.ArrowBottom:SetVertexColor(vUI:HexToRGB(Settings["ui-widget-color"]))
	self.Dropdown.Button.ArrowMiddle:SetVertexColor(vUI:HexToRGB(Settings["ui-widget-color"]))
	self.Dropdown.Button.ArrowTop:SetVertexColor(vUI:HexToRGB(Settings["ui-widget-color"]))
end

local DropdownDisable = function(self)
	self.Dropdown.Button:EnableMouse(false)
	
	self.Dropdown.Current:SetTextColor(vUI:HexToRGB("A5A5A5"))
	
	self.Dropdown.Button.ArrowBottom:SetVertexColor(vUI:HexToRGB("A5A5A5"))
	self.Dropdown.Button.ArrowMiddle:SetVertexColor(vUI:HexToRGB("A5A5A5"))
	self.Dropdown.Button.ArrowTop:SetVertexColor(vUI:HexToRGB("A5A5A5"))
end

local DropdownRequiresReload = function(self, flag)
	self.ReloadFlag = flag
	
	return self
end

local ScrollMenu = function(self)
	local First = false
	
	for i = 1, #self do
		if (i >= self.Offset) and (i <= self.Offset + DROPDOWN_MAX_SHOWN - 1) then
			if (not First) then
				self[i]:SetPoint("TOPLEFT", self, 0, 0)
				First = true
			else
				self[i]:SetPoint("TOPLEFT", self[i-1], "BOTTOMLEFT", 0, 1)
			end
			
			self[i]:Show()
		else
			self[i]:Hide()
		end
	end
end

local SetDropdownOffsetByDelta = function(self, delta)
	if (delta == 1) then -- up
		self.Offset = self.Offset - 1
		
		if (self.Offset <= 1) then
			self.Offset = 1
		end
	else -- down
		self.Offset = self.Offset + 1
		
		if (self.Offset > (#self - (DROPDOWN_MAX_SHOWN - 1))) then
			self.Offset = self.Offset - 1
		end
	end
end

local DropdownOnMouseWheel = function(self, delta)
	self:SetDropdownOffsetByDelta(delta)
	self:ScrollMenu()
	self.ScrollBar:SetValue(self.Offset)
end

local SetDropdownOffset = function(self, offset)
	self.Offset = offset
	
	if (self.Offset <= 1) then
		self.Offset = 1
	elseif (self.Offset > (#self - DROPDOWN_MAX_SHOWN - 1)) then
		self.Offset = self.Offset - 1
	end
	
	self:ScrollMenu()
end

local DropdownScrollBarOnValueChanged = function(self)
	local Value = Round(self:GetValue())
	local Parent = self:GetParent()
	Parent.Offset = Value
	
	Parent:ScrollMenu()
end

local DropdownScrollBarOnMouseWheel = function(self, delta)
	DropdownOnMouseWheel(self:GetParent(), delta)
end

local AddDropdownScrollBar = function(self)
	local MaxValue = (#self - (DROPDOWN_MAX_SHOWN - 1))
	local ScrollWidth = (WIDGET_HEIGHT / 2)
	
	local ScrollBar = CreateFrame("Slider", nil, self, "BackdropTemplate")
	ScrollBar:SetPoint("TOPLEFT", self, "TOPRIGHT", 2, 0)
	ScrollBar:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", 2, 0)
	ScrollBar:SetWidth(ScrollWidth)
	ScrollBar:SetThumbTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	ScrollBar:SetOrientation("VERTICAL")
	ScrollBar:SetValueStep(1)
	ScrollBar:SetBackdrop(vUI.BackdropAndBorder)
	ScrollBar:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-main-color"]))
	ScrollBar:SetBackdropBorderColor(0, 0, 0)
	ScrollBar:SetMinMaxValues(1, MaxValue)
	ScrollBar:SetValue(1)
	--ScrollBar:SetObeyStepOnDrag(true)
	ScrollBar:EnableMouseWheel(true)
	ScrollBar:SetScript("OnMouseWheel", DropdownScrollBarOnMouseWheel)
	ScrollBar:SetScript("OnValueChanged", DropdownScrollBarOnValueChanged)
	
	self.ScrollBar = ScrollBar
	
	local Thumb = ScrollBar:GetThumbTexture() 
	Thumb:SetSize(ScrollWidth, WIDGET_HEIGHT)
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
	ScrollBar.Progress:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	ScrollBar.Progress:SetVertexColor(vUI:HexToRGB(Settings["ui-widget-color"]))
	
	self:EnableMouseWheel(true)
	self:SetScript("OnMouseWheel", DropdownOnMouseWheel)
	
	self.ScrollMenu = ScrollMenu
	self.SetDropdownOffset = SetDropdownOffset
	self.SetDropdownOffsetByDelta = SetDropdownOffsetByDelta
	self.ScrollBar = ScrollBar
	
	self:SetDropdownOffset(1)
	
	ScrollBar:Show()
	
	for i = 1, #self do
		self[i]:SetWidth((DROPDOWN_WIDTH - ScrollWidth) - (SPACING * 3) + 1)
	end
	
	self:SetWidth((DROPDOWN_WIDTH - ScrollWidth) - (SPACING * 3) + 1)
	self:SetHeight(((WIDGET_HEIGHT - 1) * DROPDOWN_MAX_SHOWN) + 1)
end

local DropdownSort = function(self)
	tsort(self.Menu, function(a, b)
		return TrimHex(a.Key) < TrimHex(b.Key)
	end)
	
	for i = 1, #self.Menu do
		if (i == 1) then
			self.Menu[i]:SetPoint("TOP", self.Menu, 0, 0)
		else
			self.Menu[i]:SetPoint("TOP", self.Menu[i-1], "BOTTOM", 0, 1)
		end
	end
	
	self.Menu:SetHeight(((WIDGET_HEIGHT - 1) * #self.Menu) + 1)
end

local DropdownCreateSelection = function(self, key, value)
	local MenuItem = CreateFrame("Frame", nil, self.Menu, "BackdropTemplate")
	MenuItem:SetSize(DROPDOWN_WIDTH - 6, WIDGET_HEIGHT)
	MenuItem:SetBackdrop(vUI.BackdropAndBorder)
	MenuItem:SetBackdropColor(vUI:HexToRGB(Settings["ui-widget-bg-color"]))
	MenuItem:SetBackdropBorderColor(0, 0, 0)
	MenuItem:SetScript("OnMouseDown", MenuItemOnMouseDown)
	MenuItem:SetScript("OnMouseUp", MenuItemOnMouseUp)
	MenuItem:SetScript("OnEnter", MenuItemOnEnter)
	MenuItem:SetScript("OnLeave", MenuItemOnLeave)
	MenuItem.Parent = MenuItem:GetParent()
	MenuItem.GrandParent = MenuItem.Parent:GetParent()
	MenuItem.Key = key
	MenuItem.Value = value
	MenuItem.ID = self.ID
	
	MenuItem.Highlight = MenuItem:CreateTexture(nil, "OVERLAY")
	MenuItem.Highlight:SetPoint("TOPLEFT", MenuItem, 1, -1)
	MenuItem.Highlight:SetPoint("BOTTOMRIGHT", MenuItem, -1, 1)
	MenuItem.Highlight:SetTexture(Assets:GetTexture("Blank"))
	MenuItem.Highlight:SetVertexColor(1, 1, 1, 0.4)
	MenuItem.Highlight:SetAlpha(0)
	
	MenuItem.Texture = MenuItem:CreateTexture(nil, "ARTWORK")
	MenuItem.Texture:SetPoint("TOPLEFT", MenuItem, 1, -1)
	MenuItem.Texture:SetPoint("BOTTOMRIGHT", MenuItem, -1, 1)
	MenuItem.Texture:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	MenuItem.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-widget-bright-color"]))
	
	MenuItem.Selected = MenuItem:CreateTexture(nil, "OVERLAY")
	MenuItem.Selected:SetPoint("TOPLEFT", MenuItem, 1, -1)
	MenuItem.Selected:SetPoint("BOTTOMRIGHT", MenuItem, -1, 1)
	MenuItem.Selected:SetTexture(Assets:GetTexture("RenHorizonUp"))
	MenuItem.Selected:SetVertexColor(vUI:HexToRGB(Settings["ui-widget-color"]))
	MenuItem.Selected:SetAlpha(SELECTED_HIGHLIGHT_ALPHA)
	
	MenuItem.Text = MenuItem:CreateFontString(nil, "OVERLAY")
	MenuItem.Text:SetPoint("LEFT", MenuItem, 5, 0)
	MenuItem.Text:SetSize((DROPDOWN_WIDTH - 6) - 12, WIDGET_HEIGHT)
	vUI:SetFontInfo(MenuItem.Text, Settings["ui-widget-font"], Settings["ui-font-size"])
	MenuItem.Text:SetJustifyH("LEFT")
	MenuItem.Text:SetText(key)
	
	tinsert(self.Menu, MenuItem)
	
	return MenuItem
end

local DropdownRemoveSelection = function(self, key)
	for i = 1, #self.Menu do
		if (self.Menu[i].Key == key) then
			self.Menu[i]:Hide() -- Handle this more thoroughly
			self.Menu[i]:EnableMouse(false)
			
			tremove(self.Menu, i)
			
			self:Sort()
			
			return
		end
	end
end

GUI2.Widgets.CreateDropdown = function(self, id, value, values, label, tooltip, hook, specific)
	if (Settings[id] ~= nil) then
		value = Settings[id]
	end
	
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetSize(GROUP_WIDTH, WIDGET_HEIGHT)
	Anchor.ID = id
	Anchor.Text = label
	Anchor.Tooltip = tooltip
	Anchor.Enable = DropdownEnable
	Anchor.Disable = DropdownDisable
	
	Anchor:SetScript("OnEnter", AnchorOnEnter)
	Anchor:SetScript("OnLeave", AnchorOnLeave)
	
	local Dropdown = CreateFrame("Frame", nil, Anchor, "BackdropTemplate")
	Dropdown:SetSize(DROPDOWN_WIDTH, WIDGET_HEIGHT)
	Dropdown:SetPoint("RIGHT", Anchor, 0, 0)
	Dropdown:SetBackdrop(vUI.BackdropAndBorder)
	Dropdown:SetBackdropColor(0.6, 0.6, 0.6)
	Dropdown:SetBackdropBorderColor(0, 0, 0)
	Dropdown:SetFrameLevel(self:GetFrameLevel() + 1)
	Dropdown.Values = values
	Dropdown.Value = value
	Dropdown.ID = id
	Dropdown.Hook = hook
	Dropdown.Tooltip = tooltip
	Dropdown.SpecificType = specific
	Dropdown.RequiresReload = DropdownRequiresReload
	
	Dropdown.Sort = DropdownSort
	Dropdown.CreateSelection = DropdownCreateSelection
	Dropdown.RemoveSelection = DropdownRemoveSelection
	
	Dropdown.Texture = Dropdown:CreateTexture(nil, "ARTWORK")
	Dropdown.Texture:SetPoint("TOPLEFT", Dropdown, 1, -1)
	Dropdown.Texture:SetPoint("BOTTOMRIGHT", Dropdown, -1, 1)
	Dropdown.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-widget-bright-color"]))
	
	Dropdown.Current = Dropdown:CreateFontString(nil, "ARTWORK")
	Dropdown.Current:SetPoint("LEFT", Dropdown, HEADER_SPACING, 0)
	Dropdown.Current:SetSize(DROPDOWN_WIDTH - 20, Settings["ui-font-size"])
	vUI:SetFontInfo(Dropdown.Current, Settings["ui-widget-font"], Settings["ui-font-size"])
	Dropdown.Current:SetJustifyH("LEFT")
	
	Dropdown.Button = CreateFrame("Frame", nil, Dropdown, "BackdropTemplate")
	Dropdown.Button:SetSize(DROPDOWN_WIDTH, WIDGET_HEIGHT)
	Dropdown.Button:SetPoint("LEFT", Dropdown, 0, 0)
	Dropdown.Button:SetBackdrop(vUI.BackdropAndBorder)
	Dropdown.Button:SetBackdropColor(0, 0, 0, 0)
	Dropdown.Button:SetBackdropBorderColor(0, 0, 0, 0)
	Dropdown.Button:SetScript("OnMouseUp", DropdownButtonOnMouseUp)
	Dropdown.Button:SetScript("OnMouseDown", DropdownButtonOnMouseDown)
	Dropdown.Button:SetScript("OnEnter", DropdownOnEnter)
	Dropdown.Button:SetScript("OnLeave", DropdownOnLeave)
	
	Dropdown.Button.Highlight = Dropdown.Button:CreateTexture(nil, "OVERLAY")
	Dropdown.Button.Highlight:SetPoint("TOPLEFT", Dropdown.Button, 1, -1)
	Dropdown.Button.Highlight:SetPoint("BOTTOMRIGHT", Dropdown.Button, -1, 1)
	Dropdown.Button.Highlight:SetTexture(Assets:GetTexture("Blank"))
	Dropdown.Button.Highlight:SetVertexColor(1, 1, 1, 0.4)
	Dropdown.Button.Highlight:SetAlpha(0)
	
	Dropdown.Text = Dropdown:CreateFontString(nil, "OVERLAY")
	Dropdown.Text:SetPoint("LEFT", Anchor, LABEL_SPACING, 0)
	Dropdown.Text:SetSize(GROUP_WIDTH - DROPDOWN_WIDTH - 6, WIDGET_HEIGHT)
	vUI:SetFontInfo(Dropdown.Text, Settings["ui-widget-font"], Settings["ui-font-size"])
	Dropdown.Text:SetJustifyH("LEFT")
	Dropdown.Text:SetText("|cFF"..Settings["ui-widget-font-color"]..label.."|r")
	
	Dropdown.ArrowAnchor = CreateFrame("Frame", nil, Dropdown)
	Dropdown.ArrowAnchor:SetSize(WIDGET_HEIGHT, WIDGET_HEIGHT)
	Dropdown.ArrowAnchor:SetPoint("RIGHT", Dropdown, 0, 0)
	
	local ArrowMiddle = Dropdown.Button:CreateTexture(nil, "OVERLAY", 7)
	ArrowMiddle:SetPoint("CENTER", Dropdown.ArrowAnchor, 0, 0)
	ArrowMiddle:SetSize(4, 1)
	ArrowMiddle:SetTexture(Assets:GetTexture("Blank"))
	ArrowMiddle:SetVertexColor(vUI:HexToRGB(Settings["ui-widget-color"]))
	
	ArrowMiddle.BG = Dropdown.Button:CreateTexture(nil, "BORDER", 7)
	ArrowMiddle.BG:SetPoint("TOPLEFT", ArrowMiddle, -1, 1)
	ArrowMiddle.BG:SetPoint("BOTTOMRIGHT", ArrowMiddle, 1, -1)
	ArrowMiddle.BG:SetTexture(Assets:GetTexture("Blank"))
	ArrowMiddle.BG:SetVertexColor(0, 0, 0)
	
	local ArrowTop = Dropdown.Button:CreateTexture(nil, "OVERLAY", 7)
	ArrowTop:SetSize(6, 1)
	ArrowTop:SetPoint("BOTTOM", ArrowMiddle, "TOP", 0, 0)
	ArrowTop:SetTexture(Assets:GetTexture("Blank"))
	ArrowTop:SetVertexColor(vUI:HexToRGB(Settings["ui-widget-color"]))
	
	ArrowTop.BG = Dropdown.Button:CreateTexture(nil, "BORDER", 7)
	ArrowTop.BG:SetPoint("TOPLEFT", ArrowTop, -1, 1)
	ArrowTop.BG:SetPoint("BOTTOMRIGHT", ArrowTop, 1, -1)
	ArrowTop.BG:SetTexture(Assets:GetTexture("Blank"))
	ArrowTop.BG:SetVertexColor(0, 0, 0)
	
	ArrowTop.Anim = CreateAnimationGroup(ArrowTop):CreateAnimation("Width")
	ArrowTop.Anim:SetEasing("in")
	ArrowTop.Anim:SetDuration(0.15)
	
	local ArrowBottom = Dropdown.Button:CreateTexture(nil, "OVERLAY", 7)
	ArrowBottom:SetSize(2, 1)
	ArrowBottom:SetPoint("TOP", ArrowMiddle, "BOTTOM", 0, 0)
	ArrowBottom:SetTexture(Assets:GetTexture("Blank"))
	ArrowBottom:SetVertexColor(vUI:HexToRGB(Settings["ui-widget-color"]))
	
	ArrowBottom.BG = Dropdown.Button:CreateTexture(nil, "BORDER", 7)
	ArrowBottom.BG:SetPoint("TOPLEFT", ArrowBottom, -1, 1)
	ArrowBottom.BG:SetPoint("BOTTOMRIGHT", ArrowBottom, 1, -1)
	ArrowBottom.BG:SetTexture(Assets:GetTexture("Blank"))
	ArrowBottom.BG:SetVertexColor(0, 0, 0)
	
	ArrowBottom.Anim = CreateAnimationGroup(ArrowBottom):CreateAnimation("Width")
	ArrowBottom.Anim:SetEasing("in")
	ArrowBottom.Anim:SetDuration(0.15)
	
	Dropdown.Menu = CreateFrame("Frame", nil, Dropdown, "BackdropTemplate")
	Dropdown.Menu:SetPoint("TOPLEFT", Dropdown, "BOTTOMLEFT", SPACING, -2)
	Dropdown.Menu:SetSize(DROPDOWN_WIDTH - (SPACING * 2), 1)
	Dropdown.Menu:SetBackdrop(vUI.BackdropAndBorder)
	Dropdown.Menu:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-main-color"]))
	Dropdown.Menu:SetBackdropBorderColor(0, 0, 0)
	Dropdown.Menu:SetFrameStrata("DIALOG")
	Dropdown.Menu:EnableMouse(true)
	Dropdown.Menu:EnableMouseWheel(true)
	Dropdown.Menu:Hide()
	Dropdown.Menu:SetAlpha(0)
	
	Dropdown.Button.ArrowBottom = ArrowBottom
	Dropdown.Button.ArrowMiddle = ArrowMiddle
	Dropdown.Button.ArrowTop = ArrowTop
	Dropdown.Button.Menu = Dropdown.Menu
	Dropdown.Button.Parent = Dropdown
	
	Dropdown.Menu.Fade = CreateAnimationGroup(Dropdown.Menu)
	
	Dropdown.Menu.FadeIn = Dropdown.Menu.Fade:CreateAnimation("Fade")
	Dropdown.Menu.FadeIn:SetEasing("in")
	Dropdown.Menu.FadeIn:SetDuration(0.15)
	Dropdown.Menu.FadeIn:SetChange(1)
	
	Dropdown.Menu.FadeOut = Dropdown.Menu.Fade:CreateAnimation("Fade")
	Dropdown.Menu.FadeOut:SetEasing("out")
	Dropdown.Menu.FadeOut:SetDuration(0.15)
	Dropdown.Menu.FadeOut:SetChange(0)
	Dropdown.Menu.FadeOut:SetScript("OnFinished", FadeOnFinished)
	
	Dropdown.Menu.BG = CreateFrame("Frame", nil, Dropdown.Menu, "BackdropTemplate")
	Dropdown.Menu.BG:SetPoint("BOTTOMLEFT", Dropdown.Menu, -SPACING, -SPACING)
	Dropdown.Menu.BG:SetPoint("TOPRIGHT", Dropdown, "BOTTOMRIGHT", 0, 1)
	Dropdown.Menu.BG:SetBackdrop(vUI.BackdropAndBorder)
	Dropdown.Menu.BG:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-bg-color"]))
	Dropdown.Menu.BG:SetBackdropBorderColor(0, 0, 0)
	Dropdown.Menu.BG:SetFrameLevel(Dropdown.Menu:GetFrameLevel() - 1)
	Dropdown.Menu:EnableMouse(true)
	Dropdown.Menu.BG:EnableMouse(true)
	Dropdown.Menu.BG:SetScript("OnMouseWheel", function() end) -- Just to prevent misclicks from going through the frame
	
	for Key, Value in pairs(values) do
		local MenuItem = Dropdown:CreateSelection(Key, Value)
		
		if (specific == "Texture") then
			MenuItem.Texture:SetTexture(Assets:GetTexture(Key))
		elseif (specific == "Font") then
			vUI:SetFontInfo(MenuItem.Text, Key, 12)
		end
		
		if specific then
			if (MenuItem.Key == MenuItem.GrandParent.Value) then
				MenuItem.Selected:Show()
				MenuItem.GrandParent.Current:SetText(Key)
			else
				MenuItem.Selected:Hide()
			end
		else
			if (MenuItem.Value == MenuItem.GrandParent.Value) then
				MenuItem.Selected:Show()
				MenuItem.GrandParent.Current:SetText(Key)
			else
				MenuItem.Selected:Hide()
			end
		end
		
		Dropdown:Sort()
	end
	
	if (specific == "Texture") then
		Dropdown.Texture:SetTexture(Assets:GetTexture(value))
	elseif (specific == "Font") then
		Dropdown.Texture:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
		vUI:SetFontInfo(Dropdown.Current, Settings[id], Settings["ui-font-size"])
	else
		Dropdown.Texture:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	end
	
	if (#Dropdown.Menu > DROPDOWN_MAX_SHOWN) then
		AddDropdownScrollBar(Dropdown.Menu)
	else
		Dropdown.Menu:SetHeight(((WIDGET_HEIGHT - 1) * #Dropdown.Menu) + 1)
	end
	
	Anchor.Dropdown = Dropdown
	
	if self.Widgets then
		tinsert(self.Widgets, Anchor)
	end
	
	return Dropdown
end

-- Slider
local SLIDER_WIDTH = 80
local EDITBOX_WIDTH = 48

local SliderOnValueChanged = function(self)
	local Value = self:GetValue()
	
	if (self.EditBox.StepValue >= 1) then
		Value = floor(Value)
	else
		if (self.EditBox.StepValue <= 0.01) then
			Value = Round(Value, 2)
		else
			Value = Round(Value, 1)
		end
	end
	
	self.EditBox.Value = Value
	self.EditBox:SetText(self.Prefix..Value..self.Postfix)
	
	SetVariable(self.ID, Value)
	
	if self.ReloadFlag then
		vUI:DisplayPopup(Language["Attention"], Language["You have changed a setting that requires a UI reload. Would you like to reload the UI now?"], "Accept", self.Hook, "Cancel", nil, Value, self.ID)
	elseif self.Hook then
		self.Hook(Value, self.ID)
	end
end

local SliderOnMouseWheel = function(self, delta)
	if (not IsModifierKeyDown()) then
		return
	end
	
	local Value = self.EditBox.Value
	local Step = self.EditBox.StepValue
	
	if (delta < 0) then
		Value = Value - Step
	else
		Value = Value + Step
	end
	
	if (Step >= 1) then
		Value = floor(Value)
	else
		if (Step <= 0.01) then
			Value = Round(Value, 2)
		else
			Value = Round(Value, 1)
		end
	end
	
	if (Value < self.EditBox.MinValue) then
		Value = self.EditBox.MinValue
	elseif (Value > self.EditBox.MaxValue) then
		Value = self.EditBox.MaxValue
	end
	
	self.EditBox.Value = Value
	
	self:SetValue(Value)
	self.EditBox:SetText(self.Prefix..Value..self.Postfix)
end

local EditBoxOnEnterPressed = function(self)
	local Value = tonumber(self:GetText())
	
	if (type(Value) ~= "number") then
		return
	end
	
	if (Value ~= self.Value) then
		self.Slider:SetValue(Value)
		SliderOnValueChanged(self.Slider)
	end
	
	self:SetAutoFocus(false)
	self:ClearFocus()
end

local EditBoxOnMouseDown = function(self)
	self:SetAutoFocus(true)
	self:SetText(self.Value)
end

local EditBoxOnEditFocusLost = function(self)
	if (self.Value > self.MaxValue) then
		self.Value = self.MaxValue
	elseif (self.Value < self.MinValue) then
		self.Value = self.MinValue
	end
	
	self:SetText(self.Prefix..self.Value..self.Postfix)
end

local EditBoxOnChar = function(self)
	local Value = tonumber(self:GetText())
	
	if (type(Value) ~= "number") then
		self:SetText(self.Value)
	end
end

local EditBoxOnMouseWheel = function(self, delta)
	if (not IsModifierKeyDown()) then
		return
	end
	
	if self:HasFocus() then
		self:SetAutoFocus(false)
		self:ClearFocus()
	end
	
	if (delta > 0) then
		self.Value = self.Value + self.StepValue
		
		if (self.Value > self.MaxValue) then
			self.Value = self.MaxValue
		end
	else
		self.Value = self.Value - self.StepValue
		
		if (self.Value < self.MinValue) then
			self.Value = self.MinValue
		end
	end
	
	self:SetText(self.Value)
	self.Slider:SetValue(self.Value)
end

local EditBoxOnEnter = function(self)
	self.Parent.Highlight:SetAlpha(MOUSEOVER_HIGHLIGHT_ALPHA)
	
	if IsModifierKeyDown() then
		self:SetScript("OnMouseWheel", self.OnMouseWheel)
	end
end

local EditboxOnLeave = function(self)
	self.Parent.Highlight:SetAlpha(0)
	
	if self:HasScript("OnMouseWheel") then
		self:SetScript("OnMouseWheel", nil)
	end
end

local SliderOnEnter = function(self)
	self.Highlight:SetAlpha(MOUSEOVER_HIGHLIGHT_ALPHA)
	
	if IsModifierKeyDown() then
		self:SetScript("OnMouseWheel", self.OnMouseWheel)
	end
end

local SliderOnLeave = function(self)
	self.Highlight:SetAlpha(0)
	
	if self:HasScript("OnMouseWheel") then
		self:SetScript("OnMouseWheel", nil)
	end
end

local SliderEnable = function(self)
	self.Slider:EnableMouse(true)
	self.Slider:EnableMouseWheel(true)
	
	self.Slider.EditBox:EnableKeyboard(true)
	self.Slider.EditBox:EnableMouse(true)
	self.Slider.EditBox:EnableMouseWheel(true)
	
	self.Slider.EditBox:SetTextColor(vUI:HexToRGB("FFFFFF"))
	self.Slider.Progress:SetVertexColor(vUI:HexToRGB(Settings["ui-widget-color"]))
end

local SliderDisable = function(self)
	self.Slider:EnableMouse(false)
	self.Slider:EnableMouseWheel(false)
	
	self.Slider.EditBox:EnableKeyboard(false)
	self.Slider.EditBox:EnableMouse(false)
	self.Slider.EditBox:EnableMouseWheel(false)
	
	self.Slider.EditBox:SetTextColor(vUI:HexToRGB("A5A5A5"))
	self.Slider.Progress:SetVertexColor(vUI:HexToRGB("A5A5A5"))
end

local SliderRequiresReload = function(self, flag)
	self.ReloadFlag = flag
	
	return self
end

GUI2.Widgets.CreateSlider = function(self, id, value, minvalue, maxvalue, step, label, tooltip, hook, prefix, postfix)
	if (Settings[id] ~= nil) then
		value = Settings[id]
	end
	
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetSize(GROUP_WIDTH, DROPDOWN_HEIGHT)
	Anchor.ID = id
	Anchor.Text = label
	Anchor.Tooltip = tooltip
	Anchor.Enable = SliderEnable
	Anchor.Disable = SliderDisable
	
	Anchor:SetScript("OnEnter", AnchorOnEnter)
	Anchor:SetScript("OnLeave", AnchorOnLeave)
	
	if (not prefix) then
		prefix = ""
	end
	
	if (not postfix) then
		postfix = ""
	end
	
	local EditBox = CreateFrame("Frame", nil, Anchor, "BackdropTemplate")
	EditBox:SetSize(EDITBOX_WIDTH, WIDGET_HEIGHT)
	EditBox:SetPoint("RIGHT", Anchor, 0, 0)
	EditBox:SetBackdrop(vUI.BackdropAndBorder)
	EditBox:SetBackdropColor(vUI:HexToRGB(Settings["ui-window-main-color"]))
	EditBox:SetBackdropBorderColor(0, 0, 0)
	
	EditBox.Texture = EditBox:CreateTexture(nil, "ARTWORK")
	EditBox.Texture:SetPoint("TOPLEFT", EditBox, 1, -1)
	EditBox.Texture:SetPoint("BOTTOMRIGHT", EditBox, -1, 1)
	EditBox.Texture:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	EditBox.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-widget-bright-color"]))
	
	EditBox.Highlight = EditBox:CreateTexture(nil, "OVERLAY")
	EditBox.Highlight:SetPoint("TOPLEFT", EditBox, 1, -1)
	EditBox.Highlight:SetPoint("BOTTOMRIGHT", EditBox, -1, 1)
	EditBox.Highlight:SetTexture(Assets:GetTexture("Blank"))
	EditBox.Highlight:SetVertexColor(1, 1, 1, 0.4)
	EditBox.Highlight:SetAlpha(0)
	
	EditBox.Box = CreateFrame("EditBox", nil, EditBox)
	vUI:SetFontInfo(EditBox.Box, Settings["ui-widget-font"], Settings["ui-font-size"])
	EditBox.Box:SetPoint("TOPLEFT", EditBox, SPACING, -2)
	EditBox.Box:SetPoint("BOTTOMRIGHT", EditBox, -SPACING, 2)
	EditBox.Box:SetJustifyH("CENTER")
	EditBox.Box:SetMaxLetters(5)
	EditBox.Box:SetAutoFocus(false)
	EditBox.Box:EnableKeyboard(true)
	EditBox.Box:EnableMouse(true)
	EditBox.Box:EnableMouseWheel(true)
	EditBox.Box:SetText(prefix..value..postfix)
	EditBox.Box.MinValue = minvalue
	EditBox.Box.MaxValue = maxvalue
	EditBox.Box.StepValue = step
	EditBox.Box.Value = value
	EditBox.Box.Prefix = prefix
	EditBox.Box.Postfix = postfix
	EditBox.Box.Parent = EditBox
	EditBox.Box.OnMouseWheel = EditBoxOnMouseWheel
	
	EditBox.Box:SetScript("OnMouseDown", EditBoxOnMouseDown)
	EditBox.Box:SetScript("OnEscapePressed", EditBoxOnEnterPressed)
	EditBox.Box:SetScript("OnEnterPressed", EditBoxOnEnterPressed)
	EditBox.Box:SetScript("OnEditFocusLost", EditBoxOnEditFocusLost)
	EditBox.Box:SetScript("OnChar", EditBoxOnChar)
	EditBox.Box:SetScript("OnEnter", EditBoxOnEnter)
	EditBox.Box:SetScript("OnLeave", EditboxOnLeave)
	
	local Slider = CreateFrame("Slider", nil, Anchor, "BackdropTemplate")
	Slider:SetPoint("RIGHT", EditBox, "LEFT", -2, 0)
	Slider:SetSize(SLIDER_WIDTH, WIDGET_HEIGHT)
	Slider:SetThumbTexture(Assets:GetTexture("Blank"))
	Slider:SetOrientation("HORIZONTAL")
	Slider:SetValueStep(step)
	Slider:SetBackdrop(vUI.BackdropAndBorder)
	Slider:SetBackdropColor(0, 0, 0)
	Slider:SetBackdropBorderColor(0, 0, 0)
	Slider:SetMinMaxValues(minvalue, maxvalue)
	Slider:SetValue(value)
	Slider:EnableMouseWheel(true)
	Slider:SetObeyStepOnDrag(true)
	Slider:SetScript("OnValueChanged", SliderOnValueChanged)
	Slider:SetScript("OnEnter", SliderOnEnter)
	Slider:SetScript("OnLeave", SliderOnLeave)
	Slider.Prefix = prefix or ""
	Slider.Postfix = postfix or ""
	Slider.EditBox = EditBox.Box
	Slider.Hook = hook
	Slider.ID = id
	Slider.RequiresReload = SliderRequiresReload
	Slider.OnMouseWheel = SliderOnMouseWheel
	
	Slider.Text = Slider:CreateFontString(nil, "OVERLAY")
	Slider.Text:SetPoint("LEFT", Anchor, LABEL_SPACING, 0)
	Slider.Text:SetSize(GROUP_WIDTH - SLIDER_WIDTH - EDITBOX_WIDTH - 6, WIDGET_HEIGHT)
	vUI:SetFontInfo(Slider.Text, Settings["ui-widget-font"], Settings["ui-font-size"])
	Slider.Text:SetJustifyH("LEFT")
	Slider.Text:SetText("|cFF"..Settings["ui-widget-font-color"]..label.."|r")
	
	Slider.TrackTexture = Slider:CreateTexture(nil, "ARTWORK")
	Slider.TrackTexture:SetPoint("TOPLEFT", Slider, 1, -1)
	Slider.TrackTexture:SetPoint("BOTTOMRIGHT", Slider, -1, 1)
	Slider.TrackTexture:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Slider.TrackTexture:SetVertexColor(vUI:HexToRGB(Settings["ui-widget-bg-color"]))
	
	local Thumb = Slider:GetThumbTexture()
	Thumb:SetSize(8, WIDGET_HEIGHT)
	Thumb:SetTexture(Assets:GetTexture("Blank"))
	Thumb:SetVertexColor(0, 0, 0)
	
	Slider.NewThumb = CreateFrame("Frame", nil, Slider, "BackdropTemplate")
	Slider.NewThumb:SetPoint("TOPLEFT", Thumb, 0, -1)
	Slider.NewThumb:SetPoint("BOTTOMRIGHT", Thumb, 0, 1)
	Slider.NewThumb:SetBackdrop(vUI.BackdropAndBorder)
	Slider.NewThumb:SetBackdropColor(vUI:HexToRGB(Settings["ui-widget-bg-color"]))
	Slider.NewThumb:SetBackdropBorderColor(0, 0, 0)
	
	Slider.NewThumb.Texture = Slider.NewThumb:CreateTexture(nil, "OVERLAY")
	Slider.NewThumb.Texture:SetPoint("TOPLEFT", Slider.NewThumb, 1, 0)
	Slider.NewThumb.Texture:SetPoint("BOTTOMRIGHT", Slider.NewThumb, -1, 0)
	Slider.NewThumb.Texture:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Slider.NewThumb.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-widget-bright-color"]))
	
	Slider.Progress = Slider:CreateTexture(nil, "ARTWORK")
	Slider.Progress:SetPoint("TOPLEFT", Slider, 1, -1)
	Slider.Progress:SetPoint("BOTTOMRIGHT", Slider.NewThumb.Texture, "BOTTOMLEFT", 0, 0)
	Slider.Progress:SetTexture(Assets:GetTexture(Settings["ui-widget-texture"]))
	Slider.Progress:SetVertexColor(vUI:HexToRGB(Settings["ui-widget-color"]))
	
	Slider.Highlight = Slider:CreateTexture(nil, "OVERLAY", 8)
	Slider.Highlight:SetPoint("TOPLEFT", Slider, 1, -1)
	Slider.Highlight:SetPoint("BOTTOMRIGHT", Slider, -1, 1)
	Slider.Highlight:SetTexture(Assets:GetTexture("Blank"))
	Slider.Highlight:SetVertexColor(1, 1, 1, 0.4)
	Slider.Highlight:SetAlpha(0)
	
	EditBox.Box.Slider = Slider
	Anchor.Slider = Slider
	
	Slider:Show()
	
	tinsert(self.Widgets, Anchor)
	
	return Slider
end

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
	table.sort(self.Categories, function(a, b)
		return a.Name < b.Name
	end)
	
	self.NumShownButtons = 0
	
	for i = 1, #self.Categories do
		table.sort(self.Categories[i].Buttons, function(a, b)
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

--[[
	what if the window exists, but the callback doesn't fire? and then
	when we create the button it stores the window as like Button.Window = Window
	then in the OnMouseUp self.Window:Show()
]]

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
	
	--[[if parent then
		for i = 1, #category.Children do
			if (category.Children[i].Name == name) then
				category.Children[i].Window = Window
			end
		end
	else
		category.Window = Window
	end]]
	
	for i = 1, #self.OnLoadCalls[category][name].Calls do
		self.OnLoadCalls[category][name].Calls[1](Window.LeftWidgetsBG, Window.RightWidgetsBG)
		
		tremove(self.OnLoadCalls[category][name].Calls, 1)
	end
	
	return Window
end

function GUI2:LoadWindow(category, name, parent)
	
end

function GUI2:ShowWindow(category, name, parent) -- this needs writing to consider parent
	--load and initialize the window if needed
	
	-- hide all windows
	-- show the right one
	-- add hooks here?
	
	if parent then
		
	else
		for i = 1, #self.Categories do
			for j = 1, #self.Categories[i].Buttons do
				if (self.Categories[i].Name == category) and (self.Categories[i].Buttons[j].Name == name) then
					if (not self.Categories[i].Buttons[j].Window) then
						local Window = self:CreateWidgetWindow(category, name, parent)
						
						Window:SortWindow()
						
						self.Categories[i].Buttons[j].Window = Window
					end
					
					self.Categories[i].Buttons[j].Window:Show()
					
					-- children
					if self.Categories[i].Buttons[j].Children then
						for o = 1, #self.Categories[i].Buttons[j].Children do
							if (self.Categories[i].Buttons[j].Children[o].Name == name) then
								if self.Categories[i].Buttons[j].Children[o].Window then
									self.Categories[i].Buttons[j].Children[o].Window:Show()
								end
							elseif self.Categories[i].Buttons[j].Children[o].Window then
								self.Categories[i].Buttons[j].Children[o].Window:Hide()
							end
						end
						
						self.Categories[i].Buttons[j].ChildrenShown = true
					end
				else
					if self.Categories[i].Buttons[j].Window then
						self.Categories[i].Buttons[j].Window:Hide()
						
						-- if children
					end
				end
			end
		end
	end
	
	self:ScrollSelections()
	
	if 1 == 1 then return end
	
	for i = 1, #self.Categories do
		if (self.Categories[i].Name == category) then
			
			if parent then
				--self:CreateWidgetWindow(self.CategoryNames[category], name, parent)
			else
				for j = 1, #self.Categories[i].Buttons do
					if (self.Categories[i].Buttons[j].Name == name) then
						self.Categories[i].Buttons[j].Window:Show()
					elseif self.Categories[i].Buttons[j].Window then
						self.Categories[i].Buttons[j].Window:Hide()
						
						if self.Categories[i].Buttons[j].Children and self.Categories[i].Buttons[j].ChildrenShown then -- and self.Categories[i].ChildrenShown then
							for o = 1, #self.Categories[i].Buttons[j].Children do
								self.Categories[i].Buttons[j].Children[o]:Hide()
								
								self.Categories[i].Buttons[j].ChildrenShown = false
							end
						end
					end
				end
			end
			
			for j = 1, #self.Categories[i].Buttons do
				if (self.Categories[i].Buttons[j].Name == name) then
					local Category = self.Categories[i].Buttons[j]
					
					if parent then
						--[[for i = 1, #self.Categories[i].Buttons[j].Children do
							if (self.Categories[i].Buttons[j].Name == name) then
								self:CreateWidgetWindow(Category, name, parent)
							end
						end]]
						self:CreateWidgetWindow(self.CategoryNames[category], name, parent) -- uncomment
					end
					
					if (not Category.Loaded) then
						self:CreateWidgetWindow(Category, name, parent) -- uncomment
						
						-- Load window widgets
						if (self.OnLoadCalls[category] and self.OnLoadCalls[category][name]) then
							if parent then
								--self.OnLoadCalls[category][parent].Children[name].Calls
								
								for f = 1, #self.OnLoadCalls[category][parent].Children[name].Calls do
									self.OnLoadCalls[category][parent].Children[name].Calls[1](Category.Window.LeftWidgetsBG, Category.Window.RightWidgetsBG)
									
									tremove(self.OnLoadCalls[category][parent].Children[name].Calls, 1)
								end
								print('nothing happens')
							else
								--self.OnLoadCalls[category][name].Calls
								
								for f = 1, #self.OnLoadCalls[category][name].Calls do
									self.OnLoadCalls[category][name].Calls[1](Category.Window.LeftWidgetsBG, Category.Window.RightWidgetsBG)
									
									tremove(self.OnLoadCalls[category][name].Calls, 1)
								end
								
								if (not Category.Window.Sorted) then
									Category.Window:SortWindow()
									
									Category.Window.Sorted = true
								end
							end
						end
						
						Category.Loaded = true
					end
					
					-- children
					if Category.Children then
						-- show the children buttons, adjust scroll bar limits, then rescroll
						for o = 1, #Category.Children do
							if (Category.Children[o].Name == name) then
								if Category.Children[o].Window then
									Category.Children[o].Window:Show()
								end
							elseif Category.Children[o].Window then
								Category.Children[o].Window:Hide()
							end
						end
						
						Category.ChildrenShown = true
					else
						Category.Window:Show()
					end
				elseif self.Categories[i].Buttons[j].Window then
					self.Categories[i].Buttons[j].Window:Hide()
					
					if self.Categories[i].Buttons[j].Children and self.Categories[i].Buttons[j].ChildrenShown then -- and self.Categories[i].ChildrenShown then
						for o = 1, #self.Categories[i].Buttons[j].Children do
							self.Categories[i].Buttons[j].Children[o]:Hide()
							
							self.Categories[i].Buttons[j].ChildrenShown = false
						end
					end
				end
			end
		else
			for j = 1, #self.Categories[i].Buttons do
				if self.Categories[i].Buttons[j].Window then
					self.Categories[i].Buttons[j].Window:Hide()
				end
			end
		end 
	end
	
	self:ScrollSelections()
	
	--[[for WindowName, Window in pairs(self.Windows) do
		if (WindowName ~= name) then
			Window:Hide()
			
			if (Window.Button.Selected:GetAlpha() > 0) then
				Window.Button.FadeOut:Play()
			end
		else
			if (not Window.Sorted) then
				Window:SortWindow()
				
				Window.Sorted = true
			end
			
			Window.Button.FadeIn:Play()
			Window:Show()
		end
	end]]
	
	--CloseLastDropdown()
end

local WindowButtonOnEnter = function(self)
	self.Highlight:SetAlpha(MOUSEOVER_HIGHLIGHT_ALPHA)
end

local WindowButtonOnLeave = function(self)
	self.Highlight:SetAlpha(0)
end

local WindowButtonOnMouseUp = function(self)
	self.Texture:SetVertexColor(vUI:HexToRGB(Settings["ui-button-texture-color"]))
	
	GUI2:ShowWindow(self.Category, self.Name, self.Parent)
end

local WindowButtonOnMouseDown = function(self)
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
	Button.Selected:SetTexture(Assets:GetTexture("RenHorizonUp"))
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
	vUI:SetFontInfo(Button.Text, Settings["ui-widget-font"], Settings["ui-header-font-size"])
	Button.Text:SetText("|cFF" .. Settings["ui-button-font-color"] .. name .. "|r")
	
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
		
		Button.Text:SetPoint("LEFT", Button, 0, -1)
		Button.Text:SetJustifyH("LEFT")
		
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
		
		Button.Text:SetPoint("CENTER", Button, 0, -1)
		Button.Text:SetJustifyH("CENTER")
		
		tinsert(Category.Buttons, Button)
		
		self.TotalSelections = (self.TotalSelections or 0) + 1
	end
end

GUI2.OnLoadCalls = {}

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
		if (not self.OnLoadCalls[category][name].Children) then
			self.OnLoadCalls[category][name].Children = {}
		end
		
		self.OnLoadCalls[category][name].Children[arg1] = {Calls = {}}
		
		tinsert(self.OnLoadCalls[category][name].Children[arg1].Calls, arg2)
		
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
			--[[else
				Count = Count + 1
				
				if (Count >= self.Offset) and (Count <= self.Offset + MAX_WIDGETS_SHOWN - 1) then
					tinsert(self.SortScrollButtons, self.Categories[i].Buttons[j])
				end]]
			end
			
		--[[if (Count >= self.Offset) and (Count <= self.Offset + MAX_WIDGETS_SHOWN - 1) then
				if self.Categories[i].Buttons[j].ChildrenShown then
					for o = 1, #self.Categories[i].Buttons[j].Children do
						self.Categories[i].Buttons[j].Children[o]:Show()
						
						tinsert(self.SortScrollButtons, self.Categories[i].Buttons[j].Children[o])
					end
				else
					tinsert(self.SortScrollButtons, self.Categories[i].Buttons[j])
				end
			end]]
			
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
	
	self.ScrollBar:SetMinMaxValues(1, (self.NumShownButtons - MAX_WIDGETS_SHOWN) + 1)
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

GUI2_Toggle = function()
	GUI2:Toggle()
end

-- Spoof testing
GUI2:AddSettings("General", "Auras", function(left, right)
	left:CreateLine("Auras")
end)

GUI2:AddSettings("General", "Azerite", function(left, right)
	left:CreateLine("Azerite")
end)

GUI2:AddSettings("General", "Chat", function(left, right)
	left:CreateLine("Chat")
end)

GUI2:AddSettings("General", "Colors", function(left, right)
	left:CreateLine("Colors")
end)

GUI2:AddSettings("General", "Data Texts", function(left, right)
	left:CreateLine("Data Texts")
end)

GUI2:AddSettings("General", "Experience", function(left, right)
	left:CreateLine("Experience")
end)

GUI2:AddSettings("General", "General", function(left, right)
	left:CreateLine("General")
end)

GUI2:AddSettings("General", "Mini Map", function(left, right)
	left:CreateLine("Mini Map")
end)

GUI2:AddSettings("General", "Name Plates", function(left, right)
	left:CreateLine("Name Plates")
end)

GUI2:AddSettings("General", "Objectives", function(left, right)
	left:CreateLine("Objectives")
end)

GUI2:AddSettings("General", "Party", function(left, right)
	left:CreateLine("Party")
end)

GUI2:AddSettings("General", "Profiles", function(left, right)
	left:CreateLine("Profiles")
end)

GUI2:AddSettings("General", "Raid", function(left, right)
	left:CreateLine("Raid")
end)

GUI2:AddSettings("General", "Reputation", function(left, right)
	left:CreateHeader(Language["Enable"])
	left:CreateSwitch("reputation-enable", true, Language["Enable Reputation Module"], Language["Enable the vUI reputation module"], ReloadUI):RequiresReload(true)
	
	left:CreateHeader(Language["Styling"])
	left:CreateSwitch("reputation-display-progress", Settings["reputation-display-progress"], Language["Display Progress Value"], Language["Display your current progressinformation in the reputation bar"], UpdateDisplayProgress)
	left:CreateSwitch("reputation-display-percent", Settings["reputation-display-percent"], Language["Display Percent Value"], Language["Display your current percentinformation in the reputation bar"], UpdateDisplayPercent)
	left:CreateSwitch("reputation-show-tooltip", Settings["reputation-show-tooltip"], Language["Enable Tooltip"], Language["Display a tooltip when mousing over the reputation bar"])
	left:CreateSwitch("reputation-animate", Settings["reputation-animate"], Language["Animate Reputation Changes"], Language["Smoothly animate changes to the reputation bar"])
	
	right:CreateHeader(Language["Size"])
	right:CreateSlider("reputation-width", Settings["reputation-width"], 240, 400, 10, Language["Bar Width"], Language["Set the width of the reputation bar"], UpdateBarWidth)
	right:CreateSlider("reputation-height", Settings["reputation-height"], 6, 30, 1, Language["Bar Height"], Language["Set the height of the reputation bar"], UpdateBarHeight)
	
	right:CreateHeader(Language["Visibility"])
	right:CreateDropdown("reputation-progress-visibility", Settings["reputation-progress-visibility"], {[Language["Always Show"]] = "ALWAYS", [Language["Mouseover"]] = "MOUSEOVER"}, Language["Progress Text"], Language["Set when to display the progress information"], UpdateProgressVisibility)
	right:CreateDropdown("reputation-percent-visibility", Settings["reputation-percent-visibility"], {[Language["Always Show"]] = "ALWAYS", [Language["Mouseover"]] = "MOUSEOVER"}, Language["Percent Text"], Language["Set when to display the percent information"], UpdatePercentVisibility)
	
	left:CreateHeader("Mouseover")
	left:CreateSwitch("reputation-mouseover", Settings["reputation-mouseover"], Language["Display On Mouseover"], Language["Only display the reputation bar while mousing over it"], UpdateMouseover)
	left:CreateSlider("reputation-mouseover-opacity", Settings["reputation-mouseover-opacity"], 0, 100, 5, Language["Mouseover Opacity"], Language["Set the opacity of the reputation bar while not mousing over it"], UpdateMouseoverOpacity, nil, "%")
end)

GUI2:AddSettings("General", "Tooltips", function(left, right)
	left:CreateLine("Tooltips")
end)

GUI2:AddSettings("General", "Action Bars", function(left, right)
	left:CreateLine("Action Bars")
end)

GUI2:AddSettings("General", "Bar 1", "Action Bars", function(left, right)
	left:CreateLine("Action Bars - Bar 1")
end)

GUI2:AddSettings("General", "Bar 2", "Action Bars", function(left, right)
	left:CreateLine("Action Bars - Bar 2")
end)

GUI2:AddSettings("General", "Bar 3", "Action Bars", function(left, right)
	left:CreateLine("Action Bars - Bar 3")
end)

GUI2:AddSettings("General", "Unit Frames", function(left, right)
	left:CreateLine("Unit Frames")
end)

GUI2:AddSettings("General", "Player", "Unit Frames", function(left, right)
	left:CreateLine("Unit Frames - Player")
end)

GUI2:AddSettings("Info", "Credits", function(left, right)
	left:CreateHeader(Language["Scripting Help & Mentoring"])
	left:CreateMessage("Tukz, Foof, Eclipse, nightcracker, Elv, Smelly, Azilroka, AlleyKat, Zork, Simpy")
	
	left:CreateHeader("oUF")
	left:CreateLine("haste, lightspark, p3lim, Rainrider")
	
	left:CreateHeader("AceSerializer")
	left:CreateLine("Nevcairiel")
	
	right:CreateHeader("LibStub")
	right:CreateMessage("Kaelten, Cladhaire, ckknight, Mikk, Ammo, Nevcairiel, joshborke")
	
	right:CreateHeader("LibSharedMedia")
	right:CreateLine("Elkano, funkehdude")
	
	right:CreateHeader("LibDeflate")
	right:CreateLine("yoursafety")
	
	left:CreateHeader("vUI")
	left:CreateLine("Hydra")
end)
--[[
GUI2:AddSettings("Dev", "Tools", function(left, right)
	left:CreateLine("N/A")
end)

GUI2:AddSettings("Dev", "Info", function(left, right)
	left:CreateLine("N/A")
end)
]]
GUI2:AddSettings("Info", "Supporters", function(left, right)
	left:CreateSupportHeader(Language["Hall of Legends"])
	left:CreateDoubleLine("Innie", "Brightsides")
	left:CreateDoubleLine("Erthelmi", "Gene")
	left:CreateDoubleLine("JDoubleU00", "Duds")
	left:CreateDoubleLine("Shazlen", "Shawna W.")
	
	right:CreateHeader("Patrons")
	right:CreateDoubleLine("|cFFFF8000Erieeroot|r", "|cFFFF8000SwoopCrown|r")
	right:CreateDoubleLine("|cFFFF8000Quivera|r", "|cFFA335EESmelly|r")
	right:CreateDoubleLine("|cFFA335EETrix|r", "|cFFA335EEwolimazo|r")
	right:CreateDoubleLine("|cFFA335EEAri|r", "|cFFA335EEMrPoundsign|r")
	right:CreateDoubleLine("|cFF0070DDMisse Far|r", "|cFF1EFF00Ryex|r")
	right:CreateDoubleLine("|cFF1EFF00JDoubleU00|r", "|cFF1EFF00sylvester|r")
	right:CreateDoubleLine("|cFF1EFF00Maski|r", "|cFF1EFF00Innie|r")
	right:CreateDoubleLine("|cFF1EFF00Mcbooze|r", "|cFF1EFF00Aaron B.|r")
	right:CreateDoubleLine("|cFF1EFF00Chris B.|r", "|cFF1EFF00Suppabad|r")
	right:CreateDoubleLine("|cFF1EFF00Steve R.|r", "|cFF1EFF00Angel|r")
	right:CreateDoubleLine("|cFF1EFF00FrankPatten|r", "|cFF1EFF00Dellamaik|r")
	right:CreateDoubleLine("|cFF1EFF00stko|r", "madmaddy")
	right:CreateLine("Akab00m")
	
	left:CreateFooter()
	left:CreateMessage("Thank you to all of these amazing people who have supported the development of this project!")
end)

--print("|cFFFFEB3B|Hcommand:/vui t|h[Toggle Test GUI]|h|r")
print("|cFFFFEB3B|Hcommand:/run GUI2_Toggle()|h[Toggle Test GUI]|h|r")