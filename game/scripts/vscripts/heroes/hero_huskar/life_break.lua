--[[
    Author: Bude
    Date: 05.09.2015.
    (Description)
]]
function LifeBreak( keys )
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local charge_speed = ability:GetLevelSpecialValueFor("charge_speed", (ability:GetLevel() - 1)) * 1/30
    local auto_attack_target = ability:GetLevelSpecialValueFor("auto_attack_target", (ability:GetLevel() - 1))

    -- Clears any current command
    caster:Stop()

    -- Physics
    ability.velocity = charge_speed
    ability.actualtarget = target
end

function DoDamage(caster, target, ability)
    local caster_health = caster:GetHealth()
    local target_health = target:GetHealth()
    local health_cost = ability:GetLevelSpecialValueFor("health_cost_percent", (ability:GetLevel() - 1))
    local health_damage = ability:GetLevelSpecialValueFor("health_damage", (ability:GetLevel() - 1))

    local dmg_to_caster = caster_health * health_cost
    local dmg_to_target = target_health * health_damage

    local dmg_table_caster = {
                                victim = caster,
                                attacker = caster,
                                damage = dmg_to_caster,
                                damage_type = DAMAGE_TYPE_MAGICAL
                            }
    ApplyDamage(dmg_table_caster)

    local dmg_table_target = {
                                victim = target,
                                attacker = caster,
                                damage = dmg_to_target,
                                damage_type = DAMAGE_TYPE_MAGICAL
                            }
    ApplyDamage(dmg_table_target)

end


--[[Moves the caster on the horizontal axis until it has traveled the distance]]
function LeapHorizonal( keys )
    local caster = keys.target
    local ability = keys.ability
    local target = ability.actualtarget

    local target_loc = GetGroundPosition(target:GetAbsOrigin(), target)
    local caster_loc = GetGroundPosition(caster:GetAbsOrigin(), caster)
    local direction = (target_loc - caster_loc):Normalized()

    if (target_loc - caster_loc):Length2D() > 100 then
        caster:SetAbsOrigin(caster:GetAbsOrigin() + direction * ability.velocity)
    else
        caster:InterruptMotionControllers(true)

		if caster:FindModifierByName("modifier_huskar_life_break_datadriven") then
			caster:RemoveModifierByName("modifier_huskar_life_break_datadriven")
		end

		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_huskar/huskar_life_break.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(particle)

		--local effect = ParticleManager:CreateParticle("particles/status_fx/status_effect_huskar_lifebreak.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		--ParticleManager:SetParticleControlEnt(effect, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)

		ability:ApplyDataDrivenModifier(caster, target, "modifier_huskar_life_break_datadriven_debuff", {})

        DoDamage(caster, target, ability)
    end
end

--[[Moves the caster on the vertical axis until movement is interrupted]]
function LeapVertical( keys )
    local caster = keys.target
    local ability = keys.ability
    local target = ability.actualtarget

    --[[
    -- For the first half of the distance the unit goes up and for the second half it goes down
    if ability.leap_traveled < ability.leap_distance/2 then
        -- Go up
        -- This is to memorize the z point when it comes to cliffs and such although the division of speed by 2 isnt necessary, its more of a cosmetic thing
        ability.leap_z = ability.leap_z + ability.leap_speed/2
        -- Set the new location to the current ground location + the memorized z point
        caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster) + Vector(0,0,ability.leap_z))
    else
        -- Go down
        ability.leap_z = ability.leap_z - ability.leap_speed/2
        caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster) + Vector(0,0,ability.leap_z))
    end
    ]]--
end