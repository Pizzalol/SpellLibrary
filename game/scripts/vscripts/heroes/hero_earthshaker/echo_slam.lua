--[[Author: YOLOSPAGHETTI
	Date: July 30, 2016
	Renders the echo slam particles, applies all the initial damage, and sends projectiles to the echo targets]]
function EchoSlam(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	local echo_slam_damage_range = ability:GetLevelSpecialValueFor("echo_slam_damage_range", (ability:GetLevel() -1))
	local echo_slam_echo_search_range = ability:GetLevelSpecialValueFor("echo_slam_echo_search_range", (ability:GetLevel() -1))
	local echo_slam_echo_range = ability:GetLevelSpecialValueFor("echo_slam_echo_range", (ability:GetLevel() -1))
	
	-- Renders the echoslam particle around the caster
	local particle1 = ParticleManager:CreateParticle(keys.particle1, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(particle1, 0, Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z ))
	ParticleManager:SetParticleControl(particle1, 1, Vector(echo_slam_damage_range,echo_slam_damage_range,caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z ))
	ParticleManager:SetParticleControl(particle1, 2, Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z ))
			
	-- Renders the echoslam start particle around the caster
	local particle2 = ParticleManager:CreateParticle(keys.particle2, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(particle2, 0, Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z ))
	ParticleManager:SetParticleControl(particle2, 1, Vector(echo_slam_damage_range,echo_slam_damage_range,caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z ))
	ParticleManager:SetParticleControl(particle2, 2, Vector(caster:GetAbsOrigin().x,caster:GetAbsOrigin().y,caster:GetAbsOrigin().z + caster:GetBoundingMaxs().z ))
	
	-- Units to take the initial echo slam damage, and to send echo projectiles from
	local initial_units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, echo_slam_damage_range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
	local is_target = false
	local is_echo_target = false
	
	-- Loops through the targets
	for i,initial_unit in ipairs(initial_units) do
		-- Applies the initial damage to the target
		ApplyDamage({victim = initial_unit, attacker = caster, damage = ability:GetAbilityDamage(), damage_type = ability:GetAbilityDamageType()})
		
		-- Units to receive echo damage
		local units = FindUnitsInRadius(caster:GetTeamNumber(), initial_unit:GetAbsOrigin(), nil, echo_slam_echo_search_range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
		
		-- Loops through the targets
		for j,unit in ipairs(units) do
			-- Sends the echo projectiles from the initial targets to the echo targets
			local info = 
			{
				Target = unit,
				Source = initial_unit,
				Ability = ability,	
				iMoveSpeed = echo_slam_echo_range,
				vSourceLoc= initial_unit:GetAbsOrigin(),
				bDodgeable = true,
			}
			projectile = ProjectileManager:CreateTrackingProjectile(info)
			is_echo_target = true
		end
		is_target = true
	end
	
	-- Plays the appropriate sounds
	if is_target == true then
		EmitSoundOn(keys.sound1, caster)
	else
		EmitSoundOn(keys.sound2, caster)
	end
	
	if is_echo_target == true then
		EmitSoundOn(keys.sound3, caster)
	else
		EmitSoundOn(keys.sound3, caster)
	end
end

--[[Author: YOLOSPAGHETTI
	Date: July 30, 2016
	Applies the echo damage to the targets]]
function ApplyEchoDamage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	local echo_slam_echo_damage = ability:GetLevelSpecialValueFor("echo_slam_echo_damage", (ability:GetLevel() -1))
	
	ApplyDamage({victim = target, attacker = caster, damage = echo_slam_echo_damage, damage_type = ability:GetAbilityDamageType()})
end
