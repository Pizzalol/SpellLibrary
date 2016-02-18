--[[Author: YOLOSPAGHETTI
	Date: February 18, 2016
	Pulls the targets to the center]]
function MoveUnits( keys )
	local caster = keys.caster
	local target = keys.target
	local target_location = target:GetAbsOrigin()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Takes note of the point entity, so we know what to remove the thinker from when the channel ends
	ability.point_entity = target
	
	-- Ability variables
	local speed = ability:GetLevelSpecialValueFor("pull_speed", ability_level)/10
	local radius = ability:GetLevelSpecialValueFor("far_radius", ability_level)

	-- Targeting variables
	local target_teams = ability:GetAbilityTargetTeam() 
	local target_types = ability:GetAbilityTargetType() 
	local target_flags = ability:GetAbilityTargetFlags() 

	-- Units to be caught in the black hole
	local units = FindUnitsInRadius(caster:GetTeamNumber(), target_location, nil, radius, target_teams, target_types, 0, 0, false)

	-- Calculate the position of each found unit in relation to the center
	for i,unit in ipairs(units) do
		local unit_location = unit:GetAbsOrigin()
		local vector_distance = target_location - unit_location
		local distance = (vector_distance):Length2D()
		local direction = (vector_distance):Normalized()
		-- If the target is greater than 40 units from the center, we move them 40 units towards it, otherwise we move them directly to the center
		if distance >= 40 then
			unit:SetAbsOrigin(unit_location + direction * speed)
		else
			unit:SetAbsOrigin(unit_location + direction * distance)
		end
	end
end

--[[Author: YOLOSPAGHETTI
	Date: February 18, 2016
	Removes the thinker from the point entity and the sound from the caster when the channel ends]]
function ChannelEnd(keys)
	local ability = keys.ability
	local caster = keys.caster
	
	if ability.point_entity:IsNull() == false then
		ability.point_entity:RemoveModifierByName("modifier_black_hole_datadriven")
		StopSoundOn("Hero_Enigma.Black_Hole", caster)
	end
end

--[[Author: YOLOSPAGHETTI
	Date: February 18, 2016
	Gives vision over the aoe]]
function GiveVision(keys)
	caster = keys.caster
	ability = keys.ability
	local vision_radius = ability:GetLevelSpecialValueFor( "vision_radius", ability:GetLevel() - 1 )
	local duration = ability:GetLevelSpecialValueFor( "duration", ability:GetLevel() - 1 )
	
	AddFOWViewer(caster:GetTeam(), ability:GetCursorPosition(), vision_radius, duration, false)
end
