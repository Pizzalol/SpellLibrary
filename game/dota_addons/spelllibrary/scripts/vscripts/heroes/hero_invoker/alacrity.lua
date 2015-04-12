--[[Author: Pizzalol
	Date: 12.04.2015.
	Applies the alacrity values depending on wex and exort levels]]
function Alacrity( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	-- Ability variables
	local wex_level = caster:FindAbilityByName("invoker_wex_datadriven"):GetLevel() - 1
	local exort_level = caster:FindAbilityByName("invoker_exort_datadriven"):GetLevel() - 1
	local damage = ability:GetLevelSpecialValueFor("bonus_damage", exort_level) 
	local attack_speed = ability:GetLevelSpecialValueFor("bonus_attack_speed", wex_level)
	local damage_modifier = keys.damage_modifier
	local speed_modifier = keys.speed_modifier

	-- Apply the bonus modifiers
	ability:ApplyDataDrivenModifier(caster, target, damage_modifier, {}) 
	ability:ApplyDataDrivenModifier(caster, target, speed_modifier, {})

	-- Set the values
	target:SetModifierStackCount(damage_modifier, ability, damage)
	target:SetModifierStackCount(speed_modifier, ability, attack_speed) 
end