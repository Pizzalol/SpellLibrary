--[[
	Author: Ractidous
	Date: 27.01.2015.
	Create the particle effect and projectiles.
]]
function FireMacropyre( event )
	local caster		= event.caster
	local ability		= event.ability

	local pathLength	= event.cast_range
	local pathRadius	= event.path_radius
	local duration		= event.duration

	local startPos = caster:GetAbsOrigin()
	local endPos = startPos + caster:GetForwardVector() * pathLength

	ability.macropyre_startPos	= startPos
	ability.macropyre_endPos	= endPos
	ability.macropyre_expireTime = GameRules:GetGameTime() + duration

	-- Create particle effect
	local particleName = "particles/units/heroes/hero_jakiro/jakiro_macropyre.vpcf"
	local pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, caster )
	ParticleManager:SetParticleControl( pfx, 0, startPos )
	ParticleManager:SetParticleControl( pfx, 1, endPos )
	ParticleManager:SetParticleControl( pfx, 2, Vector( duration, 0, 0 ) )
	ParticleManager:SetParticleControl( pfx, 3, startPos )

	-- Generate projectiles
	pathRadius = math.max( pathRadius, 64 )
	local projectileRadius = pathRadius * math.sqrt(2)
	local numProjectiles = math.floor( pathLength / (pathRadius*2) ) + 1
	local stepLength = pathLength / ( numProjectiles - 1 )

	local dummyModifierName = "modifier_macropyre_destroy_tree_datadriven"

	for i=1, numProjectiles do
		local projectilePos = startPos + caster:GetForwardVector() * (i-1) * stepLength

		ProjectileManager:CreateLinearProjectile( {
			Ability				= ability,
		--	EffectName			= "",
			vSpawnOrigin		= projectilePos,
			fDistance			= 64,
			fStartRadius		= projectileRadius,
			fEndRadius			= projectileRadius,
			Source				= caster,
			bHasFrontalCone		= false,
			bReplaceExisting	= false,
			iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,
			iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_MECHANICAL,
			fExpireTime			= ability.macropyre_expireTime,
			bDeleteOnHit		= false,
			vVelocity			= Vector( 0, 0, 0 ),	-- Don't move!
			bProvidesVision		= false,
		--	iVisionRadius		= 0,
		--	iVisionTeamNumber	= caster:GetTeamNumber(),
		} )

		-- Create dummy to destroy trees
		if i~=1 and GridNav:IsNearbyTree( projectilePos, pathRadius, true ) then
			local dummy = CreateUnitByName( "npc_dota_thinker", projectilePos, false, caster, caster, caster:GetTeamNumber() )
			ability:ApplyDataDrivenModifier( caster, dummy, dummyModifierName, {} )
		end
	end
end

--[[
	Author: Ractidous
	Data: 27.01.2015.
	Apply a dummy modifier that periodcally checks whether the target is within the macropyre's path.
]]
function ApplyDummyModifier( event )
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local modifierName = event.modifier_name

	local duration = ability.macropyre_expireTime - GameRules:GetGameTime()

	ability:ApplyDataDrivenModifier( caster, target, modifierName, { duration = duration } )
end

--[[
	Author: Ractidous
	Date: 27.01.2015.
	Check whether the target is within the path, and apply damage if neccesary.
]]
function CheckMacropyre( event )
	local caster		= event.caster
	local target		= event.target
	local ability		= event.ability
	local pathRadius	= event.path_radius
	local damage		= event.damage

	local targetPos = target:GetAbsOrigin()
	targetPos.z = 0

	local distance = DistancePointSegment( targetPos, ability.macropyre_startPos, ability.macropyre_endPos )
	if distance < pathRadius then
		-- Apply damage
		ApplyDamage( {
			ability = ability,
			attacker = caster,
			victim = target,
			damage = damage,
			damage_type = ability:GetAbilityDamageType(),
		} )
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