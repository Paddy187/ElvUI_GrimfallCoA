local E, _, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))
local Misc = E:GetModule("Misc")
local Layout = E:GetModule("Layout")
local Totems = E:GetModule("Totems")
local Blizzard = E:GetModule("Blizzard")
local Threat = E:GetModule("Threat")
local AFK = E:GetModule("AFK")

local _G = _G

local FCF_GetNumActiveChatFrames = FCF_GetNumActiveChatFrames

local function GetChatWindowInfo()
	local ChatTabInfo = {}
	for i = 1, FCF_GetNumActiveChatFrames() do
		if i ~= 2 then
			ChatTabInfo["ChatFrame"..i] = _G["ChatFrame"..i.."Tab"]:GetText()
		end
	end

	return ChatTabInfo
end

E.Options.args.general = {
	order = 1,
	type = "group",
	name = L["General"],
	childGroups = "tab",
	get = function(info) return E.db.general[info[#info]] end,
	set = function(info, value) E.db.general[info[#info]] = value end,
	args = {
		intro = {
			order = 1,
			type = "description",
			name = L["ELVUI_DESC"]
		},
		general = {
			order = 2,
			type = "group",
			name = L["General"],
			args = {
				generalHeader = {
					order = 1,
					type = "header",
					name = L["General"]
				},
				messageRedirect = {
					order = 2,
					type = "select",
					name = L["Chat Output"],
					desc = L["This selects the Chat Frame to use as the output of ElvUI messages."],
					values = GetChatWindowInfo()
				},
				AutoScale = {
					order = 3,
					type = "execute",
					name = L["Auto Scale"],
					func = function()
						E.global.general.UIScale = E:PixelBestSize()
						E:StaticPopup_Show("UISCALE_CHANGE")
					end
				},
				UIScale = {
					order = 4,
					type = "range",
					name = L["UI_SCALE"],
					min = 0.1, max = 1.25, step = 0.0000000000000001,
					softMin = 0.40, softMax = 1.15, bigStep = 0.01,
					get = function(info) return E.global.general.UIScale end,
					set = function(info, value)
						E.global.general.UIScale = value
						E:StaticPopup_Show("UISCALE_CHANGE")
					end
				},
				ignoreScalePopup = {
					order = 5,
					type = "toggle",
					name = L["Ignore UI Scale Popup"],
					desc = L["This will prevent the UI Scale Popup from being shown when changing the game window size."],
					get = function(info) return E.global.general.ignoreScalePopup end,
					set = function(info, value) E.global.general.ignoreScalePopup = value end
				},
				pixelPerfect = {
					order = 6,
					type = "toggle",
					name = L["Thin Border Theme"],
					desc = L["The Thin Border Theme option will change the overall apperance of your UI. Using Thin Border Theme is a slight performance increase over the traditional layout."],
					get = function(info) return E.private.general.pixelPerfect end,
					set = function(info, value) E.private.general.pixelPerfect = value E:StaticPopup_Show("PRIVATE_RL") end
				},
				eyefinity = {
					order = 7,
					type = "toggle",
					name = L["Multi-Monitor Support"],
					desc = L["Attempt to support eyefinity/nvidia surround."],
					get = function(info) return E.global.general.eyefinity end,
					set = function(info, value) E.global.general.eyefinity = value E:StaticPopup_Show("GLOBAL_RL") end
				},
				taintLog = {
					order = 8,
					type = "toggle",
					name = L["Log Taints"],
					desc = L["Send ADDON_ACTION_BLOCKED errors to the Lua Error frame. These errors are less important in most cases and will not effect your game performance. Also a lot of these errors cannot be fixed. Please only report these errors if you notice a Defect in gameplay."]
				},
				screenPanels = {
					order = 9,
					type = "group",
					name = "Screen Panels",
					guiInline = true,
					args = {
						topPanelGroup = {
							order = 1,
							type = "group",
							name = "Top Panel",
							guiInline = true,
							args = {
								enable = {
									order = 1, type = "toggle", name = L["Enable"],
									get = function() return E.db.general.topPanel end,
									set = function(_, value) E.db.general.topPanel = value Layout:TopPanelVisibility() end,
								},
								texture = {
									order = 2, type = "select", dialogControl = "LSM30_Statusbar", name = "Texture",
									values = AceGUIWidgetLSMlists.statusbar,
									get = function() return E.db.general.topPanelSettings.texture end,
									set = function(_, value) E.db.general.topPanelSettings.texture = value Layout:TopPanelVisibility() end,
									disabled = function() return not E.db.general.topPanel end,
								},
								alpha = {
									order = 3, type = "range", name = "Opacity", isPercent = true,
									min = 0, max = 1, step = 0.05,
									get = function() return E.db.general.topPanelSettings.alpha end,
									set = function(_, value) E.db.general.topPanelSettings.alpha = value Layout:TopPanelVisibility() end,
									disabled = function() return not E.db.general.topPanel end,
								},
								height = {
									order = 4, type = "range", name = "Height",
									min = 2, max = 100, step = 1,
									get = function() return E.db.general.topPanelSettings.height end,
									set = function(_, value) E.db.general.topPanelSettings.height = value Layout:TopPanelVisibility() end,
									disabled = function() return not E.db.general.topPanel end,
								},
								offset = {
									order = 5, type = "range", name = "Outside Offset",
									desc = "Moves the panel farther outside the top edge of the screen.",
									min = 0, max = 100, step = 1,
									get = function() return E.db.general.topPanelSettings.offset end,
									set = function(_, value) E.db.general.topPanelSettings.offset = value Layout:TopPanelVisibility() end,
									disabled = function() return not E.db.general.topPanel end,
								},
							},
						},
						bottomPanelGroup = {
							order = 2,
							type = "group",
							name = "Bottom Panel",
							guiInline = true,
							args = {
								enable = {
									order = 1, type = "toggle", name = L["Enable"],
									get = function() return E.db.general.bottomPanel end,
									set = function(_, value) E.db.general.bottomPanel = value Layout:BottomPanelVisibility() end,
								},
								texture = {
									order = 2, type = "select", dialogControl = "LSM30_Statusbar", name = "Texture",
									values = AceGUIWidgetLSMlists.statusbar,
									get = function() return E.db.general.bottomPanelSettings.texture end,
									set = function(_, value) E.db.general.bottomPanelSettings.texture = value Layout:BottomPanelVisibility() end,
									disabled = function() return not E.db.general.bottomPanel end,
								},
								alpha = {
									order = 3, type = "range", name = "Opacity", isPercent = true,
									min = 0, max = 1, step = 0.05,
									get = function() return E.db.general.bottomPanelSettings.alpha end,
									set = function(_, value) E.db.general.bottomPanelSettings.alpha = value Layout:BottomPanelVisibility() end,
									disabled = function() return not E.db.general.bottomPanel end,
								},
								height = {
									order = 4, type = "range", name = "Height",
									min = 2, max = 100, step = 1,
									get = function() return E.db.general.bottomPanelSettings.height end,
									set = function(_, value) E.db.general.bottomPanelSettings.height = value Layout:BottomPanelVisibility() end,
									disabled = function() return not E.db.general.bottomPanel end,
								},
								offset = {
									order = 5, type = "range", name = "Outside Offset",
									desc = "Moves the panel farther outside the bottom edge of the screen.",
									min = 0, max = 100, step = 1,
									get = function() return E.db.general.bottomPanelSettings.offset end,
									set = function(_, value) E.db.general.bottomPanelSettings.offset = value Layout:BottomPanelVisibility() end,
									disabled = function() return not E.db.general.bottomPanel end,
								},
							},
						},
					},
				},
				bottomPanel = {
					order = 9,
					type = "toggle",
					name = L["Bottom Panel"],
					desc = L["Display a panel across the bottom of the screen. This is for cosmetic only."],
					set = function(info, value) E.db.general.bottomPanel = value Layout:BottomPanelVisibility() end
				},
				topPanel = {
					order = 10,
					type = "toggle",
					name = L["Top Panel"],
					desc = L["Display a panel across the top of the screen. This is for cosmetic only."],
					set = function(info, value) E.db.general.topPanel = value Layout:TopPanelVisibility() end
				},
				afk = {
					order = 11,
					type = "toggle",
					name = L["AFK Mode"],
					desc = L["When you go AFK display the AFK screen."],
					set = function(info, value) E.db.general.afk = value AFK:Toggle() end
				},
				decimalLength = {
					order = 12,
					type = "range",
					name = L["Decimal Length"],
					desc = L["Controls the amount of decimals used in values displayed on elements like NamePlates and UnitFrames."],
					min = 0, max = 4, step = 1,
					set = function(info, value)
						E.db.general.decimalLength = value
						E:BuildPrefixValues()
						E:StaticPopup_Show("CONFIG_RL")
					end
				},
				numberPrefixStyle = {
					order = 13,
					type = "select",
					name = L["Unit Prefix Style"],
					desc = L["The unit prefixes you want to use when values are shortened in ElvUI. This is mostly used on UnitFrames."],
					set = function(info, value)
						E.db.general.numberPrefixStyle = value
						E:BuildPrefixValues()
						E:StaticPopup_Show("CONFIG_RL")
					end,
					values = {
						["CHINESE"] = "Chinese (W, Y)",
						["ENGLISH"] = "English (K, M, B)",
						["GERMAN"] = "German (Tsd, Mio, Mrd)",
						["KOREAN"] = "Korean (천, 만, 억)",
						["METRIC"] = "Metric (k, M, G)"
					}
				},
				smoothingAmount = {
					order = 14,
					type = "range",
					isPercent = true,
					name = L["Smoothing Amount"],
					desc = L["Controls the speed at which smoothed bars will be updated."],
					min = 0.1, max = 0.8, softMax = 0.75, softMin = 0.25, step = 0.01,
					set = function(info, value)
						E.db.general.smoothingAmount = value
						E:SetSmoothingAmount(value)
					end
				},
				locale = {
					order = 15,
					type = "select",
					name = L["LANGUAGE"],
					get = function(info) return E.global.general.locale end,
					set = function(info, value)
						E.global.general.locale = value
						E:StaticPopup_Show("CONFIG_RL")
					end,
					values = {
						["deDE"] = "Deutsch",
						["enUS"] = "English",
						["esMX"] = "Español",
						["frFR"] = "Français",
						["ptBR"] = "Português",
						["ruRU"] = "Русский",
						["zhCN"] = "简体中文",
						["zhTW"] = "正體中文",
						["koKR"] = "한국어"
					}
				}
			}
		},
		media = {
			order = 3,
			type = "group",
			name = L["Media"],
			get = function(info) return E.db.general[info[#info]] end,
			set = function(info, value) E.db.general[info[#info]] = value end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Media"]
				},
				fontGroup = {
					order = 2,
					type = "group",
					name = L["Font"],
					guiInline = true,
					args = {
						font = {
							order = 1,
							type = "select", dialogControl = "LSM30_Font",
							name = L["Default Font"],
							desc = L["The font that the core of the UI will use."],
							values = AceGUIWidgetLSMlists.font,
							set = function(info, value) E.db.general[info[#info]] = value E:UpdateMedia() E:UpdateFontTemplates() end
						},
						fontSize = {
							order = 2,
							type = "range",
							name = L["FONT_SIZE"],
							desc = L["Set the font size for everything in UI. Note: This doesn't effect somethings that have their own seperate options (UnitFrame Font, Datatext Font, ect..)"],
							min = 4, max = 32, step = 1,
							set = function(info, value) E.db.general[info[#info]] = value E:UpdateMedia() E:UpdateFontTemplates() end
						},
						fontStyle = {
							order = 3,
							type = "select",
							name = L["Font Outline"],
							values = C.Values.FontFlags,
							set = function(info, value) E.db.general[info[#info]] = value E:UpdateMedia() E:UpdateFontTemplates() end
						},
						applyFontToAll = {
							order = 4,
							type = "execute",
							name = L["Apply Font To All"],
							desc = L["Applies the font and font size settings throughout the entire user interface. Note: Some font size settings will be skipped due to them having a smaller font size by default."],
							func = function() E:StaticPopup_Show("APPLY_FONT_WARNING") end
						},
						dmgfont = {
							order = 5,
							type = "select", dialogControl = "LSM30_Font",
							name = L["CombatText Font"],
							desc = L["The font that combat text will use. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"],
							values = AceGUIWidgetLSMlists.font,
							get = function(info) return E.private.general[info[#info]] end,
							set = function(info, value) E.private.general[info[#info]] = value E:UpdateMedia() E:UpdateFontTemplates() E:StaticPopup_Show("PRIVATE_RL") end
						},
						namefont = {
							order = 6,
							type = "select", dialogControl = "LSM30_Font",
							name = L["Name Font"],
							desc = L["The font that appears on the text above players heads. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"],
							values = AceGUIWidgetLSMlists.font,
							get = function(info) return E.private.general[info[#info]] end,
							set = function(info, value) E.private.general[info[#info]] = value E:UpdateMedia() E:UpdateFontTemplates() E:StaticPopup_Show("PRIVATE_RL") end
						},
						replaceBlizzFonts = {
							order = 7,
							type = "toggle",
							name = L["Replace Blizzard Fonts"],
							desc = L["Replaces the default Blizzard fonts on various panels and frames with the fonts chosen in the Media section of the ElvUI Options. NOTE: Any font that inherits from the fonts ElvUI usually replaces will be affected as well if you disable this. Enabled by default."],
							get = function(info) return E.private.general[info[#info]] end,
							set = function(info, value) E.private.general[info[#info]] = value E:StaticPopup_Show("PRIVATE_RL") end
						}
					}
				},
				textureGroup = {
					order = 3,
					type = "group",
					name = L["Textures"],
					guiInline = true,
					get = function(info) return E.private.general[info[#info]] end,
					args = {
						normTex = {
							order = 1,
							type = "select", dialogControl = "LSM30_Statusbar",
							name = L["Primary Texture"],
							desc = L["The texture that will be used mainly for statusbars."],
							values = AceGUIWidgetLSMlists.statusbar,
							set = function(info, value)
								local previousValue = E.private.general[info[#info]]
								E.private.general[info[#info]] = value

								if E.db.unitframe.statusbar == previousValue then
									E.db.unitframe.statusbar = value
									E:UpdateAll(true)
								else
									E:UpdateMedia()
									E:UpdateStatusBars()
								end
							end
						},
						glossTex = {
							order = 2,
							type = "select", dialogControl = "LSM30_Statusbar",
							name = L["Secondary Texture"],
							desc = L["This texture will get used on objects like chat windows and dropdown menus."],
							values = AceGUIWidgetLSMlists.statusbar,
							set = function(info, value)
								E.private.general[info[#info]] = value
								E:UpdateMedia()
								E:UpdateFrameTemplates()
							end
						},
						applyTextureToAll = {
							order = 3,
							type = "execute",
							name = L["Apply Texture To All"],
							desc = L["Applies the primary texture to all statusbars."],
							func = function()
								local texture = E.private.general.normTex
								E.db.unitframe.statusbar = texture
								E.db.nameplates.statusbar = texture
								E:UpdateAll(true)
							end
						}
					}
				},
				colorsGroup = {
					order = 4,
					type = "group",
					name = L["COLORS"],
					guiInline = true,
					get = function(info)
						local t = E.db.general[info[#info]]
						local d = P.general[info[#info]]
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
					end,
					set = function(info, r, g, b, a)
						local setting = info[#info]
						local t = E.db.general[setting]
						t.r, t.g, t.b, t.a = r, g, b, a
						E:UpdateMedia()
						if setting == "bordercolor" then
							E:UpdateBorderColors()
						elseif setting == "backdropcolor" or setting == "backdropfadecolor" then
							E:UpdateBackdropColors()
						end
					end,
					args = {
						bordercolor = {
							order = 1,
							type = "color",
							name = L["Border Color"],
							desc = L["Main border color of the UI."],
							hasAlpha = false,
						},
						backdropcolor = {
							order = 2,
							type = "color",
							name = L["Backdrop Color"],
							desc = L["Main backdrop color of the UI."],
							hasAlpha = false,
						},
						backdropfadecolor = {
							order = 3,
							type = "color",
							name = L["Backdrop Faded Color"],
							desc = L["Backdrop color of transparent frames"],
							hasAlpha = true,
						},
						valuecolor = {
							order = 4,
							type = "color",
							name = L["Value Color"],
							desc = L["Color some texts use."],
							hasAlpha = false,
						},
						cropIcon = {
							order = 5,
							type = "toggle",
							tristate = true,
							name = L["Crop Icons"],
							desc = L["This is for Customized Icons in your Interface/Icons folder."],
							get = function(info)
								local value = E.db.general[info[#info]]
								if value == 2 then return true
								elseif value == 1 then return nil
								else return false end
							end,
							set = function(info, value)
								E.db.general[info[#info]] = (value and 2) or (value == nil and 1) or 0
								E:StaticPopup_Show("PRIVATE_RL")
							end
						}
					}
				}
			}
		},
		totems = {
			order = 4,
			type = "group",
			name = L["Class Totems"],
			get = function(info) return E.db.general.totems[info[#info]] end,
			set = function(info, value) E.db.general.totems[info[#info]] = value Totems:PositionAndSize() end,
			hidden = function() return E.myclass ~= "SHAMAN" end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = TUTORIAL_TITLE47
				},
				enable = {
					order = 2,
					type = "toggle",
					name = L["Enable"],
					set = function(info, value) E.db.general.totems[info[#info]] = value Totems:ToggleEnable() end
				},
				size = {
					order = 3,
					type = "range",
					name = L["Button Size"],
					min = 24, max = 60, step = 1,
					disabled = function() return not E.db.general.totems.enable end
				},
				spacing = {
					order = 4,
					type = "range",
					name = L["Button Spacing"],
					min = 1, max = 10, step = 1,
					disabled = function() return not E.db.general.totems.enable end
				},
				sortDirection = {
					order = 5,
					type = "select",
					name = L["Sort Direction"],
					values = {
						["ASCENDING"] = L["Ascending"],
						["DESCENDING"] = L["Descending"]
					},
					disabled = function() return not E.db.general.totems.enable end
				},
				growthDirection = {
					order = 6,
					type = "select",
					name = L["Bar Direction"],
					values = {
						["VERTICAL"] = L["Vertical"],
						["HORIZONTAL"] = L["Horizontal"]
					},
					disabled = function() return not E.db.general.totems.enable end
				}
			}
		},
		chatBubblesGroup = {
			order = 5,
			type = "group",
			name = L["Chat Bubbles"],
			get = function(info) return E.private.general[info[#info]] end,
			set = function(info, value) E.private.general[info[#info]] = value E:StaticPopup_Show("PRIVATE_RL") end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Chat Bubbles"]
				},
				chatBubbles = {
					order = 2,
					type = "select",
					name = L["Chat Bubbles Style"],
					desc = L["Skin the blizzard chat bubbles."],
					values = {
						["backdrop"] = L["Skin Backdrop"],
						["nobackdrop"] = L["Remove Backdrop"],
						["backdrop_noborder"] = L["Skin Backdrop (No Borders)"],
						["disabled"] = L["DISABLE"]
					}
				},
				chatBubbleFont = {
					order = 3,
					type = "select",
					name = L["Font"],
					dialogControl = "LSM30_Font",
					values = AceGUIWidgetLSMlists.font,
					disabled = function() return E.private.general.chatBubbles == "disabled" end
				},
				chatBubbleFontSize = {
					order = 4,
					type = "range",
					name = L["FONT_SIZE"],
					min = 4, max = 32, step = 1,
					disabled = function() return E.private.general.chatBubbles == "disabled" end
				},
				chatBubbleFontOutline = {
					order = 5,
					type = "select",
					name = L["Font Outline"],
					disabled = function() return E.private.general.chatBubbles == "disabled" end,
					values = C.Values.FontFlags
				},
				chatBubbleName = {
					order = 6,
					type = "toggle",
					name = L["Chat Bubble Names"],
					desc = L["Display the name of the unit on the chat bubble."],
					disabled = function() return E.private.general.chatBubbles == "disabled" or E.private.general.chatBubbles == "nobackdrop" end
				}
			}
		},
		objectiveFrameGroup = {
			order = 6,
			type = "group",
			name = L["Objective Frame"],
			get = function(info) return E.db.general[info[#info]] end,
			args = {
				objectiveFrameHeader = {
					order = 1,
					type = "header",
					name = L["Objective Frame"],
				},
				watchFrameAutoHide = {
					order = 2,
					type = "toggle",
					name = L["Auto Hide"],
					desc = L["Automatically hide the objetive frame during boss or arena fights."],
					set = function(info, value) E.db.general.watchFrameAutoHide = value; Blizzard:SetObjectiveFrameAutoHide() end,
				},
				watchFrameHeight = {
					order = 3,
					type = "range",
					name = L["Objective Frame Height"],
					desc = L["Height of the objective tracker. Increase size to be able to see more objectives."],
					min = 400, max = E.screenheight, step = 1,
					set = function(info, value) E.db.general.watchFrameHeight = value; Blizzard:SetWatchFrameHeight() end,
				},
				watchFrameWidth = {
					order = 4,
					type = "range",
					name = L["Objective Frame Width"],
					desc = L["Width of the objective tracker. A wider tracker reduces text wrapping."],
					min = 160, max = 600, step = 1,
					set = function(info, value) E.db.general.watchFrameWidth = value; Blizzard:RefreshWatchFrameLayout() end,
				},
				watchFrameFont = {
					order = 5,
					type = "select", dialogControl = "LSM30_Font",
					name = L["Objective Tracker Font"],
					desc = L["Font used by the objective tracker."],
					values = AceGUIWidgetLSMlists.font,
					set = function(info, value) E.db.general.watchFrameFont = value; Blizzard:RefreshWatchFrameLayout() end,
				},
				watchFrameFontSize = {
					order = 6,
					type = "range",
					name = L["Objective Tracker Font Size"],
					min = 6, max = 32, step = 1,
					set = function(info, value) E.db.general.watchFrameFontSize = value; Blizzard:RefreshWatchFrameLayout() end,
				},
				watchFrameFontOutline = {
					order = 7,
					type = "select",
					name = L["Objective Tracker Font Outline"],
					values = C.Values.FontFlags,
					set = function(info, value) E.db.general.watchFrameFontOutline = value; Blizzard:RefreshWatchFrameLayout() end,
				},
				watchFrameAutoLineSpacing = {
					order = 8,
					type = "toggle",
					name = L["Automatic Tracker Line Spacing"],
					desc = L["Automatically increases the vertical spacing when a larger objective tracker font is used."],
					set = function(info, value) E.db.general.watchFrameAutoLineSpacing = value; Blizzard:RefreshWatchFrameLayout() end,
				},
				watchFrameLineSpacing = {
					order = 9,
					type = "range",
					name = L["Extra Tracker Line Spacing"],
					desc = L["Adds extra vertical space between wrapped objective tracker lines."],
					min = 0, max = 20, step = 1,
					disabled = function() return E.db.general.watchFrameAutoLineSpacing end,
					set = function(info, value) E.db.general.watchFrameLineSpacing = value; Blizzard:RefreshWatchFrameLayout() end,
				},
			},
		},
		threatGroup = {
			order = 7,
			type = "group",
			name = L["Threat"],
			get = function(info) return E.db.general.threat[info[#info]] end,
			args = {
				threatHeader = {
					order = 1,
					type = "header",
					name = L["Threat"]
				},
				enable = {
					order = 2,
					type = "toggle",
					name = L["Enable"],
					set = function(info, value)
						E.db.general.threat.enable = value
						Threat:ToggleEnable()
					end
				},
				preview = {
					order = 3,
					type = "toggle",
					name = "Preview",
					desc = "Show the threat bar with a sample value while configuring it.",
					get = function() return Threat.preview or false end,
					set = function(_, value) Threat:SetPreview(value) end,
					disabled = function() return not E.db.general.threat.enable end
				},
				detach = {
					order = 4,
					type = "toggle",
					name = "Detach",
					desc = "Detach the threat bar from the chat datatext panel and use its own mover.",
					set = function(info, value)
						E.db.general.threat.detach = value
						Threat:UpdatePosition()
					end,
					disabled = function() return not E.db.general.threat.enable end
				},
				position = {
					order = 5,
					type = "select",
					name = L["Position"],
					desc = L["Adjust the position of the threat bar to either the left or right datatext panels."],
					values = {
						["LEFTCHAT"] = L["Left Chat"],
						["RIGHTCHAT"] = L["Right Chat"]
					},
					set = function(info, value)
						E.db.general.threat.position = value
						Threat:UpdatePosition()
					end,
					disabled = function()
						return not E.db.general.threat.enable or E.db.general.threat.detach
					end
				},
				width = {
					order = 6,
					type = "range",
					name = "Width",
					min = 100, max = 1000, step = 1,
					set = function(info, value)
						E.db.general.threat.width = value
						Threat:UpdatePosition()
					end,
					disabled = function()
						return not E.db.general.threat.enable or not E.db.general.threat.detach
					end
				},
				height = {
					order = 7,
					type = "range",
					name = "Height",
					min = 8, max = 100, step = 1,
					set = function(info, value)
						E.db.general.threat.height = value
						Threat:UpdatePosition()
					end,
					disabled = function()
						return not E.db.general.threat.enable or not E.db.general.threat.detach
					end
				},
				appearanceHeader = {
					order = 10,
					type = "header",
					name = "Appearance"
				},
				texture = {
					order = 11,
					type = "select",
					dialogControl = "LSM30_Statusbar",
					name = "Statusbar Texture",
					values = AceGUIWidgetLSMlists.statusbar,
					set = function(info, value)
						E.db.general.threat.texture = value
						Threat:UpdateAppearance()
					end,
					disabled = function() return not E.db.general.threat.enable end
				},
				font = {
					order = 12,
					type = "select",
					dialogControl = "LSM30_Font",
					name = L["Font"],
					values = AceGUIWidgetLSMlists.font,
					set = function(info, value)
						E.db.general.threat.font = value
						Threat:UpdateAppearance()
					end,
					disabled = function() return not E.db.general.threat.enable end
				},
				textColor = {
					order = 13,
					type = "color",
					name = "Font Color",
					get = function()
						local c = E.db.general.threat.textColor
						return c.r, c.g, c.b
					end,
					set = function(_, r, g, b)
						local c = E.db.general.threat.textColor
						c.r, c.g, c.b = r, g, b
						Threat:UpdateAppearance()
					end,
					disabled = function() return not E.db.general.threat.enable end
				},
				textSize = {
					order = 14,
					type = "range",
					name = L["FONT_SIZE"],
					min = 6, max = 22, step = 1,
					set = function(info, value)
						E.db.general.threat.textSize = value
						Threat:UpdateAppearance()
					end,
					disabled = function() return not E.db.general.threat.enable end
				},
				textOutline = {
					order = 15,
					type = "select",
					name = L["Font Outline"],
					values = C.Values.FontFlags,
					set = function(info, value)
						E.db.general.threat.textOutline = value
						Threat:UpdateAppearance()
					end,
					disabled = function() return not E.db.general.threat.enable end
				},
				textX = {
					order = 16,
					type = "range",
					name = "Text X Offset",
					min = -200, max = 200, step = 1,
					set = function(info, value)
						E.db.general.threat.textX = value
						Threat:UpdateAppearance()
					end,
					disabled = function() return not E.db.general.threat.enable end
				},
				textY = {
					order = 17,
					type = "range",
					name = "Text Y Offset",
					min = -100, max = 100, step = 1,
					set = function(info, value)
						E.db.general.threat.textY = value
						Threat:UpdateAppearance()
					end,
					disabled = function() return not E.db.general.threat.enable end
				},
				colorsHeader = {
					order = 30,
					type = "header",
					name = "Threat Colors"
				},
				customColors = {
					order = 31,
					type = "toggle",
					name = "Custom Colors",
					desc = "Use the colors below instead of Blizzard's automatic threat colors.",
					set = function(info, value)
						E.db.general.threat.customColors = value
						if Threat.preview then Threat:ShowPreview() else Threat:Update() end
					end,
					disabled = function() return not E.db.general.threat.enable end
				},
				gradient = {
					order = 32,
					type = "toggle",
					name = "Gradient",
					desc = "Blend each Base Color into its Gradient Color.",
					set = function(info, value)
						E.db.general.threat.gradient = value
						if Threat.preview then Threat:ShowPreview() else Threat:Update() end
					end,
					disabled = function()
						return not E.db.general.threat.enable or not E.db.general.threat.customColors
					end
				}
			}
		},
		blizzUIImprovements = {
			order = 8,
			type = "group",
			name = L["BlizzUI Improvements"],
			get = function(info) return E.db.general[info[#info]] end,
			set = function(info, value) E.db.general[info[#info]] = value end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["BlizzUI Improvements"]
				},
				loot = {
					order = 2,
					type = "toggle",
					name = L["LOOT"],
					desc = L["Enable/Disable the loot frame."],
					get = function(info) return E.private.general[info[#info]] end,
					set = function(info, value)
						E.private.general[info[#info]] = value
						E:StaticPopup_Show("PRIVATE_RL")
					end
				},
				lootRoll = {
					order = 3,
					type = "toggle",
					name = L["Loot Roll"],
					desc = L["Enable/Disable the loot roll frame."],
					get = function(info) return E.private.general[info[#info]] end,
					set = function(info, value)
						E.private.general[info[#info]] = value
						E:StaticPopup_Show("PRIVATE_RL")
					end
				},
				-- PR1: misc-lootroll BEGIN
				lootRollGroup = {
					order = 3.5,
					type = "group",
					name = L["Loot Roll Options"],
					guiInline = true,
					disabled = function() return not E.private.general.lootRoll end,
					get = function(info) return E.db.general.lootRoll[info[#info]] end,
					set = function(info, value)
						E.db.general.lootRoll[info[#info]] = value
						Misc:UpdateLootRoll()
					end,
					args = {
						width = {
							order = 1,
							type = "range",
							name = L["Width"],
							min = 200, max = 500, step = 1,
						},
						height = {
							order = 2,
							type = "range",
							name = L["Height"],
							min = 18, max = 50, step = 1,
						},
						font = {
							order = 3,
							type = "select",
							dialogControl = "LSM30_Font",
							name = L["Font"],
							values = AceGUIWidgetLSMlists.font,
						},
						fontSize = {
							order = 4,
							type = "range",
							name = L["Font Size"],
							min = 6, max = 32, step = 1,
						},
						fontOutline = {
							order = 5,
							type = "select",
							name = L["Font Outline"],
							values = C.Values.FontFlags,
						},
						rollCountFont = {
							order = 5.1,
							type = "select",
							dialogControl = "LSM30_Font",
							name = L["Count Font"],
							desc = L["Font for the roll count number on roll buttons."],
							values = AceGUIWidgetLSMlists.font,
							get = function(info) return E.db.general.lootRoll.rollCountFont or "Homespun" end,
						},
						rollCountFontSize = {
							order = 5.2,
							type = "range",
							name = L["Count Font Size"],
							min = 6, max = 32, step = 1,
							get = function(info) return E.db.general.lootRoll.rollCountFontSize or 10 end,
						},
						rollCountFontOutline = {
							order = 5.3,
							type = "select",
							name = L["Count Font Outline"],
							values = C.Values.FontFlags,
							get = function(info) return E.db.general.lootRoll.rollCountFontOutline or "MONOCHROMEOUTLINE" end,
						},
						rollCountXOffset = {
							order = 5.4,
							type = "range",
							name = L["Count X Offset"],
							min = -20, max = 20, step = 1,
							get = function(info) return E.db.general.lootRoll.rollCountXOffset or 0 end,
						},
						rollCountYOffset = {
							order = 5.5,
							type = "range",
							name = L["Count Y Offset"],
							min = -20, max = 20, step = 1,
							get = function(info) return E.db.general.lootRoll.rollCountYOffset or 0 end,
						},
						transparency = {
							order = 6,
							type = "range",
							name = L["Transparency"],
							min = 0, max = 1, step = 0.05,
							isPercent = true,
						},
						useQualityColor = {
							order = 7,
							type = "toggle",
							name = L["Quality Color Background"],
							desc = L["Color the loot roll frame background based on the quality of the item."],
						},
						bgColor = {
							order = 8,
							type = "color",
							name = L["Background Color"],
							disabled = function() return E.db.general.lootRoll.useQualityColor end,
							get = function(info)
								local c = E.db.general.lootRoll.bgColor or {r = 0.06, g = 0.06, b = 0.06}
								return c.r, c.g, c.b
							end,
							set = function(info, r, g, b)
								E.db.general.lootRoll.bgColor = {r = r, g = g, b = b}
								Misc:UpdateLootRoll()
							end,
						},
						testRoll = {
							order = 9,
							type = "execute",
							name = L["Preview Loot Roll"],
							func = function() Misc:TestLootRoll() end,
						},
						texture = {
							order = 10,
							type = "select",
							dialogControl = "LSM30_Statusbar",
							name = L["Texture"],
							values = AceGUIWidgetLSMlists.statusbar,
						},
						backgroundTexture = {
							order = 11,
							type = "select",
							dialogControl = "LSM30_Statusbar",
							name = "Background Texture",
							values = AceGUIWidgetLSMlists.statusbar,
							get = function() return E.db.general.lootRoll.backgroundTexture or "ElvUI Blank" end,
						},
						gradient = {
							order = 12,
							type = "toggle",
							name = "Gradient",
							desc = "Draw the roll timer from the quality color to its gradient color.",
						},
						customColors = {
							order = 13,
							type = "toggle",
							name = "Custom Quality Colors",
							desc = "Use your own quality colors for the roll timer.",
						},
						qualityColors = {
							order = 14,
							type = "group",
							name = "Quality Colors",
							guiInline = true,
							disabled = function() return not E.private.general.lootRoll or not (E.db.general.lootRoll.customColors or E.db.general.lootRoll.gradient) end,
							args = {
								q0Base = {
									order = 10, type = "color", name = (_G["ITEM_QUALITY0_DESC"] or "Poor"),
									disabled = function() return not E.db.general.lootRoll.customColors end,
									get = function() local c = E.db.general.lootRoll.colors[0] return c.r, c.g, c.b end,
									set = function(_, r, g, b) local c = E.db.general.lootRoll.colors[0] c.r, c.g, c.b = r, g, b Misc:UpdateLootRoll() end,
								},
								q0Gradient = {
									order = 11, type = "color", name = "Gradient",
									disabled = function() return not E.db.general.lootRoll.gradient end,
									get = function() local c = E.db.general.lootRoll.gradientColors[0] return c.r, c.g, c.b end,
									set = function(_, r, g, b) local c = E.db.general.lootRoll.gradientColors[0] c.r, c.g, c.b = r, g, b Misc:UpdateLootRoll() end,
								},
								q0Break = {order = 12, type = "description", name = "", width = "full"},
								q1Base = {
									order = 13, type = "color", name = (_G["ITEM_QUALITY1_DESC"] or "Common"),
									disabled = function() return not E.db.general.lootRoll.customColors end,
									get = function() local c = E.db.general.lootRoll.colors[1] return c.r, c.g, c.b end,
									set = function(_, r, g, b) local c = E.db.general.lootRoll.colors[1] c.r, c.g, c.b = r, g, b Misc:UpdateLootRoll() end,
								},
								q1Gradient = {
									order = 14, type = "color", name = "Gradient",
									disabled = function() return not E.db.general.lootRoll.gradient end,
									get = function() local c = E.db.general.lootRoll.gradientColors[1] return c.r, c.g, c.b end,
									set = function(_, r, g, b) local c = E.db.general.lootRoll.gradientColors[1] c.r, c.g, c.b = r, g, b Misc:UpdateLootRoll() end,
								},
								q1Break = {order = 15, type = "description", name = "", width = "full"},
								q2Base = {
									order = 16, type = "color", name = (_G["ITEM_QUALITY2_DESC"] or "Uncommon"),
									disabled = function() return not E.db.general.lootRoll.customColors end,
									get = function() local c = E.db.general.lootRoll.colors[2] return c.r, c.g, c.b end,
									set = function(_, r, g, b) local c = E.db.general.lootRoll.colors[2] c.r, c.g, c.b = r, g, b Misc:UpdateLootRoll() end,
								},
								q2Gradient = {
									order = 17, type = "color", name = "Gradient",
									disabled = function() return not E.db.general.lootRoll.gradient end,
									get = function() local c = E.db.general.lootRoll.gradientColors[2] return c.r, c.g, c.b end,
									set = function(_, r, g, b) local c = E.db.general.lootRoll.gradientColors[2] c.r, c.g, c.b = r, g, b Misc:UpdateLootRoll() end,
								},
								q2Break = {order = 18, type = "description", name = "", width = "full"},
								q3Base = {
									order = 19, type = "color", name = (_G["ITEM_QUALITY3_DESC"] or "Rare"),
									disabled = function() return not E.db.general.lootRoll.customColors end,
									get = function() local c = E.db.general.lootRoll.colors[3] return c.r, c.g, c.b end,
									set = function(_, r, g, b) local c = E.db.general.lootRoll.colors[3] c.r, c.g, c.b = r, g, b Misc:UpdateLootRoll() end,
								},
								q3Gradient = {
									order = 20, type = "color", name = "Gradient",
									disabled = function() return not E.db.general.lootRoll.gradient end,
									get = function() local c = E.db.general.lootRoll.gradientColors[3] return c.r, c.g, c.b end,
									set = function(_, r, g, b) local c = E.db.general.lootRoll.gradientColors[3] c.r, c.g, c.b = r, g, b Misc:UpdateLootRoll() end,
								},
								q3Break = {order = 21, type = "description", name = "", width = "full"},
								q4Base = {
									order = 22, type = "color", name = (_G["ITEM_QUALITY4_DESC"] or "Epic"),
									disabled = function() return not E.db.general.lootRoll.customColors end,
									get = function() local c = E.db.general.lootRoll.colors[4] return c.r, c.g, c.b end,
									set = function(_, r, g, b) local c = E.db.general.lootRoll.colors[4] c.r, c.g, c.b = r, g, b Misc:UpdateLootRoll() end,
								},
								q4Gradient = {
									order = 23, type = "color", name = "Gradient",
									disabled = function() return not E.db.general.lootRoll.gradient end,
									get = function() local c = E.db.general.lootRoll.gradientColors[4] return c.r, c.g, c.b end,
									set = function(_, r, g, b) local c = E.db.general.lootRoll.gradientColors[4] c.r, c.g, c.b = r, g, b Misc:UpdateLootRoll() end,
								},
								q4Break = {order = 24, type = "description", name = "", width = "full"},
								q5Base = {
									order = 25, type = "color", name = (_G["ITEM_QUALITY5_DESC"] or "Legendary"),
									disabled = function() return not E.db.general.lootRoll.customColors end,
									get = function() local c = E.db.general.lootRoll.colors[5] return c.r, c.g, c.b end,
									set = function(_, r, g, b) local c = E.db.general.lootRoll.colors[5] c.r, c.g, c.b = r, g, b Misc:UpdateLootRoll() end,
								},
								q5Gradient = {
									order = 26, type = "color", name = "Gradient",
									disabled = function() return not E.db.general.lootRoll.gradient end,
									get = function() local c = E.db.general.lootRoll.gradientColors[5] return c.r, c.g, c.b end,
									set = function(_, r, g, b) local c = E.db.general.lootRoll.gradientColors[5] c.r, c.g, c.b = r, g, b Misc:UpdateLootRoll() end,
								},
								q5Break = {order = 27, type = "description", name = "", width = "full"},
								q6Base = {
									order = 28, type = "color", name = (_G["ITEM_QUALITY6_DESC"] or "Artifact"),
									disabled = function() return not E.db.general.lootRoll.customColors end,
									get = function() local c = E.db.general.lootRoll.colors[6] return c.r, c.g, c.b end,
									set = function(_, r, g, b) local c = E.db.general.lootRoll.colors[6] c.r, c.g, c.b = r, g, b Misc:UpdateLootRoll() end,
								},
								q6Gradient = {
									order = 29, type = "color", name = "Gradient",
									disabled = function() return not E.db.general.lootRoll.gradient end,
									get = function() local c = E.db.general.lootRoll.gradientColors[6] return c.r, c.g, c.b end,
									set = function(_, r, g, b) local c = E.db.general.lootRoll.gradientColors[6] c.r, c.g, c.b = r, g, b Misc:UpdateLootRoll() end,
								},
								q6Break = {order = 30, type = "description", name = "", width = "full"},
								q7Base = {
									order = 31, type = "color", name = (_G["ITEM_QUALITY7_DESC"] or "Heirloom"),
									disabled = function() return not E.db.general.lootRoll.customColors end,
									get = function() local c = E.db.general.lootRoll.colors[7] return c.r, c.g, c.b end,
									set = function(_, r, g, b) local c = E.db.general.lootRoll.colors[7] c.r, c.g, c.b = r, g, b Misc:UpdateLootRoll() end,
								},
								q7Gradient = {
									order = 32, type = "color", name = "Gradient",
									disabled = function() return not E.db.general.lootRoll.gradient end,
									get = function() local c = E.db.general.lootRoll.gradientColors[7] return c.r, c.g, c.b end,
									set = function(_, r, g, b) local c = E.db.general.lootRoll.gradientColors[7] c.r, c.g, c.b = r, g, b Misc:UpdateLootRoll() end,
								},
								q7Break = {order = 33, type = "description", name = "", width = "full"},
								reset = {
									order = 50, type = "execute", name = "Reset Colors",
									func = function()
										E.db.general.lootRoll.colors = E:CopyTable({}, P.general.lootRoll.colors)
										E.db.general.lootRoll.gradientColors = E:CopyTable({}, P.general.lootRoll.gradientColors)
										Misc:UpdateLootRoll()
									end,
								},
							},
						},
					},
				},
				-- PR1: misc-lootroll END
				hideErrorFrame = {
					order = 4,
					type = "toggle",
					name = L["Hide Error Text"],
					desc = L["Hides the red error text at the top of the screen while in combat."],
					set = function(info, value)
						E.db.general[info[#info]] = value
						Misc:ToggleErrorHandling()
					end
				},
				enhancedPvpMessages = {
					order = 5,
					type = "toggle",
					name = L["Enhanced PVP Messages"],
					desc = L["Display battleground messages in the middle of the screen."],
				},
				raidUtility = {
					order = 7,
					type = "toggle",
					name = L["RAID_CONTROL"],
					desc = L["Enables the ElvUI Raid Control panel."],
					get = function(info) return E.private.general[info[#info]] end,
					set = function(info, value)
						E.private.general[info[#info]] = value
						E:StaticPopup_Show("PRIVATE_RL")
					end
				},
				vehicleSeatIndicatorSize = {
					order = 8,
					type = "range",
					name = L["Vehicle Seat Indicator Size"],
					min = 64, max = 128, step = 4,
					set = function(info, value)
						E.db.general[info[#info]] = value
						Blizzard:UpdateVehicleFrame()
					end
				}
			}
		},
		misc = {
			order = 9,
			type = "group",
			name = L["MISCELLANEOUS"],
			get = function(info) return E.db.general[info[#info]] end,
			set = function(info, value) E.db.general[info[#info]] = value end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["MISCELLANEOUS"]
				},
				interruptAnnounce = {
					order = 2,
					type = "select",
					name = L["Announce Interrupts"],
					desc = L["Announce when you interrupt a spell to the specified chat channel."],
					values = {
						["NONE"] = L["NONE"],
						["SAY"] = L["SAY"],
						["PARTY"] = L["Party Only"],
						["RAID"] = L["Party / Raid"],
						["RAID_ONLY"] = L["Raid Only"],
						["EMOTE"] = L["EMOTE"]
					},
					set = function(info, value)
						E.db.general[info[#info]] = value
						Misc:ToggleInterruptAnnounce()
					end
				},
				autoRepair = {
					order = 3,
					type = "select",
					name = L["Auto Repair"],
					desc = L["Automatically repair using the following method when visiting a merchant."],
					values = {
						["NONE"] = L["NONE"],
						["GUILD"] = L["GUILD"],
						["PLAYER"] = L["PLAYER"]
					}
				},
				autoAcceptInvite = {
					order = 4,
					type = "toggle",
					name = L["Accept Invites"],
					desc = L["Automatically accept invites from guild/friends."]
				},
				autoRoll = {
					order = 5,
					type = "toggle",
					name = L["Auto Greed/DE"],
					desc = L["Automatically select greed or disenchant (when available) on green quality items. This will only work if you are the max level."],
					disabled = function() return not E.private.general.lootRoll end
				},
				questAnnounce = {
					order = 10,
					type = "group",
					name = "Quest Announce",
					guiInline = true,
					get = function(info) return E.db.general.questAnnounce[info[#info]] end,
					set = function(info, value)
						E.db.general.questAnnounce[info[#info]] = value
						Misc:ToggleQuestAnnounce()
					end,
					args = {
						enable = {
							order = 1,
							type = "toggle",
							name = L["Enable"],
							desc = "Enables/Disables Quest Announce to Party chat.",
						},
						every = {
							order = 2,
							type = "range",
							name = "Announce Every",
							desc = "Announce progression every x number of steps (0 will announce on quest objective completion only).",
							min = 0, max = 10, step = 1,
							disabled = function() return not E.db.general.questAnnounce.enable end,
						},
					},
				}
			}
		}
	}
}
-- Movable Blizzard windows. [ported from Arden]
do
	local args = E.Options.args.general.args.blizzUIImprovements.args
	args.windowMoverHeader = {
		order = 20,
		type = "header",
		name = "Movable Blizzard Windows",
	}
	args.windowMoverDescription = {
		order = 21,
		type = "description",
		name = "Move Blizzard windows by dragging the top area of the window. Positions are stored in the current ElvUI profile.",
	}
	args.blizzardWindowMoverEnabled = {
		order = 22,
		type = "toggle",
		name = "Enable Movable Blizzard Windows",
		get = function() return E.db.general.blizzardWindowMover and E.db.general.blizzardWindowMover.enabled end,
		set = function(_, value)
			E.db.general.blizzardWindowMover.enabled = value
			Blizzard:UpdateMovableBlizzardWindows()
		end,
	}
	args.resetBlizzardWindowPositions = {
		order = 23,
		type = "execute",
		name = "Reset All Window Positions",
		desc = "Reset every saved Blizzard window position for the current ElvUI profile.",
		func = function() Blizzard:ResetAllBlizzardWindowPositions() end,
		disabled = function() return not E.db.general.blizzardWindowMover or not E.db.general.blizzardWindowMover.enabled end,
	}
end
