--[[Author: Pizzalol
	Date: 14.02.2015.
	Initializes the stack count for the target]]
function ChillingTouchInitialize( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local modifier_stack = keys.modifier_stack

	local max_stacks = ability:GetLevelSpecialValueFor("max_attacks", ability_level)

	target:SetModifierStackCount(modifier_stack, ability, max_stacks)
end

--[[Author: Pizzalol
	Date: 14.02.2015.
	Manages the stack count of the target]]
function ChillingTouchDecrement( keys )
	local caster = keys.caster
	local target = keys.attacker
	local ability = keys.ability
	local modifier_stack = keys.modifier_stack

	-- Get the current stack count
	local current_stack = target:GetModifierStackCount(modifier_stack, ability)

	-- If its 1 then remove the modifier entirely, otherwise just reduce the stack number by 1
	if current_stack <= 1 then
		target:RemoveModifierByNameAndCaster(modifier_stack, caster)
	else
		target:SetModifierStackCount(modifier_stack, ability, current_stack - 1)
	end
end