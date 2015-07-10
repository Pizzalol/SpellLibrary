--[[Author: Pizzalol
	Date: 18.01.2015.
	Kills illusions, if its not an illusion then it moves the caster direction,
	checks the leash distance and drains mana from the target]]
function mana_drain( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	-- If its an illusion then kill it
	if target:IsIllusion() then
		target:ForceKill(true)
	else
		-- Location variables
		local caster_location = caster:GetAbsOrigin()
		local target_location = target:GetAbsOrigin()

		-- Distance variables
		local distance = (target_location - caster_location):Length2D()
		local break_distance = ability:GetLevelSpecialValueFor("break_distance", (ability:GetLevel() - 1))
		local direction = (target_location - caster_location):Normalized()

		-- If the leash is broken then stop the channel
		if distance >= break_distance then
			ability:OnChannelFinish(false)
			caster:Stop()
			return
		end

		-- Make sure that the caster always faces the target
		caster:SetForwardVector(direction)

		-- Mana calculation
		local mana_per_second = ability:GetLevelSpecialValueFor("mana_per_second", (ability:GetLevel() - 1))
		local tick_interval = ability:GetLevelSpecialValueFor("tick_interval", (ability:GetLevel() - 1))
		local mana_drain = mana_per_second / (1/tick_interval)

		local target_mana = target:GetMana()

		-- Mana drain part
		-- If the target has enough mana then drain the maximum amount
		-- otherwise drain whatever is left
		if target_mana >= mana_drain then
			target:ReduceMana(mana_drain)
			caster:GiveMana(mana_drain)
		else
			target:ReduceMana(target_mana)
			caster:GiveMana(target_mana)
		end
	end
end

--[[Author: Pizzalol
	Date: 18.01.2015.
	Stops the sound from looping]]
function mana_drain_stop_sound( keys )
	local target = keys.target
	local sound = keys.sound

	StopSoundEvent(sound, target)
end