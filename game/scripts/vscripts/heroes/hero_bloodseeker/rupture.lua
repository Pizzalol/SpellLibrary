--[[Author: YOLOSPAGHETTI
	Date: February 13, 2016
	Checks the target's distance from its last position and deals damage accordingly]]
function DistanceCheck(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local movement_damage_pct = ability:GetLevelSpecialValueFor( "movement_damage_pct", ability:GetLevel() - 1 )/100
	local damage_cap_amount = ability:GetLevelSpecialValueFor( "damage_cap_amount", ability:GetLevel() - 1 )
	local damage = 0
	local position = target:GetAbsOrigin()
	
	if ability.origin ~= null then
		local distance = math.sqrt((ability.origin.x - position.x)^2 + (ability.origin.y - position.y)^2)
		if distance <= damage_cap_amount then
			damage = distance * movement_damage_pct
		end
	end
	ability.origin = position
	ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
end
