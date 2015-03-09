--[[Author: Pizzalol
	Date: 10.01.2015.
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
	local dummy = CreateUnitByName("npc_dummy_blank", target_point, false, caster, caster, caster:GetTeam())
	dummy:AddNewModifier(caster, nil, "modifier_phased", {})
	ability:ApplyDataDrivenModifier(caster, dummy, dummy_modifier, {})

	-- Vision
	ability:CreateVisibilityNode(target_point, vision_radius, duration)

	-- Timer to remove the dummy
	Timers:CreateTimer(duration, function() dummy:RemoveSelf() end)
end

--[[Author: Pizzalol
	Date: 10.01.2015.
	Checks if the target is a unit owned by the player that cast the Chronosphere
	If it is then it applies the no collision and extra movementspeed modifier
	otherwise it applies the stun modifier]]
function ChronosphereAura( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local aura_modifier = keys.aura_modifier
	local caster_modifier = keys.caster_modifier
	local ignore_void = ability:GetLevelSpecialValueFor("ignore_void", (ability:GetLevel() - 1))

	-- Variable for deciding if Chronosphere should affect Faceless Void
	if ignore_void == 0 then ignore_void = false
	else ignore_void = true end


	if (caster:GetPlayerOwner() == target:GetPlayerOwner()) or (target:GetName() == "npc_dota_hero_faceless_void" and ignore_void) then
		ability:ApplyDataDrivenModifier(caster, target, caster_modifier, {})
	else
		ability:ApplyDataDrivenModifier(caster, target, aura_modifier, {}) 
	end
end