--[[Author: YOLOSPAGHETTI
	Date: February 14, 2016
	Checks if the target already has a projectile flying at it, and attempts to send one at a fresh target]]
function CheckTargets(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = caster:FindAbilityByName("ogre_magi_ignite_datadriven")
	local multicast_range = ability:GetLevelSpecialValueFor("multicast_range", ability:GetLevel() -1)
	local multicast_delay = ability:GetLevelSpecialValueFor("multicast_delay", ability:GetLevel() -1)
	local is_new_target = 0
	
	if target:HasModifier("modifier_ignite_multicast") then
		local units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, multicast_range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
		-- Checks all the units in the radius to see if they have the modifier, and applies it to the first unit without
		for i,unit in ipairs(units) do
			if unit:HasModifier("modifier_ignite_multicast") then
			else
				ability:ApplyDataDrivenModifier( caster, unit, "modifier_ignite_multicast", {Duration = 4*multicast_delay} )
				is_new_target = 1
				break
			end
		end
		-- Applies the modifier to the initial target again if there are no units in the radius without it
		if is_new_target == 0 then
			ability:ApplyDataDrivenModifier( caster, target, "modifier_ignite_multicast", {Duration = 4*multicast_delay} )
		end
	else
		-- Applies the modifier to the initial target if it does not already have it
		ability:ApplyDataDrivenModifier( caster, target, "modifier_ignite_multicast", {Duration = 4*multicast_delay} )
	end
end

--[[Author: YOLOSPAGHETTI
	Date: February 14, 2016
	Checks whether the target is in cast range (the cast range in datadriven is set to its maximum range)]]
function CheckDistance(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	
	if target == nil then
		target = ability.target
	end

	local multicast = caster:FindAbilityByName("ogre_magi_multicast_datadriven")
	local distance = math.sqrt((caster:GetAbsOrigin().x - target:GetAbsOrigin().x)^2 + (caster:GetAbsOrigin().y - target:GetAbsOrigin().y)^2)
	
	local ignite_cast_range
	if multicast:GetLevel() > 0 then
		-- After multicast is leveled, the cast range is the initial ability cast range (based on the ignite level) added to its multicast bonus range (based on the multicast level)
		ignite_cast_range = ability:GetLevelSpecialValueFor("normal_range", ability:GetLevel() -1) + ability:GetLevelSpecialValueFor("multicast_cast_range_bonus", multicast:GetLevel() -1)
	else
		ignite_cast_range = ability:GetLevelSpecialValueFor("normal_range", ability:GetLevel() -1)
	end
	
	-- Ensures last_angle and the caster's angle will not initially be equal
	if ability.last_angle == nil then
		ability.last_angle = caster:GetAnglesAsVector().y - 1
	end
	
	-- Checks if the caster is in cast range and facing the target
	if distance <= ignite_cast_range and caster:GetAnglesAsVector().y == ability.last_angle then
		-- Checks if the caster had to move forward to cast
		if caster:HasModifier("modifier_check_distance") then
			-- Removes the check distance modifier
			caster:RemoveModifierByName("modifier_check_distance")
			-- Issues a hold command
			caster:Hold()
			-- Casts the ability again (to alert multicast), and ends the function, so there will be no duplicate effects
			caster:CastAbilityOnTarget(target, ability, -1)
			return
		end
		-- This only runs if the caster is in range initially or after the second cast
		-- Applies the animation and throws a projectile at the target
		ability:ApplyDataDrivenModifier( caster, caster, "modifier_animation", {} )
		ability:ApplyDataDrivenModifier( caster, target, "modifier_ignite_multicast", {} )
	else
		-- Checks if this is the first run of this function (immediately after cast)
		if caster:HasModifier("modifier_check_distance") == false then
			-- This is necessary because target is not recognized in OnUnitMoved block
			ability.target = target
			-- Stops the cooldown
			ability:EndCooldown()
			-- Refunds the mana
			ability:RefundManaCost()
			-- Applies the check distance modifier
			ability:ApplyDataDrivenModifier( caster, caster, "modifier_check_distance", {} )
		end
		-- Issues a command to move to the target (imitation of Dota mechanics)
		caster:MoveToPosition(target:GetAbsOrigin())
	end
	-- The last angle the caster was facing (to check if they have finished turning and have faced the target)
	ability.last_angle = caster:GetAnglesAsVector().y
end

--[[Author: YOLOSPAGHETTI
	Date: February 14, 2016
	Applies an aoe effect on the target, if multicast is leveled]]
function AOEEffect(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local multicast = caster:FindAbilityByName("ogre_magi_multicast_datadriven")
	local ignite_aoe = ability:GetLevelSpecialValueFor("ignite_aoe", multicast:GetLevel() -1)
	
	if multicast:GetLevel() > 0 then
		local units = FindUnitsInRadius(caster:GetTeam(), target:GetAbsOrigin(), nil, ignite_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, 0, 0, false)
		for i,unit in ipairs(units) do
			ability:ApplyDataDrivenModifier( caster, unit, "modifier_ignite_datadriven", {} )
		end
	else
		ability:ApplyDataDrivenModifier( caster, target, "modifier_ignite_datadriven", {} )
	end
end
