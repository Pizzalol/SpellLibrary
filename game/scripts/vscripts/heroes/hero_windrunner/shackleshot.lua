--[[
    author: jacklarnes, Pizzalol
    email: christucket@gmail.com
    reddit: /u/jacklarnes
    Date: 02.10.2015.

    Finds valid units and trees to latch to if there are any then applies the particle effect and stun duration
]]
function shackleshot_hit( keys )
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local ability_level = ability:GetLevel() - 1

    -- Ability variables
    local stun_duration_long = ability:GetLevelSpecialValueFor("stun_duration", ability_level)
    local stun_duration_fail = ability:GetLevelSpecialValueFor("fail_stun_duration", ability_level)
    local shackle_distance = ability:GetLevelSpecialValueFor("shackle_distance", ability_level)

    -- Calculate the valid positions
    local caster_location = caster:GetAbsOrigin()
    local target_point = target:GetAbsOrigin()

    local shackle_vector = (target_point - caster_location)
    local shackle_vector_range = vector_unit(shackle_vector) * shackle_distance

    local cone_left = RotatePosition(Vector(0,0,0), QAngle(0, -13, 0), shackle_vector_range)
    local cone_right = RotatePosition(Vector(0,0,0), QAngle(0, 13, 0), shackle_vector_range)

    -- Find valid units
    local units = FindUnitsInRadius(caster:GetTeamNumber(),
                            target:GetAbsOrigin(),
                            nil,
                            shackle_distance,
                            DOTA_UNIT_TARGET_TEAM_ENEMY,
                            DOTA_UNIT_TARGET_ALL,
                            DOTA_UNIT_TARGET_FLAG_NONE,
                            FIND_ANY_ORDER,
                            false)

    -- Choose a valid target if possible
    local latch_target = nil
    for k,unit in pairs(units) do
        local unit_vector = unit:GetAbsOrigin() - target_point

        if (not vector_is_clockwise(cone_left, unit_vector)) and vector_is_clockwise(cone_right, unit_vector) then

            if latch_target == nil then
                latch_target = unit
                break
            end
        end
    end

    -- If a valid target has been found then create the particle, apply the stun to both targets and fire the sound effect
    if latch_target ~= nil then
        latch = ParticleManager:CreateParticle("particles/units/heroes/hero_windrunner/windrunner_shackleshot_pair.vpcf", PATTACH_CUSTOMORIGIN, caster)

        ParticleManager:SetParticleControlEnt(latch, 0, target, PATTACH_POINT, "attach_hitloc", target:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(latch, 1, latch_target, PATTACH_POINT, "attach_hitloc", latch_target:GetAbsOrigin(), true)
        ParticleManager:SetParticleControl(latch, 2, Vector(stun_duration_long,0,0))

        ability:ApplyDataDrivenModifier(caster, target, "modifier_shackle_stun_datadriven", {Duration = stun_duration_long})
        ability:ApplyDataDrivenModifier(caster, latch_target, "modifier_shackle_stun_datadriven", {Duration = stun_duration_long})

        EmitSoundOn("Hero_Windrunner.ShackleshotBind", target)
    else
        -- Otherwise repeat the same steps and try to find a valid tree for latching
        local latch_tree = nil
        local trees = GridNav:GetAllTreesAroundPoint(target:GetAbsOrigin(), shackle_distance, false)

        for _,tree in pairs(trees) do
            local tree_vector = tree:GetAbsOrigin() - target_point

            if (not vector_is_clockwise(cone_left, tree_vector)) and vector_is_clockwise(cone_right, tree_vector) then

                if latch_tree == nil then
                    latch_tree = tree
                    break
                end
            end
        end

        -- If a valid tree has been found then do the particle, stun and sound functions
        if latch_tree then
            latch = ParticleManager:CreateParticle("particles/units/heroes/hero_windrunner/windrunner_shackleshot_pair.vpcf", PATTACH_CUSTOMORIGIN, caster)

            ParticleManager:SetParticleControlEnt(latch, 0, target, PATTACH_POINT, "attach_hitloc", target:GetAbsOrigin(), true)
            ParticleManager:SetParticleControl(latch, 1, latch_tree:GetAbsOrigin() + Vector(0,0,128))
            ParticleManager:SetParticleControl(latch, 2, Vector(stun_duration_long,0,0))

            ability:ApplyDataDrivenModifier(caster, target, "modifier_shackle_stun_datadriven", {Duration = stun_duration_long})

            EmitSoundOn("Hero_Windrunner.ShackleshotBind", target)
        else
            -- If no valid tree nor unit was found for latching then apply the short stun duration and play the failure sound
            ability:ApplyDataDrivenModifier(caster, target, "modifier_shackle_stun_datadriven", {Duration = stun_duration_fail})

            EmitSoundOn("Hero_Windrunner.ShackleshotStun", target)
        end
    end
end


function vector_unit( vector )
    local mag = vector_magnitude(vector)
    return Vector(vector.x/math.sqrt(mag), vector.y/math.sqrt(mag))
end

function vector_magnitude( vector )
    return vector.x * vector.x + vector.y * vector.y
end

function vector_is_clockwise(v1, v2)
    return -v1.x * v2.y + v1.y * v2.x > 0
end