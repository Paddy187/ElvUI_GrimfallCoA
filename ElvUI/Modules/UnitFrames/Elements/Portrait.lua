local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule("UnitFrames")

--Lua functions
--WoW API / Variables
local CreateFrame = CreateFrame
local UnitClass = UnitClass
local SetPortraitTexture = SetPortraitTexture
local CLASS_ICON_TCOORDS = _G.CLASS_ICON_TCOORDS
local COA_CLASS_ICON_TEXTURE = [[Interface\GLUES\CHARACTERCREATE\UI-CHARACTERCREATE-CLASSES]]

function UF:Construct_Portrait(frame, type)
	local portrait

	if type == "texture" then
		local backdrop = CreateFrame("Frame", nil, frame)
		portrait = frame:CreateTexture(nil, "OVERLAY")
		portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
		backdrop:SetOutside(portrait)
		backdrop:SetFrameLevel(frame:GetFrameLevel())
		backdrop:SetTemplate("Default")
		portrait.backdrop = backdrop
	else
		portrait = CreateFrame("PlayerModel", nil, frame)
		portrait:CreateBackdrop("Default", nil, nil, self.thinBorders, true)
	end

	portrait.PostUpdate = self.PortraitUpdate

	return portrait
end

local DETACHABLE_PORTRAIT_UNITS = {
	player = true,
	target = true,
	targettarget = true,
	targettargettarget = true,
	focus = true,
	focustarget = true,
	pet = true,
	pettarget = true,
}

local PORTRAIT_MOVER_NAMES = {
	player = "Player Portrait",
	target = "Target Portrait",
	targettarget = "Target of Target Portrait",
	targettargettarget = "Target of Target of Target Portrait",
	focus = "Focus Portrait",
	focustarget = "Focus Target Portrait",
	pet = "Pet Portrait",
	pettarget = "Pet Target Portrait",
}

function UF:IsPortraitDetachSupported(frame)
	return frame and DETACHABLE_PORTRAIT_UNITS[frame.unitframeType] or false
end

function UF:IsPortraitDetached(frame, db)
	return self:IsPortraitDetachSupported(frame)
		and db
		and db.portrait
		and db.portrait.detachFromFrame
		and true or false
end

function UF:GetPortraitDisplayHeight(frame, db)
	if not frame or not db or not db.portrait then return 45 end

	local height = (db.height or db.portrait.width or 45) - ((frame.SPACING or 0) * 2)

	if db.infoPanel and db.infoPanel.enable and db.infoPanel.top and db.infoPanel.outsidePortrait then
		height = height + (db.infoPanel.height or 0)
	end

	if height < 15 then height = 15 end
	if height > 150 then height = 150 end
	return height
end

function UF:GetPortraitDisplayWidth(frame, db)
	if not frame or not db or not db.portrait then return 45 end
	local portraitDB = db.portrait

	if not portraitDB.autoWidth then
		return portraitDB.width or 45
	end

	local width = self:GetPortraitDisplayHeight(frame, db) + (portraitDB.autoWidthOffset or 0)
	if width < 15 then width = 15 end
	if width > 150 then width = 150 end
	return width
end

function UF:GetPortraitWidth(frame, db)
	if not frame or not db or not db.portrait then return 0 end
	if not frame.USE_PORTRAIT or self:IsPortraitDetached(frame, db) or frame.USE_PORTRAIT_OVERLAY then
		return 0
	end

	return self:GetPortraitDisplayWidth(frame, db)
end

function UF:UpdateDetachedPortraitShadow(frame)
	if not frame then return end
	local holder = frame.PortraitHolder
	if not holder then return end

	local db = frame.db
	local portraitDB = db and db.portrait
	local shadowDB = E.db and E.db.frameShadows

	local enabled = portraitDB
		and portraitDB.shadow ~= false
		and self:IsPortraitDetached(frame, db)
		and frame.USE_PORTRAIT
		and (not shadowDB or shadowDB.enable ~= false)

	if not enabled then
		if holder.portraitShadow then holder.portraitShadow:Hide() end
		return
	end

	local size = (shadowDB and shadowDB.size) or 5
	local color = (shadowDB and shadowDB.color) or {r = 0, g = 0, b = 0, a = 0.9}

	local shadow = holder.portraitShadow
	if not shadow then
		shadow = CreateFrame("Frame", nil, holder)
		shadow:EnableMouse(false)
		holder.portraitShadow = shadow
	end

	shadow:ClearAllPoints()
	shadow:SetPoint("TOPLEFT", holder, "TOPLEFT", -size, size)
	shadow:SetPoint("BOTTOMRIGHT", holder, "BOTTOMRIGHT", size, -size)
	shadow:SetFrameStrata(holder:GetFrameStrata())
	shadow:SetFrameLevel(math.max((holder:GetFrameLevel() or 1) - 1, 0))
	shadow:SetBackdrop({edgeFile = E.Libs.LSM:Fetch("border", "ElvUI GlowBorder"), edgeSize = E:Scale(size)})
	shadow:SetBackdropColor(0, 0, 0, 0)
	shadow:SetBackdropBorderColor(color.r or 0, color.g or 0, color.b or 0, color.a or 0.9)
	shadow:Show()
