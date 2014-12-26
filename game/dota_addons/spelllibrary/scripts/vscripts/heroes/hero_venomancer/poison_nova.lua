--[[Author: Pizzalol
	Date: 26.12.2014.
	Deals non lethal magic damage to the target]]

function PoisonNova( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local abilityDamage = ability:GetLevelSpecialValueFor("damage", (ability:GetLevel() - 1))
	local targetHP = target:GetHealth()
	local targetMagicResist = target:GetMagicalArmorValue()
	-- Calculating damage that would be dealt
	local damagePostReduction = abilityDamage * (1 - targetMagicResist)
	print("Damage post reduction: " .. tonumber(damagePostReduction))

	local damageTable = {}
	damageTable.attacker = caster
	damageTable.victim = target
	damageTable.damage_type = ability:GetAbilityDamageType()
	damageTable.ability = ability
	damageTable.damage = abilityDamage

	-- Checking if its lethal damage
	if targetHP <= damagePostReduction then
		-- Adjusting it to non lethal damage
		damageTable.damage = ((targetHP / (1 - targetMagicResist)) - 1.8)
		print("Adjusted non lethal damage: " .. tonumber(damageTable.damage))
	end

	print("TARGET HEALTH: " .. tonumber(targetHP))
	print("DEALING DAMAGE: " .. tonumber(damageTable.damage))
	ApplyDamage(damageTable)
end