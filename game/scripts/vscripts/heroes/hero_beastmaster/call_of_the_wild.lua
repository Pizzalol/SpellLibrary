--[[
	Author: Noya
	Date: April 5, 2015
	Get a point at a distance in front of the caster
]]
function GetFrontPoint( event )
	local caster = event.caster
	local fv = caster:GetForwardVector()
	local origin = caster:GetAbsOrigin()
	local distance = event.Distance
	
	local front_position = origin + fv * distance
	local result = {}
	table.insert(result, front_position)

	return result
end

-- Set the units looking at the same point of the caster
function SetUnitsMoveForward( event )
	local caster = event.caster
	local target = event.target
	local fv = caster:GetForwardVector()
	local origin = caster:GetAbsOrigin()
	target:SetForwardVector(fv)
end


