--[[
    author: jacklarnes
    email: christucket@gmail.com
    reddit: /u/jacklarnes
    Date: 05.04.2015.
]]

--[[
    Notes: logic might be a bit different around when damage ticks/when mana is drained
]]

function pulse_nova_start( keys )
    local caster = keys.caster
    local ability = keys.ability

    local mana_per_sec = ability:GetLevelSpecialValueFor("mana_cost_per_second", ability:GetLevel() - 1)
    local nova_tick = ability:GetLevelSpecialValueFor("nova_tick", ability:GetLevel() - 1)

    pulse_nova_take_mana({caster=caster,
                        ability=ability,
                        mana_per_sec=mana_per_sec,
                        nova_tick=nova_tick})
end

function pulse_nova_take_mana( params )
    if params.ability:GetToggleState() == false then
        return
    end

    params.caster:ReduceMana(params.mana_per_sec)
    if params.caster:GetMana() < params.mana_per_sec then
        params.ability:ToggleAbility()
    end
    
    Timers:CreateTimer(params.nova_tick,
        function()
            pulse_nova_take_mana(params)
        end
    )
end

function pulse_nova_stop( keys )
    local caster = keys.caster
    local sound = "Hero_Leshrac.Pulse_Nova"

    StopSoundEvent(sound, caster)
end