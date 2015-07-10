--[[
    author: jacklarnes
    email: christucket@gmail.com
    reddit: /u/jacklarnes
    Date: 05.04.2015.
]]

--[[
    issues: partical doesn't follow the unit
]]


function diabolic_edict_start( keys )
    local caster = keys.caster
    local ability = keys.ability

    ability.num_explosions = ability:GetLevelSpecialValueFor("num_explosions", ability:GetLevel() - 1)
    ability.explosion_delay = ability:GetLevelSpecialValueFor("explosion_delay", ability:GetLevel() - 1)
    ability.radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() - 1)
    ability.tower_bonus = ability:GetLevelSpecialValueFor("tower_bonus", ability:GetLevel() - 1)
    ability.damage = ability:GetAbilityDamage()

    diabolic_edict_repeat({ caster=caster,
        num_explosions=ability.num_explosions,
        explosion_delay=ability.explosion_delay,
        radius=ability.radius,
        damage=ability.damage,
        tower_bonus=ability.tower_bonus,
        ability=ability })
end

function diabolic_edict_repeat( params )
    if params.num_explosions == 0 then
        StopSoundEvent("Hero_Leshrac.Diabolic_Edict_lp", params.caster)
        return
    end

    -- hit initial target
    --[[local lightning = ParticleManager:CreateParticle("particles/units/heroes/hero_leshrac/leshrac_lightning_bolt.vpcf", PATTACH_WORLDORIGIN, params.initial_target)
    local loc = params.initial_target:GetAbsOrigin()
    ParticleManager:SetParticleControl(lightning, 0, loc + Vector(0, 0, 1000))
    ParticleManager:SetParticleControl(lightning, 1, loc)
    ParticleManager:SetParticleControl(lightning, 2, loc)
    EmitSoundOn("Hero_Leshrac.Lightning_Storm", params.initial_target)]]

    -- find next target (closest one to previous one)
    unitsInRange = FindUnitsInRadius(params.caster:GetTeamNumber(),
        params.caster:GetAbsOrigin(),
        nil,
        params.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_MECHANICAL + DOTA_UNIT_TARGET_BUILDING,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false)

    local target = unitsInRange[1]

    local pulse = ParticleManager:CreateParticle("particles/units/heroes/hero_leshrac/leshrac_diabolic_edict.vpcf", PATTACH_WORLDORIGIN, params.caster)
    
    -- if target is nil then pick a random spot to do explosion, 
    -- otherwise do it on target and cause damage
    if target == nil then
        x, y = GetRandomXYInCircle(params.radius)
        local loc = Vector(x, y, 0)
        local caster_loc = params.caster:GetAbsOrigin()
        ParticleManager:SetParticleControl(pulse, 1, caster_loc + loc)
    else
        local target_loc = target:GetAbsOrigin()
        ParticleManager:SetParticleControl(pulse, 1, target_loc)

        --tower_bonus
        local damage = params.damage
        if target:IsTower() then
            damage = damage * (1 + params.tower_bonus/100)
        end

        local damageTable = {
            attacker = params.caster,
            victim = target,
            damage = damage,
            damage_type = DAMAGE_TYPE_PHYSICAL,
            ability = params.ability}
        ApplyDamage(damageTable)
    end
    params.caster:EmitSound("Hero_Leshrac.Diabolic_Edict")

    params.num_explosions = params.num_explosions - 1

    -- run the function again in jump_delay seconds
    Timers:CreateTimer(params.explosion_delay, 
        function()
            diabolic_edict_repeat( params )
        end
    )
end

function GetRandomXYInCircle(radius)
    local degree = math.random(360)
    local radi = math.random(100, radius)

    return math.cos(degree) * radi, math.sin(degree) * radi
end