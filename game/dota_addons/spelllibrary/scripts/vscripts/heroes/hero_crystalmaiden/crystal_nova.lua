--[[
	Author: kritth
	Date: 1.1.2015.
	Provide vision post-attack
]]
function crystal_nova_post_vision( keys )
	-- Variables
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local duration = ability:GetLevelSpecialValueFor( "vision_duration", ( ability:GetLevel() - 1 ) )
	local modifierName = "modifier_crystal_nova_post_vision_datadriven"

	-- Create unit to reference the point
	local dummy = CreateUnitByName( "npc_dummy_blank", keys.target_points[1], false, caster, caster, caster:GetTeamNumber() )
	ability:ApplyDataDrivenModifier( caster, dummy, modifierName, {} )
	
	-- Create timer to destroy
	Timers:CreateTimer( duration, function() dummy:Destroy() end )
end
