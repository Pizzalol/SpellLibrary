--[[Author: YOLOSPAGHETTI
	Date: February 13, 2016
	Gives the caster's team flying vision at the point of cast]]
function GiveVision(keys)
	caster = keys.caster
	ability = keys.ability
	local flying_vision = ability:GetLevelSpecialValueFor( "flying_vision", ability:GetLevel() - 1 )
	local vision_duration = ability:GetLevelSpecialValueFor( "vision_duration", ability:GetLevel() - 1 )
	
	AddFOWViewer(caster:GetTeam(), ability:GetCursorPosition(), flying_vision, vision_duration, false)
end
