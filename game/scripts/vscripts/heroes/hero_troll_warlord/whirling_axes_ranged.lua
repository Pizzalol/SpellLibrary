--[[Author: Pizzalol
	Date: 14.03.2015.
	Fires several axes in a cone, damaging and slowing enemies]]
function WhirlingAxesRanged( keys )
	local caster = keys.caster
	local caster_location = caster:GetAbsOrigin()
	local target_point = keys.target_points[1]
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability variables
	local axe_width = ability:GetLevelSpecialValueFor("axe_width", ability_level) 
	local axe_speed = ability:GetLevelSpecialValueFor("axe_speed", ability_level) 
	local axe_range = ability:GetLevelSpecialValueFor("axe_range", ability_level) 
	local axe_spread = ability:GetLevelSpecialValueFor("axe_spread", ability_level) 
	local axe_count = ability:GetLevelSpecialValueFor("axe_count", ability_level)
	local axe_projectile = keys.axe_projectile
	caster.whirling_axes_ranged_hit_table = {}

	-- Vision
	local vision_radius = ability:GetLevelSpecialValueFor("vision_radius", ability_level)

	-- Initial angle calculation
	local angle = axe_spread / axe_count -- The angle between the axes
	local direction = (target_point - caster_location):Normalized()
	local axe_angle_count = math.floor(axe_count / 2) -- Number of axes for each direction
	local angle_left = QAngle(0, angle, 0) -- Rotation angle to the left
	local angle_right = QAngle(0, -angle, 0) -- Rotation angle to the right

	-- Check if its an uneven number of axes
	-- If it is then create the middle axe
	if axe_count % 2 ~= 0 then
		local projectileTable =
		{
			EffectName = axe_projectile,
			Ability = ability,
			vSpawnOrigin = caster_location,
			vVelocity = direction * axe_speed,
			fDistance = axe_range,
			fStartRadius = axe_width,
			fEndRadius = axe_width,
			Source = caster,
			bHasFrontalCone = false,
			bReplaceExisting = false,
			iUnitTargetTeam = ability:GetAbilityTargetTeam(),
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
			iUnitTargetType = ability:GetAbilityTargetType(),
			bProvidesVision = true,
			iVisionRadius = vision_radius,
			iVisionTeamNumber = caster:GetTeamNumber()
		}
		ProjectileManager:CreateLinearProjectile(projectileTable)
	end

	local new_angle = QAngle(0,0,0) -- Rotation angle

	-- Create axes that spread to the right
	for i = 1, axe_angle_count do
		-- Angle calculation		
		new_angle.y = angle_right.y * i

		-- Calculate the new position after applying the angle and then get the direction of it			
		local position = RotatePosition(caster_location, new_angle, target_point)	
		local position_direction = (position - caster_location):Normalized()

		-- Create the axe projectile
		local projectileTable =
		{
			EffectName = axe_projectile,
			Ability = ability,
			vSpawnOrigin = caster_location,
			vVelocity = position_direction * axe_speed,
			fDistance = axe_range,
			fStartRadius = axe_width,
			fEndRadius = axe_width,
			Source = caster,
			bHasFrontalCone = false,
			bReplaceExisting = false,
			iUnitTargetTeam = ability:GetAbilityTargetTeam(),
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
			iUnitTargetType = ability:GetAbilityTargetType(),
			bProvidesVision = true,
			iVisionRadius = vision_radius,
			iVisionTeamNumber = caster:GetTeamNumber()
		}
		ProjectileManager:CreateLinearProjectile(projectileTable)
	end

	-- Create axes that spread to the left
	for i = 1, axe_angle_count do
		-- Angle calculation
		new_angle.y = angle_left.y * i

		-- Calculate the new position after applying the angle and then get the direction of it	
		local position = RotatePosition(caster_location, new_angle, target_point)	
		local position_direction = (position - caster_location):Normalized()

		-- Create the axe projectile
		local projectileTable =
		{
			EffectName = axe_projectile,
			Ability = ability,
			vSpawnOrigin = caster_location,
			vVelocity = position_direction * axe_speed,
			fDistance = axe_range,
			fStartRadius = axe_width,
			fEndRadius = axe_width,
			Source = caster,
			bHasFrontalCone = false,
			bReplaceExisting = false,
			iUnitTargetTeam = ability:GetAbilityTargetTeam(),
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
			iUnitTargetType = ability:GetAbilityTargetType(),
			bProvidesVision = true,
			iVisionRadius = vision_radius,
			iVisionTeamNumber = caster:GetTeamNumber()
		}
		ProjectileManager:CreateLinearProjectile(projectileTable)
	end
end

--[[
	Author: Noya
	Used by: Pizzalol
	Date: 14.03.2015.
	Levels up the ability_name to the same level of the ability that runs this
]]
function LevelUpAbility( event )
	local caster = event.caster
	local this_ability = event.ability		
	local this_abilityName = this_ability:GetAbilityName()
	local this_abilityLevel = this_ability:GetLevel()

	-- The ability to level up
	local ability_name = event.ability_name
	local ability_handle = caster:FindAbilityByName(ability_name)	
	local ability_level = ability_handle:GetLevel()

	-- Check to not enter a level up loop
	if ability_level ~= this_abilityLevel then
		ability_handle:SetLevel(this_abilityLevel)
	end
end

--[[Author: Pizzalol
	Date: 18.03.2015.
	Checks if the target has been hit before and then does logic according to that]]
function WhirlingAxesRangedHit( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local sound = keys.sound

	local axe_damage = ability:GetLevelSpecialValueFor("axe_damage", ability_level)

	-- Check if the target has been hit before
	local hit_check = false

	for _,unit in ipairs(caster.whirling_axes_ranged_hit_table) do
		if unit == target then
			hit_check = true
			break
		end
	end

	-- If the target hasnt been hit before then insert it into the hit table to keep track of it
	if not hit_check then
		table.insert(caster.whirling_axes_ranged_hit_table, target)

		-- Play the sound
		EmitSoundOn(sound, target)

		-- Initialize the damage table and deal damage to the target
		local damage_table = {}
		damage_table.attacker = caster
		damage_table.victim = target
		damage_table.ability = ability
		damage_table.damage_type = ability:GetAbilityDamageType() 
		damage_table.damage = axe_damage

		ApplyDamage(damage_table)
	end
end