--[[
    author: ___ & jacklarnes
    email: christucket@gmail.com
    reddit: /u/jacklarnes

    feel free to contact me with suggestions or if you're finishing it and you have questions
]]

--[[

    copied a lot from primal_split.lua

    so far: no animations, no sounds, hero can attack and be attacked while infested
            does not have all the correct unit targetting right now
            does not treat familiars/spirit bears/etc as special units
            does not do anything on death of caster.host

            caster.ability probably needs to be updated when the target upgrades the spell mid-consume


            right now it looks for the first 5 spells and removes everything but infest
            it tries to add them back with their proper levels. i did not test for anything
            over 5 spells
]]

function infest_check_valid( keys )
    print "is valid"
    local caster = keys.caster
    local target = keys.target

    if target:IsHero() and target:GetTeamNumber() ~= caster:GetTeamNumber() or caster == target then
        caster:Hold()
    end
end

function infest_add_consume( keys )
    if not keys.caster:HasAbility("life_stealer_consume_datadriven") then
        keys.caster:AddAbility("life_stealer_consume_datadriven")
    end
end

function infest_start( keys )
    local target = keys.target
    local caster = keys.caster
    local ability = keys.ability

    caster.ability = {}
    caster.ability["damage"] = ability:GetLevelSpecialValueFor("damage", ability:GetLevel() - 1) 
    caster.ability["range"] = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() - 1) 

    caster.host = target
    caster.removed_spells = {}

    -- Hide the hero underground
    caster:SetAbsOrigin(caster.host:GetAbsOrigin() - Vector(0, 0, 322))
    caster:SwapAbilities("life_stealer_infest_datadriven", "life_stealer_consume_datadriven", false, true) 


    for i = 0, 4 do
        local ability_slot = caster:GetAbilityByIndex(i)
        if ability_slot ~= nil and ability_slot:GetAbilityName() ~= "life_stealer_infest_datadriven" and ability_slot:GetAbilityName() ~= "life_stealer_consume_datadriven" then
            print(ability_slot, ability_slot:GetAbilityName() )
            caster.removed_spells[i] = { ability_slot:GetAbilityName(), ability_slot:GetLevel() }

            print(caster.removed_spells[i][1], caster.removed_spells[i][2])
            caster:RemoveAbility(ability_slot:GetAbilityName())
        end
    end
    --Timers:CreateTimer(10, function() reset(keys) end)
end

function infest_move_unit( keys )
    local caster = keys.caster

    if caster.host == nil or not caster.host:IsAlive() then -- CHANGE THIS PLEASE
        caster:RemoveModifierByName("modifier_infest_hide")
        caster:SwapAbilities("life_stealer_infest_datadriven", "life_stealer_consume_datadriven", true, false) 
    else
        caster:SetAbsOrigin(caster.host:GetAbsOrigin() - Vector(0, 0, 322))
    end

end

function infest_consume(keys)
    print(keys.caster:GetClassname())
    local caster = keys.caster
    local ability = keys.ability


    caster:SetAbsOrigin(caster.host:GetAbsOrigin())
    caster:RemoveModifierByName("modifier_infest_hide")
    caster:SwapAbilities("life_stealer_infest_datadriven", "life_stealer_consume_datadriven", true, false) 

    for i = 0, 4 do
        if caster.removed_spells[i] ~= nil then
            print(caster.removed_spells[i][1], caster.removed_spells[i][2])
            caster:AddAbility(caster.removed_spells[i][1])
            caster:GetAbilityByIndex(i):SetLevel(caster.removed_spells[i][2])
        end
    end

    -- if the unit is not a hero, the unit dies
    if not caster.host:IsHero() then
        -- heal the caster
        caster:Heal(caster.host:GetHealth(), caster)

        caster.host:Kill(ability, caster)
    end

    -- deal aoe damage
    units = FindUnitsInRadius(caster:GetTeamNumber(),
                caster:GetAbsOrigin(),
                nil,
                caster.ability["range"], 
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
                DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER,
                false)

    -- if we find units, deal the damage
    if units ~= nil then
        for k, unit in pairs(units) do
            ApplyDamage({victim = unit,
                        attacker = caster,
                        damage = caster.ability["damage"],
                        damage_type = DAMAGE_TYPE_MAGICAL,
                        ability = ability}) 
        end
    end
end