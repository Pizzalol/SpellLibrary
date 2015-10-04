LinkLuaModifier("modifier_chronosphere_speed_lua", "heroes/hero_faceless_void/modifiers/modifier_chronosphere_speed_lua.lua", LUA_MODIFIER_MOTION_NONE)

--[[Author: Pizzalol
	Date: 26.09.2015.
	Creates a dummy at the target location that acts as the Chronosphere]]
function Chronosphere( keys )
	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	local target_point = keys.target_points[1]

	-- Special Variables
	local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() - 1))
	local vision_radius = ability:GetLevelSpecialValueFor("vision_radius", (ability:GetLevel() - 1))

	-- Dummy
	local dummy_modifier = keys.dummy_aura
	local dummy = CreateUnitByName("npc_dummy_unit", target_point, false, caster, caster, caster:GetTeam())
	dummy:AddNewModifier(caster, nil, "modifier_phased", {})
	ability:ApplyDataDrivenModifier(caster, dummy, dummy_modifier, {duration = duration})

	-- Vision
	AddFOWViewer(caster:GetTeamNumber(), target_point, vision_radius, duration, false)

	-- Timer to remove the dummy
	Timers:CreateTimer(duration, function() dummy:RemoveSelf() end)
end

--[[Author: Pizzalol
	Date: 26.09.2015.
	Checks if the target is a unit owned by the player that cast the Chronosphere
	If it is then it applies the no collision and extra movementspeed modifier
	otherwise it applies the stun modifier]]
function ChronosphereAura( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability variables
	local aura_modifier = keys.aura_modifier
	local ignore_void = ability:GetLevelSpecialValueFor("ignore_void", ability_level)
	local duration = ability:GetLevelSpecialValueFor("aura_interval", ability_level)

	-- Variable for deciding if Chronosphere should affect Faceless Void
	if ignore_void == 0 then ignore_void = false
	else ignore_void = true end

	-- Check if it is a caster controlled unit or not
	-- Caster controlled units get the phasing and movement speed modifier
	if (caster:GetPlayerOwner() == target:GetPlayerOwner()) or (target:GetName() == "npc_dota_hero_faceless_void" and ignore_void) then
		target:AddNewModifier(caster, ability, "modifier_chronosphere_speed_lua", {duration = duration})
	else
	-- Everyone else gets immobilized and stunned
		target:InterruptMotionControllers(false)
		ability:ApplyDataDrivenModifier(caster, target, aura_modifier, {duration = duration}) 
	end
end