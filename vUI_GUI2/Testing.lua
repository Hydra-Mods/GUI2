if (not vUIGlobal) then
	return
end

local vUI, GUI, Language, Assets, Settings = vUIGlobal:get()
local GUI2 = vUI:GetPlugin("vUI_GUI2")

-- Spoof testing, recreate widgets but with no callbacks just to test the layout and functionality

GUI2:AddSettings("General", "Auras", function(left, right)
	left:CreateHeader(Language["Enable"])
	left:CreateSwitch("auras-enable", Settings["auras-enable"], Language["Enable Auras Module"], Language["Enable the vUI auras module"])
	
	right:CreateHeader(Language["Styling"])
	right:CreateSlider("auras-size", Settings["auras-size"], 20, 40, 1, Language["Size"], Language["Set the size of auras"])
	right:CreateSlider("auras-spacing", Settings["auras-spacing"], 0, 10, 1, Language["Spacing"], Language["Set the spacing between auras"])
	right:CreateSlider("auras-row-spacing", Settings["auras-row-spacing"], 0, 30, 1, Language["Row Spacing"], Language["Set the vertical spacing between aura rows"])
	right:CreateSlider("auras-per-row", Settings["auras-per-row"], 8, 16, 1, Language["Display Per Row"], Language["Set the number of auras per row"])
end)

GUI2:AddSettings("General", "Azerite", function(left, right)
	left:CreateHeader(Language["Enable"])
	left:CreateSwitch("azerite-enable", true, Language["Enable Azerite Module"], Language["Enable the vUI azerite module"])
	
	left:CreateHeader(Language["Styling"])
	left:CreateSwitch("azerite-display-progress", Settings["azerite-display-progress"], Language["Display Progress Value"], Language["Display your current progress information in the azerite bar"])
	left:CreateSwitch("azerite-display-percent", Settings["azerite-display-percent"], Language["Display Percent Value"], Language["Display your current percent information in the azerite bar"])
	left:CreateSwitch("azerite-show-tooltip", Settings["azerite-show-tooltip"], Language["Enable Tooltip"], Language["Display a tooltip when mousing over the azerite bar"])
	left:CreateSwitch("azerite-animate", Settings["azerite-animate"], Language["Animate Azerite Changes"], Language["Smoothly animate changes to the azerite bar"])
	
	right:CreateHeader(Language["Size"])
	right:CreateSlider("azerite-width", Settings["azerite-width"], 240, 400, 10, Language["Bar Width"], Language["Set the width of the azerite bar"])
	right:CreateSlider("azerite-height", Settings["azerite-height"], 6, 30, 1, Language["Bar Height"], Language["Set the height of the azerite bar"])
	
	right:CreateHeader(Language["Visibility"])
	right:CreateDropdown("azerite-progress-visibility", Settings["azerite-progress-visibility"], {[Language["Always Show"]] = "ALWAYS", [Language["Mouseover"]] = "MOUSEOVER"}, Language["Progress Text"], Language["Set when to display the progress information"])
	right:CreateDropdown("azerite-percent-visibility", Settings["azerite-percent-visibility"], {[Language["Always Show"]] = "ALWAYS", [Language["Mouseover"]] = "MOUSEOVER"}, Language["Percent Text"], Language["Set when to display the percent information"])
	
	left:CreateHeader("Mouseover")
	left:CreateSwitch("azerite-mouseover", Settings["azerite-mouseover"], Language["Display On Mouseover"], Language["Only display the azerite bar while mousing over it"])
	left:CreateSlider("azerite-mouseover-opacity", Settings["azerite-mouseover-opacity"], 0, 100, 5, Language["Mouseover Opacity"], Language["Set the opacity of the azerite bar while not mousing over it"], nil, nil, "%")
end)

