
function BattleHungerStart( keys )
	local caster = keys.caster
	local ability = keys.ability

	local caster_modifier = keys.caster_modifier
	local speed_modifier = keys.speed_modifier

	if not caster:HasModifier(caster_modifier) then
		ability:ApplyDataDrivenModifier(caster, caster, caster_modifier, {})
		caster:SetModifierStackCount(caster_modifier, ability, 1)		
	else
		local stack_count = caster:GetModifierStackCount(caster_modifier, ability)
		caster:SetModifierStackCount(caster_modifier, ability, stack_count + 1)
	end

	ability:ApplyDataDrivenModifier(caster, caster, speed_modifier, {})
end

function BattleHungerEnd( keys )
	local caster = keys.caster
	local ability = keys.ability

	local caster_modifier = keys.caster_modifier
	local speed_modifier = keys.speed_modifier

	local stack_count = caster:GetModifierStackCount(caster_modifier, ability)

	if stack_count <= 1 then
		caster:RemoveModifierByName(caster_modifier)
	else
		caster:SetModifierStackCount(caster_modifier, ability, stack_count - 1)
	end

	caster:RemoveModifierByName(speed_modifier)
end

function BattleHungerKill( keys )
	local caster = keys.caster
	local attacker = keys.attacker
	local unit = keys.unit
	local modifier = keys.modifier

	if not unit:IsIllusion() then
		attacker:RemoveModifierByNameAndCaster(modifier, caster)
	end
end