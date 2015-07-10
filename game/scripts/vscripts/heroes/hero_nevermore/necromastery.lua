--[[
	Author: Noya
	Date: April 5, 2015
	Lose some of the modifier charges stored
	TODO: Check if floor or ceil
]]
function NecromasteryDeath( event )
	local caster = event.caster
	local ability = event.ability
	local modifier = event.modifier
	local necromastery_soul_release = ability:GetLevelSpecialValueFor( "necromastery_soul_release", ability:GetLevel() - 1 )

	local current_stack = caster:GetModifierStackCount( modifier, ability )
	if current_stack then
		target:SetModifierStackCount( modifierName, ability, math.ceil(current_stack * necromastery_soul_release) )
	end
end

--[[
	Author: Noya
	Date: April 5, 2015
	Adds to the modified stacks when a unit is killed, limited by a max_souls.
	TODO: Confirm that SetModifierStackCount adds the damage instances without the need to apply shit
]]
function NecromasteryStack( event )
	local caster = event.caster
	local target = event.target -- unit? The killed thing
	local modifier = event.modifier

	local souls_hero_bonus = ability:GetLevelSpecialValueFor( "necromastery_souls_hero_bonus", ability:GetLevel() - 1 )
	local max_souls = ability:GetLevelSpecialValueFor( "necromastery_max_souls", ability:GetLevel() - 1 )

	-- Check how many stacks can be granted
	local souls_gained = 1
	if target:IsRealHero() then
		souls_gained = souls_gained + souls_hero_bonus
	end

	-- Check if the hero already has the modifier
	local current_stack = caster:GetModifierStackCount( modifier, ability )
	if not current_stack then
		ability:ApplyDataDrivenModifier(caster, caster, modifier, {})
		current_stack = 0
	end

	-- Set the stack up to max_souls
	if (current_stack + souls_gained) <= max_souls then
		caster:SetModifierStackCount( modifier, ability, current_stack + souls_gained )
	else
		caster:SetModifierStackCount( modifier, ability, max_souls )
	end
end