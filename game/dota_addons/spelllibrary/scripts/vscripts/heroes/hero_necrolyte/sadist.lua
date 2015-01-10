--[[Author: Pizzalol
	Date: 06.01.2015.
	Applies a normal sadist stack]]
function ApplySadist( keys )
	local caster = keys.caster
	local ability = keys.ability
	local stack_modifier = keys.stack_modifier
	local stack_count = caster:GetModifierStackCount(stack_modifier, ability)

	ability:ApplyDataDrivenModifier(caster, caster, stack_modifier, {})

	caster:SetModifierStackCount(stack_modifier, ability, stack_count + 1)

end

--[[Author: Pizzalol
	Date: 06.01.2015.
	Removes a normal sadist stack]]
function RemoveSadist( keys )
	local caster = keys.caster
	local ability = keys.ability
	local stack_modifier = keys.stack_modifier
	local stack_count = caster:GetModifierStackCount(stack_modifier, ability)

	if stack_count <= 1 then
		caster:RemoveModifierByName(stack_modifier)
	else
		caster:SetModifierStackCount(stack_modifier, ability, stack_count - 1)
	end
end

--[[Author: Pizzalol
	Date: 06.01.2015.
	Changed: 10.01.2015.
	Reason: Changed it to a loop that applies normal stacks instead
	Runs a loop that applies normal stacks according to the hero multiplier]]
function ApplySadistHero( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifier = keys.modifier
	local hero_multiplier = ability:GetLevelSpecialValueFor("hero_multiplier", (ability:GetLevel() - 1))

	-- Starts from 2 since OnKill already applied 1 stack
	for i = 2, hero_multiplier do
		ability:ApplyDataDrivenModifier(caster, caster, modifier, {})
	end
end