--[[Author: Pizzalol
	Date: 26.02.2015.
	Purges positive buffs from the target]]
function DoomPurge( keys )
	local target = keys.target

	-- Purge
	local RemovePositiveBuffs = true
	local RemoveDebuffs = false
	local BuffsCreatedThisFrameOnly = false
	local RemoveStuns = false
	local RemoveExceptions = false
	target:Purge( RemovePositiveBuffs, RemoveDebuffs, BuffsCreatedThisFrameOnly, RemoveStuns, RemoveExceptions)
end

--[[Author: Pizzalol
	Date: 26.02.2015.
	The deny check is run every frame, if the target is within deny range then apply the deniable state for the
	duration of 2 frames]]
function DoomDenyCheck( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	local deny_pct = ability:GetLevelSpecialValueFor("deniable_pct", ability_level)
	local modifier = keys.modifier

	local target_hp = target:GetHealth()
	local target_max_hp = target:GetMaxHealth()
	local target_hp_pct = (target_hp / target_max_hp) * 100

	if target_hp_pct <= deny_pct then
		ability:ApplyDataDrivenModifier(caster, target, modifier, {duration = 0.06})
	end
end

-- Stops the sound from playing
function StopSound( keys )
	local target = keys.target
	local sound = keys.sound

	StopSoundEvent(sound, target)
end