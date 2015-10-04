--[[
	CHANGELIST:
	10.01.2015 - Delete unnecessary parameter to avoid confusion
]]

--[[
	Author: kritth
	Date: 10.01.2015
	Find necessary vectors, and spawn spawning until units cap is reached
]]
function march_of_the_machines_spawn( keys )
	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	local casterLoc = caster:GetAbsOrigin()
	local targetLoc = keys.target_points[1]
	local duration = ability:GetLevelSpecialValueFor( "duration", ability:GetLevel() - 1 )
	local distance = ability:GetLevelSpecialValueFor( "distance", ability:GetLevel() - 1 )
	local radius = ability:GetLevelSpecialValueFor( "radius", ability:GetLevel() - 1 )
	local collision_radius = ability:GetLevelSpecialValueFor( "collision_radius", ability:GetLevel() - 1 )
	local projectile_speed = ability:GetLevelSpecialValueFor( "speed", ability:GetLevel() - 1 )
	local machines_per_sec = ability:GetLevelSpecialValueFor ( "machines_per_sec", ability:GetLevel() - 1 )
	local dummyModifierName = "modifier_march_of_the_machines_dummy_datadriven"
	
	-- Find forward vector
	local forwardVec = targetLoc - casterLoc
	forwardVec = forwardVec:Normalized()
	
	-- Find backward vector
	local backwardVec = casterLoc - targetLoc
	backwardVec = backwardVec:Normalized()
	
	-- Find middle point of the spawning line
	local middlePoint = casterLoc + ( radius * backwardVec )
	
	-- Find perpendicular vector
	local v = middlePoint - casterLoc
	local dx = -v.y
	local dy = v.x
	local perpendicularVec = Vector( dx, dy, v.z )
	perpendicularVec = perpendicularVec:Normalized()
	
	-- Create dummy to store data in case of multiple instances are called
	local dummy = CreateUnitByName( "npc_dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber() )
	ability:ApplyDataDrivenModifier( caster, dummy, dummyModifierName, {} )
	dummy.march_of_the_machines_num = 0
	
	-- Create timer to spawn projectile
	Timers:CreateTimer( function()
			-- Get random location for projectile
			local random_distance = RandomInt( -radius, radius )
			local spawn_location = middlePoint + perpendicularVec * random_distance
			
			local velocityVec = Vector( forwardVec.x, forwardVec.y, 0 )
			
			-- Spawn projectiles
			local projectileTable = {
				Ability = ability,
				EffectName = "particles/units/heroes/hero_tinker/tinker_machine.vpcf",
				vSpawnOrigin = spawn_location,
				fDistance = distance,
				fStartRadius = collision_radius,
				fEndRadius = collision_radius,
				Source = caster,
				bHasFrontalCone = false,
				bReplaceExisting = false,
				bProvidesVision = false,
				iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
				iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_MECHANICAL,
				vVelocity = velocityVec * projectile_speed
			}
			ProjectileManager:CreateLinearProjectile( projectileTable )
			
			-- Increment the counter
			dummy.march_of_the_machines_num = dummy.march_of_the_machines_num + 1
			
			-- Check if the number of machines have been reached
			if dummy.march_of_the_machines_num == machines_per_sec * duration then
				dummy:Destroy()
				return nil
			else
				return 1 / machines_per_sec
			end
		end
	)
end
