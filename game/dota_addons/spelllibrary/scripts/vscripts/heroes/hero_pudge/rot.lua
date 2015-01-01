--[[Author: Pizzalol
	Date: 1.1.2015.
	Stops the rot sound]]
function RotStopSound( keys )
	local caster = keys.caster
	local sound = "Hero_Pudge.Rot"

	StopSoundEvent(sound, caster)
end