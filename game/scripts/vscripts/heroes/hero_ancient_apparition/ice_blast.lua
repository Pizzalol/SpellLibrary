-- Change these to whatever you want
ice_blast_target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
ice_blast_target_type = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
ice_blast_target_flag = DOTA_UNIT_TARGET_FLAG_NONE

--[[Author: Pizzalol
	Date: 13.10.2015.
	Launches a dummy unit which acts as a tracer projectile
	The tracer travels until it is stopped or reaches the map boundaries
	After stopping the tracer a hail projectile is launched which provides vision along the path, applies
	the frostbite debuff and deals damage in the final impact area (which is the point where the tracer stopped)]]
function ice_blast_launch( keys )
	local caster = keys.caster	
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	local main_ability_name = keys.main_ability_name
	local sub_ability_name = keys.sub_ability_name

	local caster_location = caster:GetAbsOrigin()
	local target_point = keys.target_points[1]
	local direction = (target_point - caster_location):Normalized()
	caster.ice_blast_ability = ability

	-- Tracer
	local radius_min = ability:GetLevelSpecialValueFor("radius_min", ability_level)
	local radius_grow = ability:GetLevelSpecialValueFor("radius_grow", ability_level)
	local radius_max = ability:GetLevelSpecialValueFor("radius_max", ability_level)
	local speed = ability:GetLevelSpecialValueFor("speed", ability_level) * 1/30
	local target_sight_radius = ability:GetLevelSpecialValueFor("target_sight_radius", ability_level)

	local tracer_modifier = keys.tracer_modifier
	local tracer_distance_traveled = 0

	-- Projectile
	local path_radius = ability:GetLevelSpecialValueFor("path_radius", ability_level)
	local min_time = ability:GetLevelSpecialValueFor("min_time", ability_level)
	local projectile_speed = ability:GetLevelSpecialValueFor("base_speed", ability_level) -- Changeable speed
	local travel_vision = ability:GetLevelSpecialValueFor("travel_vision", ability_level)
	local travel_vision_duration = ability:GetLevelSpecialValueFor("travel_vision_duration", ability_level)
	local area_vision = ability:GetLevelSpecialValueFor("area_vision", ability_level)
	local area_vision_duration = ability:GetLevelSpecialValueFor("area_vision_duration", ability_level)
	
	local projectile_particle = keys.projectile_particle

	-- Ability swap
	SwitchAbilities(caster, main_ability_name, sub_ability_name)

	-- Tracer dummy
	ability.ice_blast_tracer = CreateUnitByName("npc_dummy_unit", caster_location, false, caster, caster, caster:GetTeam())
	ability:ApplyDataDrivenModifier(caster, ability.ice_blast_tracer, tracer_modifier, {})

	-- Setting up the tracer variables
	ability.ice_blast_tracer_traveling = true
	ability.ice_blast_tracer_start = GameRules:GetGameTime()
	ability.ice_blast_tracer_location = caster_location

	-- Timer to move the tracer
	-- First it checks if its traveling and within the map boundaries
	-- If its not traveling then it launches the hail projectile
	-- If its not within the map boundaries then it kills the dummy and reverts the abilities
	Timers:CreateTimer(function()
		if ability.ice_blast_tracer_traveling and 
		(ability.ice_blast_tracer_location.x < GetWorldMaxX() and ability.ice_blast_tracer_location.x > GetWorldMinX()) and
		(ability.ice_blast_tracer_location.y < GetWorldMaxY() and ability.ice_blast_tracer_location.y > GetWorldMinY()) then

			-- Calculate the new location
			ability.ice_blast_tracer_location = ability.ice_blast_tracer_location + Vector(speed * direction.x, speed * direction.y, 0)
			-- Set the proper height
			ability.ice_blast_tracer_location = GetGroundPosition(ability.ice_blast_tracer_location, ability.ice_blast_tracer) + Vector(0,0,128)
			ability.ice_blast_tracer:SetAbsOrigin(ability.ice_blast_tracer_location)
			tracer_distance_traveled = tracer_distance_traveled + speed

			return 1/30

		-- If the tracer is within the map boundaries but not traveling	
		elseif not ability.ice_blast_tracer_traveling then
			-- Swap out the abilities
			SwitchAbilities(caster, sub_ability_name, main_ability_name )

			-- Calculate the projectile speed according to the minimum time
			if tracer_distance_traveled / projectile_speed > min_time then
				projectile_speed = tracer_distance_traveled / min_time
			end

			-- Radius
			-- Increase the radius size by the radius growth for every second traveled
			ability.ice_blast_radius = radius_min + (GameRules:GetGameTime() - ability.ice_blast_tracer_start) * radius_grow
			-- Need to make sure its within the ability radius boundaries
			if ability.ice_blast_radius > radius_max then
				ability.ice_blast_radius = radius_max
			end

			-- Get the new positions of the caster and tracer and prepare for launching the hail projectile
			caster_location = caster:GetAbsOrigin()
			local hail_location = caster_location
			local hail_traveled_distance = 0
			local hail_speed = projectile_speed * 1/30 -- This is the distance per frame
			local distance = (ability.ice_blast_tracer_location - caster_location):Length2D()
			local projectile_direction = (ability.ice_blast_tracer_location - caster_location):Normalized()

			-- Launch the projectile
			ProjectileManager:CreateLinearProjectile( {
				Ability				= ability,
				EffectName			= projectile_particle,
				vSpawnOrigin		= caster_location,
				fDistance			= distance,
				fStartRadius		= path_radius,
				fEndRadius			= path_radius,
				Source				= caster,
				bHasFrontalCone		= true,
				bReplaceExisting	= false,
				iUnitTargetTeam		= ice_blast_target_team,
				iUnitTargetFlags	= ice_blast_target_flag,
				iUnitTargetType		= ice_blast_target_type,
				--fExpireTime			= GameRules:GetGameTime() + 2,
				bDeleteOnHit		= false,
				vVelocity			= Vector(projectile_direction.x * projectile_speed, projectile_direction.y * projectile_speed, 0),
				bProvidesVision		= true,
				iVisionRadius		= travel_vision,
				iVisionTeamNumber	= caster:GetTeamNumber(),
			} )

			-- Timer to calculate the movement of the hail projectile so that we create the vision along the path
			Timers:CreateTimer(function()
				if hail_traveled_distance < distance then
					hail_location = hail_location + Vector(projectile_direction.x * hail_speed, projectile_direction.y * hail_speed, 0)
					hail_traveled_distance = hail_traveled_distance + hail_speed

					AddFOWViewer(caster:GetTeamNumber(), hail_location, travel_vision, travel_vision_duration, false)
					return 1/30
				else
					-- End path area vision
					ability.ice_blast_tracer:RemoveSelf()
					AddFOWViewer(caster:GetTeamNumber(), hail_location, area_vision, area_vision_duration, false)
					return nil
				end
			end)

			return nil
		-- This triggers when the projectile reached the map boundaries
		else
			-- Swap out the abilities
			SwitchAbilities(caster, sub_ability_name, main_ability_name )
			ability.ice_blast_tracer_traveling = false
			ability.ice_blast_tracer:RemoveSelf()
			return nil
		end
	end)
