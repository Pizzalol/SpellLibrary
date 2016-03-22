--[[Author: YOLOSPAGHETTI
	Date: March 22, 2016
	Creates the sprout]]
function CreateSprout(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() -1))
	local vision_range = ability:GetLevelSpecialValueFor("vision_range", (ability:GetLevel() -1))
	local trees = 8
	local radius = 150
	local angle = math.pi/4
	
	-- Creates 8 temporary trees at 45 degree angles from the clicked point
	for i=1,trees do
		local position = Vector(point.x+radius*math.sin(angle), point.y+radius*math.cos(angle), point.z)
		CreateTempTree(position, duration)
		angle = angle + math.pi/4
	end
	-- Gives vision to the caster's team in a radius around the clicked point for the duration
	AddFOWViewer(caster:GetTeam(), point, vision_range, duration, false)
end
