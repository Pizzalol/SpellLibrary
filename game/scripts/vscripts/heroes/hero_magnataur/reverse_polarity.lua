--[[Author: YOLOSPAGHETTI
	Date: July 15, 2016
	Puts all the targets offset in front of the caster, and stuns them]]
function ReversePolarity(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	local hero_stun_duration = ability:GetLevelSpecialValueFor("hero_stun_duration", ability:GetLevel() - 1)
	local creep_stun_duration = ability:GetLevelSpecialValueFor("creep_stun_duration", ability:GetLevel() - 1)
	local pull_offset = ability:GetLevelSpecialValueFor("pull_offset", ability:GetLevel() - 1)
	
	-- The angle the caster is facing
	local caster_angle = caster:GetForwardVector()
	-- The caster's position
	local caster_origin = caster:GetAbsOrigin()
	-- The vector from the caster to the target position
	local offset_vector = caster_angle * pull_offset
	-- The target's new position
	local new_location = caster_origin + offset_vector
	
	-- Moves all the targets to the position
	target:SetAbsOrigin(new_location)
	FindClearSpaceForUnit(target, new_location, true)
	
	-- Applies the stun modifier based on the unit's type
	if target:IsHero() == true then
		target:AddNewModifier(caster, ability, "modifier_stunned", {Duration = hero_stun_duration})
	else
		target:AddNewModifier(caster, ability, "modifier_stunned", {Duration = creep_stun_duration})
	end
end
