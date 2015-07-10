--[[Author: Pizzalol
	Date: 09.02.2015.
	Updates the value of the stack modifier and applies the movement speed modifier]]
function BattleHungerStart( keys )
	local caster = keys.caster
	local ability = keys.ability

	local caster_modifier = keys.caster_modifier
	local speed_modifier = keys.speed_modifier

	-- If the caster doesnt have the stack modifier then we create it, otherwise
	-- we just update the value
	if not caster:HasModifier(caster_modifier) then
		ability:ApplyDataDrivenModifier(caster, caster, caster_modifier, {})
		caster:SetModifierStackCount(caster_modifier, ability, 1)		
	else
		local stack_count = caster:GetModifierStackCount(caster_modifier, ability)
		caster:SetModifierStackCount(caster_modifier, ability, stack_count + 1)
	end

	-- Apply the movement speed modifier
	ability:ApplyDataDrivenModifier(caster, caster, speed_modifier, {})
end

--[[Author: Pizzalol
	Date: 09.02.2015.
	Updates the value of the stack modifier and removes the movement speed modifier]]
function BattleHungerEnd( keys )
	local caster = keys.caster
	local ability = keys.ability

	local caster_modifier = keys.caster_modifier
	local speed_modifier = keys.speed_modifier

	local stack_count = caster:GetModifierStackCount(caster_modifier, ability)

	-- If the stack is equal or less than one then just remove the stack modifier entirely
	-- otherwise just update the value
	if stack_count <= 1 then
		caster:RemoveModifierByName(caster_modifier)
	else
		caster:SetModifierStackCount(caster_modifier, ability, stack_count - 1)
	end

	-- Remove one movement modifier
	caster:RemoveModifierByName(speed_modifier)
end

--[[Author: Pizzalol
	Date: 09.02.2015.
	Triggers when the unit kills something, if its not an illusion then remove the Battle Hunger debuff]]
function BattleHungerKill( keys )
	local caster = keys.caster
	local attacker = keys.attacker
	local unit = keys.unit
	local modifier = keys.modifier

	if not unit:IsIllusion() then
		attacker:RemoveModifierByNameAndCaster(modifier, caster)
	end
end