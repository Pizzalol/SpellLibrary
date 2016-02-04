--[[Author: YOLOSPAGHETTI
	Date: February 4, 2016
	Checks if Riki is behind his target
	Borrows heavily from bristleback.lua]]
	
function CheckBackstab(params)
	
	local ability = params.ability
	local agility_damage_multiplier = ability:GetLevelSpecialValueFor("agility_damage", ability:GetLevel() - 1) / 100

	-- The y value of the angles vector contains the angle we actually want: where units are directionally facing in the world.
	local victim_angle = params.target:GetAnglesAsVector().y
	local origin_difference = params.target:GetAbsOrigin() - params.attacker:GetAbsOrigin()

	-- Get the radian of the origin difference between the attacker and Riki. We use this to figure out at what angle the victim is at relative to Riki.
	local origin_difference_radian = math.atan2(origin_difference.y, origin_difference.x)
	
	-- Convert the radian to degrees.
	origin_difference_radian = origin_difference_radian * 180
	local attacker_angle = origin_difference_radian / math.pi
	-- Makes angle "0 to 360 degrees" as opposed to "-180 to 180 degrees" aka standard dota angles.
	attacker_angle = attacker_angle + 180.0
	
	-- Finally, get the angle at which the victim is facing Riki.
	local result_angle = attacker_angle - victim_angle
	result_angle = math.abs(result_angle)
	
	-- Check for the backstab angle.
	if result_angle >= (180 - (ability:GetSpecialValueFor("backstab_angle") / 2)) and result_angle <= (180 + (ability:GetSpecialValueFor("backstab_angle") / 2)) then 
		-- Play the sound on the victim.
		EmitSoundOn(params.sound, params.target)
		-- Create the back particle effect.
		local particle = ParticleManager:CreateParticle(params.particle, PATTACH_ABSORIGIN_FOLLOW, params.target) 
		-- Set Control Point 1 for the backstab particle; this controls where it's positioned in the world. In this case, it should be positioned on the victim.
		ParticleManager:SetParticleControlEnt(particle, 1, params.target, PATTACH_POINT_FOLLOW, "attach_hitloc", params.target:GetAbsOrigin(), true) 
		-- Apply extra backstab damage based on Riki's agility
		ApplyDamage({victim = params.target, attacker = params.attacker, damage = params.attacker:GetAgility() * agility_damage_multiplier, damage_type = ability:GetAbilityDamageType()})
	else
		--EmitSoundOn(params.sound2, params.target)
		-- uncomment this if regular (non-backstab) attack has no sound
	end
end
