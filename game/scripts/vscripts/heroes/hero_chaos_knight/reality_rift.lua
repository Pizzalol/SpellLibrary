--[[Author: Pizzalol
	Date: 27.09.2015.
	Calculate the rift position and play the particle]]
function RealityRiftPosition( keys )
	local caster = keys.caster
	local target = keys.target
	local caster_location = caster:GetAbsOrigin() 
	local target_location = target:GetAbsOrigin() 
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability variables
	local min_range = ability:GetLevelSpecialValueFor("min_range", ability_level) 
	local max_range = ability:GetLevelSpecialValueFor("max_range", ability_level)
	local reality_rift_particle = keys.reality_rift_particle

	-- Position calculation
	local distance = (target_location - caster_location):Length2D() 
	local direction = (target_location - caster_location):Normalized()
	local target_point = RandomFloat(min_range, max_range) * distance
	local target_point_vector = caster_location + direction * target_point

	-- Particle
	local particle = ParticleManager:CreateParticle(reality_rift_particle, PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster_location, true)
	ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target_location, true)
	ParticleManager:SetParticleControl(particle, 2, target_point_vector)
	ParticleManager:SetParticleControlOrientation(particle, 2, direction, Vector(0,1,0), Vector(1,0,0))
	ParticleManager:ReleaseParticleIndex(particle) 

	-- Save the location
	ability.reality_rift_location = target_point_vector
	ability.reality_rift_direction = direction
end

--[[Author: Pizzalol
	Date: 09.04.2015.
	Relocates the target, caster and any illusions under the casters control]]
function RealityRift( keys )
	local caster = keys.caster
	local target = keys.target
	local caster_location = caster:GetAbsOrigin()
	local player = caster:GetPlayerOwnerID()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability variables
	local bonus_duration = ability:GetLevelSpecialValueFor("bonus_duration", ability_level) 
	local illusion_search_radius = ability:GetLevelSpecialValueFor("illusion_search_radius", ability_level) 
	local bonus_modifier = keys.bonus_modifier
	
	-- Set the positions to be one on each side of the rift
	target:SetAbsOrigin(ability.reality_rift_location - ability.reality_rift_direction * 25)
	caster:SetAbsOrigin(ability.reality_rift_location + ability.reality_rift_direction * 25)

	-- Set the targets to face eachother
	target:SetForwardVector(ability.reality_rift_direction)
	caster:Stop() 
	caster:SetForwardVector(ability.reality_rift_direction * -1)

	-- Add the phased modifier to prevent getting stuck
	target:AddNewModifier(caster, nil, "modifier_phased", {duration = 0.03})
	caster:AddNewModifier(caster, nil, "modifier_phased", {duration = 0.03})

	-- Execute the attack order for the caster
	local order =
	{
		UnitIndex = caster:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		TargetIndex = target:entindex(),
		Queue = true
	}

	ExecuteOrderFromTable(order)

	-- Find the caster illusions if they exist
	local target_teams = DOTA_UNIT_TARGET_TEAM_FRIENDLY
	local target_types = DOTA_UNIT_TARGET_HERO
	local target_flags = DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED

	local units = FindUnitsInRadius(caster:GetTeamNumber(), caster_location, nil, illusion_search_radius, target_teams, target_types, target_flags, FIND_CLOSEST, false)

	for _,unit in ipairs(units) do
		if unit:IsIllusion() and unit:GetPlayerOwnerID() == player then
			-- Do the same thing that we did for the caster
			-- Relocate and set the illusion to face the target
			unit:SetAbsOrigin(ability.reality_rift_location + ability.reality_rift_direction * 25) 
			unit:Stop() 
			unit:SetForwardVector(ability.reality_rift_direction * -1)

			-- Add the phased and reality rift modifiers
			unit:AddNewModifier(caster, nil, "modifier_phased", {duration = 0.03})
			ability:ApplyDataDrivenModifier(caster, unit, bonus_modifier, {duration = bonus_duration})

			-- Execute the attack order
			local order =
			{
				UnitIndex = unit:entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
				TargetIndex = target:entindex(),
				Queue = true
			}

			ExecuteOrderFromTable(order)
		end
	end	
end