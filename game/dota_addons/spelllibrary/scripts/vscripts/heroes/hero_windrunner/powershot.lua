--[[
	Author: kritth
	Date: 5.1.2015.
	Init: Initialize the damaage
]]
function powershot_initialize( keys )
	keys.caster.powershot_damage_percent = 0.0
end

--[[
	Author: kritth
	Date: 5.1.2015.
	Init: Charge the damage per duration
]]
function powershot_charge( keys )
	local caster = keys.caster
	-- Fail check
	if not caster.powershot_damage_percent then
		caster.powershot_damage_percent = 0.0
	end
	caster.powershot_damage_percent = caster.powershot_damage_percent + keys.ability:GetLevelSpecialValueFor( "damage_per_interval", ( keys.ability:GetLevel() - 1 ) )
end

--[[
	Author: kritth
	Date: 5.1.2015.
	Init: Register units to become target
]]
function powershot_register_unit( keys )
	local caster = keys.caster
	local target = keys.target
	local index = keys.target:entindex()
	-- Register
	caster.powershot_units_array[ index ] = keys.target
	caster.powershot_units_hit[ index ] = false
end

--[[
	Author: kritth
	Date: 5.1.2015.
	Main: Start traversing upon timer while providing vision, reducing damage and speed per units hit, and also destroy trees
	Changes:
	09.01.2015 - Minor cleanup
]]
function powershot_start_traverse( keys )
	-- Init local variables
	local dummyModifierName = "modifier_powershot_dummy_datadriven"
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[ 1 ]
	local forwardVec = point - caster:GetAbsOrigin()
	local max_range = ability:GetLevelSpecialValueFor( "arrow_range", ( ability:GetLevel() - 1 ) )
	local max_movespeed = ability:GetLevelSpecialValueFor( "arrow_speed", ( ability:GetLevel() - 1 ) )
	local radius = ability:GetLevelSpecialValueFor( "arrow_width", ( ability:GetLevel() - 1 ) )
	local vision_radius = ability:GetLevelSpecialValueFor( "vision_radius", ( ability:GetLevel() - 1 ) )
	
	-- Variables to use in timer
	caster.powershot_movespeed = max_movespeed							-- Store the maximum movespeed
	caster.powershot_percent_movespeed = 100							-- Store current movement speed
	caster.powershot_source = caster:GetAbsOrigin()						-- Store the source position of the damage
	caster.powershot_currentPos = caster:GetAbsOrigin()					-- Store current position the damage is at
	caster.powershot_max_range = max_range								-- Maximum range it can hit
	caster.powershot_radius = radius
	caster.powershot_forwardVec = forwardVec:Normalized()				-- Forward vector
	caster.powershot_units_array = {}									-- Table to store units, key is entindex, value is entity
	caster.powershot_units_hit = {}										-- Flag to check if unit is hit, key is entindex, value is true or false
	caster.powershot_vision_radius = vision_radius
	caster.powershot_vision_duration = ability:GetLevelSpecialValueFor( "vision_duration", ( ability:GetLevel() - 1 ) )
	caster.powershot_damage_reduction = ability:GetLevelSpecialValueFor( "damage_reduction", ( ability:GetLevel() - 1 ) )
	caster.powershot_speed_reduction = ability:GetLevelSpecialValueFor( "speed_reduction", ( ability:GetLevel() - 1 ) )
	
	-- Stop sound event and fire new one, can do this in datadriven but for continuous purpose, let's put it here
	StopSoundEvent( "Ability.PowershotPull", caster )
	StartSoundEvent( "Ability.Powershot", caster )
	
	-- Create projectile
	local projectileTable =
	{
		EffectName = "particles/units/heroes/hero_windrunner/windrunner_spell_powershot.vpcf",
		Ability = ability,
		vSpawnOrigin = caster:GetAbsOrigin(),
		vVelocity = Vector( caster.powershot_forwardVec.x * max_movespeed,
			caster.powershot_forwardVec.y * max_movespeed, 0 ),
		fDistance = 99999,
		fStartRadius = radius,
		fEndRadius = radius,
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = true,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		iVisionRadius = vision_radius,
		iVisionTeamNumber = caster:GetTeamNumber()
	}
	caster.powershot_projectileID = ProjectileManager:CreateLinearProjectile( projectileTable )
	
	-- Register units around caster
	local units = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
	for k, v in pairs( units ) do
		local index = v:entindex()
		caster.powershot_units_array[ index ] = v
		caster.powershot_units_hit[ index ] = false
	end
	
	-- Traverse
	Timers:CreateTimer( function()
			-- Traverse the point
			caster.powershot_currentPos = caster.powershot_currentPos + ( caster.powershot_forwardVec * caster.powershot_percent_movespeed )
			
			-- Loop through the units array
			for k, v in pairs( caster.powershot_units_array ) do
				-- Check if it never got hit and is in radius
				if caster.powershot_units_hit[ k ] == false
						and powershot_distance( v:GetAbsOrigin(), caster.powershot_currentPos ) <= caster.powershot_radius then
					-- Deal damage
					local damageTable =
					{
						victim = v,
						attacker = caster,
						damage = ability:GetAbilityDamage() * caster.powershot_damage_percent,
						damage_type = ability:GetAbilityDamageType()
					}
					ApplyDamage( damageTable )
					-- Reduction
					caster.powershot_damage_percent = caster.powershot_damage_percent * ( 1.0 - caster.powershot_damage_reduction )
					caster.powershot_percent_movespeed = caster.powershot_percent_movespeed * ( 1.0 - caster.powershot_speed_reduction )
					-- Change flag
					caster.powershot_units_hit[ k ] = true
					-- Fire sound
					StartSoundEvent( "Hero_Windrunner.PowershotDamage", v )
				end
			end
			
			-- Check if nearby tree, then create dummy to destroy them
			if GridNav:IsNearbyTree( caster.powershot_currentPos, caster.powershot_radius, true ) then
				local dummy = CreateUnitByName( "npc_dummy_blank", caster.powershot_currentPos, false, caster, caster, caster:GetTeamNumber() )
				ability:ApplyDataDrivenModifier( caster, dummy, dummyModifierName, {} )
				Timers:CreateTimer( 0.1, function()
					dummy:ForceKill( true )
					return nil
				end )
			end
			
			-- Create visibility node
			ability:CreateVisibilityNode( caster.powershot_currentPos, caster.powershot_vision_radius, caster.powershot_vision_duration )
			
			-- Check if damage point reach the maximum range, if so, delete the projectile and the timer
			local dx = caster.powershot_source.x - caster.powershot_currentPos.x
			local dy = caster.powershot_source.y - caster.powershot_currentPos.y
			if math.sqrt( dx * dx + dy * dy ) > caster.powershot_max_range then
				ProjectileManager:DestroyLinearProjectile( caster.powershot_projectileID )
				return nil
			else
				return 1.0 / caster.powershot_movespeed
			end	
		end
	)
end

--[[
	Author: kritth
	Date: 5.1.2015.
	Helper: Calculate distance between two points
]]
function powershot_distance( pointA, pointB )
	local dx = pointA.x - pointB.x
	local dy = pointA.y - pointB.y
	return math.sqrt( dx * dx + dy * dy )
end
