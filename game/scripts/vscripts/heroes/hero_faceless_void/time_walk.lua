--[[Author: Pizzalol
	Date: 07.01.2015.
	Moves the caster to the target location
	Upon getting to the location it removes the invulnerability and slow aura modifiers]]
function TimeWalk( keys )
	local caster = keys.caster
	local caster_location = caster:GetAbsOrigin() 
	local target_point = keys.target_points[1]
	local ability = keys.ability
	local caster_modifier = keys.caster_modifier
	local caster_aura = keys.caster_aura

	local speed = ability:GetLevelSpecialValueFor("speed", (ability:GetLevel() - 1)) * 0.03
	local distance = (target_point - caster_location):Length2D()
	local direction = (target_point - caster_location):Normalized()
	local traveled_distance = 0

	-- Moving the caster
	Timers:CreateTimer(0, function()
		if traveled_distance < distance then
			caster_location = caster_location + direction * speed
			caster:SetAbsOrigin(caster_location)
			traveled_distance = traveled_distance + speed
			return 0.03
		else
			caster:RemoveModifierByName(caster_modifier)
			caster:RemoveModifierByName(caster_aura)
		end

	end)

end