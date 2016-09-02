--[[Author: Nightborn and KAL
	Date: September 1, 2016
]]

function Desolate (keys)

	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local radius = ability:GetSpecialValueFor("radius")

	units = FindUnitsInRadius(
				caster:GetTeamNumber(),
                target:GetAbsOrigin(),
                nil,
                radius,
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                DOTA_UNIT_TARGET_FLAG_NO_INVIS,
                FIND_ANY_ORDER,
                false
    )

	local target_is_alone = true

    for _,unit in pairs(units) do
    	if unit:GetTeam() == target:GetTeam() and unit ~= target then
    		target_is_alone = false
    	end
    end

    if target_is_alone and target:IsAlive() and not target:IsMagicImmune() then
    	
    	EmitSoundOn("Hero_Spectre.Desolate", caster)

    	local particle_name = "particles/units/heroes/hero_spectre/spectre_desolate.vpcf"
    	--Not really a cleave attack (cleave damage = 0), its just for the particle effect
    	local particle = ParticleManager:CreateParticle(particle_name, PATTACH_POINT, target)
        local pelel = caster:GetForwardVector()
        ParticleManager:SetParticleControl(particle, 0, Vector(     target:GetAbsOrigin().x,
                                                                    target:GetAbsOrigin().y, 
                                                                    GetGroundPosition(target:GetAbsOrigin(), target).z + 140))
        --ParticleManager:SetParticleControl(particle, 4, Vector(1, 1, 0))
        ParticleManager:SetParticleControlForward(particle, 0, caster:GetForwardVector())

		local damageTable = {
		victim = target,
		attacker = caster,
		damage = ability:GetLevelSpecialValueFor( "bonus_damage", ability:GetLevel()-1 ),
		damage_type = ability:GetAbilityDamageType(),
		}
		 
		ApplyDamage(damageTable)
 
    end

end
