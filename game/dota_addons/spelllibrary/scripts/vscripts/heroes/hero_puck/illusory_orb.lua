--[[
	Author: Ractidous
	Date: 02.16.2015.
	Create a linear projectile, then keep it tracked.
]]
function CastIllusoryOrb( event )
	
	local caster	= event.caster
	local ability	= event.ability
	local point		= event.target_points[1]

	local radius			= event.radius
	local maxDist			= event.max_distance
	local orbSpeed			= event.orb_speed
	local visionRadius		= event.orb_vision
	local visionDuration	= event.vision_duration
	local numExtraVisions	= event.num_extra_visions

	local travelDuration	= maxDist / orbSpeed
	local extraVisionInterval = travelDuration / numExtraVisions

	local casterOrigin		= caster:GetAbsOrigin()
	local targetDirection	= ( ( point - casterOrigin ) * Vector(1,1,0) ):Normalized()
	local projVelocity		= targetDirection * orbSpeed

	local startTime		= GameRules:GetGameTime()
	local endTime		= startTime + travelDuration

	local numExtraVisionsCreated = 0
	local isKilled		= false

	-- Make Ethereal Jaunt active
	local etherealJauntAbility = ability.illusory_orb_etherealJauntAbility
	etherealJauntAbility:SetActivated( true )

	-- Create linear projectile
	local projID = ProjectileManager:CreateLinearProjectile( {
		Ability				= ability,
		EffectName			= event.proj_particle,
		vSpawnOrigin		= casterOrigin,
		fDistance			= maxDist,
		fStartRadius		= radius,
		fEndRadius			= radius,
		Source				= caster,
		bHasFrontalCone		= false,
		bReplaceExisting	= false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		fExpireTime			= endTime,
		bDeleteOnHit		= false,
		vVelocity			= projVelocity,
		bProvidesVision		= true,
		iVisionRadius		= visionRadius,
		iVisionTeamNumber	= caster:GetTeamNumber(),
	} )

	--print("projID = " .. projID)

	-- Create sound source
	local thinker = CreateUnitByName( "npc_dota_thinker", casterOrigin, false, caster, caster, caster:GetTeamNumber() )
	ability:ApplyDataDrivenModifier( caster, thinker, event.proj_modifier, { duration = -1 } )

	--
	-- Replace Ethereal Jaunt function
	--
	etherealJauntAbility.etherealJaunt_cast = function ( )
		-- Remove the projectile
		ProjectileManager:DestroyLinearProjectile( projID )

		-- Blink
		FindClearSpaceForUnit( caster, thinker:GetAbsOrigin(), false )

		-- Kill
		isKilled = true

		etherealJauntAbility.etherealJaunt_cast = nil
	end

	--
	-- Track the projectile
	--
	Timers:CreateTimer( function ( )
		
		local elapsedTime 	= GameRules:GetGameTime() - startTime
		local currentOrbPosition = casterOrigin + projVelocity * elapsedTime
		currentOrbPosition = GetGroundPosition( currentOrbPosition, thinker )

		-- Update position of the sound source
		thinker:SetAbsOrigin( currentOrbPosition )

		-- Try to create new extra vision
		if elapsedTime > extraVisionInterval * (numExtraVisionsCreated + 1) then
			ability:CreateVisibilityNode( currentOrbPosition, visionRadius, visionDuration )
			numExtraVisionsCreated = numExtraVisionsCreated + 1
		end

		-- Remove if the projectile has expired
		if elapsedTime >= travelDuration or isKilled then
			--print( numExtraVisionsCreated .. " extra vision created." )
			thinker:RemoveModifierByName( event.proj_modifier )
			--thinker:RemoveSelf()

			etherealJauntAbility:SetActivated( false )

			return nil
		end

		return 0.03

	end )

end

--[[
	Author: Ractidous
	Date: 16.02.2015.
	Upgrade the sub ability and make inactive it.
]]
function OnUpgrade( event )
	local caster	= event.caster
	local ability	= event.ability
	local etherealJauntAbility = caster:FindAbilityByName( event.sub_ability )
	ability.illusory_orb_etherealJauntAbility = etherealJauntAbility

	if not etherealJauntAbility then
		print( "Ethereal jaunt not found. at heroes/hero_puck/illusory_orb.lua # OnUpgrade" )
		return
	end

	etherealJauntAbility:SetLevel( ability:GetLevel() )

	if etherealJauntAbility:GetLevel() == 1 then
		etherealJauntAbility:SetActivated( false )
	end
end

--[[
	Author: Ractidous
	Date: 16.02.2015.
	Cast Ethereal Jaunt.
]]
function CastEtherealJaunt( event )
	local ability = event.ability
	if ability.etherealJaunt_cast then
		ability.etherealJaunt_cast()
	end
end



--[[
	Author: Ractidous
	Date: 13.02.2015.
	Stop a sound on the target unit.
]]
function StopSound( event )
	StopSoundEvent( event.sound_name, event.target )
end