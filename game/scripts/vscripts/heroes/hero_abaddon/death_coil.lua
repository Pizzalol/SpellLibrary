--[[
	Author: igo95862, Noya
	Date: 14.1.2015.
	Disallows self targeting by checking if the target is not the caster when the ability starts
]]
function DeathCoilPreCast( event )
	local caster = event.caster
	local target = event.target
	local player = caster:GetPlayerOwner()
	local pID = caster:GetPlayerOwnerID()

	-- This prevents the spell from going off
	if target == caster then
		caster:Stop()

		-- Play Error Sound
		EmitSoundOnClient("General.CastFail_InvalidTarget_Hero", player)

		-- This makes use of the Custom Error Flash module by zedor. https://github.com/zedor/CustomError
		FireGameEvent( 'custom_error_show', { player_ID = pID, _error = "Ability Can't Target Self" } )
	end
end

--[[
	Author: Noya
	Date: 14.1.2015.
	If cast on an ally it will heal, if cast on an enemy it will do damage
]]
function DeathCoil( event )
	-- Variables
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local damage = ability:GetLevelSpecialValueFor( "target_damage" , ability:GetLevel() - 1  )
	local self_damage = ability:GetLevelSpecialValueFor( "self_damage" , ability:GetLevel() - 1  )
	local heal = ability:GetLevelSpecialValueFor( "heal_amount" , ability:GetLevel() - 1 )
	local projectile_speed = ability:GetSpecialValueFor( "projectile_speed" )
	local particle_name = "particles/units/heroes/hero_abaddon/abaddon_death_coil.vpcf"

	-- Play the ability sound
	caster:EmitSound("Hero_Abaddon.DeathCoil.Cast")
	target:EmitSound("Hero_Abaddon.DeathCoil.Target")

	-- If the target and caster are on a different team, do Damage. Heal otherwise
	if target:GetTeamNumber() ~= caster:GetTeamNumber() then
		ApplyDamage({ victim = target, attacker = caster, damage = damage,	damage_type = DAMAGE_TYPE_MAGICAL })
	else
		target:Heal( heal, caster)
	end

	-- Self Damage
	ApplyDamage({ victim = caster, attacker = caster, damage = self_damage,	damage_type = DAMAGE_TYPE_MAGICAL })

	-- Create the projectile
	local info = {
		Target = target,
		Source = caster,
		Ability = ability,
		EffectName = particle_name,
		bDodgeable = false,
			bProvidesVision = true,
			iMoveSpeed = projectile_speed,
        iVisionRadius = 0,
        iVisionTeamNumber = caster:GetTeamNumber(),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
	}
	ProjectileManager:CreateTrackingProjectile( info )

end