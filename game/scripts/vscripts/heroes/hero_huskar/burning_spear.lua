--[[
    Author: Bude
    Date: 30.09.2015

    Removes HP for using Burning Spear
    This is called everytime the ability is used (manual left-click or via auto-cast right-click)
]]
function DoHealthCost( event )
    -- Variables
    local caster = event.caster
    local ability = event.ability
    local health_cost = ability:GetLevelSpecialValueFor( "health_cost" , ability:GetLevel() - 1  )
    local health = caster:GetHealth()
    local new_health = (health - health_cost)

    -- "do damage"
    -- aka set the casters HP to the new value
    -- ModifyHealth's third parameter lets us decide if the healthcost should be lethal
    caster:ModifyHealth(new_health, ability, false, 0)
end

--[[
    Author: Bude
    Date: 30.09.2015

    Increases stack count on the visual modifier
    This is called everytime an enemy is hit by burning_spear
]]
function IncreaseStackCount( event )
    -- Variables
    local caster = event.caster
    local target = event.target
    local ability = event.ability
    local modifier_name = event.modifier_counter_name
    local dur = ability:GetDuration()

    local modifier = target:FindModifierByName(modifier_name)
    local count = target:GetModifierStackCount(modifier_name, caster)

    -- if the unit does not already have the counter modifier we apply it with a stackcount of 1
    -- else we increase the stack and refresh the counters duration
    if not modifier then
        ability:ApplyDataDrivenModifier(caster, target, modifier_name, {duration=dur})
        target:SetModifierStackCount(modifier_name, caster, 1) 
    else
        target:SetModifierStackCount(modifier_name, caster, count+1)
        modifier:SetDuration(dur, true)
    end
end

--[[
    Author: Bude
    Date: 30.09.2015

    Decreases stack count on the visual modifier 
    This is called whenever the debuff modifier runs out
]]
function DecreaseStackCount(event)
    --Variables
    local caster = event.caster
    local target = event.target
    local modifier_name = event.modifier_counter_name
    local modifier = target:FindModifierByName(modifier_name)
    local count = target:GetModifierStackCount(modifier_name, caster)

    -- just some saftey checks -just in case
    if modifier then

        -- if there is something to reduce reduce
        -- else just remove the modifier
        if count and count > 1 then
            target:SetModifierStackCount(modifier_name, caster, count-1)
        else
            target:RemoveModifierByName(modifier_name)
        end
    end
end