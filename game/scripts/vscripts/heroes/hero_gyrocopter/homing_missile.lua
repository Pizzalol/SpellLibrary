--[[Author: YOLOSPAGHETTI
	Date: March 28, 2016
	Creates the missile]]
function CreateMissile(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local starting_distance = ability:GetLevelSpecialValueFor( "starting_distance", ability:GetLevel() - 1 )
	local direction = caster:GetForwardVector()
	-- The missile starts some distance from the caster, in the direction of the target (also the way the caster's facing)
	local position = caster:GetAbsOrigin() + starting_distance * direction
	ability.target = target
	-- The initial position of the missile, to be used later in damage calculations
	ability.starting_position = position
	ability.level = ability:GetLevel() - 1
	-- Number of hits to kill the missile, to be decremented upon attacks
	ability.hits_to_kill = ability:GetLevelSpecialValueFor( "hits_to_kill_tooltip", ability:GetLevel() - 1 )
	-- A boolean telling us whether the missile has hit its target (ensures no repeated missile hit actions)
	ability.hit = false
	
	-- Creates the missile
	caster.missile = CreateUnitByName("npc_dota_gyrocopter_homing_missile", position, true, caster, nil, caster:GetTeam())
	-- Applies the modifer that moves the missile
	ability:ApplyDataDrivenModifier(caster, caster.missile, "modifier_homing_missile_datadriven", {})
	caster.missile:SetOwner(caster)
	-- We need to keep track of passing time, so we know when to fire the missile after the delay
	ability.time_passed = 0
	-- Attaches the fuse particle to the missile
	local particle = ParticleManager:CreateParticle(keys.particle, PATTACH_ABSORIGIN_FOLLOW, caster.missile) 
	ParticleManager:SetParticleControlEnt(particle, 1, caster.missile, PATTACH_POINT_FOLLOW, "attach_hitloc", caster.missile:GetAbsOrigin(), true)
end

--[[Author: YOLOSPAGHETTI
	Date: March 28, 2016
	Moves the missile and senses when it hits the target]]
function MoveMissile(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = ability.target
	-- The interval on which this function is called (every 0.02 seconds)
	local interval = 0.02
	
	-- Checks whether the missile has hit the target already
	if ability.hit == false then
		local pre_flight_time = ability:GetLevelSpecialValueFor( "pre_flight_time", ability.level )
		local stun_duration = ability:GetLevelSpecialValueFor( "stun_duration", ability.level )
		local min_damage = ability:GetLevelSpecialValueFor( "min_damage", ability.level )
		local max_distance = ability:GetLevelSpecialValueFor( "max_distance", ability.level )
		local min_distance = ability:GetLevelSpecialValueFor( "min_distance", ability.level )
		local speed = ability:GetLevelSpecialValueFor( "speed", ability.level )*interval
		local acceleration = ability:GetLevelSpecialValueFor( "acceleration", ability.level )*interval
		
		-- Location and distance variables
		local vector_distance = target:GetAbsOrigin() - caster.missile:GetAbsOrigin()
		local distance = (vector_distance):Length2D()
		local direction = (vector_distance):Normalized()
		
		-- Adds the interval length to the passed time
		ability.time_passed = ability.time_passed + interval
		
		-- Checks if the missile has passed its pre-launch phase
		if ability.time_passed >= pre_flight_time then
			-- On the missile launch, we play the launch sound
			if ability.time_passed == pre_flight_time then
				EmitSoundOn(keys.sound2, caster.missile)
			end
			-- Checks if the missile is close enough to hit the target (melee range)
			if distance < 128 then
				ability.hit = true
				-- The missile's distance from its starting point
				local travel_vector_distance = caster.missile:GetAbsOrigin() - ability.starting_position
				local travel_distance = travel_vector_distance:Length2D()
				
				-- Solves for the damage the missile does
				local damage
				if travel_distance >= max_distance then
					damage = ability:GetAbilityDamage()
				elseif travel_distance > min_distance then
					damage = (travel_distance/max_distance) * ability:GetAbilityDamage()
				else
					damage = min_damage
				end
				
				-- Applies the stun to the target
				target:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stun_duration})
				-- Applies the damage to the target
				ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType()})
				-- Kills the missile, which triggers the OnMissileAttacked block
				caster.missile:ForceKill(false)
			else
				-- Turns the missile so it's facing the target
				caster.missile:SetForwardVector(Vector(direction.x/2, direction.y/2, -1))
				-- Calculates the time after launch so we can solve for the new speed (after acceleration)
				local move_duration = math.modf(ability.time_passed - pre_flight_time)
				speed = speed + acceleration * move_duration
				-- Moves the missile
				caster.missile:SetAbsOrigin(caster.missile:GetAbsOrigin() + direction * speed)
			end
		end
	end
end

--[[Author: YOLOSPAGHETTI
	Date: March 28, 2016
	Keeps track of attacks on the missile and applies all death particles and sfx]]
function MissileAttacked(keys)
	local caster = keys.caster
	local attacker = keys.attacker
	local ability = keys.ability
	local target = ability.target
	local total_hits = ability:GetLevelSpecialValueFor( "hits_to_kill_tooltip", ability.level )
	
	-- If the attacker is a tower, we decrement half a hit, and give the missile the appropriate health bar
	if attacker:IsTower() == true then
		ability.hits_to_kill = ability.hits_to_kill - 0.5
		caster.missile:SetHealth(caster.missile:GetMaxHealth()*(ability.hits_to_kill/total_hits))
	-- The missile attacks itself in ForceKill calls (so the missile is already dead if this runs)
	elseif attacker == caster.missile then
		ability.hits_to_kill = 0
	-- If the attacker is not a tower, we decrement a full hit, and give the missile the appropriate health bar
	else
		ability.hits_to_kill = ability.hits_to_kill - 1
		caster.missile:SetHealth(caster.missile:GetMaxHealth()*(ability.hits_to_kill/total_hits))
	end
	
	-- If the missile is out of hits, we kill it
	if ability.hits_to_kill <= 0 then
		caster.missile:ForceKill(false)
	end
	-- Checks if the missile is dead
	if caster.missile:IsAlive() == false then
		-- If the missile did not hit the target, we play the appropriate effects
		if ability.hit == false then
			local particle = ParticleManager:CreateParticle(keys.particle, PATTACH_ABSORIGIN_FOLLOW, caster.missile) 
			ParticleManager:SetParticleControlEnt(particle, 1, caster.missile, PATTACH_POINT_FOLLOW, "attach_hitloc", caster.missile:GetAbsOrigin(), true)
		-- If the missile did hit the target, we add vision over the target and play the appropriate effects
		else
			local vision_time = ability:GetLevelSpecialValueFor( "vision_time", ability.level )
			local vision_radius = ability:GetLevelSpecialValueFor( "vision_radius", ability.level )
			AddFOWViewer(caster:GetTeam(), target:GetAbsOrigin(), vision_radius, vision_time, false)
			local particle = ParticleManager:CreateParticle(keys.particle2, PATTACH_ABSORIGIN_FOLLOW, target) 
			ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
			EmitSoundOn(keys.sound3, caster.missile)
		end
		-- Removes the missile's model, so there is no death animation
		caster.missile:AddNoDraw()
		-- Removes the targeting particle from the target
		target:RemoveModifierByName("modifier_homing_missile_target")
		-- Stops both missile sounds
		StopSoundEvent(keys.sound, caster.missile)
		StopSoundEvent(keys.sound2, caster.missile)
		-- Plays the missile death sound
		EmitSoundOn(keys.sound4, caster.missile)
	end
end
