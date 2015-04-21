
function deafening_blast_start( keys )
	local caster = keys.caster
	local caster_location = caster:GetAbsOrigin()
	local target_point = keys.target_points[1]
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability and projectile variables
	local travel_distance = ability:GetLevelSpecialValueFor("travel_distance", ability_level) 
	local travel_speed = ability:GetLevelSpecialValueFor("travel_speed", ability_level) 
	local radius_start = ability:GetLevelSpecialValueFor("radius_start", ability_level) 
	local radius_end = ability:GetLevelSpecialValueFor("radius_end", ability_level) 
	local dummy_ability_name = keys.dummy_ability_name
	local projectile_name = keys.projectile_name
	local direction = (target_point - caster_location):Normalized()

	-- Create the dummy
	local deafening_dummy = CreateUnitByName("npc_dummy_blank", caster_location, false, caster, caster, caster:GetTeamNumber())
	deafening_dummy:AddAbility(dummy_ability_name)

	local dummy_ability = deafening_dummy:FindAbilityByName(dummy_ability_name)
	dummy_ability:SetLevel(1)

	local distance_traveled = 0
	local dummy_speed = travel_speed * 1/30


	-- Create projectile
	local projectile_table =
	{
		EffectName = projectile_name,
		Ability = dummy_ability,
		vSpawnOrigin = caster_location,
		vVelocity = direction * travel_speed,
		fDistance = travel_distance,
		fStartRadius = radius_start,
		fEndRadius = radius_end,
		Source = deafening_dummy,
		bHasFrontalCone = true,
		bReplaceExisting = false,
		iUnitTargetTeam = ability:GetAbilityTargetTeam(),
		iUnitTargetFlags = ability:GetAbilityTargetFlags(),
		iUnitTargetType = ability:GetAbilityTargetType()
	}
	ProjectileManager:CreateLinearProjectile( projectile_table )

	Timers:CreateTimer(function()
		if distance_traveled < travel_distance then
			local dummy_location = deafening_dummy:GetAbsOrigin() + direction * dummy_speed
			deafening_dummy:SetAbsOrigin(dummy_location)
			distance_traveled = distance_traveled + dummy_speed

			return 1/30
		else
			deafening_dummy:RemoveSelf() 
		end
	end)
end