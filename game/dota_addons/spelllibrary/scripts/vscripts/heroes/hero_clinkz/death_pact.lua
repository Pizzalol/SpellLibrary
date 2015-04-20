--[[
	Author: Noya
	Date: April 5, 2015
	Increases the casters current and max HP, and applies a damage bonus.
]]
function DeathPact( event )
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local duration = ability:GetLevelSpecialValueFor( "duration" , ability:GetLevel() - 1 )

	-- Health Gain
	local health_gain_pct = ability:GetLevelSpecialValueFor( "health_gain_pct" , ability:GetLevel() - 1 ) * 0.01
	local target_health = target:GetHealth()
	local health_gain = math.floor(target_health * health_gain_pct)

	local health_modifier = "modifier_death_pact_health"
	ability:ApplyDataDrivenModifier(caster, caster, health_modifier, { duration = duration })
	caster:SetModifierStackCount( health_modifier, ability, health_gain )
	caster:Heal( health_gain, caster)

	-- Damage Gain
	local damage_gain_pct = ability:GetLevelSpecialValueFor( "damage_gain_pct" , ability:GetLevel() - 1 ) * 0.01
	local damage_gain = math.floor(target_health * damage_gain_pct)

	local damage_modifier = "modifier_death_pact_damage"
	ability:ApplyDataDrivenModifier(caster, caster, damage_modifier, { duration = duration })
	caster:SetModifierStackCount( damage_modifier, ability, damage_gain )

	target:Kill(ability, caster)

	print("Gained "..damage_gain.." damage and  "..health_gain.." health")
	caster.death_pact_health = health_gain
end

-- Keeps track of the casters health
function DeathPactHealth( event )
	local caster = event.caster
	caster.OldHealth = caster:GetHealth()
end

-- Sets the current health to the old health
function SetCurrentHealth( event )
	local caster = event.caster
	caster:SetHealth(caster.OldHealth)
end