end

function UF:GetDetachedPortraitHolder(frame, width, height)
	if not frame or not self:IsPortraitDetachSupported(frame) then return end

	local holder = frame.PortraitHolder
	if not holder then
		holder = CreateFrame("Frame", nil, frame)
		holder:Size(width, height)
		holder:SetFrameStrata(frame:GetFrameStrata())
		holder:SetFrameLevel(frame:GetFrameLevel() + 1)

		-- IMPORTANT: anchor only to the named UnitFrame.
		-- ElvUI Movers.lua serializes anchor:GetName(); anonymous backdrops produce nil.
		if frame.ORIENTATION == "RIGHT" then
			holder:Point("TOPRIGHT", frame, "TOPRIGHT", -(frame.SPACING or 0), -(frame.SPACING or 0))
		else
			holder:Point("TOPLEFT", frame, "TOPLEFT", frame.SPACING or 0, -(frame.SPACING or 0))
		end

		frame.PortraitHolder = holder

		local frameName = frame:GetName()
		if frameName then
			local moverName = frameName.."PortraitMover"
			local moverText = PORTRAIT_MOVER_NAMES[frame.unitframeType] or ((frame.unitframeType or "Unit").." Portrait")

			-- Defensive cleanup for an invalid experimental mover entry, if one exists.
			if E.db and E.db.movers and E.db.movers[moverName] and type(E.db.movers[moverName]) ~= "string" then
				E.db.movers[moverName] = nil
			end

			E:CreateMover(holder, moverName, moverText, nil, nil, nil, "ALL,SOLO", nil, "unitframe,"..tostring(frame.unitframeType)..",portrait")
			holder.__portraitMoverName = moverName
		end
	else
		holder:Size(width, height)
		holder:SetFrameStrata(frame:GetFrameStrata())
		holder:SetFrameLevel(frame:GetFrameLevel() + 1)
	end

	return holder
end

-- Grimfall: the side portrait reaches down to the lowest resource bar that is
-- attached below Health (Power -> Energy -> Rage -> Mana -> Runic).
local PORTRAIT_STACK = {
	{"Runic", "RUNICBAR"}, {"Mana", "MANABAR"}, {"Rage", "RAGEBAR"}, {"Energy", "ENERGYBAR"}, {"Power", "POWERBAR"},
}

local function GetPortraitBottomAnchor(frame)
	for _, info in ipairs(PORTRAIT_STACK) do
		local bar, flag = frame[info[1]], info[2]
		if bar and bar.backdrop and frame["USE_"..flag] and not frame["USE_INSET_"..flag] and not frame[flag.."_DETACHED"]
			and not frame["USE_MINI_"..flag] and not frame["USE_"..flag.."_OFFSET"] then
			return bar.backdrop
		end
	end
	return frame.Health.backdrop
end

