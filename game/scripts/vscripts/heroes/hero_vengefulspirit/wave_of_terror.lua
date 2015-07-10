--[[Author: Pizzalol, kritth
	Date: 31.01.2015.
	Provides vision along the way of the projectile]]
function WaveOfTerrorVision( keys )
	local caster = keys.caster
	local caster_location = caster:GetAbsOrigin()
	local ability = keys.ability
	local target_point = keys.target_points[1]
	local forwardVec = (target_point - caster_location):Normalized()

	-- Projectile variables
	local wave_speed = ability:GetLevelSpecialValueFor("wave_speed", (ability:GetLevel() - 1))
	local wave_width = ability:GetLevelSpecialValueFor("wave_width", (ability:GetLevel() - 1))
	local wave_range = ability:GetLevelSpecialValueFor("wave_range", (ability:GetLevel() - 1))
	local wave_location = caster_location

	-- Vision variables
	local vision_aoe = ability:GetLevelSpecialValueFor("vision_aoe", (ability:GetLevel() - 1))
	local vision_duration = ability:GetLevelSpecialValueFor("vision_duration", (ability:GetLevel() - 1))

	-- Creating the projectile
	local projectileTable =
	{
		EffectName = "",
		Ability = nil,
		vSpawnOrigin = caster_location,
		vVelocity = Vector( forwardVec.x * wave_speed, forwardVec.y * wave_speed, 0 ),
		fDistance = 99999,
		fStartRadius = wave_width,
		fEndRadius = wave_width,
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO
	}
	-- Saving the projectile ID so that we can destroy it later
	projectile_id = ProjectileManager:CreateLinearProjectile( projectileTable )

	-- Timer to provide vision and to destroy the projectile
	Timers:CreateTimer( function()
		-- Calculating the distance traveled
		wave_location = wave_location + forwardVec * (wave_speed * 1/30)

		ability:CreateVisibilityNode( wave_location, vision_aoe, vision_duration )

		local distance = (wave_location - caster_location):Length2D()

		-- Checking if we traveled far enough, if yes then destroy the projectile and kill the timer
		if distance >= wave_range then
			ProjectileManager:DestroyLinearProjectile(projectile_id)
			return nil
		else
			return 1/30
		end
	end)

end