pudge_rot_lua = class({})
LinkLuaModifier( "modifier_rot_lua", "heroes/hero_pudge/modifiers/modifier_rot_lua.lua" ,LUA_MODIFIER_MOTION_NONE )

--[[Author: Valve
	Date: 26.09.2015.
	Applies the rot modifier on the caster depending on the toggle state]]
--------------------------------------------------------------------------------

function pudge_rot_lua:ProcsMagicStick()
	return false
end

--------------------------------------------------------------------------------

function pudge_rot_lua:OnToggle()
	-- Apply the rot modifier if the toggle is on
	if self:GetToggleState() then
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_rot_lua", nil )

		if not self:GetCaster():IsChanneling() then
			self:GetCaster():StartGesture( ACT_DOTA_CAST_ABILITY_ROT )
		end
	else
		-- Remove it if it is off
		local hRotBuff = self:GetCaster():FindModifierByName( "modifier_rot_lua" )
		if hRotBuff ~= nil then
			hRotBuff:Destroy()
		end
	end
end

--------------------------------------------------------------------------------