modifier_voodoo_lua = class({})

--[[Author: Noya, Pizzalol
	Date: 27.09.2015.
	Changes the model, reduces the movement speed and disables the target]]
function modifier_voodoo_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE
	}

	return funcs
end

function modifier_voodoo_lua:GetModifierModelChange()
	return "models/props_gameplay/chicken.vmdl"
end

function modifier_voodoo_lua:GetModifierMoveSpeedOverride()
	return self:GetAbility():GetSpecialValueFor("movespeed")
end

function modifier_voodoo_lua:CheckState()
	local state = {
	[MODIFIER_STATE_DISARMED] = true,
	[MODIFIER_STATE_HEXED] = true,
	[MODIFIER_STATE_MUTED] = true,
	[MODIFIER_STATE_EVADE_DISABLED] = true,
	[MODIFIER_STATE_BLOCK_DISABLED] = true,
	[MODIFIER_STATE_SILENCED] = true
	}

	return state
end

function modifier_voodoo_lua:IsHidden() 
	return false
end