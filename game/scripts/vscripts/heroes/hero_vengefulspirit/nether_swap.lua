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

--[[
	Author: igo95862, Noya
	Used by: Pizzalol
	Date: 26.01.2015.
	Disallows self targeting by checking if the target is not the caster when the ability starts
]]
function NetherSwapPreCast( event )
	local caster = event.caster
	local target = event.target
	local player = caster:GetPlayerOwner()
	local pID = caster:GetPlayerOwnerID()

	-- This prevents the spell from going off
	if target == caster then
		caster:Stop()

		-- Play Error Sound
		EmitSoundOnClient("General.CastFail_InvalidTarget_Hero", player)

		-- This makes use of the Custom Error Flash module by zedor. https://github.com/zedor/CustomError
		FireGameEvent( 'custom_error_show', { player_ID = pID, _error = "Ability can't target Self" } )
	end
end