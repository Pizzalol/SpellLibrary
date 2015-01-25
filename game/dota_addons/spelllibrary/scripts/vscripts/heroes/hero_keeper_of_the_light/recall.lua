--[[Author: Pizzalol
	Date: 19.01.2015.
	Changed: 25.01.2015.
	Reason: Fixed error case
	Finds the closest unit to the selected point and then applies the Recall modifier]]
function Recall( keys )
	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]

	-- Extra variables
	local sound_caster = keys.sound_caster
	local sound_target = keys.sound_target
	local modifier = keys.modifier
	local duration = ability:GetLevelSpecialValueFor("teleport_delay", (ability:GetLevel() - 1))

	-- Find the closest target
	local targets = FindUnitsInRadius(caster:GetTeam(), point, nil, FIND_UNITS_EVERYWHERE, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_CLOSEST, false)
	
	-- In case the caster is the only one available then it stops the sound
	if #targets < 2 then
		Timers:CreateTimer(0.03, function()
			StopSoundOn(sound_caster, caster)
		end)
		return
	end

	-- Apply the modifier to the closest target
	for _,v in ipairs(targets) do
		if v ~= caster then
			ability:ApplyDataDrivenModifier(caster, v, modifier, {duration = duration})
			EmitSoundOn(sound_target, v)

			-- Stop the sound after the duration
			Timers:CreateTimer(duration, function()				
				StopSoundOn(sound_caster, caster)
				StopSoundOn(sound_target, v)
				-- Stop the active command of the target upon being teleported
				v:Stop()
			end)
			return
		end
	end
end

--[[Author: Pizzalol
	Date: 19.01.2015.
	Finds the closest unit to the selected point and then applies the Recall modifier]]
function RecallFail( keys )
	local caster = keys.caster
	local target = keys.unit

	local sound_caster = keys.sound_caster
	local sound_target = keys.sound_target

	StopSoundOn(sound_caster, caster)
	StopSoundOn(sound_target, target)
end