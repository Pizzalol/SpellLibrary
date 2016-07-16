--[[Author: YOLOSPAGHETTI
	Date: July 15, 2016
	Calculates all the values for the motion controllers]]
function Skewer(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	local skewer_speed = ability:GetLevelSpecialValueFor("skewer_speed", ability:GetLevel() - 1)
	local range = ability:GetLevelSpecialValueFor("range", ability:GetLevel() - 1)
	local point = ability:GetCursorPosition()
	
	-- Distance and direction variables
	local vector_distance = point - caster:GetAbsOrigin()
	local distance = (vector_distance):Length2D()
	local direction = (vector_distance):Normalized()
	
	-- If the caster targets over the max range, sets the distance to the max
	if distance > range then
		point = caster:GetAbsOrigin() + range * direction
		distance = range
	end
	
	-- Total distance to travel
	ability.distance = distance
	
	-- Distance traveled per interval
	ability.speed = skewer_speed/30
	
	-- The direction to travel
	ability.direction = direction
	
	-- Distance traveled so far
	ability.traveled_distance = 0
	
	-- Applies the disable modifier
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_skewer_disable_caster", {})
end

--[[Author: YOLOSPAGHETTI
	Date: July 15, 2016
	Checks if targets are within range of the skewer]]
function CheckTargets(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	local skewer_radius = ability:GetLevelSpecialValueFor("skewer_radius", ability:GetLevel() - 1)
	local hero_offset = ability:GetLevelSpecialValueFor("hero_offset", ability:GetLevel() - 1)

	-- Units to be caught in the skewer
	local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, skewer_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false)
	
	-- Loops through target
	for i,unit in ipairs(units) do
		-- Checks if the target is already affected by skewer
		if unit:HasModifier("modifier_skewer_disable_target") == false then
			-- If not, move it offset in front of the caster
			local new_position = caster:GetAbsOrigin() + hero_offset * ability.direction
			unit:SetAbsOrigin(new_position)
			-- Apply the motion controller to the target
			ability:ApplyDataDrivenModifier(caster, unit, "modifier_skewer_disable_target", {})
		end
	end
end

--[[Author: YOLOSPAGHETTI
	Date: July 15, 2016
	Applies motion to the target]]
function SkewerMotion(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	-- Move the target while the distance traveled is less than the original distance upon cast
	if ability.traveled_distance < ability.distance then
		target:SetAbsOrigin(target:GetAbsOrigin() + ability.direction * ability.speed)
		-- If the target is the caster, calculate the new travel distance
		if target == caster then
			ability.traveled_distance = ability.traveled_distance + ability.speed
		end
	else
		FindClearSpaceForUnit(target, target:GetAbsOrigin(), true)
		-- Remove the motion controller once the distance has been traveled
		target:InterruptMotionControllers(true)
		-- Remove the appropriate disable modifier from the target
		if target == caster then
			target:RemoveModifierByName("modifier_skewer_disable_caster")
		else
			target:RemoveModifierByName("modifier_skewer_disable_target")
		end
	end
end
