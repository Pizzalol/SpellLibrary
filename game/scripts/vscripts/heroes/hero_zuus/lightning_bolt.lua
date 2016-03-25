--[[Author: YOLOSPAGHETTI
	Date: March 24, 2016
	Applies the damage to the necessary unit (if there is one) and gives the caster's team vision in the aoe]]
function SearchArea(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local radius = ability:GetLevelSpecialValueFor("spread_aoe", (ability:GetLevel() -1))
	local sight_radius = ability:GetLevelSpecialValueFor("sight_radius", (ability:GetLevel() -1))
	local sight_duration = ability:GetLevelSpecialValueFor("sight_duration", (ability:GetLevel() -1))
	
	-- Checks if the ability was ground targeted (target will be the targeted entity otherwise)
	if target == nil then
		-- Finds all heroes in the radius (the closest hero takes priority over the closest creep)
		local units = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius, ability:GetAbilityTargetTeam(), DOTA_UNIT_TARGET_HERO, 0, 0, false)
		local closest = radius
		for i,unit in ipairs(units) do
			-- Positioning and distance variables
			local unit_location = unit:GetAbsOrigin()
			local vector_distance = point - unit_location
			local distance = (vector_distance):Length2D()
			-- If the hero is closer than the closest checked so far, then we set its distance as the new closest distance and it as the new target
			if distance < closest then
				closest = distance
				target = unit
			end
		end
	end
	
	-- Checks if the target was set in the last block (checking for heroes in the aoe)
	if target == nil then
		local units = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), 0, 0, false)
		local closest = radius
		for i,unit in ipairs(units) do
			-- Positioning and distance variables
			local unit_location = unit:GetAbsOrigin()
			local vector_distance = point - unit_location
			local distance = (vector_distance):Length2D()
			-- If the hero is closer than the closest checked so far, then we set its distance as the new closest distance and it as the new target
			if distance < closest then
				closest = distance
				target = unit
			end
		end
	end
	
	-- Gives vision to the caster's team in the radius
	AddFOWViewer(caster:GetTeam(), point, sight_radius, sight_duration, false)
	
	-- Checks if the target has been set yet
	if target ~= nil then
		-- Applies the ministun and the damage to the target
		target:AddNewModifier(caster, ability, "modifier_stun", {Duration = 0.1})
		ApplyDamage({victim = target, attacker = caster, damage = ability:GetAbilityDamage(), damage_type = ability:GetAbilityDamageType()})
		-- Renders the particle on the target
		local particle = ParticleManager:CreateParticle(keys.particle, PATTACH_WORLDORIGIN, target)
		-- Raise 1000 value if you increase the camera height above 1000
		ParticleManager:SetParticleControl(particle, 0, Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z + target:GetBoundingMaxs().z ))
		ParticleManager:SetParticleControl(particle, 1, Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,1000 ))
		ParticleManager:SetParticleControl(particle, 2, Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z + target:GetBoundingMaxs().z ))
	else
		-- Renders the particle on the ground target
		local particle = ParticleManager:CreateParticle(keys.particle, PATTACH_WORLDORIGIN, caster)
		-- Raise 1000 value if you increase the camera height above 1000
		ParticleManager:SetParticleControl(particle, 0, Vector(point.x,point.y,point.z))
		ParticleManager:SetParticleControl(particle, 1, Vector(point.x,point.y,1000))
		ParticleManager:SetParticleControl(particle, 2, Vector(point.x,point.y,point.z))
	end
end