GUI2:AddSettings("General", "Chat", function(left, right)
	left:CreateHeader(Language["Enable"])
	left:CreateSwitch("chat-enable", Settings["chat-enable"], Language["Enable Chat Module"], Language["Enable the vUI chat module"])
	
	left:CreateHeader(Language["General"])
	left:CreateSlider("chat-frame-width", Settings["chat-frame-width"], 300, 650, 1, Language["Chat Width"], Language["Set the width of the chat frame"])
	left:CreateSlider("chat-frame-height", Settings["chat-frame-height"], 40, 350, 1, Language["Chat Height"], Language["Set the height of the chat frame"])
	left:CreateSlider("chat-bg-opacity", Settings["chat-bg-opacity"], 0, 100, 5, Language["Background Opacity"], Language["Set the opacity of the chat background"], nil, nil, "%")
	left:CreateSlider("chat-fade-time", Settings["chat-enable-fading"], 0, 60, 5, Language["Set Fade Time"], Language["Set the duration to display text before fading out"], nil, nil, "s")
	left:CreateSwitch("chat-enable-fading", Settings["chat-enable-fading"], Language["Enable Text Fading"], Language["Set the text to fade after the set amount of time"])
	left:CreateSwitch("chat-link-tooltip", Settings["chat-link-tooltip"], Language["Show Link Tooltips"], Language["Display a tooltip when hovering over links in chat"])
	
	right:CreateHeader(Language["Install"])
	right:CreateButton(Language["Install"], Language["Install Chat Defaults"], Language["Set default channels and settings related to chat"])
	
	left:CreateHeader(Language["Links"])
	left:CreateSwitch("chat-enable-url-links", Settings["chat-enable-url-links"], Language["Enable URL Links"], Language["Enable URL links in the chat frame"])
	left:CreateSwitch("chat-enable-discord-links", Settings["chat-enable-discord-links"], Language["Enable Discord Links"], Language["Enable Discord links in the chat frame"])
	left:CreateSwitch("chat-enable-email-links", Settings["chat-enable-email-links"], Language["Enable Email Links"], Language["Enable email links in the chat frame"])
	left:CreateSwitch("chat-enable-friend-links", Settings["chat-enable-friend-links"], Language["Enable Friend Tag Links"], Language["Enable friend tag links in the chat frame"])
	
	right:CreateHeader(Language["Chat Frame Font"])
	right:CreateDropdown("chat-font", Settings["chat-font"], Assets:GetFontList(), Language["Font"], "Set the font of the chat frame", nil, "Font")
	right:CreateSlider("chat-font-size", Settings["chat-font-size"], 8, 32, 1, "Font Size", "Set the font size of the chat frame")
	right:CreateDropdown("chat-font-flags", Settings["chat-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], "Set the font flags of the chat frame")
	
	right:CreateHeader(Language["Tab Font"])
	right:CreateDropdown("chat-tab-font", Settings["chat-tab-font"], Assets:GetFontList(), Language["Font"], "Set the font of the chat frame tabs", nil, "Font")
	right:CreateSlider("chat-tab-font-size", Settings["chat-tab-font-size"], 8, 32, 1, "Font Size", "Set the font size of the chat frame tabs")
	right:CreateDropdown("chat-tab-font-flags", Settings["chat-tab-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], "Set the font flags of the chat frame tabs")
	right:CreateColorSelection("chat-tab-font-color", Settings["chat-tab-font-color"], Language["Font Color"], "Set the color of the chat frame tabs")
	right:CreateColorSelection("chat-tab-font-color-mouseover", Settings["chat-tab-font-color-mouseover"], Language["Font Color Mouseover"], "Set the color of the chat frame tab while mousing over it")
end)

GUI2:AddSettings("General", "Colors", function(left, right)
	left:CreateLine("Colors")
end)

GUI2:AddSettings("General", "Data Texts", function(left, right)
	left:CreateHeader(Language["Chat Frame Texts"])
	left:CreateDropdown("data-text-chat-left", Settings["data-text-chat-left"], {}, Language["Set Left Text"], Language["Set the information to be displayed in the left data text anchor"])
	left:CreateDropdown("data-text-chat-middle", Settings["data-text-chat-middle"], {}, Language["Set Middle Text"], Language["Set the information to be displayed in the middle data text anchor"])
	left:CreateDropdown("data-text-chat-right", Settings["data-text-chat-right"], {}, Language["Set Right Text"], Language["Set the information to be displayed in the right data text anchor"])
	
	left:CreateHeader(Language["Mini Map Texts"])
	left:CreateDropdown("data-text-minimap-top", Settings["data-text-minimap-top"], {}, Language["Set Top Text"], Language["Set the information to be displayed in the top mini map data text anchor"])
	left:CreateDropdown("data-text-minimap-bottom", Settings["data-text-minimap-bottom"], {}, Language["Set Bottom Text"], Language["Set the information to be displayed in the bottom mini map data text anchor"])
	
	right:CreateHeader(Language["Font"])
	right:CreateDropdown("data-text-font", Settings["data-text-font"], Assets:GetFontList(), Language["Font"], Language["Set the font of the data texts"], nil, "Font")
	right:CreateSlider("data-text-font-size", Settings["data-text-font-size"], 8, 32, 1, Language["Font Size"], Language["Set the font size of the data texts"])
	right:CreateDropdown("data-text-font-flags", Settings["data-text-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], Language["Set the font flags of the data texts"])
	
	right:CreateHeader(Language["Colors"])
	right:CreateColorSelection("data-text-label-color", Settings["data-text-label-color"], Language["Label Color"], Language["Set the text color of data text labels"])
	right:CreateColorSelection("data-text-value-color", Settings["data-text-value-color"], Language["Value Color"], Language["Set the text color of data text values"])
	
	right:CreateHeader(Language["Styling"])
	right:CreateSwitch("data-text-enable-tooltips", Settings["data-text-enable-tooltips"], Language["Enable Tooltips"], Language["Display tooltip information when hovering over data texts"])
	right:CreateSwitch("data-text-hover-tooltips", Settings["data-text-hover-tooltips"], Language["Hover Tooltips"], Language["Display tooltip information directly by the data text instead of at the default tooltip location"])
	right:CreateSwitch("data-text-24-hour", Settings["data-text-24-hour"], Language["Enable 24 Hour Time"], Language["Display time in a 24 hour format"])
	
	right:CreateHeader(Language["Gold"])
	right:CreateButton(Language["Reset"], Language["Reset Gold"], Language["Reset stored information for each characters gold"])
end)

GUI2:AddSettings("General", "Experience", function(left, right)
	left:CreateHeader(Language["Enable"])
	left:CreateSwitch("experience-enable", Settings["experience-enable"], Language["Enable Experience Module"], Language["Enable the vUI experience module"])
	
	left:CreateHeader(Language["Styling"])
	left:CreateSwitch("experience-display-level", Settings["experience-display-level"], Language["Display Level"], Language["Display your current level in the experience bar"])
	left:CreateSwitch("experience-display-progress", Settings["experience-display-progress"], Language["Display Progress Value"], Language["Display your current progressinformation in the experience bar"])
	left:CreateSwitch("experience-display-percent", Settings["experience-display-percent"], Language["Display Percent Value"], Language["Display your current percentinformation in the experience bar"])
	left:CreateSwitch("experience-display-rested-value", Settings["experience-display-rested-value"], Language["Display Rested Value"], Language["Display your current restedvalue on the experience bar"])
	left:CreateSwitch("experience-show-tooltip", Settings["experience-show-tooltip"], Language["Enable Tooltip"], Language["Display a tooltip when mousing over the experience bar"])
	left:CreateSwitch("experience-animate", Settings["experience-animate"], Language["Animate Experience Changes"], Language["Smoothly animate changes to the experience bar"])
	
	right:CreateHeader(Language["Size"])
	right:CreateSlider("experience-width", Settings["experience-width"], 240, 400, 10, Language["Bar Width"], Language["Set the width of the experience bar"])
	right:CreateSlider("experience-height", Settings["experience-height"], 6, 30, 1, Language["Bar Height"], Language["Set the height of the experience bar"])
	
	right:CreateHeader(Language["Colors"])
	right:CreateColorSelection("experience-bar-color", Settings["experience-bar-color"], Language["Experience Color"], Language["Set the color of the experience bar"])
	right:CreateColorSelection("experience-rested-color", Settings["experience-rested-color"], Language["Rested Color"], Language["Set the color of the rested bar"])
	
	right:CreateHeader(Language["Visibility"])
	right:CreateDropdown("experience-progress-visibility", Settings["experience-progress-visibility"], {[Language["Always Show"]] = "ALWAYS", [Language["Mouseover"]] = "MOUSEOVER"}, Language["Progress Text"], Language["Set when to display the progress information"])
	right:CreateDropdown("experience-percent-visibility", Settings["experience-percent-visibility"], {[Language["Always Show"]] = "ALWAYS", [Language["Mouseover"]] = "MOUSEOVER"}, Language["Percent Text"], Language["Set when to display the percent information"])
	
	left:CreateHeader("Mouseover")
	left:CreateSwitch("experience-mouseover", Settings["experience-mouseover"], Language["Display On Mouseover"], Language["Only display the experience bar while mousing over it"])
	left:CreateSlider("experience-mouseover-opacity", Settings["experience-mouseover-opacity"], 0, 100, 5, Language["Mouseover Opacity"], Language["Set the opacity of the experience bar while not mousing over it"], nil, nil, "%")
end)

GUI2:AddSettings("General", "General", function(left, right)
	left:CreateLine("General")
end)

GUI2:AddSettings("General", "Mini Map", function(left, right)
	left:CreateHeader(Language["Enable"])
	left:CreateSwitch("minimap-enable", Settings["minimap-enable"], Language["Enable Mini Map Module"], Language["Enable the vUI mini map module"])
	
	left:CreateHeader(Language["Styling"])
	left:CreateSlider("minimap-size", Settings["minimap-size"], 100, 250, 10, Language["Mini Map Size"], Language["Set the size of the mini map"])
	left:CreateSwitch("minimap-show-top", Settings["minimap-show-top"], Language["Enable Top Bar"], Language["Enable the data text bar on top of the mini map"])
	left:CreateSwitch("minimap-show-bottom", Settings["minimap-show-bottom"], Language["Enable Bottom Bar"], Language["Enable the data text bar on the bottom of the mini map"])
	left:CreateSwitch("minimap-show-tracking", Settings["minimap-show-tracking"], Language["Enable Tracking"], Language["Enable the tracking button in the top left of the mini map"])
end)

--[[GUI2:AddSettings("General", "Mini Map", function(left, right)
	right:CreateHeader(Language["Minimap Buttons"])
	right:CreateSwitch("minimap-buttons-enable", Settings["minimap-buttons-enable"], "Enable Minimap Button Bar", "")
	right:CreateSlider("minimap-buttons-size", Settings["minimap-buttons-size"], 16, 44, 1, "Button Size", "")
	right:CreateSlider("minimap-buttons-spacing", Settings["minimap-buttons-spacing"], 1, 5, 1, "Button Spacing", "")
	right:CreateSlider("minimap-buttons-perrow", Settings["minimap-buttons-perrow"], 1, 20, 1, "Per Row", "")
end)]]

GUI2:AddSettings("General", "Name Plates", function(left, right)
	left:CreateHeader(Language["Enable"])
	left:CreateSwitch("nameplates-enable", Settings["nameplates-enable"], Language["Enable Name Plates"], Language["Enable the vUI name plates module"])
	
	left:CreateHeader(Language["Font"])
	left:CreateDropdown("nameplates-font", Settings["nameplates-font"], Assets:GetFontList(), Language["Font"], Language["Set the font of the name plates"], nil, "Font")
	left:CreateSlider("nameplates-font-size", Settings["nameplates-font-size"], 8, 32, 1, Language["Font Size"], Language["Set the font size of the name plates"])
	left:CreateDropdown("nameplates-font-flags", Settings["nameplates-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], Language["Set the font flags of the name plates"])
	
	left:CreateHeader(Language["Health"])
	left:CreateSlider("nameplates-width", Settings["nameplates-width"], 60, 220, 1, "Set Width", "Set the width of name plates")
	left:CreateSlider("nameplates-height", Settings["nameplates-height"], 4, 50, 1, "Set Height", "Set the height of name plates")
	left:CreateDropdown("nameplates-health-color", Settings["nameplates-health-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Custom"]] = "CUSTOM"}, Language["Health Bar Color"], Language["Set the color of the health bar"])
	left:CreateSwitch("nameplates-health-smooth", Settings["nameplates-health-smooth"], Language["Enable Smooth Progress"], Language["Set the health bar to animate changes smoothly"])
	
	left:CreateHeader(Language["Debuffs"])
	left:CreateSwitch("nameplates-display-debuffs", Settings["nameplates-display-debuffs"], Language["Enable Debuffs"], Language["Display your debuffs above enemy name plates"])
	left:CreateSwitch("nameplates-only-player-debuffs", Settings["nameplates-only-player-debuffs"], Language["Only Display Player Debuffs"], Language["If enabled, only your own debuffs will be displayed"])
	
	right:CreateHeader(Language["Information"])
	right:CreateInput("nameplates-top-text", Settings["nameplates-top-text"], Language["Top Text"], "")
	right:CreateInput("nameplates-topleft-text", Settings["nameplates-topleft-text"], Language["Top Left Text"], "")
	right:CreateInput("nameplates-topright-text", Settings["nameplates-topright-text"], Language["Top Right Text"], "")
	right:CreateInput("nameplates-bottom-text", Settings["nameplates-bottom-text"], Language["Bottom Text"], "")
	right:CreateInput("nameplates-bottomleft-text", Settings["nameplates-bottomleft-text"], Language["Bottom Left Text"], "")
	right:CreateInput("nameplates-bottomright-text", Settings["nameplates-bottomright-text"], Language["Bottom Right Text"], "")
	
	right:CreateHeader(Language["Casting Bar"])
	right:CreateSwitch("nameplates-enable-castbar", Settings["nameplates-enable-castbar"], Language["Enable Casting Bar"], Language["Enable the casting bar the name plates"])
	right:CreateSlider("nameplates-castbar-height", Settings["nameplates-castbar-height"], 3, 28, 1, Language["Set Height"], Language["Set the height of name plate casting bars"])
	
	right:CreateHeader(Language["Target Indicator"])
	right:CreateSwitch("nameplates-enable-target-indicator", Settings["nameplates-enable-target-indicator"], Language["Enable Target Indicator"], Language["Display an indication on the targetted unit name plate"])
	right:CreateDropdown("nameplates-target-indicator-size", Settings["nameplates-target-indicator-size"], {[Language["Small"]] = "SMALL", [Language["Large"]] = "LARGE", [Language["Huge"]] = "HUGE"}, Language["Indicator Size"], Language["Select the size of the target indicator"])
end)

GUI2:AddSettings("General", "Objectives", function(left, right)
	left:CreateHeader(Language["Enable"])
	left:CreateSwitch("tracker-enable", Settings["tracker-enable"], Language["Enable Tracker Module"], Language["Enable the vUI objective tracker module"])
	
	left:CreateHeader(Language["Styling"])
	left:CreateSwitch("tracker-enable-backdrop", Settings["tracker-enable-backdrop"], Language["Enable Backdrop"], Language["Enable a backdrop for the objective tracker"])
	left:CreateSlider("tracker-backdrop-opacity", Settings["tracker-backdrop-opacity"], 0, 100, 5, Language["Backdrop Opacity"], Language["Set the backdrop opacity of the objective tracker"])
	left:CreateSlider("tracker-height", Settings["tracker-height"], 100, 500, 1, Language["Set Height"], Language["Set the height of the objective tracker"])
	
	left:CreateHeader(Language["Colors"])
	left:CreateColorSelection("tracker-color-normal", Settings["tracker-color-normal"], Language["Line Normal"], "")
	left:CreateColorSelection("tracker-color-normal-highlight", Settings["tracker-color-normal-highlight"], Language["Line Highlight"], "")
	left:CreateColorSelection("tracker-color-header", Settings["tracker-color-header"], Language["Header"], "")
	left:CreateColorSelection("tracker-color-header-highlight", Settings["tracker-color-header-highlight"], Language["Header Highlight"], "")
	left:CreateColorSelection("tracker-color-failed", Settings["tracker-color-failed"], Language["Failed"], "")
	left:CreateColorSelection("tracker-color-failed-highlight", Settings["tracker-color-failed-highlight"], Language["Failed Highlight"], "")
	left:CreateColorSelection("tracker-color-timeleft", Settings["tracker-color-timeleft"], Language["Time Left"], "")
	left:CreateColorSelection("tracker-color-timeleft-highlight", Settings["tracker-color-timeleft-highlight"], Language["Time Left Highlight"], "")
	left:CreateColorSelection("tracker-color-complete", Settings["tracker-color-complete"], Language["Complete"], "")
	
	right:CreateHeader(Language["Category Font"])
	right:CreateDropdown("tracker-module-font", Settings["tracker-module-font"], Assets:GetFontList(), Language["Font"], Language["Set the font of the objective tracker lines"], nil, "Font")
	right:CreateSlider("tracker-module-font-size", Settings["tracker-module-font-size"], 8, 18, 1, Language["Font Size"], Language["Set the font size of the objective tracker lines"])
	right:CreateDropdown("tracker-module-font-flags", Settings["tracker-module-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], Language["Set the font flags of the objective tracker lines"])
	right:CreateColorSelection("tracker-module-font-color", Settings["tracker-module-font-color"], Language["Font Color"], "")
	
	right:CreateHeader(Language["Header Font"])
	right:CreateDropdown("tracker-header-font", Settings["tracker-header-font"], Assets:GetFontList(), Language["Font"], Language["Set the font of the objective tracker header lines"], nil, "Font")
	right:CreateSlider("tracker-header-font-size", Settings["tracker-header-font-size"], 8, 18, 1, Language["Font Size"], Language["Set the font size of the objective tracker header lines"])
	right:CreateDropdown("tracker-header-font-flags", Settings["tracker-header-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], Language["Set the font flags of the objective tracker header lines"])
	
	right:CreateHeader(Language["Line Font"])
	right:CreateDropdown("tracker-font", Settings["tracker-font"], Assets:GetFontList(), Language["Font"], Language["Set the font of the objective tracker lines"], nil, "Font")
	right:CreateSlider("tracker-font-size", Settings["tracker-font-size"], 8, 18, 1, Language["Font Size"], Language["Set the font size of the objective tracker lines"])
	right:CreateDropdown("tracker-font-flags", Settings["tracker-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], Language["Set the font flags of the objective tracker lines"])
end)

GUI2:AddSettings("General", "Party", function(left, right)
	left:CreateHeader(Language["Enable"])
	left:CreateSwitch("party-enable", Settings["party-enable"], Language["Enable Party Module"], Language["Enable the party frames module"])
	left:CreateSwitch("party-pets-enable", Settings["party-pets-enable"], Language["Enable Party Pet Frames"], Language["Enable the party pet frames module"])
	
	left:CreateHeader(Language["Party Size"])
	left:CreateSlider("party-width", Settings["party-width"], 40, 200, 1, Language["Width"], Language["Set the width of the party unit frame"])
	
	left:CreateHeader(Language["Health"])
	left:CreateSlider("party-health-height", Settings["party-health-height"], 12, 60, 1, Language["Health Height"], Language["Set the height of party health bars"])
	left:CreateDropdown("party-health-color", Settings["party-health-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Custom"]] = "CUSTOM"}, Language["Health Bar Color"], Language["Set the color of the health bar"])
	left:CreateDropdown("party-health-orientation", Settings["party-health-orientation"], {[Language["Horizontal"]] = "HORIZONTAL", [Language["Vertical"]] = "VERTICAL"}, Language["Fill Orientation"], Language["Set the fill orientation of the health bar"])
	left:CreateSwitch("party-health-reverse", Settings["party-health-reverse"], Language["Reverse Health Fill"], Language["Reverse the fill of the health bar"])
	
	left:CreateHeader(Language["Power"])
	left:CreateSlider("party-power-height", Settings["party-power-height"], 2, 30, 1, Language["Power Height"], Language["Set the height of party power bars"])
	left:CreateDropdown("party-power-color", Settings["party-power-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Power Type"]] = "POWER"}, Language["Power Bar Color"], Language["Set the color of the power bar"])
	left:CreateSwitch("party-power-reverse", Settings["party-power-reverse"], Language["Reverse Power Fill"], Language["Reverse the fill of the power bar"])
	
	right:CreateHeader(Language["Styling"])
	right:CreateSwitch("party-show-debuffs", Settings["party-show-debuffs"], Language["Enable Debuffs"], Language["Display debuffs on party members"])
	right:CreateSwitch("party-show-role", Settings["party-show-role"], Language["Enable Role Icons"], Language["Display role icons on party members"])
	
	right:CreateHeader(Language["Range Opacity"])
	right:CreateSlider("party-in-range", Settings["party-in-range"], 0, 100, 5, Language["In Range"], Language["Set the opacity of party members within range of you"])
	right:CreateSlider("party-out-of-range", Settings["party-out-of-range"], 0, 100, 5, Language["Out of Range"], Language["Set the opacity of party members out of your range"])
	
	right:CreateHeader(Language["Attributes"])
	right:CreateSlider("party-x-offset", Settings["party-x-offset"], -10, 10, 1, Language["X Offset"], Language["Set the x offset of party units from eachother"])
	right:CreateSlider("party-y-offset", Settings["party-y-offset"], -10, 10, 1, Language["Y Offset"], Language["Set the y offset of party units from eachother"])
	right:CreateDropdown("party-point", Settings["party-point"], {[Language["Left"]] = "LEFT", [Language["Right"]] = "RIGHT", [Language["Top"]] = "TOP", [Language["Bottom"]] = "BOTTOM"}, Language["Anchor Point"], Language["Set where new party members will anchor to previous ones"])
	
	right:CreateHeader(Language["Party Pets Size"])
	right:CreateSlider("party-pets-width", Settings["party-pets-width"], 40, 200, 1, Language["Width"], Language["Set the width of party pet unit frames"])
end)

GUI2:AddSettings("General", "Profiles", function(left, right)
	--left:DisableScrolling()
	
	left:CreateHeader(Language["Profiles"])
	left:CreateDropdown("ui-profile", vUI:GetActiveProfileName(), vUI:GetProfileList(), Language["Select Profile"], Language["Select a profile to load"], UpdateActiveProfile)
	--left:CreateButton("Apply", "Apply Current Profile", "", UpdateActiveProfile)
	
	left:CreateHeader(Language["Modify"])
	left:CreateInput("profile-key", vUI:GetDefaultProfileKey(), Language["Create New Profile"], Language["Create a new profile to store a different collection of settings"], CreateProfile):DisableSaving()
	left:CreateInput("profile-delete", vUI:GetDefaultProfileKey(), Language["Delete Profile"], Language["Delete a profile"], DeleteProfile):DisableSaving()
	left:CreateInput("profile-rename", "", Language["Rename Profile"], Language["Rename the currently selected profile"], RenameProfile):DisableSaving()
	--left:CreateInput("profile-copy", "", Language["Copy From"], Language["Copy the settings from another profile"], CopyProfile):DisableSaving()
	left:CreateDropdown("profile-copy", vUI:GetActiveProfileName(), vUI:GetProfileList(), Language["Copy From"], Language["Copy the settings from another profile"], CopyProfile)
	
	left:CreateHeader(Language["Manage"])
	left:CreateButton(Language["Restore"], Language["Restore To Default"], Language["Restore the currently selected profile to default settings"], RestoreToDefault):RequiresReload(true)
	left:CreateButton(Language["Delete"], Language["Delete Unused Profiles"], Language["Delete any profiles that are not currently in use by any characters"], DeleteUnused)
	
	left:CreateHeader(Language["Sharing is caring"])
	left:CreateButton(Language["Import"], Language["Import A Profile"], Language["Import a profile using an import string"], ShowImportWindow)
	left:CreateButton(Language["Export"], Language["Export Current Profile"], Language["Export the currently active profile as a string that can be shared with others"], ShowExportWindow)
end)

GUI2:AddSettings("General", "Raid", function(left, right)
	left:CreateHeader(Language["Enable"])
	left:CreateSwitch("raid-enable", Settings["raid-enable"], Language["Enable Raid Module"], Language["Enable the raid frames module"])
	
	left:CreateHeader(Language["Raid Size"])
	left:CreateSlider("raid-width", Settings["raid-width"], 40, 200, 1, Language["Width"], Language["Set the width of the raid frames"], nil, nil)
	
	left:CreateHeader(Language["Health"])
	left:CreateSlider("raid-health-height", Settings["raid-health-height"], 12, 60, 1, Language["Health Height"], Language["Set the height of raid health bars"])
	left:CreateDropdown("raid-health-color", Settings["raid-health-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Custom"]] = "CUSTOM"}, Language["Health Bar Color"], Language["Set the color of the health bar"])
	left:CreateDropdown("raid-health-orientation", Settings["raid-health-orientation"], {[Language["Horizontal"]] = "HORIZONTAL", [Language["Vertical"]] = "VERTICAL"}, Language["Fill Orientation"], Language["Set the fill orientation of the health bar"])
	left:CreateSwitch("raid-health-reverse", Settings["raid-health-reverse"], Language["Reverse Health Fill"], Language["Reverse the fill of the health bar"])
	
	left:CreateHeader(Language["Power"])
	left:CreateSlider("raid-power-height", Settings["raid-power-height"], 2, 30, 1, Language["Power Height"], Language["Set the height of raid power bars"])
	left:CreateDropdown("raid-power-color", Settings["raid-power-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Power Type"]] = "POWER"}, Language["Power Bar Color"], Language["Set the color of the power bar"])
	left:CreateSwitch("raid-power-reverse", Settings["raid-power-reverse"], Language["Reverse Power Fill"], Language["Reverse the fill of the power bar"])
	
	right:CreateHeader(Language["Range Opacity"])
	right:CreateSlider("raid-in-range", Settings["raid-in-range"], 0, 100, 5, Language["In Range"], Language["Set the opacity of raid members within range of you"])
	right:CreateSlider("raid-out-of-range", Settings["raid-out-of-range"], 0, 100, 5, Language["Out of Range"], Language["Set the opacity of raid members out of your range"])
	
	right:CreateHeader(Language["Attributes"])
	right:CreateSlider("raid-x-offset", Settings["raid-x-offset"], -10, 10, 1, Language["X Offset"], Language["Set the x offset of raid units from eachother"])
	right:CreateSlider("raid-y-offset", Settings["raid-y-offset"], -10, 10, 1, Language["Y Offset"], Language["Set the y offset of raid units from eachother"])
	right:CreateSlider("raid-units-per-column", Settings["raid-units-per-column"], 1, 40, 1, Language["Units Per Column"], Language["Set the maximum number of units per column"])
	right:CreateSlider("raid-max-columns", Settings["raid-max-columns"], 1, 40, 1, Language["Max Columns"], Language["Set the maximum number of visible columns of raid units"])
	right:CreateSlider("raid-column-spacing", Settings["raid-column-spacing"], -10, 10, 1, Language["Column Spacing"], Language["Set the spacing between columns of raid units"])
	right:CreateDropdown("raid-sorting-method", Settings["raid-sorting-method"], {[Language["Group"]] = "GROUP", [Language["Name"]] = "NAME", [Language["Class"]] = "CLASS", [Language["Role"]] = "ROLE", [Language["Main Tank"]] = "MTMA"}, Language["Sorting Method"], Language["Set how the raid units are sorted"])
	right:CreateDropdown("raid-point", Settings["raid-point"], {[Language["Left"]] = "LEFT", [Language["Right"]] = "RIGHT", [Language["Top"]] = "TOP", [Language["Bottom"]] = "BOTTOM"}, Language["Anchor Point"], Language["Set where new raid frames will connect to previous ones"])
	right:CreateDropdown("raid-column-anchor", Settings["raid-column-anchor"], {[Language["Left"]] = "LEFT", [Language["Right"]] = "RIGHT", [Language["Top"]] = "TOP", [Language["Bottom"]] = "BOTTOM"}, Language["New Column Anchor"], Language["Set where new columns should anchor to"])
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
	left:CreateHeader(Language["Enable"])
	left:CreateSwitch("tooltips-enable", Settings["tooltips-enable"], Language["Enable Tooltips Module"], Language["Enable the vUI tooltips module"])
	
	left:CreateHeader(Language["Styling"])
	left:CreateSlider("tooltips-health-bar-height", Settings["tooltips-health-bar-height"], 2, 30, 1, Language["Health Bar Height"], Language["Set the height of the tooltip health bar"])
	left:CreateSwitch("tooltips-show-health-text", Settings["tooltips-show-health-text"], Language["Display Health Text"], Language["Dislay health information on the tooltip health bar"])
	left:CreateSwitch("tooltips-show-target", Settings["tooltips-show-target"], Language["Display Target"], Language["Dislay the units current target"])
	left:CreateSwitch("tooltips-on-cursor", Settings["tooltips-on-cursor"], Language["Tooltip On Cursor"], Language["Anchor the tooltip to the mouse cursor"])
	left:CreateSwitch("tooltips-show-id", Settings["tooltips-show-id"], Language["Display ID's"], Language["Dislay item and spell ID's in the tooltip"])
	
	left:CreateHeader(Language["Font"])
	left:CreateDropdown("tooltips-font", Settings["tooltips-font"], Assets:GetFontList(), Language["Font"], Language["Set the font of the tooltip text"], nil, "Font")
	left:CreateSlider("tooltips-font-size", Settings["tooltips-font-size"], 8, 32, 1, Language["Font Size"], Language["Set the font size of the tooltip text"])
	left:CreateDropdown("tooltips-font-flags", Settings["tooltips-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], Language["Set the font flags of the tooltip text"])
	
	right:CreateHeader(Language["Information"])
	right:CreateSwitch("tooltips-display-realm", Settings["tooltips-display-realm"], Language["Display Realm"], Language["Display character realms"])
	right:CreateSwitch("tooltips-display-title", Settings["tooltips-display-title"], Language["Display Title"], Language["Display character titles"])
	right:CreateSwitch("tooltips-display-rank", Settings["tooltips-display-rank"], Language["Display Guild Rank"], Language["Display character guild ranks"])
	
	right:CreateHeader(Language["Disable Tooltips"])
	right:CreateDropdown("tooltips-hide-on-unit", Settings["tooltips-hide-on-unit"], {[Language["Never"]] = "NEVER", [Language["Always"]] = "ALWAYS", [Language["Friendly"]] = "FRIENDLY", [Language["Hostile"]] = "HOSTILE", [Language["Combat"]] = "NO_COMBAT"}, Language["Disable Units"], Language["Set the tooltip to not display units"])
	right:CreateDropdown("tooltips-hide-on-item", Settings["tooltips-hide-on-item"], {[Language["Never"]] = "NEVER", [Language["Always"]] = "ALWAYS", [Language["Combat"]] = "NO_COMBAT"}, Language["Disable Items"], Language["Set the tooltip to not display items"])
	right:CreateDropdown("tooltips-hide-on-action", Settings["tooltips-hide-on-action"], {[Language["Never"]] = "NEVER", [Language["Always"]] = "ALWAYS", [Language["Combat"]] = "NO_COMBAT"}, Language["Disable Actions"], Language["Set the tooltip to not display actions"])
end)

GUI2:AddSettings("General", "Action Bars", function(left, right)
	left:CreateHeader(Language["Enable"])
	left:CreateSwitch("ab-enable", Settings["ab-enable"], Language["Enable Action Bar"], Language["Enable action bars module"])
	
	right:CreateHeader(Language["Styling"])
	right:CreateSwitch("ab-show-hotkey", Settings["ab-show-hotkey"], Language["Show Hotkeys"], Language["Display hotkey text on action buttons"])
	right:CreateSwitch("ab-show-macro", Settings["ab-show-macro"], Language["Show Macro Names"], Language["Display macro name text on action buttons"])
	right:CreateSwitch("ab-show-count", Settings["ab-show-count"], Language["Show Count Text"], Language["Display count text on action buttons"])
	right:CreateSwitch("ab-show-empty", Settings["ab-show-empty"], Language["Show Empty Buttons"], Language["Set whether or not the action bar should display empty buttons"])
end)

GUI2:AddSettings("General", "Bar 1", "Action Bars", function(left, right)
	left:CreateHeader(Language["Enable"])
	left:CreateSwitch("ab-enable", Settings["ab-enable"], Language["Enable Action Bar"], Language["Enable action bars module"])
	
	left:CreateHeader(Language["Styling"])
	left:CreateSwitch("ab-bar1-hover", Settings["ab-bar1-hover"], Language["Set Mouseover"], Language["Only display the bar while hovering over it"])
	left:CreateSlider("ab-bar1-per-row", Settings["ab-bar1-per-row"], 1, 12, 1, Language["Buttons Per Row"], Language["Set the number of buttons per row"])
	left:CreateSlider("ab-bar1-button-max", Settings["ab-bar1-button-max"], 1, 12, 1, Language["Max Buttons"], Language["Set the number of buttons displayed on the action bar"])
	left:CreateSlider("ab-bar1-button-size", Settings["ab-bar1-button-size"], 20, 50, 1, Language["Button Size"], Language["Set the action button size"])
	left:CreateSlider("ab-bar1-button-gap", Settings["ab-bar1-button-gap"], -1, 8, 1, Language["Button Spacing"], Language["Set the spacing between action buttons"])
	left:CreateSwitch("ab-show-hotkey", Settings["ab-show-hotkey"], Language["Show Hotkeys"], Language["Display hotkey text on action buttons"])
	left:CreateSwitch("ab-show-macro", Settings["ab-show-macro"], Language["Show Macro Names"], Language["Display macro name text on action buttons"])
	left:CreateSwitch("ab-show-count", Settings["ab-show-count"], Language["Show Count Text"], Language["Display count text on action buttons"])
	
	right:CreateHeader(Language["Font"])
	right:CreateDropdown("ab-font", Settings["ab-font"], Assets:GetFontList(), Language["Font"], Language["Set the font of the action bar buttons"], nil, "Font")
	right:CreateSlider("ab-font-size", Settings["ab-font-size"], 8, 42, 1, Language["Font Size"], Language["Set the font size of the action bar buttons"])
	right:CreateSlider("ab-cd-size", Settings["ab-cd-size"], 8, 42, 1, Language["Cooldown Font Size"], Language["Set the font size of the action bar cooldowns"])
	right:CreateDropdown("ab-font-flags", Settings["ab-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], Language["Set the font flags of the action bar buttons"])
end)

GUI2:AddSettings("General", "Bar 2", "Action Bars", function(left, right)
	left:CreateHeader(Language["Enable"])
	left:CreateSwitch("ab-enable", Settings["ab-enable"], Language["Enable Action Bar"], Language["Enable action bars module"])
	
	left:CreateHeader(Language["Styling"])
	left:CreateSwitch("ab-bar1-hover", Settings["ab-bar1-hover"], Language["Set Mouseover"], Language["Only display the bar while hovering over it"])
	left:CreateSlider("ab-bar1-per-row", Settings["ab-bar1-per-row"], 1, 12, 1, Language["Buttons Per Row"], Language["Set the number of buttons per row"])
	left:CreateSlider("ab-bar1-button-max", Settings["ab-bar1-button-max"], 1, 12, 1, Language["Max Buttons"], Language["Set the number of buttons displayed on the action bar"])
	left:CreateSlider("ab-bar1-button-size", Settings["ab-bar1-button-size"], 20, 50, 1, Language["Button Size"], Language["Set the action button size"])
	left:CreateSlider("ab-bar1-button-gap", Settings["ab-bar1-button-gap"], -1, 8, 1, Language["Button Spacing"], Language["Set the spacing between action buttons"])
	left:CreateSwitch("ab-show-hotkey", Settings["ab-show-hotkey"], Language["Show Hotkeys"], Language["Display hotkey text on action buttons"])
	left:CreateSwitch("ab-show-macro", Settings["ab-show-macro"], Language["Show Macro Names"], Language["Display macro name text on action buttons"])
	left:CreateSwitch("ab-show-count", Settings["ab-show-count"], Language["Show Count Text"], Language["Display count text on action buttons"])
	
	right:CreateHeader(Language["Font"])
	right:CreateDropdown("ab-font", Settings["ab-font"], Assets:GetFontList(), Language["Font"], Language["Set the font of the action bar buttons"], nil, "Font")
	right:CreateSlider("ab-font-size", Settings["ab-font-size"], 8, 42, 1, Language["Font Size"], Language["Set the font size of the action bar buttons"])
	right:CreateSlider("ab-cd-size", Settings["ab-cd-size"], 8, 42, 1, Language["Cooldown Font Size"], Language["Set the font size of the action bar cooldowns"])
	right:CreateDropdown("ab-font-flags", Settings["ab-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], Language["Set the font flags of the action bar buttons"])
end)

GUI2:AddSettings("General", "Bar 3", "Action Bars", function(left, right)
	left:CreateHeader(Language["Enable"])
	left:CreateSwitch("ab-enable", Settings["ab-enable"], Language["Enable Action Bar"], Language["Enable action bars module"])
	
	left:CreateHeader(Language["Styling"])
	left:CreateSwitch("ab-bar1-hover", Settings["ab-bar1-hover"], Language["Set Mouseover"], Language["Only display the bar while hovering over it"])
	left:CreateSlider("ab-bar1-per-row", Settings["ab-bar1-per-row"], 1, 12, 1, Language["Buttons Per Row"], Language["Set the number of buttons per row"])
	left:CreateSlider("ab-bar1-button-max", Settings["ab-bar1-button-max"], 1, 12, 1, Language["Max Buttons"], Language["Set the number of buttons displayed on the action bar"])
	left:CreateSlider("ab-bar1-button-size", Settings["ab-bar1-button-size"], 20, 50, 1, Language["Button Size"], Language["Set the action button size"])
	left:CreateSlider("ab-bar1-button-gap", Settings["ab-bar1-button-gap"], -1, 8, 1, Language["Button Spacing"], Language["Set the spacing between action buttons"])
	left:CreateSwitch("ab-show-hotkey", Settings["ab-show-hotkey"], Language["Show Hotkeys"], Language["Display hotkey text on action buttons"])
	left:CreateSwitch("ab-show-macro", Settings["ab-show-macro"], Language["Show Macro Names"], Language["Display macro name text on action buttons"])
	left:CreateSwitch("ab-show-count", Settings["ab-show-count"], Language["Show Count Text"], Language["Display count text on action buttons"])
	
	right:CreateHeader(Language["Font"])
	right:CreateDropdown("ab-font", Settings["ab-font"], Assets:GetFontList(), Language["Font"], Language["Set the font of the action bar buttons"], nil, "Font")
	right:CreateSlider("ab-font-size", Settings["ab-font-size"], 8, 42, 1, Language["Font Size"], Language["Set the font size of the action bar buttons"])
	right:CreateSlider("ab-cd-size", Settings["ab-cd-size"], 8, 42, 1, Language["Cooldown Font Size"], Language["Set the font size of the action bar cooldowns"])
	right:CreateDropdown("ab-font-flags", Settings["ab-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], Language["Set the font flags of the action bar buttons"])
end)

GUI2:AddSettings("General", "Bar 4", "Action Bars", function(left, right)
	left:CreateHeader(Language["Enable"])
	left:CreateSwitch("ab-enable", Settings["ab-enable"], Language["Enable Action Bar"], Language["Enable action bars module"])
	
	left:CreateHeader(Language["Styling"])
	left:CreateSwitch("ab-bar1-hover", Settings["ab-bar1-hover"], Language["Set Mouseover"], Language["Only display the bar while hovering over it"])
	left:CreateSlider("ab-bar1-per-row", Settings["ab-bar1-per-row"], 1, 12, 1, Language["Buttons Per Row"], Language["Set the number of buttons per row"])
	left:CreateSlider("ab-bar1-button-max", Settings["ab-bar1-button-max"], 1, 12, 1, Language["Max Buttons"], Language["Set the number of buttons displayed on the action bar"])
	left:CreateSlider("ab-bar1-button-size", Settings["ab-bar1-button-size"], 20, 50, 1, Language["Button Size"], Language["Set the action button size"])
	left:CreateSlider("ab-bar1-button-gap", Settings["ab-bar1-button-gap"], -1, 8, 1, Language["Button Spacing"], Language["Set the spacing between action buttons"])
	left:CreateSwitch("ab-show-hotkey", Settings["ab-show-hotkey"], Language["Show Hotkeys"], Language["Display hotkey text on action buttons"])
	left:CreateSwitch("ab-show-macro", Settings["ab-show-macro"], Language["Show Macro Names"], Language["Display macro name text on action buttons"])
	left:CreateSwitch("ab-show-count", Settings["ab-show-count"], Language["Show Count Text"], Language["Display count text on action buttons"])
	
	right:CreateHeader(Language["Font"])
	right:CreateDropdown("ab-font", Settings["ab-font"], Assets:GetFontList(), Language["Font"], Language["Set the font of the action bar buttons"], nil, "Font")
	right:CreateSlider("ab-font-size", Settings["ab-font-size"], 8, 42, 1, Language["Font Size"], Language["Set the font size of the action bar buttons"])
	right:CreateSlider("ab-cd-size", Settings["ab-cd-size"], 8, 42, 1, Language["Cooldown Font Size"], Language["Set the font size of the action bar cooldowns"])
	right:CreateDropdown("ab-font-flags", Settings["ab-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], Language["Set the font flags of the action bar buttons"])
end)

GUI2:AddSettings("General", "Bar 5", "Action Bars", function(left, right)
	left:CreateHeader(Language["Enable"])
	left:CreateSwitch("ab-enable", Settings["ab-enable"], Language["Enable Action Bar"], Language["Enable action bars module"])
	
	left:CreateHeader(Language["Styling"])
	left:CreateSwitch("ab-bar1-hover", Settings["ab-bar1-hover"], Language["Set Mouseover"], Language["Only display the bar while hovering over it"])
	left:CreateSlider("ab-bar1-per-row", Settings["ab-bar1-per-row"], 1, 12, 1, Language["Buttons Per Row"], Language["Set the number of buttons per row"])
	left:CreateSlider("ab-bar1-button-max", Settings["ab-bar1-button-max"], 1, 12, 1, Language["Max Buttons"], Language["Set the number of buttons displayed on the action bar"])
	left:CreateSlider("ab-bar1-button-size", Settings["ab-bar1-button-size"], 20, 50, 1, Language["Button Size"], Language["Set the action button size"])
	left:CreateSlider("ab-bar1-button-gap", Settings["ab-bar1-button-gap"], -1, 8, 1, Language["Button Spacing"], Language["Set the spacing between action buttons"])
	left:CreateSwitch("ab-show-hotkey", Settings["ab-show-hotkey"], Language["Show Hotkeys"], Language["Display hotkey text on action buttons"])
	left:CreateSwitch("ab-show-macro", Settings["ab-show-macro"], Language["Show Macro Names"], Language["Display macro name text on action buttons"])
	left:CreateSwitch("ab-show-count", Settings["ab-show-count"], Language["Show Count Text"], Language["Display count text on action buttons"])
	
	right:CreateHeader(Language["Font"])
	right:CreateDropdown("ab-font", Settings["ab-font"], Assets:GetFontList(), Language["Font"], Language["Set the font of the action bar buttons"], nil, "Font")
	right:CreateSlider("ab-font-size", Settings["ab-font-size"], 8, 42, 1, Language["Font Size"], Language["Set the font size of the action bar buttons"])
	right:CreateSlider("ab-cd-size", Settings["ab-cd-size"], 8, 42, 1, Language["Cooldown Font Size"], Language["Set the font size of the action bar cooldowns"])
	right:CreateDropdown("ab-font-flags", Settings["ab-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], Language["Set the font flags of the action bar buttons"])
end)

GUI2:AddSettings("General", "Pet", "Action Bars", function(left, right)
	left:CreateHeader(Language["Enable"])
	left:CreateSwitch("ab-enable", Settings["ab-enable"], Language["Enable Action Bar"], Language["Enable action bars module"])
	
	left:CreateHeader(Language["Styling"])
	left:CreateSwitch("ab-bar1-hover", Settings["ab-bar1-hover"], Language["Set Mouseover"], Language["Only display the bar while hovering over it"])
	left:CreateSlider("ab-bar1-per-row", Settings["ab-bar1-per-row"], 1, 12, 1, Language["Buttons Per Row"], Language["Set the number of buttons per row"])
	left:CreateSlider("ab-bar1-button-max", Settings["ab-bar1-button-max"], 1, 12, 1, Language["Max Buttons"], Language["Set the number of buttons displayed on the action bar"])
	left:CreateSlider("ab-bar1-button-size", Settings["ab-bar1-button-size"], 20, 50, 1, Language["Button Size"], Language["Set the action button size"])
	left:CreateSlider("ab-bar1-button-gap", Settings["ab-bar1-button-gap"], -1, 8, 1, Language["Button Spacing"], Language["Set the spacing between action buttons"])
	left:CreateSwitch("ab-show-hotkey", Settings["ab-show-hotkey"], Language["Show Hotkeys"], Language["Display hotkey text on action buttons"])
	left:CreateSwitch("ab-show-macro", Settings["ab-show-macro"], Language["Show Macro Names"], Language["Display macro name text on action buttons"])
	left:CreateSwitch("ab-show-count", Settings["ab-show-count"], Language["Show Count Text"], Language["Display count text on action buttons"])
	
	right:CreateHeader(Language["Font"])
	right:CreateDropdown("ab-font", Settings["ab-font"], Assets:GetFontList(), Language["Font"], Language["Set the font of the action bar buttons"], nil, "Font")
	right:CreateSlider("ab-font-size", Settings["ab-font-size"], 8, 42, 1, Language["Font Size"], Language["Set the font size of the action bar buttons"])
	right:CreateSlider("ab-cd-size", Settings["ab-cd-size"], 8, 42, 1, Language["Cooldown Font Size"], Language["Set the font size of the action bar cooldowns"])
	right:CreateDropdown("ab-font-flags", Settings["ab-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], Language["Set the font flags of the action bar buttons"])
end)

GUI2:AddSettings("General", "Stance", "Action Bars", function(left, right)
	left:CreateHeader(Language["Enable"])
	left:CreateSwitch("ab-enable", Settings["ab-enable"], Language["Enable Action Bar"], Language["Enable action bars module"])
	
	left:CreateHeader(Language["Styling"])
	left:CreateSwitch("ab-bar1-hover", Settings["ab-bar1-hover"], Language["Set Mouseover"], Language["Only display the bar while hovering over it"])
	left:CreateSlider("ab-bar1-per-row", Settings["ab-bar1-per-row"], 1, 12, 1, Language["Buttons Per Row"], Language["Set the number of buttons per row"])
	left:CreateSlider("ab-bar1-button-max", Settings["ab-bar1-button-max"], 1, 12, 1, Language["Max Buttons"], Language["Set the number of buttons displayed on the action bar"])
	left:CreateSlider("ab-bar1-button-size", Settings["ab-bar1-button-size"], 20, 50, 1, Language["Button Size"], Language["Set the action button size"])
	left:CreateSlider("ab-bar1-button-gap", Settings["ab-bar1-button-gap"], -1, 8, 1, Language["Button Spacing"], Language["Set the spacing between action buttons"])
	left:CreateSwitch("ab-show-hotkey", Settings["ab-show-hotkey"], Language["Show Hotkeys"], Language["Display hotkey text on action buttons"])
	left:CreateSwitch("ab-show-macro", Settings["ab-show-macro"], Language["Show Macro Names"], Language["Display macro name text on action buttons"])
	left:CreateSwitch("ab-show-count", Settings["ab-show-count"], Language["Show Count Text"], Language["Display count text on action buttons"])
	
	right:CreateHeader(Language["Font"])
	right:CreateDropdown("ab-font", Settings["ab-font"], Assets:GetFontList(), Language["Font"], Language["Set the font of the action bar buttons"], nil, "Font")
	right:CreateSlider("ab-font-size", Settings["ab-font-size"], 8, 42, 1, Language["Font Size"], Language["Set the font size of the action bar buttons"])
	right:CreateSlider("ab-cd-size", Settings["ab-cd-size"], 8, 42, 1, Language["Cooldown Font Size"], Language["Set the font size of the action bar cooldowns"])
	right:CreateDropdown("ab-font-flags", Settings["ab-font-flags"], Assets:GetFlagsList(), Language["Font Flags"], Language["Set the font flags of the action bar buttons"])
end)

GUI2:AddSettings("General", "Unit Frames", function(left, right)
	left:CreateHeader(Language["Enable"])
	left:CreateSwitch("unitframes-enable", Settings["unitframes-enable"], Language["Enable Unit Frames Module"], Language["Enable the unit frames module"])
end)

GUI2:AddSettings("General", "Player", "Unit Frames", function(left, right)
	left:CreateHeader(Language["Styling"])
	left:CreateSlider("unitframes-player-width", Settings["unitframes-player-width"], 120, 320, 1, "Width", "Set the width of the player unit frame", UpdatePlayerWidth)
	left:CreateSwitch("unitframes-player-enable-resource", Settings["unitframes-player-enable-resource"], Language["Enable Resource Bar"], Language["Enable the player resources such as combo points, runes, etc."])
	left:CreateSwitch("unitframes-show-player-buffs", Settings["unitframes-show-player-buffs"], Language["Show Player Buffs"], Language["Show your auras above the player unit frame"])
	
	left:CreateHeader(Language["Health"])
	left:CreateSlider("unitframes-player-health-height", Settings["unitframes-player-health-height"], 6, 60, 1, "Health Bar Height", "Set the height of the player health bar")
	left:CreateDropdown("unitframes-player-health-color", Settings["unitframes-player-health-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Custom"]] = "CUSTOM"}, Language["Health Bar Color"], Language["Set the color of the health bar"])
	left:CreateInput("unitframes-player-health-left", Settings["unitframes-player-health-left"], Language["Left Health Text"], Language["Set the text on the left of the player health bar"])
	left:CreateInput("unitframes-player-health-right", Settings["unitframes-player-health-right"], Language["Right Health Text"], Language["Set the text on the right of the player health bar"])
	left:CreateSwitch("unitframes-player-health-reverse", Settings["unitframes-player-health-reverse"], Language["Reverse Health Fill"], Language["Reverse the fill of the health bar"])
	
	right:CreateHeader(Language["Power"])
	right:CreateSwitch("unitframes-player-enable-power", Settings["unitframes-player-enable-power"], Language["Enable Power Bar"], Language["Enable the player power bar"])
	right:CreateSlider("unitframes-player-power-height", Settings["unitframes-player-power-height"], 2, 30, 1, "Power Bar Height", "Set the height of the player power bar")
	right:CreateDropdown("unitframes-player-power-color", Settings["unitframes-player-power-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Power Type"]] = "POWER"}, Language["Power Bar Color"], Language["Set the color of the power bar"])
	right:CreateInput("unitframes-player-power-left", Settings["unitframes-player-power-left"], Language["Left Power Text"], Language["Set the text on the left of the player power bar"])
	right:CreateInput("unitframes-player-power-right", Settings["unitframes-player-power-right"], Language["Right Power Text"], Language["Set the text on the right of the player power bar"])
	right:CreateSwitch("unitframes-player-power-reverse", Settings["unitframes-player-power-reverse"], Language["Reverse Power Fill"], Language["Reverse the fill of the power bar"], UpdatePlayerPowerFill)
	
	left:CreateHeader(Language["Cast Bar"])
	left:CreateSwitch("unitframes-player-enable-castbar", Settings["unitframes-player-enable-castbar"], Language["Enable Cast Bar"], Language["Enable the player cast bar"])
	left:CreateSlider("unitframes-player-cast-width", Settings["unitframes-player-cast-width"], 80, 360, 1, Language["Cast Bar Width"], Language["Set the width of the player cast bar"])
	left:CreateSlider("unitframes-player-cast-height", Settings["unitframes-player-cast-height"], 8, 50, 1, Language["Cast Bar Height"], Language["Set the height of the player cast bar"])
end)

GUI2:AddSettings("General", "Target", "Unit Frames", function(left, right)
	left:CreateHeader(Language["Styling"])
	left:CreateSlider("unitframes-player-width", Settings["unitframes-player-width"], 120, 320, 1, "Width", "Set the width of the player unit frame", UpdatePlayerWidth)
	left:CreateSwitch("unitframes-player-enable-resource", Settings["unitframes-player-enable-resource"], Language["Enable Resource Bar"], Language["Enable the player resources such as combo points, runes, etc."])
	left:CreateSwitch("unitframes-show-player-buffs", Settings["unitframes-show-player-buffs"], Language["Show Player Buffs"], Language["Show your auras above the player unit frame"])
	
	left:CreateHeader(Language["Health"])
	left:CreateSlider("unitframes-player-health-height", Settings["unitframes-player-health-height"], 6, 60, 1, "Health Bar Height", "Set the height of the player health bar")
	left:CreateDropdown("unitframes-player-health-color", Settings["unitframes-player-health-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Custom"]] = "CUSTOM"}, Language["Health Bar Color"], Language["Set the color of the health bar"])
	left:CreateInput("unitframes-player-health-left", Settings["unitframes-player-health-left"], Language["Left Health Text"], Language["Set the text on the left of the player health bar"])
	left:CreateInput("unitframes-player-health-right", Settings["unitframes-player-health-right"], Language["Right Health Text"], Language["Set the text on the right of the player health bar"])
	left:CreateSwitch("unitframes-player-health-reverse", Settings["unitframes-player-health-reverse"], Language["Reverse Health Fill"], Language["Reverse the fill of the health bar"])
	
	right:CreateHeader(Language["Power"])
	right:CreateSwitch("unitframes-player-enable-power", Settings["unitframes-player-enable-power"], Language["Enable Power Bar"], Language["Enable the player power bar"])
	right:CreateSlider("unitframes-player-power-height", Settings["unitframes-player-power-height"], 2, 30, 1, "Power Bar Height", "Set the height of the player power bar")
	right:CreateDropdown("unitframes-player-power-color", Settings["unitframes-player-power-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Power Type"]] = "POWER"}, Language["Power Bar Color"], Language["Set the color of the power bar"])
	right:CreateInput("unitframes-player-power-left", Settings["unitframes-player-power-left"], Language["Left Power Text"], Language["Set the text on the left of the player power bar"])
	right:CreateInput("unitframes-player-power-right", Settings["unitframes-player-power-right"], Language["Right Power Text"], Language["Set the text on the right of the player power bar"])
	right:CreateSwitch("unitframes-player-power-reverse", Settings["unitframes-player-power-reverse"], Language["Reverse Power Fill"], Language["Reverse the fill of the power bar"], UpdatePlayerPowerFill)
	
	left:CreateHeader(Language["Cast Bar"])
	left:CreateSwitch("unitframes-player-enable-castbar", Settings["unitframes-player-enable-castbar"], Language["Enable Cast Bar"], Language["Enable the player cast bar"])
	left:CreateSlider("unitframes-player-cast-width", Settings["unitframes-player-cast-width"], 80, 360, 1, Language["Cast Bar Width"], Language["Set the width of the player cast bar"])
	left:CreateSlider("unitframes-player-cast-height", Settings["unitframes-player-cast-height"], 8, 50, 1, Language["Cast Bar Height"], Language["Set the height of the player cast bar"])
end)

GUI2:AddSettings("General", "Target of Target", "Unit Frames", function(left, right)
	left:CreateHeader(Language["Styling"])
	left:CreateSlider("unitframes-player-width", Settings["unitframes-player-width"], 120, 320, 1, "Width", "Set the width of the player unit frame", UpdatePlayerWidth)
	left:CreateSwitch("unitframes-player-enable-resource", Settings["unitframes-player-enable-resource"], Language["Enable Resource Bar"], Language["Enable the player resources such as combo points, runes, etc."])
	left:CreateSwitch("unitframes-show-player-buffs", Settings["unitframes-show-player-buffs"], Language["Show Player Buffs"], Language["Show your auras above the player unit frame"])
	
	left:CreateHeader(Language["Health"])
	left:CreateSlider("unitframes-player-health-height", Settings["unitframes-player-health-height"], 6, 60, 1, "Health Bar Height", "Set the height of the player health bar")
	left:CreateDropdown("unitframes-player-health-color", Settings["unitframes-player-health-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Custom"]] = "CUSTOM"}, Language["Health Bar Color"], Language["Set the color of the health bar"])
	left:CreateInput("unitframes-player-health-left", Settings["unitframes-player-health-left"], Language["Left Health Text"], Language["Set the text on the left of the player health bar"])
	left:CreateInput("unitframes-player-health-right", Settings["unitframes-player-health-right"], Language["Right Health Text"], Language["Set the text on the right of the player health bar"])
	left:CreateSwitch("unitframes-player-health-reverse", Settings["unitframes-player-health-reverse"], Language["Reverse Health Fill"], Language["Reverse the fill of the health bar"])
	
	right:CreateHeader(Language["Power"])
	right:CreateSwitch("unitframes-player-enable-power", Settings["unitframes-player-enable-power"], Language["Enable Power Bar"], Language["Enable the player power bar"])
	right:CreateSlider("unitframes-player-power-height", Settings["unitframes-player-power-height"], 2, 30, 1, "Power Bar Height", "Set the height of the player power bar")
	right:CreateDropdown("unitframes-player-power-color", Settings["unitframes-player-power-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Power Type"]] = "POWER"}, Language["Power Bar Color"], Language["Set the color of the power bar"])
	right:CreateInput("unitframes-player-power-left", Settings["unitframes-player-power-left"], Language["Left Power Text"], Language["Set the text on the left of the player power bar"])
	right:CreateInput("unitframes-player-power-right", Settings["unitframes-player-power-right"], Language["Right Power Text"], Language["Set the text on the right of the player power bar"])
	right:CreateSwitch("unitframes-player-power-reverse", Settings["unitframes-player-power-reverse"], Language["Reverse Power Fill"], Language["Reverse the fill of the power bar"], UpdatePlayerPowerFill)
	
	left:CreateHeader(Language["Cast Bar"])
	left:CreateSwitch("unitframes-player-enable-castbar", Settings["unitframes-player-enable-castbar"], Language["Enable Cast Bar"], Language["Enable the player cast bar"])
	left:CreateSlider("unitframes-player-cast-width", Settings["unitframes-player-cast-width"], 80, 360, 1, Language["Cast Bar Width"], Language["Set the width of the player cast bar"])
	left:CreateSlider("unitframes-player-cast-height", Settings["unitframes-player-cast-height"], 8, 50, 1, Language["Cast Bar Height"], Language["Set the height of the player cast bar"])
end)

GUI2:AddSettings("General", "Focus", "Unit Frames", function(left, right)
	left:CreateHeader(Language["Styling"])
	left:CreateSlider("unitframes-player-width", Settings["unitframes-player-width"], 120, 320, 1, "Width", "Set the width of the player unit frame", UpdatePlayerWidth)
	left:CreateSwitch("unitframes-player-enable-resource", Settings["unitframes-player-enable-resource"], Language["Enable Resource Bar"], Language["Enable the player resources such as combo points, runes, etc."])
	left:CreateSwitch("unitframes-show-player-buffs", Settings["unitframes-show-player-buffs"], Language["Show Player Buffs"], Language["Show your auras above the player unit frame"])
	
	left:CreateHeader(Language["Health"])
	left:CreateSlider("unitframes-player-health-height", Settings["unitframes-player-health-height"], 6, 60, 1, "Health Bar Height", "Set the height of the player health bar")
	left:CreateDropdown("unitframes-player-health-color", Settings["unitframes-player-health-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Custom"]] = "CUSTOM"}, Language["Health Bar Color"], Language["Set the color of the health bar"])
	left:CreateInput("unitframes-player-health-left", Settings["unitframes-player-health-left"], Language["Left Health Text"], Language["Set the text on the left of the player health bar"])
	left:CreateInput("unitframes-player-health-right", Settings["unitframes-player-health-right"], Language["Right Health Text"], Language["Set the text on the right of the player health bar"])
	left:CreateSwitch("unitframes-player-health-reverse", Settings["unitframes-player-health-reverse"], Language["Reverse Health Fill"], Language["Reverse the fill of the health bar"])
	
	right:CreateHeader(Language["Power"])
	right:CreateSwitch("unitframes-player-enable-power", Settings["unitframes-player-enable-power"], Language["Enable Power Bar"], Language["Enable the player power bar"])
	right:CreateSlider("unitframes-player-power-height", Settings["unitframes-player-power-height"], 2, 30, 1, "Power Bar Height", "Set the height of the player power bar")
	right:CreateDropdown("unitframes-player-power-color", Settings["unitframes-player-power-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Power Type"]] = "POWER"}, Language["Power Bar Color"], Language["Set the color of the power bar"])
	right:CreateInput("unitframes-player-power-left", Settings["unitframes-player-power-left"], Language["Left Power Text"], Language["Set the text on the left of the player power bar"])
	right:CreateInput("unitframes-player-power-right", Settings["unitframes-player-power-right"], Language["Right Power Text"], Language["Set the text on the right of the player power bar"])
	right:CreateSwitch("unitframes-player-power-reverse", Settings["unitframes-player-power-reverse"], Language["Reverse Power Fill"], Language["Reverse the fill of the power bar"], UpdatePlayerPowerFill)
	
	left:CreateHeader(Language["Cast Bar"])
	left:CreateSwitch("unitframes-player-enable-castbar", Settings["unitframes-player-enable-castbar"], Language["Enable Cast Bar"], Language["Enable the player cast bar"])
	left:CreateSlider("unitframes-player-cast-width", Settings["unitframes-player-cast-width"], 80, 360, 1, Language["Cast Bar Width"], Language["Set the width of the player cast bar"])
	left:CreateSlider("unitframes-player-cast-height", Settings["unitframes-player-cast-height"], 8, 50, 1, Language["Cast Bar Height"], Language["Set the height of the player cast bar"])
end)

GUI2:AddSettings("General", "Pet", "Unit Frames", function(left, right)
	left:CreateHeader(Language["Styling"])
	left:CreateSlider("unitframes-player-width", Settings["unitframes-player-width"], 120, 320, 1, "Width", "Set the width of the player unit frame", UpdatePlayerWidth)
	left:CreateSwitch("unitframes-player-enable-resource", Settings["unitframes-player-enable-resource"], Language["Enable Resource Bar"], Language["Enable the player resources such as combo points, runes, etc."])
	left:CreateSwitch("unitframes-show-player-buffs", Settings["unitframes-show-player-buffs"], Language["Show Player Buffs"], Language["Show your auras above the player unit frame"])
	
	left:CreateHeader(Language["Health"])
	left:CreateSlider("unitframes-player-health-height", Settings["unitframes-player-health-height"], 6, 60, 1, "Health Bar Height", "Set the height of the player health bar")
	left:CreateDropdown("unitframes-player-health-color", Settings["unitframes-player-health-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Custom"]] = "CUSTOM"}, Language["Health Bar Color"], Language["Set the color of the health bar"])
	left:CreateInput("unitframes-player-health-left", Settings["unitframes-player-health-left"], Language["Left Health Text"], Language["Set the text on the left of the player health bar"])
	left:CreateInput("unitframes-player-health-right", Settings["unitframes-player-health-right"], Language["Right Health Text"], Language["Set the text on the right of the player health bar"])
	left:CreateSwitch("unitframes-player-health-reverse", Settings["unitframes-player-health-reverse"], Language["Reverse Health Fill"], Language["Reverse the fill of the health bar"])
	
	right:CreateHeader(Language["Power"])
	right:CreateSwitch("unitframes-player-enable-power", Settings["unitframes-player-enable-power"], Language["Enable Power Bar"], Language["Enable the player power bar"])
	right:CreateSlider("unitframes-player-power-height", Settings["unitframes-player-power-height"], 2, 30, 1, "Power Bar Height", "Set the height of the player power bar")
	right:CreateDropdown("unitframes-player-power-color", Settings["unitframes-player-power-color"], {[Language["Class"]] = "CLASS", [Language["Reaction"]] = "REACTION", [Language["Power Type"]] = "POWER"}, Language["Power Bar Color"], Language["Set the color of the power bar"])
	right:CreateInput("unitframes-player-power-left", Settings["unitframes-player-power-left"], Language["Left Power Text"], Language["Set the text on the left of the player power bar"])
	right:CreateInput("unitframes-player-power-right", Settings["unitframes-player-power-right"], Language["Right Power Text"], Language["Set the text on the right of the player power bar"])
	right:CreateSwitch("unitframes-player-power-reverse", Settings["unitframes-player-power-reverse"], Language["Reverse Power Fill"], Language["Reverse the fill of the power bar"], UpdatePlayerPowerFill)
	
	left:CreateHeader(Language["Cast Bar"])
	left:CreateSwitch("unitframes-player-enable-castbar", Settings["unitframes-player-enable-castbar"], Language["Enable Cast Bar"], Language["Enable the player cast bar"])
	left:CreateSlider("unitframes-player-cast-width", Settings["unitframes-player-cast-width"], 80, 360, 1, Language["Cast Bar Width"], Language["Set the width of the player cast bar"])
	left:CreateSlider("unitframes-player-cast-height", Settings["unitframes-player-cast-height"], 8, 50, 1, Language["Cast Bar Height"], Language["Set the height of the player cast bar"])
end)

GUI2:AddSettings("General", "Tags", "Unit Frames", function(left, right)
	left:CreateLine("Just kidding. Coming soon though.")
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

GUI2:AddSettings("Info", "Plugins", function(left, right)
	if (#vUI.Plugins == 0) then
		return
	end
	
	for i = 1, #vUI.Plugins do
		if ((i % 2) == 0) then
			Anchor = right
		else
			Anchor = left
		end
		
		Anchor:CreateHeader(vUI.Plugins[i].Title)
		
		Anchor:CreateDoubleLine(Language["Author"], vUI.Plugins[i].Author)
		Anchor:CreateDoubleLine(Language["Version"], vUI.Plugins[i].Version)
		Anchor:CreateLine(" ")
		Anchor:CreateMessage(vUI.Plugins[i].Notes)
	end
end)

print("|cFFFFEB3B|Hcommand:/run GUI2_Toggle()|h[Toggle Test GUI]|h|r")