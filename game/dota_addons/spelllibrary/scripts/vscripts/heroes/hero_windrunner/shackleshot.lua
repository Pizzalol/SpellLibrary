--[[
    author: jacklarnes
    email: christucket@gmail.com
    reddit: /u/jacklarnes
]]

--[[
    projectile latch particle doesn't work correctly
]]
function shackleshot_hit( keys )
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability

    local debug = false

    -- Ability variables
    local stun_duration_long = ability:GetLevelSpecialValueFor("stun_duration", ability:GetLevel() - 1)
    local stun_duration_fail = ability:GetLevelSpecialValueFor("fail_stun_duration", ability:GetLevel() - 1)
    local shackle_distance = ability:GetLevelSpecialValueFor("shackle_distance", ability:GetLevel() - 1)

    -- Calculate the valid positions
    local caster_location = caster:GetAbsOrigin()
    local target_point = target:GetAbsOrigin()

    local shackle_vector = (target_point - caster_location)
    local shackle_vector_range = vector_unit(shackle_vector) * shackle_distance

    local cone_left = RotatePosition(Vector(0,0,0), QAngle(0, -13, 0), shackle_vector_range)
    local cone_right = RotatePosition(Vector(0,0,0), QAngle(0, 13, 0), shackle_vector_range)


    units = FindUnitsInRadius(caster:GetTeamNumber(),
                            target:GetAbsOrigin(),
                            nil,
                            shackle_distance,
                            DOTA_UNIT_TARGET_TEAM_ENEMY,
                            DOTA_UNIT_TARGET_ALL,
                            DOTA_UNIT_TARGET_FLAG_NONE,
                            FIND_ANY_ORDER,
                            false)

    if debug then 
        DebugDrawClear()
        DebugDrawLine(Vector(0,0,0), cone_left, 0, 0, 255, true, 120)
        DebugDrawLine(Vector(0,0,0), cone_right, 255, 0, 0, true, 120)
    end

    -- Choose a valid target is possible
    local latch_target = nil
    for k,unit in pairs(units) do
        local unit_vector = unit:GetAbsOrigin() - target_point

        if (not vector_is_clockwise(cone_left, unit_vector)) and vector_is_clockwise(cone_right, unit_vector) then
            if debug then DebugDrawCircle(unit_vector, Vector(0, 255, 0), 128, 5, true, 120) end

            if latch_target == nil then
                latch_target = unit
            end

            if not debug then break end
        else
            if debug then DebugDrawCircle(unit_vector, Vector(255, 255, 0), 128, 5, true, 120) end
        end
    end

    -- Fire the sound and particle
    -- Apply the stun modifier
    -- NOTE: particle doesn't work currently
    if latch_target ~= nil then
        latch = ParticleManager:CreateParticle("particles/units/heroes/hero_windrunner/windrunner_shackleshot_pair.vpcf", PATTACH_CUSTOMORIGIN, caster)
        --ParticleManager:SetParticleControl(latch, 0, target:GetAbsOrigin())
        --ParticleManager:SetParticleControl(latch, 1, latch_target:GetAbsOrigin())

        ParticleManager:SetParticleControlEnt(latch, 0, target, PATTACH_POINT, "attach_hitloc", target:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(latch, 1, latch_target, PATTACH_POINT, "attach_hitloc", latch_target:GetAbsOrigin(), true)
        print("latch!")

        ability:ApplyDataDrivenModifier(caster, target, "modifier_shackle_stun_datadriven", {Duration = stun_duration_long})
        ability:ApplyDataDrivenModifier(caster, latch_target, "modifier_shackle_stun_datadriven", {Duration = stun_duration_long})

        EmitSoundOn("Hero_Windrunner.ShackleshotBind", target)
    else
        ability:ApplyDataDrivenModifier(caster, target, "modifier_shackle_stun_datadriven", {Duration = stun_duration_fail})

        EmitSoundOn("Hero_Windrunner.ShackleshotStun", target)
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