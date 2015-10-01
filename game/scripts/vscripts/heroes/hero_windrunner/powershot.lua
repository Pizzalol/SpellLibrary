--[[
	Author: kritth, Pizzalol
	Date: 01.10.2015.
	Initialize the data we require for the ability
]]
function powershot_initialize( keys )
	local caster = keys.caster
	local caster_location = caster:GetAbsOrigin()
	local ability = keys.ability	
	local ability_level = ability:GetLevel() - 1
	local point = keys.target_points[1]

	-- Ability variables
	ability.powershot_damage_percent = 0.0
	ability.powershot_traveled = 0
	ability.powershot_direction = (point - caster_location):Normalized()
	ability.powershot_source = caster_location
	ability.powershot_currentPos = caster_location
	ability.powershot_percent_movespeed = 100
	ability.powershot_units_array = {}
	ability.powershot_units_hit = {}

	ability.powershot_interval_damage =  ability:GetLevelSpecialValueFor("damage_per_interval", ability_level)
	ability.powershot_max_range = ability:GetLevelSpecialValueFor( "arrow_range", ability_level )
	ability.powershot_max_movespeed = ability:GetLevelSpecialValueFor( "arrow_speed", ability_level )
	ability.powershot_radius = ability:GetLevelSpecialValueFor( "arrow_width", ability_level )
	ability.powershot_vision_radius = ability:GetLevelSpecialValueFor( "vision_radius", ability_level )	
	ability.powershot_vision_duration = ability:GetLevelSpecialValueFor( "vision_duration", ability_level )
	ability.powershot_damage_reduction = ability:GetLevelSpecialValueFor( "damage_reduction", ability_level )
	ability.powershot_speed_reduction = ability:GetLevelSpecialValueFor( "speed_reduction", ability_level )
	ability.powershot_tree_width = ability:GetLevelSpecialValueFor("tree_width", ability_level) * 2 -- Double the radius because the original feels too small
end

--[[
	Author: kritth
	Date: 01.10.2015.
	Init: Charge the damage per duration
]]
function powershot_charge( keys )
	local ability = keys.ability
	
	-- Fail check
	if not ability.powershot_damage_percent then
		ability.powershot_damage_percent = 0.0
	end
	ability.powershot_damage_percent = ability.powershot_damage_percent + ability.powershot_interval_damage
end

--[[
	Author: kritth
	Date: 5.1.2015.
	Init: Register units to become target
]]
function powershot_register_unit( keys )
	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local index = keys.target:entindex()
	
	-- Register
	ability.powershot_units_array[ index ] = target
	ability.powershot_units_hit[ index ] = false
end

--[[
	Author: kritth, Pizzalol
	Date: 01.10.2015.
	Main: Start traversing upon timer while providing vision, reducing damage and speed per units hit, and also destroy trees
]]
function powershot_start_traverse( keys )
	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	local startAttackSound = "Ability.PowershotPull"
	local startTraverseSound = "Ability.Powershot"
	local projectileName = "particles/units/heroes/hero_windrunner/windrunner_spell_powershot.vpcf"
	
	-- Stop sound event and fire new one, can do this in datadriven but for continuous purpose, let's put it here
	StopSoundEvent( startAttackSound, caster )
	StartSoundEvent( startTraverseSound, caster )
	
	-- Create projectile
	local projectileTable =
	{
		EffectName = projectileName,
		Ability = ability,
		vSpawnOrigin = ability.powershot_source,
		vVelocity = Vector(ability.powershot_direction.x * ability.powershot_max_movespeed, ability.powershot_direction.y * ability.powershot_max_movespeed, 0),
		fDistance = ability.powershot_max_range,
		fStartRadius = ability.powershot_radius,
		fEndRadius = ability.powershot_radius,
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = true,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		iVisionRadius = ability.powershot_vision_radius,
		iVisionTeamNumber = caster:GetTeamNumber()
	}
	caster.powershot_projectileID = ProjectileManager:CreateLinearProjectile( projectileTable )
	
	-- Register units around caster
	local units = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, ability.powershot_radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
	for k, v in pairs( units ) do
		local index = v:entindex()
		caster.powershot_units_array[ index ] = v
		caster.powershot_units_hit[ index ] = false
	end
	
	-- Traverse
	Timers:CreateTimer( function()
			-- Traverse the point
			ability.powershot_currentPos = ability.powershot_currentPos + ( ability.powershot_direction * ability.powershot_percent_movespeed/100 * ability.powershot_max_movespeed * 1/30 )
			ability.powershot_traveled = ability.powershot_traveled + ability.powershot_max_movespeed * 1/30
			
			-- Loop through the units array
			for k, v in pairs( ability.powershot_units_array ) do
				-- Check if it never got hit and is in radius
				if ability.powershot_units_hit[ k ] == false and powershot_distance( v:GetAbsOrigin(), ability.powershot_currentPos ) <= ability.powershot_radius then
					-- Deal damage
					local damageTable =
					{
						victim = v,
						attacker = caster,
						damage = ability:GetAbilityDamage() * ability.powershot_damage_percent,
						damage_type = ability:GetAbilityDamageType()
					}
					ApplyDamage( damageTable )
					-- Reduction
					ability.powershot_damage_percent = ability.powershot_damage_percent * ( 1.0 - ability.powershot_damage_reduction )
					ability.powershot_percent_movespeed = ability.powershot_percent_movespeed * ( 1.0 - ability.powershot_speed_reduction )
					-- Change flag
					ability.powershot_units_hit[ k ] = true
					-- Fire sound
					StartSoundEvent( "Hero_Windrunner.PowershotDamage", v )
				end
			end
			
			-- Check for nearby trees, destroy them if they exist
			if GridNav:IsNearbyTree( ability.powershot_currentPos, ability.powershot_radius, true ) then
				GridNav:DestroyTreesAroundPoint(ability.powershot_currentPos, ability.powershot_tree_width, false)
			end
			
			-- Create visibility node
			AddFOWViewer(caster:GetTeamNumber(), ability.powershot_currentPos, ability.powershot_vision_radius, ability.powershot_vision_duration, false)
			
			-- Check if damage point reach the maximum range, if so, delete the timer
			if ability.powershot_traveled < ability.powershot_max_range then
				return 1/30
			else
				return nil
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