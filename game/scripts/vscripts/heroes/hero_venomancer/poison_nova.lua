--[[Author: Pizzalol
	Date: 30.09.2015.
	Deals non lethal magic damage to the target]]
function PoisonNova( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	local damage = ability:GetLevelSpecialValueFor("damage", ability_level)

	local damage_table = {}
	damage_table.attacker = caster
	damage_table.victim = target
	damage_table.damage_type = ability:GetAbilityDamageType()
	damage_table.ability = ability
	damage_table.damage = damage
	damage_table.damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL

	ApplyDamage(damage_table)
end