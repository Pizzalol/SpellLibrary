--[[Author: Pizzalol
	Date: 13.10.2015.
	Provides vision over the targeted area]]
function IceVortexVision( keys )
	local caster = keys.caster
	local target_point = keys.target_points[1]
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	local duration = ability:GetLevelSpecialValueFor("duration", ability_level)
	local vision_aoe = ability:GetLevelSpecialValueFor("vision_aoe", ability_level)

	AddFOWViewer(caster:GetTeamNumber(), target_point, vision_aoe, duration, true)
end

--[[Author: Pizzalol
	Date: 11.02.2015.
	Stops the sound from playing on the targeted unit]]
function IceVortexStopSound( keys )
	local target = keys.target
	local sound = keys.sound

	StopSoundEvent(sound, target)
end