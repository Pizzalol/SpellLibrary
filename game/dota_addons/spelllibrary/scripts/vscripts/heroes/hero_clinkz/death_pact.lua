--[[
	Author: Noya
	Date: April 5, 2015
	Increases the casters current and max HP, and applies a damage bonus.
]]
function DeathPact( event )
	local caster = event.caster
	local target = event.target
	local ability = event.ability

	-- Health Gain
	local health_gain_pct = ability:GetLevelSpecialValueFor( "health_gain_pct" , ability:GetLevel() - 1 ) * 0.01
	local target_health = target:GetHealth()
	local health_gain = target_health * health_gain_pct

	-- Damage Gain
	local damage_gain_pct = ability:GetLevelSpecialValueFor( "damage_gain_pct" , ability:GetLevel() - 1 ) * 0.01
	local damage_gain = target_health * health_gain_pct

	-- TODO: Test if this sticks with item/level change or needs bitfield shit
	ability.health_gain = health_gain
	caster:SetMaxHealth(caster:GetMaxHealth() + health_gain)
	caster:Heal( health_gain, caster)

	ability.damage_gain = damage_gain
	caster:SetBaseDamageMax(caster:GetBaseDamageMax() + damage_gain)
	caster:SetBaseDamageMin(caster:GetBaseDamageMin() + damage_gain)

	target:Kill(ability, caster)
end

-- When the duration ends, max HP returns to normal, but current HP stays the same.
function DeathPactEnd( event )
	local health_gain = ability.health_gain
	local damage_gain = ability.damage_gain
	caster:SetMaxHealth(caster:GetMaxHealth() - health_gain)
	caster:SetBaseDamageMax(caster:GetBaseDamageMax() - damage_gain)
	caster:SetBaseDamageMin(caster:GetBaseDamageMin() - damage_gain)
end

-- TODO: Check interaction with Refresher