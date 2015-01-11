--[[Last Word stop loop sound
	Author: chrislotix
	Date: 11.1.2015.]]

function LastWordStopSound( keys )

	local sound_name = "Hero_Silencer.LastWord.Target"
	local unit = keys.unit

	StopSoundEvent(sound_name, unit)
end