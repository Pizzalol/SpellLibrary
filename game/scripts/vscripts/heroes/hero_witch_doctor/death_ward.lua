--[[Author: YOLOSPAGHETTI
	Date: March 15, 2016
	Creates the death ward]]
function CreateWard(keys)
	local caster = keys.caster
	local ability = keys.ability
	local position = ability:GetCursorPosition()
	
	-- Creates the death ward (There is no way to control the default ward, so this is a custom one)
	caster.death_ward = CreateUnitByName("witch_doctor_death_ward_datadriven", position, true, caster, nil, caster:GetTeam())
	caster.death_ward:SetControllableByPlayer(caster:GetPlayerID(), true)
	caster.death_ward:SetOwner(caster)
	
	-- Applies the modifier (gives it damage, removes health bar, and makes it invulnerable)
	ability:ApplyDataDrivenModifier( caster, caster.death_ward, "modifier_death_ward_datadriven", {} )
end

--[[Author: YOLOSPAGHETTI
	Date: March 15, 2016
	Removes the death ward entity from the game and stops its sound]]
function DestroyWard(keys)
	local caster = keys.caster
	
	UTIL_Remove(caster.death_ward)
	StopSoundEvent(keys.sound, caster)
end
