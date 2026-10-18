local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule("UnitFrames")
local LSM = E.Libs.LSM

--[[
	Texture / Base -> Gradient styling for Grimfall's extra resource bars
	(Energy, Rage, Mana, Runic) and the CoA resource stack.
	Ported from the Arden build (ApplyEnergyStyle / ApplyRageStyle) and
	adapted to Grimfall's own resource bar implementation.

	Per bar settings (db.energy / db.rage / db.mana / db.runic):
		texture            statusbar texture (nil = global UnitFrame texture)
		backgroundTexture  background texture (nil = same as texture)
		customColor        use baseColor instead of the normal resource color
		baseColor          {r, g, b}
		gradient           draw a Base -> Gradient color fill
		gradientColor      {r, g, b} (nil = slightly brighter base color)
]]

local type = type

local function DefaultGradientEnd(r, g, b)
	return r + ((1 - r) * 0.18), g + ((1 - g) * 0.18), b + ((1 - b) * 0.18)
end

local function ClearGradient(bar)
	if not bar.__ElvUIResourceGradientApplied then return end
	local texture = bar:GetStatusBarTexture()
	if texture and texture.SetGradientAlpha then
		texture:SetGradientAlpha("HORIZONTAL", 1, 1, 1, 1, 1, 1, 1, 1)
	end
	bar.__ElvUIResourceGradientApplied = nil
end

-- Paint a statusbar with a solid color or a Base -> Gradient fill.
function UF:PaintResourceBar(bar, r, g, b, gradient, gradientColor)
	if not bar or not bar.GetStatusBarTexture then return end
	local texture = bar:GetStatusBarTexture()

	if gradient and texture and texture.SetGradientAlpha then
		local er, eg, eb
		if gradientColor and type(gradientColor.r) == "number" then
			er, eg, eb = gradientColor.r, gradientColor.g, gradientColor.b
		else
			er, eg, eb = DefaultGradientEnd(r, g, b)
		end

		local orientation = (bar.GetOrientation and bar:GetOrientation()) or "HORIZONTAL"
		bar:SetStatusBarColor(1, 1, 1, 1)
		texture:SetGradientAlpha(orientation, r, g, b, 1, er, eg, eb, 1)
		bar.__ElvUIResourceGradientApplied = true
	else
		ClearGradient(bar)
		bar:SetStatusBarColor(r, g, b)
	end
end

function UF:ApplyCustomResourceStyle(bar, key)
	if type(bar) ~= "table" or not bar.GetStatusBarTexture then return end
	local frame = bar.origParent or bar:GetParent()
	local db = frame and frame.db and frame.db[key]
	if not db then return end

	-- Texture
	bar.__ElvUIStatusBarTextureName = db.texture
	if db.texture then
		local fill = LSM:Fetch("statusbar", db.texture, true)
		if fill and bar.__ElvUIResourceTexture ~= fill then
			bar:SetStatusBarTexture(fill)
			bar.__ElvUIResourceTexture = fill
		end
	end
	if bar.BG and (db.backgroundTexture or db.texture) then
		local bgTexture = LSM:Fetch("statusbar", db.backgroundTexture or db.texture, true)
		if bgTexture then bar.BG:SetTexture(bgTexture) end
	end

	-- Color: the original color function has just set the normal resource color.
	local r, g, b
	if db.customColor and db.baseColor then
		r, g, b = db.baseColor.r or 1, db.baseColor.g or 1, db.baseColor.b or 1
	else
		r, g, b = bar:GetStatusBarColor()
	end

	UF:PaintResourceBar(bar, r, g, b, db.gradient, db.gradientColor)

	if bar.BG and UF.UpdateBackdropTextureColor and (db.customColor or db.gradient) then
		UF.UpdateBackdropTextureColor(bar, r, g, b)
	end
end

-- Wrap the color callbacks of the extra resource bars. The construct functions
-- capture these function references later (frame creation), so wrapping at file
-- load time is enough.
local function Wrap(funcName, key)
	local original = UF[funcName]
	if type(original) ~= "function" then return end

	UF[funcName] = function(self, bar)
		-- Called either as UF:PostUpdateXColor(bar) or by oUF as
		-- element:PostUpdateColor(unit, r, g, b). In the second case "bar" is the
		-- unit string, so hand the element itself to the original function.
		local target = (type(bar) == "table" and bar) or self
		if type(target) ~= "table" or not target.GetStatusBarTexture then
			return original(self, bar)
		end

		-- Remove our gradient first so the original sets the plain resource color.
		ClearGradient(target)
		original(UF, target)
		UF:ApplyCustomResourceStyle(target, key)
	end
end

Wrap("PostUpdateEnergyColor", "energy")
Wrap("PostUpdateRageColor", "rage")
Wrap("PostUpdateManaColor", "mana")
Wrap("PostUpdateRunicColor", "runic")

-- CoA resource stack (UnitFrames -> Player -> CoA Resources)
-- Settings live in E.db.unitframe.units.player.coaResources:
--   texture, gradient, gradientStrength (0..1)
local function StyleCoABars(frame)
	local host = frame and frame.CoAResources
	if not host or not host.bars or not UF.CoAResourceTypes then return end

	local config = UF.Get_CoAResourceConfig and UF:Get_CoAResourceConfig()
	if not config then return end

	local fill = (config.texture and LSM:Fetch("statusbar", config.texture, true)) or E.media.blankTex
	for _, resource in ipairs(UF.CoAResourceTypes) do
		local bar = host.bars[resource.key]
		if bar then
			if bar.__ElvUICoATexture ~= fill then
				bar:SetStatusBarTexture(fill)
				bar.__ElvUICoATexture = fill
			end

			local r, g, b = resource.color[1], resource.color[2], resource.color[3]
			local custom = config.colors and config.colors[resource.key]
			if custom and type(custom.r) == "number" then r, g, b = custom.r, custom.g, custom.b end

			local finish
			local customEnd = config.gradientColors and config.gradientColors[resource.key]
			if customEnd and type(customEnd.r) == "number" then finish = customEnd end

			UF:PaintResourceBar(bar, r, g, b, config.gradient, finish)
		end
	end
end
UF.StyleCoAResourceBars = StyleCoABars

if UF.Configure_CoAResources then
	hooksecurefunc(UF, "Configure_CoAResources", function(_, frame) StyleCoABars(frame) end)
end
