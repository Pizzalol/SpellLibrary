--[[
    Author: Bude
    Date: 29.09.2015.
    Sets some initial values and prepares the caster for motion controllers
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
    ability.target = target
    ability.velocity = charge_speed
    ability.life_break_z = 0
    ability.initial_distance = (GetGroundPosition(target:GetAbsOrigin(), target)-GetGroundPosition(caster:GetAbsOrigin(), caster)):Length2D()
    ability.traveled = 0
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
    local target = ability.target

    local target_loc = GetGroundPosition(target:GetAbsOrigin(), target)
    local caster_loc = GetGroundPosition(caster:GetAbsOrigin(), caster)
    local direction = (target_loc - caster_loc):Normalized()

    if (target_loc - caster_loc):Length2D() >= 1400 then
    	caster:InterruptMotionControllers(true)
    end

    if (target_loc - caster_loc):Length2D() > 100 then
        caster:SetAbsOrigin(caster:GetAbsOrigin() + direction * ability.velocity)
        ability.traveled = ability.traveled + ability.velocity
    else
        caster:InterruptMotionControllers(true)

        caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster))

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

        order = 
        {
            UnitIndex = caster:GetEntityIndex(),
            OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
            TargetIndex = target:GetEntityIndex(),
            Queue = true
        }

        ExecuteOrderFromTable(order)
    end
end

--[[Moves the caster on the vertical axis until movement is interrupted]]
function LeapVertical( keys )
    local caster = keys.target
    local ability = keys.ability
    local target = ability.target

    if caster:GetAbsOrigin().z < GetGroundPosition(caster:GetAbsOrigin(), caster).z then
    	caster:SetAbsOrigin(Vector(caster:GetAbsOrigin().x, caster:GetAbsOrigin().y, 0))
    end

    -- For the first half of the distance the unit goes up and for the second half it goes down
    if ability.traveled < ability.initial_distance/2 then
        -- Go up
        -- This is to memorize the z point when it comes to cliffs and such although the division of speed by 2 isnt necessary, its more of a cosmetic thing
        ability.life_break_z = ability.life_break_z + ability.velocity/2
        -- Set the new location to the current ground location + the memorized z point
        caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster) + Vector(0,0,ability.life_break_z))
    elseif caster:GetAbsOrigin().z > GetGroundPosition(caster:GetAbsOrigin(), caster).z then
        -- Go down
        ability.life_break_z = ability.life_break_z - ability.velocity/2
        caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster) + Vector(0,0,ability.life_break_z))
    end
end