--[[Fiends grip stop loop sound
	Author: chrislotix
	Date: 11.1.2015.]]

function FiendsGripStopLoop( keys )
	
	local sound_name = "Hero_Bane.FiendsGrip"
	local target = keys.target

	StopSoundEvent(sound_name, target)

end

--[[Fiends grip cast stop loop sound
	Author: chrislotix
	Date: 11.1.2015.]]

function FiendsGripCastStopLoop( keys )
	
	local sound_name = "Hero_Bane.FiendsGrip.Cast"
	local target = keys.target

	StopSoundEvent(sound_name, target)

end

--[[Fiends grip mana drain
	Author: chrislotix
	Date: 11.1.2015.]]

function ManaDrain( keys )
	
	local target = keys.target
	local caster = keys.caster
	local ability = keys.ability
	local mana_drain = ability:GetLevelSpecialValueFor("fiend_grip_mana_drain", (ability:GetLevel() -1))

	target:ReduceMana(mana_drain)

end