end

-- Stops the tracer from traveling
function ice_blast_release( keys )
	local caster = keys.caster

	caster.ice_blast_ability.ice_blast_tracer_traveling = false
end


--[[ Author: Pizzalol
	Date: 13.10.2015.
	Triggers when the hail projectile reaches the end point
	Applies the frostbite debuff and deals damage in an area
	Radius is calculated according to the distance that the tracer traveled]]
function ice_blast_explode( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	local duration = ability:GetLevelSpecialValueFor("frostbite_duration", ability_level)
	local modifier = keys.modifier
	local sound = keys.sound
	local explosion_particle = keys.explosion_particle

	local damage_table = {}
	damage_table.attacker = caster
	damage_table.damage_type = ability:GetAbilityDamageType()
	damage_table.ability = ability
	damage_table.damage = ability:GetAbilityDamage()

	-- Plays the explosion sound and explosion particle
	EmitSoundOn(sound, ability.ice_blast_tracer)
	local particle = ParticleManager:CreateParticle(explosion_particle, PATTACH_ABSORIGIN_FOLLOW, ability.ice_blast_tracer)
	ParticleManager:SetParticleControl(particle, 0, ability.ice_blast_tracer_location)
	ParticleManager:SetParticleControl(particle, 3, ability.ice_blast_tracer_location)
	ParticleManager:ReleaseParticleIndex(particle)

	local units_to_damage = FindUnitsInRadius(caster:GetTeam(), ability.ice_blast_tracer_location, nil, ability.ice_blast_radius, ice_blast_target_team, ice_blast_target_type, ice_blast_target_flag, FIND_CLOSEST, false)

	for _,v in pairs(units_to_damage) do
		-- Apply the frostbite modifier only to heroes
		if v:IsConsideredHero() then
			ability:ApplyDataDrivenModifier(caster, v, modifier, {duration = duration})
		end

		damage_table.victim = v
		ApplyDamage(damage_table)
	end
end

--[[Author: Pizzalol
	Date: 21.02.2015.
	Triggers whenever the unit takes damage
	Checks the HP of the unit and if its below the threshold then it kills the target
	and grants the kill credit to the attacker]]
function ice_blast_frostbite( keys )
	local caster = keys.caster
	local attacker = keys.attacker
	local unit = keys.unit

	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	local kill_pct = ability:GetLevelSpecialValueFor("kill_pct", ability_level)
	local unit_hp = unit:GetHealth()
	local unit_hp_pct = (unit_hp / unit:GetMaxHealth()) * 100

	-- Threshold check
	if unit_hp_pct <= kill_pct then
		local damage_table = {}

		damage_table.victim = unit
		damage_table.damage_type = DAMAGE_TYPE_PURE
		damage_table.ability = ability
		damage_table.damage = unit_hp + 1

		-- If the unit damaged itself then the kill is awarded to the caster instead
		-- of being counted as a suicide
		if attacker == unit then
			damage_table.attacker = caster
		else
			damage_table.attacker = attacker
		end

		ApplyDamage(damage_table)
	end
end

--[[
	Author: Noya, Pizzalol
	Date: 20.02.2015.
	Swaps the abilities
]]
function SwitchAbilities( caster, main_ability_name, sub_ability_name )
	-- Swap sub_ability
	caster:SwapAbilities(main_ability_name, sub_ability_name, false, true)
	--print("Swapped "..main_ability_name.." with " ..sub_ability_name)
end