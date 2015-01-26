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