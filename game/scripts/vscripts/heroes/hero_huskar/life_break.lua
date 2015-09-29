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
    local end_time = (target:GetAbsOrigin()-caster:GetAbsOrigin()):Length2D()/(velocity)
    local half_time = end_time/2
    local elapsed_time = 0
    local jump = end_time/(0.03*5)
    local previousPosition

    --[[
    Physics:Unit(caster)

    -- Move the unit
    Timers:CreateTimer(0, function()
        local ground_position = GetGroundPosition(caster:GetAbsOrigin() , caster)

        local ground_poistion2 = GetGroundPosition(target:GetAbsOrigin(), target)
        local direction = (ground_poistion2 - ground_position):Normalized()

        if elapsed_time < half_time then
            --jump
            caster:SetAbsOrigin(caster:GetAbsOrigin() + Vector(0,0,jump)) -- Going up
        elseif caster:GetAbsOrigin().z - ground_position.z > 0 then
            --descend
            caster:SetAbsOrigin(caster:GetAbsOrigin() - Vector(0,0,jump)) -- Going down
        end

        -- If the target reached the enemy
        if (ground_poistion2-ground_position):Length2D() <= 100 or (ground_poistion2-ground_position):Length2D() > 1400 or not target:IsAlive() or
            caster:IsStunned() or caster:IsHexed() or caster:IsOutOfGame() or (previousPosition and (ground_position-previousPosition):Length2D() > velocity*0.06) then
            
            if caster:FindModifierByName("modifier_huskar_life_break_datadriven") then
                caster:RemoveModifierByName("modifier_huskar_life_break_datadriven")
            end

            if (ground_poistion2-ground_position):Length2D() <= 100 then
                EmitSoundOn("Hero_Huskar.Life_Break.Impact", target)

                local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_huskar/huskar_life_break.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
                ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
                ParticleManager:SetParticleControlEnt(particle, 1, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
                ParticleManager:ReleaseParticleIndex(particle)

                --local effect = ParticleManager:CreateParticle("particles/status_fx/status_effect_huskar_lifebreak.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
                --ParticleManager:SetParticleControlEnt(effect, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)

                ability:ApplyDataDrivenModifier(caster, target, "modifier_huskar_life_break_datadriven_debuff", {})

                DoDamage(caster, target, ability)

                if auto_attack_target then
                    order = {
                                UnitIndex = caster:GetEntityIndex(),
                                OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
                                TargetIndex = target:GetEntityIndex(),
                                Queue = false
                            }
                    ExecuteOrderFromTable(order)
                end
            end

            caster:SetAbsOrigin(ground_position)
            caster:SetPhysicsAcceleration(Vector(0,0,0))
            caster:SetPhysicsVelocity(Vector(0,0,0))
            caster:OnPhysicsFrame(nil)
            caster:PreventDI(false)
            caster:SetNavCollisionType(PHYSICS_NAV_SLIDE)
            caster:SetAutoUnstuck(true)
            caster:FollowNavMesh(true)
            caster:SetPhysicsFriction(.05)
            return nil
        end

        caster:PreventDI(false)
        caster:SetAutoUnstuck(false)
        caster:SetNavCollisionType(PHYSICS_NAV_NOTHING)
        caster:FollowNavMesh(false) 
        caster:SetPhysicsVelocity(direction * velocity)

        elapsed_time = elapsed_time + 0.03
        --[[
        time_elapsed = time_elapsed + 0.03
        if time_elapsed < time then
            caster:SetAbsOrigin(caster:GetAbsOrigin() + Vector(0,0,jump)) -- Going up
        else
            caster:SetAbsOrigin(caster:GetAbsOrigin() - Vector(0,0,jump)) -- Going down
        end
        ]--

        previousPosition = ground_position
        return 0.03
    end)
    ]]--
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
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability

    local target_loc = target:GetGroundPosition(target:GetAbsOrigin(), target)
    local caster_loc = caster:GetGroundPosition(caster:GetAbsOrigin(), caster)
    local direction = (target_loc - caster_loc):Normalized()

    if (target:GetAbsOrigin()-caster:GetAbsOrigin()):Length2D() <= 100 then
        caster:SetAbsOrigin(caster:GetAbsOrigin() + direction * ability.velocity)
    else
        caster:InterruptMotionControllers(true)
        DoDamage(caster, target, ability)
    end
end

--[[Moves the caster on the vertical axis until movement is interrupted]]
function LeapVertical( keys )
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability

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