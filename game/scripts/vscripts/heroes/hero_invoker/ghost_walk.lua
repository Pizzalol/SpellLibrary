--[[Author: Pizzalol
	Date: 14.04.2015.
	Applies a slow on the caster depending on the Wex level]]
function GhostWalkSelfSlow( keys )
	local caster = keys.caster
	local ability = keys.ability
	local wex_level = caster:FindAbilityByName("invoker_wex_datadriven"):GetLevel() - 1 -- Self slow depends on wex level

	-- Ability variables
	local self_slow = ability:GetLevelSpecialValueFor("self_slow", wex_level) 
	local slow_modifier = keys.slow_modifier
	local boost_modifier = keys.boost_modifier

	-- If the self slow is less than 0 then apply the slowing modifier
	-- if its greater than 0 then apply the movement speed increasing modifier
	if self_slow < 0 then
		self_slow = self_slow * -1 -- Turn it into a positive number because we cant apply negative stacks
		ability:ApplyDataDrivenModifier(caster, caster, slow_modifier, {})
		caster:SetModifierStackCount(slow_modifier, ability, self_slow)
	elseif self_slow > 0 then
		ability:ApplyDataDrivenModifier(caster, caster, boost_modifier, {})
		caster:SetModifierStackCount(boost_modifier, ability, self_slow)
	end
end

--[[Author: Pizzalol
	Date: 14.04.2015.
	Applies a slow on the target depending on the level of Quas]]
function GhostWalkEnemySlow( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local quas_level = caster:FindAbilityByName("invoker_quas_datadriven"):GetLevel() - 1

	-- Ability variables
	local enemy_slow = ability:GetLevelSpecialValueFor("enemy_slow", quas_level) 
	local slow_modifier = keys.slow_modifier

	-- If the slow number is a negative then turn it into a positive number
	-- because we cannot apply negative stacks
	if enemy_slow < 0 then enemy_slow = enemy_slow * -1 end

	ability:ApplyDataDrivenModifier(caster, target, slow_modifier, {}) 
	target:SetModifierStackCount(slow_modifier, ability, enemy_slow)
end