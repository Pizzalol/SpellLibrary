--[[Author: Pizzalol
	Date: 26.01.2015.
	Swaps the position of the caster and the target]]
function NetherSwap( keys )
	local caster = keys.caster
	local target = keys.target

	local caster_position = caster:GetAbsOrigin()
	local target_position = target:GetAbsOrigin()

	caster:SetAbsOrigin(target_position)
	target:SetAbsOrigin(caster_position)

	-- Stops the current action of the target
	target:Stop()
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