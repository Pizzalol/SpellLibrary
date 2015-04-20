--[[
	Author: Noya
	Date: April 5, 2015
	Return a front position at a distance
]]
function ShadowrazePoint( event )
	local caster = event.caster
	local fv = caster:GetForwardVector()
	local origin = caster:GetAbsOrigin()
	local distance = event.distance
	
	local front_position = origin + fv * distance
	local result = {}
	table.insert(result, front_position)

	return result
end