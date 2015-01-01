--[[
	Author: kritth
	Date: 1.1.2015
	Teleport sandking to destination
]]
function burrowstrike_teleport( keys )
	local point = keys.target_points[1]
	local caster = keys.caster
	FindClearSpaceForUnit( caster, point, false )
end
