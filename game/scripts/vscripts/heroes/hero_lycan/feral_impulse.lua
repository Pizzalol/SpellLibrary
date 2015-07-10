--[[Author: Pizzalol
	Date: 24.03.2015.
	Checks if the target owner is the same as the caster owner]]
function FeralImpulse( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	local modifier = keys.modifier
	local duration = ability:GetLevelSpecialValueFor("think_interval", ability_level) 
	local caster_owner = caster:GetPlayerOwner() 
	local target_owner = target:GetPlayerOwner() 

	-- If they are the same then apply the modifier
	if caster_owner == target_owner then
		ability:ApplyDataDrivenModifier(caster, target, modifier, {Duration = duration}) 
	end
end