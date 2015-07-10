--[[
	Author: Noya
	Date: April 4, 2015.
	Finds targets to fire the ether shock effect and damage.
]]
function Shock( event )
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local level = ability:GetLevel() - 1
	local start_radius = ability:GetLevelSpecialValueFor("start_radius", level )
	local end_radius = ability:GetLevelSpecialValueFor("end_radius", level )
	local end_distance = ability:GetLevelSpecialValueFor("end_distance", level )
	local targets = ability:GetLevelSpecialValueFor("targets", level )
	local damage = ability:GetLevelSpecialValueFor("damage", level )
	local AbilityDamageType = ability:GetAbilityDamageType()
	local particleName = "particles/units/heroes/hero_shadowshaman/shadowshaman_ether_shock.vpcf"

	-- Make sure the main target is damaged
	local lightningBolt = ParticleManager:CreateParticle(particleName, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(lightningBolt,0,Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z ))	
	ParticleManager:SetParticleControl(lightningBolt,1,Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z + target:GetBoundingMaxs().z ))
	ApplyDamage({ victim = target, attacker = caster, damage = damage, damage_type = AbilityDamageType})
	target:EmitSound("Hero_ShadowShaman.EtherShock.Target")

	local cone_units = GetEnemiesInCone( caster, start_radius, end_radius, end_distance )
	local targets_shocked = 1 --Is targets=extra targets or total?
	for _,unit in pairs(cone_units) do
		if targets_shocked < targets then
			if unit ~= target then
				-- Particle
				local origin = unit:GetAbsOrigin()
				local lightningBolt = ParticleManager:CreateParticle(particleName, PATTACH_WORLDORIGIN, caster)
				ParticleManager:SetParticleControl(lightningBolt,0,Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z ))	
				ParticleManager:SetParticleControl(lightningBolt,1,Vector(origin.x,origin.y,origin.z + unit:GetBoundingMaxs().z ))
			
				-- Damage
				ApplyDamage({ victim = unit, attacker = caster, damage = damage, damage_type = AbilityDamageType})

				-- Increment counter
				targets_shocked = targets_shocked + 1
			end
		else
			break
		end
	end
end

--[[
	Author: Noya
	Date: April 4, 2015.
	Returns a table of enemy units in a frontal cone of the unit
	The cone starts with start_radius and reaches its end_radius after start_radius + end_distance
]]
function GetEnemiesInCone( unit, start_radius, end_radius, end_distance)
	local DEBUG = false
	
	-- Positions
	local fv = unit:GetForwardVector()
	local origin = unit:GetAbsOrigin()

	local start_point = origin + fv * start_radius -- Position to find units with start_radius
	local end_point = origin + fv * (start_radius + end_distance) -- Position to find units with end_radius

	if DEBUG then
		DebugDrawCircle(start_point, Vector(255,0,0), 100, start_radius, true, 3)
		DebugDrawCircle(end_point, Vector(255,0,0), 100, end_radius, true, 3)
	end

	-- 1 medium circle should be enough as long as the mid_interval isn't too large
	local mid_interval = end_distance - start_radius - end_radius
	local mid_radius = (start_radius + end_radius) / 2
	local mid_point = origin + fv * mid_radius * 2
	
	if DEBUG then
		--print("There's a space of "..mid_interval.." between the circles at the cone edges")
		DebugDrawCircle(mid_point, Vector(0,255,0), 100, mid_radius, true, 3)
	end

	-- Find the units
	local team = unit:GetTeamNumber()
	local iTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
	local iType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	local iFlag = DOTA_UNIT_TARGET_FLAG_NONE
	local iOrder = FIND_ANY_ORDER

	local start_units = FindUnitsInRadius(team, start_point, nil, start_radius, iTeam, iType, iFlag, iOrder, false)
	local end_units = FindUnitsInRadius(team, end_point, nil, end_radius, iTeam, iType, iFlag, iOrder, false)
	local mid_units = FindUnitsInRadius(team, mid_point, nil, mid_radius, iTeam, iType, iFlag, iOrder, false)

	-- Join the tables
	local cone_units = {}
	for k,v in pairs(end_units) do
		table.insert(cone_units, v)
	end

	for k,v in pairs(start_units) do
		if not tableContains(cone_units, k) then
			table.insert(cone_units, v)
		end
	end	

	for k,v in pairs(mid_units) do
		if not tableContains(cone_units, k) then
			table.insert(cone_units, v)
		end
	end

	DeepPrintTable(cone_units)
	return cone_units

end

-- Returns true if the element can be found on the list, false otherwise
function tableContains(list, element)
    if list == nil then return false end
    for i=1,#list do
        if list[i] == element then
            return true
        end
    end
    return false
end