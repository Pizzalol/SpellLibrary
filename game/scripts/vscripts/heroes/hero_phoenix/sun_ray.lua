--[[
	Author: Ractidous
	Date: 28.01.2015.
	Cast Sun Ray
]]
function CastSunRay( event )

	local caster	= event.caster
	local ability	= event.ability

	local pathLength					= event.path_length
	local numThinkers					= event.num_thinkers
	local thinkerStep					= event.thinker_step
	local thinkerRadius					= event.thinker_radius
	local forwardMoveSpeed				= event.forward_move_speed
	local turnRateInitial				= event.turn_rate_initial
	local turnRate						= event.turn_rate
	local initialTurnDuration			= event.initial_turn_max_duration
	local modifierCasterName			= event.modifier_caster_name
	local modifierThinkerName			= event.modifier_thinker_name
	local modifierIgnoreTurnRateName	= event.modifier_ignore_turn_rate_limit_name

	local casterOrigin	= caster:GetAbsOrigin()

	caster.sun_ray_is_moving = false
	caster.sun_ray_hp_at_start = caster:GetHealth()

	-- Create thinkers
	local vThinkers = {}
	for i=1, numThinkers do
		local thinker = CreateUnitByName( "npc_dota_invisible_vision_source", casterOrigin, false, caster, caster, caster:GetTeam() )
		vThinkers[i] = thinker

		thinker:SetDayTimeVisionRange( thinkerRadius )
		thinker:SetNightTimeVisionRange( thinkerRadius )

		ability:ApplyDataDrivenModifier( caster, thinker, modifierThinkerName, {} )
	end

	local endcap = vThinkers[numThinkers]

	-- Create particle FX
	local particleName = "particles/units/heroes/hero_phoenix/phoenix_sunray.vpcf"
	pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControlEnt( pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true )

	-- Attach a loop sound to the endcap
	local endcapSoundName = "Hero_Phoenix.SunRay.Beam"
	StartSoundEvent( endcapSoundName, endcap )

	-- Swap sub ability
	local main_ability_name	= ability:GetAbilityName()
	local sub_ability_name	= event.sub_ability_name
	caster:SwapAbilities( main_ability_name, sub_ability_name, false, true )

	-- Enable the toggle ability
	caster:SwapAbilities( event.toggle_move_empty_ability_name, event.toggle_move_ability_name, false, true )

	--
	-- Note: The turn speed
	--
	--  Original's actual turn speed = 277.7735 (at initial) and 22.2218 [deg/s].
	--  We can achieve this weird value by using this formula.
	--	  actual_turn_rate = turn_rate / (0.0333..) * 0.03
	--
	--  And, initial turn buff ends when the delta yaw gets 0 or 0.75 seconds elapsed.
	--
	turnRateInitial	= turnRateInitial	/ (1/30) * 0.03
	turnRate		= turnRate			/ (1/30) * 0.03

	-- Update
	local deltaTime = 0.03

	local lastAngles = caster:GetAngles()
	local isInitialTurn = true
	local elapsedTime = 0.0

	caster:SetContextThink( DoUniqueString( "updateSunRay" ), function ( )

		-- OnInterrupted :
		--  Destroy FXs and the thinkers.
		if not caster:HasModifier( modifierCasterName ) then
			ParticleManager:DestroyParticle( pfx, false )
			StopSoundEvent( endcapSoundName, endcap )

			for i=1, numThinkers do
				vThinkers[i]:RemoveSelf()
			end

			return nil
		end

		--
		-- "MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE" is seems to be broken.
		-- So here we fix the yaw angle manually in order to clamp the turn speed.
		--
		-- If the hero has "modifier_ignore_turn_rate_limit_datadriven" modifier,
		-- we shouldn't change yaw from here.
		--

		-- Calculate the turn speed limit.
		local deltaYawMax
		if isInitialTurn then
			deltaYawMax = turnRateInitial * deltaTime
		else
			deltaYawMax = turnRate * deltaTime
		end

		-- Calculate the delta yaw
		local currentAngles	= caster:GetAngles()
		local deltaYaw		= RotationDelta( lastAngles, currentAngles ).y
		local deltaYawAbs	= math.abs( deltaYaw )

		if deltaYawAbs > deltaYawMax and not caster:HasModifier( modifierIgnoreTurnRateName ) then
			-- Clamp delta yaw
			local yawSign = (deltaYaw < 0) and -1 or 1
			local yaw = lastAngles.y + deltaYawMax * yawSign

			currentAngles.y = yaw	-- Never forget!

			-- Update the yaw
			caster:SetAngles( currentAngles.x, currentAngles.y, currentAngles.z )
		end

		lastAngles = currentAngles

		-- Update the turning state.
		elapsedTime = elapsedTime + deltaTime

		if isInitialTurn then
			if deltaYawAbs == 0 then
				isInitialTurn = false
			end
			if elapsedTime >= initialTurnDuration then
				isInitialTurn = false
			end
		end

		-- Current position & direction
		local casterOrigin	= caster:GetAbsOrigin()
		local casterForward	= caster:GetForwardVector()

		-- Move forward
		if caster.sun_ray_is_moving then
			casterOrigin = casterOrigin + casterForward * forwardMoveSpeed * deltaTime
			casterOrigin = GetGroundPosition( casterOrigin, caster )
			caster:SetAbsOrigin( casterOrigin )
		end

		-- Update thinker positions
		local endcapPos = casterOrigin + casterForward * pathLength
		endcapPos = GetGroundPosition( endcapPos, nil )
		endcapPos.z = endcapPos.z + 92
		endcap:SetAbsOrigin( endcapPos )

		for i=1, numThinkers-1 do
			local thinker = vThinkers[i]
			thinker:SetAbsOrigin( casterOrigin + casterForward * ( thinkerStep * (i-1) ) )
		end

		-- Update particle FX
		ParticleManager:SetParticleControl( pfx, 1, endcapPos )

		return deltaTime

	end, 0.0 )

