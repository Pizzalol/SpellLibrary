--[[
    Author: jacklarnes, RcColes
    Date: 08.07.2015.

    Note: feel free to contact me with suggestions or if you're finishing it and you have questions.
    Email: christucket@gmail.com
    reddit: /u/jacklarnes, /u/RcColes

    Note: Problems may occur if used on heroes with more then 5 abilities.
]]

function infest_check_valid( keys )
    local caster = keys.caster
    local target = keys.target

    print(target:GetUnitLabel())
    print(target:GetUnitName())

    if target:IsHero() and target:GetTeamNumber() ~= caster:GetTeamNumber() or caster == target or target:IsCourier() or target:IsBoss() then
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

    -- Strong Dispel
    local RemovePositiveBuffs = false
    local RemoveDebuffs = true
    local BuffsCreatedThisFrameOnly = false
    local RemoveStuns = true
    local RemoveExceptions = false
    caster:Purge( RemovePositiveBuffs, RemoveDebuffs, BuffsCreatedThisFrameOnly, RemoveStuns, RemoveExceptions)

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
    caster:SetAbsOrigin(caster.host:GetAbsOrigin())
    caster:RemoveModifierByName("modifier_infest_hide")
    caster.host:RemoveModifierByName("modifier_infest_buff")
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
    else
        caster:SetAbsOrigin(caster.host:GetAbsOrigin() - Vector(0, 0, 322))
    end

end

function infest_consume(keys)
    print(keys.caster.host:GetUnitLabel())
    print(keys.caster.host:GetUnitName())
    local caster = keys.caster
    local ability = keys.ability


    caster:SetAbsOrigin(caster.host:GetAbsOrigin())
    caster:RemoveModifierByName("modifier_infest_hide")
    caster.host:RemoveModifierByName("modifier_infest_buff")
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