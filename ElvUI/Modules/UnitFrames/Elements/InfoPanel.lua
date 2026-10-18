local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule("UnitFrames")
local LSM = E.Libs.LSM

--Lua functions
--WoW API / Variables
local CreateFrame = CreateFrame

function UF:Construct_InfoPanel(frame)
	local infoPanel = CreateFrame("Frame", nil, frame)

	infoPanel:SetFrameLevel(7) --Health is 10 and filled power is 5 by default
	local thinBorders = self.thinBorders
	infoPanel:CreateBackdrop(nil, true, nil, thinBorders, true)

	infoPanel.texture = infoPanel:CreateTexture(nil, "ARTWORK")
	infoPanel.texture:SetPoint("TOPLEFT", infoPanel, "TOPLEFT", 1, -1)
	infoPanel.texture:SetPoint("BOTTOMRIGHT", infoPanel, "BOTTOMRIGHT", -1, 1)

	return infoPanel
end

-- Grimfall stacks extra resource bars below Power in this order:
-- Power -> Energy -> Rage -> Mana -> Runic. A bottom InfoPanel sits below the
-- lowest bar that is attached to the frame.
local STACK = {
	{"Runic", "USE_RUNICBAR", "USE_INSET_RUNICBAR", "RUNICBAR_DETACHED"},
	{"Mana", "USE_MANABAR", "USE_INSET_MANABAR", "MANABAR_DETACHED"},
	{"Rage", "USE_RAGEBAR", "USE_INSET_RAGEBAR", "RAGEBAR_DETACHED"},
	{"Energy", "USE_ENERGYBAR", "USE_INSET_ENERGYBAR", "ENERGYBAR_DETACHED"},
	{"Power", "USE_POWERBAR", "USE_INSET_POWERBAR", "POWERBAR_DETACHED"},
}

local function GetBottomAnchor(frame)
	for _, info in ipairs(STACK) do
		local bar = frame[info[1]]
		if bar and bar.backdrop and frame[info[2]] and not frame[info[3]] and not frame[info[4]] then
			return bar.backdrop
		end
	end
	return frame.Health.backdrop
end

function UF:Configure_InfoPanel(frame, noTemplateChange)
	if not frame.VARIABLES_SET then return end
	local db = frame.db

	if frame.USE_INFO_PANEL then
		frame.InfoPanel:Show()
		frame.InfoPanel:ClearAllPoints()

		local infoTexture = LSM:Fetch("statusbar", db.infoPanel.texture or self.db.statusbar) or E.media.normTex or E.media.blankTex
		frame.InfoPanel.texture:SetTexture(infoTexture)

		local color = db.infoPanel.color
		local r, g, b, a
		if color then
			r, g, b, a = color.r or 1, color.g or 1, color.b or 1, color.a or 1
		elseif db.infoPanel.transparent then
			r, g, b, a = unpack(E.media.backdropfadecolor)
		else
			r, g, b = unpack(E.media.backdropcolor)
			a = 1
		end

		frame.InfoPanel.texture:SetVertexColor(r, g, b, a or 1)
		frame.InfoPanel.texture:Show()

		local outsidePortrait = db.infoPanel.outsidePortrait
			and frame.USE_PORTRAIT
			and not frame.USE_PORTRAIT_OVERLAY
			and frame.PORTRAIT_WIDTH
			and frame.PORTRAIT_WIDTH > 0

		local leftOffset = frame.BORDER + frame.SPACING
		local rightOffset = -frame.BORDER - frame.SPACING

		-- Match the Health bar's portrait edge when requested.
		if outsidePortrait then
			if frame.ORIENTATION == "LEFT" then
				leftOffset = frame.PORTRAIT_WIDTH + frame.BORDER + frame.SPACING
			elseif frame.ORIENTATION == "RIGHT" then
				rightOffset = -frame.PORTRAIT_WIDTH - frame.BORDER - frame.SPACING
			end
		end

		if db.infoPanel.top then
			local panelHeight = db.infoPanel.height - (frame.BORDER - frame.SPACING)
			if panelHeight < 1 then panelHeight = 1 end

			frame.InfoPanel:Point("TOPLEFT", frame, "TOPLEFT", leftOffset, -frame.BORDER - frame.SPACING)
			frame.InfoPanel:Point("TOPRIGHT", frame, "TOPRIGHT", rightOffset, -frame.BORDER - frame.SPACING)
			frame.InfoPanel:Height(panelHeight)
		elseif frame.ORIENTATION == "RIGHT" and frame.unitframeType ~= "arena" then
			frame.InfoPanel:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", rightOffset, frame.BORDER + frame.SPACING)
			frame.InfoPanel:Point("TOPLEFT", GetBottomAnchor(frame), "BOTTOMLEFT", frame.BORDER, -(frame.SPACING*3))
		else
			frame.InfoPanel:Point("BOTTOMLEFT", frame, "BOTTOMLEFT", leftOffset, frame.BORDER + frame.SPACING)
			frame.InfoPanel:Point("TOPRIGHT", GetBottomAnchor(frame), "BOTTOMRIGHT", -frame.BORDER, -(frame.SPACING*3))
		end

		if (not noTemplateChange) then
			local thinBorders = self.thinBorders
			if db.infoPanel.transparent then
				frame.InfoPanel.backdrop:SetTemplate("Transparent", nil, nil, thinBorders, true)
			else
				frame.InfoPanel.backdrop:SetTemplate(nil, true, nil, thinBorders, true)
			end
		end
	else
		if frame.InfoPanel.texture then
			frame.InfoPanel.texture:Hide()
		end
		frame.InfoPanel:Hide()
	end
end