end

--[[
	Author: Ractidous
	Date: 29.01.2015.
	Remove HP.
]]
function SpendHPCost( event )
	local caster = event.caster
	local hpCost = event.hp_cost_perc_per_second * event.tick_interval
--	caster:SetHealth( caster:GetHealth() * ( 100 - hpCost ) / 100 )
	caster:SetHealth( caster:GetHealth() - caster.sun_ray_hp_at_start * hpCost / 100 )
end

--[[
	Author: Ractidous
	Date: 29.01.2015.
	Swap the abilities back to the original states.
]]
function EndSunRay( event )
	local caster	= event.caster
	local ability	= event.ability

	caster:SwapAbilities( ability:GetAbilityName(), event.sub_ability_name, true, false )
	caster:SwapAbilities( event.toggle_move_empty_ability_name, event.toggle_move_ability_name, true, false )
end

--[[
	Author: Ractidous
	Date: 29.01.2015.
	Toggle move.
]]
function ToggleMove( event )
	local caster = event.caster
	caster.sun_ray_is_moving = not caster.sun_ray_is_moving
end

--[[
	Author: Ractidous
	Date: 29.01.2015.
	Check current states, and interrupt the sun ray if the caster is getting disabled.
]]
function CheckToInterrupt( event )
	local caster	= event.caster

	if caster:IsSilenced() or 
	   caster:IsStunned() or caster:IsHexed() or caster:IsFrozen() or caster:IsNightmared() or caster:IsOutOfGame() then
		-- Interrupt the ability
		caster:RemoveModifierByName( event.modifier_caster_name )
	end
end

--[[
	Author: Ractidous
	Date: 28.01.2015.
	Check whether the target is within the sun ray, and apply the damage if neccesary.
]]
function CheckForCollision( event )

	local caster			= event.caster
	local target			= event.target
	local ability			= event.ability

	local pathLength		= event.path_length
	local pathRadius		= event.path_radius

	local tickInterval		= event.tick_interval
	local baseDamage		= event.base_dmg
	local hpPercentDamage	= event.hp_perc_dmg
	local allyHealFactor	= event.ally_heal

	-- Calculate distance
	local pathStartPos	= caster:GetAbsOrigin() * Vector( 1, 1, 0 )
	local pathEndPos	= pathStartPos + caster:GetForwardVector() * pathLength

	local distance = DistancePointSegment( target:GetAbsOrigin() * Vector( 1, 1, 0 ), pathStartPos, pathEndPos )
	if distance > pathRadius then
		return
	end

	-- Calculate damage
	local damage = baseDamage + target:GetMaxHealth() * hpPercentDamage / 100
	damage = damage * tickInterval

	-- Check team
	local isEnemy = caster:IsOpposingTeam( target:GetTeamNumber() )

	if isEnemy then

		-- Remove HP
		ApplyDamage( {
			victim		= target,
			attacker	= caster,
			damage		= damage,
			damage_type	= DAMAGE_TYPE_PURE,
		} )

		-- Fire burn particle
		local pfx = ParticleManager:CreateParticle( event.particle_burn_name, PATTACH_ABSORIGIN, target )
		ParticleManager:SetParticleControlEnt( pfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true )
		ParticleManager:ReleaseParticleIndex( pfx )

	else

		-- Healing
		damage = damage * allyHealFactor

		target:Heal( damage, caster )

		-- Fire healing particle
		local pfx = ParticleManager:CreateParticle( event.particle_heal_name, PATTACH_ABSORIGIN, target )
		ParticleManager:ReleaseParticleIndex( pfx )

	end
end

--[[
	Author: Ractidous
	Date: 27.01.2015.
	Distance between a point and a segment.
]]
function DistancePointSegment( p, v, w )
	local l = w - v
	local l2 = l:Dot( l )
	t = ( p - v ):Dot( w - v ) / l2
	if t < 0.0 then
		return ( v - p ):Length2D()
	elseif t > 1.0 then
		return ( w - p ):Length2D()
	else
		local proj = v + t * l
		return ( proj - p ):Length2D()
	end
end

--[[
	Author: Noya
	Date: 16.01.2015.
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

--[[
	Author: Ractidous
	Date: 29.01.2015.
	Stop a sound.
]]
function StopSound( event )
	StopSoundEvent( event.sound_name, event.caster )
end