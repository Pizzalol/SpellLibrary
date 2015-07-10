--[[Author: Pizzalol
	Date: 24.03.2015.
	Checks if the unit is owned by a player]]
function Howl( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	local playerID = target:GetPlayerOwnerID()
	local duration = ability:GetLevelSpecialValueFor("think_interval", ability_level)
	local modifier = keys.modifier

	-- If the unit is owned by a player then apply the unit modifier
	if playerID then
		ability:ApplyDataDrivenModifier(caster, target, modifier, {Duration = duration}) 
	end
end