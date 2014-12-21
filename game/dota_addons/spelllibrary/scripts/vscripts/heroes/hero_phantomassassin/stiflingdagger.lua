--[[ Author: Pizzalol
	 Date: 21.12.2014.
	 On projectile impact it checks if the target is a hero and then deals damage depending on it]]

function StiflingDagger( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local heroPercent = (ability:GetLevelSpecialValueFor("hero_dmg_pct", (ability:GetLevel() - 1)))/100
	local abilityDamage = ability:GetAbilityDamage()
	local abilityDmgType = ability:GetAbilityDamageType()

	local damageTable = {}

	damageTable.attacker = caster
	damageTable.victim = target
	damageTable.ability = ability
	damageTable.damage_type = abilityDmgType

	if target:IsRealHero() then
		damageTable.damage = abilityDamage * heroPercent
	else
		damageTable.damage = abilityDamage
	end

	ApplyDamage(damageTable)
end