--Author: Nightborn and KAL
--Created: August 27, 2016

function ForceStaff (keys)

	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1	

	target:Stop()

	ability.forced_direction = target:GetForwardVector()
	ability.forced_distance = ability:GetLevelSpecialValueFor("push_length", ability_level)
	ability.forced_speed = ability:GetLevelSpecialValueFor("push_speed", ability_level) * 1/30	-- * 1/30 gives a duration of ~0.4 second push time (which is what the gamepedia-site says it should be)
	ability.forced_traveled = 0

end

function ForceHorizontal( keys )

	local target = keys.target
	local ability = keys.ability

	if ability.forced_traveled < ability.forced_distance then
		target:SetAbsOrigin(target:GetAbsOrigin() + ability.forced_direction * ability.forced_speed)
		ability.forced_traveled = ability.forced_traveled + (ability.forced_direction * ability.forced_speed):Length2D()
	else
		target:InterruptMotionControllers(true)
	end

end
