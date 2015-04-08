--[[
    author: jacklarnes, Pizzalol
    email: christucket@gmail.com
    reddit: /u/jacklarnes
]]
function feast_attack( keys )
    local attacker = keys.attacker
    local target = keys.target
    local ability = keys.ability

    ability.hp_leech_percent = ability:GetLevelSpecialValueFor("hp_leech_percent", ability:GetLevel() - 1)
    local feast_modifier = keys.feast_modifier 

    local damage = target:GetHealth() * (ability.hp_leech_percent / 100)

    -- this sets the number of stacks of damage
    ability:ApplyDataDrivenModifier(attacker, attacker, feast_modifier, {})
    attacker:SetModifierStackCount(feast_modifier, ability, damage)
end

function feast_heal( keys )
  local attacker = keys.attacker
  local target = keys.target
  local ability = keys.ability

  ability.hp_leech_percent = ability:GetLevelSpecialValueFor("hp_leech_percent", ability:GetLevel() - 1)
  local damage = target:GetHealth() * (ability.hp_leech_percent / 100)

  attacker:Heal(damage, ability)
end