function UF:Configure_Portrait(frame, dontHide)
	if not frame.VARIABLES_SET then return end
	local db = frame.db
	local detached = self:IsPortraitDetached(frame, db)
	local infoPanelTopOffset = 0
	if frame.USE_INFO_PANEL and db.infoPanel and db.infoPanel.top and not db.infoPanel.outsidePortrait then
		infoPanelTopOffset = frame.INFO_PANEL_HEIGHT - (frame.BORDER - frame.SPACING)
		if infoPanelTopOffset < 0 then infoPanelTopOffset = 0 end
	end

	if frame.Portrait and not dontHide then
		frame.Portrait:Hide()
		frame.Portrait:ClearAllPoints()
		frame.Portrait.backdrop:Hide()
	end
	local texturePortrait = db.portrait.style == "2D" or db.portrait.style == "COACLASS"
	frame.Portrait = texturePortrait and frame.Portrait2D or frame.Portrait3D

	local portrait = frame.Portrait
	if not detached and frame.PortraitHolder then
		frame.PortraitHolder:Hide()
		if frame.PortraitHolder.portraitShadow then frame.PortraitHolder.portraitShadow:Hide() end
		if frame.PortraitHolder.__portraitMoverName and E.CreatedMovers[frame.PortraitHolder.__portraitMoverName] then
			E:DisableMover(frame.PortraitHolder.__portraitMoverName)
		end
	end

	if frame.USE_PORTRAIT then
		if not frame:IsElementEnabled("Portrait") then
			frame:EnableElement("Portrait")
		end

		local color = E.db.unitframe.colors.borderColor
		portrait.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)

		portrait:ClearAllPoints()
		portrait.backdrop:ClearAllPoints()
		if detached then
			local portraitWidth = self:GetPortraitDisplayWidth(frame, db)
			local portraitHeight = self:GetPortraitDisplayHeight(frame, db)
			local holder = self:GetDetachedPortraitHolder(frame, portraitWidth, portraitHeight)

			if holder then
				if holder.__portraitMoverName and E.DisabledMovers[holder.__portraitMoverName] then
					E:EnableMover(holder.__portraitMoverName)
				end
				holder:Show()

				portrait.backdrop:SetAllPoints(holder)
				portrait:SetInside(portrait.backdrop, frame.BORDER)
				portrait:SetAlpha(1)
				portrait.backdrop:Show()

				if db.portrait.style == "3D" then
					portrait:SetFrameLevel(frame:GetFrameLevel() + 2)
				else
					portrait:SetParent(frame)
				end

				if not dontHide then portrait:Show() end
				self:UpdateDetachedPortraitShadow(frame)
			end
		elseif frame.USE_PORTRAIT_OVERLAY then
			if db.portrait.style == "3D" then
				portrait:SetFrameLevel(frame.Health:GetFrameLevel() + 1)
			else
				portrait:SetParent(frame.Health)
			end

			portrait:SetAlpha(db.portrait.overlayAlpha)
			if not dontHide then
				portrait:Show()
			end
			portrait.backdrop:Hide()

			portrait:ClearAllPoints()
			if db.portrait.fullOverlay then
				portrait:SetAllPoints(frame.Health)
			else
				local statusBarTex = frame.Health:GetStatusBarTexture()
				if frame.Health:GetOrientation() == "VERTICAL" then
					portrait:SetPoint("BOTTOMLEFT", frame.Health)
					portrait:SetPoint("TOPRIGHT", statusBarTex, "TOPRIGHT")
				else
					portrait:SetPoint("TOPLEFT", frame.Health)
					portrait:SetPoint("BOTTOMRIGHT", statusBarTex, "BOTTOMRIGHT")
				end
			end
		else
			portrait:ClearAllPoints()
			portrait:SetAllPoints()
			portrait:SetAlpha(1)

			if not dontHide then
				portrait:Show()
			end
			portrait.backdrop:Show()
			if db.portrait.style == "3D" then
				portrait:SetFrameLevel(frame.Health:GetFrameLevel() -4) --Make sure portrait is behind Health and Power
			else
				portrait:SetParent(frame)
			end

			if frame.ORIENTATION == "LEFT" then
				portrait.backdrop:Point("TOPLEFT", frame, "TOPLEFT", frame.SPACING, (frame.USE_MINI_CLASSBAR and -(frame.CLASSBAR_YOFFSET+frame.SPACING) or -frame.SPACING) - infoPanelTopOffset)

				portrait.backdrop:Point("BOTTOMRIGHT", GetPortraitBottomAnchor(frame), "BOTTOMLEFT", frame.BORDER - frame.SPACING*3, 0)
			elseif frame.ORIENTATION == "RIGHT" then
				portrait.backdrop:Point("TOPRIGHT", frame, "TOPRIGHT", -frame.SPACING, (frame.USE_MINI_CLASSBAR and -(frame.CLASSBAR_YOFFSET+frame.SPACING) or -frame.SPACING) - infoPanelTopOffset)

				portrait.backdrop:Point("BOTTOMLEFT", GetPortraitBottomAnchor(frame), "BOTTOMRIGHT", -frame.BORDER + frame.SPACING*3, 0)
			end

			portrait:SetInside(portrait.backdrop, frame.BORDER)
		end
	else
		if frame:IsElementEnabled("Portrait") then
			frame:DisableElement("Portrait")
			portrait:Hide()
			portrait.backdrop:Hide()
		end

		if frame.PortraitHolder then
			frame.PortraitHolder:Hide()
			if frame.PortraitHolder.portraitShadow then frame.PortraitHolder.portraitShadow:Hide() end
			if frame.PortraitHolder.__portraitMoverName and E.CreatedMovers[frame.PortraitHolder.__portraitMoverName] then
				E:DisableMover(frame.PortraitHolder.__portraitMoverName)
			end
		end
	end
end

function UF:PortraitUpdate(unit)
	local frame = self:GetParent()
	local db = frame and frame.db
	if not db then return end

	local portraitDB = db.portrait
	if portraitDB.style == "COACLASS" and self:IsObjectType("Texture") then
		unit = unit or frame.unit

		local _, class = UnitClass(unit)
		local coords = class and CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[class]

		if coords then
			self:SetTexture(COA_CLASS_ICON_TEXTURE)

			-- Inset the atlas coordinates very slightly. Detached portraits expose
			-- the full square more clearly, and exact atlas edges can sample a row
			-- of pixels from the neighboring class icon.
			local left, right, top, bottom = coords[1], coords[2], coords[3], coords[4]
			local padX = (right - left) * 0.008
			local padY = (bottom - top) * 0.008
			self:SetTexCoord(left + padX, right - padX, top + padY, bottom - padY)
		else
			-- NPCs / units without a class icon keep a normal 2D portrait.
			if unit then
				SetPortraitTexture(self, unit)
			end
			self:SetTexCoord(0.15, 0.85, 0.15, 0.85)
		end
	elseif self:IsObjectType("Texture") then
		-- Switching back from CoA Class to 2D must also restore the portrait crop.
		self:SetTexCoord(0.15, 0.85, 0.15, 0.85)
	end

	if portraitDB.enable and frame.USE_PORTRAIT_OVERLAY and not UF:IsPortraitDetached(frame, db) then
		self:SetAlpha(0)
		self:SetAlpha(portraitDB.overlayAlpha)
	else
		self:SetAlpha(1)
	end
end
