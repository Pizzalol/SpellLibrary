--[[
	Author: Ractidous
	Date: 27.01.2015.
	Launch the icy breath
]]
function Launch_IcyBreath( event )
	local caster = event.caster
	local ability = event.ability

	local casterOrigin = caster:GetAbsOrigin()
	local targetPos = event.target_points[1]
	local direction = targetPos - casterOrigin
	direction = direction / direction:Length2D()

	ProjectileManager:CreateLinearProjectile( {
		Ability				= ability,
	--	EffectName			= "",
		vSpawnOrigin		= casterOrigin,
		fDistance			= event.distance,
		fStartRadius		= event.start_radius,
		fEndRadius			= event.end_radius,
		Source				= caster,
		bHasFrontalCone		= true,
		bReplaceExisting	= false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_MECHANICAL,
	--	fExpireTime			= ,
		bDeleteOnHit		= false,
		vVelocity			= direction * event.speed,
		bProvidesVision		= false,
	--	iVisionRadius		= ,
	--	iVisionTeamNumber	= caster:GetTeamNumber(),
	} )

	local particleName = "particles/units/heroes/hero_jakiro/jakiro_dual_breath_ice.vpcf"
	local pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, caster )
	ParticleManager:SetParticleControl( pfx, 0, casterOrigin )
	ParticleManager:SetParticleControl( pfx, 1, direction * event.speed * 1.333 )
	ParticleManager:SetParticleControl( pfx, 3, Vector(0,0,0) )
	ParticleManager:SetParticleControl( pfx, 9, casterOrigin )

	caster:SetContextThink( DoUniqueString( "destroy_particle" ), function ()
		ParticleManager:DestroyParticle( pfx, false )
	end, event.distance / event.speed )
end

--[[
	Author: Ractidous
	Date: 27.01.2015.
	Launch the fiery breath
]]
function Launch_FieryBreath( event )
	local caster = event.caster
	local fieryAbility = caster:FindAbilityByName( event.fiery_ability_name )

	local casterOrigin = caster:GetAbsOrigin()
	local targetPos = event.target_points[1]
	local direction = targetPos - casterOrigin
	direction = direction / direction:Length2D()

	ProjectileManager:CreateLinearProjectile( {
		Ability				= fieryAbility,
	--	EffectName			= "",
		vSpawnOrigin		= casterOrigin,
		fDistance			= event.distance,
		fStartRadius		= event.start_radius,
		fEndRadius			= event.end_radius,
		Source				= caster,
		bHasFrontalCone		= true,
		bReplaceExisting	= false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_MECHANICAL,
	--	fExpireTime			= ,
		bDeleteOnHit		= false,
		vVelocity			= direction * event.speed,
		bProvidesVision		= false,
	--	iVisionRadius		= ,
	--	iVisionTeamNumber	= caster:GetTeamNumber(),
	} )

	local particleName = "particles/units/heroes/hero_jakiro/jakiro_dual_breath_fire.vpcf"
	local pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, caster )
	ParticleManager:SetParticleControl( pfx, 0, casterOrigin )
	ParticleManager:SetParticleControl( pfx, 1, direction * event.speed * 1.333 )
	ParticleManager:SetParticleControl( pfx, 3, Vector(0,0,0) )
	ParticleManager:SetParticleControl( pfx, 9, casterOrigin )

	caster:SetContextThink( DoUniqueString( "destroy_particle" ), function ()
		ParticleManager:DestroyParticle( pfx, false )
	end, event.distance / event.speed )
end

--[[
	Author: Ractidous
	Date: 26.01.2015.
	Apply burn modifier to the target.
]]
function OnProjectileHit_Fiery( event )
	local caster = event.caster
	local target = event.target
	local ability = caster:FindAbilityByName( event.main_ability_name )

	ability:ApplyDataDrivenModifier( caster, target, event.modifier_name, {} )
end