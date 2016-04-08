--[[Author: YOLOSPAGHETTI
	Date: April 3, 2016
	Fires the projectile if the targets line up]]
function CheckAngles(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	-- Notes the origin of the first target to be the center of the findunits radius
	local first_target_origin = target:GetAbsOrigin()
	-- Notes the damage the first target takes to apply to the other targets
	ability.first_target_damage = keys.damage
		
	-- Gets the caster's origin difference from the target
	local caster_origin_difference = caster:GetAbsOrigin() - first_target_origin 

	-- Get the radian of the origin difference between the attacker and TA. We use this to figure out at what angle the victim is at relative to the TA.
	local caster_origin_difference_radian = math.atan2(caster_origin_difference.y, caster_origin_difference.x)
	
	-- Convert the radian to degrees.
	caster_origin_difference_radian = caster_origin_difference_radian * 180
	local attacker_angle = caster_origin_difference_radian / math.pi
	-- Turns negative angles into positive ones and make the math simpler.
	attacker_angle = attacker_angle + 180.0
	
	local radius = ability:GetLevelSpecialValueFor("attack_spill_range", ability:GetLevel() - 1)
	local attack_spill_width = ability:GetLevelSpecialValueFor("attack_spill_width", ability:GetLevel() - 1)/2
	
	-- Units in radius
	local units = FindUnitsInRadius(caster:GetTeamNumber(), first_target_origin, nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), 0, 0, false)
	
	-- Calculates the position of each found unit in relation to the last target
	for i,unit in ipairs(units) do
		if unit ~= target then
		
			local target_origin_difference = target:GetAbsOrigin() - unit:GetAbsOrigin()
			
			-- Get the radian of the origin difference between the last target and the unit. We use this to figure out at what angle the unit is at relative to the the target.
			local target_origin_difference_radian = math.atan2(target_origin_difference.y, target_origin_difference.x)
	
			-- Convert the radian to degrees.
			target_origin_difference_radian = target_origin_difference_radian * 180
			local victim_angle = target_origin_difference_radian / math.pi
			-- Turns negative angles into positive ones and make the math simpler.
			victim_angle = victim_angle + 180.0
	
			-- The difference between the world angle of the caster-target vector and the target-unit vector
			local angle_difference = math.abs(victim_angle - attacker_angle)			
			
			local new_target = false
			
			-- Ensures the angle difference is less than the allowed width
			if angle_difference <= attack_spill_width then
				local info = {
				Target = unit,
				Source = target,
				Ability = ability,
				EffectName = keys.particle,
				bDodgeable = false,
				iMoveSpeed = 9000,
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
				}
				ProjectileManager:CreateTrackingProjectile( info )
				
				new_target = true
			end
		end
	end
end

--[[Author: YOLOSPAGHETTI
	Date: April 8, 2016
	Deals damage to the secondary targets]]
function DealDamage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	-- Applies the damage to the attack target
	ApplyDamage({victim = target, attacker = caster, damage = ability.first_target_damage, damage_type = ability:GetAbilityDamageType()})
end
