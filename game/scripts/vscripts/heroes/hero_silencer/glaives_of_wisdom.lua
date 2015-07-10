--[[Glaives of Wisdom intelligence to damage
	Author: chrislotix
	Date: 10.1.2015.]]

function IntToDamage( keys )

	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	local int_caster = caster:GetIntellect()
	local int_damage = ability:GetLevelSpecialValueFor("intellect_damage_pct", (ability:GetLevel() -1)) 
	

	local damage_table = {}

	damage_table.attacker = caster
	damage_table.damage_type = ability:GetAbilityDamageType()
	damage_table.ability = ability
	damage_table.victim = target

	damage_table.damage = int_caster * int_damage / 100

	ApplyDamage(damage_table)

end