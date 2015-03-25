--[[Author: Pizzalol
	Date: 25.03.2015.
	Creates the stasis trap unit and initializes all the required functions of the unit]]
function StasisTrapPlant( keys )
	local caster = keys.caster
	local target_point = keys.target_points[1]
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Modifiers
	local modifier_tracker = keys.modifier_tracker
	local modifier_stasis_trap_invisibility = keys.modifier_stasis_trap_invisibility
	local modifier_stasis_trap = keys.modifier_stasis_trap

	-- Ability variables
	local activation_time = ability:GetLevelSpecialValueFor("activation_time", ability_level) 
	local fade_time = ability:GetLevelSpecialValueFor("fade_time", ability_level) 
	local duration = ability:GetLevelSpecialValueFor("duration", ability_level) 

	-- Create the stasis trap and apply the stasis trap modifier and duration
	local stasis_trap = CreateUnitByName("npc_dota_techies_stasis_trap", target_point, false, nil, nil, caster:GetTeamNumber())
	stasis_trap:AddNewModifier(caster, ability, "modifier_kill", {Duration = duration})
	ability:ApplyDataDrivenModifier(caster, stasis_trap, modifier_stasis_trap, {})

	-- Apply the unit tracker after the activation time
	Timers:CreateTimer(activation_time, function()
		ability:ApplyDataDrivenModifier(caster, stasis_trap, modifier_tracker, {})
	end)

	-- Apply the invisibility after the fade time
	Timers:CreateTimer(fade_time, function()
		ability:ApplyDataDrivenModifier(caster, stasis_trap, modifier_stasis_trap_invisibility, {})
	end)
end

--[[Author: Pizzalol
	Date: 25.03.2015.
	Tracks if there are any enemy units within the trigger radius]]
function StasisTrapTracker( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability variables
	local activation_radius = ability:GetLevelSpecialValueFor("activation_radius", ability_level) 
	local explode_delay = ability:GetLevelSpecialValueFor("explode_delay", ability_level)
	local vision_radius = ability:GetLevelSpecialValueFor("vision_radius", ability_level) 
	local vision_duration = ability:GetLevelSpecialValueFor("vision_duration", ability_level)
	local modifier_trigger = keys.modifier_trigger

	-- Target variables
	local target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
	local target_types = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
	local target_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES

	-- Find the valid units in the trigger radius
	local units = FindUnitsInRadius(target:GetTeamNumber(), target:GetAbsOrigin(), nil, activation_radius, target_team, target_types, target_flags, FIND_CLOSEST, false) 

	-- If there is a valid unit in range then explode the mine
	if #units > 0 then
		Timers:CreateTimer(explode_delay, function()
			if target:IsAlive() then
				ability:ApplyDataDrivenModifier(caster, target, modifier_trigger, {})

				-- Create vision upon exploding
				ability:CreateVisibilityNode(target:GetAbsOrigin(), vision_radius, vision_duration)
			end
		end)
	end
end

--[[Author: Pizzalol
	Date: 25.03.2015.
	Upon a Stasis Trap activation, remove all traps within the activation radius]]
function StasisTrapRemove( keys )
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability variables
	local activation_radius = ability:GetLevelSpecialValueFor("activation_radius", ability_level)
	local unit_name = target:GetUnitName()

	-- Target variables
	local target_team = DOTA_UNIT_TARGET_TEAM_FRIENDLY
	local target_types = DOTA_UNIT_TARGET_ALL
	local target_flags = DOTA_UNIT_TARGET_FLAG_NONE

	local units = FindUnitsInRadius(target:GetTeamNumber(), target:GetAbsOrigin(), nil, activation_radius, target_team, target_types, target_flags, FIND_CLOSEST, false)

	for _,unit in ipairs(units) do
		if unit:GetUnitName() == unit_name then
			unit:ForceKill(true) 
		end
	end
end