--[[Author: Pizzalol
	Date: 12.07.2015.
	Swaps the position of the caster and the target]]
function NetherSwap( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local tree_radius = ability:GetLevelSpecialValueFor("tree_radius", ability:GetLevel() - 1)

	local caster_position = caster:GetAbsOrigin()
	local target_position = target:GetAbsOrigin()

	-- Destroy trees around the caster and target
	GridNav:DestroyTreesAroundPoint( caster_position, tree_radius, false )
	GridNav:DestroyTreesAroundPoint( target_position, tree_radius, false )

	-- Swap their positions
	caster:SetAbsOrigin(target_position)
	target:SetAbsOrigin(caster_position)

	-- Make sure that they dont get stuck
	FindClearSpaceForUnit( caster, target_position, true )
	FindClearSpaceForUnit( target, caster_position, true )

	-- Stops the current action of the target
	target:Interrupt()
end