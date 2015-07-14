LinkLuaModifier( "arc_warden_magnetic_field_thinker", "heroes/hero_arc_warden/arc_warden_magnetic_field_lua.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "arc_warden_magnetic_field_modifier", "heroes/hero_arc_warden/arc_warden_magnetic_field_lua.lua",LUA_MODIFIER_MOTION_NONE )


arc_warden_magnetic_field = class({})

function arc_warden_magnetic_field:OnSpellStart()
	local point = self:GetCursorPosition()
	local caster = self:GetCaster()
	local team_id = caster:GetTeamNumber()
	local duration = self:GetSpecialValueFor("field_duration")
	local thinker = CreateModifierThinker(caster, self, "arc_warden_magnetic_field_thinker", {["duration"] = duration}, point, team_id, false)
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_disruptor/disruptor_static_storm.vpcf", PATTACH_ABSORIGIN, thinker)
	local radius = self:GetSpecialValueFor("radius")
	ParticleManager:SetParticleControl(particle, 1, Vector(radius, radius, radius))
	ParticleManager:SetParticleControl(particle, 2, Vector(duration, duration, duration))
end

function arc_warden_magnetic_field:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

arc_warden_magnetic_field_thinker = class({})

function arc_warden_magnetic_field_thinker:OnCreated(event)
	local thinker = self:GetParent()
	local ability = self:GetAbility()
	self.team_number = thinker:GetTeamNumber()
	self.radius = ability:GetSpecialValueFor("radius")

end

function arc_warden_magnetic_field_thinker:IsAura()
	return true
end

function arc_warden_magnetic_field_thinker:GetAuraRadius()
	return self.radius
end

function arc_warden_magnetic_field_thinker:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function arc_warden_magnetic_field_thinker:GetAuraSearchType()
	return DOTA_UNIT_TARGET_BUILDING + DOTA_UNIT_TARGET_HERO
end

function arc_warden_magnetic_field_thinker:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS
end

function arc_warden_magnetic_field_thinker:GetModifierAura()
	return "arc_warden_magnetic_field_modifier"
end


arc_warden_magnetic_field_modifier = class({})

function arc_warden_magnetic_field_modifier:IsBuff()
	return true
end

function arc_warden_magnetic_field_modifier:OnCreated( event )
	local ability = self:GetAbility()
	self.evasion = ability:GetSpecialValueFor("evasion")
	self.as = ability:GetSpecialValueFor("bonus_attack_speed")
end

function arc_warden_magnetic_field_modifier:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_EVASION_CONSTANT}
end

function arc_warden_magnetic_field_modifier:GetModifierEvasion_Constant()
	return self.evasion
end

function arc_warden_magnetic_field_modifier:GetModifierAttackSpeedBonus_Constant()
	return self.as
end