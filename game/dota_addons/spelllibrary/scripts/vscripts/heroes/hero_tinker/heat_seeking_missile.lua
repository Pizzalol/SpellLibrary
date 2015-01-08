--[[
	Author: kritth
	Date: 7.1.2015.
	Fire missiles if there are targets, else play dud
]]
function heat_seeking_missile_seek_targets( keys )
	local caster = keys.caster
	local ability = keys.ability
	local particle_name = "particles/units/heroes/hero_tinker/tinker_missile.vpcf"
	local particle_dud_name = "particles/units/heroes/hero_tinker/tinker_missile_dud.vpcf"
	local sound_dud_name = "Hero_Tinker.Heat-Seeking_Missile_Dud"
	local radius = ability:GetLevelSpecialValueFor( "radius", ability:GetLevel() - 1 )
	local max_targets = ability:GetLevelSpecialValueFor( "targets", ability:GetLevel() - 1 )
	
	-- pick up x nearest target heroes and create tracking projectile targeting the number of targets
	local units = FindUnitsInRadius(
		caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_CLOSEST, false
	)
	
	-- Seek out target
	local count = 0
	for k, v in pairs( units ) do
		if count < max_targets then
			local projTable = {
				Target = v,
				Source = caster,
				Ability = ability,
				EffectName = particle_name,
				bDodgeable = false,
				bProvidesVision = false,
				iMoveSpeed = 900, 
				vSpawnOrigin = caster:GetAbsOrigin()
			}
			ProjectileManager:CreateTrackingProjectile( projTable )
			count = count + 1
		else
			break
		end
	end
	
	-- If no unit is found, fire dud
	if count == 0 then
		ability:ApplyDataDrivenModifier( caster, caster, "modifier_heat_seeking_missile_dud", {} )
	end
end
