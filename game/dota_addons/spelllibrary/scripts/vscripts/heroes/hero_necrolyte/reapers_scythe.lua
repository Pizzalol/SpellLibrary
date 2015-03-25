--[[Author: Pizzalol
	Date: 06.01.2015.
	Deals damage depending on missing hp
	If the target dies then it increases the respawn time]]
function ReapersScythe( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local target_missing_hp = target:GetMaxHealth() - target:GetHealth()
	local damage_per_health = ability:GetLevelSpecialValueFor("damage_per_health", (ability:GetLevel() - 1))
	local respawn_time = ability:GetLevelSpecialValueFor("respawn_constant", (ability:GetLevel() - 1))

	local damage_table = {}

	damage_table.attacker = caster
	damage_table.victim = target
	damage_table.ability = ability
	damage_table.damage_type = ability:GetAbilityDamageType()
	damage_table.damage = target_missing_hp * damage_per_health

	ApplyDamage(damage_table)

	-- Checking if target is alive to decide if it needs to increase respawn time
	if not target:IsAlive() then
		target:SetTimeUntilRespawn(target:GetRespawnTime() + respawn_time)
	end
end