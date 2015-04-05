--[[
    author: jacklarnes
    email: christucket@gmail.com
    reddit: /u/jacklarnes
    Date: 05.04.2015.
]]

--[[
    issues: might have some tooltips or particles slightly wrong
]]


function lightning_storm_start( keys )
    local target = keys.target
    local caster = keys.caster
    local ability = keys.ability

    ability.jump_count = ability:GetLevelSpecialValueFor("jump_count", ability:GetLevel() - 1)
    ability.radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() - 1)
    ability.jump_delay = ability:GetLevelSpecialValueFor("jump_delay", ability:GetLevel() - 1)
    ability.slow_duration = ability:GetLevelSpecialValueFor("slow_duration", ability:GetLevel() - 1)
    ability.slow_movement_speed = ability:GetLevelSpecialValueFor("slow_movement_speed", ability:GetLevel() - 1)
    ability.damage = ability:GetAbilityDamage()

    lightning_storm_repeat({ caster=caster,
        initial_target=target, 
        jump_count=ability.jump_count, 
        radius=ability.radius,
        jump_delay=ability.jump_delay,
        slow_duration=ability.slow_duration,
        slow_movement_speed=ability.slow_movement_speed,
        damage=ability.damage,
        ability=ability,
        bounceTable={} })
end

function lightning_storm_repeat( params )
    if params.jump_count == 0 or params.initial_target == nil then
        return
    end

    -- hit initial target
    local lightning = ParticleManager:CreateParticle("particles/units/heroes/hero_leshrac/leshrac_lightning_bolt.vpcf", PATTACH_WORLDORIGIN, params.initial_target)
    local loc = params.initial_target:GetAbsOrigin()
    ParticleManager:SetParticleControl(lightning, 0, loc + Vector(0, 0, 1000))
    ParticleManager:SetParticleControl(lightning, 1, loc)
    ParticleManager:SetParticleControl(lightning, 2, loc)
    EmitSoundOn("Hero_Leshrac.Lightning_Storm", params.initial_target)

    local damageTable = {
        attacker = params.caster,
        victim = params.initial_target,
        damage = params.damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = params.ability}
    ApplyDamage(damageTable)

    -- if unit is still alive, apply slow with glow particle
    if params.initial_target:IsAlive() then
        params.ability:ApplyDataDrivenModifier(params.caster, params.initial_target, "lightning_storm_slow", {})
    end

    params.bounceTable[params.initial_target] = 1

    -- find next target (closest one to previous one)
    unitsInRange = FindUnitsInRadius(params.initial_target:GetTeamNumber(),
        params.initial_target:GetAbsOrigin(),
        nil,
        params.radius,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_CLOSEST,
        false)

    params.initial_target = nil
    for k,v in pairs(unitsInRange) do
        if params.bounceTable[v] == nil then
            params.initial_target = v
            break
        end
    end

    params.jump_count = params.jump_count - 1

    -- run the function again in jump_delay seconds
    Timers:CreateTimer(params.jump_delay, 
        function()
            lightning_storm_repeat( params )
        end
    )
end