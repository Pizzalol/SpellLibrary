--[[Author: YOLOSPAGHETTI
	Date: March 28, 2016
	Gives the caster's team vision in the radius]]
function GiveVision(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local sight_radius = ability:GetLevelSpecialValueFor("sight_radius", (ability:GetLevel() -1))
	local sight_duration = ability:GetLevelSpecialValueFor("sight_duration", (ability:GetLevel() -1))
	
	AddFOWViewer(caster:GetTeam(), point, sight_radius, sight_duration, false)
end
