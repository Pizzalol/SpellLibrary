-- Fix projectile offset to take into consideration the direction
-- Fix motion controller
-- Fix particles
-- FIX HOOK


function LaunchMeatHook( keys )
	local hCaster = keys.caster
	local hAbility = keys.ability
	local vTarget_point = keys.target_points[1]
	local vCaster_location = hCaster:GetAbsOrigin() 
	local vDirection = (vTarget_point - vCaster_location):Normalized()
	local nAbility_level = hAbility:GetLevel() - 1

	hAbility.hook_damage = hAbility:GetLevelSpecialValueFor("hook_damage", nAbility_level)
	hAbility.hook_speed = hAbility:GetLevelSpecialValueFor("hook_speed", nAbility_level)
	hAbility.hook_width = hAbility:GetLevelSpecialValueFor("hook_width", nAbility_level)
	hAbility.hook_distance = hAbility:GetLevelSpecialValueFor("hook_distance", nAbility_level)

	hAbility.vision_radius = hAbility:GetLevelSpecialValueFor("vision_radius", nAbility_level)
	hAbility.vision_duration = hAbility:GetLevelSpecialValueFor("vision_duration", nAbility_level)

	hAbility.vHookOffset = Vector(0,0,96)
	hAbility.vStartPosition = (vCaster_location + hAbility.hook_width) * vDirection
	vDirection.z = 0 -- Didnt do some calculations for direction
	hAbility.vTargetPosition = vDirection * hAbility.hook_distance

	-- ??
	local vHookTarget = hAbility.vTargetPosition --+ hAbility.vHookOffset
	local vKillswitch = Vector( ( ( hAbility.hook_distance / hAbility.hook_speed ) * 2 ), 0, 0 )

	if hCaster and hCaster:IsHero() then
		local hHook = hCaster:GetTogglableWearable( DOTA_LOADOUT_TYPE_WEAPON )
		if hHook ~= nil then
			hHook:AddEffects( EF_NODRAW )
		end
	end

	hAbility.nChainParticleFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_meathook.vpcf", PATTACH_CUSTOMORIGIN, hAbility:GetCaster() )
	ParticleManager:SetParticleAlwaysSimulate( hAbility.nChainParticleFXIndex )
	ParticleManager:SetParticleControlEnt( hAbility.nChainParticleFXIndex, 0, hCaster, PATTACH_POINT_FOLLOW, "attach_hitloc", vCaster_location + hAbility.vHookOffset, true )
	ParticleManager:SetParticleControl( hAbility.nChainParticleFXIndex, 1, vHookTarget )
	ParticleManager:SetParticleControl( hAbility.nChainParticleFXIndex, 2, Vector( hAbility.hook_speed, hAbility.hook_distance, hAbility.hook_width ) )
	ParticleManager:SetParticleControl( hAbility.nChainParticleFXIndex, 3, vKillswitch )
	ParticleManager:SetParticleControl( hAbility.nChainParticleFXIndex, 4, Vector( 1, 0, 0 ) )
	ParticleManager:SetParticleControl( hAbility.nChainParticleFXIndex, 5, Vector( 0, 0, 0 ) )
	ParticleManager:SetParticleControlEnt( hAbility.nChainParticleFXIndex, 7, hCaster, PATTACH_CUSTOMORIGIN, nil, vCaster_location, true )

	--print("Caster location: " .. tostring(vCaster_location))
	--print("Target point: " .. tostring(vTarget_point))
	--print("Target position: " .. tostring(hAbility.vTargetPosition))
	--print("Direction: " .. tostring(vDirection))
	--print("Spawn origin: " .. tostring((vCaster_location + hAbility.hook_width) * vDirection))

	local info = 
	{
		EffectName = "particles/units/heroes/hero_vengeful/vengeful_wave_of_terror.vpcf",
		Ability = hAbility,
		vSpawnOrigin = vCaster_location + hAbility.hook_width * vDirection,
		vVelocity = vDirection * hAbility.hook_speed,
		fDistance = hAbility.hook_distance,
		fStartRadius = hAbility.hook_width ,
		fEndRadius = hAbility.hook_width ,
		Source = hCaster,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_BOTH,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
	}

	ProjectileManager:CreateLinearProjectile( info )

	hAbility.bRetracting = false
	hAbility.hVictim = nil
	hAbility.bDiedInHook = false
end

