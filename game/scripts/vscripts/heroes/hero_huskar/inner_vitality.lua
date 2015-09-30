LinkLuaModifier( "modifier_huskar_inner_vitality_lua" , "heroes/hero_huskar/modifiers/modifier_inner_vitality.lua" , LUA_MODIFIER_MOTION_NONE )

--[[
    Author: Bude
    Date: 29.09.2015
    Simply applies the lua modifier
--]]

function ApplyLuaModifier( keys )
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local modifiername = keys.ModifierName
    local duration = ability:GetDuration()

    target:AddNewModifier(caster, ability, modifiername, {Duration = duration})
end