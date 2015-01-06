--[[Arcane Orb
	Author: chrislotix
	Date: 05.01.2015.]]

function ArcaneOrb( keys )

	local ability = keys.ability
	local caster = keys.caster
	local mana = caster:GetMana()
	local target = keys.target
	local summon_damage = ability:GetLevelSpecialValueFor("illusion_damage", (ability:GetLevel() -1))
	local extra_damage = ability:GetLevelSpecialValueFor("mana_pool_damage_pct", (ability:GetLevel() -1)) / 100

	

	local damage_table = {}

	damage_table.attacker = caster
	damage_table.damage_type = DAMAGE_TYPE_PURE
	damage_table.ability = ability
	damage_table.victim = target



	if target:IsRealHero() then
		damage_table.damage = mana * extra_damage
	else
		damage_table.damage = mana * extra_damage + summon_damage
	end 

	ApplyDamage(damage_table)

	print("ebin2")
end

