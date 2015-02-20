
function ice_blast_launch( keys )
	local caster = keys.caster	
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	local caster_location = caster:GetAbsOrigin()
	local target_point = keys.target_points[1]
	local direction = (target_point - caster_location):Normalized()

	-- Tracer
	local radius_min = ability:GetLevelSpecialValueFor("radius_min", ability_level)
	local radius_grow = ability:GetLevelSpecialValueFor("radius_grow", ability_level)
	local radius_max = ability:GetLevelSpecialValueFor("radius_max", ability_level)
	local speed = ability:GetLevelSpecialValueFor("speed", ability_level) * 1/30
	local target_sight_radius = ability:GetLevelSpecialValueFor("target_sight_radius", ability_level)

	local tracer_modifier = keys.tracer_modifier
	local tracer_location = caster_location
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

	-- Tracer dummy
	caster.ice_blast_tracer = CreateUnitByName("npc_dummy_blank", caster_location, false, caster, caster, caster:GetTeam())
	ability:ApplyDataDrivenModifier(caster, caster.ice_blast_tracer, tracer_modifier, {})

	caster.ice_blast_tracer_traveling = true
	caster.ice_blast_tracer_start = GameRules:GetGameTime()
	local count = 0

	Timers:CreateTimer(function()
		if caster.ice_blast_tracer_traveling and 
		(tracer_location.x < GetWorldMaxX() and tracer_location.x > GetWorldMinX()) and
		(tracer_location.y < GetWorldMaxY() and tracer_location.y > GetWorldMinY()) then

			-- Calculate the new location
			tracer_location = tracer_location + Vector(speed * direction.x, speed * direction.y, 0)
			-- Set the proper height
			tracer_location = GetGroundPosition(tracer_location, caster.ice_blast_tracer) + Vector(0,0,128)
			caster.ice_blast_tracer:SetAbsOrigin(tracer_location)
			tracer_distance_traveled = tracer_distance_traveled + speed
			count = count + 1
			print("COUNT: " .. count)
			print("TRACER LOCATION: " .. tostring(tracer_location))
			return 1/30
		elseif not caster.ice_blast_tracer_traveling then
			-- End point logic
			if tracer_distance_traveled / speed > min_time then
				projectile_speed = tracer_distance_traveled / min_time
			end

			-- Radius
			-- Increase the radius size by the radius growth for every second traveled
			local radius = (GameRules:GetGameTime() - caster.ice_blast_tracer_start) * radius_grow
			-- Need to make sure its within the ability radius boundaries
			if radius < radius_min then
				radius = radius_min
			elseif radius > radius_max then
				radius = radius_max
			end

			-- Get the new positions of the caster and tracer and prepare for launching the hail projectile
			caster_location = caster:GetAbsOrigin()
			local hail_location = caster_location
			local hail_traveled_distance = 0
			local hail_speed = projectile_speed * 1/30 -- This is the distance per frame
			local distance = (tracer_location - caster_location):Length2D()
			local projectile_direction = (tracer_location - caster_location):Normalized()

			--[[local projectileTable = 
			{
			    Ability        	 	=   ability,
				EffectName			=	projectile_particle,
				vSpawnOrigin		=	caster_location,
				fDistance			=	distance,
				fStartRadius		=	path_radius,
				fEndRadius			=	path_radius,
				Source         	 	=   caster,
				bHasFrontalCone		=	false,
				bRepalceExisting 	=	false,
				iUnitTargetTeams	=	DOTA_UNIT_TARGET_TEAM_ENEMY,
				iUnitTargetTypes	=	DOTA_UNIT_TARGET_HERO,
				iUnitTargetFlags	=	DOTA_UNIT_TARGET_FLAG_NONE,
				bDeleteOnHit    	=   false,
				vVelocity       	=   Vector(projectile_direction.x * projectile_speed, projectile_direction.y * projectile_speed, 0),
				bProvidesVision		=	true,
				iVisionRadius		=	travel_vision,
				iVisionTeamNumber 	=	caster:GetTeamNumber()
			}

			ProjectileManager:CreateLinearProjectile(projectileTable)]]

			ProjectileManager:CreateLinearProjectile( {
				Ability				= ability,
				EffectName			= "particles/units/heroes/hero_ancient_apparition/ancient_apparition_ice_blast_final.vpcf",
				vSpawnOrigin		= caster_location,
				fDistance			= distance,
				fStartRadius		= path_radius,
				fEndRadius			= path_radius,
				Source				= caster,
				bHasFrontalCone		= true,
				bReplaceExisting	= false,
				iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
				iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,
				iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_MECHANICAL,
				fExpireTime			= GameRules:GetGameTime() + 2,
				bDeleteOnHit		= false,
				vVelocity			= Vector(projectile_direction.x * projectile_speed, projectile_direction.y * projectile_speed, 0),
				bProvidesVision		= true,
				iVisionRadius		= travel_vision,
				iVisionTeamNumber	= caster:GetTeamNumber(),
			} )

			Timers:CreateTimer(function()
				if hail_traveled_distance < distance then
					hail_location = hail_location + Vector(projectile_direction.x * hail_speed, projectile_direction.y * hail_speed, 0)
					hail_traveled_distance = hail_traveled_distance + hail_speed

					--ability:CreateVisibilityNode(hail_location, travel_vision, travel_vision_duration)

					return 1/30
				else
					--ability:CreateVisibilityNode(hail_location, area_vision, area_vision_duration)
					return nil
				end
			end)

			return nil
		else
			caster.ice_blast_tracer_traveling = false
			caster.ice_blast_tracer:RemoveSelf()
			return nil
		end
	end)
end

function ice_blast_release( keys )
	local caster = keys.caster

	caster.ice_blast_tracer_traveling = false
end

--[[
	Author: Noya
	Used by: Pizzalol
	Date: 20.02.2015.
	Swaps the abilities
]]
function SwitchAbilities( event )
	local caster = event.caster
	local ability = event.ability

	-- Swap sub_ability
	local sub_ability_name = event.sub_ability_name
	local main_ability_name = ability:GetAbilityName()
	caster:SwapAbilities(main_ability_name, sub_ability_name, false, true)
	--print("Swapped "..main_ability_name.." with " ..sub_ability_name)
end