function MeatHookHit( keys )
	local hCaster = keys.caster
	local hTarget = keys.target
	local hAbility = keys.ability


	if hAbility.bRetracting == false then
		local bTargetPulled = false

		if hTarget then
			if hTarget:GetTeamNumber() ~= hCaster:GetTeamNumber() then
				local hDamage_table = {}

				hDamage_table.attacker = hCaster
				hDamage_table.victim = hTarget
				hDamage_table.ability = hAbility
				hDamage_table.damage_type = hAbility:GetAbilityDamageType()
				hDamage_table.damage = hAbility.hook_damage

				if not hTarget:IsAlive() then
					hAbility.bDiedInHook = true
				end

				if not hTarget:IsMagicImmune() then
					hTarget:Interrupt()
				end
		
				local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_meathook_impact.vpcf", PATTACH_CUSTOMORIGIN, hTarget )
				ParticleManager:SetParticleControlEnt( nFXIndex, 0, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hCaster:GetOrigin(), true )
				ParticleManager:ReleaseParticleIndex( nFXIndex )
			end

			AddFOWViewer( hCaster:GetTeamNumber(), hTarget:GetOrigin(), hAbility.vision_radius, hAbility.vision_duration, false )
			hAbility.hVictim = hTarget
			bTargetPulled = true
		end

		local vHookPos = hAbility.vTargetPosition
		local flPad = hCaster:GetPaddedCollisionRadius()
		if hTarget ~= nil then
			vHookPos = hTarget:GetOrigin()
			flPad = flPad + hTarget:GetPaddedCollisionRadius()
		end

		--Missing: Setting target facing angle
		local vVelocity = hAbility.vStartPosition - vHookPos
		vVelocity.z = 0.0

		local flDistance = vVelocity:Length2D() - flPad
		vVelocity = vVelocity:Normalized() * hAbility.hook_speed

		local info = 
		{
			Ability = hAbility,
			vSpawnOrigin = vHookPos,
			vVelocity = vVelocity,
			fDistance = flDistance,
			Source = hCaster,
		}

		ProjectileManager:CreateLinearProjectile( info )
		hAbility.vProjectileLocation = vHookPos

		if hTarget ~= nil and ( not hTarget:IsInvisible() ) and bTargetPulled then
			ParticleManager:SetParticleControlEnt( hAbility.nChainParticleFXIndex, 1, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetOrigin() + hAbility.vHookOffset, true )
			ParticleManager:SetParticleControl( hAbility.nChainParticleFXIndex, 4, Vector( 0, 0, 0 ) )
			ParticleManager:SetParticleControl( hAbility.nChainParticleFXIndex, 5, Vector( 1, 0, 0 ) )
		else
			ParticleManager:SetParticleControlEnt( hAbility.nChainParticleFXIndex, 1, hCaster, PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", hCaster:GetOrigin() + hAbility.vHookOffset, true);
		end

		EmitSoundOn( "Hero_Pudge.AttackHookRetract", hTarget )

		hAbility.bRetracting = true
	else
		if hCaster and hCaster:IsHero() then
			local hHook = hCaster:GetTogglableWearable( DOTA_LOADOUT_TYPE_WEAPON )
			if hHook ~= nil then
				hHook:RemoveEffects( EF_NODRAW )
			end
		end

		if hAbility.hVictim ~= nil then
			local vFinalHookPos = vLocation
			hAbility.hVictim:InterruptMotionControllers( true )
			hAbility.hVictim:RemoveModifierByName( "modifier_pudge_meat_hook_lua" )

			local vVictimPosCheck = hAbility.hVictim:GetOrigin() - vFinalHookPos 
			local flPad = hCaster:GetPaddedCollisionRadius() + hAbility.hVictim:GetPaddedCollisionRadius()
			if vVictimPosCheck:Length2D() > flPad then
				FindClearSpaceForUnit( hAbility.hVictim, hAbility.vStartPosition, false )
			end
		end

		hAbility.hVictim = nil
		ParticleManager:DestroyParticle( hAbility.nChainParticleFXIndex, true )
		EmitSoundOn( "Hero_Pudge.AttackHookRetractStop", hCaster )
	end
end

-- do direction *-1 and hook speed * server tick instead of projectile location

function HookMotionControl( keys )
	local hCaster = keys.caster
	local hTarget = keys.target
	local hAbility = keys.ability

	if hAbility.hVictim then
		hAbility.hVictim:SetOrigin( hAbility.vProjectileLocation )
		local vToCaster = hAbility.vStartPosition - hCaster:GetOrigin()
		local flDist = vToCaster:Length2D()
		if hAbility.bChainAttached == false and flDist > 128.0 then 
			hAbility.bChainAttached = true  
			ParticleManager:SetParticleControlEnt( hAbility.nChainParticleFXIndex, 0, hCaster, PATTACH_CUSTOMORIGIN, "attach_hitloc", hCaster:GetOrigin(), true )
			ParticleManager:SetParticleControl( hAbility.nChainParticleFXIndex, 0, hAbility.vStartPosition + hAbility.vHookOffset )
		end                   
	end
end