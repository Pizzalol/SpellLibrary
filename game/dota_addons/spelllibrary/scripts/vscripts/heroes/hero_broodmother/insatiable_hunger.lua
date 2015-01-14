--[[Author: Pizzalol
	Date: 14.01.2015.
	Stops the sound upon expiration]]
function InsatiableHungerStopSound( keys )
	local caster = keys.caster
	local sound = keys.sound

	StopSoundEvent(sound, caster)
end