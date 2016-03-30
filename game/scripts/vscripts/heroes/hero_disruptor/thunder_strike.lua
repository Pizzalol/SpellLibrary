--[[Author: YOLOSPAGHETTI
	Date: March 30, 2016
	Gives vision to the caster's team]]
function GiveVisionEnd(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local vision_radius = ability:GetLevelSpecialValueFor("vision_radius", ability:GetLevel() -1)
	local vision_duration = ability:GetLevelSpecialValueFor("vision_duration", ability:GetLevel() -1)
		
	AddFOWViewer(caster:GetTeam(), target:GetAbsOrigin(), vision_radius, vision_duration, false)
end
