--[[Author: Pizzalol
	Date: 11.03.2015.
	Stops the specified sound from playing]]
function FiendsGripStopSound( keys )
	local target = keys.target
	local sound = keys.sound

	StopSoundEvent(sound, target)
end

--[[Fiends grip mana drain
	Author: chrislotix, Pizzalol
	Date: 11.1.2015.
	Changed: 11.03.2015.
	Reason: Improved the code]]
function ManaDrain( keys )	
	local target = keys.target
	local caster = keys.caster
	local ability = keys.ability
	local mana_drain = ability:GetLevelSpecialValueFor("fiend_grip_mana_drain", (ability:GetLevel() -1)) / 100

	local max_mana_drain = target:GetMaxMana() * mana_drain
	local current_mana = target:GetMana()

	-- Calculates the amount of mana to be given to the caster
	if current_mana >= max_mana_drain then
		caster:GiveMana(max_mana_drain)
	else
		caster:GiveMana(current_mana)
	end

	target:ReduceMana(max_mana_drain)
end

--[[Author: Pizzalol
	Date: 11.03.2015.
	Reveals the target if its invisible]]
function FiendsGripInvisCheck( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local modifier = keys.modifier

	if target:IsInvisible() then
		ability:ApplyDataDrivenModifier(caster, target, modifier, {})
	end
end
