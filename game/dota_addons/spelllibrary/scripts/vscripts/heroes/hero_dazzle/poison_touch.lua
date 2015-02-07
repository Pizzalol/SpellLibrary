--[[Author: Pizzalol
	Date: 07.02.2015.
	Checks if the current ability level is supposed to stun, if yes then stun the target]]
function PoisonTouchStun( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local ability_level = ability:GetLevel() - 1
	local stun_duration = ability:GetLevelSpecialValueFor("stun_duration", ability_level)
	local should_stun = ability:GetLevelSpecialValueFor("should_stun", ability_level)

	if should_stun == 1 then
		target:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun_duration})
	end
end