--[[Author: Pizzalol
	Date: 03.04.2015.
	Pulls the targets to the center]]
function Vacuum( keys )
	local caster = keys.caster
	local target = keys.target
	local target_location = target:GetAbsOrigin()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability variables
	local duration = ability:GetLevelSpecialValueFor("duration", ability_level)
	local radius = ability:GetLevelSpecialValueFor("radius", ability_level)
	local vacuum_modifier = keys.vacuum_modifier
	local remaining_duration = duration - (GameRules:GetGameTime() - target.vacuum_start_time)

	-- Targeting variables
	local target_teams = ability:GetAbilityTargetTeam() 
	local target_types = ability:GetAbilityTargetType() 
	local target_flags = ability:GetAbilityTargetFlags() 

	local units = FindUnitsInRadius(caster:GetTeamNumber(), target_location, nil, radius, target_teams, target_types, target_flags, FIND_CLOSEST, false)

	-- Calculate the position of each found unit
	for _,unit in ipairs(units) do
		local unit_location = unit:GetAbsOrigin()
		local vector_distance = target_location - unit_location
		local distance = (vector_distance):Length2D()
		local direction = (vector_distance):Normalized()

		-- Check if its a new vacuum cast
		-- Set the new pull speed if it is
		if unit.vacuum_caster ~= target then
			unit.vacuum_caster = target
			-- The standard speed value is for 1 second durations so we have to calculate the difference
			-- with 1/duration
			unit.vacuum_caster.pull_speed = distance * 1/duration * 1/30
		end

		-- Apply the stun and no collision modifier then set the new location
		ability:ApplyDataDrivenModifier(caster, unit, vacuum_modifier, {duration = remaining_duration})
		unit:SetAbsOrigin(unit_location + direction * unit.vacuum_caster.pull_speed)

	end
end

--[[Author: Pizzalol
	Date: 03.04.2015.
	Track the starting vacuum time]]
function VacuumStart( keys )
	local target = keys.target

	target.vacuum_start_time = GameRules:GetGameTime()
end