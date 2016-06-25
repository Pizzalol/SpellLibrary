--[[Author: YOLOSPAGHETTI
	Date: February 13, 2016
	Checks the target's distance from its last position and deals damage accordingly]]
function DistanceCheck(keys)
	local caster = keys.caster
	local target = keys.target
	print(target)
	local ability = keys.ability
	local movement_damage_pct = ability:GetLevelSpecialValueFor( "movement_damage_pct", ability:GetLevel() - 1 )/100
	local damage_cap_amount = ability:GetLevelSpecialValueFor( "damage_cap_amount", ability:GetLevel() - 1 )
	local damage = 0
	
	if target.position == nil then
		target.position = target:GetAbsOrigin()
	end
	local vector_distance = target.position - target:GetAbsOrigin()
	local distance = (vector_distance):Length2D()
	if distance <= damage_cap_amount and distance > 0 then
		damage = distance * movement_damage_pct
	end
	target.position = target:GetAbsOrigin()
	if damage ~= 0 then
		ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
	end
end
