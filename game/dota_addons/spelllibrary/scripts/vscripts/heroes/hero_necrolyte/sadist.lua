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
	Applies a hero sadist stack]]
function ApplySadistHero( keys )
	local caster = keys.caster
	local ability = keys.ability
	local stack_modifier = keys.stack_modifier
	local stack_count = caster:GetModifierStackCount(stack_modifier, ability)
	local hero_multiplier = ability:GetLevelSpecialValueFor("hero_multiplier", (ability:GetLevel() - 1)) - 1 -- Its -1 per normal sadist stack that you apply

	ability:ApplyDataDrivenModifier(caster, caster, stack_modifier, {})

	caster:SetModifierStackCount(stack_modifier, ability, stack_count + hero_multiplier)
end

--[[Author: Pizzalol
	Date: 06.01.2015.
	Removes a hero sadist stack]]
function RemoveSadistHero( keys )
	local caster = keys.caster
	local ability = keys.ability
	local stack_modifier = keys.stack_modifier
	local stack_count = caster:GetModifierStackCount(stack_modifier, ability)
	local hero_multiplier = ability:GetLevelSpecialValueFor("hero_multiplier", (ability:GetLevel() - 1)) - 1 -- Its -1 per normal sadist stack that you apply

	caster:SetModifierStackCount( stack_modifier, ability, stack_count - hero_multiplier)
end