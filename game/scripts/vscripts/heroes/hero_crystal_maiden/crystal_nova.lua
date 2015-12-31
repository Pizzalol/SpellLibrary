--[[
	Author: kritth
	Date: 31.12.2015.
	Provide vision post-attack
]]
function crystal_nova_post_vision( keys )
	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target_points[ 1 ]
	local duration = ability:GetLevelSpecialValueFor( "vision_duration", ( ability:GetLevel() - 1 ) )
	local radius = ability:GetLevelSpecialValueFor( "vision_radius", ( ability:GetLevel() - 1 ) )

	-- Create unobstructed vision around the point
	AddFOWViewer(caster:GetTeamNumber(), target, radius, duration, false)
end
