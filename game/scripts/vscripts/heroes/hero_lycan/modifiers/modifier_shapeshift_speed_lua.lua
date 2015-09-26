modifier_shapeshift_speed_lua = class({})

--[[Author: Perry,Noya
	Date: 26.09.2015.
	Creates a modifier that allows to go beyond the 522 movement speed limit]]
function modifier_shapeshift_speed_lua:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_MOVESPEED_MAX,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE
	}

	return funcs
end

function modifier_shapeshift_speed_lua:GetModifierMoveSpeed_Max()
	return self:GetAbility():GetSpecialValueFor("speed")
end

function modifier_shapeshift_speed_lua:GetModifierMoveSpeed_Limit()
	return self:GetAbility():GetSpecialValueFor("speed")
end

function modifier_shapeshift_speed_lua:GetModifierMoveSpeed_Absolute()
	return self:GetAbility():GetSpecialValueFor("speed")
end

function modifier_shapeshift_speed_lua:IsHidden()
	return true
end

--[[Adds the shapeshift haste particle to the unit when the modifier gets created]]
function modifier_shapeshift_speed_lua:OnCreated()
	if IsServer() then
		self.nFXIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_lycan/lycan_shapeshift_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		self:AddParticle(self.nFXIndex, false, false, -1, false, false)
	end
end