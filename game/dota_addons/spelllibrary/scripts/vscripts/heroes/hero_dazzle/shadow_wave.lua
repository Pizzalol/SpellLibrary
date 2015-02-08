

function ShadowWave( keys )
	local caster = keys.caster
	local caster_location = caster:GetAbsOrigin()
	local target = keys.target
	local target_location = target:GetAbsOrigin()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	local bounce_radius = ability:GetLevelSpecialValueFor("bounce_radius", ability_level)
	local damage_radius = ability:GetLevelSpecialValueFor("damage_radius", ability_level)
	local max_targets = ability:GetLevelSpecialValueFor("max_targets", ability_level)
	local damage = ability:GetLevelSpecialValueFor("damage", ability_level)
	local heal = damage
	local targets_healed = 0

	local shadow_wave_particle = keys.shadow_wave_particle
	local damage_particle = keys.damage_particle

	local hit_table = {}
	local damage_table = {}
	damage_table.attacker = caster
	damage_table.damage_type = ability:GetAbilityDamageType()
	damage_table.ability = ability
	damage_table.damage = damage

	-- If the target is not the caster then do the extra bounce for the caster
	if target ~= caster then
		-- Heal the caster and do damage to the units around it
		caster:Heal(heal, caster)

		local units_to_damage = FindUnitsInRadius(caster:GetTeam(), caster_location, nil, damage_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, ability:GetAbilityTargetType(), 0, 0, false)

		for _,v in pairs(units_to_damage) do
			damage_table.victim = v
			ApplyDamage(damage_table)
		end
	end

	-- Heal the initial target and do the damage to the units around it
	target:Heal(heal, caster)
	local units_to_damage = FindUnitsInRadius(caster:GetTeam(), target_location, nil, damage_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, ability:GetAbilityTargetType(), 0, 0, false)

	for _,v in pairs(units_to_damage) do
		damage_table.victim = v
		ApplyDamage(damage_table)
	end

	-- Keep track of how many bounces we made so far
	targets_healed = targets_healed + 1
	
	-- Hurt heroes
	-- Find the hurt heroes and heal them first
	for i = targets_healed, max_targets do
		local heroes = FindUnitsInRadius(caster:GetTeam(), target_location, nil, bounce_radius, ability:GetAbilityTargetTeam(), DOTA_UNIT_TARGET_HERO, 0, FIND_CLOSEST, false)
		for _,unit in pairs(heroes) do
			local check_unit = 0	-- Helper variable to determine if a unit has been hit or not

			-- Checking the hit table to see if the unit is hit
			for c = 0, #hit_table do
				if hit_table[c] == unit then
					check_unit = 1
				end
			end

			-- If its not hit then check if the unit is hurt
			if check_unit == 0 then
				if unit:GetHealth() ~= unit:GetMaxHealth() then
					-- After we find the hurt hero unit then we insert it into the hit table to keep track of it
					-- and we also get the unit position
					table.insert(hit_table, unit)
					local unit_location = unit:GetAbsOrigin()

					-- Create the particle for the visual effect
					local particle = ParticleManager:CreateParticle(shadow_wave_particle, PATTACH_CUSTOMORIGIN, caster)
					ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target_location, true)
					ParticleManager:SetParticleControlEnt(particle, 1, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit_location, true)

					-- Set the unit as the new target
					target = unit
					target_location = unit_location

					-- Heal it and deal damage to enemy units around it
					target:Heal(heal, caster)
					local units_to_damage = FindUnitsInRadius(caster:GetTeam(), target_location, nil, damage_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, ability:GetAbilityTargetType(), 0, 0, false)

					for _,v in pairs(units_to_damage) do
						damage_table.victim = v
						ApplyDamage(damage_table)
					end

					-- Increase the bounce count
					targets_healed = targets_healed + 1

					-- Exit the loop for finding hurt heroes
					break
				end
			end
		end
	end

	-- Hurt units
	-- Find the hurts unit as second priority and then heal them
	for i = targets_healed, max_targets do
		local units = FindUnitsInRadius(caster:GetTeam(), target_location, nil, bounce_radius, ability:GetAbilityTargetTeam(), DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_MECHANICAL, 0, FIND_CLOSEST, false)
		for _,unit in pairs(units) do
			local check_unit = 0	-- Helper variable to determine if the unit has been hit or not

			-- Checking the hit table to see if the unit is hit
			for c = 0, #hit_table do
				if hit_table[c] == unit then
					check_unit = 1
				end
			end

			-- If its not hit then check if the unit is hurt
			if check_unit == 0 then
				if unit:GetHealth() ~= unit:GetMaxHealth() then
					-- After we find the hurt hero unit then we insert it into the hit table to keep track of it
					-- and we also get the unit position
					table.insert(hit_table, unit)
					local unit_location = unit:GetAbsOrigin()

					-- Create the particle for the visual effect
					local particle = ParticleManager:CreateParticle(shadow_wave_particle, PATTACH_CUSTOMORIGIN, caster)
					ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target_location, true)
					ParticleManager:SetParticleControlEnt(particle, 1, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit_location, true)

					-- Set the unit as the new target
					target = unit
					target_location = unit_location

					-- Heal it and deal damage to enemy units around it
					target:Heal(heal, caster)
					local units_to_damage = FindUnitsInRadius(caster:GetTeam(), target_location, nil, damage_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, ability:GetAbilityTargetType(), 0, 0, false)

					-- Increase the bounce count
					for _,v in pairs(units_to_damage) do
						damage_table.victim = v
						ApplyDamage(damage_table)
					end

					-- Exit the loop for finding hurt heroes
					targets_healed = targets_healed + 1
					break
				end
			end
		end
	end
end