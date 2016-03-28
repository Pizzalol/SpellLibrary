--[[Author: YOLOSPAGHETTI
	Date: March 28, 2016
	Applies the flak cannon modifier to the caster, and adds stacks based on the ability level]]
function ApplyModifier(keys)
	local caster = keys.caster
	local ability = keys.ability
	local stacks = ability:GetLevelSpecialValueFor( "max_attacks", ability:GetLevel() - 1 )
	
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_flak_cannon_datadriven", {})
	caster:SetModifierStackCount("modifier_flak_cannon_datadriven", ability, stacks)
end

--[[Author: YOLOSPAGHETTI
	Date: March 28, 2016
	Deals damage to every unit in range (except the main target)]]
function DealDamage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage = caster:GetAttackDamage()
	
	if target ~= ability.main_target then
		ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
	end
end

--[[Author: YOLOSPAGHETTI
	Date: March 28, 2016
	Gets the main target (the right-clicked target) of the attack]]
function GetMainTarget(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local stacks = caster:GetModifierStackCount("modifier_flak_cannon_datadriven", ability)
	
	-- Removes the modifier, if there is only one stack
	if stacks == 1 then
		caster:RemoveModifierByName("modifier_flak_cannon_datadriven")
	-- Decrements the stacks
	else
		caster:SetModifierStackCount("modifier_flak_cannon_datadriven", ability, stacks - 1)
	end
	ability.main_target = target
end
