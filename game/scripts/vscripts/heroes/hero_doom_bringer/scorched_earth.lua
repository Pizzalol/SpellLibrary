--[[Author: Pizzalol
	Date: 24.02.2015.
	Checks if the target is owned by the caster or if its the caster itself
	If yes then it applies the scorched earth buff]]
function ScorchedEarthCheck( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local modifier = keys.modifier

	if target:GetOwner() == caster or target == caster then
		ability:ApplyDataDrivenModifier(caster, target, modifier, {})
	end
end

-- Stops the sound from playing
function StopSound( keys )
	local target = keys.target
	local sound = keys.sound

	StopSoundEvent(sound, target)
end