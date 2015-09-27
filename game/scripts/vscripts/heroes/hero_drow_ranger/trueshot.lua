--[[
	Author: kritth, Pizzalol
	Date: 27.09.2015.
	Calculates the bonus damage based on casters agility and then applies a stack modifier to grant the damage
]]
function trueshot_initialize( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	local trueshot_modifier = keys.trueshot_modifier
	local trueshot_damage_modifier = keys.trueshot_damage_modifier

	-- Check if its a valid target
	if target and IsValidEntity(target) and target:HasModifier(trueshot_modifier) then
		local agility = caster:GetAgility()
		local percent = ability:GetLevelSpecialValueFor("trueshot_ranged_damage", ability_level) 
		local trueshot_damage = math.floor(agility * percent / 100)

		-- If it doesnt have the stack modifier then apply it
		if not target:FindModifierByName(trueshot_damage_modifier) then
			ability:ApplyDataDrivenModifier(caster, target, trueshot_damage_modifier, {})
		end
		
		-- Set the damage to the calculated damage
		target:SetModifierStackCount(trueshot_damage_modifier, caster, trueshot_damage)
	end
end
